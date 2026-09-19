"""Database interface module for SQLAgent.
Handles MySQL connections, schema introspection, query execution,
and robust JSON-compatible serialization of MySQL data types.
"""

import time
import json
from decimal import Decimal
from datetime import date, datetime, time as dtime, timedelta
from typing import Any, Dict, List, Optional, Tuple
import mysql.connector
from mysql.connector import errorcode

from config import Config, get_config


def serialize_db_value(val: Any) -> Any:
    """Converts MySQL-specific data types to JSON-serializable Python primitives."""
    if val is None:
        return None
    if isinstance(val, Decimal):
        # Convert Decimal to int if no fractional component, else float
        return int(val) if val % 1 == 0 else float(val)
    if isinstance(val, (datetime, date, dtime)):
        return val.isoformat()
    if isinstance(val, timedelta):
        return str(val)
    if isinstance(val, (bytes, bytearray)):
        try:
            return val.decode("utf-8")
        except UnicodeDecodeError:
            return val.hex()
    if isinstance(val, (set, frozenset)):
        return list(val)
    return val


def make_json_serializable(data: Any) -> Any:
    """Recursively converts structures (dicts, lists, tuples) into JSON-serializable types."""
    if isinstance(data, dict):
        return {str(k): make_json_serializable(v) for k, v in data.items()}
    if isinstance(data, (list, tuple)):
        return [make_json_serializable(item) for item in data]
    return serialize_db_value(data)


