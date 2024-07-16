#!/usr/bin/env bash

pgrep swww        || swww init &
pgrep nm-applet   || nm-applet --indicator & # pkgs.networkmanagerapplet
pgrep waybar      || waybar &
pgrep mako        || mako &
pgrep wireplumber || wireplumber &
pgrep wl-paste    || wl-paste --watch cliphist store &

swww img ~/Pictures/breno-machado-in9-n0JwgZ0-unsplash.jpg
notify-send -u normal "Hyprland" "Welcome, $(whoami)"
