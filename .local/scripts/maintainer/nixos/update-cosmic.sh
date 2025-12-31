#!/usr/bin/env bash
set -xeuf -o pipefail

nix-shell maintainers/scripts/update.nix \
    --argstr commit true \
    --argstr keep-going true \
    --argstr max-workers 50 \
    --argstr skip-prompt true \
    --arg predicate '(path: pkg: let lib = import <nixpkgs/lib>; in lib.lists.elem lib.teams.cosmic (pkg.meta.teams or []))' \
    #EOF
