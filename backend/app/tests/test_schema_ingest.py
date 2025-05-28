# app/tests/test_schema_ingest.py
import pytest
from app.schema_ingest import get_schema_metadata

@pytest.fixture
def md():
    return get_schema_metadata()

def test_app_user_table(md):
    assert "app_user" in md

def test_report_table(md):
    assert "report" in md

def test_student_table(md):
    assert "student" in md

def test_teacher_table(md):
    assert "teacher" in md

def test_student_concierge_table(md):
    assert "student_concierge" in md

def test_session_table(md):
    assert "session" in md

def test_transaction_table(md):
    assert "transaction" in md

def test_app_user_columns(md):
    cols = md["app_user"]["columns"]
    for c in ["id", "uuid", "name", "email"]:
        assert c in cols

def test_report_fk(md):
    fks = md["report"]["foreign_keys"]
    assert any(
        f["column"] == "user_id" and f["referred_table"] == "app_user"
        for f in fks
    )

def test_student_concierge_fks(md):
    fks = md["student_concierge"]["foreign_keys"]
    assert any(fk["column"] == "student_id" and fk["referred_table"] == "student" for fk in fks)
    assert any(fk["column"] == "teacher_id" and fk["referred_table"] == "teacher" for fk in fks)

def test_session_fks(md):
    fks = md["session"]["foreign_keys"]
    assert any(fk["column"] == "student_uuid" and fk["referred_table"] == "student" for fk in fks)
    assert any(fk["column"] == "teacher_uuid" and fk["referred_table"] == "teacher" for fk in fks)

def test_transaction_fks(md):
    fks = md["transaction"]["foreign_keys"]
    assert any(fk["column"] == "student_uuid" and fk["referred_table"] == "student" for fk in fks)
