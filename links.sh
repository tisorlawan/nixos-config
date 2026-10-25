#!/usr/bin/env bash
# Symlink parts of this repository into $HOME. Safe to rerun, and safe to run from any directory.
# Each destination is deleted and relinked, so local edits to a linked file are lost.
#
# Usage: links.sh TARGET...    e.g. links.sh nvim codex
#        links.sh all          set up every target
# All targets are validated before anything is linked.
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

CFG=files/cfg
CONFIG=$CFG/config

# ~/.config entries that have the same name as their directory under files/cfg/config.
CONFIG_ENTRIES=(
  alacritty.toml bspwm dunst eww fish greenclip.toml gtk-3.0 gtk-4.0 hypr kitty
  lazygit mako mpd mpv nix nushell nvim picom quickshell redshift
  rofi swappy sxhkd user-dirs.dirs waybar wezterm yazi zellij
)

# Every target, in the order that "all" runs them.
TARGETS=(
  "${CONFIG_ENTRIES[@]}"
  btop copyq pudb opencode emacs
  bash clang-format git tmux vim images scripts
  claude codex agents
  ghostty rclone
  t3code codex-desktop tern
  cliproxyapi account-reset-priority agent-usage-stats
)

usage() {
  printf 'usage: links.sh all | TARGET...\n\ntargets:\n' >&2
  printf '  %s\n' all "${TARGETS[@]}" >&2
}

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

declare -A is_config_entry=() is_target=()
for name in "${CONFIG_ENTRIES[@]}"; do is_config_entry[$name]=1; done
for name in "${TARGETS[@]}"; do is_target[$name]=1; done

# run_target NAME: link one target.
run_target() {
  local name="$1"

  if [[ -n ${is_config_entry[$name]:-} ]]; then
    link "$CONFIG/$name" "$HOME/.config/$name"
    return
  fi

  case "$name" in
    # Single files inside a ~/.config directory that other programs also write to.
    btop) link "$CONFIG/btop/btop.conf" "$HOME/.config/btop/btop.conf" ;;
    copyq) link "$CONFIG/copyq/copyq.conf" "$HOME/.config/copyq/copyq.conf" ;;
    pudb) link "$CONFIG/pudb/pudb.cfg" "$HOME/.config/pudb/pudb.cfg" ;;
    opencode)
      link "$CONFIG/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
      link .agents/AGENTS.md "$HOME/.config/opencode/AGENTS.md"
      link .agents/skills "$HOME/.config/opencode/skills"
      ;;
    emacs) link emacs "$HOME/.config/emacs" ;;

    # Dotfiles in $HOME.
    bash) link "$CFG/bashrc" "$HOME/.bashrc" ;;
    clang-format) link "$CFG/clang-format" "$HOME/.clang-format" ;;
    git) link "$CFG/gitconfig" "$HOME/.gitconfig" ;;
    tmux) link "$CFG/tmux.conf" "$HOME/.tmux.conf" ;;
    vim) link "$CFG/vimrc" "$HOME/.vimrc" ;;
    images) link "$CFG/images" "$HOME/.images" ;;
    scripts) link "$CFG/scripts" "$HOME/.scripts" ;;

    # Agent instructions and skills are shared by Claude Code, Codex, and opencode.
    claude)
      link .agents/AGENTS.md "$HOME/.claude/CLAUDE.md"
      link .agents/commands "$HOME/.claude/commands"
      link .agents/skills "$HOME/.claude/skills"
      ;;
    codex)
      link .agents/AGENTS.md "$HOME/.codex/AGENTS.md"
      link .agents/skills "$HOME/.codex/skills"
      ;;
    agents) link .agents/skills "$HOME/.agents/skills" ;;

    # The my-ghostty script generates ~/.config/ghostty, so start from an empty directory.
    ghostty)
      rm -rf -- "$HOME/.config/ghostty"
      mkdir -p -- "$HOME/.config/ghostty"
      ;;

    # rclone.conf holds credentials and is gitignored, so it is copied, not linked.
    # Skip the copy when the source is missing so an existing config survives.
    rclone)
      if [[ -d $CONFIG/rclone ]]; then
        rm -rf -- "$HOME/.config/rclone"
        cp -r -- "$CONFIG/rclone" "$HOME/.config/rclone"
      fi
      ;;

    # Desktop wrappers use system Mesa instead of the inherited Nix graphics overrides.
    # Not linked: com.t3tools.T3Code.desktop, which T3 regenerates on every launch.
    t3code | codex-desktop)
      link "$CFG/local/bin/$name" "$HOME/.local/bin/$name"
      link "$CFG/local/share/applications/$name.desktop" "$HOME/.local/share/applications/$name.desktop"
      ;;

    # Preserve the Tern binary and its generated desktop files. Use a separate Mesa wrapper and desktop entry.
    tern)
      link "$CFG/local/bin/my-tern" "$HOME/.local/bin/my-tern"
      link "$CFG/local/share/applications/tern.desktop" "$HOME/.local/share/applications/tern.desktop"
      ;;

    # CLIProxyAPI: install, then replace its config with the one in this repository.
    cliproxyapi)
      curl -fsSL https://raw.githubusercontent.com/router-for-me/cliproxyapi-installer/refs/heads/master/cliproxyapi-installer | bash
      link "$CFG/cli-proxy-api/config.yaml" "$HOME/cliproxyapi/config.yaml"
      systemctl --user enable cliproxyapi.service
      systemctl --user restart cliproxyapi.service
      ;;

    # Every 10 minutes, give the Codex and Claude accounts whose weekly quota resets soonest the
    # highest CLIProxyAPI "priority", so their quota is used before it resets.
    account-reset-priority)
      link "$CFG/cli-proxy-api/account_reset_priority.py" "$HOME/cliproxyapi/account_reset_priority.py"
      for unit in account-reset-priority.service account-reset-priority.timer; do
        link "$CONFIG/systemd/user/$unit" "$HOME/.config/systemd/user/$unit"
      done
      systemctl --user daemon-reload
      systemctl --user enable --now account-reset-priority.timer
      ;;

    # Agent usage dashboard: link the app and unit, build the React app, start the service.
    agent-usage-stats) bash install-script/setup-agent-usage-stats.sh ;;
  esac
}

if (($# == 0)); then
  usage
  exit 1
fi

if [[ $1 == -h || $1 == --help ]]; then
  usage
  exit 0
fi

# Validate every argument before linking anything.
invalid=()
for arg in "$@"; do
  if [[ $arg != all && -z ${is_target[$arg]:-} ]]; then
    invalid+=("$arg")
  fi
done
if ((${#invalid[@]})); then
  printf 'links.sh: unknown target: %s\n' "${invalid[@]}" >&2
  usage
  exit 1
fi

# "all" wins over anything else; otherwise run each target once, in the order given.
selected=()
declare -A seen=()
for arg in "$@"; do
  if [[ $arg == all ]]; then
    selected=("${TARGETS[@]}")
    break
  fi
  if [[ -z ${seen[$arg]:-} ]]; then
    seen[$arg]=1
    selected+=("$arg")
  fi
done

for name in "${selected[@]}"; do
  run_target "$name"
done
