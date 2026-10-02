"""Plan limit parsing and failure isolation, with no network access."""
import json
import tempfile
import unittest
import urllib.error
from pathlib import Path

import quota

CLAUDE = {"five_hour": {"utilization": 0.0, "resets_at": None},
    "seven_day": {"utilization": 100.0, "resets_at": "2026-10-03T07:59:59+00:00"},
    "seven_day_opus": None}
CODEX = {"plan_type": "plus", "rate_limit": {
    "primary_window": {"used_percent": 17, "limit_window_seconds": 18000, "reset_at": 1790975387},
    "secondary_window": {"used_percent": 85, "limit_window_seconds": 604800, "reset_at": 1791285713}}}


def auth_dir(*accounts):
    temp = tempfile.TemporaryDirectory()
    for index, account in enumerate(accounts):
        Path(temp.name, f"{index}.json").write_text(json.dumps(account))
    return temp


class Quota(unittest.TestCase):
    def test_claude_windows_skip_missing_limits_and_keep_idle_reset_empty(self):
        windows = quota.claude_windows(CLAUDE)
        self.assertEqual([item["label"] for item in windows], ["5 hours", "Weekly"])
        self.assertEqual(windows[0]["resets_at"], None)
        self.assertEqual(windows[1]["percent"], 100.0)

    def test_codex_windows_are_labelled_by_length(self):
        windows = quota.codex_windows(CODEX)
        self.assertEqual([(item["label"], item["percent"]) for item in windows],
            [("5 hours", 17.0), ("Weekly", 85.0)])
        self.assertTrue(windows[0]["resets_at"].startswith("2026-10-"))

    def test_one_failing_account_does_not_hide_the_others(self):
        temp = auth_dir(
            {"type": "claude", "email": "a@example.com", "access_token": "dead"},
            {"type": "claude", "email": "b@example.com", "access_token": "live"},
            {"type": "claude", "email": "off@example.com", "access_token": "x", "disabled": True},
            {"type": "other", "access_token": "x"})
        self.addCleanup(temp.cleanup)

        def fetch(url, headers):
            if headers["Authorization"] == "Bearer dead":
                raise urllib.error.HTTPError(url, 401, "no", {}, None)
            return CLAUDE

        accounts = quota.collect_quota(temp.name, fetch)["accounts"]
        self.assertEqual([item["name"] for item in accounts], ["a@example.com", "b@example.com"])
        self.assertEqual(accounts[0]["error"], quota.EXPIRED)
        self.assertEqual(accounts[0]["windows"], [])
        self.assertEqual(accounts[1]["error"], "")
        self.assertEqual(len(accounts[1]["windows"]), 2)

    def test_network_failure_is_reported_without_raising(self):
        temp = auth_dir({"type": "codex", "email": "c@example.com", "access_token": "t", "account_id": "1"})
        self.addCleanup(temp.cleanup)

        def fetch(url, headers):
            raise OSError("offline")

        account = quota.collect_quota(temp.name, fetch)["accounts"][0]
        self.assertEqual(account["error"], "Provider unreachable.")

    def test_codex_request_carries_the_account_id(self):
        temp = auth_dir({"type": "codex", "email": "c@example.com", "access_token": "t", "account_id": "acct"})
        self.addCleanup(temp.cleanup)
        seen = {}

        def fetch(url, headers):
            seen.update(headers)
            return CODEX

        account = quota.collect_quota(temp.name, fetch)["accounts"][0]
        self.assertEqual(seen["chatgpt-account-id"], "acct")
        self.assertEqual(account["plan"], "plus")


if __name__ == "__main__":
    unittest.main()
