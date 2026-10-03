#!/usr/bin/env python3
"""Prefer the CLIProxyAPI account whose weekly quota resets soonest.

CLIProxyAPI reads a top-level "priority" from each auth JSON (higher wins; the
highest available tier is used until it is in cooldown). Priority is compared
only between accounts of the same provider. For each supported provider this
script asks the provider's usage endpoint for every OAuth account's quota and
rewrites "priority" so that:

  * usable accounts are ranked by weekly reset time, soonest first, with the
    5-hour reset as a tie-breaker, so quota that is about to expire is used first;
  * accounts at their 5-hour or weekly limit drop to priority 0;
  * accounts whose usage lookup fails keep their current priority.

Supported providers: Codex (chatgpt.com/backend-api/wham/usage) and Claude
(api.anthropic.com/api/oauth/usage). Both endpoints are undocumented.

Files are only rewritten when the value changes. Each write is an atomic
replace guarded by a re-read, so a concurrent token refresh by the proxy is
never overwritten (that file is skipped and retried on the next timer tick).

Usage: account_reset_priority.py [--dry-run] [--auth-dir DIR] [--provider NAME ...]
"""

import argparse
import glob
import json
import os
import sys
import tempfile
import time
import urllib.error
import urllib.request
from datetime import datetime

PRIORITY_STEP = 10
NEVER = float("inf")


def http_json(url, headers):
    req = urllib.request.Request(url, headers={"Accept": "application/json", **headers})
    with urllib.request.urlopen(req, timeout=20) as resp:
        return json.load(resp)


def iso_ts(value):
    return datetime.fromisoformat(value).timestamp() if value else NEVER


def codex_usage(auth):
    usage = http_json(
        "https://chatgpt.com/backend-api/wham/usage",
        {
            "Authorization": "Bearer " + auth["access_token"],
            "ChatGPT-Account-Id": auth.get("account_id", ""),
            "User-Agent": "codex_cli_rs/0.50.0",
        },
    )
    rl = usage.get("rate_limit") or {}
    short = rl.get("primary_window") or {}
    weekly = rl.get("secondary_window") or {}
    return {
        "usable": bool(rl.get("allowed", True))
        and not rl.get("limit_reached", False)
        and (short.get("used_percent") or 0) < 100
        and (weekly.get("used_percent") or 0) < 100,
        "weekly_reset": weekly.get("reset_at") or NEVER,
        "weekly_used": weekly.get("used_percent"),
        "short_reset": short.get("reset_at") or NEVER,
        "short_used": short.get("used_percent"),
    }


def claude_usage(auth):
    usage = http_json(
        "https://api.anthropic.com/api/oauth/usage",
        {
            "Authorization": "Bearer " + auth["access_token"],
            "anthropic-beta": "oauth-2025-04-20",
            "User-Agent": "claude-cli/2.1.0 (external, cli)",
        },
    )
    short = usage.get("five_hour") or {}
    weekly = usage.get("seven_day") or {}
    return {
        "usable": (short.get("utilization") or 0) < 100
        and (weekly.get("utilization") or 0) < 100
        and not short.get("locked_reason")
        and not weekly.get("locked_reason"),
        "weekly_reset": iso_ts(weekly.get("resets_at")),
        "weekly_used": weekly.get("utilization"),
        "short_reset": iso_ts(short.get("resets_at")),
        "short_used": short.get("utilization"),
    }


# Auth file prefix in the auth dir -> usage fetcher.
PROVIDERS = {"codex": codex_usage, "claude": claude_usage}


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


def update_provider(provider, fetch, auth_dir, dry_run):
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
            stats[name] = fetch(auth)
        except urllib.error.HTTPError as e:
            failures += 1
            print(f"{name}: usage lookup failed: HTTP {e.code}; priority left as {current[name]}")
        except Exception as e:  # network errors, bad JSON
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
    parser.add_argument(
        "--provider",
        action="append",
        choices=sorted(PROVIDERS),
        help="limit to this provider (repeatable; default: all)",
    )
    args = parser.parse_args()

    failures = 0
    for provider in args.provider or sorted(PROVIDERS):
        _, failed = update_provider(provider, PROVIDERS[provider], args.auth_dir, args.dry_run)
        failures += failed
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
