#!/usr/bin/env bash
set -xeuf -o pipefail

reset
# shellcheck disable=SC2086
nixpkgs-review pr --print-result --eval local --build-graph nix ${EXTRA_ARGS:-} "${1}"
