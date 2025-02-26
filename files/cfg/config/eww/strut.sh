#!/bin/sh
# Wait for the bar window with a timeout
TIMEOUT=5
START_TIME=$(date +%s)
while [ -z "$(xdotool search --name bar 2>/dev/null)" ]; do
	sleep 0.1
	CURRENT_TIME=$(date +%s)
	if [ $((CURRENT_TIME - START_TIME)) -ge $TIMEOUT ]; then
		echo "Error: Bar window not found after $TIMEOUT seconds" >&2
		exit 1
	fi
done

# Get the window ID
WINDOW_ID=$(xdotool search --name bar 2>/dev/null)
if [ -z "$WINDOW_ID" ]; then
	echo "Error: Could not find window ID for bar" >&2
	exit 1
fi

# Get the height
HEIGHT=$(xwininfo -id "$WINDOW_ID" 2>/dev/null | grep "Height:" | awk '{print $2}')
if [ -z "$HEIGHT" ]; then
	echo "Error: Could not get height for window ID $WINDOW_ID" >&2
	exit 1
fi

# Set the strut property
echo "Setting _NET_WM_STRUT for window $WINDOW_ID with height $HEIGHT" >&2
xprop -id "$WINDOW_ID" -f _NET_WM_STRUT 32c -set _NET_WM_STRUT "0,0,$HEIGHT,0" || {
	echo "Error: Failed to set _NET_WM_STRUT" >&2
	exit 1
}

# Force bspwm to reapply layout
bspc wm -r

echo "Successfully set strut property and refreshed layout" >&2

xprop -id "$WINDOW_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE "_NET_WM_STATE_STICKY"
bspc wm -r
