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
| `ThemePicker.qml` | Bar button and panel to select the theme. |
| `Theme.qml` | Singleton with the active colors and the dimensions. |
| `Themes.js` | Theme catalog for the bar and the apps that `set-theme` updates. Each theme has a dark palette and a light palette. |

## Themes

Each theme has a dark palette and a light palette. The mode in `~/.color` selects the palette.
`~/.scripts/set-color` and `color-toggle` change the mode.

The themes are Catppuccin, Kanagawa, Gruvbox, Tokyo Night, Rosé Pine, Everforest, and Solarized.
Catppuccin is the default.

The focused workspace gets a faint accent tint, 25% `activeText` mixed into the panel color, with its number in bold text color.
The bar darkens its text in light mode, or lightens it in dark mode, until the text reaches a 7:1 contrast ratio on every chip fill, that tint, and the panel.
It adjusts the accent text the same way, to 4.5:1 on `chipBlue` and the panel. A color that already reaches the ratio stays as it is.
An urgent workspace gets a tint of 30% `urgent` mixed into the panel color, with its number in bold `urgent`.
The bar adjusts `urgent` to 4.5:1 on that tint, every chip fill, and the panel, so alerts such as a muted microphone stay readable.
`Themes.barColors` makes these adjustments for the bar only. Other apps get the palette's own colors.
Check the ratios with `node --test files/cfg/config/quickshell/tests/themes.test.cjs`.

Select the brush icon in the bar to open the theme panel. Then select a theme.
Each row shows a preview of the dark palette and of the light palette.

The panel runs `~/.scripts/set-theme <id>`. You can also run it from a shell.
The script writes the theme ID to `${XDG_STATE_HOME:-~/.local/state}/theme/current` and applies the theme to these apps:

| App | How it follows the theme |
|-----|--------------------------|
| Quickshell | The bar reads the state file and `~/.color` four times each second. |
| Neovim | `init.lua` watches the state file and loads the theme's colorscheme plugin. |
| omp | The script sets `theme.dark` and `theme.light` with `omp config set`. Running sessions reload `~/.omp/agent/config.yml`. |
| T3 Code | The script runs `t3 theme set`, which publishes the theme file and switches the connected clients. |
| Tern | With **Follow omp** selected in Tern's appearance settings, Tern uses omp's theme choice. |
| Rofi | `~/.scripts/theme-colors` writes `config/rofi/colors.rasi`. `set-color` also runs it after a mode change. The next launch reads it. |
| Mako | `~/.scripts/theme-colors` writes `config/mako/config` as the theme colors followed by `config/mako/base`, then runs `makoctl reload`. Edit `base` for other mako settings. |
| Brave | `~/.scripts/theme-colors` writes a managed policy with the palette's `browserSeed`, or `panelBg` without one, as the seed color, then a running Brave reloads its policies. Brave derives its own palette from the seed. |
| Hyprland | `theme-colors` writes the window border colors to `config/hypr/theme.conf`, which `hyprland.conf` sources, then runs `hyprctl reload`. |
| kitty | `theme-colors` writes `config/kitty/themes/rice.conf`, which `kitty.conf` includes, then sends SIGUSR1 so every running kitty reloads. Its tabs are monochrome: the active tab is `panelBg` on `text`, and inactive tabs are `text` on `chipLight`. |
| btop | `theme-colors` writes `~/.config/btop/themes/rice.theme`, which `btop.conf` selects. btop reads it when it starts. |
| Claude Code | `theme-colors` writes `~/.claude/themes/rice.json`. Claude Code reloads it in running sessions. `~/.claude/settings.json` selects it with `"theme": "custom:rice"`. |
| Qt | `theme-colors` writes the qt6ct palette to `config/qt6ct/colors.conf`, which `config/qt6ct/qt6ct.conf` selects. qt6ct reloads running Qt 6 apps from Nix, such as CopyQ and Quickshell's tray menus, about 3 seconds later. `hyprland.conf` and `environment.d` set `QT_QPA_PLATFORMTHEME=qt6ct`. |
| GTK | `theme-colors` writes two GTK themes, `~/.local/share/themes/rice-<theme>` (light, with a dark variant) and `rice-<theme>-dark`. Each is adw-gtk3 with the palette as libadwaita's color names. gsettings selects one by mode, and running GTK 3 apps reload it. libadwaita apps ignore the GTK theme and read `config/gtk-4.0/gtk.css`, which holds both modes: they follow a mode change at once and a theme change after a restart. |
| Wallpaper | `theme-colors` points the link `wallpaper/current` at `wallpaper/<theme>-<mode>`, or at `wallpaper/<mode>` when the theme has none for the mode, then restarts hyprpaper. |

