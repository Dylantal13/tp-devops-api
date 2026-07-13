
# ETAPA 1: BUILDER

FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .

# Instalamos dependencias en un directorio específico para no ensuciar la imagen
RUN pip install --no-cache-dir --target=/app/dependencies -r requirements.txt


# ETAPA 2: FINAL

FROM python:3.11-slim

# Metadatos (OCI Labels) - Buena práctica de auditoría
LABEL org.opencontainers.image.title="API FastAPI DevOps E2E"
LABEL org.opencontainers.image.authors="Dylan Amarilla"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.description="API REST con hardening, APM y Multi-stage"

# Variables de entorno para optimizar Python
# PYTHONDONTWRITEBYTECODE evita que se generen archivos .pyc
# PYTHONUNBUFFERED asegura que los logs de stdout salgan sin retrasos (útil para Sentry/Render)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

WORKDIR /app

# HARDENING: Crear un usuario no-root para ejecutar la aplicación
RUN useradd -m -u 1000 appuser

# Copiamos las dependencias de la etapa builder
COPY --from=builder /app/dependencies /usr/local/lib/python3.11/site-packages

# Copiamos el código fuente de nuestra aplicación
COPY --chown=appuser:appuser src/ /app/src/

# Cambiamos al usuario no-root
USER appuser

# Exponemos el puerto (informativo)
EXPOSE 8000

# LIVENESS PROBE NATIVO (Healthcheck de Docker)
# Verifica cada 30 segundos si el endpoint /health responde. Si falla 3 veces, el contenedor se marca como "unhealthy"
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)" || exit 1

# Comando de inicio seguro. "python -m uvicorn" es más agnóstico al PATH del SO.
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]