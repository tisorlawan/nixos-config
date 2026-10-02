#!/usr/bin/env bash
# Symlink this repository into $HOME. Safe to rerun, and safe to run from any directory.
# Each destination is deleted and relinked, so local edits to a linked file are lost.
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

CFG=files/cfg
CONFIG=$CFG/config

# link SOURCE DESTINATION: replace DESTINATION with a relative symlink to SOURCE.
# Fails before deleting anything if SOURCE does not exist.
link() {
  local source="$1" destination="$2"
  if [[ ! -e "$source" ]]; then
    printf 'links.sh: missing source %s\n' "$source" >&2
    return 1
  fi
  rm -rf -- "$destination"
  mkdir -p -- "$(dirname -- "$destination")"
  ln -sr -- "$source" "$destination"
}

# ~/.config entries that have the same name as their directory under files/cfg/config.
for name in \
  alacritty.toml bspwm dunst eww fish greenclip.toml gtk-3.0 gtk-4.0 hypr kitty \
  lazygit mako mpd mpv nix nushell nvim nvim-minimal picom quickshell redshift \
  rofi swappy sxhkd user-dirs.dirs waybar wezterm yazi zellij; do
  link "$CONFIG/$name" "$HOME/.config/$name"
done

# Single files inside a ~/.config directory that other programs also write to.
link "$CONFIG/btop/btop.conf" "$HOME/.config/btop/btop.conf"
link "$CONFIG/copyq/copyq.conf" "$HOME/.config/copyq/copyq.conf"
link "$CONFIG/pudb/pudb.cfg" "$HOME/.config/pudb/pudb.cfg"
link "$CONFIG/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"

link emacs "$HOME/.config/emacs"

# Dotfiles in $HOME.
link "$CFG/bashrc" "$HOME/.bashrc"
link "$CFG/clang-format" "$HOME/.clang-format"
link "$CFG/gitconfig" "$HOME/.gitconfig"
link "$CFG/tmux.conf" "$HOME/.tmux.conf"
link "$CFG/vimrc" "$HOME/.vimrc"
link "$CFG/images" "$HOME/.images"
link "$CFG/scripts" "$HOME/.scripts"

# Agent instructions and skills are shared by Claude Code, Codex, and opencode.
link .agents/AGENTS.md "$HOME/.claude/CLAUDE.md"
link .agents/AGENTS.md "$HOME/.codex/AGENTS.md"
link .agents/AGENTS.md "$HOME/.config/opencode/AGENTS.md"
link .agents/commands "$HOME/.claude/commands"
for dir in .claude .codex .agents .config/opencode; do
  link .agents/skills "$HOME/$dir/skills"
done

# The my-ghostty script generates ~/.config/ghostty, so start from an empty directory.
rm -rf -- "$HOME/.config/ghostty"
mkdir -p -- "$HOME/.config/ghostty"

# rclone.conf holds credentials and is gitignored, so it is copied, not linked.
# Skip the copy when the source is missing so an existing config survives.
if [[ -d $CONFIG/rclone ]]; then
  rm -rf -- "$HOME/.config/rclone"
  cp -r -- "$CONFIG/rclone" "$HOME/.config/rclone"
fi

# T3 Code Nightly: the wrapper unsets the Nix Mesa env vars so Chromium keeps GPU rendering.
# Not linked: com.t3tools.T3Code.desktop, which T3 regenerates on every launch.
link "$CFG/local/bin/t3code-nightly" "$HOME/.local/bin/t3code-nightly"
link "$CFG/local/share/applications/t3code-nightly.desktop" \
  "$HOME/.local/share/applications/t3code-nightly.desktop"

# CLIProxyAPI: install, then replace its config with the one in this repository.
curl -fsSL https://raw.githubusercontent.com/router-for-me/cliproxyapi-installer/refs/heads/master/cliproxyapi-installer | bash
link "$CFG/cli-proxy-api/config.yaml" "$HOME/cliproxyapi/config.yaml"
systemctl --user enable cliproxyapi.service
systemctl --user restart cliproxyapi.service

# Agent usage dashboard: link the app and unit, build the React app, start the service.
bash install-script/setup-agent-usage-stats.sh
