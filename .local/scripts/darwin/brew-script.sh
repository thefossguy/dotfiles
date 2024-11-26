#!/usr/bin/env bash

set -xeuf

# **INSTALL ONLY WHAT DOESN'T SEEM TO WORK WITH NIX/HOME-MANAGER**
BREW_FORMULAE=(
    bash
    mpv
    neovide
    rpm2cpio
    wakeonlan
)

# "GUI apps" that cannot be handled by home-manager
BREW_CASKS=(
    alacritty
    balenaetcher
    bitwarden
    brave-browser
    discord
    exifcleaner
    firefox
    handbrake
    keka
    librewolf
    maccy
    macs-fan-control
    obs
    proton-pass
    protonvpn
    raspberry-pi-imager
    thunderbird
    tor-browser
    utm
    zen-browser
)

# Work machine has Google Chrome installed via the IDM. Using homebrew to do
# that will fail. So add them only if the username is not what I use on my work machine.
if [[ "${LOGNAME}" != 'ppatel' ]]; then
    BREW_CASKS+=( google-chrome )
fi

# Kill the processes that automatically start on login so that the upgrade
# does not error out because the cask can't be replace as it is running.
function pkill_process() {
    PROCESS_NAME="${1:-}"
    if [[ -z "${PROCESS_NAME}" ]]; then
        echo 'No process specified to pkill.'
        exit 1
    fi

    pkill -o "${PROCESS_NAME}" || echo "${PROCESS_NAME} is not running, doing nothing"
}
PROCESSES_TO_KILL=(
    'Bitwarden'
    'Discord'
    'Maccy'
    'Macs Fan Control'
    'OBS'
    'Proton Pass'
    'ProtonVPN'
    'UTM'
)
if pgrep -q QEMULauncher; then
    echo 'QEMU VMs are running. Please close them in case UTM has an update to install.'
    exit 1
fi
for PROCESS_TO_KILL in "${PROCESSES_TO_KILL[@]}"; do
    pkill_process "${PROCESS_TO_KILL}"
done

brew analytics off
brew update --force # upgrade homebrew itself
brew upgrade --greedy --greedy-latest --greedy-auto-updates --no-quarantine --force # upgrade the packages installed by homebrew

brew install --no-quarantine --formula --force "${BREW_FORMULAE[@]}"

for HB_CASK in "${BREW_CASKS[@]}"; do
    if ! brew list --cask "${HB_CASK}" 1>/dev/null; then
        brew install --no-quarantine --cask "${HB_CASK}"
    fi
done

brew autoremove
brew cleanup --prune=all -s
# shellcheck disable=SC2016
brew doctor || echo 'WARNING: `brew doctor` found some issues!'
brew outdated --greedy --greedy-latest --greedy-auto-updates
brew missing
