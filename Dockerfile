FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .

RUN pip install --no-cache-dir --target=/app/dependencies -r requirements.txt

FROM python:3.11-slim

RUN useradd -m appuser
USER appuser

WORKDIR /app

COPY --from=builder /app/dependencies /usr/local/lib/python3.11/site-packages
COPY src/ /app/src/

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
