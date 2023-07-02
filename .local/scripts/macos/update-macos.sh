#!/usr/bin/env bash

function ensure_installed_formulas() {
    brew install --formula \
        aria2 \
        bash \
        bat \
        btop \
        coreutils \
        curl \
        dash \
        fd \
        ffmpeg \
        fish \
        gcc \
        git \
        gnu-sed \
        grep \
        htop \
        imagemagick \
        iperf \
        iperf3 \
        minisign \
        mpv \
        neovide \
        neovim \
        picocom \
        rename \
        ripgrep \
        rpm2cpio \
        tmux \
        tree \
        wakeonlan \
        watch \
        wget \
        xz \
        yt-dlp \
        #EOL
}

function ensure_installed_casks() {
    brew tap homebrew/cask-fonts
    brew install --cask \
        alacritty \
        android-platform-tools \
        balenaetcher \
        bitwarden \
        brave-browser \
        discord \
        exifcleaner \
        firefox \
        font-fira-mono-nerd-font \
        font-overpass-nerd-font \
        font-sauce-code-pro-nerd-font \
        google-chrome \
        handbrake \
        keepassx \
        keka \
        libreoffice \
        librewolf \
        maccy \
        macs-fan-control \
        meld \
        microsoft-teams \
        obs \
        protonvpn \
        raspberry-pi-imager \
        telegram \
        tor-browser \
        utm \
        whatsapp \
        #EOL
}

if [[ $(uname) != "Darwin" ]]; then
    echo "You are on a good platform. Do not execute this script."
    exit
fi

if ! command -v brew > /dev/null; then
    if ! xcode-select -p > /dev/null; then
        xcode-select --install
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew analytics off
brew update --force # upgrade homebrew itself
ensure_installed_formulas
ensure_installed_casks
brew upgrade --greedy --greedy-latest --greedy-auto-updates --no-quarantine # upgrade the packages installed by homebrew
brew autoremove
brew cleanup --prune=all -s
brew doctor
tput -x clear
brew outdated --greedy --greedy-latest --greedy-auto-updates
brew missing
