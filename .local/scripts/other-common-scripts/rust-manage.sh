#!/usr/bin/env dash

set -xeuf

RUSTUP_BIN="${1:-$(command -v rustup)}"
if [ -z "${RUSTUP_BIN}" ]; then
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

${RUSTUP_BIN} default stable
${RUSTUP_BIN} update stable
${RUSTUP_BIN} component add rust-src rust-analysis rust-analyzer clippy

if echo "${SHELL}" | grep 'bash' > /dev/null; then
    mkdir -p "${HOME}/.local/share/bash-completion/completions"
    ${RUSTUP_BIN} completions bash > "${HOME}/.local/share/bash-completion/completions/rustup"
    ${RUSTUP_BIN} completions bash cargo > "${HOME}/.local/share/bash-completion/completions/cargo"
elif echo "${SHELL}" | grep 'fish' > /dev/null; then
    mkdir -p "${HOME}/.config/fish/completions"
    ${RUSTUP_BIN} completions fish > "${HOME}/.config/fish/completions/rustup.fish"
    ${RUSTUP_BIN} completions fish cargo > "${HOME}/.config/fish/completions/cargo.fish"
fi
