# Quickshell Bar Config

Minimal status bar for Hyprland using [Quickshell](https://quickshell.outfoxxed.me/) 0.2.1.

## Files

| File | Purpose |
|------|---------|
| `shell.qml` | Entry point. Must have `//@ pragma UseQApplication` for system tray support. |
| `Bar.qml` | Bar layout — workspaces, media, stats, systray, clock. |
| `Clock.qml` | Standalone top-right clock window with its own visibility toggle. |
| `BarData.qml` | Singleton providing all data: stats polling, media (Mpris), battery (UPower), clock. |
| `Chip.qml` | Reusable pill/chip component. |
| `Theme.qml` | Singleton with colors and dimensions. |

## External dependency

`~/.scripts/quickshell-bar-stats` — bash script that outputs one JSON line per second with cpu, memory, backlight, audio, and network info. Source: `../../scripts/quickshell-bar-stats`.

`~/.scripts/quickshell-clock-toggle` — toggles the standalone top-right clock by writing a state file under `~/.local/state/quickshell-clock-toggle`.

## Gotchas

### nixGLIntel required (non-NixOS)
On non-NixOS with home-manager, quickshell needs `nixGLIntel` wrapping in the systemd service `ExecStart` or it fails with `EGL not available` / `Failed to create graphics context`.

### SplitParser signal syntax
```qml
// WRONG — declares a JS function, does NOT connect to the read signal
stdout: SplitParser {
  function onRead(data) { ... }
}

// CORRECT — connects to the read(data) signal
stdout: SplitParser {
  onRead: data => { ... }
}
```

### System tray menus
`//@ pragma UseQApplication` must be the first line in `shell.qml` or tray icon context menus fail with `Cannot display PlatformMenuEntry`.
