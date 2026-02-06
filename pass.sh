#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
SRC="$SCRIPT_DIR/pass_decrypt.c"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/passlock"
BIN="$CACHE_DIR/pass_decrypt"

# --- dependency check ---
command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 || {
	echo >&2 "error: C compiler not found. Install: sudo apt install build-essential"
	exit 1
}
[ -f "$SRC" ] || {
	echo >&2 "error: $SRC not found"
	exit 1
}

# --- compile once, rebuild if source changed ---
if [ ! -x "$BIN" ] || [ "$SRC" -nt "$BIN" ]; then
	mkdir -p "$CACHE_DIR"
	cc -O2 -o "$BIN" "$SRC" -lpthread 2>&1 || {
		echo >&2 "error: compilation failed (need build-essential? sudo apt install build-essential)"
		exit 1
	}
fi

# --- run ---
FILE="${1:-$SCRIPT_DIR/passlock.enc}"
[ -f "$FILE" ] || {
	echo >&2 "error: file not found: $FILE"
	exit 1
}

read -rsp "Master password: " PASSWORD
echo >&2

printf '%s' "$PASSWORD" | "$BIN" "$FILE"
