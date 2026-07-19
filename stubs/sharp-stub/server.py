"""SharpAPI SSE stub: replays a World Cup live-frame fixture in a loop.

Stands in for the real SharpAPI stream (ADR-007) so the live-betting path
(lines-service live consumer -> agent live edges -> UI /live) can be
exercised end-to-end without credentials. Frame shape is the canonical
contract the lines-service sharpapi adapter parses.

Stdlib only. Endpoints:
  GET /v1/stream  -- text/event-stream; one fixture frame every
                     STUB_FRAME_INTERVAL_SECONDS (default 5), looping
                     forever with `: ping` keep-alives between frames.
                     captured_at is rewritten to "now" so frames are
                     always fresh.
  GET /healthz    -- 200 ok
"""

import json
import os
import time
from datetime import UTC, datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

FRAMES_PATH = Path(os.environ.get("STUB_FRAMES_PATH", Path(__file__).parent / "frames.jsonl"))
INTERVAL = float(os.environ.get("STUB_FRAME_INTERVAL_SECONDS", "5"))
PORT = int(os.environ.get("PORT", "8010"))


def _load_frames() -> list[dict]:
    frames = []
    for line in FRAMES_PATH.read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            frames.append(json.loads(line))
    if not frames:
        raise SystemExit(f"no frames in {FRAMES_PATH}")
    return frames


FRAMES = _load_frames()


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_GET(self) -> None:  # noqa: N802 - http.server API
        if self.path == "/healthz":
            body = b"ok"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if self.path != "/v1/stream":
            self.send_response(404)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.end_headers()
        try:
            index = 0
            while True:
                frame = dict(FRAMES[index % len(FRAMES)])
                frame["captured_at"] = datetime.now(tz=UTC).isoformat().replace("+00:00", "Z")
                self.wfile.write(f"data: {json.dumps(frame)}\n\n".encode())
                self.wfile.flush()
                index += 1
                # keep-alive halfway through the interval, like real streams do
                time.sleep(INTERVAL / 2)
                self.wfile.write(b": ping\n\n")
                self.wfile.flush()
                time.sleep(INTERVAL / 2)
        except (BrokenPipeError, ConnectionResetError):
            pass  # client went away; nothing to clean up

    def log_message(self, format: str, *args: object) -> None:  # noqa: A002 - http.server API
        print(f"[sharp-stub] {format % args}")


if __name__ == "__main__":
    print(f"[sharp-stub] serving {len(FRAMES)} frames on :{PORT}, interval {INTERVAL}s")
    ThreadingHTTPServer(("", PORT), Handler).serve_forever()
