import test from 'node:test';
import assert from 'node:assert/strict';
import { byDay, selectRows, sumUsage, cacheRate, untilReset, untilExpiry } from './usage.js';

const rows = [{ day: '2026-10-03', model: 'shared', input_tokens: 150,
  cached_input_tokens: 100, requests: 3, clients: ['codex', 'claude'],
  by_client: { codex: { input_tokens: 100, cached_input_tokens: 90, requests: 2 },
    claude: { input_tokens: 50, cached_input_tokens: 10, requests: 1 } } },
{ day: '2026-10-02', model: 'other', input_tokens: 30, cached_input_tokens: 5,
  requests: 1, clients: ['codex'], by_client: { codex: { input_tokens: 30, cached_input_tokens: 5, requests: 1 } } }];

test('agent filter uses that agents counters on a shared model', () => {
  const selected = selectRows(rows, { client: 'claude' });
  assert.equal(selected.length, 1);
  assert.equal(sumUsage(selected).cached_input_tokens, 10);
  assert.equal(sumUsage(selected).requests, 1);
  assert.deepEqual(selected[0].clients, ['claude']);
  assert.equal(rows[0].cached_input_tokens, 100);
});

test('date and model filters combine inclusively', () => {
  assert.equal(selectRows(rows, { from: '2026-10-03', to: '2026-10-03', model: 'shared' }).length, 1);
  assert.equal(selectRows(rows, { from: '2026-10-03', model: 'other' }).length, 0);
});

test('daily cache rate is weighted by tokens and newest dates come first', () => {
  const days = byDay([...rows, { ...rows[0], model: 'third', input_tokens: 50, cached_input_tokens: 0, requests: 1 }]);
  assert.equal(days[0].day, '2026-10-03');
  assert.equal(days[0].requests, 4);
  assert.equal(cacheRate(days[0].cached_input_tokens, days[0].input_tokens), '50.0%');
  assert.equal(cacheRate(0, 0), '—');
});

test('reset countdown uses the largest two units and handles idle or past windows', () => {
  const now = Date.parse('2026-10-03T00:00:00Z');
  assert.equal(untilReset('2026-10-03T00:45:00Z', now), 'resets in 45m');
  assert.equal(untilReset('2026-10-03T03:10:00Z', now), 'resets in 3h 10m');
  assert.equal(untilReset('2026-10-05T04:00:00Z', now), 'resets in 2d 4h');
  assert.equal(untilReset('2026-10-02T23:00:00Z', now), 'resetting');
  assert.equal(untilReset(null, now), 'no active window');
});

test('credit expiry reads as a countdown, with no expiry and past dates called out', () => {
  const now = Date.parse('2026-10-03T00:00:00Z');
  assert.equal(untilExpiry('2026-10-22T12:00:00Z', now), 'in 19d 12h');
  assert.equal(untilExpiry(null, now), 'no expiry');
  assert.equal(untilExpiry('2026-10-02T00:00:00Z', now), 'expired');
});
