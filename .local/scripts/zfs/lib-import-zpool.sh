#!/usr/bin/env bash

CALLER_SCRIPT_NAME=$1
ZPOOL_NAME=$2

if [[ ${EUID} -ne 0 || ${UID} -ne 0 ]]; then
    >&2 echo "${CALLER_SCRIPT_NAME}: ERROR: you are not the superuser"
    exit 1
fi

if [[ -z $1 || -z $2 ]]; then
    >&2 echo "${CALLER_SCRIPT_NAME}: ERROR: insufficient parameters provided"
    exit 1
fi

if [[ ! $(lsmod | grep "zfs" &> /dev/null) ]]; then
    sudo modprobe zfs || exit 1
fi

ZPOOL_STATUS=$(zpool status -v 2>&1)
if [[ ${ZPOOL_STATUS} == "no pools available" || ! ${ZPOOL_STATUS[@]} =~ "${ZPOOL_NAME}" ]]; then
    zpool import -f ${ZPOOL_NAME} &> /dev/null
    if [[ $? -ne 0 ]]; then
        >&2 echo "${CALLER_SCRIPT_NAME}: ERROR: unable to import zpool '${ZPOOL_NAME}', please recheck the name"
        exit 1
    fi
fi
