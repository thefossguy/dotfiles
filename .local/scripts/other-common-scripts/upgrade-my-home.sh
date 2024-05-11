#!/usr/bin/env bash

set -xeuf -o pipefail

hm_config_dir="${HOME}/.prathams-nixos"
if [[ ! -d "${hm_config_dir}" ]]; then
    git clone https://gitlab.com/thefossguy/prathams-nixos "${hm_config_dir}"
fi

pushd "${hm_config_dir}"
git restore flake.lock
git pull
nix flake update
home-manager -v --show-trace --print-build-logs --flake . switch
home-manager expire-generations '-1 days'
popd
