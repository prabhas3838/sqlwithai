# ==========================================
# STREAMLIT SQL CHAT APP (FEW-SHOT + GROQ)
# ==========================================

__import__('pysqlite3')
import sys
sys.modules['sqlite3'] = sys.modules.pop('pysqlite3')

import streamlit as st
from urllib.parse import quote_plus

from langchain_groq import ChatGroq
from langchain_community.utilities import SQLDatabase
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings

from langchain_core.prompts import PromptTemplate, FewShotPromptTemplate
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_classic.chains import create_sql_query_chain


# ==========================================
# STREAMLIT UI
# ==========================================
st.set_page_config(page_title="SQL AI Assistant", layout="wide")
st.title("🧠 SQL AI Assistant (Few-Shot + Groq)")
st.caption("Ask questions about your MySQL database in plain English")


# ==========================================
# SECRETS & LLM (GROQ)
# ==========================================
llm = ChatGroq(
    model="openai/gpt-oss-20b",
    api_key=st.secrets["GROQ_API_KEY"],
    temperature=0
)


# ==========================================
# DATABASE CONNECTION
# ==========================================
db_user = st.secrets["DB_USER"]
raw_password = st.secrets["DB_PASSWORD"]
db_password = quote_plus(raw_password)
db_host = st.secrets["DB_HOST"]
db_name = st.secrets["DB_NAME"]

db_uri = f"mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}"

db = SQLDatabase.from_uri(
    db_uri,
    sample_rows_in_table_info=3
)


# ==========================================
# FEW-SHOT EXAMPLES
# ==========================================
few_shots = [
    {'Question' : "How many t-shirts do we have left for Nike in XS size and white color?",
     'SQLQuery' : "SELECT sum(stock_quantity) FROM t_shirts WHERE brand = 'Nike' AND color = 'White' AND size = 'XS'",
     'SQLResult': "Result of the SQL query",
     'Answer' : "52"},
    {'Question': "How much is the total price of the inventory for all S-size t-shirts?",
     'SQLQuery':"SELECT SUM(price*stock_quantity) FROM t_shirts WHERE size = 'S'",
     'SQLResult': "Result of the SQL query",
     'Answer': "21676"},
    {'Question': "If we have to sell all the Levi’s T-shirts today with discounts applied. How much revenue  our store will generate (post discounts)?" ,
     'SQLQuery' : """SELECT sum(a.total_amount * ((100-COALESCE(discounts.pct_discount,0))/100)) as total_revenue from
(select sum(price*stock_quantity) as total_amount, t_shirt_id from t_shirts where brand = 'Levi'
group by t_shirt_id) a left join discounts on a.t_shirt_id = discounts.t_shirt_id
 """,
     'SQLResult': "Result of the SQL query",
     'Answer': "22089.200000"} ,
     {'Question' : "If we have to sell all the Levi’s T-shirts today. How much revenue our store will generate without discount?" ,
      'SQLQuery': "SELECT SUM(price * stock_quantity) FROM t_shirts WHERE brand = 'Levi'",
      'SQLResult': "Result of the SQL query",
      'Answer' : "22310"},
    {'Question': "How many white color Levi's shirt I have?",
     'SQLQuery' : "SELECT sum(stock_quantity) FROM t_shirts WHERE brand = 'Levi' AND color = 'White'",
     'SQLResult': "Result of the SQL query",
     'Answer' : "196"
     },
    {'Question': "how much sales amount will be generated if we sell all large size t shirts today in nike brand after discounts?",
     'SQLQuery' : """SELECT sum(a.total_amount * ((100-COALESCE(discounts.pct_discount,0))/100)) as total_revenue from
(select sum(price*stock_quantity) as total_amount, t_shirt_id from t_shirts where brand = 'Nike' and size="L"
group by t_shirt_id) a left join discounts on a.t_shirt_id = discounts.t_shirt_id
 """,
     'SQLResult': "Result of the SQL query",
     'Answer' : "3477.450000"
    }
] 


# ==========================================
# EMBEDDINGS + VECTORSTORE
# ==========================================
embeddings = HuggingFaceEmbeddings(
    model_name="sentence-transformers/all-MiniLM-L6-v2",
    model_kwargs={'device': 'cpu'}
)

texts = [
    f"Question: {ex['Question']} SQLQuery: {ex['SQLQuery']} Answer: {ex['Answer']}"
    for ex in few_shots
]

vectorstore = Chroma.from_texts(
    texts=texts,
    embedding=embeddings,
    metadatas=few_shots
)

example_selector = SemanticSimilarityExampleSelector(
    vectorstore=vectorstore,
    k=2,
    input_keys=["input"]
)


# ==========================================
# EXAMPLE FORMAT
# ==========================================
example_prompt = PromptTemplate(
    input_variables=["Question", "SQLQuery", "Answer"],
    template="""
Question: {Question}
SQLQuery: {SQLQuery}
Answer: {Answer}
"""
)


# ==========================================
# MAIN PROMPT
# ==========================================
prefix = """
You are a MySQL expert.

You are given the following database schema:
{table_info}

Rules:
- Use only columns present in the tables
- Never use SELECT *
- Wrap column names in backticks
- Use CURDATE() if the question involves today
- Limit results to {top_k}
"""


few_shot_prompt = FewShotPromptTemplate(
    example_selector=example_selector,
    example_prompt=example_prompt,
    prefix=prefix,
    suffix="Question: {input}\nSQLQuery:",
    input_variables=["input", "table_info", "top_k"],
)


# ==========================================
# SQL GENERATION CHAIN
# ==========================================
sql_chain = create_sql_query_chain(
    llm=llm,
    db=db,
    prompt=few_shot_prompt
)


# ==========================================
# USER INPUT
# ==========================================
question = st.text_input(
    "Ask a question about your database:",
    placeholder="How many white colour Levi tshirts are available?"
)

import re

def extract_sql(text: str) -> str:
    # Prefer fenced SQL blocks
    match = re.search(r"```sql(.*?)```", text, re.DOTALL | re.IGNORECASE)
    if match:
        return match.group(1).strip()

    # Fallback: after SQLQuery:
    if "SQLQuery:" in text:
        return text.split("SQLQuery:")[1].split("SQLResult:")[0].strip()

    return text.strip()

# ==========================================
# RUN QUERY
# ==========================================
if st.button("Run Query") and question:
    with st.spinner("Thinking..."):
        sql_query = sql_chain.invoke({
            "question":question,
            "input": question,
            "top_k": 5
        })
        sql_query = extract_sql(sql_query)

    st.subheader("🧾 Generated SQL")
    st.code(sql_query, language="sql")

    try:
        result = db.run(sql_query)
        st.subheader("📊 Result")
        st.write(result)
    except Exception as e:
        st.error(f"SQL Execution Error: {e}")