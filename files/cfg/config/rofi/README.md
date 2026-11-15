# Rofi theme

Rofi follows the theme from the Quickshell theme panel and the dark or light mode from `~/.scripts/set-color`.
The Hyprland shortcut **Super+T** changes the mode with `color-toggle`.
Each Rofi launch reads the selected palette from `colors.rasi`.
Close an open menu and open it again after a change.

`~/.scripts/theme-colors` writes `colors.rasi`. `set-theme` and `set-color` run it.
It copies a palette from `files/cfg/themes/rofi/`, which `files/cfg/themes/generate.cjs` builds from the Quickshell catalog.
To change the colors, edit the palette in `config/quickshell/Themes.js` and run the generator.
Git ignores `colors.rasi`. Until the first write, `config.rasi` uses Catppuccin dark.

The shared config applies to the application launcher, command launcher, and dmenu menus.

The Hyprland shortcuts are **Super+Space** for applications and **Super+Shift+Space** for commands.
**Super+Enter** opens Kitty.
