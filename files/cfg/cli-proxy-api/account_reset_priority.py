#!/usr/bin/env python3
"""Prefer the CLIProxyAPI account whose weekly quota resets soonest.

CLIProxyAPI reads a top-level "priority" from each auth JSON (higher wins; the
highest available tier is used until it is in cooldown). Priority is compared
only between accounts of the same provider. For each supported provider this
script reads the local dashboard's shared quota API and
rewrites "priority" so that:

  * usable accounts are ranked by weekly reset time, soonest first, with the
    5-hour reset as a tie-breaker, so quota that is about to expire is used first;
  * accounts at their 5-hour or weekly limit drop to priority 0;
  * accounts whose usage lookup fails keep their current priority.

Supported providers: Codex and Claude. The dashboard owns provider reads and cooldowns.

Files are only rewritten when the value changes. Each write is an atomic
replace guarded by a re-read, so a concurrent token refresh by the proxy is
never overwritten (that file is skipped and retried on the next timer tick).

Usage: account_reset_priority.py [--dry-run] [--auth-dir DIR] [--provider NAME ...]
"""

import argparse
import glob
import json
import math
import os
import sys
import tempfile
import time
import urllib.request
from datetime import datetime

PRIORITY_STEP = 10
MAX_QUOTA_AGE = 600
QUOTA_URL = "http://127.0.0.1:8770/api/quota"
NEVER = float("inf")


def http_json(url):
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=55) as resp:
        return json.load(resp)


def iso_ts(value):
    return datetime.fromisoformat(value).timestamp() if value else NEVER


def account_usage(account, now=None):
    if account.get("error"):
        raise ValueError(account["error"])
    now = time.time() if now is None else now
    updated = iso_ts(account.get("updated_at"))
    if updated == NEVER or now - updated > MAX_QUOTA_AGE:
        raise ValueError("quota is out of date")
    if type(account.get("available")) is not bool:
        raise ValueError("quota availability is unknown")
    windows = account.get("windows")
    if not isinstance(windows, list) or not windows:
        raise ValueError("quota windows are unavailable")
    limits = {}
    for window in windows:
        if not isinstance(window, dict):
            raise ValueError("invalid quota window")
        if window.get("label") not in ("5 hours", "Weekly"):
            continue
        percent = window.get("percent")
        if type(percent) not in (int, float) or not math.isfinite(percent) or percent < 0:
            raise ValueError("invalid quota percent")
        limits[window["label"]] = window
    if not limits:
        raise ValueError("no supported quota windows")
    short = limits.get("5 hours", {})
    weekly = limits.get("Weekly", {})
    return {
        "usable": account["available"] and all(item["percent"] < 100 for item in limits.values()),
        "weekly_reset": iso_ts(weekly.get("resets_at")),
        "weekly_used": weekly.get("percent"),
        "short_reset": iso_ts(short.get("resets_at")),
        "short_used": short.get("percent"),
    }


PROVIDERS = ("claude", "codex")


def desired_priorities(stats):
    usable = sorted(
        (name for name, s in stats.items() if s["usable"]),
        key=lambda n: (stats[n]["weekly_reset"], stats[n]["short_reset"], n),
    )
    out = {name: 0 for name in stats}
    for rank, name in enumerate(usable):
        out[name] = (len(usable) - rank) * PRIORITY_STEP
    return out


def write_priority(path, original_bytes, priority):
    data = json.loads(original_bytes)
    data["priority"] = priority
    indent = 2 if original_bytes.startswith(b"{\n") else None
    payload = json.dumps(data, indent=indent).encode()

    directory = os.path.dirname(path)
    mode = os.stat(path).st_mode & 0o777
    # No .json suffix: the proxy's watcher ignores non-JSON files in the auth dir.
    fd, tmp = tempfile.mkstemp(dir=directory, prefix=".account-priority-", suffix=".tmp")
    try:
        with os.fdopen(fd, "wb") as fh:
            fh.write(payload)
            fh.flush()
            os.fsync(fh.fileno())
        os.chmod(tmp, mode)
        with open(path, "rb") as fh:
            if fh.read() != original_bytes:
                raise RuntimeError("file changed during update (token refresh?)")
        os.replace(tmp, path)
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def fmt(ts, used):
    when = "?" if ts == NEVER else time.strftime("%Y-%m-%d %H:%M", time.localtime(ts))
    return f"{when} ({used}% used)"


def update_provider(provider, accounts, auth_dir, dry_run):
    """Returns (files written or planned, failures)."""
    paths = sorted(glob.glob(os.path.join(auth_dir, f"{provider}-*.json")))
    if not paths:
        return 0, 0

    raw, stats, current = {}, {}, {}
    failures = 0
    for path in paths:
        name = os.path.basename(path)
        with open(path, "rb") as fh:
            raw[name] = fh.read()
        auth = json.loads(raw[name])
        current[name] = auth.get("priority")
        if auth.get("disabled"):
            print(f"{name}: disabled, skipped")
            continue
        try:
            account = accounts.get(os.path.splitext(name)[0])
            if account is None or account.get("provider") != provider:
                raise ValueError("account is absent from the quota API")
            stats[name] = account_usage(account)
        except (TypeError, ValueError) as e:
            failures += 1
            print(f"{name}: usage lookup failed: {e}; priority left as {current[name]}")

    changed = 0
    for name, prio in desired_priorities(stats).items():
        s = stats[name]
        line = (
            f"{name}: weekly reset {fmt(s['weekly_reset'], s['weekly_used'])}, "
            f"5h reset {fmt(s['short_reset'], s['short_used'])}, "
            f"usable={s['usable']} priority {current[name]} -> {prio}"
        )
        if current[name] == prio:
            print(line + " (unchanged)")
            continue
        changed += 1
        if dry_run:
            print(line + " (dry run)")
            continue
        try:
            write_priority(os.path.join(auth_dir, name), raw[name], prio)
            print(line + " (written)")
        except Exception as e:
            failures += 1
            print(line + f" (NOT written: {e})")
    return changed, failures


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--auth-dir", default=os.path.expanduser("~/.cli-proxy-api"))
    parser.add_argument("--dry-run", action="store_true", help="print the plan without writing")
    parser.add_argument("--quota-url", default=QUOTA_URL, help="local dashboard quota API")
    parser.add_argument(
        "--provider",
        action="append",
        choices=sorted(PROVIDERS),
        help="limit to this provider (repeatable; default: all)",
    )
    args = parser.parse_args()

    try:
        document = http_json(args.quota_url)
        if not isinstance(document, dict) or not isinstance(document.get("accounts"), list):
            raise ValueError("invalid quota response")
        accounts = {}
        for account in document["accounts"]:
            if not isinstance(account, dict) or not isinstance(account.get("id"), str) or not account["id"]:
                raise ValueError("invalid quota account")
            if account["id"] in accounts:
                raise ValueError("duplicate quota account")
            accounts[account["id"]] = account
    except (OSError, ValueError) as failure:
        print(f"Quota API unavailable: {failure}; all priorities left unchanged", file=sys.stderr)
        return 1

    failures = 0
    for provider in args.provider or sorted(PROVIDERS):
        _, failed = update_provider(provider, accounts, args.auth_dir, args.dry_run)
        failures += failed
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
