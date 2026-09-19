"""Main Entry Point for SQLAgent.
Supports both an Interactive CLI mode and Single-Question CLI argument mode.
Outputs all query responses in structured JSON format.
"""

import sys
import json
import argparse
from typing import Optional

from config import get_config
from database import DatabaseManager
from sql_agent import SQLAgent


def print_banner(db_name: str, table_count: int, model: str, host: str):
    """Prints a friendly startup banner."""
    print("=" * 65)
    print("                   SQLAgent - MySQL Assistant            ")
    print("=" * 65)
    print(f" Database: {db_name} ({table_count} tables)")
    print(f" Model:    {model} via {host}")
    print(" Commands: Type 'exit', 'quit', or 'q' to stop.")
    print("=" * 65)


def run_interactive_mode(agent: SQLAgent):
    """Runs interactive loop asking the end user for questions."""
    db_name = agent.config.db_name
    tables = agent.db.get_table_names()
    print_banner(
        db_name=db_name,
        table_count=len(tables),
        model=agent.config.ollama_model,
        host=agent.config.ollama_base_url,
    )

    while True:
        try:
            print()
            question = input("Enter your question: ").strip()
            if not question:
                continue
            if question.lower() in ("exit", "quit", "q"):
                print("\nGoodbye!")
                break

            print("\nGenerating SQL and querying database...")
            result = agent.ask(question)

            # Display formatted JSON output
            json_str = json.dumps(result, indent=2, default=str)
            print("\nResult (JSON):")
            print(json_str)

        except (KeyboardInterrupt, EOFError):
            print("\n\nSession terminated. Goodbye!")
            break
        except Exception as exc:
            err_json = {
                "status": "error",
                "question": question if "question" in locals() else "",
                "sql_query": "",
                "row_count": 0,
                "data": [],
                "error": str(exc),
                "execution_time_ms": 0.0,
            }
            print(json.dumps(err_json, indent=2))


def main():
    parser = argparse.ArgumentParser(
        description="SQLAgent: Natural Language to SQL with JSON results"
    )
    parser.add_argument(
        "-q", "--question", type=str, help="Natural language question to execute"
    )
    parser.add_argument(
        "-m", "--model", type=str, default=None, help="Override Ollama model name"
    )
    parser.add_argument(
        "-l", "--limit", type=int, default=None, help="Maximum number of rows to return"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Enable verbose diagnostics"
    )
    parser.add_argument(
        "--raw", action="store_true", help="Output compact non-indented JSON"
    )

    args = parser.parse_args()

    # Load configuration
    cfg = get_config()
    if args.model:
        cfg.ollama_model = args.model

    agent = SQLAgent(config=cfg, verbose=args.verbose)

    # If question provided via CLI arguments, run in single-shot mode
    if args.question:
        result = agent.ask(args.question, max_rows=args.limit)
        indent = None if args.raw else 2
        print(json.dumps(result, indent=indent, default=str))
        sys.exit(0 if result["status"] == "success" else 1)

    # Otherwise run interactive CLI mode
    run_interactive_mode(agent)


if __name__ == "__main__":
    main()
