import os
from fastapi.testclient import TestClient

from app.main import app
import app.ib as ib


def test_health_returns_connection_status(monkeypatch):
    monkeypatch.setattr(ib, "is_connected", lambda: True)
    client = TestClient(app)

    response = client.get("/health")

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert payload["ib_connected"] is True


def test_price_requires_token():
    client = TestClient(app)

    response = client.get("/price/AAPL")

    assert response.status_code == 401


def test_price_returns_value(monkeypatch):
    os.environ["API_TOKEN"] = "test-token"

    async def fake_price(_symbol: str):
        return 123.45

    monkeypatch.setattr(ib, "get_last_price", fake_price)
    client = TestClient(app)

    response = client.get("/price/AAPL", headers={"X-API-Token": "test-token"})

    assert response.status_code == 200
    payload = response.json()
    assert payload["symbol"] == "AAPL"
    assert payload["price"] == 123.45
