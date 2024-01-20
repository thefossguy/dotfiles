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

if [[ -d '/sys' ]]; then
    if grep 'x86_64' /proc/sys/kernel/arch > /dev/null; then
        ALL_PKGS=( "${COMMON_PKGS[@]}" "${AMD_PKGS[@]}" )
    elif grep 'aarch64' /proc/sys/kernel/arch > /dev/null; then
        ALL_PKGS=( "${COMMON_PKGS[@]}" "${ARM_PKGS[@]}" )
    elif grep 'riscv64' /proc/sys/kernel/arch > /dev/null; then
        ALL_PKGS=( "${COMMON_PKGS[@]}" "${RISCV_PKGS[@]}" )
    else
        echo 'Unsupported CPU ISA'
        exit 1
    fi
else
    echo 'macOS?'
    exit 1
fi

if command -v flatpak > /dev/null; then
    FLATPAK_BIN="$(command -v flatpak)"
elif [[ -x '/run/current-system/sw/bin/flatpak' ]]; then
    FLATPAK_BIN='/run/current-system/sw/bin/flatpak'
else
    echo 'Flatpak not found, exiting cleanly nonetheless'
    exit 0
fi

${FLATPAK_BIN} remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
${FLATPAK_BIN} install --user --or-update --assumeyes --noninteractive "${ALL_PKGS[@]}"
${FLATPAK_BIN} update --user --assumeyes --noninteractive
${FLATPAK_BIN} uninstall --user --unused --assumeyes --noninteractive --delete-data
${FLATPAK_BIN} repair --user
