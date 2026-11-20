#!/usr/bin/env python3
"""Read plan limits for the Claude and Codex accounts stored by CLIProxyAPI, and the Antigravity login T3 keeps for agy.

Token files are only read, never written: the proxy and agy own them. An expired Antigravity
access token is refreshed in memory only.
"""
from __future__ import annotations
import datetime as dt
import functools
import json
import os
import re
import subprocess
import threading
import time
import urllib.error
import urllib.request
import uuid
from dataclasses import dataclass
from pathlib import Path
from quota_cache import UsageCache

AUTH_DIR = Path(os.environ.get("CLI_PROXY_AUTH_DIR", "~/.cli-proxy-api")).expanduser()
# T3 keeps one agy login per Antigravity provider instance.
ANTIGRAVITY_TOKENS = "userdata/providers/antigravity/*/antigravity-acp/antigravity-oauth-token"
T3_HOME = Path("~/.t3").expanduser()
# Antigravity's installed-app OAuth client, copied from the agy binary. It stays out of this public repo.
ANTIGRAVITY_CLIENT = Path("~/.config/cli-quota/antigravity-client.json").expanduser()
# agy talks to the daily host. The production host serves other models and keeps separate quota.
ANTIGRAVITY_BASE = "https://daily-cloudcode-pa.googleapis.com/v1internal"
ANTIGRAVITY_FALLBACK_VERSION = "1.5.13"
ANTIGRAVITY_METADATA = {"ideType": "ANTIGRAVITY"}
# The summary buckets the widget shows. Gemini 4 Argon has its own weekly bucket, which is left out.
ANTIGRAVITY_BUCKETS = {"gemini-5h": "Gemini 5h", "gemini-weekly": "Gemini 7d"}
ANTIGRAVITY_EXPIRED = "Sign-in expired. Sign in to Antigravity again in T3."
GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
TOKEN_MARGIN = dt.timedelta(minutes=1)
CLAUDE_BASE = "https://api.anthropic.com/api"
# cedar_ember asks for the banked usage-limit resets; skip_spend leaves out the dollar spend.
CLAUDE_URL = f"{CLAUDE_BASE}/oauth/usage?cedar_ember=1&skip_spend=1"
CLAUDE_FALLBACK_VERSION = "2.1.288"
CODEX_BASE = "https://chatgpt.com/backend-api/wham"
CODEX_URL = f"{CODEX_BASE}/usage"
CODEX_RESETS_URL = f"{CODEX_BASE}/rate-limit-reset-credits"
CACHE_SECONDS = 60
_usage_cache = UsageCache()
EXPIRED = "Sign-in expired. Send a request through the proxy to refresh it."
RESET_MESSAGES = {
    "no_credit": "No reset credits left on this account.",
    "nothing_to_reset": "Nothing to reset: no limit is in use right now.",
    "already_redeemed": "That reset was already used. Refresh to see the current limits.",
    "not_limited": "Nothing to reset: no limit is in use right now.",
    "already_used": "That reset was already used. Refresh to see the current limits.",
    "cooldown": "A reset was used recently. Try again after the cooldown.",
    "ineligible": "This account is not eligible for that reset.",
    "unavailable": "Resets are unavailable right now. Try again later.",
}

CODEX_LABELS = {18000: "5 hours", 604800: "Weekly"}


@functools.lru_cache(maxsize=1)
def claude_user_agent() -> str:
    """Anthropic only sends the reset block to the Claude Code CLI, so identify as it."""
    try:
        version = subprocess.run(["claude", "--version"], capture_output=True, text=True,
            timeout=5).stdout.split()[0]
    except (OSError, subprocess.SubprocessError, IndexError):
        version = ""
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        version = CLAUDE_FALLBACK_VERSION
    return f"claude-cli/{version} (external, cli)"


@functools.lru_cache(maxsize=1)
def antigravity_user_agent() -> str:
    """Identify as the installed agy CLI.

    loadCodeAssist leaves out the project unless the caller is Antigravity, and retrieveUserQuotaSummary
    returns the Gemini groups only to a recent `antigravity/cli/<version>`. Version 1.0.0 gets only Claude and GPT.
    """
    try:
        version = subprocess.run(["agy", "--version"], capture_output=True, text=True, timeout=5).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        version = ""

    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        version = ANTIGRAVITY_FALLBACK_VERSION

    return f"antigravity/cli/{version}"


def claude_headers(auth: dict) -> dict:
    return {"Authorization": f"Bearer {auth.get('access_token')}", "anthropic-beta": "oauth-2025-04-20",
        "User-Agent": claude_user_agent()}


