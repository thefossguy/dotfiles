#!/usr/bin/env bash

set -eu

if [[ ! -f "${HOME}/.config/home-manager/home.nix" ]]; then
    if [[ "$(uname -s)" == 'Linux' ]]; then
        if ! grep 'ID=nixos' /etc/os-release > /dev/null; then
            ln -s "${HOME}/.config/home-manager/"{common,home}.nix
            ln -s "${HOME}/.config/home-manager/"{linux,platform}.nix
        fi
    elif [[ "$(uname -s)" == 'Darwin' ]]; then
            ln -s "${HOME}/.config/home-manager/"{common,home}.nix
            ln -s "${HOME}/.config/home-manager/"{darwin,platform}.nix
    fi
fi
