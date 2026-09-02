#!/bin/sh

mode="$(cat "$HOME/.color" 2>/dev/null || printf 'dark')"
case "$mode" in
    dark|light) ;;
    *) mode=dark ;;
esac

DIR="$HOME/.rice/wallpaper/$mode"
IMG="$(find "$DIR" -type f | shuf -n 1)"

[ -n "$IMG" ] || exit 0
hyprctl hyprpaper wallpaper ",$IMG,cover"
