#!/usr/bin/env bash

USER_X_RESOURCES=$HOME/.Xresources
if [[ -f "$USER_X_RESOURCES" ]]; then
    xrdb -merge "$USER_X_RESOURCES"
fi

xsetroot -cursor_name left_ptr &
xrandr -s 3840x2160+0+0
nvidia-settings --assign CurrentMetaMode="3840x2160+0+0 { ForceFullCompositionPipeline = On }"

pgrep -x dunst > /dev/null || dunst &
pgrep -x picom > /dev/null || picom --fade-exclude 'class_g = "xsecurelock"' &
pgrep -x sxhkd > /dev/null || sxhkd &
pgrep -x lxpolkit > /dev/null || lxpolkit &

notify-send -u normal "Login manager" "Welcome, $(whoami)"

exec bspwm -c $HOME/.config/bspwm/bspwmrc
