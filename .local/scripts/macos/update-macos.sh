#!/usr/bin/env bash

function ensure_installed_formulas() {
    brew install --formula \
        aria2 \
        bash \
        bat \
        btop \
        choose-rust \
        coreutils \
        curl \
        dash \
        dog \
        fd \
        ffmpeg \
        fish \
        fisher \
        fzf \
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
        thunderbird \
        tor-browser \
        utm \
        whatsapp \
        #EOL
}

function ensure_installed_fish_plugins() {
    fish -c "fisher install \
        acomagu/fish-async-prompt \
        jethrokuan/z \
        jethrokuan/fzf \
        meaningful-ooo/sponge \
        nickeb96/puffer-fish \
        PatrickF1/colored_man_pages.fish \
        #EOF"
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

if [[ ! -f $HOME/.config/fish/functions/fisher.fish ]]; then
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fi

if ! command -v rustup > /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
        -y \
        --quiet \
        --profile default
fi

brew analytics off
brew update --force # upgrade homebrew itself
ensure_installed_formulas
ensure_installed_casks
ensure_installed_fish_plugins
bash "$HOME/.local/scripts/other-common-scripts/rust-manage.sh"
fish -c "fisher update"
brew upgrade --greedy --greedy-latest --greedy-auto-updates --no-quarantine # upgrade the packages installed by homebrew
brew autoremove
brew cleanup --prune=all -s
brew doctor
/usr/local/Cellar/ncurses/*/bin/tput -x clear
brew outdated --greedy --greedy-latest --greedy-auto-updates
brew missing