def codex_headers(auth: dict) -> dict:
    return {"Authorization": f"Bearer {auth.get('access_token')}", "chatgpt-account-id": auth.get("account_id", "")}


def http_get(url: str, headers: dict) -> dict:
    request = urllib.request.Request(url, headers={"User-Agent": "cli-quota", **headers})
    with urllib.request.urlopen(request, timeout=10) as response:
        return json.load(response)


def http_post(url: str, headers: dict, body: dict) -> dict:
    request = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"User-Agent": "cli-quota", "Content-Type": "application/json", **headers})
    with urllib.request.urlopen(request, timeout=10) as response:
        return json.load(response)


def count(value) -> int:
    try:
        return max(0, int(value or 0))
    except (TypeError, ValueError):
        return 0


def window(label: str, percent, resets_at) -> dict:
    return {"label": label, "percent": max(0.0, float(percent or 0)), "resets_at": resets_at}


CLAUDE_LABELS = {"session": "5 hours", "weekly_all": "Weekly"}


def claude_windows(payload: dict) -> list[dict]:
    """The account-wide limits only; model-scoped weekly limits are left out."""
    windows = []

    for limit in payload.get("limits") or []:

        if not isinstance(limit, dict):
            continue

        label = CLAUDE_LABELS.get(limit.get("kind"))

        if label is not None:
            windows.append(window(label, limit.get("percent"), limit.get("resets_at")))

    return windows


def codex_windows(payload: dict) -> list[dict]:
    limit = payload.get("rate_limit") or {}
    result = []
    for key in ("primary_window", "secondary_window"):
        item = limit.get(key)
        if not isinstance(item, dict):
            continue
        seconds = item.get("limit_window_seconds")
        reset = item.get("reset_at")
        resets_at = dt.datetime.fromtimestamp(reset, dt.timezone.utc).isoformat() if reset else None
        result.append(window(CODEX_LABELS.get(seconds, f"{round((seconds or 0) / 3600)} hours"),
            item.get("used_percent"), resets_at))
    return result


def read_account(auth: dict, fetch) -> dict:
    kind = auth.get("type")
    priority = auth.get("priority")
    account = {"provider": kind, "name": auth.get("email") or kind, "windows": [], "error": "",
        "priority": priority if type(priority) is int else None, "available": None}
    token = auth.get("access_token")
    if not token:
        account["error"] = EXPIRED
        return account
    try:
        if kind == "claude":
            payload = fetch(CLAUDE_URL, claude_headers(auth))
            account["windows"] = claude_windows(payload)
            account["available"] = all(not payload[key].get("locked_reason")
                for key in ("five_hour", "seven_day") if isinstance(payload.get(key), dict))
            credits = claude_credits(payload)
            if credits:
                account["resets"] = {"available": sum(item["resets_left"] for item in credits)}
        else:
            payload = fetch(CODEX_URL, codex_headers(auth))
            account["windows"] = codex_windows(payload)
            limit = payload.get("rate_limit") or {}
            account["available"] = bool(limit.get("allowed", True)) and not limit.get("limit_reached", False)
            account["plan"] = payload.get("plan_type") or auth.get("plan_type")
            credits = payload.get("rate_limit_reset_credits") or {}
            account["resets"] = {"available": count(credits.get("available_count")),
                "applicable": count(credits.get("applicable_available_count"))}
    except urllib.error.HTTPError as failure:
        account["error"] = EXPIRED if failure.code in (401, 403) else f"Provider returned HTTP {failure.code}."
    except (OSError, ValueError):
        account["error"] = "Provider unreachable."
    return account


def iso_time(timestamp) -> str | None:
    return dt.datetime.fromtimestamp(timestamp, dt.timezone.utc).isoformat() if timestamp is not None else None


def usage_error(snapshot, expired: str = EXPIRED) -> str:
    if snapshot.status == 429:
        when = dt.datetime.fromtimestamp(snapshot.retry_at).astimezone().strftime("%H:%M")
        return f"Rate limited. Next quota check at {when}."
    if snapshot.status in (401, 403):
        return expired
    if snapshot.status is not None:
        return f"Provider returned HTTP {snapshot.status}."
    return "Provider unreachable."


def with_snapshot(account: dict, snapshot, expired: str = EXPIRED) -> dict:
    """Add the cache state of the account's last provider read; `snapshot` is None when nothing was read."""
    account["updated_at"] = iso_time(snapshot.updated_at) if snapshot else None
    account["retry_at"] = iso_time(snapshot.retry_at) if snapshot and snapshot.failed else None

    if snapshot and snapshot.failed:
        account["error"] = usage_error(snapshot, expired)

        if snapshot.updated_at is not None:
            account["error"] += " Quota is out of date."

    return account


