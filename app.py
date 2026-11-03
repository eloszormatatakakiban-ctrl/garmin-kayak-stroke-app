from datetime import datetime
import os
import re

from flask import Flask, jsonify, request, send_from_directory

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(BASE_DIR, "web")
app = Flask(__name__, static_folder=WEB_DIR, static_url_path="")


@app.get("/")
def index():
    return send_from_directory(WEB_DIR, "index.html")


@app.get("/api/health")
def health():
    return jsonify({"ok": True, "app": "Garmin Kayak Stroke Dashboard"})


@app.post("/api/session")
def create_session():
    data = request.get_json(silent=True) or {}
    session_id = str(data.get("sessionId", "")).strip()
    if not session_id:
        return jsonify({"ok": False, "error": "sessionId is required"}), 400

    try:
        strokes = int(data.get("strokes", 0))
        spm = float(data.get("spm", 0))
        duration = int(data.get("duration", 0))
    except (TypeError, ValueError):
        return jsonify({"ok": False, "error": "strokes, spm and duration must be numbers"}), 400

    if strokes < 0 or duration < 0 or spm < 0:
        return jsonify({"ok": False, "error": "Session values cannot be negative"}), 400

    # Demo endpoint only: accepts and echoes data; it does not persist it.
    return jsonify({
        "ok": True,
        "message": "Session received (not saved).",
        "received": {
            "sessionId": session_id,
            "strokes": strokes,
            "spm": spm,
            "duration": duration,
            "timestamp": data.get("timestamp") or datetime.utcnow().isoformat() + "Z",
        },
    })


@app.get("/<path:filename>")
def static_files(filename):
    # Do not let unknown API paths fall through to the frontend.
    if filename.startswith("api/"):
        return jsonify({"error": "Not found"}), 404
    return send_from_directory(WEB_DIR, filename)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "10000")))
