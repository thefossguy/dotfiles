#!/usr/bin/env bash

set -xeuf -o pipefail

# no need to use a browser as a flatpak except for filesystem ($HOME) sandboxing
BROWSERS_AMD=(
    com.google.Chrome
)
BROWSERS_COMMON=(
    io.gitlab.librewolf-community
)
COMMON_PKGS=(
    "${BROWSERS_COMMON[@]}"
    md.obsidian.Obsidian
    org.gnome.gitlab.YaLTeR.VideoTrimmer
    org.gnome.meld
    org.raspberrypi.rpi-imager
)
AMD_PKGS=(
    "${COMMON_PKGS[@]}"
    "${BROWSERS_AMD[@]}"
    com.discordapp.Discord
    fr.handbrake.ghb
)
ARM_PKGS=(
    "${COMMON_PKGS[@]}"
)
RISCV_PKGS=(
    "${COMMON_PKGS[@]}"
)
BROWSERS_ALL=( "${BROWSERS_AMD[@]}" "${BROWSERS_COMMON[@]}" )

if [[ -d '/sys' ]]; then
    if grep 'x86_64' /proc/sys/kernel/arch > /dev/null; then
        ALL_PKGS=( "${AMD_PKGS[@]}" )
    elif grep 'aarch64' /proc/sys/kernel/arch > /dev/null; then
        ALL_PKGS=( "${ARM_PKGS[@]}" )
    elif grep 'riscv64' /proc/sys/kernel/arch > /dev/null; then
        ALL_PKGS=( "${RISCV_PKGS[@]}" )
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

${FLATPAK_BIN} remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# always install Flatseal
${FLATPAK_BIN} install --user --or-update --assumeyes --noninteractive com.github.tchx84.Flatseal
${FLATPAK_BIN} install --user --or-update --assumeyes --noninteractive "${ALL_PKGS[@]}"
${FLATPAK_BIN} update --user --assumeyes --noninteractive
${FLATPAK_BIN} uninstall --user --unused --assumeyes --noninteractive --delete-data
${FLATPAK_BIN} repair --user

for flatpak_pkg in "${ALL_PKGS[@]}"; do
    if [[ "${BROWSERS_ALL[*]}" == *"${flatpak_pkg}"* ]]; then
        flatpak override --user --reset "${flatpak_pkg}"
    fi
done
