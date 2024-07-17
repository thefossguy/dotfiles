#!/usr/bin/env bash

pidof -q swww-daemon || swww-daemon &
pidof -q waybar      || waybar &
pidof -q nm-applet   || nm-applet --indicator & # pkgs.networkmanagerapplet
pgrep blueman-applet || blueman-applet & # pkgs.blueman; also, `blueman-applet` is run by `python` :|
pidof -q mako        || mako &
pidof -q wl-paste    || wl-paste --watch cliphist store &

#swww img <IMG>
notify-send -u normal "Hyprland" "Welcome, $(whoami)"
