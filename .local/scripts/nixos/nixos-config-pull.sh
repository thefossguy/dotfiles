#!/usr/bin/env nix-shell
#!nix-shell -i dash --packages dash git openssh

set -xeuf -o pipefail

GIT_REPO_LOCAL_PATH="${HOME}/my-git-repos/pratham/prathams-nixos/"
cd "${GIT_REPO_LOCAL_PATH}"
DIRTY_REPO=$(git status --porcelain=v1 --ignored=no --untracked-files=no)
if [ -n "${DIRTY_REPO}" ]; then
    >&2 echo "$0: You have unsaved changes, not pulling..."
    exit 1
fi
git pull
