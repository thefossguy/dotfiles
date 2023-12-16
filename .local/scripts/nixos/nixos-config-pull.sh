#!/usr/bin/env dash

set -xeuf

cd /home/pratham/my-git-repos/pratham/prathams-nixos
DIRTY_REPO=$(git status --porcelain=v1 --ignored=no --untracked-files=no)
if [ -n "${DIRTY_REPO}" ]; then
    >&2 echo 'You have unsaved changes, not pulling.'
    exit 1
else
    git pull
fi
