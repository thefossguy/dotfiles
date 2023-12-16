#!/usr/bin/env dash

set -xeuf

if ! command -v rustup > /dev/null; then
    >&2 echo 'No rustup? What are you, a monster?'
    exit 1
fi

if pgrep --exact "rust-analyzer|cargo|rustc" > /dev/null; then
    >&2 echo 'You are probably using components that will be updated, even replaced...'
    >&2 echo 'Not continuing'
    exit 1
fi

rustup default stable
rustup update stable
rustup component add rust-src rust-analysis rust-analyzer clippy

if [ ! -d "${HOME}/.config/fish/completions" ]; then
    mkdir -p "${HOME}/.config/fish/completions"
fi
rustup completions fish > "${HOME}/.config/fish/completions/rustup.fish"
