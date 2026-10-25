# Rofi theme

Rofi uses the system color mode from `~/.scripts/set-color`.
The Hyprland shortcut **Super+T** changes this mode with `color-toggle`.
Each Rofi launch reads the selected palette from `colors.rasi`.
Close an open menu and open it again after a mode change.

Edit `colors-dark.rasi` or `colors-light.rasi` to change the colors.
The `set-color` command copies the selected palette to `colors.rasi`.
The shared config applies to the application launcher, command launcher, and dmenu menus.

The Hyprland shortcuts are **Super+Space** for applications and **Super+Shift+Space** for commands.
**Super+Enter** opens Kitty.
