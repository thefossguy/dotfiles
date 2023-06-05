#!/usr/bin/env bash

if [[ ${EUID} -ne 0 || ${UID} -ne 0 ]]; then
    >&2 echo "$0: ERROR: you are not the superuser"
    exit 1
fi

if [[ -z $1 ]]; then
    >&2 echo "$0: ERROR: you need to specify at least one storage pool's name"
    exit 1
fi

ALL_POOLS=("$@")

for VIRSH_POOL in ${ALL_POOLS[@]}; do
    POOL_ACTIVE=false

    while [[ ${POOL_ACTIVE} == "false" ]]; do
        virsh pool-info "${VIRSH_POOL}" | grep "Stage: *running" > /dev/null

        if [[ $? -ne 0 ]]; then
            # pool is inactive
            systemctl restart libvirtd.service
        else
            # pool is active
            POOL_ACTIVE=true
        fi
    done
done
