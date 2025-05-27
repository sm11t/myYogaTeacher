# app/tests/test_schema_ingest.py
import pytest
from app.schema_ingest import get_schema_metadata


def test_metadata_contains_tables():
    md = get_schema_metadata()
    assert "app_user" in md
    assert "report" in md

def test_app_user_columns():
    md = get_schema_metadata()
    cols = md["app_user"]["columns"]
    for c in ["id", "uuid", "name", "email"]:
        assert c in cols

def test_report_fk():
    md = get_schema_metadata()
    fks = md["report"]["foreign_keys"]
    assert any(
        f["column"] == "user_id" and f["referred_table"] == "app_user"
        for f in fks
    )