# ==========================================
# ETAPA 1: BUILDER (Compilación de dependencias)
# ==========================================
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .

# Instalamos las librerías en una carpeta especial temporal
RUN pip install --no-cache-dir --target=/app/dependencies -r requirements.txt

# ==========================================
# ETAPA 2: PRODUCCIÓN (Imagen final liviana y segura)
# ==========================================
FROM python:3.11-slim

# Creamos un usuario sin privilegios por seguridad
RUN useradd -m appuser
USER appuser

WORKDIR /app

# Traemos las librerías ya instaladas de la etapa 1
COPY --from=builder /app/dependencies /usr/local/lib/python3.11/site-packages
# Copiamos nuestro código
COPY src/ /app/src/

EXPOSE 8000

# El comando que arranca FastAPI
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]