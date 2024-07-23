#!/usr/bin/env bash

brightnessctl --save set 5% >/dev/null 2>&1 # set monitor backlight to minimum, avoid 0 on OLED monitor
notify-send -u normal "Hypridle" "Timeout reached (3 minutes).\nDisplay dimmed to 5% temporarily."
notify-send -u normal "Hypridle" "next timeout: 5 minutes, lock & display off"
