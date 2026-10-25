# Rice

Dotfiles, scripts, and Nix configuration for my machines. Clone this repository to `~/.rice`. `links.sh` symlinks the configs into `$HOME`, so editing a file under `~/.config` edits it here.

## Layout

| Path | Contents |
|------|----------|
| `files/cfg/config/` | Per-program configs, linked into `~/.config` (nvim, kitty, hypr, fish, mpv, and others). |
| `files/cfg/scripts/` | Shell and Python helpers, linked to `~/.scripts`. |
| `files/cfg/local/` | `~/.local` content: the T3 launchers, the `my-tern` wrapper and its desktop entry, and the agent usage dashboard. |
| `files/cfg/` | Dotfiles for `$HOME`: `bashrc`, `gitconfig`, `tmux.conf`, `vimrc`, and similar. |
| `emacs/` | Emacs config, linked to `~/.config/emacs`. Build output is gitignored. |
| `.agents/` | `AGENTS.md`, commands, and skills shared by Claude Code, Codex, and opencode. |
| `flake.nix`, `hosts/default/` | NixOS system config. |
| `home-manager/` | Standalone home-manager flake for machines that do not run NixOS. |
| `install-script/` | Bootstrap scripts for fresh machines (`install.sh`, `runpod.sh`) and the dashboard setup. |
| `notes/`, `learning/` | Org notes and study notes. |
| `fonts/`, `wallpaper/` | Font files and wallpapers. |
| `pass.sh`, `passlock.enc`, `priv/`, `secrets.org.gpg`, `backup.sh` | Encrypted secrets and the scripts that open them. |

## Commands

| Task | Command |
|------|---------|
| Link configs into `$HOME` | `./links.sh all`, or `./links.sh nvim codex` for specific targets |
| Rebuild NixOS | `./rebuild.sh` |
| Rebuild home-manager | `cd home-manager && ./update.sh` (add `--upgrade` to update flake inputs first) |
| Set up the usage dashboard only | `install-script/setup-agent-usage-stats.sh` |

`links.sh` deletes each destination before it links, so a file that already exists in `$HOME` is replaced. The `cliproxyapi` and `agent-usage-stats` targets also install CLIProxyAPI and build the usage dashboard. Run `./links.sh` with no arguments to list the targets. See [SETUP.md](SETUP.md) for the one-time install steps.

## T3 Code stable launcher

Install or update the latest stable release with `~/tools/t3/install-t3.sh`, then
run `./links.sh t3code` to link its system-Mesa wrapper and desktop entry.
Select **T3 Code** in Rofi or run `~/.local/bin/t3code`. Only the stable launcher
is managed; main and nightly targets have been removed. The installer preserves
the wrapper, and updates leave T3 workspace data in `~/.t3` untouched.

## Codex desktop launcher

Run `~/tools/codex/install-codex.sh` to install or update OpenAI's Linux desktop app.
The installer uses `./links.sh codex-desktop` to link its system-Mesa wrapper and
desktop entry. Select **ChatGPT (Codex)** in Rofi, or run `~/.local/bin/codex-desktop`.
The wrapper selects native Wayland in a Wayland session to use the Intel GPU;
it does not replace the existing `codex` CLI or change T3. See `~/tools/README.md`
for signature verification, update behavior, and GPU verification details.

## Tern launcher

Install Tern at `~/.local/bin/tern`, then link the wrapper and desktop entry:

```sh
./links.sh tern
```

Select **Tern (System Mesa)** in Rofi. The `my-tern` wrapper removes `LD_LIBRARY_PATH`, `LIBGL_DRIVERS_PATH`, `__EGL_VENDOR_LIBRARY_FILENAMES`, and `GBM_BACKENDS_PATH`, as the T3 wrapper does. It preserves command arguments and leaves the Tern binary unchanged.

The Hyprland shortcut **Super+Shift+Return** uses the same wrapper. Tern rewrites its own `so.stencil.tern*.desktop` files on launch, so `links.sh` uses a separate `tern.desktop` file. The original **Tern** entry still launches the binary without the wrapper.


## Account priority

When CLIProxyAPI has several Codex or Claude logins, `files/cfg/cli-proxy-api/account_reset_priority.py` steers new sessions to the account whose weekly quota resets soonest, so that quota is used before it expires. It reads the local dashboard's `/api/quota` endpoint and writes a `priority` field into the auth files in `~/.cli-proxy-api`. The dashboard owns provider reads and HTTP 429 cooldowns. The proxy reloads the auth files without a restart and compares priority only between accounts of the same provider. Accounts at their 5-hour or weekly limit drop to priority 0.

The `account-reset-priority.timer` user unit runs it every 10 minutes and requires `agent-usage-stats.service`. `links.sh` links the script to `~/cliproxyapi/` and the units to `~/.config/systemd/user/`, then enables the timer. Run the script with `--dry-run` to see the ranking without writing, or `--provider claude` to limit it to one provider. Accounts with a quota error, or quota data older than 10 minutes, keep their current priority. Check past runs with `journalctl --user -u account-reset-priority`.

## Agent usage dashboard

The dashboard shows Codex and Claude token usage at http://127.0.0.1:8770, grouped by model and by day in WIB (UTC+7). The React app is in `files/cfg/local/share/agent-usage-stats`, and its systemd unit is `files/cfg/config/systemd/user/agent-usage-stats.service`.

`setup-agent-usage-stats.sh` links the app to `~/.local/share/agent-usage-stats` and `~/tools/codex-usage-stats`, links the unit into `~/.config/systemd/user`, builds the app, and enables the service at login. Pass `--skip-build` to relink and restart without rebuilding. Dependencies, builds, and usage snapshots are gitignored. The [dashboard README](files/cfg/local/share/agent-usage-stats/README.md) covers development and token accounting.

## Wallpapers

`wallpaper/` holds a small selection. More are in [wall-archive](https://github.com/debraj-80/wall-archive).
