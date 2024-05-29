#!/usr/bin/env bash

WM="${1:-bspwm}"
THEME="${2:-gruvbox}"

killall polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

CONFIG_DIR=$(dirname $0)/themes/$THEME/config.ini

echo $WM

cp "$HOME/.config/polybar/modules-$WM.ini" "$HOME/.config/polybar-modules.ini"
polybar main -c "$CONFIG_DIR"
