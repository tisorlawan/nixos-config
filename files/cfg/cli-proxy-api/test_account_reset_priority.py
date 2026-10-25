"""Priority reads use one local API request, without provider or reset calls."""
import contextlib
import datetime as dt
import io
import json
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch

import account_reset_priority as priority


def account(account_id='claude-a', percent=20, **extra):
    return {'id': account_id, 'provider': 'claude', 'available': True, 'error': '',
        'updated_at': dt.datetime.now(dt.timezone.utc).isoformat(), 'windows': [
            {'label': '5 hours', 'percent': percent, 'resets_at': None},
            {'label': 'Weekly', 'percent': percent, 'resets_at': '2030-01-01T00:00:00+00:00'}], **extra}


class Priority(unittest.TestCase):
    def test_shared_quota_preserves_limit_and_availability_decisions(self):
        self.assertTrue(priority.account_usage(account())['usable'])
        self.assertFalse(priority.account_usage(account(percent=100))['usable'])
        self.assertFalse(priority.account_usage(account(available=False))['usable'])
        with self.assertRaises(ValueError):
            priority.account_usage(account(available=None))

    def test_failed_or_old_quota_cannot_change_priority(self):
        with self.assertRaises(ValueError):
            priority.account_usage(account(error='Rate limited.'))
        with self.assertRaises(ValueError):
            priority.account_usage(account(updated_at='2000-01-01T00:00:00+00:00'))
        with self.assertRaises(ValueError):
            priority.account_usage(account(updated_at=None))

    def test_soonest_weekly_reset_wins_and_limited_accounts_get_zero(self):
        stats = {name: priority.account_usage(account()) for name in ('a', 'b', 'limited')}
        stats['a']['weekly_reset'] = 2
        stats['b']['weekly_reset'] = 1
        stats['limited']['usable'] = False
        self.assertEqual(priority.desired_priorities(stats), {'a': 10, 'b': 20, 'limited': 0})

    def test_dry_run_uses_one_local_get_and_does_not_write_auth_files(self):
        requests = []
        document = {'accounts': [account()]}

        class Handler(BaseHTTPRequestHandler):
            def do_GET(self):
                requests.append(self.path)
                self.send_response(200)
                self.end_headers()
                self.wfile.write(json.dumps(document).encode())

            def log_message(self, *args):
                pass

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory, 'claude-a.json')
            original = json.dumps({'type': 'claude', 'priority': 20}).encode()
            path.write_bytes(original)
            server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            try:
                url = f'http://127.0.0.1:{server.server_port}/api/quota'
                with patch('sys.argv', ['priority', '--auth-dir', directory, '--quota-url', url, '--dry-run']), \
                        contextlib.redirect_stdout(io.StringIO()) as output:
                    self.assertEqual(priority.main(), 0)
                self.assertIn('priority 20 -> 10', output.getvalue())
                self.assertEqual(path.read_bytes(), original)
                self.assertEqual(requests, ['/api/quota'])
            finally:
                server.shutdown()
                server.server_close()
                thread.join(timeout=2)


if __name__ == '__main__':
    unittest.main()