def collect_quota(auth_dir: Path = AUTH_DIR, fetch=http_get, cache=None, antigravity_tokens=(),
        post=http_post, antigravity_client: Path = ANTIGRAVITY_CLIENT) -> dict:
    if cache is None:
        cache = UsageCache()

    accounts = []

    for path in sorted(Path(auth_dir).glob("*.json")):
        try:
            auth = json.loads(path.read_text())
        except (OSError, ValueError):
            continue
        if auth.get("type") not in ("claude", "codex") or auth.get("disabled"):
            continue
        snapshot = None

        def cached_fetch(url, headers):
            nonlocal snapshot
            snapshot = cache.read(auth["type"], path.stem, lambda: fetch(url, headers))
            if snapshot.payload is None:
                raise OSError("No usage data.")
            return snapshot.payload

        accounts.append(with_snapshot({"id": path.stem, **read_account(auth, cached_fetch)}, snapshot))

    for path in antigravity_tokens:
        account = read_antigravity(Path(path), cache, post, antigravity_client)

        if account is not None:
            accounts.append(account)

    return {"generated_at": dt.datetime.now(dt.timezone.utc).isoformat(), "accounts": accounts}


@dataclass(frozen=True)
class AntigravityLogin:
    email: str
    access_token: str
    refresh_token: str
    expiry: dt.datetime


def parse_antigravity_login(document) -> AntigravityLogin | None:
    """agy's token file, or None when it is not one."""
    token = document.get("token") if isinstance(document, dict) else None

    try:
        login = AntigravityLogin(str(document.get("id_token_email") or ""), str(token["access_token"]),
            str(token["refresh_token"]), dt.datetime.fromisoformat(token["expiry"]))
    except (KeyError, TypeError, ValueError):
        return None

    return login if login.expiry.tzinfo is not None else None


def load_antigravity_client(path: Path) -> dict | None:
    try:
        client = json.loads(Path(path).read_text())
    except (OSError, ValueError):
        return None

    if not isinstance(client, dict) or not client.get("client_id") or not client.get("client_secret"):
        return None

    return {"client_id": client["client_id"], "client_secret": client["client_secret"]}


def refresh_google_token(login: AntigravityLogin, client: dict, post) -> str:
    """A fresh access token for this read only. Google keeps the refresh token, so agy's file stays valid."""
    try:
        reply = post(GOOGLE_TOKEN_URL, {}, {"grant_type": "refresh_token", "refresh_token": login.refresh_token,
            **client})
    except urllib.error.HTTPError as failure:
        # Google answers a revoked or expired refresh token with HTTP 400 invalid_grant.
        if failure.code == 400:
            raise urllib.error.HTTPError(failure.url, 401, "Refresh token rejected.", failure.headers,
                None) from None
        raise

    token = reply.get("access_token") if isinstance(reply, dict) else None

    if not isinstance(token, str) or not token:
        raise ValueError("Google returned no access token.")

    return token


def antigravity_quota(access_token: str, post) -> dict:
    """The quota summary of the account's project: a weekly and a 5-hour bucket per model group."""
    headers = {"User-Agent": antigravity_user_agent(), "Authorization": f"Bearer {access_token}"}
    assist = post(f"{ANTIGRAVITY_BASE}:loadCodeAssist", headers, {"metadata": ANTIGRAVITY_METADATA})
    project = assist.get("cloudaicompanionProject") if isinstance(assist, dict) else None

    if not project:
        raise ValueError("Antigravity returned no project.")

    return post(f"{ANTIGRAVITY_BASE}:retrieveUserQuotaSummary", headers, {"project": project})


def antigravity_windows(payload: dict) -> list[dict]:
    """The 5-hour and weekly limit that Gemini models share, 5 hours first.

    Protobuf JSON leaves out zero values, so a bucket without remainingFraction is used up.
    """
    buckets = {bucket["bucketId"]: bucket for group in payload.get("groups") or [] if isinstance(group, dict)
        for bucket in group.get("buckets") or [] if isinstance(bucket, dict)
        and bucket.get("bucketId") in ANTIGRAVITY_BUCKETS
        and isinstance(bucket.get("remainingFraction", 0), (int, float))}

    return [window(label, 100 * (1 - buckets[key].get("remainingFraction", 0)), buckets[key].get("resetTime"))
        for key, label in ANTIGRAVITY_BUCKETS.items() if key in buckets]