class DatabaseManager:
    """Manages MySQL database connections, metadata inspection, and query execution."""

    def __init__(self, config: Optional[Config] = None):
        self.config = config or get_config()
        self._schema_cache: Optional[Dict[str, Any]] = None

    def get_connection(self):
        """Creates and returns a new MySQL database connection."""
        return mysql.connector.connect(
            host=self.config.db_host,
            port=self.config.db_port,
            database=self.config.db_name,
            user=self.config.db_user,
            password=self.config.db_password,
            connection_timeout=self.config.db_connect_timeout,
            autocommit=True,
        )

    def test_connection(self) -> Tuple[bool, Optional[str]]:
        """Tests database connectivity. Returns (True, None) if successful."""
        try:
            conn = self.get_connection()
            conn.ping(reconnect=True, attempts=1, delay=0)
            conn.close()
            return True, None
        except Exception as exc:
            return False, str(exc)

    def get_schema(self, force_refresh: bool = False) -> Dict[str, Any]:
        """Introspects and caches all tables, columns, and foreign keys in the database."""
        if self._schema_cache is not None and not force_refresh:
            return self._schema_cache

        schema: Dict[str, Any] = {}
        conn = self.get_connection()
        try:
            cursor = conn.cursor(dictionary=True)

            # 1. Fetch all tables and views
            cursor.execute(
                """
                SELECT TABLE_NAME, TABLE_TYPE, TABLE_COMMENT 
                FROM information_schema.TABLES 
                WHERE TABLE_SCHEMA = %s 
                ORDER BY TABLE_NAME
                """,
                (self.config.db_name,),
            )
            tables = cursor.fetchall()

            for tbl in tables:
                tname = tbl["TABLE_NAME"]
                schema[tname] = {
                    "type": tbl["TABLE_TYPE"],
                    "comment": tbl.get("TABLE_COMMENT") or "",
                    "columns": [],
                    "column_names": [],
                    "primary_keys": [],
                    "foreign_keys": [],
                }

            # 2. Fetch all columns
            cursor.execute(
                """
                SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, 
                       IS_NULLABLE, COLUMN_KEY, EXTRA, COLUMN_COMMENT
                FROM information_schema.COLUMNS 
                WHERE TABLE_SCHEMA = %s 
                ORDER BY TABLE_NAME, ORDINAL_POSITION
                """,
                (self.config.db_name,),
            )
            columns = cursor.fetchall()
            for col in columns:
                tname = col["TABLE_NAME"]
                if tname in schema:
                    cname = col["COLUMN_NAME"]
                    schema[tname]["columns"].append({
                        "name": cname,
                        "data_type": col["DATA_TYPE"],
                        "full_type": col["COLUMN_TYPE"],
                        "nullable": col["IS_NULLABLE"] == "YES",
                        "key": col["COLUMN_KEY"],
                        "extra": col["EXTRA"],
                        "comment": col.get("COLUMN_COMMENT") or "",
                    })
                    schema[tname]["column_names"].append(cname)
                    if col["COLUMN_KEY"] == "PRI":
                        schema[tname]["primary_keys"].append(cname)

            # 3. Fetch foreign key relationships
            cursor.execute(
                """
                SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
                FROM information_schema.KEY_COLUMN_USAGE
                WHERE TABLE_SCHEMA = %s AND REFERENCED_TABLE_NAME IS NOT NULL
                ORDER BY TABLE_NAME, COLUMN_NAME
                """,
                (self.config.db_name,),
            )
            fkeys = cursor.fetchall()
            for fk in fkeys:
                tname = fk["TABLE_NAME"]
                if tname in schema:
                    schema[tname]["foreign_keys"].append({
                        "column": fk["COLUMN_NAME"],
                        "ref_table": fk["REFERENCED_TABLE_NAME"],
                        "ref_column": fk["REFERENCED_COLUMN_NAME"],
                    })

            self._schema_cache = schema
            return schema
        finally:
            conn.close()

    def get_table_names(self) -> List[str]:
        """Returns list of all table and view names."""
        schema = self.get_schema()
        return list(schema.keys())

    def format_table_schema(self, table_name: str, include_foreign_keys: bool = True) -> str:
        """Formats a single table's schema into a concise, LLM-friendly string."""
        schema = self.get_schema()
        if table_name not in schema:
            return f"Table `{table_name}` not found."

        info = schema[table_name]
        cols_str = []
        for c in info["columns"]:
            tag = "PK" if c["key"] == "PRI" else ("MUL" if c["key"] == "MUL" else "")
            type_str = c["full_type"] if c["data_type"] in ("enum", "set") else c["data_type"]
            col_desc = f"`{c['name']}` {type_str}"
            if tag:
                col_desc += f" [{tag}]"
            cols_str.append(col_desc)

        lines = [f"Table: `{table_name}`"]
        lines.append(f"  Columns: {', '.join(cols_str)}")

        if include_foreign_keys and info["foreign_keys"]:
            fk_strs = [
                f"`{fk['column']}` -> `{fk['ref_table']}`.`{fk['ref_column']}`"
                for fk in info["foreign_keys"]
            ]
            lines.append(f"  Foreign Keys: {', '.join(fk_strs)}")

        return "\n".join(lines)

    def execute_query(
        self,
        sql_query: str,
        max_rows: Optional[int] = None,
    ) -> Tuple[List[Dict[str, Any]], float]:
        """Executes a SQL query and returns (rows as dicts, execution_time_ms).
        Converts all fields into JSON-serializable types.
        """
        limit = max_rows if max_rows is not None else self.config.max_rows
        conn = self.get_connection()
        start_time = time.perf_counter()

        try:
            cursor = conn.cursor(dictionary=True)
            # Set query execution timeout if supported by session
            try:
                timeout_ms = self.config.db_query_timeout * 1000
                cursor.execute(f"SET SESSION max_execution_time = {timeout_ms};")
            except Exception:
                pass  # Not all MySQL/MariaDB engines support max_execution_time

            cursor.execute(sql_query)

            # If the query returns a result set (e.g. SELECT, SHOW, DESCRIBE)
            if cursor.description:
                raw_rows = cursor.fetchmany(limit)
                rows = [make_json_serializable(row) for row in raw_rows]
            else:
                rows = [{"affected_rows": cursor.rowcount}]

            elapsed_ms = round((time.perf_counter() - start_time) * 1000, 2)
            return rows, elapsed_ms

        finally:
            conn.close()


if __name__ == "__main__":
    db = DatabaseManager()
    ok, err = db.test_connection()
    print("Database Connection Test:", "SUCCESS" if ok else f"FAILED ({err})")
    if ok:
        tables = db.get_table_names()
        print(f"Total tables found: {len(tables)}")
        sample_tbl = "fintech_customer" if "fintech_customer" in tables else tables[0]
        print(f"\nSample Schema for {sample_tbl}:")
        print(db.format_table_schema(sample_tbl))

        print(f"\nSample Query Test (first 2 rows of {sample_tbl}):")
        rows, elapsed = db.execute_query(f"SELECT * FROM `{sample_tbl}` LIMIT 2")
        print(f"Executed in {elapsed}ms. Rows returned: {len(rows)}")
        print(json.dumps(rows, indent=2))
