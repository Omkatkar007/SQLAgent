"""Configuration loader for SQLAgent.
Reads database and Ollama model configuration from .env file.
"""

import os
from dataclasses import dataclass
from pathlib import Path
from dotenv import load_dotenv


@dataclass
class Config:
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3.2:1b"
    db_host: str = "localhost"
    db_port: int = 3306
    db_name: str = "httpscoo_deverp"
    db_user: str = "root"
    db_password: str = ""
    max_rows: int = 100
    db_connect_timeout: int = 10
    db_query_timeout: int = 30

    @classmethod
    def load(cls, env_path: str = None) -> "Config":
        """Loads configuration from specified or default .env file."""
        if env_path:
            load_dotenv(dotenv_path=env_path)
        else:
            # Default search in current working directory and file directory
            base_dir = Path(__file__).resolve().parent
            env_file = base_dir / ".env"
            if env_file.exists():
                load_dotenv(dotenv_path=env_file)
            else:
                load_dotenv()

        # Fallback helper for MAX_ROWS / MAX ROWS
        max_rows_val = os.getenv("MAX_ROWS") or os.getenv("MAX ROWS") or "100"
        try:
            max_rows = int(max_rows_val.strip())
        except (ValueError, TypeError):
            max_rows = 100

        try:
            db_port = int(os.getenv("DB_PORT", "3306").strip())
        except (ValueError, TypeError):
            db_port = 3306

        try:
            db_connect_timeout = int(os.getenv("DB_CONNECT_TIMEOUT", "10").strip())
        except (ValueError, TypeError):
            db_connect_timeout = 10

        try:
            db_query_timeout = int(os.getenv("DB_QUERY_TIMEOUT", "30").strip())
        except (ValueError, TypeError):
            db_query_timeout = 30

        return cls(
            ollama_base_url=os.getenv("OLLAMA_BASE_URL", "http://localhost:11434").strip(),
            ollama_model=os.getenv("OLLAMA_MODEL", "llama3.2:1b").strip(),
            db_host=os.getenv("DB_HOST", "localhost").strip(),
            db_port=db_port,
            db_name=os.getenv("DB_NAME", "httpscoo_deverp").strip(),
            db_user=os.getenv("DB_USER", "root").strip(),
            db_password=os.getenv("DB_PASSWORD", "").strip(),
            max_rows=max_rows,
            db_connect_timeout=db_connect_timeout,
            db_query_timeout=db_query_timeout,
        )


def get_config(env_path: str = None) -> Config:
    """Helper function to get loaded Config instance."""
    return Config.load(env_path)


if __name__ == "__main__":
    cfg = get_config()
    print("Loaded Configuration:")
    print(f"  Ollama URL:   {cfg.ollama_base_url}")
    print(f"  Ollama Model: {cfg.ollama_model}")
    print(f"  DB Host:      {cfg.db_host}:{cfg.db_port}")
    print(f"  DB Name:      {cfg.db_name}")
    print(f"  DB User:      {cfg.db_user}")
    print(f"  Max Rows:     {cfg.max_rows}")
    print(f"  Timeouts:     connect={cfg.db_connect_timeout}s, query={cfg.db_query_timeout}s")
