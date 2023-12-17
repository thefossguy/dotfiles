#!/usr/bin/env bash

set -xeuf -o pipefail

if [[ "$(nix eval -f '<nixpkgs>' 'linux.version' | sed -e 's/"//g')" == "$(uname -r)" ]]; then
    KERNEL_PACKAGE='linux'
elif [[ "$(nix eval -f '<nixpkgs>' 'linux_latest.version' | sed -e 's/"//g')" == "$(uname -r)" ]]; then
    KERNEL_PACKAGE='linux_latest'
else
    echo 'Could not determine which kernel you are using. Bye!'
    exit 1
fi

OLD_KERNEL_VERSION="$(nix eval -f '<nixpkgs>' ${KERNEL_PACKAGE}.version | sed -e 's/"//g')"
nix-channel --update nixos
NEW_KERNEL_VERSION="$(nix eval -f '<nixpkgs>' ${KERNEL_PACKAGE}.version | sed -e 's/"//g')"
if [[ "${OLD_KERNEL_VERSION}" != "${NEW_KERNEL_VERSION}" ]]; then
    KERNEL_UPGRADE=true
else
    KERNEL_UPGRADE=false
fi

if [[ "$(date +%A)" == 'Saturday' ]]; then
    UNCONDITIONAL_UPGRADE=true
else
    UNCONDITIONAL_UPGRADE=false
fi

if [[ "${KERNEL_UPGRADE}" || "${UNCONDITIONAL_UPGRADE}" ]]; then
    nixos-rebuild boot --upgrade-all
else
    echo 'Nothing to upgrade today.'
fi
