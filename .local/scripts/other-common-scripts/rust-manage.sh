#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash rustup

set -xeuf -o pipefail

if pgrep "rust-analyzer|cargo|rustc" > /dev/null; then
    >&2 echo "$0: You are probably using components that will be updated, even replaced..."
    >&2 echo "$0: Not continuing"
    exit 1
fi

rustup default stable
rustup update stable
rustup component add rust-src rust-analysis rust-analyzer clippy

if [ ! -d "${HOME}/.config/fish/completions" ]; then
    mkdir -p "${HOME}/.config/fish/completions"
fi
rustup completions fish > "${HOME}/.config/fish/completions/rustup.fish"
