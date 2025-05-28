# app/sql_builder.py

def build_sql(intent: dict) -> str:
    """
    Given an intent of the form:
      {
        "table": "<table_name>",
        "filters": { "<column>": "<value>", ... }
      }
    Returns a simple SQL SELECT string with WHERE clauses.
    """
    table = intent["table"]
    filters = intent.get("filters", {})

    base = f"SELECT * FROM {table}"
    if not filters:
        return base + ";"

    clauses = [f"{col} = '{val}'" for col, val in filters.items()]
    where = " AND ".join(clauses)
    return f"{base} WHERE {where};"
