# Rice

Dotfiles, scripts, and Nix configuration for my machines. Clone this repository to `~/.rice`. `links.sh` symlinks the configs into `$HOME`, so editing a file under `~/.config` edits it here.

## Layout

| Path | Contents |
|------|----------|
| `files/cfg/config/` | Per-program configs, linked into `~/.config` (nvim, kitty, hypr, fish, mpv, and others). |
| `files/cfg/scripts/` | Shell and Python helpers, linked to `~/.scripts`. |
| `files/cfg/local/` | `~/.local` content: the `t3code-nightly` launcher and the agent usage dashboard. |
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
| Link configs into `$HOME` | `./links.sh` |
| Rebuild NixOS | `./rebuild.sh` |
| Rebuild home-manager | `cd home-manager && ./update.sh` (add `--upgrade` to update flake inputs first) |
| Set up the usage dashboard only | `install-script/setup-agent-usage-stats.sh` |

`links.sh` deletes each destination before it links, so a file that already exists in `$HOME` is replaced. It also installs CLIProxyAPI and builds the usage dashboard. See [SETUP.md](SETUP.md) for the one-time install steps.

## Agent usage dashboard

The dashboard shows Codex and Claude token usage at http://127.0.0.1:8770, grouped by model and by day in WIB (UTC+7). The React app is in `files/cfg/local/share/agent-usage-stats`, and its systemd unit is `files/cfg/config/systemd/user/agent-usage-stats.service`.

`setup-agent-usage-stats.sh` links the app to `~/.local/share/agent-usage-stats` and `~/tools/codex-usage-stats`, links the unit into `~/.config/systemd/user`, builds the app, and enables the service at login. Pass `--skip-build` to relink and restart without rebuilding. Dependencies, builds, and usage snapshots are gitignored. The [dashboard README](files/cfg/local/share/agent-usage-stats/README.md) covers development and token accounting.

## Wallpapers

`wallpaper/` holds a small selection. More are in [wall-archive](https://github.com/debraj-80/wall-archive).
