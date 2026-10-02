#!/usr/bin/env python3
"""Serve the built React SPA and live usage API on the same local port."""
from __future__ import annotations
import argparse
import json
import traceback
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit
import collect
import quota

HERE = Path(__file__).resolve().parent


class Handler(SimpleHTTPRequestHandler):
    codex_homes = None
    claude_homes = None

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def send_json(self, status, document):
        body = json.dumps(document).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def local_request(self):
        """Reject DNS-rebinding and cross-site requests before any irreversible action."""
        host = self.headers.get("Host", "")
        if host.rsplit(":", 1)[0] not in ("127.0.0.1", "localhost", "[::1]"):
            return False
        origin = self.headers.get("Origin")
        return origin is None or origin == f"http://{host}"

    def do_POST(self):
        if urlsplit(self.path).path != "/api/quota/reset":
            self.send_json(404, {"error": "Not found."})
            return
        # A JSON content type forces a CORS preflight, which this server never approves.
        if not self.local_request() or self.headers.get("Content-Type", "").split(";")[0] != "application/json":
            self.send_json(403, {"error": "Reset must be requested from the dashboard."})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            request = json.loads(self.rfile.read(length)) if 0 < length <= 1024 else None
        except ValueError:
            request = None
        if not isinstance(request, dict) or request.get("confirm") is not True:
            self.send_json(400, {"error": "Reset needs an account and explicit confirmation."})
            return
        try:
            credit = request.get("credit")
            if credit is not None and not isinstance(credit, str):
                raise quota.ResetError("Unknown reset.", 400)
            self.send_json(200, quota.reset_codex(request.get("account"), credit))
        except quota.ResetError as failure:
            self.send_json(failure.status, {"error": str(failure)})
        except Exception:
            traceback.print_exc()
            self.send_json(500, {"error": "Reset failed unexpectedly. Refresh to check the account before retrying."})

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
        if path == "/api/quota":
            self.send_json(200, quota.cached_quota())
            return
        if path == "/api/quota/resets":
            account = parse_qs(urlsplit(self.path).query).get("account", [None])[0]
            try:
                self.send_json(200, quota.list_resets(account))
            except quota.ResetError as failure:
                self.send_json(failure.status, {"error": str(failure)})
            except Exception:
                traceback.print_exc()
                self.send_json(500, {"error": "Could not read the reset list."})
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
