#!/bin/sh

DIR="$HOME/.rice/wallpaper"
IMG=$(find "$DIR" -type f | shuf -n 1)

# hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$IMG"
hyprctl hyprpaper wallpaper ",$IMG"
