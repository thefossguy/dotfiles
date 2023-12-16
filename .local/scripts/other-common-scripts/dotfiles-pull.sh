#!/usr/bin/env dash

set -xeuf

DIRTY_REPO=$(git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" status --porcelain=v1 --ignored=no --untracked-files=no)
if [ -n "${DIRTY_REPO}" ]; then
    >&2 echo 'You have unsaved changes, not pulling.'
    exit 1
else
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" pull
fi
