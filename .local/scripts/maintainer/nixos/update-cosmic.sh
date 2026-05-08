#!/usr/bin/env bash
set -xeuf -o pipefail

nix-shell maintainers/scripts/update.nix \
    --argstr commit true \
    --argstr keep-going true \
    --argstr max-workers 50 \
    --argstr skip-prompt true \
    --arg predicate '(path: pkg: builtins.any (t: t.shortName or "" == "COSMIC") (pkg.meta.teams or []))' \
    #EOF
