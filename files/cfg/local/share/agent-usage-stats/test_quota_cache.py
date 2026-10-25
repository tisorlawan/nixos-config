"""Provider read budgets and cooldowns. No external network or reset operations."""
import datetime as dt
import threading
import unittest
import urllib.error
from concurrent.futures import ThreadPoolExecutor
from email.utils import format_datetime

from quota_cache import UsageCache, retry_after


class Clock:
    now = 0

    def __call__(self):
        return self.now


def limited(retry=None):
    return urllib.error.HTTPError('https://provider.invalid/usage', 429, 'limited',
        {'Retry-After': retry} if retry is not None else {}, None)


class QuotaCache(unittest.TestCase):
    def setUp(self):
        self.clock = Clock()
        self.cache = UsageCache(self.clock)

    def test_readers_share_a_five_minute_account_budget(self):
        calls = []

        def fetch():
            calls.append(1)
            return {'count': len(calls)}

        first = self.cache.read('claude', 'a', fetch)
        self.clock.now = 299
        self.assertIs(self.cache.read('claude', 'a', fetch), first)
        self.assertEqual(len(calls), 1)
        self.clock.now = 300
        self.assertEqual(self.cache.read('claude', 'a', fetch).payload, {'count': 2})

    def test_retry_after_retains_data_and_pauses_other_accounts_of_that_provider(self):
        original = self.cache.read('claude', 'a', lambda: {'used': 20})
        self.clock.now = 300

        def fetch():
            raise limited('900')

        with self.assertLogs('quota_cache', level='WARNING') as logs:
            failed = self.cache.read('claude', 'a', fetch)
        self.assertEqual(len(logs.output), 1)
        self.assertEqual(failed.payload, original.payload)
        self.assertEqual(failed.updated_at, 0)
        self.assertEqual(failed.retry_at, 1200)
        self.assertEqual(failed.status, 429)
        self.clock.now = 1199
        blocked = lambda: self.fail('Provider call during cooldown')
        self.assertIs(self.cache.read('claude', 'a', blocked), failed)
        self.assertEqual(self.cache.read('claude', 'b', blocked).status, 429)
        self.assertFalse(self.cache.read('codex', 'c', lambda: {}).failed)
        self.clock.now = 1200
        recovered = self.cache.read('claude', 'a', lambda: {'used': 21})
        self.assertFalse(recovered.failed)
        self.assertEqual(recovered.updated_at, 1200)
        self.assertEqual(recovered.payload, {'used': 21})

    def test_repeated_429_increases_the_fallback_to_one_hour(self):
        def fetch():
            raise limited()

        for delay in (300, 600, 1200, 2400, 3600, 3600):
            with self.assertLogs('quota_cache', level='WARNING'):
                result = self.cache.read('claude', 'a', fetch)
            self.assertEqual(result.retry_at - self.clock.now, delay)
            self.clock.now = result.retry_at

    def test_retry_after_handles_seconds_http_dates_and_invalid_values(self):
        date = format_datetime(dt.datetime.fromtimestamp(7200, dt.timezone.utc), usegmt=True)
        self.assertEqual(retry_after('900', 100), 1000)
        self.assertEqual(retry_after(date, 100), 7200)
        for value in (None, '', 'bad date', '-1'):
            self.assertEqual(retry_after(value, 100), 100)
        with self.assertLogs('quota_cache', level='WARNING'):
            result = self.cache.read('claude', 'a', lambda: self.raise_limit(date))
        self.assertEqual(result.retry_at, 7200)

    @staticmethod
    def raise_limit(value):
        raise limited(value)

    def test_network_failure_preserves_the_previous_payload(self):
        self.cache.read('claude', 'a', lambda: {'used': 10})
        self.clock.now = 300

        def fetch():
            raise OSError('offline')

        result = self.cache.read('claude', 'a', fetch)
        self.assertTrue(result.failed)
        self.assertIsNone(result.status)
        self.assertEqual(result.payload, {'used': 10})
        self.assertEqual(result.retry_at, 600)

    def test_targeted_invalidation_keeps_other_accounts_cached_and_keeps_cooldowns(self):
        claude = self.cache.read('claude', 'a', lambda: {'used': 10})
        self.cache.read('codex', 'b', lambda: {})
        self.cache.invalidate('b')
        self.assertIs(self.cache.read('claude', 'a', lambda: self.fail('Unrelated account was invalidated')), claude)
        self.clock.now = 300
        with self.assertLogs('quota_cache', level='WARNING'):
            self.cache.read('claude', 'a', lambda: self.raise_limit('900'))
        self.cache.invalidate('a')
        result = self.cache.read('claude', 'a', lambda: self.fail('Invalidation bypassed the cooldown'))
        self.assertEqual(result.status, 429)
        self.assertEqual(result.retry_at, 1200)

    def test_concurrent_readers_make_one_provider_request(self):
        entered, release = threading.Event(), threading.Event()
        calls = []

        def fetch():
            calls.append(1)
            entered.set()
            if not release.wait(2):
                raise RuntimeError('Fixture release timeout')
            return {'used': 10}

        with ThreadPoolExecutor(max_workers=4) as pool:
            first = pool.submit(self.cache.read, 'claude', 'a', fetch)
            self.assertTrue(entered.wait(2))
            others = [pool.submit(self.cache.read, 'claude', 'a', fetch) for _ in range(3)]
            release.set()
            results = [future.result(timeout=2) for future in [first, *others]]
        self.assertEqual(len(calls), 1)
        self.assertTrue(all(result is results[0] for result in results))


if __name__ == '__main__':
    unittest.main()
