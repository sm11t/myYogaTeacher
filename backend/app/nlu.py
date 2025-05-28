# app/nlu.py

import spacy
from .schema_ingest import get_schema_metadata

# Load spaCy model
nlp = spacy.load("en_core_web_sm")

# Introspect your database schema once at import time
SCHEMA = get_schema_metadata()  # e.g. {"student": {...}, "session": {...}, ...}

def extract_intent(text: str) -> dict:
    """
    Parse a transcript into:
      - table: the target table name (e.g. "session", "transaction")
      - filters: a mapping of column → value (e.g. {"status": "completed", "start_time": "march"})
    Returns a dict suitable for SQL generation:
      {
        "table": "<table_name>",
        "filters": { "<column>": "<value>", ... }
      }
    """
    doc = nlp(text.lower())
    tokens = [token.text for token in doc]

    # 1. Identify the target table
    table = None
    for tbl in SCHEMA:
        # match exact or singular/plural form
        if tbl in tokens or tbl.rstrip("s") in tokens:
            table = tbl
            break
    if not table:
        raise ValueError(f"No table name found in text: '{text}'")

    # 2. Initialize filters dict
    filters = {}
    cols = SCHEMA[table]["columns"]

    # 3. Naively match column names in the token stream
    for col in cols:
        if col in tokens:
            idx = tokens.index(col)
            # take the next word as the filter value, if available
            if idx + 1 < len(tokens):
                filters[col] = tokens[idx + 1]

    # 4. Use spaCy entities for dates and numbers
    for ent in doc.ents:
        # Date/time entities
        if ent.label_ in ("DATE", "TIME"):
            for col in cols:
                if col not in filters and ("date" in col or "time" in col):
                    filters[col] = ent.text
                    break
        # Cardinal numbers (e.g. "5", "ten")
        if ent.label_ in ("CARDINAL", "QUANTITY"):
            for col in cols:
                if col not in filters:
                    filters[col] = ent.text
                    break

    return {
        "table": table,
        "filters": filters
    }
