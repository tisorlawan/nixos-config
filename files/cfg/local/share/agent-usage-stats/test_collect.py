#!/usr/bin/env python3
"""Checks for collect.py against synthetic rollouts, no real session data.

Run: python3 test_collect.py
"""

import datetime as dt
import json
import tempfile
import unittest
from pathlib import Path

import collect

WIB = collect.WIB


def rollout(session_meta, turn_context, records):
    """Build the JSONL lines a Codex session would write."""
    lines = []
    if session_meta:
        lines.append({"timestamp": "2026-10-02T16:00:00.000Z", "type": "session_meta", "payload": session_meta})
    if turn_context:
        lines.append({"timestamp": "2026-10-02T16:00:01.000Z", "type": "turn_context", "payload": turn_context})
    for index, usage in enumerate(records):
        lines.append(
            {
                "timestamp": f"2026-10-02T16:0{index}:00.000Z",
                "type": "token_usage_record",
                "payload": {"usage": usage, "turn_token_usage": usage, "thread_token_usage": usage},
            }
        )
    return "\n".join(json.dumps(line) for line in lines) + "\n"


def write_session(home: Path, day: str, name: str, body: str) -> Path:
    directory = home / "sessions" / day
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / name
    path.write_text(body, encoding="utf-8")
    return path


class TestLocalDay(unittest.TestCase):
    def test_utc_evening_is_same_wib_day(self):
        # 16:26 UTC is 23:26 WIB, still the 2nd locally.
        self.assertEqual(collect.local_day("2026-10-02T16:26:14.923Z"), "2026-10-02")

    def test_utc_after_17h_rolls_into_next_wib_day(self):
        # 17:30 UTC is 00:30 WIB on the 3rd. This is the case a naive
        # UTC-date grouping would get wrong.
        self.assertEqual(collect.local_day("2026-10-02T17:30:00.000Z"), "2026-10-03")

    def test_utc_afternoon_before_midnight_wib(self):
        # 09:00 UTC is 16:00 WIB, same day.
        self.assertEqual(collect.local_day("2026-10-02T09:00:00.000Z"), "2026-10-02")


