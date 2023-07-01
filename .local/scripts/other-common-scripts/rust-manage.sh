#!/usr/bin/env bash

rustup default stable
rustup update stable
rustup component add rust-src rust-analysis rust-analyzer clippy

if [[ ! -d "$HOME/.config/fish/completions" ]]; then
    mkdir -p "$HOME/.config/fish/completions"
fi
rustup completions fish > "$HOME/.config/fish/completions/rustup.fish"
