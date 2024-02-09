#!/usr/bin/env bash

if [[ "$(uname -s)" == 'Linux' ]]; then
    if grep 'ID=nixos' /etc/os-release > /dev/null; then
        echo 'You are on NixOS, no need, have a great day, bye!'
        exit 0
    fi
fi

if sudo grep '^#.*NOPASSWD.*' /etc/sudoers > /dev/null; then
    echo 'You forgot to set NOPASSWD.'
    exit 1
fi

if ! command -v tmux; then
    echo 'install tmux'
    exit 1
fi

if ! printenv | grep 'TERM_PROGRAM=tmux' > /dev/null; then
    echo 'Run this script in tmux.'
    exit 1
fi

set -xeuf -o pipefail


function enable_ssh_daemon_common() {
    if [[ "$(sudo systemctl is-enabled "$1.service")" != 'enabled' ]]; then
        sudo systemctl enable --now "$1.service"
    fi
}
function enable_ssh_daemon_debian() {
    enable_ssh_daemon_common ssh
}
function enable_ssh_daemon_fedora() {
    enable_ssh_daemon_common sshd
}


function dnf_conf() {
    function dnf_conf_inner() {
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

    dnf_conf_inner 'exit_on_lock' 'True'
    dnf_conf_inner 'installonly_limit' '20'
    dnf_conf_inner 'max_parallel_downloads' '10'
}


function install_pkgs_debian() {
    PKGS_TO_INSTALL=(
        curl
        git
        openssh-server
        wget
    )
    sudo apt-get update
    sudo apt-get install --assume-yes --no-install-recommends "${PKGS_TO_INSTALL[@]}"
    sudo apt-get upgrade --assume-yes
}
function install_pkgs_fedora() {
    REAL_USER="$USER"
    PKGS_TO_INSTALL=(
        appliance-tools
        curl
        git
        mock
        openssh-server
        procps-ng
        pykickstart
        rpm-build
        rpmdevtools
        rpmlint
        wget
    )
    sudo dnf clean expire-cache
    sudo dnf install --assumeyes "${PKGS_TO_INSTALL[@]}"
    sudo dnf upgrade --assumeyes
    sudo usermod -aG mock "${REAL_USER}"
}
function enable_epel() {
    if command -v subscription-manager > /dev/null; then
        REL_VER=$1

        sudo subscription-manager repos --enable "codeready-builder-for-rhel-${REL_VER}-$(uname -m)-rpms"
        sudo dnf install --assumeyes "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${REL_VER}.noarch.rpm"
    else
        sudo dnf config-manager --set-enabled crb
        sudo dnf install --assumeyes epel-release
    fi
}
function install_pkgs_rhel() {
    sudo dnf clean expire-cache
    enable_epel "$1"
    install_pkgs_fedora
}


function install_dotfiles() {
    if [[ ! -d "${HOME}/.dotfiles" ]]; then
        git clone --bare https://gitlab.com/thefossguy/dotfiles "${HOME}/.dotfiles"
        git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout -f
    fi
}
function nix_setup() {
    if ! command -v nix > /dev/null; then
        if [[ ! -f "${HOME}/.detsys-nix/nix-installer" ]]; then
            mkdir -vp "${HOME}/.detsys-nix"
            pushd "${HOME}/.detsys-nix"

            curl -sL -o nix-installer "https://install.determinate.systems/nix/nix-installer-$(uname -m)-linux"
            chmod +x nix-installer
            popd
        fi

        "${HOME}/.detsys-nix/nix-installer" install linux --no-confirm
    fi
}
function home_manager_setup() {
    if ! command -v home-manager > /dev/null; then
        # pushd-ing because otherwise the flake.nix points to
        # '/home/pratham/.config/home-manager/hm.flake.nix' but home-manager,
        # for some reason does not like it; probably because it assumes the
        # source to be **outside of $HOME**; so make it point to './<file>'
        pushd "${HOME}/.config/home-manager"
        [[ ! -f 'flake.nix' ]] && ln -s {hm.,}flake.nix
        [[ ! -f 'home.nix' ]] && ln -s {common,home}.nix
        popd

        # PATH needs to be modified temporarily
        # otherwise you get a 'command not found' error like this
        # /nix/store/bpdrgm43y8mgjd5g6q13yfydj9057gly-home-manager/bin/home-manager: line 510: nix-build: command not found
        export PATH="${HOME}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
        nix run home-manager/master -- init --switch
    fi
}
function run_rustup() {
    "${HOME}"/.local/scripts/other-common-scripts/rust-manage.sh "${HOME}"/.nix-profile/bin/rustup
}
function common_setup() {
    install_dotfiles
    nix_setup
    home_manager_setup
    run_rustup
}


if grep "ID=debian\|ID=ubuntu" /etc/os-release > /dev/null; then
    function linux_setup() {
        install_pkgs_debian
        enable_ssh_daemon_debian
        common_setup
    }
elif grep "ID=fedora" /etc/os-release > /dev/null; then
    function linux_setup() {
        dnf_conf
        install_pkgs_fedora
        enable_ssh_daemon_fedora
        common_setup
    }
elif grep "ID_LIKE=*.rhel*." /etc/os-release > /dev/null; then
    RHEL_VERSION="$(grep VERSION_ID /etc/os-release | awk -F"=" '{print $2}')"
    function linux_setup() {
        dnf_conf
        install_pkgs_rhel "${RHEL_VERSION}"
        enable_ssh_daemon_fedora
        common_setup
    }
else
    echo 'Unsupported Linux distribution.'
    exit 1
fi


linux_setup
