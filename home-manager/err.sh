#!/bin/sh

journalctl -b --no-pager | rg -i "start-hyprland|Hyprland|gdm|gbm|MESA|execvp"
