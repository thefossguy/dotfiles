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
    dnf_conf_inner 'max_parallel_downloads' '20'
}


function install_pkgs_debian() {
    PKGS_TO_INSTALL=(
        curl
        git
        vim
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
function install_64k_kernel() {
    sudo dnf install -y kernel-64k
    KERNEL_64K=$(echo /boot/vmlinuz*64k)
    sudo grubby --set-default="${KERNEL_64K}" \
        --update-kernel="${KERNEL_64K}" \
        --args='crashkernel=2G-:640M'
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

            platform="$(uname -s | awk '{print tolower($0)}')"
            curl -sL -o nix-installer "https://install.determinate.systems/nix/nix-installer-$(uname -m)-${platform}"
            chmod +x nix-installer
            popd
        fi

        "${HOME}/.detsys-nix/nix-installer" install --no-confirm
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
function darwin_setup() {
    if [[ "$(uname -s)" == 'Darwin' ]]; then
        # TODO: xcode thingy
        # TODO: homebrew setup
        echo "WIP"
    fi
}
function common_setup() {
    install_dotfiles
    nix_setup
    darwin_setup
    home_manager_setup
    run_rustup
}


if [[ "$(uname -s)" == 'Linux' ]]; then
    if grep "ID=debian\|ID=ubuntu" /etc/os-release > /dev/null; then
        function unix_setup() {
            install_pkgs_debian
            enable_ssh_daemon_debian
            common_setup
        }
    elif grep "ID=fedora" /etc/os-release > /dev/null; then
        function unix_setup() {
            dnf_conf
            install_pkgs_fedora
            enable_ssh_daemon_fedora
            common_setup
        }
    elif grep "ID_LIKE=*.rhel*." /etc/os-release > /dev/null; then
        RHEL_VERSION="$(grep VERSION_ID /etc/os-release | awk -F"=" '{print $2}')"
        function unix_setup() {
            dnf_conf
            install_pkgs_rhel "${RHEL_VERSION}"
            install_64k_kernel
            enable_ssh_daemon_fedora
            common_setup
            echo '64K kernel has been installed and will be what gets used upon the next boot.'
            # shellcheck disable=SC2016
            echo 'Please run `sudo dnf erase kernel` upon the next boot.'
        }
    else
        echo 'Unsupported Linux distribution.'
        exit 1
    fi
elif [[ "$(uname -s)" == 'Darwin' ]]; then
    function unix_setup() {
        common_setup
    }
else
    echo 'Unsupported OS.'
    exit 1
fi


unix_setup
rm -v "$0"
