from fastapi import FastAPI
import sentry_sdk
from typing import Dict

# Inicializamos Sentry. ¡Automáticamente va a leer la variable SENTRY_DSN de Render!
sentry_sdk.init(
    # traces_sample_rate al 1.0 significa que captura el 100% de las transacciones (APM/Trazas)
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

# Este es el endpoint trampa para tu demostración
@app.get("/sentry-debug", tags=["Testing"])
async def trigger_error():
    division_by_zero = 1 / 0
    return {"message": "Nunca deberías ver esto porque explotó antes"}