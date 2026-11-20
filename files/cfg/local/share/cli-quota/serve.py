#!/usr/bin/env python3
"""Serve quota data and reset credits for local clients."""

import json
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

import quota


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        target = urlsplit(self.path)

        if target.path == "/api/quota":
            self._send_json(200, quota.cached_quota())
        elif target.path == "/api/quota/resets":
            account = parse_qs(target.query).get("account", [None])[0]

            try:
                self._send_json(200, quota.list_resets(account))
            except quota.ResetError as failure:
                self._send_json(failure.status, {"error": str(failure)})
            except Exception:
                traceback.print_exc()
                self._send_json(500, {"error": "Could not read the reset list."})
        else:
            self._send_json(404, {"error": "Not found."})

    def do_POST(self):
        if urlsplit(self.path).path != "/api/quota/reset":
            self._send_json(404, {"error": "Not found."})

            return

        # JSON forces cross-origin browsers to preflight, which the server never approves.
        if not self._local_request() or self.headers.get_content_type() != "application/json":
            self._send_json(403, {"error": "Reset requires a local JSON request."})

            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            request = json.loads(self.rfile.read(length)) if 0 < length <= 1024 else None
        except ValueError:
            request = None

        if not isinstance(request, dict) or request.get("confirm") is not True:
            self._send_json(400, {"error": "Reset needs an account and explicit confirmation."})

            return

        try:
            credit = request.get("credit")

            if credit is not None and not isinstance(credit, str):
                raise quota.ResetError("Unknown reset.", 400)

            self._send_json(200, quota.reset_credit(request.get("account"), credit))
        except quota.ResetError as failure:
            self._send_json(failure.status, {"error": str(failure)})
        except Exception:
            traceback.print_exc()
            self._send_json(500, {"error": "Reset failed unexpectedly. Refresh to check the account before retrying."})

    def _send_json(self, status, document):
        body = json.dumps(document).encode("utf-8")
        self.send_response(status)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _local_request(self):
        """Reject DNS rebinding and cross-site reset requests."""
        host = self.headers.get("Host", "")
        origin = self.headers.get("Origin")

        return host.rsplit(":", 1)[0] in ("127.0.0.1", "localhost", "[::1]") and (
            origin is None or origin == f"http://{host}"
        )


def main():
    with ThreadingHTTPServer(("127.0.0.1", 8770), Handler) as server:
        print("Quota API listening on http://127.0.0.1:8770/", flush=True)

        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