The Hyprland, kitty, btop, and Claude Code files come from Omarchy's templates in `files/cfg/themes/templates/`.
Only Everforest dark has its own wallpaper, Omarchy's `everforest-dark/1-tree-tops.webp`. Every other theme and mode uses `wallpaper/dark` or `wallpaper/light`.
To give a theme wallpapers for a mode, add a `wallpaper/<theme>-<mode>/` folder with images.

### Brave

Brave takes one seed color, not a palette, through the Chromium policy `BrowserThemeColor`.
The policy applies to every profile and replaces each profile's own color. Brave shows "Managed by your organization".

The policy file is root-owned, so the theme needs a one-time setup:

```sh
sudo ~/.scripts/install-brave-theme-policy
```

The setup installs a root-owned copy of `scripts/brave-theme-policy` as `/usr/local/sbin/rice-brave-theme-policy` and adds `/etc/sudoers.d/rice-brave-theme`.
The sudoers rule lets your user run that helper without a password, with one argument of six lowercase hex digits.
The helper writes only `/etc/brave/policies/managed/color.json`.
Run the setup again after you change `brave-theme-policy`. Until the setup runs, `theme-colors` skips Brave.

Each app keeps a dark and a light version of the theme, so `set-color` changes the mode without a call to `set-theme`.
An ID that is missing or unknown selects Catppuccin in the bar and in Neovim. `set-theme` rejects an unknown ID.

`files/cfg/themes/generate.cjs` builds the T3 Code theme files, the Rofi and Mako palettes, the Brave seed colors, the GTK colors, the qt6ct palettes, and the Hyprland, kitty, btop, and Claude Code files from the palettes in `Themes.js`.
It also builds omp themes for Kanagawa and Everforest, which omp does not include.
`set-theme` copies those omp themes to `~/.omp/agent/themes/rice-*.json`.

To add a theme:

1. Add an entry to `Themes.js`. Give the entry the ten color roles in the header comment for each palette.
2. Add the omp built-in names to `omp_themes` in `set-theme`, or add a palette to `ompPalettes` in the generator.
3. Run `node files/cfg/themes/generate.cjs` and commit the generated files.
4. Add the colorscheme plugin to `vim.pack.add` and an entry to `themes` in `nvim/init.lua`.

Check Neovim with `sh tests/colors.sh` from `nvim/`. It loads every catalog theme in both modes.

`set-theme` changes two files outside this repository: `~/.omp/agent/config.yml` and T3 Code's `settings.json` and `themes/`.
To return omp and T3 Code to their stock themes, run:

```sh
omp config reset theme.dark && omp config reset theme.light
rm -f ~/.omp/agent/themes/rice-*.json
t3 theme clear
rm -f ~/.t3/userdata/themes/{catppuccin,everforest,gruvbox,kanagawa,rosepine,solarized,tokyonight}.json
```

After `t3 theme clear`, open clients keep their current theme. Select a theme in T3 Code's appearance settings to change it.

To return Claude Code to its stock dark theme, run:

```sh
jq '.theme = "dark"' ~/.claude/settings.json > /tmp/claude-settings.json && mv /tmp/claude-settings.json ~/.claude/settings.json
rm -f ~/.claude/themes/rice.json
```

To return GTK and Qt apps to their stock look, run the commands below. Then remove the `QT_*` lines from `hyprland.conf` and `home.nix`, and log in again.

```sh
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
rm -rf ~/.local/share/themes/rice-* ~/.config/gtk-4.0/gtk.css ~/.config/qt6ct/colors.conf
```

To remove the Brave setup and return each profile to its own color, run:

```sh
sudo rm -f /usr/local/sbin/rice-brave-theme-policy /etc/sudoers.d/rice-brave-theme /etc/brave/policies/managed/color.json
brave-browser --refresh-platform-policy --no-startup-window
```

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
