from fastapi import FastAPI
from .schema_ingest import get_schema_metadata

app = FastAPI()

@app.get("/schema")
def read_schema():
    return get_schema_metadata()
