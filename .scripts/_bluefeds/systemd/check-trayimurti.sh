#!/usr/bin/env bash

if [[ ${EUID} -ne 0 || ${UID} -ne 0 ]]; then
    echo "error: either you are not root, or EUID or UID is not 0"
    echo "error: exiting..."
    exit 1
fi

if ! lsmod | grep "zfs" &> /dev/null ; then
    sleep 10
fi

if [[ -f /sbin/zpool ]]; then
    if [[ ! -d /trayimurti/containers/volumes/caddy || ! -d /trayimurti/containers/volumes/nextcloud || ! -d /trayimurti/containers/volumes/gitea ]]; then
        /sbin/zpool import 9345246849197696133
    fi
fi
