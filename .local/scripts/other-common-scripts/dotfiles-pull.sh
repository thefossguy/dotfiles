#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash git openssh

set -xeu

DIRTY_REPO=$(git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" status --porcelain=v1 --ignored=no --untracked-files=no)
if [ -n "${DIRTY_REPO}" ]; then
    >&2 echo "$0: You have unsaved changes, not pulling..."
    exit 1
fi
git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" pull
