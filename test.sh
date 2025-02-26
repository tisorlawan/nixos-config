#!/bin/bash

export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export WAYLAND_DISPLAY=wayland-0

# If not in Wayland session, try to start one just for this app
if [ -z "$WAYLAND_DISPLAY" ]; then
	# Create a temporary Wayland server just for this application
	weston --width=1024 --height=768 --shell=fullscreen-shell.so &
	WESTON_PID=$!
	sleep 2
	export WAYLAND_DISPLAY=wayland-0

	# Run TopTracker
	TopTracker

	# Clean up
	kill $WESTON_PID
else
	# Already in Wayland, just run TopTracker
	TopTracker
fi
