#!/usr/bin/env bash
set -xeuf -o pipefail

if [[ "$(virsh domstate "${1}")" == 'running' ]]; then
    virsh destroy "${1}"
fi
virsh undefine --nvram --remove-all-storage "${1}"
