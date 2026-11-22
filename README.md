# Rice

Dotfiles, scripts, and Nix configuration for my machines. Clone this repository to `~/.rice`. `links.sh` symlinks the configs into `$HOME`, so editing a file under `~/.config` edits it here.

## Layout

| Path | Contents |
|------|----------|
| `files/cfg/config/` | Per-program configs, linked into `~/.config` (nvim, kitty, hypr, fish, mpv, and others). |
| `files/cfg/scripts/` | Shell and Python helpers, linked to `~/.scripts`. |
| `files/cfg/local/` | `~/.local` content: desktop launchers, desktop entries, and the local quota service. |
| `files/cfg/` | Dotfiles for `$HOME`: `bashrc`, `gitconfig`, `tmux.conf`, `vimrc`, and similar. |
| `emacs/` | Emacs config, linked to `~/.config/emacs`. Build output is gitignored. |
| `.agents/` | `AGENTS.md`, commands, and skills shared by Claude Code, Codex, and opencode. |
| `flake.nix`, `hosts/default/` | NixOS system config. |
| `home-manager/` | Standalone home-manager flake for machines that do not run NixOS. |
| `install-script/` | Bootstrap scripts for fresh machines (`install.sh`, `runpod.sh`). |
| `notes/`, `learning/` | Org notes and study notes. |
| `fonts/`, `wallpaper/` | Font files and wallpapers. |
| `pass.sh`, `passlock.enc`, `priv/`, `secrets.org.gpg`, `backup.sh` | Encrypted secrets and the scripts that open them. |

## Commands

| Task | Command |
|------|---------|
| Link configs into `$HOME` | `./links.sh all`, or `./links.sh nvim codex` for specific targets |
| Rebuild NixOS | `./rebuild.sh` |
| Rebuild home-manager | `cd home-manager && ./update.sh` (add `--upgrade` to update flake inputs first) |
| Set up the quota service and account-priority timer | `./links.sh cli-quota account-reset-priority` |

`links.sh` deletes each destination before it links, so a file that already exists in `$HOME` is replaced. The `cliproxyapi` target also runs `~/tools/cliproxyapi/install-cliproxyapi.sh`, which installs or upgrades CLIProxyAPI and restarts it. Run `./links.sh` with no arguments to list the targets. See [SETUP.md](SETUP.md) for the one-time install steps.

Home Manager installs Neovide from its `nixpkgs-unstable` pin and wraps it with nixGL. Run `neovide` to open a window with the `nvim` already on your `PATH`.

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

Install Tern at `~/.local/bin/tern`, then link `~/.scripts`, the desktop entry, and `~/.config/tern`:

```sh
./links.sh tern
```

Select **Tern (System Mesa)** in Rofi or run `~/.scripts/my-tern`. The wrapper removes `LD_LIBRARY_PATH`, `LIBGL_DRIVERS_PATH`, `__EGL_VENDOR_LIBRARY_FILENAMES`, and `GBM_BACKENDS_PATH`, as the T3 wrapper does. It sets `WGPU_BACKEND=vulkan` because the OpenGL backend creates opaque surfaces on this Intel Wayland system. Vulkan permits transparency at the configured opacity. The wrapper preserves command arguments and leaves the Tern binary unchanged.

The Hyprland shortcut **Super+Shift+Return** uses the same wrapper. Tern rewrites its own `so.stencil.tern*.desktop` files on launch, so `links.sh` uses a separate `tern.desktop` file. The original **Tern** entry still launches the binary without the wrapper.

`links.sh tern` links the whole `~/.config/tern` directory to `files/cfg/config/tern/`. Tern saves `settings.json` by replacing the file, so a symlink to that file alone would be lost on the first save. Tern's own state files, `files.json` and `account.lock`, are gitignored. The `copy-cwd` plugin makes **Ctrl+Shift+C** copy the focused pane's absolute working directory when nothing is selected, and shows a toast. With a selection, the key copies the selection as before.

The `zen` plugin toggles zen mode with **Alt+B** or **Toggle zen mode** in the command palette. Zen mode hides the tab bar and shrinks the outer padding to 4 px at the window edge and between split panes. The terminal's own padding (`padding_x`, `padding_y`) stays as set. Each window toggles its own zen mode. The plugin keeps the last choice in Tern's plugin data, outside the repository, and windows start with it after a restart.

The `quiet-grip` plugin hides each pane's **Drag to move the pane** grip until the pointer is within about 24 px of it. Clicks in that area reach the grip, so they start a drag or open the pane menu instead of reaching the terminal.


## Account priority

When CLIProxyAPI has several Codex or Claude logins, `files/cfg/cli-proxy-api/account_reset_priority.py` steers new sessions to the account whose weekly quota resets soonest, so that quota is used before it expires. It reads the local quota API and writes a `priority` field into the auth files in `~/.cli-proxy-api`. The proxy reloads the auth files without a restart and compares priority only between accounts of the same provider. Accounts at their 5-hour or weekly limit drop to priority 0.

The `account-reset-priority.timer` user unit runs the script about every 10 minutes. It needs `cli-quota.service`. Run `./links.sh cli-quota account-reset-priority` to link and enable both. Run the script with `--dry-run` to see the ranking without writing, or `--provider claude` to limit it to one provider. Accounts with a quota error, or quota data older than 10 minutes, keep their current priority. Check past runs with `journalctl --user -u account-reset-priority`.

## Quota service

`cli-quota.service` serves quota data and reset credits to Quickshell at `http://127.0.0.1:8770/api/quota`. It uses Python's standard library and backs off after provider rate limits. Run `./links.sh cli-quota` to set up the service without the account-priority timer. Use `systemctl --user restart cli-quota.service` after changing the Python code.

The service reads Codex and Claude credentials from `~/.cli-proxy-api` and Antigravity credentials from T3. To refresh an expired Antigravity access token in memory, it needs `~/.config/cli-quota/antigravity-client.json` with `client_id` and `client_secret`. Keep that file private and outside the repository.

## Wallpapers

`wallpaper/` holds a small selection. More are in [wall-archive](https://github.com/debraj-80/wall-archive).
