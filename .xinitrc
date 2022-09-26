#!/usr/bin/env bash

USER_X_RESOURCES=$HOME/.Xresources
if [[ -f "$USER_X_RESOURCES" ]]; then
	xrdb -merge "$USER_X_RESOURCES"
fi

xsetroot -cursor_name left_ptr &
xrandr -s 3840x2160+0+0
nvidia-settings --assign CurrentMetaMode="3840x2160+0+0 { ForceFullCompositionPipeline = On }"

pgrep -x dunst > /dev/null || dunst &
pgrep -x picom > /dev/null || picom --experimental-backends --no-fading-openclose &
pkill -USR1 -x sxhkd &

notify-send -u normal "Login manager" "Welcome, $(whoami)"

exec bspwm
