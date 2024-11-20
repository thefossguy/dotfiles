#!/usr/bin/env bash

if [[ "$(uname -s)" == 'Linux' ]]; then
    if grep 'ID=nixos' /etc/os-release > /dev/null; then
        echo 'You are on NixOS, no need, have a great day, bye!'
        exit 0
    fi
elif [[ "$(uname -s)" == 'Darwin' ]]; then

    if ! xcode-select --print-path 2>/dev/null; then
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        XCODE_CLI_TOOLS=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
        softwareupdate --install "${XCODE_CLI_TOOLS}" --verbose;
    fi

    # TODO: This is specific to `aarch64-darwin`; `x86_64-darwin` doesn't **need** to be supported.
    if [[ ! -x /opt/homebrew/bin/brew ]]; then
        # Add the user to the `admin` group for a non-interactive installation of homebrew.
        if ! groups | grep -q admin; then
            sudo dseditgroup -o edit -a "${LOGNAME}" -t user admin
        fi
        # A "nonsense" `sudo` to enter the password-less timeout window for
        # really non-interactive homebrew installation.
        sudo ls >/dev/null
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    PATH="$PATH:/opt/homebrew/bin:/opt/homebrew/sbin"
    export PATH
    brew analytics off
    if ! command -v tmux; then
        brew install tmux
    fi
fi

if ! command -v tmux; then
    echo 'install tmux'
    exit 1
fi

if ! printenv | grep 'TERM_PROGRAM=tmux' > /dev/null; then
    exec tmux
fi

set -xeuf -o pipefail

export REAL_USER="$LOGNAME"

if [[ -z "${REAL_USER}" ]]; then
    echo 'For some reason, $LOGNAME is empty.'
    exit 1
fi


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


function install_pkgs_darwin() {
    "${HOME}/.local/scripts/macos/brew-script.sh"
}
function install_pkgs_debian() {
    EXTRA_APT_CONF='/etc/apt/apt.conf.d/90noinstallsuggests'
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_SUSPEND=true
    PKGS_TO_INSTALL=(
        bridge-utils
        curl
        debhelper
        dpkg-dev
        git
        openssh-server
        rsync
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
        bridge-utils
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
        epel_targets=('epel-release')
        if grep 'NAME="CentOS Stream"' /etc/os-release > /dev/null; then
            epel_targets+=('epel-next-release')
        fi
        sudo dnf install --assumeyes "${epel_targets[@]}"
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
            pushd "${HOME}/.detsys-nix" || exit 1

            curl -sL -o nix-installer "https://install.determinate.systems/nix/nix-installer-${platform_arch}-${platform_kernel}"
            chmod +x nix-installer
            popd || exit 1
        fi

        "${HOME}/.detsys-nix/nix-installer" install --no-confirm
    fi
}
function home_manager_setup() {
    # PATH needs to be modified temporarily
    # otherwise you get a 'command not found' error like this
    # /nix/store/bpdrgm43y8mgjd5g6q13yfydj9057gly-home-manager/bin/home-manager: line 510: nix-build: command not found
    export PATH="${HOME}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
    HM_CONFIG_PATH="${HOME}/.prathams-nixos"

    nix_setup

    if ! command -v home-manager > /dev/null; then
        [[ -d "${HM_CONFIG_PATH}/.git" ]] || git clone https://gitlab.com/thefossguy/prathams-nixos "${HM_CONFIG_PATH}"
        pushd  "${HM_CONFIG_PATH}" || exit 1

        nix flake update
        nix build --max-jobs 1 --print-build-logs --show-trace --trace-verbose --verbose .#homeConfigurations."${platform_arch}-${platform_kernel}"."${LOGNAME}".activationPackage
        ./result/activate
        popd || exit 1
    fi
}
function run_rustup() {
    RUSTUP_PATH="${HOME}/.nix-profile/bin/rustup"

    if [[ -x "${RUSTUP_PATH}" && "${PERFORM_RUSTUP_SETUP:-0}" == 1 ]]; then
        "${HOME}"/.local/scripts/other-common-scripts/rust-manage.sh "${RUSTUP_PATH}"
    fi
}
function chsh_to_bash() {
    BREW_BASH="$(brew --prefix)/bin/bash"

    # /etc/shells is world readable, so no need to `sudo` unless modifying
    if ! grep "${BREW_BASH}" /etc/shells > /dev/null; then
        echo "${BREW_BASH}" | sudo tee -a /etc/shells
    fi

    if ! dscl . -read "${HOME}" UserShell | sed -s 's/UserShell: //' | grep -q "${BREW_BASH}"; then
        sudo chsh -s "${BREW_BASH}" "${REAL_USER}"
    fi
}
function common_setup() {
    install_dotfiles
    home_manager_setup
    run_rustup
}


platform_kernel="$(uname -s | awk '{print tolower($0)}')"
platform_arch="$(uname -m)"
if [[ "${platform_arch}" == 'arm64' ]]; then
platform_arch='aarch64'
fi
export platform_arch
export platform_kernel

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
        common_setup
        install_pkgs_darwin
        chsh_to_bash
    }
else
    echo 'Unsupported OS.'
    exit 1
fi


unix_setup
rm -v "$0"
