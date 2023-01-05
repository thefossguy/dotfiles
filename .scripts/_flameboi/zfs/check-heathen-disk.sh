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
    if [[ ! -d heathen_disk/personal || ! -d heathen_disk/personal/backup ||  ! -d heathen_disk/work ]]; then
        /bin/zpool import 12327394492612946617
    fi
fi
