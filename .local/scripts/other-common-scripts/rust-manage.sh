#!/usr/bin/env bash

set -xeuf -o pipefail

RUSTUP_BIN="${1:-$(command -v rustup)}"
COMPLETIONS_DIR="${HOME}/.local/share/bash-completion/completions"

if [[ -z "${RUSTUP_BIN}" ]]; then
    echo 'No rustup? What are you, a monster?'
    exit 1
fi

if [[ "$(uname -s)" == 'Linux' ]]; then
    if pgrep --exact "rust-analyzer|cargo|rustc" > /dev/null; then
        echo 'You are probably using components that will be updated, even replaced...'
        echo 'Not continuing.'
        exit 1
    fi
fi

${RUSTUP_BIN} default stable
${RUSTUP_BIN} update stable
${RUSTUP_BIN} component add rust-src rust-analysis rust-analyzer clippy
mkdir -p "${COMPLETIONS_DIR}"
${RUSTUP_BIN} completions bash rustup > "${COMPLETIONS_DIR}/rustup"
${RUSTUP_BIN} completions bash cargo  > "${COMPLETIONS_DIR}/cargo"
