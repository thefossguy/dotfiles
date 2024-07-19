#!/usr/bin/env bash

set -xeuf -o pipefail

# no need to use a browser as a flatpak except for filesystem ($HOME) sandboxing
BROWSERS_AMD=(
    com.google.Chrome
    org.mozilla.firefox
)
BROWSERS_COMMON=(
    com.brave.Browser
    io.gitlab.librewolf-community
)
COMMON_PKGS=(
    # always install Flatseal
    com.github.tchx84.Flatseal
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

flatpak_uninstall_cmd="${FLATPAK_BIN} uninstall --user --assumeyes --noninteractive --delete-data"
${FLATPAK_BIN} remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
${FLATPAK_BIN} install --user --or-update --assumeyes --noninteractive "${ALL_PKGS[@]}"
${FLATPAK_BIN} update --user --assumeyes --noninteractive
${flatpak_uninstall_cmd} --unused
${FLATPAK_BIN} repair --user

CHROMIUM_FLAGS_FILES=(
    "${HOME}/.var/app/com.brave.Browser/config/brave-flags.conf"
    "${HOME}/.var/app/com.google.Chrome/config/chrome-flags.conf"
)
CHROMIUM_FLAGS=(
    '--enable-features=UseOzonePlatform' # enable the Ozone Wayland thingy
    '--ozone-platform-hint=auto' # two-finger zoom on wayland
    '--enable-features=TouchpadOverscrollHistoryNavigation' # enable two-finger swipe for forward/backward history navigation
    '--disable-sync-preferences' # disable syncing chromium preferences with a sync account
)

for CHROMIUM_FLAGS_FILE in "${CHROMIUM_FLAGS_FILES[@]}"; do
    mkdir -p "$(dirname "${CHROMIUM_FLAGS_FILE}")"

    for CHROMIUM_FLAG in "${CHROMIUM_FLAGS[@]}"; do
        if ! grep -q "^${CHROMIUM_FLAG}" "${CHROMIUM_FLAGS_FILE}"; then
            echo "${CHROMIUM_FLAG}" | tee -a "${CHROMIUM_FLAGS_FILE}"
        fi
    done
done

flatpak_override_cmd="${FLATPAK_BIN} override --user"
${flatpak_override_cmd} --nodevice=all --device=dri --nofilesystem=host-etc com.brave.Browser
${flatpak_override_cmd} --nodevice=all --device=dri --nosocket=fallback-x11 --disallow=devel --talk-name=org.freedesktop.Notifications org.mozilla.firefox

sed -i 's@^Name=Brave$@Name=Brave Browser (flatpak)@g' ~/.local/share/flatpak/exports/share/applications/com.brave.Browser.desktop
sed -i 's@^Name=Firefox Web Browser$@Name=Firefox (flatpak)@g' ~/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop
update-desktop-database
