from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .schema_ingest import get_schema_metadata

app = FastAPI(title="MyYogaTeacher Schema API")

# === Add this block ===
origins = [
    "http://localhost:3000",  # your React dev server
    # add other origins if needed
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)
# === End CORS setup ===

@app.get("/schema")
def read_schema():
    return get_schema_metadata()



