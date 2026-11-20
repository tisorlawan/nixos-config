"""Plan limit parsing and failure isolation, with no network access."""
import json
import tempfile
import unittest
import urllib.error
from pathlib import Path

import quota
from quota_cache import UsageCache

CLAUDE = {"five_hour": {"utilization": 0.0, "resets_at": None},
    "seven_day": {"utilization": 100.0, "resets_at": "2026-10-03T07:59:59+00:00"},
    "seven_day_opus": None,
    "limits": [
        {"kind": "session", "percent": 0, "resets_at": None, "scope": None},
        {"kind": "weekly_all", "percent": 100, "resets_at": "2026-10-03T07:59:59+00:00", "scope": None}]}
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
    def test_cached_usage_keeps_the_last_windows_and_reports_the_cooldown(self):
        temp = auth_dir({'type': 'claude', 'email': 'a@example.com', 'access_token': 't', 'priority': 20})
        self.addCleanup(temp.cleanup)
        now = [0]
        cache = UsageCache(lambda: now[0])
        first = quota.collect_quota(temp.name, lambda *args: CLAUDE, cache)['accounts'][0]
        now[0] = 300

        def fetch(*args):
            raise urllib.error.HTTPError('https://provider.invalid/usage', 429, 'limited', {'Retry-After': '900'}, None)

        with self.assertLogs('quota_cache', level='WARNING'):
            account = quota.collect_quota(temp.name, fetch, cache)['accounts'][0]
        self.assertEqual(account['windows'], first['windows'])
        self.assertEqual(account['updated_at'], first['updated_at'])
        self.assertEqual(account['priority'], 20)
        self.assertTrue(account['retry_at'])
        self.assertIn('Rate limited.', account['error'])
        self.assertIn('out of date', account['error'])

    def test_provider_availability_survives_the_shared_api(self):
        codex = {**CODEX, 'rate_limit': {**CODEX['rate_limit'], 'allowed': False}}
        account = quota.read_account({'type': 'codex', 'access_token': 't'}, lambda *args: codex)
        self.assertFalse(account['available'])
        claude = {**CLAUDE, 'five_hour': {**CLAUDE['five_hour'], 'locked_reason': 'blocked'}}
        account = quota.read_account({'type': 'claude', 'access_token': 't'}, lambda *args: claude)
        self.assertFalse(account['available'])

    def test_priority_is_the_stored_integer_even_when_sign_in_expires(self):
        for priority, expected in ((20, 20), (0, 0), (-10, -10), (None, None), ("20", None), (True, None)):
            with self.subTest(priority=priority):
                account = quota.read_account({"type": "codex", "priority": priority}, None)
                self.assertEqual(account["priority"], expected)
                self.assertEqual(account["error"], quota.EXPIRED)

    def test_claude_session_and_weekly_limits_keep_idle_reset_empty(self):
        windows = quota.claude_windows(CLAUDE)
        self.assertEqual([item["label"] for item in windows], ["5 hours", "Weekly"])
        self.assertEqual(windows[0]["resets_at"], None)
        self.assertEqual(windows[1]["percent"], 100.0)

    def test_claude_limits_are_authoritative_and_skip_model_scoped_and_unknown_kinds(self):
        payload = {**CLAUDE, "limits": [
            {"kind": "weekly_scoped", "percent": 20, "resets_at": "2026-11-22T08:00:00+00:00",
                "scope": {"model": {"id": None, "display_name": "Fable"}, "surface": None}},
            {"kind": "future_limit", "percent": 20}]}

        self.assertEqual(quota.claude_windows(payload), [])

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
        fable = {**GRANT, "id": "launch-2610-fable-week", "ends_at": "2997-01-01T00:00:00+00:00",
            "label": "New model launch: one Fable reset for Pro and Team Standard, launch week only"}
        usage = claude_usage(GRANT, paused, spent, expired, two, fable)
        temp = self.account()

        account = quota.collect_quota(temp.name, lambda url, headers: usage)["accounts"][0]
        self.assertEqual(account["resets"], {"available": 3})

        listing = quota.list_resets("0", temp.name, lambda url, headers: usage)
        self.assertEqual([item["id"] for item in listing["credits"]], ["two", "launch-reset"])
        self.assertEqual(listing["credits"][1]["title"], "Launch reset")

    def test_accounts_without_an_offer_show_no_resets(self):
        temp = self.account()
        fable = {**GRANT, "label": "New model launch: one Fable reset"}

        for payload in (CLAUDE, claude_usage(GRANT, eligible=False), claude_usage(), claude_usage(fable)):
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


SUMMARY = {"groups": [
    {"displayName": "Gemini Models", "buckets": [
        {"bucketId": "gemini-weekly", "window": "weekly", "resetTime": "2026-11-27T11:51:26Z", "remainingFraction": 0.68},
        {"bucketId": "gemini-5h", "window": "5h", "resetTime": "2026-11-20T21:51:26Z", "remainingFraction": 0.87}]},
    {"displayName": "Claude and GPT models", "buckets": [
        {"bucketId": "3p-weekly", "window": "weekly", "resetTime": "2026-11-27T17:05:34Z", "remainingFraction": 1},
        {"bucketId": "3p-5h", "window": "5h", "resetTime": "2026-11-20T22:05:34Z", "remainingFraction": 1}]},
    {"displayName": "Gemini 4 Argon", "buckets": [
        {"bucketId": "gemini-argon-wtu-weekly", "window": "weekly", "resetTime": "2026-11-27T17:05:34Z",
            "remainingFraction": 1}]}]}


