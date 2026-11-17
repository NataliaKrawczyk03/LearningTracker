import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def _preflight(origin):
    return client.options(
        "/health",
        headers={
            "Origin": origin,
            "Access-Control-Request-Method": "GET",
            "Access-Control-Request-Headers": "Authorization, Content-Type",
        },
    )


@pytest.mark.parametrize(
    "origin", ["http://localhost:5173", "https://nataliakrawczyk03.github.io"]
)
def test_frontend_origins_allowed(origin):
    r = _preflight(origin)
    assert r.status_code == 200
    assert r.headers["access-control-allow-origin"] == origin
    assert "access-control-allow-credentials" not in r.headers


def test_simple_get_from_frontend_gets_cors_header():
    r = client.get("/health", headers={"Origin": "http://localhost:5173"})
    assert r.headers["access-control-allow-origin"] == "http://localhost:5173"


def test_other_origin_rejected():
    r = _preflight("https://evil.example")
    assert "access-control-allow-origin" not in r.headers