def read_antigravity(path: Path, cache: UsageCache, post, client_path: Path) -> dict | None:
    """One agy login's quota, or None when the file is not a login."""
    try:
        login = parse_antigravity_login(json.loads(path.read_text()))
    except (OSError, ValueError):
        login = None

    if login is None:
        return None

    # The folder above antigravity-acp/ is T3's provider instance.
    account_id = f"antigravity-{path.parents[1].name[:8]}"
    account = {"id": account_id, "provider": "antigravity", "name": login.email or "Antigravity", "windows": [],
        "error": "", "priority": None, "available": None}
    expired = login.expiry < dt.datetime.now(dt.timezone.utc) + TOKEN_MARGIN
    client = load_antigravity_client(client_path) if expired else None

    if expired and client is None:
        account["error"] = f"Sign-in expired, and {client_path} is missing, so it cannot be refreshed."

        return with_snapshot(account, None)

    def load():
        token = refresh_google_token(login, client, post) if expired else login.access_token

        return antigravity_quota(token, post)

    snapshot = cache.read("antigravity", account_id, load)

    if snapshot.payload is not None:
        account["windows"] = antigravity_windows(snapshot.payload)

    return with_snapshot(account, snapshot, ANTIGRAVITY_EXPIRED)


class ResetError(Exception):
    """A reset that was refused or failed; `status` is the HTTP code to answer with."""

    def __init__(self, message: str, status: int = 502):
        super().__init__(message)
        self.status = status


def provider_failure(failure: Exception, action: str, confirmed: bool = True) -> ResetError:
    if isinstance(failure, urllib.error.HTTPError):
        if failure.code in (401, 403):
            return ResetError(EXPIRED, 401)
        if failure.code == 429:
            return ResetError("Rate limited by the provider. Try again later.", 429)
        return ResetError(f"Provider returned HTTP {failure.code} while {action}.", 502)
    if confirmed:
        return ResetError(f"Provider unreachable while {action}.", 502)
    return ResetError("Could not confirm the reset. Refresh to check whether it was used.", 502)


def usable_credits(listing) -> list[dict]:
    """Credits that apply to Codex limits, earliest expiry first; no expiry goes last."""
    credits = listing.get("credits") if isinstance(listing, dict) else None
    usable = [item for item in credits or [] if isinstance(item, dict) and item.get("id")
        and item.get("status") == "available"
        and item.get("reset_type", "codex_rate_limits") == "codex_rate_limits"
        and item.get("is_supported_by_plan") is not False]
    usable.sort(key=lambda item: (item.get("expires_at") is None, item.get("expires_at") or ""))
    return usable


def grant_is_open(grant: dict, now: dt.datetime) -> bool:
    try:
        start = dt.datetime.fromisoformat(grant["starts_at"]) if grant.get("starts_at") else None
        end = dt.datetime.fromisoformat(grant["ends_at"]) if grant.get("ends_at") else None
        return (start is None or start <= now) and (end is None or now < end)
    except (TypeError, ValueError):
        return False


def is_fable_grant(grant: dict) -> bool:
    # The grant names its model only in the label; there is no structured model field.
    label = grant.get("label")

    return isinstance(label, str) and re.search(r"\bfable\b", label, re.IGNORECASE) is not None


def claude_credits(payload) -> list[dict]:
    """Claude's banked limit resets (the cedar_ember program), earliest expiry first.

    A grant counts when it is not paused, has resets left, is inside its dates and is not a Fable grant.
    Anthropic decides whether a grant can be spent right now and which limits it clears.
    """
    block = payload.get("cedar_ember") if isinstance(payload, dict) else None
    if not isinstance(block, dict) or block.get("eligible") is not True:
        return []
    now = dt.datetime.now(dt.timezone.utc)
    usable = [{"id": grant["id"], "title": grant.get("label"), "granted_at": grant.get("starts_at"),
        "expires_at": grant.get("ends_at"), "resets_left": count(grant.get("resets_left"))}
        for grant in block.get("grants") or [] if isinstance(grant, dict) and grant.get("id")
        and not grant.get("paused") and count(grant.get("resets_left")) > 0 and grant_is_open(grant, now)
        and not is_fable_grant(grant)]
    usable.sort(key=lambda item: (item["expires_at"] is None, item["expires_at"] or ""))
    return usable


