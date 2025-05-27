# app/tests/test_api.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_schema():
    resp = client.get("/schema")
    assert resp.status_code == 200
    data = resp.json()
    # basic shape
    assert "app_user" in data and "columns" in data["app_user"]
    assert "report" in data and "foreign_keys" in data["report"]

