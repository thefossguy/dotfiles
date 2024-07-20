#!/usr/bin/env bash

if [[ ! -f "${HOME}/.config/alacritty/platform.toml" ]]; then
    pushd "${HOME}/.config/alacritty/" || exit 0
    if [[ "$(uname -s)" == 'Linux' ]]; then
        ln -s linux.toml platform.toml
    elif [[ "$(uname -s)" == 'Darwin' ]]; then
        ln -s darwin.toml platform.toml
    fi
    popd || exit 0
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
