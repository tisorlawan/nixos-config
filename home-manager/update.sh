#!/usr/bin/env bash
set -euo pipefail

VERBOSE=0

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-v|--verbose] [extra home-manager args...]"
      echo "Example: $0 -v --no-substitute"
      exit 0
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
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
