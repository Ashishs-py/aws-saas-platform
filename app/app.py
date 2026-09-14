"""Minimal demo application for the platform.

It exists to prove the platform end to end: health checks, logging, secrets
injection and data access. Any container that listens on APP_PORT and answers
the health check path can replace it without infrastructure changes.
"""

import logging
import os
import time
import uuid

import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from flask import Flask, jsonify, request

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
log = logging.getLogger("app")

APP_ENVIRONMENT = os.getenv("APP_ENVIRONMENT", "local")
APP_VERSION = os.getenv("APP_VERSION", "dev")
TABLE_NAME = os.getenv("TABLE_NAME", "")
REGION = os.getenv("AWS_REGION", "eu-west-2")
# Injected by ECS from Secrets Manager. Never logged, never returned.
SECRET_PRESENT = bool(os.getenv("APP_SECRET"))

app = Flask(__name__)

_table = None


def table():
    global _table
    if _table is None and TABLE_NAME:
        _table = boto3.resource("dynamodb", region_name=REGION).Table(TABLE_NAME)
    return _table


@app.get("/healthz")
def healthz():
    return jsonify(status="ok", version=APP_VERSION), 200


@app.get("/")
def index():
    return (
        f"<html><body style='font-family:system-ui;margin:3rem'>"
        f"<h1>SaaS platform reference application</h1>"
        f"<p>Environment: <b>{APP_ENVIRONMENT}</b></p>"
        f"<p>Version: <b>{APP_VERSION}</b></p>"
        f"<p>Region: <b>{REGION}</b></p>"
        f"<p>Secret injected from Secrets Manager: <b>{SECRET_PRESENT}</b></p>"
        f"<p>Try <a href='/api/items'>/api/items</a> and <a href='/healthz'>/healthz</a></p>"
        f"</body></html>"
    ), 200


@app.get("/api/items")
def list_items():
    t = table()
    if t is None:
        return jsonify(items=[], note="no table configured"), 200
    try:
        result = t.query(
            KeyConditionExpression=Key("pk").eq("demo"),
            Limit=25,
        )
        return jsonify(items=result.get("Items", [])), 200
    except ClientError as exc:
        log.error("ERROR reading items: %s", exc)
        return jsonify(error="read failed"), 500


@app.post("/api/items")
def create_item():
    t = table()
    if t is None:
        return jsonify(error="no table configured"), 400
    payload = request.get_json(silent=True) or {}
    item = {
        "pk": "demo",
        "sk": f"{int(time.time())}-{uuid.uuid4().hex[:8]}",
        "message": str(payload.get("message", "hello"))[:256],
    }
    try:
        t.put_item(Item=item)
        return jsonify(item=item), 201
    except ClientError as exc:
        log.error("ERROR writing item: %s", exc)
        return jsonify(error="write failed"), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("APP_PORT", "8080")))
