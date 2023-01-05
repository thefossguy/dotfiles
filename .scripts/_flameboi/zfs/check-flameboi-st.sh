#!/usr/bin/env bash

if [[ ${EUID} -ne 0 || ${UID} -ne 0 ]]; then
    echo "error: either you are not root, or EUID or UID is not 0"
    echo "error: exiting..."
    exit 1
fi

if ! lsmod | grep "zfs" &> /dev/null ; then
    sleep 10
fi

if [[ -f /bin/zpool ]]; then
    if [[ ! -d /flameboi_st/Downloads || ! -d /flameboi_st/_home || ! -d /flameboi_st/vm-store ]]; then
        /bin/zpool import 16601987433518749526
    fi
fi
