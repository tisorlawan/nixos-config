#!/usr/bin/env sh

HYPRGAMEMODE=$(hyprctl getoption decoration:shadow:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ]; then
	notify-send "Game Mode"
	hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 0;\
        keyword decoration:rounding 0"
	exit
else
	notify-send "No Game Mode"
	hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 1;\
        keyword decoration:blur:enabled 1;\
        keyword general:gaps_in 1;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 1"
	exit
fi
hyprctl reload
