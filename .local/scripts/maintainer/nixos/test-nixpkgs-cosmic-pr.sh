#!/usr/bin/env bash
set -xeuf -o pipefail

# additional tests to run, should mirror upstream's tests for COSMIC
export EXTRA_ARGS='--additional-package nixosTests.cosmic --additional-package nixosTests.cosmic-autologin --additional-package nixosTests.cosmic-autologin-noxwayland --additional-package nixosTests.cosmic-noxwayland'

"${HOME}/.local/scripts/maintainer/nixos/test-nixpkgs-pr.sh" "${1}"
