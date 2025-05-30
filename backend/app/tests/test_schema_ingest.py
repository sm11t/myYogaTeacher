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

def test_student_columns(md):
    cols = md["student"]["columns"]
    for c in [
        "id","uuid","created_date","modified_date",
        "first_name","middle_name","last_name","email",
        "phone_personal","gender","credits","credits_currency",
        "is_credits_currency_fixed","password",
        "iana_timezone","funnel_url","funnel_type",
        "trial_start_date","trial_end_date"
    ]:
        assert c in cols

def test_teacher_columns(md):
    cols = md["teacher"]["columns"]
    for c in [
        "id","uuid","status","created_date","modified_date",
        "first_name","middle_name","last_name","last_name_full_value",
        "email","phone_personal","gender","profile_photo",
        "goals","years_of_yoga_practise","years_of_yoga_teaching_experience",
        "video_thumbnail","iana_timezone","slug"
    ]:
        assert c in cols

def test_session_columns(md):
    cols = md["session"]["columns"]
    for c in [
        "id","uuid","student_uuid","teacher_uuid",
        "start_time","end_time","duration","status",
        "is_trial","student_joined","teacher_joined",
        "created_date","modified_date","student_id","teacher_id","type"
    ]:
        assert c in cols

def test_transaction_columns(md):
    cols = md["transaction"]["columns"]
    for c in [
        "id","student_uuid","package_id","currency","type",
        "recurring","order_id","next_billing_date","subscription_status",
        "purchase_date","user_agent","created_date","modified_date","student_id"
    ]:
        assert c in cols
