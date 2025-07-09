from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import text

from .schema_ingest import get_schema_metadata
from .nlu import extract_intent
from .sql_builder import build_sql
from .db import SessionLocal

app = FastAPI(title="MyYogaTeacher Reporting API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class QueryRequest(BaseModel):
    text: str
    teacher_id: int | None = None   # ← NEW

@app.post("/query")
def run_query(req: QueryRequest):
    try:
        intent = extract_intent(req.text)
        if req.teacher_id is not None:
            intent["teacher_id"] = req.teacher_id

        sql = build_sql(intent)

        with SessionLocal() as session:
            rows = session.execute(text(sql)).fetchall()

        return {"sql": sql, "results": [dict(r._mapping) for r in rows]}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
