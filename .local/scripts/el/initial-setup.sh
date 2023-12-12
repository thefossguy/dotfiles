#!/usr/bin/env bash

set -xeuf -o pipefail

if sudo grep '^#.*NOPASSWD.*' /etc/sudoers > /dev/null; then
    echo 'You forgot to set NOPASSWD.'
    exit 1
fi

if ! command -v tmux; then
    echo 'sudo dnf install -y tmux'
    exit 1
fi

if ! printenv | grep 'TERM_PROGRAM=tmux' > /dev/null; then
    echo 'Run this script in a terminal multiplexer (tmux).'
    exit 1
fi

export REAL_USER="$USER"
export DISTRO="$1"

if [[ "$DISTRO" = 'alma' || "$DISTRO" = 'rhel' || "$DISTRO" = 'centos' || "$DISTRO" = 'rocky' ]]; then
    DISTRO='el'
fi

if [[ "$DISTRO" != 'el' && "$DISTRO" != 'fedora' ]]; then
    echo 'Unsupported distro.'
    exit 1
fi

function dnf_conf() {
    OPTION="$1"
    VALUE="$2"

    if ! grep "${OPTION}=${VALUE}" /etc/dnf/dnf.conf > /dev/null; then
        if ! grep "${OPTION}" /etc/dnf/dnf.conf > /dev/null; then
            echo "${OPTION}=${VALUE}" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
        else
            sudo sed -i "s/.*${OPTION}.*/${OPTION}=${VALUE}/" /etc/dnf/dnf.conf
        fi
    fi
}
dnf_conf 'exit_on_lock' 'True'
dnf_conf 'installonly_limit' '20'
dnf_conf 'max_parallel_downloads' '10'

sudo dnf clean expire-cache

PKGS_TO_INSTALL=(
    appliance-tools
    aria2
    bat
    btop
    curl
    dash
    git
    gzip
    hdparm
    htop
    mock
    parallel
    perl-Digest-SHA
    picocom
    podman
    procps-ng
    pykickstart
    ripgrep
    rpm-build
    rpmdevtools
    rpmlint
    rsync
    ShellCheck
    tmux
    tree
    vim-enhanced
    wget
    xz
    yt-dlp
    zstd
)

if [[ "$DISTRO" = 'el' ]]; then
    if command -v subscription-manager > /dev/null; then
        M_ARCH="$(uname -m)"
        REL_VER="$(dnf config-manager --dump-variables | grep 'releasever' | awk '{print $3}')"

        sudo subscription-manager repos --enable "codeready-builder-for-rhel-${REL_VER}-${M_ARCH}-rpms"
        sudo dnf install --assumeyes "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${REL_VER}.noarch.rpm"
    else
        sudo dnf config-manager --set-enabled crb
        sudo dnf install --assumeyes epel-release
    fi
elif [[ "$DISTRO" = 'fedora' ]]; then
    PKGS_TO_INSTALL+=(
        direnv
        fish
        neovim
    )
fi

sudo dnf install --assumeyes "${PKGS_TO_INSTALL[@]}"
sudo dnf upgrade --assumeyes

sudo usermod -aG mock "${REAL_USER}"

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
    curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep "direnv.linux-$DIRENV_ARCH" | cut -d : -f 2,3 | tr -d \" | wget -qi -
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
