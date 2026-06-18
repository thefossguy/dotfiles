#!/usr/bin/env bash
set -xuf -o pipefail

if [[ "${TERM_PROGRAM:-}" != 'tmux' ]]; then
    exec tmux
fi

[[ -d "${HOME}/.dotfiles" ]] && rm -rf "${HOME}/.dotfiles"
git clone --bare https://codeberg.org/thefossguy/dotfiles.git "${HOME}/.dotfiles"
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" checkout -f

[[ -d "${HOME}/.prathams-nixos" ]] && rm -rf "${HOME}/.prathams-nixos"
git clone https://codeberg.org/thefossguy/prathams-nixos.git "${HOME}/.prathams-nixos"
if pushd "${HOME}/.prathams-nixos"; then
    ./scripts/home-manager/build-and-activate.sh
fi

mkdir -p "${HOME}/my-git-repos/nixos"
git clone https://github.com/thefossguy/nixpkgs.git "${HOME}/my-git-repos/nixos/nixpkgs"
