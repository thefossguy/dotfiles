#!/usr/bin/env bash

if [[ ${EUID} -ne 0 || ${UID} -ne 0 ]]; then
    echo "error: either you are not root, or EUID or UID is not 0"
    echo "error: exiting..."
    exit 1
fi

if [[ -f /usr/sbin/zpool ]]; then
    if [[ ! -d /trayimurti/containers &&
        ! -d /trayimurti/sanaatana-dharma &&
        ! -d /trayimurti/torrents &&
        ! -d /trayimurti/containers/volumes ]]; then
        /usr/sbin/zpool import 8797010937679026602
    fi
fi
