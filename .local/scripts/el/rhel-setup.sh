#!/usr/bin/env bash

set -xef -o pipefail

if ! command -v tmux > /dev/null; then
    echo 'sudo dnf install -y tmux'
    exit 2
fi

if [[ -z $1 ]]; then
    # shellcheck disable=SC2016
    echo 'Who is $USER?'
    exit 1
fi

sudo dnf install -y epel-release
sudo /usr/bin/crb enable
sudo dnf install -y appliance-tools aria2 arm-trusted-firmware-armv8 asciidoc audit-libs-devel bat binutils-devel bison btop cloud-utils-growpart container-tools dash dwarves e2fsprogs elfutils-devel epel-release flex gcc gcc-c++ gcc-plugin-devel git glibc-static gnutls-devel gzip hdparm htop kernel-rpm-macros libbabeltrace-devel libbpf-devel libcap-devel libcap-ng-devel libnl3-devel libtraceevent-devel libuuid-devel m4 make mock ncurses-devel neovim newt-devel numactl-devel opencsd-devel openssl-devel parallel pciutils pciutils-devel 'perl(ExtUtils::Embed)' perl-devel perl-Digest-SHA perl-generators picocom procps-ng pykickstart python3-devel python3-docutils python3-libfdt python3-pyelftools ripgrep rpm-build rpmdevtools rpmlint SDL2-devel ShellCheck swig tmux tree util-linux wget xmlto xz xz-devel yt-dlp zlib-devel zstd
sudo dnf clean all
sudo dnf upgrade
sudo usermod -aG mock "$1"
echo 'sudo systemctl reboot'
