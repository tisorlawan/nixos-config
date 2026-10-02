# Quickshell Bar Config

Minimal status bar for Hyprland using [Quickshell](https://quickshell.outfoxxed.me/) 0.2.1.

## Files

| File | Purpose |
|------|---------|
| `shell.qml` | Entry point. Must have `//@ pragma UseQApplication` for system tray support. |
| `Bar.qml` | Bar layout: workspaces, media, stats, systray, clock. |
| `Clock.qml` | Standalone top-right clock window with its own visibility toggle. |
| `BarData.qml` | Singleton providing all data: stats polling, media (Mpris), battery (UPower), clock. |
| `Chip.qml` | Reusable pill/chip component. |
| `Theme.qml` | Singleton with colors and dimensions. |

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
