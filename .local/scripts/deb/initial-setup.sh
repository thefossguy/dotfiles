#!/usr/bin/env bash

set -xeuf -o pipefail

if ! sudo test -f /etc/sudoers; then
    echo 'sudo apt-get install -y sudo'
    exit 1
fi

if sudo grep '^#.*NOPASSWD.*' /etc/sudoers > /dev/null; then
    echo 'You forgot to set NOPASSWD.'
    exit 1
fi

if ! command -v tmux; then
    echo 'sudo apt-get install -y tmux'
    exit 1
fi

if ! printenv | grep 'TERM_PROGRAM=tmux' > /dev/null; then
    echo 'Run this script in a terminal multiplexer (tmux).'
    exit 1
fi

export REAL_USER="$USER"

sudo systemctl enable --now ssh

echo 'deb http://deb.debian.org/debian bookworm main non-free-firmware
deb-src http://deb.debian.org/debian bookworm main non-free-firmware

deb http://deb.debian.org/debian-security bookworm-security main non-free-firmware
deb-src http://deb.debian.org/debian-security bookworm-security main non-free-firmware

deb http://deb.debian.org/debian bookworm-updates main non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware' | sudo tee /etc/apt/sources.list

PKGS_TO_INSTALL=(
    aria2
    bat
    btop
    curl
    dash
    direnv
    fish
    git
    gzip
    hdparm
    htop
    parallel
    picocom
    podman
    ripgrep
    rsync
    shellcheck
    tree
    vim
    wget
    yt-dlp
    zstd
)

sudo apt-get update
sudo apt-get install -y --no-install-recommends "${PKGS_TO_INSTALL[@]}"
sudo apt-get upgrade -y

if [[ ! -d "${HOME}/.dotfiles" ]]; then
    git clone --bare https://gitlab.com/thefossguy/dotfiles "${HOME}/.dotfiles"
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout -f
fi

if ! command -v direnv > /dev/null; then
    if [[ "$(uname -m)" = 'x86_64' ]]; then
        DIRENV_ARCH='amd64'
    elif [[ "$(uname -m)" = 'aarch64' ]]; then
        DIRENV_ARCH='arm64'
    fi

    mkdir -vp "${HOME}/.local/bin"
    pushd "${HOME}/.local/bin"
    curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep "direnv.linux-$DIRENV_ARCH" | cut -d : -f 2,3 | tr -d \" | grep 'https' | wget -qi -
    mv "direnv.linux-$DIRENV_ARCH" direnv
    chmod +x direnv
    popd
fi

if command -v fish > /dev/null; then
    if ! getent passwd "${REAL_USER}" | cut -d: -f7 | grep fish > /dev/null; then
        sudo chsh -s "$(command -v fish)" "${REAL_USER}"
    fi
fi

if ! command -v rustup > /dev/null; then
    curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh -s -- \
        -y \
        --quiet \
        --profile default \
        --component rust-src rust-analysis rust-analyzer clippy
fi

if ! command -v nix > /dev/null; then
    if [[ ! -f "${HOME}/.detsys-nix/nix-installer" ]]; then
        mkdir -vp "${HOME}/.detsys-nix"
        pushd "${HOME}/.detsys-nix"

        curl -sL -o nix-installer "https://install.determinate.systems/nix/nix-installer-$(uname -m)-linux"
        chmod +x nix-installer
        popd
    fi

    "${HOME}/.detsys-nix/nix-installer" install linux --no-confirm
    /nix/var/nix/profiles/default/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixos
    /nix/var/nix/profiles/default/bin/nix-channel --update
fi
