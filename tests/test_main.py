import pytest
from fastapi.testclient import TestClient

from src.main import app

# Cliente de pruebas que simula peticiones HTTP sin levantar un servidor real.
client = TestClient(app)


def test_root_status_code() -> None:
    """El endpoint raíz debe responder con HTTP 200."""
    response = client.get("/")
    assert response.status_code == 200


def test_root_message() -> None:
    """El endpoint raíz debe devolver el mensaje de bienvenida esperado."""
    response = client.get("/")
    assert response.json() == {"message": "Bienvenido a la API del TP de DevOps"}


def test_health_status_code() -> None:
    """El endpoint /health debe responder con HTTP 200."""
    response = client.get("/health")
    assert response.status_code == 200


def test_health_response() -> None:
    """El endpoint /health debe devolver status 'ok'."""
    response = client.get("/health")
    assert response.json() == {"status": "ok"}
