#!/usr/bin/env bash

set -xeuf

# **INSTALL ONLY WHAT DOESN'T SEEM TO WORK WITH NIX/HOME-MANAGER**
BREW_FORUMLAS=(
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
    google-chrome
    handbrake
    keka
    libreoffice
    librewolf
    maccy
    macs-fan-control
    meld
    obs
    protonvpn
    raspberry-pi-imager
    slack
    thunderbird
    tor-browser
    utm
    whatsapp
)

brew analytics off
brew update --force # upgrade homebrew itself
brew upgrade --greedy --greedy-latest --greedy-auto-updates --no-quarantine # upgrade the packages installed by homebrew

brew install --formula "${BREW_FORUMLAS[@]}"
brew install --cask "${BREW_CASKS[@]}"

brew autoremove
brew cleanup --prune=all -s
# shellcheck disable=SC2016
brew doctor || echo 'WARNING: `brew doctor` found some issues!'
brew outdated --greedy --greedy-latest --greedy-auto-updates
brew missing
