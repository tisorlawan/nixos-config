#!/usr/bin/env python3
"""Serve the built React SPA and live usage API on the same local port."""
from __future__ import annotations
import argparse
import json
import traceback
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
import collect

HERE = Path(__file__).resolve().parent


class Handler(SimpleHTTPRequestHandler):
    codex_homes = None
    claude_homes = None

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_GET(self):
        path = urlsplit(self.path).path
        if path in ("/api/usage", "/data.json"):
            try:
                document = collect.collect_document(self.codex_homes, self.claude_homes)
                body = json.dumps(document).encode("utf-8")
            except Exception:
                traceback.print_exc()
                body = json.dumps({"error": "Usage collection failed. Check the service logs."}).encode()
                self.send_response(500)
            else:
                self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if path == "/stats.html":
            self.send_response(302)
            self.send_header("Location", "/")
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        super().do_GET()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("homes", nargs="*", type=Path)
    parser.add_argument("--claude-home", action="append", type=Path)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8770)
    parser.add_argument("--dist", type=Path, default=HERE / "dist")
    args = parser.parse_args()
    if not (args.dist / "index.html").is_file():
        parser.error("Frontend build missing. Run npm install && npm run build first.")
    Handler.codex_homes = args.homes or None
    Handler.claude_homes = args.claude_home
    server = ThreadingHTTPServer((args.host, args.port), partial(Handler, directory=str(args.dist)))
    print(f"Agent usage: http://{args.host}:{args.port}/", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
