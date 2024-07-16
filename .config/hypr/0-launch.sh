#!/usr/bin/env bash

pgrep -x swww           || swww-daemon &
pgrep -x waybar         || waybar &
pgrep -x nm-applet      || nm-applet --indicator & # pkgs.networkmanagerapplet
pgrep -x blueman-applet || blueman-applet & # pkgs.blueman
pgrep -x mako           || mako &
pgrep -x wl-paste       || wl-paste --watch cliphist store &

#swww img <IMG>
notify-send -u normal "Hyprland" "Welcome, $(whoami)"
