FROM python:3.12-slim

ARG APP_VERSION=dev

ENV APP_VERSION=${APP_VERSION} \
     PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=8080

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Run as a non-root user.
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8080

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${APP_PORT} --workers 2 --threads 4 --access-logfile - app:app"]
