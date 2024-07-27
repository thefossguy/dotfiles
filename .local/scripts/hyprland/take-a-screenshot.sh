#!/usr/bin/env bash

XDG_PICTURES_DIR="${HOME}/Pictures"
SCREENSHOT_FILENAME="$(date +'%Y-%m-%d-%H.%M.%S')_$(hostname).png"
SCREENSHOT_FILE_PATH="${XDG_PICTURES_DIR}/${SCREENSHOT_FILENAME}"

[[ ! -d "${XDG_PICTURES_DIR}" ]] && mkdir "${XDG_PICTURES_DIR}"

if [[ "${1:-}" == 'selection' ]]; then
    grim -g "$(slurp -d)" "${SCREENSHOT_FILE_PATH}"
else
    grim "${SCREENSHOT_FILE_PATH}"
fi

wl-copy < "${SCREENSHOT_FILE_PATH}"
