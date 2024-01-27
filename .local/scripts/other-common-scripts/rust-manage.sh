#!/usr/bin/env dash

set -xeuf

if ! command -v rustup > /dev/null; then
    >&2 echo 'No rustup? What are you, a monster?'
    exit 1
fi

if [ "$(uname -s)" = 'Linux' ]; then
    if pgrep --exact "rust-analyzer|cargo|rustc" > /dev/null; then
        >&2 echo 'You are probably using components that will be updated, even replaced...'
        >&2 echo 'Not continuing'
        exit 1
    fi
fi

rustup default stable
rustup update stable
rustup component add rust-src rust-analysis rust-analyzer clippy

if echo "${SHELL}" | grep 'bash' > /dev/null; then
    mkdir -p "${HOME}/.local/share/bash-completion/completions"
    rustup completions bash > "${HOME}/.local/share/bash-completion/completions/rustup"
    rustup completions bash cargo > "${HOME}/.local/share/bash-completion/completions/cargo"
elif echo "${SHELL}" | grep 'fish' > /dev/null; then
    mkdir -p "${HOME}/.config/fish/completions"
    rustup completions fish > "${HOME}/.config/fish/completions/rustup.fish"
    rustup completions fish cargo > "${HOME}/.config/fish/completions/cargo.fish"
fi
