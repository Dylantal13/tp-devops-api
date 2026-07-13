from fastapi import FastAPI
import sentry_sdk
from typing import Dict

sentry_sdk.init(
    traces_sample_rate=1.0,
    profiles_sample_rate=1.0,
)

app = FastAPI(
    title="Sistema de Gestión E2E",
    description="API documentada para TP de DevOps con APM integrado",
    version="1.0.0"
)

@app.get("/", tags=["General"])
def read_root() -> Dict[str, str]:
    return {"message": "Infraestructura lista. Bienvenido al sistema."}

@app.get("/health", tags=["Monitoring"])
def health_check() -> Dict[str, str]:
    return {"status": "healthy", "service": "api-gateway"}

# endpoint para tirar un error de prueba y testear sentry
@app.get("/sentry-debug", tags=["Testing"])
async def trigger_error():
    division_by_zero = 1 / 0
    return {"message": "Nunca deberías ver esto porque explotó antes"}