"""SQLAgent Module.
Translates natural language questions from end users into SQL queries,
executes them against the configured MySQL database, and returns results in structured JSON.
Includes dynamic schema pruning, query sanitization, safety guardrails, intelligent diagnostics,
and single-turn self-healing retries.
"""

import re
import json
import time
import difflib
from typing import Any, Dict, List, Optional, Tuple
import ollama

from config import Config, get_config
from database import DatabaseManager, make_json_serializable


# Forbidden statements for read-only safety guard
DANGEROUS_PATTERNS = [
    r"\bDROP\b",
    r"\bDELETE\b",
    r"\bUPDATE\b",
    r"\bINSERT\b",
    r"\bALTER\b",
    r"\bTRUNCATE\b",
    r"\bRENAME\b",
    r"\bCREATE\b",
    r"\bGRANT\b",
    r"\bREVOKE\b",
]

# Allowed statement openers
ALLOWED_PREFIXES = ("SELECT", "SHOW", "DESCRIBE", "EXPLAIN", "WITH")

# Auxiliary system tables that shouldn't be included unless explicitly mentioned
AUXILIARY_TABLE_KEYWORDS = ("configuration", "ai_", "api_key", "audit", "notification", "permission")


class SQLAgent:
    """Intelligent Text-to-SQL Agent powered by Ollama and MySQL."""

    def __init__(
        self,
        config: Optional[Config] = None,
        db_manager: Optional[DatabaseManager] = None,
        verbose: bool = False,
    ):
        self.config = config or get_config()
        self.db = db_manager or DatabaseManager(self.config)
        self.verbose = verbose
        self.client = ollama.Client(host=self.config.ollama_base_url)

    def log(self, *args):
        """Prints log messages if verbose mode is enabled."""
        if self.verbose:
            print("[SQLAgent]", *args)

    def find_relevant_tables(self, question: str, top_k: int = 3) -> List[str]:
        """Finds the most relevant tables for the given question based on keywords,
        table names, column names, and foreign key relations.
        """
        schema = self.db.get_schema()
        # Extract meaningful alphanumeric words (length >= 3)
        tokens = [w.lower() for w in re.findall(r"\b[a-zA-Z]{3,}\b", question.lower())]
        scores: Dict[str, int] = {}
        q_lower = question.lower()

        for tname, info in schema.items():
            score = 0
            t_clean = tname.lower().replace("fintech_", "").replace("vw_", "")
            t_clean_spaced = t_clean.replace("_", " ")

            # Downweight views unless requested
            if tname.startswith("vw_") and not any(kw in q_lower for kw in ("view", "report", "kpi", "summary")):
                score -= 40

            # Downweight auxiliary / config tables unless user asked for them
            is_aux = any(kw in tname.lower() for kw in AUXILIARY_TABLE_KEYWORDS)
            user_asked_aux = any(kw in q_lower for kw in AUXILIARY_TABLE_KEYWORDS)
            if is_aux and not user_asked_aux:
                score -= 80

            # Exact multi-word phrase matches table name (e.g. "account type" in "fintech_account_type")
            if t_clean_spaced in q_lower:
                score += 70

            t_parts = t_clean.split("_")
            for token in tokens:
                stem = token.rstrip("s")
                if stem == t_clean or token == t_clean:
                    score += 50
                elif stem in t_parts or token in t_parts:
                    score += 35
                elif stem in t_clean or t_clean in stem:
                    score += 15

            # Match against column names (both full phrase and individual tokens)
            for col in info["column_names"]:
                c_clean = col.lower()
                c_spaced = c_clean.replace("_", " ")
                if c_spaced in q_lower:
                    score += 30
                elif c_clean in tokens:
                    score += 15
                else:
                    c_parts = c_clean.split("_")
                    for token in tokens:
                        stem = token.rstrip("s")
                        if stem in c_parts or token in c_parts:
                            score += 5

            scores[tname] = score

        # Rank tables by score
        sorted_tables = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        relevant = [tbl for tbl, sc in sorted_tables[:top_k] if sc > 0]

        # If no tables matched specifically, pick fundamental core tables
        if not relevant:
            core_defaults = [
                "fintech_customer",
                "fintech_account",
                "fintech_transaction",
                "fintech_loan",
            ]
            relevant = [t for t in core_defaults if t in schema][:top_k]

        # If the top table is dominant and has high score, keep it isolated to prevent unnecessary joins
        if len(relevant) > 1 and sorted_tables[0][1] >= 100:
            if sorted_tables[0][1] >= (sorted_tables[1][1] * 1.5):
                relevant = [relevant[0]]

        # Follow foreign keys to ensure necessary JOIN partners are included (only if multiple entities queried)
        if len(relevant) > 1:
            for tname in list(relevant):
                if tname in schema:
                    for fk in schema[tname]["foreign_keys"]:
                        ref_t = fk["ref_table"]
                        if ref_t in schema and ref_t not in relevant and len(relevant) < (top_k + 2):
                            relevant.append(ref_t)

        self.log(f"Selected relevant tables for '{question}': {relevant}")
        return relevant

    def build_system_prompt(self, relevant_tables: List[str]) -> str:
        """Constructs a schema-rich, instruction-focused prompt for the LLM."""
        table_schemas = "\n\n".join(
            self.db.format_table_schema(tbl) for tbl in relevant_tables
        )

        return (
            "You are an expert MySQL database query generator.\n"
            "Given the user question and the database schema below, write a single valid MySQL SELECT query.\n\n"
            "CRITICAL RULES:\n"
            "1. Output ONLY the raw SQL query. Do NOT include markdown blocks (no ```sql or ```). Do NOT provide explanations or apologies.\n"
            "2. Use ONLY the exact tables and column names specified in the schema below. NEVER guess or invent column names.\n"
            "3. Exact table names must be used (e.g., `fintech_customer`, NOT `customer`; `fintech_account_type`, NOT `account_type`).\n"
            "4. Only generate safe, read-only SELECT or SHOW queries. NEVER use DROP, DELETE, INSERT, UPDATE, ALTER, or TRUNCATE.\n"
            "5. NEVER join a table to itself (NO self-joins like `FROM table t1 JOIN table t2`).\n"
            "6. If all requested columns exist in a single table, use a simple `SELECT ... FROM table` with NO JOINs.\n"
            "7. Only JOIN different tables when columns must come from multiple distinct tables.\n"
            "8. If joining tables, use the exact foreign key relationships indicated in the schema.\n"
            "9. Use standard MySQL functions (e.g., COUNT(*), SUM(), AVG(), DATE(), NOW()).\n\n"
            f"DATABASE SCHEMA:\n{table_schemas}"
        )

    def clean_and_validate_sql(
        self, raw_output: str, max_rows: int
    ) -> Tuple[bool, str, Optional[str]]:
        """Cleans LLM response, strips markdown fences, validates safety,
        and enforces LIMIT clause.
        """
        cleaned = raw_output.strip()
        cleaned = re.sub(r"^```(?:sql)?\s*", "", cleaned, flags=re.IGNORECASE)
        cleaned = re.sub(r"\s*```$", "", cleaned)
        cleaned = cleaned.strip()

        # Extract SQL statement if surrounding text exists
        match = re.search(
            r"\b(SELECT\b[\s\S]+?|SHOW\b[\s\S]+?|DESCRIBE\b[\s\S]+?|EXPLAIN\b[\s\S]+?|WITH\b[\s\S]+?)(?:;|\n\n|$)",
            cleaned,
            re.IGNORECASE,
        )
        if match:
            cleaned = match.group(1).strip()

        # Remove trailing semicolon
        cleaned = cleaned.rstrip(";").strip()

        # Validate allowed prefix
        upper_query = cleaned.upper()
        if not any(upper_query.startswith(prefix) for prefix in ALLOWED_PREFIXES):
            return (
                False,
                cleaned,
                "Query is not a permitted read-only statement (must begin with SELECT, SHOW, DESCRIBE, EXPLAIN, or WITH).",
            )

        # Check for forbidden dangerous statements
        for pattern in DANGEROUS_PATTERNS:
            if re.search(pattern, upper_query):
                return (
                    False,
                    cleaned,
                    f"Query rejected by safety guard: disallowed statement pattern matched ({pattern}).",
                )

        # Enforce LIMIT if not present in SELECT
        if upper_query.startswith("SELECT") and not re.search(r"\bLIMIT\b\s+\d+", upper_query):
            cleaned = f"{cleaned} LIMIT {max_rows}"

        return True, cleaned, None

    def diagnose_and_suggest_fix(
        self, error_msg: str, relevant_tables: List[str]
    ) -> Tuple[Optional[str], Optional[str], Optional[str]]:
        """Analyzes MySQL error message to provide precise column/table suggestions.
        Returns: (diagnostic_text, bad_column, suggested_column)
        """
        schema = self.db.get_schema()

        # Check for unknown column error: Unknown column 'col' in 'field list'
        col_match = re.search(r"Unknown column '([^']+)'", error_msg)
        if col_match:
            bad_col = col_match.group(1).split(".")[-1].strip("`")
            suggestions = []
            best_replacement = None

            for tname in relevant_tables:
                if tname in schema:
                    cols = schema[tname]["column_names"]
                    # Check fuzzy match
                    matches = difflib.get_close_matches(bad_col, cols, n=2, cutoff=0.25)
                    # Check token overlap (e.g. 'amount' in 'disbursed_amount')
                    bad_parts = bad_col.split("_")
                    token_matches = [
                        c for c in cols
                        if any(part in c for part in bad_parts if len(part) >= 3)
                    ]
                    combined = list(dict.fromkeys(matches + token_matches))

                    if combined:
                        if not best_replacement:
                            best_replacement = combined[0]
                        suggestions.append(
                            f"- In `{tname}`, invalid column '{bad_col}' does not exist. Did you mean `{combined[0]}`? (All matching columns: {combined})"
                        )
                    else:
                        suggestions.append(f"- Available columns in `{tname}`: {cols}")

            diag_text = (
                f"Column '{bad_col}' does not exist.\n" + "\n".join(suggestions)
                if suggestions
                else f"Column '{bad_col}' does not exist."
            )
            return diag_text, bad_col, best_replacement

        # Check for table doesn't exist error
        tbl_match = re.search(r"Table '([^']+)' doesn't exist", error_msg)
        if tbl_match:
            bad_tbl = tbl_match.group(1).split(".")[-1].strip("`")
            all_tbls = list(schema.keys())
            close_tbls = difflib.get_close_matches(bad_tbl, all_tbls, n=3, cutoff=0.25)
            diag_text = f"Table `{bad_tbl}` does not exist."
            if close_tbls:
                diag_text += f" Did you mean one of: {close_tbls}?"
            return diag_text, bad_tbl, (close_tbls[0] if close_tbls else None)

        return None, None, None

    def generate_sql(
        self,
        question: str,
        relevant_tables: List[str],
        repair_context: Optional[str] = None,
    ) -> str:
        """Sends prompt to Ollama LLM to generate SQL."""
        system_prompt = self.build_system_prompt(relevant_tables)

        if repair_context:
            user_content = (
                f"User Question: '{question}'\n\n"
                f"{repair_context}\n\n"
                f"Write the corrected valid MySQL query. Return ONLY the raw SQL query."
            )
        else:
            user_content = question

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_content},
        ]

        response = self.client.chat(
            model=self.config.ollama_model,
            messages=messages,
            options={"temperature": 0.0},
        )
        return response["message"]["content"].strip()

    def ask(self, question: str, max_rows: Optional[int] = None) -> Dict[str, Any]:
        """Processes a natural language question, converts it to SQL, executes it,
        and returns the complete result as a Python dictionary.
        """
        limit = max_rows if max_rows is not None else self.config.max_rows
        start_total = time.perf_counter()

        relevant_tables = self.find_relevant_tables(question)

        current_sql = ""
        max_retries = 3
        last_error = None
        rows = []
        exec_time_ms = 0.0
        repair_context = None

        for attempt in range(1, max_retries + 1):
            self.log(f"Attempt {attempt}/{max_retries} to generate/execute SQL...")
            try:
                # 1. Generate SQL from LLM
                raw_sql = self.generate_sql(
                    question=question,
                    relevant_tables=relevant_tables,
                    repair_context=repair_context,
                )
                self.log(f"Raw LLM output: {raw_sql}")

                # 2. Clean and validate SQL safety
                is_valid, cleaned_sql, validation_error = self.clean_and_validate_sql(
                    raw_sql, max_rows=limit
                )
                current_sql = cleaned_sql

                if not is_valid:
                    raise ValueError(validation_error)

                self.log(f"Executing SQL: {current_sql}")

                # 3. Execute query
                rows, exec_time_ms = self.db.execute_query(current_sql, max_rows=limit)
                last_error = None
                break  # Successful execution!

            except Exception as exc:
                err_msg = str(exc)
                last_error = err_msg
                self.log(f"Attempt {attempt} failed with error: {err_msg}")

                if attempt < max_retries:
                    diag, bad_target, suggested_target = self.diagnose_and_suggest_fix(
                        err_msg, relevant_tables
                    )
                    diag_str = f"\n{diag}" if diag else ""
                    hint_str = (
                        f"\nPlease replace `{bad_target}` with `{suggested_target}`."
                        if bad_target and suggested_target
                        else ""
                    )

                    repair_context = (
                        f"A previous attempt generated this SQL query:\n"
                        f"{current_sql}\n\n"
                        f"However, execution failed with this database error:\n"
                        f"'{err_msg}'{diag_str}{hint_str}"
                    )

        total_elapsed_ms = round((time.perf_counter() - start_total) * 1000, 2)

        if last_error:
            result = {
                "status": "error",
                "question": question,
                "sql_query": current_sql,
                "row_count": 0,
                "data": [],
                "error": last_error,
                "execution_time_ms": total_elapsed_ms,
            }
        else:
            result = {
                "status": "success",
                "question": question,
                "sql_query": current_sql,
                "row_count": len(rows),
                "data": rows,
                "error": None,
                "execution_time_ms": exec_time_ms,
            }

        return make_json_serializable(result)

    def ask_json(
        self, question: str, max_rows: Optional[int] = None, indent: int = 2
    ) -> str:
        """Processes a natural language question and returns the JSON string."""
        res = self.ask(question, max_rows=max_rows)
        return json.dumps(res, indent=indent, default=str)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="SQLAgent CLI")
    parser.add_argument("-q", "--question", type=str, help="Natural language question to ask")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging")
    parser.add_argument("--limit", type=int, default=None, help="Maximum number of rows to return")
    args = parser.parse_args()

    agent = SQLAgent(verbose=args.verbose)

    if args.question:
        json_output = agent.ask_json(args.question, max_rows=args.limit)
        print(json_output)
    else:
        # Self-test with sample query
        test_q = "How many customers are there?"
        print(f"Running test question: '{test_q}'\n")
        print(agent.ask_json(test_q))
