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

if (( ${#ARGS[@]} > 0 )); then
  home-manager switch "${HM_ARGS[@]}" "${ARGS[@]}"
else
  home-manager switch "${HM_ARGS[@]}"
fi
