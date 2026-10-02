#!/usr/bin/env python3
"""Read plan limits for the Claude and Codex accounts stored by CLIProxyAPI.

Tokens are only read, never refreshed: the proxy owns refresh-token rotation.
"""
from __future__ import annotations
import datetime as dt
import json
import os
import threading
import time
import urllib.error
import urllib.request
import uuid
from pathlib import Path

AUTH_DIR = Path(os.environ.get("CLI_PROXY_AUTH_DIR", "~/.cli-proxy-api")).expanduser()
CLAUDE_URL = "https://api.anthropic.com/api/oauth/usage"
CODEX_BASE = "https://chatgpt.com/backend-api/wham"
CODEX_URL = f"{CODEX_BASE}/usage"
CODEX_RESETS_URL = f"{CODEX_BASE}/rate-limit-reset-credits"
CACHE_SECONDS = 60
EXPIRED = "Sign-in expired. Send a request through the proxy to refresh it."
RESET_MESSAGES = {
    "no_credit": "No reset credits left on this account.",
    "nothing_to_reset": "Nothing to reset: no limit is in use right now.",
    "already_redeemed": "That reset was already used. Refresh to see the current limits.",
}

CLAUDE_WINDOWS = (
    ("five_hour", "5 hours"), ("seven_day", "Weekly"),
    ("seven_day_opus", "Weekly Opus"), ("seven_day_sonnet", "Weekly Sonnet"),
)
CODEX_LABELS = {18000: "5 hours", 604800: "Weekly"}


def http_get(url: str, headers: dict) -> dict:
    request = urllib.request.Request(url, headers={"User-Agent": "agent-usage-stats", **headers})
    with urllib.request.urlopen(request, timeout=10) as response:
        return json.load(response)


def http_post(url: str, headers: dict, body: dict) -> dict:
    request = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), method="POST",
        headers={"User-Agent": "agent-usage-stats", "Content-Type": "application/json", **headers})
    with urllib.request.urlopen(request, timeout=10) as response:
        return json.load(response)


def count(value) -> int:
    try:
        return max(0, int(value or 0))
    except (TypeError, ValueError):
        return 0


def window(label: str, percent, resets_at) -> dict:
    return {"label": label, "percent": max(0.0, float(percent or 0)), "resets_at": resets_at}


def claude_windows(payload: dict) -> list[dict]:
    return [window(label, payload[key].get("utilization"), payload[key].get("resets_at"))
        for key, label in CLAUDE_WINDOWS if isinstance(payload.get(key), dict)]


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
    account = {"provider": kind, "name": auth.get("email") or kind, "windows": [], "error": ""}
    token = auth.get("access_token")
    if not token:
        account["error"] = EXPIRED
        return account
    try:
        if kind == "claude":
            payload = fetch(CLAUDE_URL, {"Authorization": f"Bearer {token}",
                "anthropic-beta": "oauth-2025-04-20"})
            account["windows"] = claude_windows(payload)
        else:
            payload = fetch(CODEX_URL, {"Authorization": f"Bearer {token}",
                "chatgpt-account-id": auth.get("account_id", "")})
            account["windows"] = codex_windows(payload)
            account["plan"] = payload.get("plan_type") or auth.get("plan_type")
            credits = payload.get("rate_limit_reset_credits") or {}
            account["resets"] = {"available": count(credits.get("available_count")),
                "applicable": count(credits.get("applicable_available_count"))}
    except urllib.error.HTTPError as failure:
        account["error"] = EXPIRED if failure.code in (401, 403) else f"Provider returned HTTP {failure.code}."
    except (OSError, ValueError):
        account["error"] = "Provider unreachable."
    return account


