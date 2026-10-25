# Quickshell Bar Config

Minimal status bar for Hyprland with [Quickshell](https://quickshell.outfoxxed.me/) 0.3.0.

## Files

| File | Purpose |
|------|---------|
| `shell.qml` | Entry point. Must have `//@ pragma UseQApplication` for system tray support. |
| `Bar.qml` | Bar layout: workspaces, media, stats, systray, clock. |
| `Clock.qml` | Standalone top-right clock window with its own visibility toggle. |
| `QuotaWidget.qml` | Bar button and panel for provider quotas, accounts, and reset times. |
| `QuotaData.qml` | Shared quota data from the local dashboard API. |
| `Quota.js` | Quota response parser and reset countdowns. |
| `ResetData.qml` | Reset credit list, selection, and request state. |
| `ResetCredits.qml` | Credit entries and reset confirmation. |
| `QuotaButton.qml` | Button for quota and reset controls. |
| `BarData.qml` | Singleton providing all data: stats polling, media (Mpris), battery (UPower), clock. |
| `Chip.qml` | Reusable pill/chip component. |
| `Theme.qml` | Singleton with colors and dimensions. |

## Account quotas

Select **AI** in the bar to open the CLIProxy quota panel. The number shows the account count.
The panel groups accounts by provider. Each quota row shows the limit, remaining percent, and reset countdown.
Each account also shows its reset credit count when available.

The `P20` label shows the priority value from that account's auth JSON. Higher values come first within each provider.
The `account-reset-priority.timer` runs the priority script about every 10 minutes. The dashboard only reads the stored value.

Point to a reset count to see the available credit entries and their expiry dates.
Select **Use** beside an entry, then select **Use reset** to confirm that credit.

The widget posts that account ID and credit ID to `/api/quota/reset`. This action consumes one reset and cannot be undone.
The provider decides which limits the credit resets. A reset credit does not select a specific quota row.

If the result is uncertain, check the account before another attempt. The widget never retries a reset automatically.

Select **↻** to refresh the data. Select **×**, press Escape, or click outside the panel to close it.

The widget reads `http://127.0.0.1:8770/api/quota` from the local
[agent usage dashboard](../../local/share/agent-usage-stats/README.md).
The dashboard reads the accounts that CLIProxy stores. It supports Claude and Codex quotas.
Quickshell needs no provider token or management key. Hover only reads the reset list.
Only the **Use reset** confirmation sends a reset request.

The widget refreshes every 60 seconds. The dashboard reads each account's provider quota at most once every five minutes.
The priority script and Claude credit lists share those reads.
After HTTP 429, the dashboard pauses reads for that provider. It respects `Retry-After` and increases the cooldown after repeated failures.

The panel keeps the last known quota and shows the next check time. This cannot guarantee that a provider never returns HTTP 429.

If a request fails, the panel keeps the last successful data and shows an error.
An exclamation mark in the bar indicates an account error, a request error, or data older than three minutes.
The provider endpoints are undocumented and can change. Other CLIProxy providers do not appear in this API.

If the API is unavailable, check the dashboard service:

```sh
systemctl --user status agent-usage-stats.service
```

Run the quota parser checks with Node.js:

```sh
node --test files/cfg/config/quickshell/tests/quota.test.cjs
```

## External dependency

The bar calls three scripts from `~/.scripts`. Their sources are in `files/cfg/scripts/`.

- `quickshell-bar-stats` prints one JSON line per second with CPU, memory, backlight, audio, and network data.
- `quickshell-clock-toggle` shows or hides the standalone top-right clock by writing a state file under `~/.local/state/quickshell-clock-toggle`.
- `quickshell-ghostty-status` prints the focused Ghostty window's working directory and terminal-surface count as JSON.

## Gotchas

### nixGLIntel required (non-NixOS)
On non-NixOS with home-manager, quickshell needs `nixGLIntel` wrapping in the systemd service `ExecStart` or it fails with `EGL not available` / `Failed to create graphics context`.

### SplitParser signal syntax
```qml
// Wrong: declares a JS function and does not connect to the read signal
stdout: SplitParser {
  function onRead(data) { ... }
}

// Right: connects to the read(data) signal
stdout: SplitParser {
  onRead: data => { ... }
}
```

### System tray menus
`//@ pragma UseQApplication` must be the first line in `shell.qml` or tray icon context menus fail with `Cannot display PlatformMenuEntry`.
