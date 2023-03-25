#!/usr/bin/env bash

ALL_OK=false
ALL_VIRT_POOLS=("default" "ISOs")

for POOL in "${ALL_VIRT_POOLS[@]}"; do
    POOL_OK=false

    while [[ "$POOL_OK" == "false" ]]; do
        virsh pool-info --pool "$POOL" | grep "State: *running" > /dev/null

        if [[ $? -ne 0 ]]; then
            echo "$POOL: not running"
            systemctl restart libvirtd && POOL_OK=true
        else
            echo "$POOL: OK"
            POOL_OK=true
        fi
    done
done
