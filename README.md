# 🧠 SQL AI Assistant (Text-to-SQL RAG Pipeline)

An intelligent web application that allows non-technical business users to query a live MySQL retail database using plain English. It translates natural language into highly accurate SQL queries, executes them securely, and returns the data in a clean web interface.

## 🚀 Features

- **Natural Language to SQL:** Ask complex business questions in plain English.
- **Dynamic Few-Shot Prompting:** Uses a Vector Database (ChromaDB) to inject mathematically similar historical queries into the prompt, practically eliminating LLM hallucinations and SQL syntax errors.
- **Ultra-Low Latency:** Powered by `openai/gpt-oss-20b` running on the **Groq API** for lightning-fast query generation.
- **Robust Parsing:** Built-in Regex parsers to cleanly extract executable SQL from conversational LLM outputs.
- **Local Embeddings:** Uses HuggingFace's `all-MiniLM-L6-v2` for 100% free, local, and instant vector embeddings.

## 🛠️ Architecture & Tech Stack

- **Frontend:** Streamlit
- **Orchestration:** LangChain (`create_sql_query_chain`)
- **LLM:** `openai/gpt-oss-20b` via Groq
- **Vector Database:** ChromaDB (In-Memory Ephemeral)
- **Embeddings:** HuggingFace (`sentence-transformers/all-MiniLM-L6-v2`)
- **Database:** MySQL (AWS RDS) via SQLAlchemy / PyMySQL

## ⚙️ Setup & Installation

### 1. Clone the repository and navigate to the project directory
```bash
git clone <your-repo-url>
cd sql
```

### 2. Install dependencies
It is recommended to use a virtual environment.
```bash
pip install -r requirements.txt
```

### 3. Configure Secrets
Streamlit uses a `secrets.toml` file to manage environment variables safely. 
Create a folder named `.streamlit` in the root directory and add a file named `secrets.toml`:

```bash
mkdir .streamlit
touch .streamlit/secrets.toml
```

Add your API keys and Database credentials to `.streamlit/secrets.toml`:
```toml
GROQ_API_KEY = "your_groq_api_key_here"

DB_USER = "your_database_username"
DB_PASSWORD = "your_database_password"
DB_HOST = "your_database_endpoint"
DB_NAME = "your_database_name"
```

## 🚀 How to Run

Once your dependencies are installed and secrets are configured, start the Streamlit server:

```bash
streamlit run rag.py
```

The application will automatically open in your default web browser at `http://localhost:8501`.

## 🧠 How the "Secret Sauce" Works (Few-Shot RAG)

Standard Text-to-SQL LLMs often fail at complex business logic (e.g., calculating revenue after applying discounts from a joined table). 

To solve this, this project implements a **Retrieval-Augmented Generation (RAG)** approach:
1. We curate a set of "gold-standard" SQL queries for our most complex business questions.
2. These examples are embedded using a local HuggingFace model and stored in an in-memory ChromaDB vector store.
3. When a user asks a question, the app performs a semantic similarity search in ChromaDB, grabs the two most mathematically similar historical queries, and injects them into the LLM's prompt context.
4. This effectively "teaches" the LLM the exact database schema and business logic on the fly before it generates its response.
