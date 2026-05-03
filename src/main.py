from fastapi import FastAPI

# Instancia principal de la aplicación FastAPI.
# El título y la versión quedan disponibles en la documentación automática (/docs).
app = FastAPI(title="TP DevOps API", version="1.0.0")


@app.get("/", summary="Bienvenida")
def root() -> dict[str, str]:
    """Endpoint raíz que devuelve un mensaje de bienvenida."""
    return {"message": "Bienvenido a la API del TP de DevOps"}


@app.get("/health", summary="Health check")
def health_check() -> dict[str, str]:
    """Endpoint de salud utilizado para monitoreo y liveness probes."""
    return {"status": "ok"}
