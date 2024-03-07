#!/usr/bin/env bash

set -xeuf -o pipefail

DEVICE="$1"
UBOOT="$2"
DD_COMMON='dd conv=sync status=progress'

if [[ "${EUID}" != '0' ]]; then
    echo 'Run as root'
    exit 1
fi

if [[  ! -f "${UBOOT}" ]]; then
    echo "file not found: ${UBOOT}"
    exit 2
fi

if [[ ! -b "${DEVICE}" ]]; then
    echo "device not found: ${DEVICE}"
    exit 3
fi

if [[ -z "${3:-}" ]]; then
    FLASH_CMD="${DD_COMMON} of=${DEVICE} if=${UBOOT}"
else
    FLASH_CMD="${DD_COMMON} bs=$3 seek=$4 of=${DEVICE} if=${UBOOT}"
fi

echo 'Following command will be executed, is that okay?'
echo -e "\n${FLASH_CMD}\n"
# shellcheck disable=SC2034
read -r WAIT_INFINITELY


${DD_COMMON} bs=1M count=64 of="${DEVICE}" if=/dev/urandom
${DD_COMMON} bs=1M count=64 of="${DEVICE}" if=/dev/zero
sync
${DD_COMMON} bs=1M count=64 of="${DEVICE}" if=/dev/urandom
${DD_COMMON} bs=1M count=64 of="${DEVICE}" if=/dev/zero
sync
${FLASH_CMD}
sync
