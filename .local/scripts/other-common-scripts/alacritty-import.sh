#!/usr/bin/env bash

set -eu

if [[ ! -f "${HOME}/.config/alacritty/platform.yml" ]]; then
    if [[ "$(uname -s)" == 'Linux' ]]; then
        ln -s "${HOME}/.config/alacritty/"{linux,platform}.yml
    elif [[ "$(uname -s)" == 'Darwin' ]]; then
        ln -s "${HOME}/.config/alacritty/"{darwin,platform}.yml
    fi
fi
