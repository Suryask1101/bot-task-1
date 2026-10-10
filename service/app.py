import os
import socket
from pathlib import Path

from flask import Flask, jsonify

app = Flask(__name__)

CONFIG_DIR = Path("/etc/demo-config")


def get_config(name, filename, default):
    config_file = CONFIG_DIR / filename
    if config_file.is_file():
        return config_file.read_text().strip()
    return os.getenv(name, default)


@app.get("/")
def home():
    return jsonify({
        "app": get_config("APP_NAME", "appName", "demo-service"),
        "version": get_config("VERSION", "version", "1.0.0"),
        "pod": socket.gethostname()
    })


@app.get("/healthz")
def healthz():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
