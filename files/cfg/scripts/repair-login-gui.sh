#!/usr/bin/env sh
set -eu

sudo apt update
sudo apt install -y ubuntu-desktop-minimal gdm3 gnome-shell xserver-xorg-core libgl1-mesa-dri libglx-mesa0 libegl-mesa0
sudo systemctl set-default graphical.target
sudo systemctl enable gdm3
sudo systemctl restart gdm3

printf '%s\n' 'If GUI does not appear, run: sudo reboot'
