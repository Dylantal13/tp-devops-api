# etapa 1: compilacion de dependencias
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .

# instalamos dependencias en una ruta limpia para el final stage
RUN pip install --no-cache-dir --target=/app/dependencies -r requirements.txt

# etapa 2: ejecucion final
FROM python:3.11-slim

# metadatos basicos de la imagen
LABEL org.opencontainers.image.title="API FastAPI DevOps E2E"
LABEL org.opencontainers.image.authors="Dylan Amarilla"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.description="API REST con hardening, APM y Multi-stage"

# variables de entorno basicas para optimizar python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

WORKDIR /app

# creamos un usuario comun por seguridad
RUN useradd -m -u 1000 appuser

# traemos las dependencias del builder
COPY --from=builder /app/dependencies /usr/local/lib/python3.11/site-packages

# copiamos el codigo y asignamos permisos a appuser
COPY --chown=appuser:appuser src/ /app/src/

# pasamos al usuario comun
USER appuser

# puerto expuesto
EXPOSE 8000

# healthcheck usando python para no tener que instalar curl en la imagen slim
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)" || exit 1

# comando de arranque de la aplicacion
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]