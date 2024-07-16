#!/usr/bin/env bash

swww init &
nm-applet --indicator & # pkgs.networkmanagerapplet
waybar &
mako &
wireplumber &
swww img ~/Pictures/breno-machado-in9-n0JwgZ0-unsplash.jpg
notify-send -u normal "Hyprland" "Welcome, $(whoami)"