def antigravity_reply(url):
    endpoint = url.rsplit(":", 1)[1]

    return {"loadCodeAssist": {"cloudaicompanionProject": "project-1"}, "retrieveUserQuotaSummary": SUMMARY}[endpoint]


class Antigravity(unittest.TestCase):
    def login(self, expiry="2999-01-01T00:00:00.123456789+07:00", client=True):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        token = Path(temp.name, "ac0a3dfd6ddd", "antigravity-acp", "antigravity-oauth-token")
        token.parent.mkdir(parents=True)
        token.write_text(json.dumps({"token": {"access_token": "stored", "refresh_token": "refresh",
            "expiry": expiry, "token_type": "Bearer"}, "id_token_email": "g@example.com"}))
        client_path = Path(temp.name, "client.json")

        if client:
            client_path.write_text(json.dumps({"client_id": "id", "client_secret": "secret"}))

        return token, client_path

    def collect(self, token, client_path, post):
        return quota.collect_quota(Path(token).parent, lambda *args: {}, None, [token], post,
            client_path)["accounts"][0]

    def test_windows_show_only_the_gemini_limits_five_hours_first(self):
        windows = quota.antigravity_windows(SUMMARY)

        self.assertEqual([(item["label"], round(item["percent"], 1), item["resets_at"]) for item in windows],
            [("Gemini 5h", 13.0, "2026-11-20T21:51:26Z"), ("Gemini 7d", 32.0, "2026-11-27T11:51:26Z")])

    def test_a_missing_fraction_is_used_up_and_a_summary_without_gemini_shows_nothing(self):
        used_up = {"groups": [{"buckets": [{"bucketId": "gemini-5h", "resetTime": "2026-11-20T21:51:26Z"}]}]}
        old_client = {"groups": [SUMMARY["groups"][1]]}

        self.assertEqual(quota.antigravity_windows(used_up)[0]["percent"], 100.0)
        self.assertEqual(quota.antigravity_windows(old_client), [])

    def test_a_valid_token_reads_the_project_then_the_summary_as_antigravity(self):
        token, client_path = self.login()
        calls = []

        def post(url, headers, body):
            calls.append((url, headers, body))

            return antigravity_reply(url)

        account = self.collect(token, client_path, post)

        self.assertEqual([call[0] for call in calls], [f"https://daily-cloudcode-pa.googleapis.com/v1internal:{name}"
            for name in ("loadCodeAssist", "retrieveUserQuotaSummary")])
        self.assertEqual(calls[1][1], {"User-Agent": quota.antigravity_user_agent(), "Authorization": "Bearer stored"})
        self.assertRegex(calls[1][1]["User-Agent"], r"^antigravity/cli/\d+\.\d+\.\d+$")
        self.assertEqual(calls[1][2], {"project": "project-1"})
        self.assertEqual((account["id"], account["provider"], account["name"]),
            ("antigravity-ac0a3dfd", "antigravity", "g@example.com"))
        self.assertEqual(account["error"], "")
        self.assertEqual(len(account["windows"]), 2)
        self.assertTrue(account["updated_at"])

    def test_an_expired_token_is_refreshed_in_memory_and_the_file_is_left_alone(self):
        token, client_path = self.login(expiry="2020-01-01T00:00:00+00:00")
        before = token.read_text()
        calls = []

        def post(url, headers, body):
            calls.append((url, headers, body))

            if url == quota.GOOGLE_TOKEN_URL:
                return {"access_token": "fresh", "expires_in": 3599}

            return antigravity_reply(url)

        account = self.collect(token, client_path, post)

        self.assertEqual(calls[0][2], {"grant_type": "refresh_token", "refresh_token": "refresh",
            "client_id": "id", "client_secret": "secret"})
        self.assertEqual(calls[2][1]["Authorization"], "Bearer fresh")
        self.assertEqual(account["error"], "")
        self.assertEqual(token.read_text(), before)

    def test_a_rejected_refresh_token_reports_an_expired_sign_in(self):
        token, client_path = self.login(expiry="2020-01-01T00:00:00+00:00")

        def post(url, headers, body):
            raise urllib.error.HTTPError(url, 400, "invalid_grant", {}, None)

        account = self.collect(token, client_path, post)

        self.assertEqual(account["error"], quota.ANTIGRAVITY_EXPIRED)
        self.assertEqual(account["windows"], [])

    def test_an_expired_token_without_the_client_file_sends_nothing(self):
        token, client_path = self.login(expiry="2020-01-01T00:00:00+00:00", client=False)

        def post(url, headers, body):
            raise AssertionError("must not be sent")

        account = self.collect(token, client_path, post)

        self.assertIn("is missing", account["error"])

    def test_a_file_that_is_not_a_login_is_skipped(self):
        token, client_path = self.login()
        token.write_text(json.dumps({"token": {"access_token": "t"}}))

        accounts = quota.collect_quota(token.parent, lambda *args: {}, None, [token], None, client_path)["accounts"]

        self.assertEqual(accounts, [])


if __name__ == "__main__":
    unittest.main()
