#!/usr/bin/env python3
"""Read Codex, Claude, omp, and Pi JSONL; aggregate usage by model and WIB day."""
from __future__ import annotations
import argparse
import datetime as dt
import json
import os
from collections import defaultdict
from dataclasses import dataclass
from functools import partial
from pathlib import Path

WIB = dt.timezone(dt.timedelta(hours=7), name="WIB")
USAGE_FIELDS = (
    "input_tokens", "uncached_input_tokens", "cached_input_tokens",
    "cache_write_input_tokens", "output_tokens", "reasoning_output_tokens", "total_tokens",
)


def local_day(timestamp: str) -> str:
    parsed = dt.datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(WIB).date().isoformat()


def empty_usage() -> dict[str, int]:
    return dict.fromkeys(USAGE_FIELDS, 0)


def tokens(value) -> int:
    try:
        return max(0, int(value or 0))
    except (TypeError, ValueError, OverflowError):
        return 0


def normalize_usage(usage: dict, client: str) -> dict[str, int]:
    result = empty_usage()
    if client == "claude":
        result["uncached_input_tokens"] = tokens(usage.get("input_tokens"))
        result["cached_input_tokens"] = tokens(usage.get("cache_read_input_tokens"))
        result["cache_write_input_tokens"] = tokens(usage.get("cache_creation_input_tokens"))
        # Anthropic reports fresh input, cache reads and cache writes separately.
        result["input_tokens"] = sum(result[k] for k in (
            "uncached_input_tokens", "cached_input_tokens", "cache_write_input_tokens"))
        details = usage.get("output_tokens_details") or {}
        result["reasoning_output_tokens"] = tokens(details.get("thinking_tokens"))
    elif client in ("omp", "pi"):
        result["uncached_input_tokens"] = tokens(usage.get("input"))
        result["cached_input_tokens"] = tokens(usage.get("cacheRead"))
        result["cache_write_input_tokens"] = tokens(usage.get("cacheWrite"))
        result["input_tokens"] = sum(result[k] for k in (
            "uncached_input_tokens", "cached_input_tokens", "cache_write_input_tokens"))
        result["reasoning_output_tokens"] = tokens(usage.get("reasoning" if client == "pi" else "reasoningTokens"))
    else:
        for field in USAGE_FIELDS:
            result[field] = tokens(usage.get(field))
        result["uncached_input_tokens"] = max(0, result["input_tokens"]
            - result["cached_input_tokens"] - result["cache_write_input_tokens"])
    result["output_tokens"] = tokens(usage.get("output" if client in ("omp", "pi") else "output_tokens"))
    result["total_tokens"] = result["input_tokens"] + result["output_tokens"]
    return result


def events(path: Path):
    """Ignore a partial trailing write, malformed events and removed files."""
    try:
        with path.open(encoding="utf-8", errors="replace") as handle:
            for index, line in enumerate(handle):
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if isinstance(event, dict):
                    yield index, event
    except FileNotFoundError:
        return


@dataclass
class Record:
    identity: tuple
    timestamp: str
    model: str
    client: str
    provider: str
    thread: str
    usage: dict[str, int]


def read_codex(path: Path) -> list[Record]:
    meta, model, provider = {}, "unknown", "unknown"
    direct, fallback = [], []
    previous_total = None
    for index, event in events(path):
        kind, payload = event.get("type"), event.get("payload")
        if not isinstance(payload, dict):
            continue
        if kind == "session_meta":
            meta = payload
            model = meta.get("model") or model
            provider = meta.get("model_provider") or provider
        elif kind == "turn_context":
            model = payload.get("model") or model
            provider = payload.get("model_provider") or provider
        else:
            timestamp = event.get("timestamp")
            thread = meta.get("session_id") or meta.get("id") or path.stem
            if kind == "token_usage_record" and isinstance(payload.get("usage"), dict):
                identity = ("codex", payload["response_id"]) if payload.get("response_id") else (
                    "codex", thread, index)
                direct.append(Record(identity, timestamp, payload.get("model") or model,
                    "codex", provider, thread, normalize_usage(payload["usage"], "codex")))
            elif kind == "event_msg" and payload.get("type") == "token_count":
                info = payload.get("info") or {}
                usage, total = info.get("last_token_usage"), info.get("total_token_usage")
                if isinstance(usage, dict) and (total is None or total != previous_total):
                    fallback.append(Record(("codex", thread, index), timestamp, model,
                        "codex", provider, thread, normalize_usage(usage, "codex")))
                previous_total = total
    # Both formats can describe the same request. Prefer explicit request records.
    return direct if direct else fallback


