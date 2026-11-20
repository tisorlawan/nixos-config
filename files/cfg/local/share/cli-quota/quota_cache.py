"""One owner for provider usage reads, cached data, and HTTP 429 cooldowns."""
from __future__ import annotations

import datetime as dt
import logging
import threading
import time
import urllib.error
from dataclasses import dataclass
from email.utils import parsedate_to_datetime

POLL_SECONDS = 300
MAX_BACKOFF_SECONDS = 3600
logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class UsageSnapshot:
    payload: dict | None
    updated_at: float | None
    retry_at: float
    failed: bool = False
    status: int | None = None


def retry_after(value: str | None, now: float) -> float:
    """Accept both Retry-After formats. An absent or invalid value adds no delay."""
    if not value:
        return now
    try:
        return now + max(0, int(value))
    except ValueError:
        try:
            parsed = parsedate_to_datetime(value)
            return parsed.timestamp() if parsed.tzinfo else now
        except (TypeError, ValueError, OverflowError):
            return now


class UsageCache:
    def __init__(self, clock=time.time):
        self.clock = clock
        self.entries: dict[tuple[str, str], UsageSnapshot] = {}
        self.cooldowns: dict[str, float] = {}
        self.strikes: dict[str, int] = {}
        self.lock = threading.Lock()

    def read(self, provider: str, account_id: str, fetch) -> UsageSnapshot:
        # The lock also covers the request, so concurrent readers share one result.
        with self.lock:
            now = self.clock()
            key = (provider, account_id)
            previous = self.entries.get(key)
            if previous is not None and now < previous.retry_at:
                return previous
            payload = previous.payload if previous else None
            updated_at = previous.updated_at if previous else None
            cooldown = self.cooldowns.get(provider, 0)
            if now < cooldown:
                snapshot = UsageSnapshot(payload, updated_at, cooldown, True, 429)
            else:
                try:
                    fresh = fetch()
                    if not isinstance(fresh, dict):
                        raise ValueError("Invalid usage response.")
                except urllib.error.HTTPError as failure:
                    now = self.clock()
                    retry_at = now + POLL_SECONDS
                    if failure.code == 429:
                        strikes = self.strikes.get(provider, 0) + 1
                        self.strikes[provider] = strikes
                        backoff = min(MAX_BACKOFF_SECONDS, POLL_SECONDS * 2 ** min(strikes - 1, 4))
                        retry_at = max(now + backoff, retry_after(failure.headers.get("Retry-After")
                            if failure.headers else None, now))
                        # The provider can apply the limit to the shared IP, so pause its other accounts too.
                        self.cooldowns[provider] = retry_at
                        logger.warning("Quota HTTP 429: provider=%s account=%s retry_at=%s", provider,
                            account_id, dt.datetime.fromtimestamp(retry_at, dt.timezone.utc).isoformat())
                    snapshot = UsageSnapshot(payload, updated_at, retry_at, True, failure.code)
                except (OSError, ValueError):
                    snapshot = UsageSnapshot(payload, updated_at, self.clock() + POLL_SECONDS, True)
                else:
                    now = self.clock()
                    self.strikes.pop(provider, None)
                    self.cooldowns.pop(provider, None)
                    snapshot = UsageSnapshot(fresh, now, now + POLL_SECONDS)
            self.entries[key] = snapshot
            return snapshot

    def invalidate(self, account_id: str | None) -> None:
        with self.lock:
            if account_id is None:
                self.entries.clear()
            else:
                self.entries = {key: value for key, value in self.entries.items() if key[1] != account_id}
            # A successful reset does not cancel a usage endpoint's cooldown.
