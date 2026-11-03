"""Demo app for Kubernetes + Datadog monitoring.

Endpoints:
  /          normal response
  /health    liveness/readiness probe
  /config    shows config read from the ConfigMap, and whether the Secret was mounted
  /slow      responds after a random delay (to see latency in Datadog)
  /error     returns HTTP 500 (to trigger error-rate alerts)
"""
import logging
import os
import random
import socket
import time

from flask import Flask, jsonify

# JSON-like structured logs -> easy to search in Datadog Logs
logging.basicConfig(
    level=logging.INFO,
    format='{"time": "%(asctime)s", "level": "%(levelname)s", "message": "%(message)s"}',
)
log = logging.getLogger("demo-app")

app = Flask(__name__)


@app.route("/")
def home():
    log.info("home page served")
    return jsonify(message=os.getenv("APP_MESSAGE", "Hello from Kubernetes!"), pod=socket.gethostname())


@app.route("/health")
def health():
    return jsonify(status="healthy")


@app.route("/config")
def config():
    # Never return the secret value itself - only whether it is present
    return jsonify(
        app_env=os.getenv("APP_ENV", "unset"),
        log_level=os.getenv("LOG_LEVEL", "unset"),
        api_token_loaded=bool(os.getenv("API_TOKEN")),
    )


@app.route("/slow")
def slow():
    delay = random.uniform(0.5, 2.0)
    time.sleep(delay)
    log.warning("slow request took %.2fs", delay)
    return jsonify(delay_seconds=round(delay, 2))


@app.route("/error")
def error():
    log.error("simulated failure on /error")
    return jsonify(error="simulated failure"), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
