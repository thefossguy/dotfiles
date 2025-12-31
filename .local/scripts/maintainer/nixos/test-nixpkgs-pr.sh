#!/usr/bin/env bash
set -xeuf -o pipefail

# shellcheck disable=SC2086
nixpkgs-review pr --print-result --eval local ${EXTRA_ARGS:-} "${1}"
