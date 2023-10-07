#!/usr/bin/env bash

set -euf

if [ ! -f "${HOME}/.config/alacritty/load_intermediate.yml" ]; then
    if uname | grep -q Linux; then
        ln -s "${HOME}/.config/alacritty/load_linux.yml" "${HOME}/.config/alacritty/load_intermediate.yml"
    else
        ln -s "${HOME}/.config/alacritty/load_macos.yml" "${HOME}/.config/alacritty/load_intermediate.yml"
    fi
fi
