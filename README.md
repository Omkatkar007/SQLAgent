# 🤖 SQLAgent - Natural Language to SQL Assistant

An intelligent, schema-aware **Text-to-SQL Agent** that translates natural language questions into safe, optimized MySQL queries using local **Ollama** LLMs (`llama3.2:1b`, `llama3:latest`) and delivers results in structured **JSON** and an interactive **Web UI**.

---

## 🚀 Key Features

- **🧠 Schema-Aware Context Pruning**: Automatically ranks and injects only the most relevant tables and foreign keys from 100+ database tables, keeping LLM prompts focused and accurate.
- **🛡️ Read-Only Guardrails**: Prohibits destructive statements (`DROP`, `DELETE`, `UPDATE`, `INSERT`, `ALTER`, `TRUNCATE`) and automatically enforces row limits.
- **🔄 Self-Healing Query Repair**: Automatically diagnoses database execution errors (such as column hallucinations or typos), suggests closest matching valid columns, and retries with the LLM.
- **📊 Standardized JSON Output**: Returns structured JSON payloads with execution time, row count, status, query, and data records.
- **✨ Cyber-Glassmorphism Web UI**: Modern dark-mode interface built with Vanilla HTML5/CSS3/JavaScript and FastAPI backend. Includes live schema exploration, model switching, dual Table/JSON views, and quick prompt chips.
- **💻 CLI & Python Library**: Run queries from terminal, interactive prompt, or import as a Python package.

---

## 🏗️ Architecture

```
User Question
     │
     ▼
┌────────────────────────────────────────┐
│               SQLAgent                 │
│  1. Relevance Ranking & Schema Pruner  │
│  2. Prompt Builder                     │
└──────────────────┬─────────────────────┘
                   │
                   ▼
       Ollama LLM (llama3.2:1b / llama3)
                   │
                   ▼
┌────────────────────────────────────────┐
│  SQL Sanitizer & Safety Validator      │
└──────────────────┬─────────────────────┘
                   │
                   ▼
         MySQL Database Execution
         (Self-Healing Retry on Error)
                   │
                   ▼
┌────────────────────────────────────────┐
│      JSON Formatter / Serializer       │
└──────────────────┬─────────────────────┘
                   │
       ┌───────────┴───────────┐
       ▼                       ▼
  JSON Payload         Interactive Web UI
 (CLI / API)          (FastAPI / HTML5)
```

---

## 📦 Project Structure

```
├── .env                  # Local database and model credentials (git-ignored)
├── .env.example          # Environment variable template
├── config.py             # Configuration loader module
├── database.py           # MySQL manager, schema inspector, and JSON serializer
├── sql_agent.py          # Core SQLAgent engine (prompting, safety, self-healing)
├── server.py             # FastAPI web server
├── main.py               # Interactive CLI & command-line interface
├── test_sql_agent.py     # Automated unit test suite
├── requirements.txt      # Python dependencies
└── static/               # Frontend assets
    ├── index.html        # Web interface structure
    ├── style.css         # Dark glassmorphism stylesheet
    └── app.js            # Frontend state and API controller
```

---

## ⚡ Quick Start

### 1. Prerequisites
- Python 3.10+
- MySQL Server (running with target database)
- Ollama installed and running locally (`ollama pull llama3.2:1b`)

### 2. Installation
```bash
git clone https://github.com/Omkatkar007/SQLAgent.git
cd SQLAgent
pip install -r requirements.txt
```

### 3. Configuration
Copy `.env.example` to `.env` and set your credentials:
```env
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:1b
DB_HOST=localhost
DB_PORT=3306
DB_NAME=httpscoo_deverp
DB_USER=root
DB_PASSWORD=your_password
MAX_ROWS=100
DB_CONNECT_TIMEOUT=10
DB_QUERY_TIMEOUT=30
```

---

## 🖥️ Usage

### 🌐 1. Launch the Web Interface
```bash
python server.py
```
Open **[http://localhost:8000](http://localhost:8000)** in your browser.

### 💬 2. Interactive CLI Prompt
```bash
python main.py
```

### ⌨️ 3. Single-Query Command Line
```bash
# Output JSON directly to stdout
python main.py -q "How many customers are there?"

# Limit output to 5 rows
python main.py -l 5 -q "Show 5 loans with status and amount"

# Override Ollama model
python main.py -m llama3:latest -q "What account types exist?"
```

### 🐍 4. Python Programmatic Usage
```python
from sql_agent import SQLAgent

agent = SQLAgent()

# Returns Python dict
result = agent.ask("How many customers are in the database?")
print(result["data"])

# Returns formatted JSON string
json_output = agent.ask_json("Show top 5 branches")
print(json_output)
```

---

## 🧪 Running Tests

```bash
python -m unittest test_sql_agent.py
```

---

## 📄 License
MIT License
