const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const { test } = require('node:test');

const quota = vm.createContext({});
vm.runInContext(readFileSync(join(__dirname, '../Quota.js'), 'utf8'), quota);
const generated = '2026-10-29T12:00:00.438616+00:00';
const now = Date.parse(generated);
const account = (provider, windows = [], extra = {}) => ({
  id: provider + '-account', provider, name: provider + '@example.com', windows, error: '', ...extra
});
const parse = accounts => quota.parseDocument(JSON.stringify({ generated_at: generated, accounts }));

test('group accounts by provider without merging accounts that share an email', () => {
  const result = parse([
    account('codex', [], { name: 'same@example.com', plan: 'plus' }),
    account('claude', [], { name: 'same@example.com' }),
    account('codex', [], { name: 'second@example.com' })
  ]);
  assert.equal(result.generatedAt, now);
  assert.equal(result.groups[0].name, 'Claude');
  assert.equal(result.groups[1].name, 'Codex');
  assert.equal(result.groups[1].accounts.length, 2);
  assert.equal(result.groups[1].accounts[0].name, 'same@example.com');
});

test('keep the exact account id and stored priority, including zero and negative values', () => {
  const accounts = parse([20, 0, -10, null, '20', true].map((priority, index) =>
    account('codex', [], { id: 'account-' + index, priority }))).groups[0].accounts;
  assert.equal(accounts[0].id, 'account-0');
  assert.deepEqual(Array.from(accounts, item => item.priority), [20, 0, -10, null, null, null]);
});

test('convert used quota to remaining quota and preserve zero and unknown', () => {
  const values = [0, 100, 26.5, 130, -5, null, '20'];
  const windows = parse([account('codex', values.map(percent => ({ label: 'Weekly', percent })))])
    .groups[0].accounts[0].windows;
  assert.deepEqual(Array.from(windows, item => item.remaining), [100, 0, 73.5, 0, 100, null, null]);
});

test('parse provider reset timestamps, including microseconds, and keep absent dates unknown', () => {
  const windows = parse([account('claude', [
    { label: 'Weekly', percent: 26, resets_at: generated },
    { label: '5 hours', percent: 0, resets_at: null },
    { label: 'Other', resets_at: 'invalid' }
  ])]).groups[0].accounts[0].windows;
  assert.deepEqual(Array.from(windows, item => item.resetAt), [now, null, null]);
});

test('keep account errors and distinguish zero credits from unknown credits', () => {
  const accounts = parse([
    account('codex', [], { error: 'Sign-in expired.', resets: { available: 0 } }),
    account('codex', [], { resets: { available: 2 } }),
    account('codex'),
    account('codex', [], { resets: { available: -1 } })
  ]).groups[0].accounts;
  assert.equal(accounts[0].error, 'Sign-in expired.');
  assert.deepEqual(Array.from(accounts, item => item.resetCredits), [0, 2, null, null]);
});

test('reject invalid responses so the caller can retain the last successful snapshot', () => {
  for (const payload of ['null', '{}', '{', JSON.stringify({ accounts: [], generated_at: 'invalid' })]) {
    assert.throws(() => quota.parseDocument(payload));
  }
  assert.throws(() => parse([null]));
  assert.throws(() => parse([account('', [])]));
  assert.throws(() => parse([account('codex', [null])]));
  assert.equal(parse([]).groups.length, 0);
});

test('show reset countdowns without assuming that elapsed quota is available again', () => {
  assert.equal(quota.resetText(null, now), '—');
  assert.equal(quota.resetText(now, now), 'Due');
  assert.equal(quota.resetText(now - 60000, now), 'Due');
  assert.equal(quota.resetText(now + 1000, now), '1m');
  assert.equal(quota.resetText(now + 61 * 60000, now), '1h 1m');
  assert.equal(quota.resetText(now + (2 * 1440 + 3 * 60) * 60000, now), '2d 3h');
});
