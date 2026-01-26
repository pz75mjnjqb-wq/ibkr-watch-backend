from fastapi.testclient import TestClient
from backend.mock_main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "ib_connected": True}

def test_price_unauthorized():
    response = client.get("/price/AAPL")
    assert response.status_code == 401

def test_price_authorized():
    response = client.get("/price/AAPL", headers={"X-API-Token": "mock-token"})
    assert response.status_code == 200
    data = response.json()
    assert data["symbol"] == "AAPL"
    assert isinstance(data["price"], float)