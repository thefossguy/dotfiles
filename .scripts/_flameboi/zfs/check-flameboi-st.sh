#!/usr/bin/env bash

if [[ ${EUID} -ne 0 || ${UID} -ne 0 ]]; then
    echo "error: either you are not root, or EUID or UID is not 0"
    echo "error: exiting..."
    exit 1
fi

if [[ -f /usr/sbin/zpool ]]; then
    if [[ ! -d /flameboi_st ]]; then
        /usr/sbin/zpool import 16601987433518749526
    fi
fi
