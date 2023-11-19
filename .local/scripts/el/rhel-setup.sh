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
sudo dnf install -y appliance-tools aria2 bat btop cloud-utils-growpart dash e2fsprogs git gzip htop mock neovim parallel pciutils perl-Digest-SHA picocom procps-ng pykickstart ripgrep rpm-build rpmdevtools rpmlint ShellCheck tmux tree util-linux wget xz yt-dlp zstd
sudo dnf clean all
sudo dnf upgrade
sudo usermod -aG mock "$1"
echo 'sudo systemctl reboot'
