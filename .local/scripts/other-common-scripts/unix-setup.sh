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

export REAL_USER="$USER"


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


function darwin_init_setup() {
    if ! [[ -e '/Library/Developer/CommandLineTools/usr/bin/git' ]]; then
        xcode-select --install
        # shellcheck disable=SC2034
        read -r WAIT_FOR_XCODE_SELECT
    fi
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


function install_pkgs_darwin() {
    if [[ "$(uname -s)" == 'Darwin' ]]; then
        if ! command -v brew > /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        "${HOME}/.local/scripts/macos/brew-script.sh"
    fi
}
function install_pkgs_debian() {
    EXTRA_APT_CONF='/etc/apt/apt.conf.d/90noinstallsuggests'
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_SUSPEND=true
    PKGS_TO_INSTALL=(
        curl
        debhelper
        dpkg-dev
        git
        openssh-server
        vim
        wget
        gcc-
    )
    sudo apt-get update
    cat << EOF | sudo tee "${EXTRA_APT_CONF}"
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
    sudo apt-get install --assume-yes --no-install-recommends "${PKGS_TO_INSTALL[@]}"
    sudo rm "${EXTRA_APT_CONF}"
    sudo apt-get upgrade --assume-yes
}
function install_pkgs_fedora() {
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
    # PATH needs to be modified temporarily
    # otherwise you get a 'command not found' error like this
    # /nix/store/bpdrgm43y8mgjd5g6q13yfydj9057gly-home-manager/bin/home-manager: line 510: nix-build: command not found
    export PATH="${HOME}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
    HM_CONFIG_PATH="${HOME}/my-git-repos/$(whoami)/prathams-nixos"

    nix_setup

    if ! command -v home-manager > /dev/null; then
        mkdir -vp "${HM_CONFIG_PATH}"
        git clone https://gitlab.com/thefossguy/prathams-nixos "${HM_CONFIG_PATH}"
        nix run home-manager/master -- --print-build-logs init --switch --flake "${HM_CONFIG_PATH}"
    fi
}
function run_rustup() {
    RUSTUP_PATH="${HOME}"/.nix-profile/bin/rustup

    if [[ -x "${RUSTUP_PATH}" && "${PERFORM_RUSTUP_SETUP:-0}" == 1 ]]; then
        "${HOME}"/.local/scripts/other-common-scripts/rust-manage.sh "${HOME}"/.nix-profile/bin/rustup
    fi
}
function chsh_to_bash() {
    if [[ "$(uname -s)" == 'Darwin' ]]; then
        BREW_BASH="$(brew --prefix)/bin/bash"

        # /etc/shells is world readable, so no need to `sudo` unless modifying
        if ! grep "${BREW_BASH}" /etc/shells > /dev/null; then
            echo "${BREW_BASH}" | sudo tee -a /etc/shells
        fi

        if ! finger "${REAL_USER}" | grep -oP "${BREW_BASH}"; then
            sudo chsh -s "${BREW_BASH}" "${REAL_USER}"
        fi
    fi
}
function common_setup() {
    install_dotfiles
    home_manager_setup
    run_rustup
}


if [[ "$(uname -s)" == 'Linux' ]]; then
    if grep 'debian' /etc/os-release > /dev/null; then
        function unix_setup() {
            install_pkgs_debian
            enable_ssh_daemon_debian
            common_setup
        }
    elif grep 'fedora' /etc/os-release > /dev/null; then
        if grep 'rhel' /etc/os-release > /dev/null; then
            RHEL_VERSION="$(grep VERSION_ID /etc/os-release | awk -F"=" '{print $2}')"
            function unix_setup() {
                dnf_conf
                install_pkgs_rhel "${RHEL_VERSION}"
                enable_ssh_daemon_fedora
                common_setup
            }
        else
            function unix_setup() {
                dnf_conf
                install_pkgs_fedora
                enable_ssh_daemon_fedora
                common_setup
            }
        fi
    else
        echo 'Unsupported Linux distribution.'
        exit 1
    fi
elif [[ "$(uname -s)" == 'Darwin' ]]; then
    function unix_setup() {
        darwin_init_setup
        install_pkgs_darwin
        common_setup
        chsh_to_bash
    }
else
    echo 'Unsupported OS.'
    exit 1
fi


unix_setup
rm -v "$0"