def load_auth(auth_dir: Path, account_id) -> dict:
    # The id is a file stem, so anything that could leave the auth folder is unknown.
    if not isinstance(account_id, str) or not account_id or Path(account_id).name != account_id \
            or account_id.startswith("."):
        raise ResetError("Unknown account.", 404)
    try:
        return json.loads((Path(auth_dir) / f"{account_id}.json").read_text())
    except (OSError, ValueError):
        raise ResetError("Unknown account.", 404) from None


def reset_account(auth_dir: Path, account_id) -> dict:
    auth = load_auth(auth_dir, account_id)
    if auth.get("type") not in ("claude", "codex") or auth.get("disabled"):
        raise ResetError("This account has no resets.", 400)
    if not auth.get("access_token"):
        raise ResetError(EXPIRED, 401)
    return auth


def provider_credits(auth: dict, fetch) -> list[dict]:
    try:
        if auth["type"] == "claude":
            return claude_credits(fetch(CLAUDE_URL, claude_headers(auth)))
        return usable_credits(fetch(CODEX_RESETS_URL, codex_headers(auth)))
    except (OSError, ValueError) as failure:
        raise provider_failure(failure, "listing reset credits") from None


def consume_credit(auth: dict, credit_id: str, post) -> str | None:
    """Ask the provider to spend one credit; returns its answer code."""
    request_id = str(uuid.uuid4())
    if auth["type"] == "claude":
        try:
            organization = str(uuid.UUID(str(auth.get("organization_uuid"))))
        except ValueError:
            raise ResetError("This Claude account has no organization to reset. Sign in again through the proxy.",
                409) from None
        outcome = post(f"{CLAUDE_BASE}/organizations/{organization}/reset_rate_limits", claude_headers(auth),
            {"program": "cedar_ember", "grant_id": credit_id, "request_id": request_id})
        return outcome.get("result") if isinstance(outcome, dict) else None
    outcome = post(f"{CODEX_RESETS_URL}/consume", codex_headers(auth),
        {"redeem_request_id": request_id, "credit_id": credit_id})
    return outcome.get("code") if isinstance(outcome, dict) else None


def list_resets(account_id, auth_dir: Path = AUTH_DIR, fetch=http_get) -> dict:
    """The credits a reset can spend, read-only."""
    auth = reset_account(auth_dir, account_id)
    if auth["type"] == "claude":
        snapshot = _usage_cache.read("claude", account_id, lambda: fetch(CLAUDE_URL, claude_headers(auth)))
        if snapshot.failed:
            raise ResetError(usage_error(snapshot), snapshot.status or 502)
        credits = claude_credits(snapshot.payload)
    else:
        credits = provider_credits(auth, fetch)
    return {"credits": [{key: item.get(key) for key in ("id", "title", "granted_at", "expires_at")}
        for item in credits]}


_reset_lock = threading.Lock()


def reset_credit(account_id, credit_id=None, auth_dir: Path = AUTH_DIR, fetch=http_get, post=http_post) -> dict:
    """Spend one banked reset credit: `credit_id`, or the earliest-expiring when omitted.

    Irreversible; the caller must have the user's consent. Raises ResetError for every
    refusal or failure, so nothing is spent silently.
    """
    with _reset_lock:
        auth = reset_account(auth_dir, account_id)
        usable = provider_credits(auth, fetch)
        if not usable:
            raise ResetError(RESET_MESSAGES["no_credit"], 409)
        if credit_id is None:
            credit_id = usable[0]["id"]
        elif credit_id not in {item["id"] for item in usable}:
            raise ResetError("That reset is no longer available. Reopen the list to see the current ones.", 409)
        try:
            code = consume_credit(auth, credit_id, post)
        except (OSError, ValueError) as failure:
            raise provider_failure(failure, "using the reset", confirmed=False) from None
        if code != "reset":
            if code in RESET_MESSAGES:
                raise ResetError(RESET_MESSAGES[code], 409)
            raise ResetError("Unexpected response from the provider. Refresh to check the account before retrying.")
        invalidate(account_id)
        return {"ok": True}


_cache = {"at": 0.0, "value": None}
_lock = threading.Lock()


def invalidate(account_id=None) -> None:
    with _lock:
        _cache["value"] = None
        _usage_cache.invalidate(account_id)


def cached_quota(**kwargs) -> dict:
    """Share one provider read across browser tabs and refreshes."""
    with _lock:
        if _cache["value"] is None or time.monotonic() - _cache["at"] > CACHE_SECONDS:
            _cache["value"] = collect_quota(cache=_usage_cache,
                antigravity_tokens=sorted(T3_HOME.glob(ANTIGRAVITY_TOKENS)), **kwargs)
            _cache["at"] = time.monotonic()
        return _cache["value"]