def collect_quota(auth_dir: Path = AUTH_DIR, fetch=http_get) -> dict:
    accounts = []
    for path in sorted(Path(auth_dir).glob("*.json")):
        try:
            auth = json.loads(path.read_text())
        except (OSError, ValueError):
            continue
        if auth.get("type") not in ("claude", "codex") or auth.get("disabled"):
            continue
        accounts.append({"id": path.stem, **read_account(auth, fetch)})
    return {"generated_at": dt.datetime.now(dt.timezone.utc).isoformat(), "accounts": accounts}


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


def load_auth(auth_dir: Path, account_id) -> dict:
    # The id is a file stem, so anything that could leave the auth folder is unknown.
    if not isinstance(account_id, str) or not account_id or Path(account_id).name != account_id \
            or account_id.startswith("."):
        raise ResetError("Unknown account.", 404)
    try:
        return json.loads((Path(auth_dir) / f"{account_id}.json").read_text())
    except (OSError, ValueError):
        raise ResetError("Unknown account.", 404) from None


def codex_headers(auth_dir: Path, account_id) -> dict:
    auth = load_auth(auth_dir, account_id)
    if auth.get("type") != "codex" or auth.get("disabled"):
        raise ResetError("Only Codex accounts have resets. Claude limits clear when their window ends.", 400)
    token = auth.get("access_token")
    if not token:
        raise ResetError(EXPIRED, 401)
    return {"Authorization": f"Bearer {token}", "chatgpt-account-id": auth.get("account_id", "")}


def list_resets(account_id, auth_dir: Path = AUTH_DIR, fetch=http_get) -> dict:
    """The credits a reset can spend, read-only."""
    headers = codex_headers(auth_dir, account_id)
    try:
        listing = fetch(CODEX_RESETS_URL, headers)
    except (OSError, ValueError) as failure:
        raise provider_failure(failure, "listing reset credits") from None
    return {"credits": [{key: item.get(key) for key in ("id", "title", "granted_at", "expires_at")}
        for item in usable_credits(listing)]}


_reset_lock = threading.Lock()


def reset_codex(account_id, credit_id=None, auth_dir: Path = AUTH_DIR, fetch=http_get, post=http_post) -> dict:
    """Spend one banked reset credit: `credit_id`, or the earliest-expiring when omitted.

    Irreversible; the caller must have the user's consent. Raises ResetError for every
    refusal or failure, so nothing is spent silently.
    """
    with _reset_lock:
        headers = codex_headers(auth_dir, account_id)
        try:
            usable = usable_credits(fetch(CODEX_RESETS_URL, headers))
        except (OSError, ValueError) as failure:
            raise provider_failure(failure, "listing reset credits") from None
        if not usable:
            raise ResetError(RESET_MESSAGES["no_credit"], 409)
        if credit_id is None:
            credit_id = usable[0]["id"]
        elif credit_id not in {item["id"] for item in usable}:
            raise ResetError("That reset is no longer available. Reopen the list to see the current ones.", 409)
        try:
            outcome = post(f"{CODEX_RESETS_URL}/consume", headers,
                {"redeem_request_id": str(uuid.uuid4()), "credit_id": credit_id})
        except (OSError, ValueError) as failure:
            raise provider_failure(failure, "using the reset", confirmed=False) from None
        code = outcome.get("code") if isinstance(outcome, dict) else None
        if code != "reset":
            if code in RESET_MESSAGES:
                raise ResetError(RESET_MESSAGES[code], 409)
            raise ResetError("Unexpected response from the provider. Refresh to check the account before retrying.")
        invalidate()
        return {"ok": True}


_cache = {"at": 0.0, "value": None}
_lock = threading.Lock()


def invalidate() -> None:
    with _lock:
        _cache["value"] = None


def cached_quota(**kwargs) -> dict:
    """Share one provider read across browser tabs and refreshes."""
    with _lock:
        if _cache["value"] is None or time.monotonic() - _cache["at"] > CACHE_SECONDS:
            _cache["value"] = collect_quota(**kwargs)
            _cache["at"] = time.monotonic()
        return _cache["value"]
