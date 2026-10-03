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
ORG = "11111111-2222-3333-4444-555555555555"
GRANT = {"id": "launch-reset", "label": "Launch reset", "resets_total": 1, "resets_left": 1,
    "starts_at": "2020-01-01T00:00:00+00:00", "ends_at": "2999-01-01T00:00:00+00:00", "paused": False}


def claude_usage(*grants, eligible=True):
    return {**CLAUDE, "cedar_ember": {"eligible": eligible, "grants": list(grants)}}


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


class ClaudeResets(unittest.TestCase):
    """Every provider call is a fake: nothing here can spend a real reset."""

    def account(self, **extra):
        temp = auth_dir({"type": "claude", "email": "a@example.com", "access_token": "t",
            "organization_uuid": ORG, **extra})
        self.addCleanup(temp.cleanup)
        return temp

    def test_usable_grants_count_as_available_resets(self):
        paused = {**GRANT, "id": "paused", "paused": True}
        spent = {**GRANT, "id": "spent", "resets_left": 0}
        expired = {**GRANT, "id": "expired", "ends_at": "2020-02-01T00:00:00+00:00"}
        two = {**GRANT, "id": "two", "resets_left": 2, "ends_at": "2998-01-01T00:00:00+00:00"}
        temp = self.account()
        account = quota.collect_quota(temp.name, lambda url, headers: claude_usage(GRANT, paused, spent, expired, two))["accounts"][0]
        self.assertEqual(account["resets"], {"available": 3})
        listing = quota.list_resets("0", temp.name, lambda url, headers: claude_usage(GRANT, paused, spent, expired, two))
        self.assertEqual([item["id"] for item in listing["credits"]], ["two", "launch-reset"])
        self.assertEqual(listing["credits"][1]["title"], "Launch reset")

    def test_accounts_without_an_offer_show_no_resets(self):
        temp = self.account()
        for payload in (CLAUDE, claude_usage(GRANT, eligible=False), claude_usage()):
            account = quota.collect_quota(temp.name, lambda url, headers: payload)["accounts"][0]
            self.assertNotIn("resets", account)

    def test_reset_posts_the_grant_to_the_accounts_organization(self):
        temp = self.account()
        sent = {}

        def post(url, headers, body):
            sent.update(url=url, headers=headers, body=body)
            return {"result": "reset"}

        self.assertEqual(quota.reset_credit("0", None, temp.name, lambda url, headers: claude_usage(GRANT), post), {"ok": True})
        self.assertEqual(sent["url"], f"{quota.CLAUDE_BASE}/organizations/{ORG}/reset_rate_limits")
        self.assertEqual(sent["body"]["program"], "cedar_ember")
        self.assertEqual(sent["body"]["grant_id"], "launch-reset")
        self.assertEqual(sent["headers"]["Authorization"], "Bearer t")
        self.assertTrue(sent["headers"]["User-Agent"].startswith("claude-cli/"))

    def test_refusals_are_reported_and_a_stale_grant_is_never_sent(self):
        temp = self.account()
        calls = []

        def post(url, headers, body):
            calls.append(body)
            return {"result": "not_limited"}

        fetch = lambda url, headers: claude_usage(GRANT)
        with self.assertRaises(quota.ResetError) as refused:
            quota.reset_credit("0", "launch-reset", temp.name, fetch, post)
        self.assertEqual(str(refused.exception), quota.RESET_MESSAGES["not_limited"])
        with self.assertRaises(quota.ResetError):
            quota.reset_credit("0", "someone-elses", temp.name, fetch, post)
        with self.assertRaises(quota.ResetError):
            quota.reset_credit("0", None, temp.name, lambda url, headers: claude_usage(), post)
        self.assertEqual(len(calls), 1)

    def test_missing_organization_is_refused_before_anything_is_sent(self):
        temp = self.account(organization_uuid="not-a-uuid")

        def post(url, headers, body):
            raise AssertionError("must not be sent")

        with self.assertRaises(quota.ResetError):
            quota.reset_credit("0", None, temp.name, lambda url, headers: claude_usage(GRANT), post)


if __name__ == "__main__":
    unittest.main()