def read_claude(path: Path) -> list[Record]:
    records = []
    for index, event in events(path):
        message = event.get("message")
        if event.get("type") != "assistant" or not isinstance(message, dict):
            continue
        model, usage = message.get("model") or "unknown", message.get("usage")
        if model.startswith("<") or not isinstance(usage, dict):
            continue
        thread = event.get("sessionId") or path.stem
        identity = ("claude", message["id"]) if message.get("id") else (
            "claude", thread, event.get("uuid") or index)
        records.append(Record(identity, event.get("timestamp"), model, "claude",
            "claude", thread, normalize_usage(usage, "claude")))
    return records


def read_agent_session(path: Path, client: str) -> list[Record]:
    """Read the shared Pi/omp format, including Pi's non-conversation usage."""
    records, thread = [], path.stem
    for index, event in events(path):
        kind = event.get("type")
        if kind == "session":
            thread = event.get("id") or thread
            continue
        if client == "pi" and kind in ("usage", "compaction", "branch_summary"):
            message = event
        elif kind == "message" and isinstance(event.get("message"), dict):
            message = event["message"]
            roles = ("assistant", "toolResult") if client == "pi" else ("assistant",)
            if message.get("role") not in roles:
                continue
        else:
            continue
        if not isinstance(message.get("usage"), dict):
            continue
        provider = message.get("provider") or "unknown"
        if message.get("responseId"):
            identity = (client, provider, message["responseId"])
        elif client == "pi" and event.get("id"):
            # Forks copy entry IDs and timestamps but get a new session header.
            identity = (client, provider, event["id"], event.get("timestamp"))
        else:
            identity = (client, thread, event.get("id") or index)
        records.append(Record(identity, event.get("timestamp"), message.get("model") or "unknown",
            client, provider, thread, normalize_usage(message["usage"], client)))
    return records


def unique_roots(roots: list[Path], subdir: str) -> list[Path]:
    """T3 shadow homes often symlink the same sessions; scan each target once."""
    seen, result = set(), []
    for root in roots:
        root = root.expanduser().absolute()
        target = (root / subdir).resolve()
        if target not in seen:
            seen.add(target)
            result.append(root)
    return result


def default_homes() -> tuple[list[Path], list[Path]]:
    home = Path.home()
    codex = [home / ".config/codex-cpa", home / ".codex"]
    if os.environ.get("CODEX_HOME"):
        codex.append(Path(os.environ["CODEX_HOME"]))
    codex.extend((home / ".t3/userdata/providers/codex").glob("*/shadow"))
    claude = [home / ".claude"]
    if os.environ.get("CLAUDE_CONFIG_DIR"):
        claude.append(Path(os.environ["CLAUDE_CONFIG_DIR"]))
    return unique_roots(codex, "sessions"), unique_roots(claude, "projects")


def default_omp_homes() -> list[Path]:
    root = Path.home() / ".omp"
    return unique_roots([root / "agent", *(root / "profiles").glob("*/agent")], "sessions")


def default_pi_homes() -> list[Path]:
    homes = [Path.home() / ".pi/agent"]
    if os.environ.get("PI_CODING_AGENT_DIR"):
        homes.append(Path(os.environ["PI_CODING_AGENT_DIR"]))
    return unique_roots(homes, "sessions")


def bucket():
    return {"usage": empty_usage(), "requests": 0, "threads": set(), "providers": set()}


def add_record(target: dict, record: Record):
    for field in USAGE_FIELDS:
        target["usage"][field] += record.usage[field]
    target["requests"] += 1
    target["threads"].add((record.client, record.thread))
    target["providers"].add(record.provider)


