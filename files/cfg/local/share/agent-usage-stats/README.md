# Agent usage dashboard

React + Vite frontend, with a Python standard-library server serving the built
SPA and the live `/api/usage` endpoint on http://127.0.0.1:8770.

The dashboard reads Codex and Claude session logs. It groups requests by model
and calendar day in **WIB (Asia/Jakarta, UTC+7)**. Refresh reads the current logs;
the frontend also refreshes every 15 seconds while visible.

## Run

```sh
npm ci
npm run build
python3 serve.py
```

Default sources are `~/.config/codex-cpa`, `~/.codex`, T3's Codex shadow homes,
and `~/.claude`. The server also respects `CODEX_HOME` and `CLAUDE_CONFIG_DIR`.
Symlinked session folders are scanned once. To use explicit homes:

```sh
python3 serve.py /path/to/codex-home --claude-home /path/to/claude-home
```

Codex homes contain `sessions/`; Claude homes contain `projects/`.
This reads all local usage in those homes, including CLI sessions outside T3
and Claude subagents. Token counts need no proxy key or management API.

## Plan limits

`/api/quota` reports percent used for the 5-hour and weekly limits of each Claude and Codex account (the page shows percent remaining)
stored by CLIProxyAPI (`~/.cli-proxy-api/*.json`, or `CLI_PROXY_AUTH_DIR`). It calls
Anthropic's `/api/oauth/usage` and ChatGPT's `/backend-api/wham/usage` with each
account's stored access token. Both endpoints are undocumented and may change.

Codex accounts also show their banked reset credits. "Use reset" asks for
confirmation, then `POST /api/quota/reset` spends the earliest-expiring credit through
ChatGPT's `/wham/rate-limit-reset-credits/consume`. This cannot be undone. The server
refuses requests that are not same-origin JSON with `confirm: true`, and every failure
(expired sign-in, no credit, nothing to reset, rate limit, unreachable provider) is shown
on the account row. Claude has no reset; its limits clear when the window ends.

Tokens are only read, never refreshed, because the proxy owns refresh-token
rotation. An expired token shows "Sign-in expired" for that account until a request
goes through the proxy. Results are cached for 60 seconds. The browser never sees a
token.

## User service

The source lives in `~/.rice/files/cfg/local/share/agent-usage-stats`. The setup
script links it to `~/.local/share/agent-usage-stats` and keeps
`~/tools/codex-usage-stats` as a compatibility link. The service unit is managed
in `~/.rice/files/cfg/config/systemd/user/agent-usage-stats.service`.

```sh
bash ~/.rice/install-script/setup-agent-usage-stats.sh
```

```sh
systemctl --user status agent-usage-stats.service
systemctl --user restart agent-usage-stats.service
journalctl --user -u agent-usage-stats.service -n 50
```

After frontend changes, run `npm run build` and refresh the page. After Python
changes, restart the service. The service uses the production build; it does not
run Vite's development server. `/stats.html` redirects to the live dashboard.

`~/.rice/links.sh` also calls the setup script. Use `--skip-build` with the setup
script to relink and restart without reinstalling dependencies or rebuilding.

## Token accounting

- Codex uses `token_usage_record.usage`. Older logs without those records use
  `event_msg.token_count.info.last_token_usage`, ignoring repeated totals.
- Model changes are attributed at the request's position in the log.
- Codex response IDs and Claude message IDs deduplicate copied transcripts and
  repeated streaming blocks. Turn and thread cumulative totals are not summed.
- Claude `input_tokens` describes fresh input only. Total input is fresh input
  plus `cache_read_input_tokens` plus `cache_creation_input_tokens`.
- Cache share is cache reads divided by total input. Cache writes are reported
  separately; they are not cache hits. Output includes reported reasoning.
- Synthetic Claude messages, zero-token events, malformed timestamps and partial
  JSONL writes are skipped. Session logs remain the source of history.

## Develop and verify

Run the Python server, then `npm run dev` for Vite's frontend on port 5173.
Vite proxies `/api` to port 8770.

```sh
python3 -m unittest -v test_collect.py test_usage.py
npm test
npm run build
```

Fonts are bundled locally so the dashboard works without a network connection.
