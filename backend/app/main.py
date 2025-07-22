from fastapi import FastAPI, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import text
import logging

from .schema_ingest import get_schema_metadata
from .nlu import extract_intent
from .sql_builder import build_sql
from .db import SessionLocal
from .asr import transcribe_audio

# Set up logger for incoming queries and generated SQL
logger = logging.getLogger("uvicorn")
logger.setLevel(logging.INFO)

app = FastAPI(title="MyYogaTeacher Reporting API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class QueryRequest(BaseModel):
    text: str
    teacher_id: int | None = None

@app.post("/query")
def run_query(req: QueryRequest):
    try:
        # Log the raw incoming natural-language query
        logger.info(f"📥 Incoming natural-language query: {req.text!r}")

        intent = extract_intent(req.text)
        if req.teacher_id is not None:
            intent["teacher_id"] = req.teacher_id

        sql = build_sql(intent)
        # Log the generated SQL statement
        logger.info(f"🔨 Generated SQL: {sql}")

        with SessionLocal() as session:
            rows = session.execute(text(sql)).fetchall()

        return {"sql": sql, "results": [dict(r._mapping) for r in rows]}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/whisper")
async def whisper_endpoint(file: UploadFile = File(...)):
    """
    Accepts an audio file, runs it through Whisper ASR,
    and returns the transcript.
    """
    try:
        contents = await file.read()
        tmp_path = f"/tmp/{file.filename}"
        with open(tmp_path, "wb") as f:
            f.write(contents)

        transcript = transcribe_audio(tmp_path)
        return {"transcript": transcript}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"ASR error: {e}")
