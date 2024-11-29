#!/usr/bin/env bash
set -xeuf -o pipefail

if ! ping -c 1 'gitlab.com' 1>/dev/null 2>&1; then
    if ! ping -c 2 'gitlab.com' 1>/dev/null 2>&1; then
        if ! ping -c 20 'gitlab.com' 1>/dev/null 2>&1; then
            # Exit early because the internet is unreachable
            exit 0
        fi
    fi
fi

DIRTY_REPO=$(git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" status --porcelain=v1 --ignored=no --untracked-files=no)
if [[ -n "${DIRTY_REPO}" ]]; then
    >&2 echo 'You have unsaved changes, not pulling.'
    exit 1
else
    git --git-dir="${HOME}/.dotfiles" --work-tree="${HOME}" pull
fi
