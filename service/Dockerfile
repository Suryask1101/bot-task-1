# Stage 1: Build dependency wheels
FROM python:3.12.7-slim-bookworm AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt


# Stage 2: Run the application
FROM python:3.12.7-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

COPY requirements.txt .
COPY --from=builder /wheels /wheels

RUN pip install --no-cache-dir --no-index \
        --find-links=/wheels -r requirements.txt \
    && rm -rf /wheels \
    && useradd --uid 10001 --create-home appuser

COPY --chown=10001:10001 app.py .

USER 10001:10001

EXPOSE 8080

CMD ["python", "app.py"]
