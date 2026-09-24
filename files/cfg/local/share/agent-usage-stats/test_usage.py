"""Regression checks for mixed sources, streamed responses and live reloads."""
import json
import shutil
import tempfile
import threading
import unittest
import urllib.request
from functools import partial
from http.server import ThreadingHTTPServer
from pathlib import Path

import collect
from serve import Handler
from test_collect import rollout, write_session


def write_claude(home, name, events):
    path = home / 'projects' / 'repo' / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(''.join(json.dumps(event) + '\n' for event in events))
    return path


def assistant(identity='msg-1', timestamp='2026-10-02T17:01:00Z', **usage):
    return {'type': 'assistant', 'timestamp': timestamp, 'sessionId': 'claude-session',
        'message': {'id': identity, 'model': 'claude-opus-5-5', 'usage': usage}}


class UsageRegression(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)

    def test_model_switch_keeps_each_requests_model(self):
        body = rollout({'session_id': 'switch', 'model_provider': 'cpa'},
            {'model': 'model-a'}, [{'input_tokens': 10}])
        body += json.dumps({'timestamp': '2026-10-02T16:05:00Z', 'type': 'turn_context',
            'payload': {'model': 'model-b'}}) + '\n'
        body += json.dumps({'timestamp': '2026-10-02T16:06:00Z', 'type': 'token_usage_record',
            'payload': {'usage': {'input_tokens': 20}}}) + '\n'
        write_session(self.home, '2026/10/02', 'rollout-switch.jsonl', body)
        rows = {r['model']: r for r in collect.collect(self.home)}
        self.assertEqual(rows['model-a']['input_tokens'], 10)
        self.assertEqual(rows['model-b']['input_tokens'], 20)

    def test_claude_cache_counts_and_wib_day(self):
        write_claude(self.home, 'session.jsonl', [assistant(input_tokens=2,
            cache_read_input_tokens=100, cache_creation_input_tokens=30, output_tokens=9,
            output_tokens_details={'thinking_tokens': 4})])
        row = collect.collect_document([], [self.home])['rows'][0]
        self.assertEqual(row['day'], '2026-10-03')
        self.assertEqual(row['input_tokens'], 132)
        self.assertEqual(row['uncached_input_tokens'], 2)
        self.assertEqual(row['cached_input_tokens'], 100)
        self.assertEqual(row['cache_write_input_tokens'], 30)
        self.assertEqual(row['reasoning_output_tokens'], 4)
        self.assertEqual(row['total_tokens'], 141)

    def test_streamed_and_copied_claude_responses_count_once(self):
        path = write_claude(self.home, 'session.jsonl', [
            assistant(input_tokens=2, cache_read_input_tokens=100, output_tokens=2),
            assistant(input_tokens=2, cache_read_input_tokens=100, output_tokens=9),
        ])
        shutil.copyfile(path, path.with_name('copied.jsonl'))
        row = collect.collect_document([], [self.home])['rows'][0]
        self.assertEqual(row['requests'], 1)
        self.assertEqual(row['cached_input_tokens'], 100)
        self.assertEqual(row['output_tokens'], 9)

    def test_synthetic_and_partial_claude_events_are_ignored(self):
        synthetic = assistant(input_tokens=0, output_tokens=0)
        synthetic['message']['model'] = '<synthetic>'
        path = write_claude(self.home, 'session.jsonl', [synthetic,
            assistant('real', input_tokens=3, output_tokens=1)])
        with path.open('a') as handle:
            handle.write('{"type":"assistant"')
        rows = collect.collect_document([], [self.home])['rows']
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]['requests'], 1)

    def test_copied_codex_request_deduplicates_by_response_id(self):
        body = rollout({'session_id': 'same'}, {'model': 'gpt-test'}, [{'input_tokens': 20}])
        events = [json.loads(line) for line in body.splitlines()]
        events[-1]['payload']['response_id'] = 'resp-1'
        body = ''.join(json.dumps(e) + '\n' for e in events)
        for root in [self.home / 'a', self.home / 'b']:
            write_session(root, '2026/10/02', 'rollout-copy.jsonl', body)
        row = collect.collect_document([self.home / 'a', self.home / 'b'], [])['rows'][0]
        self.assertEqual(row['requests'], 1)
        self.assertEqual(row['input_tokens'], 20)

    def test_symlinked_home_is_read_once(self):
        write_session(self.home, '2026/10/02', 'rollout-a.jsonl',
            rollout({'session_id': 'same'}, {'model': 'gpt-test'}, [{'input_tokens': 20}]))
        shadow = self.home / 'shadow'
        shadow.mkdir()
        (shadow / 'sessions').symlink_to(self.home / 'sessions', target_is_directory=True)
        doc = collect.collect_document([self.home, shadow], [])
        self.assertEqual(len(doc['sources']), 1)
        self.assertEqual(doc['rows'][0]['requests'], 1)

    def test_token_count_fallback_skips_repeated_running_totals(self):
        body = rollout({'session_id': 'fallback'}, {'model': 'gpt-test'}, [])
        for usage in [10, 10, 20]:
            body += json.dumps({'timestamp': '2026-10-02T16:00:03Z', 'type': 'event_msg',
                'payload': {'type': 'token_count', 'info': {
                    'last_token_usage': {'input_tokens': usage},
                    'total_token_usage': {'input_tokens': usage}}}}) + '\n'
        write_session(self.home, '2026/10/02', 'rollout-fallback.jsonl', body)
        row = collect.collect(self.home)[0]
        self.assertEqual(row['requests'], 2)
        self.assertEqual(row['input_tokens'], 30)

    def test_explicit_usage_and_token_count_are_not_both_summed(self):
        body = rollout({'session_id': 'both'}, {'model': 'gpt-test'}, [{'input_tokens': 10}])
        body += json.dumps({'timestamp': '2026-10-02T16:00:03Z', 'type': 'event_msg',
            'payload': {'type': 'token_count', 'info': {'last_token_usage': {'input_tokens': 10}}}}) + '\n'
        write_session(self.home, '2026/10/02', 'rollout-both.jsonl', body)
        self.assertEqual(collect.collect(self.home)[0]['requests'], 1)

    def test_same_model_across_agents_has_one_row_and_filterable_totals(self):
        write_session(self.home, '2026/10/02', 'rollout-a.jsonl',
            rollout({'session_id': 'codex'}, {'model': 'claude-opus-5-5'}, [{'input_tokens': 20}]))
        write_claude(self.home, 'session.jsonl', [assistant(timestamp='2026-10-02T16:01:00Z',
            input_tokens=3, cache_read_input_tokens=5, output_tokens=1)])
        rows = collect.collect_document([self.home], [self.home])['rows']
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]['input_tokens'], 28)
        self.assertEqual(rows[0]['by_client']['claude']['input_tokens'], 8)
        self.assertEqual(rows[0]['by_client']['codex']['input_tokens'], 20)

    def test_invalid_timestamp_does_not_break_collection(self):
        write_claude(self.home, 'session.jsonl', [assistant(timestamp='invalid', input_tokens=1),
            assistant('valid', input_tokens=3)])
        self.assertEqual(collect.collect_document([], [self.home])['rows'][0]['requests'], 1)

    def test_api_reads_newly_appended_usage_and_old_url_redirects(self):
        class TestHandler(Handler):
            codex_homes = []
            claude_homes = [self.home]

            def log_message(self, *args):
                pass

        server = ThreadingHTTPServer(('127.0.0.1', 0), partial(TestHandler, directory=str(self.home)))
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        def close():
            server.shutdown()
            server.server_close()
            thread.join()
        self.addCleanup(close)
        url = f'http://127.0.0.1:{server.server_port}'
        path = write_claude(self.home, 'session.jsonl', [assistant(input_tokens=3)])
        def fetch():
            with urllib.request.urlopen(url + '/api/usage') as response:
                self.assertEqual(response.headers['Cache-Control'], 'no-store')
                return json.load(response)
        self.assertEqual(fetch()['rows'][0]['requests'], 1)
        with path.open('a') as handle:
            handle.write(json.dumps(assistant('new', input_tokens=5)) + '\n')
        self.assertEqual(fetch()['rows'][0]['requests'], 2)
        (self.home / 'index.html').write_text('<h1>React app</h1>')
        with urllib.request.urlopen(url + '/stats.html') as response:
            self.assertEqual(response.url, url + '/')
            self.assertIn(b'React app', response.read())


if __name__ == '__main__':
    unittest.main()
