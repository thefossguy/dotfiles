#!/usr/bin/env bash

brightnessctl set 15%
pidof -q hypridle    || hypridle &
pidof -q wl-paste    || wl-paste --watch cliphist store &
pidof -q mako        || mako &
pidof -q waybar      || waybar &
pidof -q swww-daemon || swww-daemon &
pidof -q nm-applet   || nm-applet --indicator & # pkgs.networkmanagerapplet
pgrep blueman-applet || blueman-applet & # pkgs.blueman; also, `blueman-applet` is run by `python` :|

"${HOME}/.local/scripts/hyprland/set-wallpaper.sh" &
notify-send --urgency normal "Hyprland" "Welcome, $(whoami)"
