# app/nlu.py

import spacy
from .schema_ingest import get_schema_metadata

nlp = spacy.load("en_core_web_sm")
SCHEMA = get_schema_metadata()

def extract_intent(text: str) -> dict:
    """
    Parse a transcript into:
      - table: the target table name
      - filters: {column: value} when column names explicitly appear or
                 when pattern "in <value>" maps to a date column
    """
    doc = nlp(text.lower())
    tokens = [token.text for token in doc]

    # 1) Determine table name
    table = None
    for tbl in SCHEMA:
        if tbl in tokens or (tbl + "s") in tokens:
            table = tbl
            break
    if not table:
        raise ValueError(f"No table name found in text: '{text}'")

    cols = SCHEMA[table]["columns"]
    filters = {}

    # 2) Match explicit column mentions
    for col in cols:
        if col in tokens:
            idx = tokens.index(col)
            if idx + 1 < len(tokens):
                filters[col] = tokens[idx + 1]

    # 3) Handle "in <value>" → purchase_date (if present)
    #    e.g. "list transactions in may"
    for idx, token in enumerate(tokens):
        if token == "in" and idx + 1 < len(tokens):
            val = tokens[idx + 1]
            # map to any 'date' column (common: purchase_date)
            for date_col in cols:
                if "date" in date_col:
                    filters[date_col] = val
                    break
            break

    return {"table": table, "filters": filters}