class TestCollect(unittest.TestCase):
    def test_sums_per_request_usage_not_cumulative(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            body = rollout(
                {"session_id": "s1", "model_provider": "cpa", "cwd": "/repo"},
                {"model": "gpt-6.1-sol"},
                [
                    {"input_tokens": 100, "cached_input_tokens": 40, "output_tokens": 5, "total_tokens": 105},
                    {"input_tokens": 200, "cached_input_tokens": 150, "output_tokens": 7, "total_tokens": 207},
                ],
            )
            write_session(home, "2026/10/02", "rollout-a.jsonl", body)

            rows = collect.collect(home)

            self.assertEqual(len(rows), 1)
            row = rows[0]
            self.assertEqual(row["input_tokens"], 300)
            self.assertEqual(row["cached_input_tokens"], 190)
            self.assertEqual(row["output_tokens"], 12)
            self.assertEqual(row["requests"], 2)
            self.assertEqual(row["model"], "gpt-6.1-sol")
            self.assertEqual(row["provider"], "cpa")
            self.assertEqual(row["day"], "2026-10-02")

    def test_threads_on_same_model_and_day_collapse_to_one_row(self):
        # Three short threads on one model is one row, not three. This is the
        # grain the stats page is for.
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            for index in range(3):
                body = rollout(
                    {"session_id": f"s{index}", "model_provider": "cpa"},
                    {"model": "gpt-6.1-sol"},
                    [{"input_tokens": 10, "cached_input_tokens": index, "output_tokens": 1}],
                )
                write_session(home, "2026/10/02", f"rollout-{index}.jsonl", body)

            rows = collect.collect(home)

            self.assertEqual(len(rows), 1, "one row per model per day")
            row = rows[0]
            self.assertEqual(row["requests"], 3)
            self.assertEqual(row["threads"], 3)
            self.assertEqual(row["input_tokens"], 30)
            self.assertEqual(row["cached_input_tokens"], 3)  # 0 + 1 + 2

    def test_different_models_on_same_day_stay_separate(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            write_session(
                home, "2026/10/02", "rollout-a.jsonl",
                rollout({"session_id": "a", "model_provider": "cpa"}, {"model": "gpt-6.1-sol"},
                        [{"input_tokens": 10, "cached_input_tokens": 1, "output_tokens": 1}]),
            )
            write_session(
                home, "2026/10/02", "rollout-b.jsonl",
                rollout({"session_id": "b", "model_provider": "cpa"}, {"model": "gpt-6-astra"},
                        [{"input_tokens": 20, "cached_input_tokens": 2, "output_tokens": 2}]),
            )

            rows = collect.collect(home)

            self.assertEqual(len(rows), 2)
            self.assertEqual({r["model"] for r in rows}, {"gpt-6.1-sol", "gpt-6-astra"})

    def test_same_model_across_two_homes_merges(self):
        with tempfile.TemporaryDirectory() as tmp:
            home_a, home_b = Path(tmp) / "a", Path(tmp) / "b"
            for home, cached in ((home_a, 5), (home_b, 9)):
                write_session(
                    home, "2026/10/02", f"rollout-{home.name}.jsonl",
                    rollout({"session_id": home.name, "model_provider": "cpa"}, {"model": "gpt-6.1-sol"},
                            [{"input_tokens": 10, "cached_input_tokens": cached, "output_tokens": 1}]),
                )

            rows = collect.collect_document([home_a, home_b], [], [])['rows']

            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]['cached_input_tokens'], 14)
            self.assertEqual(rows[0]['requests'], 2)
            self.assertEqual(rows[0]['threads'], 2)

    def test_turn_spanning_midnight_wib_splits_into_two_days(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            # 16:30 UTC = 23:30 WIB on the 2nd; 17:10 UTC = 00:10 WIB on the 3rd.
            lines = [
                {"timestamp": "2026-10-02T16:30:00.000Z", "type": "session_meta", "payload": {"session_id": "s2", "model_provider": "cpa"}},
                {"timestamp": "2026-10-02T16:30:01.000Z", "type": "turn_context", "payload": {"model": "gpt-6.1-sol"}},
                {"timestamp": "2026-10-02T16:30:02.000Z", "type": "token_usage_record", "payload": {"usage": {"input_tokens": 10, "cached_input_tokens": 1, "output_tokens": 1}}},
                {"timestamp": "2026-10-02T17:10:00.000Z", "type": "token_usage_record", "payload": {"usage": {"input_tokens": 20, "cached_input_tokens": 2, "output_tokens": 2}}},
            ]
            write_session(home, "2026/10/02", "rollout-b.jsonl", "\n".join(json.dumps(x) for x in lines) + "\n")

            rows = collect.collect(home)

            self.assertEqual(len(rows), 2, "one row per local day touched")
            by_day = {row["day"]: row for row in rows}
            self.assertEqual(by_day["2026-10-02"]["input_tokens"], 10)
            self.assertEqual(by_day["2026-10-03"]["input_tokens"], 20)
            # One thread, counted on both days.
            self.assertEqual(by_day["2026-10-02"]["threads"], 1)

    def test_truncated_final_line_is_skipped(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            good = rollout(
                {"session_id": "s3", "model_provider": "cpa"},
                {"model": "gpt-6.1-sol"},
                [{"input_tokens": 5, "cached_input_tokens": 0, "output_tokens": 1}],
            )
            write_session(home, "2026/10/02", "rollout-c.jsonl", good + '{"timestamp":"2026-10-02T16:00:09.000Z","type":"token_usage_rec')

            rows = collect.collect(home)

            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]["input_tokens"], 5)

    def test_missing_model_falls_back_to_unknown(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            body = rollout(
                {"session_id": "s4", "model_provider": "cpa"},
                None,
                [{"input_tokens": 7, "cached_input_tokens": 0, "output_tokens": 1}],
            )
            write_session(home, "2026/10/02", "rollout-d.jsonl", body)

            rows = collect.collect(home)

            self.assertEqual(rows[0]["model"], "unknown")

    def test_home_without_sessions_is_not_an_error(self):
        with tempfile.TemporaryDirectory() as tmp:
            self.assertEqual(collect.collect(Path(tmp)), [])

    def test_missing_usage_fields_default_to_zero(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            body = rollout(
                {"session_id": "s5", "model_provider": "cpa"},
                {"model": "gpt-6.1-sol"},
                [{"input_tokens": 9}],
            )
            write_session(home, "2026/10/02", "rollout-e.jsonl", body)

            row = collect.collect(home)[0]

            self.assertEqual(row["input_tokens"], 9)
            self.assertEqual(row["cached_input_tokens"], 0)
            self.assertEqual(row["cache_write_input_tokens"], 0)
            self.assertEqual(row["reasoning_output_tokens"], 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
