#!/usr/bin/env bash

set -xeuf -o pipefail

COMMON_PKGS=(
    com.brave.Browser
    com.github.tchx84.Flatseal
    io.gitlab.librewolf-community
    md.obsidian.Obsidian
    org.gnome.gitlab.YaLTeR.Identity
    org.gnome.gitlab.YaLTeR.VideoTrimmer
    org.gnome.Logs
    org.gnome.meld
    org.raspberrypi.rpi-imager
)
AMD_PKGS=(
    com.discordapp.Discord
    fr.handbrake.ghb
)
ARM_PKGS=()
RISCV_PKGS=() # lol

if [[ "$(uname -m)" == 'x86_64' ]]; then
    ALL_PKGS=( "${COMMON_PKGS[@]}" "${AMD_PKGS[@]}" )
elif [[ "$(uname -m)" == 'aarch64' ]]; then
    ALL_PKGS=( "${COMMON_PKGS[@]}" "${ARM_PKGS[@]}" )
elif [[ "$(uname -m)" == 'riscv64' ]]; then
    ALL_PKGS=( "${COMMON_PKGS[@]}" "${RISCV_PKGS[@]}" )
else
    echo 'Unsupported CPU ISA'
    exit 1
fi

if command -v flatpak > /dev/null; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install --user --or-update --assumeyes --noninteractive "${ALL_PKGS[@]}"
    flatpak update --user --assumeyes --noninteractive
    flatpak uninstall --user --unused --assumeyes --noninteractive --delete-data
    flatpak repair --user
else
    echo 'Flatpak not found, exiting cleanly nonetheless'
    exit 0
fi
