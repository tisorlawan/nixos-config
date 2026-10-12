"""Behavior checks for native omp session accounting."""
import json
import shutil
import tempfile
import unittest
from pathlib import Path

import collect
from test_collect import rollout, write_session


def omp_message(identity='entry-1', response='response-1', model='gpt-6.1-sol',
                provider='cliproxy', timestamp='2026-10-02T17:01:00Z', **usage):
    return {'type': 'message', 'id': identity, 'timestamp': timestamp,
        'message': {'role': 'assistant', 'provider': provider, 'model': model,
            'responseId': response, 'usage': usage}}


def write_omp(home, name, messages, session='omp-session'):
    events = [{'type': 'session', 'id': session}, *messages]
    return write_session(home, 'repo', name, ''.join(json.dumps(e) + '\n' for e in events))


class OmpUsage(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)

    def document(self):
        return collect.collect_document([], [], [self.home])

    def test_fresh_input_cache_and_reasoning_are_not_double_counted(self):
        write_omp(self.home, 'session.jsonl', [omp_message(input=2, cacheRead=100,
            cacheWrite=30, output=9, reasoningTokens=4, totalTokens=9999)])
        row = self.document()['rows'][0]
        self.assertEqual(row['day'], '2026-10-03')
        self.assertEqual(row['input_tokens'], 132)
        self.assertEqual(row['uncached_input_tokens'], 2)
        self.assertEqual(row['cached_input_tokens'], 100)
        self.assertEqual(row['cache_write_input_tokens'], 30)
        self.assertEqual(row['output_tokens'], 9)
        self.assertEqual(row['reasoning_output_tokens'], 4)
        self.assertEqual(row['total_tokens'], 141)
        self.assertEqual(row['provider'], 'cliproxy')
        self.assertEqual(row['clients'], ['omp'])

    def test_forked_response_is_counted_once_but_new_requests_remain(self):
        shared = omp_message(input=10, output=2)
        write_omp(self.home, 'parent.jsonl', [shared])
        write_omp(self.home, 'fork.jsonl', [shared,
            omp_message('entry-2', 'response-2', input=20, output=3)], session='fork')
        row = self.document()['rows'][0]
        self.assertEqual(row['requests'], 2)
        self.assertEqual(row['input_tokens'], 30)
        self.assertEqual(row['output_tokens'], 5)

    def test_entry_ids_are_scoped_to_session_without_response_ids(self):
        for name in ['parent', 'child']:
            write_omp(self.home, name + '.jsonl', [omp_message(response=None, input=10)], session=name)
        shutil.copyfile(self.home / 'sessions/repo/parent.jsonl',
            self.home / 'sessions/repo/copy.jsonl')
        row = self.document()['rows'][0]
        self.assertEqual(row['requests'], 2)
        self.assertEqual(row['threads'], 2)
        self.assertEqual(row['input_tokens'], 20)

    def test_model_and_provider_changes_follow_each_request(self):
        write_omp(self.home, 'session.jsonl', [omp_message(input=10),
            omp_message('entry-2', 'response-2', model='glm-5.3-flash',
                provider='opencode-go', input=20)])
        rows = {row['model']: row for row in self.document()['rows']}
        self.assertEqual(rows['gpt-6.1-sol']['provider'], 'cliproxy')
        self.assertEqual(rows['gpt-6.1-sol']['input_tokens'], 10)
        self.assertEqual(rows['glm-5.3-flash']['provider'], 'opencode-go')
        self.assertEqual(rows['glm-5.3-flash']['input_tokens'], 20)

    def test_partial_non_assistant_and_invalid_time_events_are_ignored(self):
        user = omp_message(input=100)
        user['message']['role'] = 'user'
        path = write_omp(self.home, 'session.jsonl', [user,
            omp_message('bad', 'bad', timestamp='invalid', input=100),
            omp_message('empty', 'empty'), omp_message(input=3)])
        with path.open('a') as handle:
            handle.write('{"type":"message"')
        row = self.document()['rows'][0]
        self.assertEqual(row['requests'], 1)
        self.assertEqual(row['input_tokens'], 3)

    def test_shared_model_keeps_codex_and_omp_totals_filterable(self):
        write_session(self.home, 'repo', 'rollout-a.jsonl',
            rollout({'session_id': 'codex'}, {'model': 'gpt-6.1-sol'}, [{'input_tokens': 20}]))
        write_omp(self.home, 'omp.jsonl', [omp_message(timestamp='2026-10-02T16:00:00Z', input=3)])
        row = collect.collect_document([self.home], [], [self.home])['rows'][0]
        self.assertEqual(row['input_tokens'], 23)
        self.assertEqual(row['requests'], 2)
        self.assertEqual(row['by_client']['codex']['input_tokens'], 20)
        self.assertEqual(row['by_client']['omp']['input_tokens'], 3)


if __name__ == '__main__':
    unittest.main()
