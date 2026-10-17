#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
root=$(pwd -P)
scratch=$(mktemp -d "$root/tests/.lean-state.XXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
export XDG_STATE_HOME="$scratch/state"
export XDG_CACHE_HOME="$scratch/cache"
export LEAN_CONFIG_TEST_ROOT="$root"
mkdir "$scratch/project"
cd "$scratch/project"
lake init LeanConfigCheck
nvim --headless -u "$root/init.lua" -i NONE \
  '+lua local ok, err = xpcall(function() dofile(vim.env.LEAN_CONFIG_TEST_ROOT .. "/tests/lean.lua") end, debug.traceback); if not ok then print(err); vim.cmd("cquit 1") end' \
  '+qa!'
