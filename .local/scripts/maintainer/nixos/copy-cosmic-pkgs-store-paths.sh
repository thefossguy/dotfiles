#!/usr/bin/env bash
set -xeuf -o pipefail

NIXPKGS_TARBALL_URL="https://github.com/nixos/nixpkgs/archive/${1}.tar.gz"
NIXPKGS_TARBALL_SHA256="$(nix-prefetch-url --type sha256 --unpack "${NIXPKGS_TARBALL_URL}" 2>/dev/null)"
if [[ -z "${NIXPKGS_TARBALL_URL}" ]]; then
    echo "Could not calculate the SHA256 hash for '${NIXPKGS_TARBALL_URL}'"
    exit 1
fi

NIXPKGS_PATH="$(nix eval --raw --expr "fetchTarball { url = \"${NIXPKGS_TARBALL_URL}\"; sha256 = \"${NIXPKGS_TARBALL_SHA256}\"; }" 2>/dev/null)"
if [[ -z "${NIXPKGS_PATH}" ]]; then
    echo "Failed to generate NIXPKGS_PATH for '${NIXPKGS_TARBALL_URL}'"
    exit 1
fi
if [[ ! -d "${NIXPKGS_PATH}" ]]; then
    echo "The path '${NIXPKGS_PATH}' does not exist"
    exit 1
fi
if [[ ! "${NIXPKGS_PATH}" =~ ^/nix/store/.*-source$ ]]; then
    echo "'${NIXPKGS_PATH}' does not seem to be valid"
    exit 1
fi

COSMIC_PATHS=$(nix eval --raw -I "nixpkgs=${NIXPKGS_PATH}" --file "${HOME}/.local/scripts/maintainer/nixos/get-cosmic-pkgs-store-paths.nix" 2>/dev/null)
if [[ -z "${COSMIC_PATHS}" ]]; then
    echo 'Failed to evaluate the outPaths of COSMIC packages'
    exit 1
fi

NIX_SYSTEM="$(nix eval --raw --impure --expr builtins.currentSystem)"
BUILD_SERVER=''
if [[ "${NIX_SYSTEM}" == 'x86_64-linux' ]]; then
    BUILD_SERVER='build-box.nix-community.org'
elif [[ "${NIX_SYSTEM}" == 'aarch64-linux' ]]; then
    BUILD_SERVER='aarch64-build-box.nix-community.org'
else
    echo 'Could not populate BUILD_SERVER'
fi

nix copy \
    --refresh \
    --no-check-sigs \
    --from "ssh-ng://thefossguy@${BUILD_SERVER}?ssh-key=/home/pratham/.ssh/ssh" \
    ${COSMIC_PATHS}
