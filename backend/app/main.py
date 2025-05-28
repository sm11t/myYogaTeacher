# app/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import text

from .schema_ingest import get_schema_metadata
from .nlu import extract_intent
from .sql_builder import build_sql
from .db import SessionLocal

app = FastAPI(title="MyYogaTeacher Reporting API")

# CORS setup: allow your React dev server to call this API
origins = [
    "http://localhost:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/schema")
def read_schema():
    """
    Return the full database schema metadata.
    """
    return get_schema_metadata()


class QueryRequest(BaseModel):
    """
    Request body for /query: a simple text prompt.
    """
    text: str


@app.post("/query")
def run_query(req: QueryRequest):
    """
    1. Parse text → intent
    2. Build SQL string
    3. Execute against the DB
    4. Return the SQL and result rows
    """
    try:
        intent = extract_intent(req.text)
        sql = build_sql(intent)
        with SessionLocal() as session:
            result = session.execute(text(sql))
            rows = result.fetchall()
        # Use the RowMapping interface to convert rows safely
        return {
            "sql": sql,
            "results": [dict(r._mapping) for r in rows]
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
