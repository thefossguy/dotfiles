#!/usr/bin/env dash

if [ ! -f "${HOME}/.config/alacritty/load_intermediate.yml" ]; then
    if uname | grep -q Linux; then
        echo "load_linux.yml" > "${HOME}/.config/alacritty/load_intermediate.yml"
    else
        echo "load_macos.yml" > "${HOME}/.config/alacritty/load_intermediate.yml"
    fi
fi
