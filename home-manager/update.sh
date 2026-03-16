#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

install_gdm_session() {
  local wrapper_src="$SCRIPT_DIR/gdm/hyprland-hm-session"
  local desktop_src="$SCRIPT_DIR/gdm/hyprland.desktop"
  local wrapper_dst="/usr/local/bin/hyprland-hm-session"
  local desktop_dst="/usr/local/share/wayland-sessions/hyprland.desktop"

  if [[ ! -x "$HOME/.nix-profile/bin/Hyprland" ]]; then
    echo "Hyprland is not present in ~/.nix-profile/bin; removing stale GDM session files if they exist."
    sudo rm -f "$wrapper_dst" "$desktop_dst"
    return
  fi

  echo "Installing GDM session entry for Hyprland..."
  sudo install -D -m 755 "$wrapper_src" "$wrapper_dst"
  sudo install -D -m 644 "$desktop_src" "$desktop_dst"
}

VERBOSE=0

UPDATE_INPUTS=()
UPDATE_ALL=0
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
  -v | --verbose)
    VERBOSE=1
    shift
    ;;
  -u | --update-input)
    if [[ -z "${2:-}" ]]; then
      echo "Error: --update-input requires a flake input name" >&2
      exit 1
    fi
    UPDATE_INPUTS+=("$2")
    shift 2
    ;;
  --upgrade)
    UPDATE_ALL=1
    shift
    ;;
  --update-all)
    UPDATE_ALL=1
    shift
    ;;
  -h | --help)
    echo "Usage: $0 [-v|--verbose] [--upgrade] [-u|--update-input <input>] [--update-all] [extra home-manager args...]"
    echo ""
    echo "By default, only rebuilds the configuration without upgrading package versions."
    echo "Use --upgrade to update all flake inputs before rebuilding."
    echo ""
    echo "Example: $0              # Rebuild only"
    echo "Example: $0 --upgrade    # Update all inputs and rebuild"
    echo "Example: $0 -v --upgrade --no-substitute"
    echo "Example: $0 --update-input opencode"
    echo "Example: $0 --update-all"
    exit 0
    ;;
  *)
    ARGS+=("$1")
    shift
    ;;
  esac
done

if [[ $UPDATE_ALL -eq 1 ]]; then
  echo "Updating all flake inputs..."
  nix flake update
fi

for input in "${UPDATE_INPUTS[@]}"; do
  echo "Updating flake input: $input"
  nix flake lock --update-input "$input"
done

HM_ARGS=(
  --extra-experimental-features "nix-command flakes"
  --flake .
)

if [[ $VERBOSE -eq 1 ]]; then
  set -x
  HM_ARGS+=(--verbose --show-trace)
fi

# If user didn't provide a backup option, default to "-b backup" so
# Home Manager backs up conflicting unmanaged files instead of failing.
want_backup=1
for a in "${ARGS[@]}"; do
  if [[ "$a" == "-b" || "$a" == "--backup" ]]; then
    want_backup=0
    break
  fi
done
if ((want_backup)); then
  HM_ARGS+=(-b backup)
fi

if ((${#ARGS[@]} > 0)); then
  home-manager switch "${HM_ARGS[@]}" "${ARGS[@]}"
else
  home-manager switch "${HM_ARGS[@]}"
fi

install_gdm_session
