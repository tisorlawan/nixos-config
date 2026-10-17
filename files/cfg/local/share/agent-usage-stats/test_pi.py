"""Pi usage must appear once, under the correct client, model, and WIB day."""
import json
import os
import tempfile
import threading
import unittest
import urllib.request
from functools import partial
from http.server import ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch

import collect
from serve import Handler
from test_collect import write_session
from test_omp import omp_message, write_omp


def pi_message(identity: str = 'entry-1', response: str | None = 'response-1',
               model: str = 'gpt-6.1-sol', provider: str = 'cliproxyapi',
               timestamp: str = '2026-10-02T17:01:00Z', **usage: int) -> dict:
    return {'type': 'message', 'id': identity, 'timestamp': timestamp,
        'message': {'role': 'assistant', 'provider': provider, 'model': model,
            'responseId': response, 'usage': usage}}


def write_pi(home: Path, name: str, entries: list[dict], session: str = 'pi-session') -> Path:
    events = [{'type': 'session', 'version': 3, 'id': session}, *entries]
    return write_session(home, 'repo', name, ''.join(json.dumps(event) + '\n' for event in events))


class PiUsage(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)

    def document(self) -> dict:
        return collect.collect_document([], [], [], [self.home])

    def test_pi_and_omp_keep_separate_counters_on_a_shared_model(self) -> None:
        write_pi(self.home / 'pi', 'session.jsonl', [pi_message(
            input=2, cacheRead=100, cacheWrite=30, output=9, reasoning=4, totalTokens=9999)])
        write_omp(self.home / 'omp', 'session.jsonl', [omp_message(
            provider='cliproxyapi', input=7, output=3, reasoningTokens=2)])
        row = collect.collect_document([], [], [self.home / 'omp'], [self.home / 'pi'])['rows'][0]
        self.assertEqual(row['clients'], ['omp', 'pi'])
        self.assertEqual(row['requests'], 2)
        self.assertEqual(row['input_tokens'], 139)
        self.assertEqual(row['output_tokens'], 12)
        pi = row['by_client']['pi']
        self.assertEqual(row['day'], '2026-10-03')
        self.assertEqual(pi['uncached_input_tokens'], 2)
        self.assertEqual(pi['cached_input_tokens'], 100)
        self.assertEqual(pi['cache_write_input_tokens'], 30)
        self.assertEqual(pi['reasoning_output_tokens'], 4)
        self.assertEqual(pi['total_tokens'], 141)
        self.assertEqual(pi['providers'], ['cliproxyapi'])
        self.assertEqual(row['by_client']['omp']['reasoning_output_tokens'], 2)

    def test_forked_responses_deduplicate_without_merging_different_providers(self) -> None:
        shared = pi_message(input=10, output=2)
        write_pi(self.home, 'parent.jsonl', [shared])
        write_pi(self.home, 'fork.jsonl', [shared,
            pi_message('entry-2', 'response-2', input=20, output=3),
            pi_message('entry-3', provider='openai', input=30, output=4)], session='fork')
        row = self.document()['rows'][0]
        self.assertEqual(row['requests'], 3)
        self.assertEqual(row['input_tokens'], 60)
        self.assertEqual(row['output_tokens'], 9)
        self.assertEqual(row['providers'], ['cliproxyapi', 'openai'])

    def test_copied_entries_without_response_ids_deduplicate_across_fork_headers(self) -> None:
        shared = pi_message(response=None, input=10)
        write_pi(self.home, 'parent.jsonl', [shared])
        write_pi(self.home, 'fork.jsonl', [shared,
            pi_message(response=None, timestamp='2026-10-02T17:02:00Z', input=20)], session='fork')
        row = self.document()['rows'][0]
        self.assertEqual(row['requests'], 2)
        self.assertEqual(row['input_tokens'], 30)

    def test_model_changes_and_explicit_usage_keep_their_own_attribution(self) -> None:
        write_pi(self.home, 'session.jsonl', [pi_message(input=10),
            pi_message('opus', 'opus-response', model='claude-opus-5-5', input=20),
            {'type': 'usage', 'id': 'warm', 'timestamp': '2026-10-02T17:03:00Z',
                'kind': 'future-usage-kind', 'provider': 'cliproxyapi', 'model': 'claude-haiku-5-5',
                'usage': {'input': 1, 'cacheRead': 50, 'output': 2}},
            pi_message('luna', 'luna-response', model='gpt-6-luna', provider='openai', input=30)])
        rows = {row['model']: row for row in self.document()['rows']}
        self.assertEqual(set(rows), {'gpt-6.1-sol', 'claude-opus-5-5', 'claude-haiku-5-5', 'gpt-6-luna'})
        self.assertEqual(rows['gpt-6.1-sol']['input_tokens'], 10)
        self.assertEqual(rows['claude-opus-5-5']['input_tokens'], 20)
        self.assertEqual(rows['claude-haiku-5-5']['total_tokens'], 53)
        self.assertEqual(rows['gpt-6-luna']['providers'], ['openai'])
        self.assertEqual(rows['gpt-6-luna']['input_tokens'], 30)

    def test_unattributed_summaries_and_nested_usage_do_not_disappear_or_borrow_a_model(self) -> None:
        entries = [pi_message(input=10)]
        for kind in ('compaction', 'branch_summary'):
            entries.append({'type': kind, 'id': kind, 'timestamp': '2026-10-02T17:03:00Z',
                'usage': {'input': 3, 'output': 2}})
        entries.append({'type': 'message', 'id': 'nested', 'timestamp': '2026-10-02T17:04:00Z',
            'message': {'role': 'toolResult', 'usage': {'input': 4, 'output': 1}}})
        write_pi(self.home, 'parent.jsonl', entries)
        write_pi(self.home, 'fork.jsonl', entries, session='fork')
        rows = {row['model']: row for row in self.document()['rows']}
        self.assertEqual(rows['gpt-6.1-sol']['requests'], 1)
        self.assertEqual(rows['unknown']['requests'], 3)
        self.assertEqual(rows['unknown']['input_tokens'], 10)
        self.assertEqual(rows['unknown']['output_tokens'], 5)
        self.assertEqual(rows['unknown']['providers'], ['unknown'])

    def test_partial_non_usage_and_invalid_timestamp_entries_are_ignored(self) -> None:
        user = pi_message(input=100)
        user['message']['role'] = 'user'
        path = write_pi(self.home, 'session.jsonl', [user,
            pi_message('bad', 'bad', timestamp='invalid', input=100),
            pi_message('empty', 'empty'), pi_message(input=3)])
        with path.open('a') as handle:
            handle.write('{"type":"message"')
        row = self.document()['rows'][0]
        self.assertEqual(row['requests'], 1)
        self.assertEqual(row['input_tokens'], 3)

    def test_default_and_environment_pi_homes_are_not_omp_sources(self) -> None:
        pi_home = self.home / '.pi/agent'
        alternate = self.home / 'alternate-pi'
        write_pi(pi_home, 'main.jsonl', [pi_message(input=10)])
        write_pi(alternate, 'work.jsonl', [pi_message('work', 'work-response', input=20)], session='work')
        with patch('collect.Path.home', return_value=self.home), patch.dict(
                os.environ, {'PI_CODING_AGENT_DIR': str(alternate)}, clear=True):
            document = collect.collect_document([], [])
        row = document['rows'][0]
        self.assertEqual(row['clients'], ['pi'])
        self.assertEqual(row['input_tokens'], 30)
        self.assertEqual(row['requests'], 2)
        self.assertEqual({source['path'] for source in document['sources'] if source['client'] == 'pi'},
            {str(pi_home / 'sessions'), str(alternate / 'sessions')})
        alias = self.home / 'pi-alias'
        alias.symlink_to(pi_home, target_is_directory=True)
        with patch('collect.Path.home', return_value=self.home), patch.dict(
                os.environ, {'PI_CODING_AGENT_DIR': str(alias)}, clear=True):
            row = collect.collect_document([], [])['rows'][0]
        self.assertEqual(row['requests'], 1)
        self.assertEqual(row['input_tokens'], 10)

    def test_api_reads_new_pi_usage_without_restart_or_double_counting(self) -> None:
        class TestHandler(Handler):
            codex_homes = []
            claude_homes = []
            omp_homes = []
            pi_homes = [self.home]

            def log_message(self, *args: object) -> None:
                pass

        server = ThreadingHTTPServer(('127.0.0.1', 0), partial(TestHandler, directory=str(self.home)))
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        def close() -> None:
            server.shutdown()
            server.server_close()
            thread.join()
        self.addCleanup(close)

        def fetch() -> dict:
            with urllib.request.urlopen(f'http://127.0.0.1:{server.server_port}/api/usage') as response:
                return json.load(response)

        path = write_pi(self.home, 'session.jsonl', [pi_message(input=3)])
        self.assertEqual(fetch()['rows'][0]['by_client']['pi']['input_tokens'], 3)
        with path.open('a') as handle:
            handle.write(json.dumps(pi_message('new', 'new-response', input=5)) + '\n')
        for _ in range(2):
            row = fetch()['rows'][0]
            self.assertEqual(row['requests'], 2)
            self.assertEqual(row['by_client']['pi']['input_tokens'], 8)


if __name__ == '__main__':
    unittest.main()
