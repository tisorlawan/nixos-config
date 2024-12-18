#!/usr/bin/env bash

rm -rf ~/.config/rofi
ln -srf files/cfg/config/rofi ~/.config/rofi

rm -rf ~/.config/alacritty.toml
ln -srf ./files/cfg/config/alacritty.toml ~/.config/alacritty.toml

rm -rf ~/.config/starship.toml
ln -srf ./files/cfg/config/starship.toml ~/.config/starship.toml

rm -rf ~/.config/greenclip.toml
ln -srf ./files/cfg/config/greenclip.toml ~/.config/greenclip.toml

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

rm -rf ~/.config/yazi
ln -srf ./files/cfg/config/yazi ~/.config/yazi

rm -rf ~/.config/mpd
ln -srf ./files/cfg/config/mpd ~/.config/mpd

rm -rf ~/.config/mpv
ln -srf ./files/cfg/config/mpv ~/.config/mpv

rm -rf ~/.config/eww
ln -srf files/cfg/config/eww ~/.config/eww

rm -rf ~/.images
ln -srf ./files/cfg/images ~/.images

rm -rf ~/.gitconfig
ln -srf ./files/cfg/gitconfig ~/.gitconfig

rm -rf ~/.tmux.conf
ln -srf ./files/cfg/tmux.conf ~/.tmux.conf

rm -rf ~/.scripts
ln -srf ./files/cfg/scripts ~/.scripts
