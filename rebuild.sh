#!/usr/bin/env bash

# rebuild
sudo nixos-rebuild switch --flake .#default