def summarize(target: dict) -> dict:
    return {**target["usage"], "requests": target["requests"],
        "threads": len(target["threads"]), "providers": sorted(target["providers"])}


def collect_document(codex_homes: list[Path] | None = None,
                     claude_homes: list[Path] | None = None,
                     omp_homes: list[Path] | None = None,
                     pi_homes: list[Path] | None = None) -> dict:
    default_codex, default_claude = default_homes()
    codex_homes = unique_roots(default_codex if codex_homes is None else codex_homes, "sessions")
    claude_homes = unique_roots(default_claude if claude_homes is None else claude_homes, "projects")
    omp_homes = unique_roots(default_omp_homes() if omp_homes is None else omp_homes, "sessions")
    pi_homes = unique_roots(default_pi_homes() if pi_homes is None else pi_homes, "sessions")
    records: dict[tuple, Record] = {}
    sources = []
    for client, homes, directory, pattern, reader in (
        ("codex", codex_homes, "sessions", "rollout-*.jsonl", read_codex),
        ("claude", claude_homes, "projects", "*.jsonl", read_claude),
        ("omp", omp_homes, "sessions", "*.jsonl", partial(read_agent_session, client="omp")),
        ("pi", pi_homes, "sessions", "*.jsonl", partial(read_agent_session, client="pi")),
    ):
        for home in homes:
            root = home / directory
            source = {"client": client, "path": str(root), "exists": root.is_dir(),
                "files": 0, "requests": 0, "last_usage_at": None, "error": None}
            for path in sorted(root.rglob(pattern)):
                if not path.is_file():
                    continue
                source["files"] += 1
                try:
                    found = reader(path)
                except OSError as error:
                    source["error"] = str(error)
                    continue
                for record in found:
                    try:
                        local_day(record.timestamp)
                    except (ValueError, TypeError, AttributeError):
                        continue
                    if not record.usage["total_tokens"]:
                        continue
                    previous = records.get(record.identity)
                    if previous:
                        # Several blocks can belong to one streamed Claude response.
                        # Keep the largest observed counters, never sum snapshots.
                        for field in USAGE_FIELDS:
                            previous.usage[field] = max(previous.usage[field], record.usage[field])
                    else:
                        records[record.identity] = record
                        source["requests"] += 1
                    if source["last_usage_at"] is None or record.timestamp > source["last_usage_at"]:
                        source["last_usage_at"] = record.timestamp
            sources.append(source)

    totals = defaultdict(bucket)
    clients = defaultdict(lambda: defaultdict(bucket))
    for record in records.values():
        key = (local_day(record.timestamp), record.model)
        add_record(totals[key], record)
        add_record(clients[key][record.client], record)
    rows = []
    for (day, model), target in sorted(totals.items(), reverse=True):
        summary = summarize(target)
        rows.append({"day": day, "model": model, **summary,
            "provider": ", ".join(summary["providers"]),
            "clients": sorted(clients[(day, model)]),
            "by_client": {client: summarize(value) for client, value in clients[(day, model)].items()}})
    now = dt.datetime.now(WIB)
    return {"timezone": "WIB (UTC+7)", "today": now.date().isoformat(),
        "generated_at": now.isoformat(timespec="seconds"), "rows": rows, "sources": sources,
        "homes": [str(h) for h in codex_homes], "claude_homes": [str(h) for h in claude_homes],
        "omp_homes": [str(h) for h in omp_homes], "pi_homes": [str(h) for h in pi_homes]}


def collect(home: Path) -> list[dict]:
    """Compatibility for callers collecting one Codex home."""
    return collect_document([home], [], [], [])['rows']


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("homes", nargs="*", type=Path, help="Codex homes (default: auto-discover)")
    parser.add_argument("--claude-home", action="append", type=Path, help="Claude config root; repeatable")
    parser.add_argument("--omp-home", action="append", type=Path, help="omp agent directory; repeatable")
    parser.add_argument("--pi-home", action="append", type=Path, help="Pi agent directory; repeatable")
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()
    document = collect_document(args.homes or None, args.claude_home, args.omp_home, args.pi_home)
    payload = json.dumps(document, indent=2) + "\n"
    if args.output:
        args.output.write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
