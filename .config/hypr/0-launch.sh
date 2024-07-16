#!/usr/bin/env bash

pgrep -x swww        || swww-daemon &
pgrep -x nm-applet   || nm-applet --indicator & # pkgs.networkmanagerapplet
pgrep -x waybar      || waybar &
pgrep -x mako        || mako &
pgrep -x wireplumber || wireplumber &
pgrep -x wl-paste    || wl-paste --watch cliphist store &

# workaround for pipewire not working for some fucking reason
timeout 1 wpctl status
# we restart pipewire.service only if the command is killed by timeout
if [[ "$?" -eq 124 ]]; then
    systemctl --user restart pipewire.service
fi

#swww img <IMG>
notify-send -u normal "Hyprland" "Welcome, $(whoami)"
