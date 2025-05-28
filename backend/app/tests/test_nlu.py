# app/tests/test_nlu.py
import pytest
from app.nlu import extract_intent

@pytest.mark.parametrize("text,expected", [
    (
        "show me sessions status completed",
        {"table": "session", "filters": {"status": "completed"}}
    ),
    (
        "list transactions in may",
        {"table": "transaction", "filters": {"purchase_date": "may"}}
    ),
    (
        "get student credits 10",
        {"table": "student", "filters": {"credits": "10"}}
    ),
])
def test_extract_intent_simple(text, expected):
    intent = extract_intent(text)
    assert intent["table"] == expected["table"]
    assert intent["filters"] == expected["filters"]
