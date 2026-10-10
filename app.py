import os
import socket

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def home():
    return jsonify({
        "app": os.getenv("APP_NAME", "demo-service"),
        "version": os.getenv("VERSION", "1.0.0"),
        "pod": socket.gethostname()
    })


@app.get("/healthz")
def healthz():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
