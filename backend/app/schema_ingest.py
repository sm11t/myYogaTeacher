from sqlalchemy import inspect
from .db import engine

def get_schema_metadata():
    inspector = inspect(engine)
    metadata = {}
    for table_name in inspector.get_table_names():
        cols = [col["name"] for col in inspector.get_columns(table_name)]
        fks = [
            {"column": fk["constrained_columns"][0], "referred_table": fk["referred_table"], "referred_column": fk["referred_columns"][0]}
            for fk in inspector.get_foreign_keys(table_name)
        ]
        metadata[table_name] = {"columns": cols, "foreign_keys": fks}
    return metadata
