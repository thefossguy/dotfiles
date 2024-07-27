#!/usr/bin/env bash

WALLPAPER_DIR="${WALLPAPER_DIR:-${HOME}/Pictures/wallpapers}"
WALLPAPER_TIMEOUT_IN_SEC="${WALLPAPER_TIMEOUT_IN_SEC:-1800}"

if [[ -d "${WALLPAPER_DIR}" ]]; then
    ALL_WALLPAPERS=( $(find "${WALLPAPER_DIR}" -type f | shuf) )
    for RANDOM_WALLPAPER in "${ALL_WALLPAPERS[@]}"; do
        swww img --resize crop --transition-type fade --transition-duration 2 --transition-fps 12 "${RANDOM_WALLPAPER}"
        sleep "${WALLPAPER_TIMEOUT_IN_SEC}s"
        notify-send --expire-time 10000 --urgency normal "swww" "wallpaper change timeout (${WALLPAPER_TIMEOUT_IN_SEC}s)"
    done
fi
