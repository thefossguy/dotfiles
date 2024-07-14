#!/usr/bin/env bash

if [[ ! -f "${HOME}/.config/alacritty/platform.toml" ]]; then
    if [[ "$(uname -s)" == 'Linux' ]]; then
        ln -s "${HOME}/.config/alacritty/"{linux,platform}.toml
    elif [[ "$(uname -s)" == 'Darwin' ]]; then
        ln -s "${HOME}/.config/alacritty/"{darwin,platform}.toml
    fi
fi

# for some reason Fedora/RHEL does not have a '/etc/ssl/certs/ca-certificates.crt'
# instead they have a '/etc/pki/tls/certs/ca-bundle.crt'
if [[ "$(uname -s)" == 'Linux' ]]; then
    if [[ ! -f '/etc/ssl/certs/ca-certificates.crt' ]]; then
        if grep -q "ID_LIKE=*.rhel*." /etc/os-release; then
            sudo ln -s /etc/pki/tls/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
        fi
    fi
fi
