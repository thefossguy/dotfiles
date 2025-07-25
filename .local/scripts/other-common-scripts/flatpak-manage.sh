#!/usr/bin/env bash

set -xeuf -o pipefail

# no need to use a browser as a flatpak except for filesystem ($HOME) sandboxing
BROWSERS_AMD=(
    com.google.Chrome
    com.google.ChromeDev
    app.zen_browser.zen
    org.mozilla.firefox
)
BROWSERS_COMMON=(
    com.brave.Browser
    io.gitlab.librewolf-community
    org.chromium.Chromium
)
COMMON_PKGS=(
    # always install Flatseal
    com.github.tchx84.Flatseal
    "${BROWSERS_COMMON[@]}"
)
AMD_PKGS=(
    "${COMMON_PKGS[@]}"
    "${BROWSERS_AMD[@]}"
    com.discordapp.Discord
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

# Weird, but if $DISPLAY is set but "empty", then GPG fails with the error
# `GPG: Unable to complete signature verification: GnuPG: General error`
# but once $DISPLAY is unexported, it fails with
# `Can't check signature: public key not found`
if printenv | grep -q '^DISPLAY=$'; then
    export -n DISPLAY
fi

# If an error is raised because of GPG signature verification failing
# then try the following steps:
# 1. `wget https://flathub.org/repo/flathub.gpg`
# 2. `gpg --import flathub.gpg`
# 3. `cp flathub.gpg ~/.local/share/flatpak/repo/flathub.trustedkeys.gpg`

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
    '--disable-sync-preferences' # disable syncing chromium preferences with a sync account
    '--enable-features=TouchpadOverscrollHistoryNavigation' # enable two-finger swipe for forward/backward history navigation
    '--enable-features=UseOzonePlatform' # enable the Ozone Wayland thingy

    # when packaged in nixpkgs, these two are included in the [wrapper] script
    # and enabled/used when NIXOS_OZONE_WL == 1
    '--enable-features=WaylandWindowDecorations' # enables client-side (?) window decorations on Wayland
    '--ozone-platform-hint=auto' # two-finger zoom on wayland
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

sed -i 's@^Name=.*$@Name=Brave Browser (flatpak)@g' ~/.local/share/flatpak/exports/share/applications/com.brave.Browser.desktop
sed -i 's@^Name=.*$@Name=Firefox (flatpak)@g' ~/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop
update-desktop-database
