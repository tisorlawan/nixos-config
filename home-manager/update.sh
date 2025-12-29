#!/usr/bin/env bash
set -euo pipefail

VERBOSE=0

UPDATE_INPUTS=()
UPDATE_ALL=0
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -u|--update-input)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --update-input requires a flake input name" >&2
        exit 1
      fi
      UPDATE_INPUTS+=("$2")
      shift 2
      ;;
    --update-all)
      UPDATE_ALL=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-v|--verbose] [-u|--update-input <input>] [--update-all] [extra home-manager args...]"
      echo "Example: $0 -v --no-substitute"
      echo "Example: $0 --update-input opencode"
      echo "Example: $0 --update-all"
      echo ""
      echo "Note: If no update arguments are provided, --update-all is assumed."
      exit 0
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

# Default to updating all if no specific update instructions are given
if [[ $UPDATE_ALL -eq 0 && ${#UPDATE_INPUTS[@]} -eq 0 ]]; then
  UPDATE_ALL=1
fi

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
if (( want_backup )); then
  HM_ARGS+=( -b backup )
fi

if (( ${#ARGS[@]} > 0 )); then
  home-manager switch "${HM_ARGS[@]}" "${ARGS[@]}"
else
  home-manager switch "${HM_ARGS[@]}"
fi
