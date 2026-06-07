#!/usr/bin/env bash

rm -rf ~/.config/alacritty.toml
ln -srf files/cfg/config/alacritty.toml ~/.config/alacritty.toml

rm -rf ~/.config/nvim
ln -srf files/cfg/config/nvim ~/.config/nvim

rm -rf ~/.config/kittty
ln -srf files/cfg/config/kitty ~/.config/kitty

rm -rf ~/.config/btop/btop.conf
mkdir -p ~/.config/btop
ln -srf files/cfg/config/btop/btop.conf ~/.config/btop/btop.conf

rm -rf ~/.config/copyq/copyq.conf
mkdir -p ~/.config/copyq
ln -srf files/cfg/config/copyq/copyq.conf ~/.config/copyq/copyq.conf

rm -rf ~/.config/pudb/pudb.cfg
mkdir -p ~/.config/pudb
ln -srf files/cfg/config/pudb/pudb.cfg ~/.config/pudb/pudb.cfg

rm -rf ~/.vimrc
ln -srf files/cfg/vimrc ~/.vimrc

rm -rf ~/.config/fish
ln -srf files/cfg/config/fish ~/.config/fish

rm -rf ~/.config/rofi
ln -srf files/cfg/config/rofi ~/.config/rofi

rm -rf ~/.config/greenclip.toml
ln -srf ./files/cfg/config/greenclip.toml ~/.config/greenclip.toml

rm -rf ~/.config/lazygit
ln -srf ./files/cfg/config/lazygit ~/.config/lazygit

rm -rf ~/.config/user-dirs.dirs
ln -srf ./files/cfg/config/user-dirs.dirs ~/.config/user-dirs.dirs

rm -rf ~/.config/bspwm
ln -srf ./files/cfg/config/bspwm ~/.config/bspwm

rm -rf ~/.config/dunst
ln -srf ./files/cfg/config/dunst ~/.config/dunst

rm -rf ~/.config/picom
ln -srf ./files/cfg/config/picom ~/.config/picom

rm -rf ~/.config/polybar
ln -srf ./files/cfg/config/polybar ~/.config/polybar

rm -rf ~/.config/sxhkd
ln -srf ./files/cfg/config/sxhkd ~/.config/sxhkd

rm -rf ~/.config/redshift
ln -srf ./files/cfg/config/redshift ~/.config/redshift

rm -rf ~/.config/wezterm
ln -srf ./files/cfg/config/wezterm ~/.config/wezterm

rm -rf ~/.config/nushell
ln -srf ./files/cfg/config/nushell ~/.config/nushell

rm -rf ~/.config/yazi
ln -srf ./files/cfg/config/yazi ~/.config/yazi

rm -rf ~/.config/quickshell
ln -srf ./files/cfg/config/quickshell ~/.config/quickshell

rm -rf ~/.config/mpd
ln -srf ./files/cfg/config/mpd ~/.config/mpd

rm -rf ~/.config/mpv
ln -srf ./files/cfg/config/mpv ~/.config/mpv

rm -rf ~/.config/eww
ln -srf files/cfg/config/eww ~/.config/eww

rm -rf ~/.config/zellij
ln -srf files/cfg/config/zellij ~/.config/zellij

rm -rf ~/.images
ln -srf ./files/cfg/images ~/.images

rm -rf ~/.gitconfig
ln -srf ./files/cfg/gitconfig ~/.gitconfig

rm -rf ~/.clang-format
ln -srf ./files/cfg/clang-format ~/.clang-format

rm -rf ~/.tmux.conf
ln -srf ./files/cfg/tmux.conf ~/.tmux.conf

rm -rf ~/.scripts
ln -srf ./files/cfg/scripts ~/.scripts

rm -rf ~/.doom.d/
ln -srf files/cfg/doom.d/ ~/.doom.d

mkdir -p ~/.claude
rm -rf ~/.claude/commands
ln -srf cc/commands/ ~/.claude/commands
ln -srf ./files/cfg/config/opencode/AGENTS.md ~/.claude/CLAUDE.md

rm -rf ~/.config/opencode/AGENTS.md
ln -srf ./files/cfg/config/opencode/AGENTS.md ~/.config/opencode/AGENTS.md

rm -rf ~/.config/opencode/opencode.json
ln -srf ./files/cfg/config/opencode/opencode.json ~/.config/opencode/opencode.json

rm -rf ~/.config/opencode/skill
ln -srf ./files/cfg/config/opencode/skill ~/.config/opencode/skill

rm -rf ~/.config/opencode/commands
ln -srf cc/commands/ ~/.config/opencode/commands

rm -rf ~/.config/ghostty
mkdir ~/.config/ghostty

rm -rf ~/.config/gtk-3.0
ln -srf files/cfg/config/gtk-3.0 ~/.config/gtk-3.0

rm -rf ~/.config/gtk-4.0
ln -srf files/cfg/config/gtk-4.0 ~/.config/gtk-4.0

rm -rf ~/.config/hypr
ln -srf files/cfg/config/hypr ~/.config/hypr

rm -rf ~/.config/mako
ln -srf files/cfg/config/mako ~/.config/mako

rm -rf ~/.config/rclone
cp -r files/cfg/config/rclone ~/.config/rclone

rm -rf ~/.config/nix
ln -srf files/cfg/config/nix ~/.config/nix

rm -rf ~/.config/nix
ln -srf files/cfg/config/nix ~/.config/nix

rm -rf ~/.config/swappy
ln -srf files/cfg/config/swappy ~/.config/swappy

rm -rf ~/.config/waybar
ln -srf files/cfg/config/waybar ~/.config/waybar

rm -rf ~/.bashrc
ln -srf ./files/cfg/bashrc ~/.bashrc
