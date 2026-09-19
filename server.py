"""FastAPI Web Server for SQLAgent.
Serves REST API endpoints and static frontend assets.
"""

import os
from pathlib import Path
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
import uvicorn
from fastapi import FastAPI, HTTPException, status
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import ollama

from config import get_config, Config
from database import DatabaseManager
from sql_agent import SQLAgent


app = FastAPI(title="SQLAgent API", version="1.0.0")

# Enable CORS for local development flexibility
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"

# Ensure static directory exists
STATIC_DIR.mkdir(exist_ok=True)

# Shared Database & Config instance
config = get_config()
db_manager = DatabaseManager(config)
agent_cache: Dict[str, SQLAgent] = {}


def get_agent_for_model(model_name: Optional[str] = None) -> SQLAgent:
    """Returns or creates a SQLAgent for the specified model."""
    selected_model = model_name or config.ollama_model
    if selected_model not in agent_cache:
        model_config = Config.load()
        model_config.ollama_model = selected_model
        agent_cache[selected_model] = SQLAgent(
            config=model_config, db_manager=db_manager
        )
    return agent_cache[selected_model]


class QueryRequest(BaseModel):
    question: str
    model: Optional[str] = None
    limit: Optional[int] = None


@app.get("/api/health")
async def check_health():
    """Returns health status of database and Ollama."""
    db_ok, db_err = db_manager.test_connection()
    ollama_ok = False
    ollama_err = None
    try:
        client = ollama.Client(host=config.ollama_base_url)
        client.list()
        ollama_ok = True
    except Exception as exc:
        ollama_err = str(exc)

    return {
        "status": "healthy" if (db_ok and ollama_ok) else "degraded",
        "database": {
            "connected": db_ok,
            "host": config.db_host,
            "port": config.db_port,
            "database": config.db_name,
            "error": db_err,
        },
        "ollama": {
            "online": ollama_ok,
            "base_url": config.ollama_base_url,
            "model": config.ollama_model,
            "error": ollama_err,
        },
    }


@app.get("/api/models")
async def list_models():
    """Lists locally installed Ollama models."""
    try:
        client = ollama.Client(host=config.ollama_base_url)
        resp = client.list()
        model_list = [m.model for m in resp.models]
        return {
            "current_model": config.ollama_model,
            "models": model_list,
        }
    except Exception as exc:
        return {
            "current_model": config.ollama_model,
            "models": [config.ollama_model],
            "error": str(exc),
        }


@app.get("/api/schema")
async def get_schema_summary():
    """Returns all tables with column counts and descriptions."""
    schema = db_manager.get_schema()
    summary = []
    for tname, info in schema.items():
        summary.append({
            "name": tname,
            "type": info["type"],
            "column_count": len(info["columns"]),
            "columns": [c["name"] for c in info["columns"]],
            "primary_keys": info["primary_keys"],
            "foreign_keys": info["foreign_keys"],
        })
    return {
        "database": config.db_name,
        "table_count": len(summary),
        "tables": summary,
    }


@app.get("/api/schema/{table_name}")
async def get_table_details(table_name: str):
    """Returns detailed columns and types for a specific table."""
    schema = db_manager.get_schema()
    if table_name not in schema:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Table '{table_name}' not found",
        )
    return {
        "table": table_name,
        "details": schema[table_name],
        "formatted": db_manager.format_table_schema(table_name),
    }


@app.post("/api/query")
async def execute_query(req: QueryRequest):
    """Translates question to SQL and executes it, returning standardized JSON."""
    if not req.question or not req.question.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Question cannot be empty",
        )

    agent = get_agent_for_model(req.model)
    result = agent.ask(req.question.strip(), max_rows=req.limit)
    return JSONResponse(content=result)


# Mount static assets directory
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")


@app.get("/")
async def serve_index():
    """Serves the main frontend index.html."""
    index_path = STATIC_DIR / "index.html"
    if index_path.exists():
        return FileResponse(str(index_path))
    return {"message": "SQLAgent API is running. index.html not yet created."}


def start():
    """Entry point to run server via python server.py."""
    print("Starting SQLAgent Web Server on http://localhost:8000 ...")
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=False, log_level="info")


if __name__ == "__main__":
    start()
