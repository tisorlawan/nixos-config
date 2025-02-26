#!/bin/sh

function get_workspaces() {
	# Read desktops into an array to handle names with spaces
	mapfile -t desktops < <(bspc query -D --names)
	# Get the currently focused desktop
	focused=$(bspc query -D -d focused --names)
	# Start building the EWW box string
	result="(box"

	# Loop through each desktop
	for desktop in "${desktops[@]}"; do
		# Check if the desktop is focused or has windows
		is_focused="$([ "$desktop" == "$focused" ] && echo "true" || echo "false")"
		has_windows="$([ $(bspc query -N -d "$desktop" | wc -l) -gt 0 ] && echo "true" || echo "false")"

		# Only include desktops that are focused or occupied
		if [ "$is_focused" == "true" ] || [ "$has_windows" == "true" ]; then
			if [ "$is_focused" == "true" ]; then
				style="workspace-active"
			else
				style="workspace-visible"
			fi
			# Add a label for this desktop (matching Hyprland output)
			result="$result (label :class \"$style\" :text \"$desktop\")"
		fi
	done

	result="$result)"
	echo "$result"
}

# Initial output
get_workspaces

# Listen for BSPWM events and update the widget
bspc subscribe desktop_focus node_add node_remove | while read -r event; do
	get_workspaces
done
