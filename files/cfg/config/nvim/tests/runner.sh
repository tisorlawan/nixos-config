#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
root=$(pwd -P)
scratch=$(mktemp -d "$root/tests/.runner-state.XXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
export XDG_STATE_HOME="$scratch/state"
export XDG_DATA_HOME="$scratch/data"
export XDG_CACHE_HOME="$scratch/cache"
export XDG_CONFIG_HOME="$scratch/config"
for phase in initial restart; do
  RUNNER_TEST_PHASE="$phase" nvim --headless -u NONE -i NONE \
    '+lua local ok, err = xpcall(function() dofile("tests/runner.lua") end, debug.traceback); if not ok then print(err); vim.cmd("cquit 1") end' \
    '+qa!'
done
