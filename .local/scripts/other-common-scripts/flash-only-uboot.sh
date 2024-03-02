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

${DD_COMMON} bs=1M count=64 of="${DEVICE}" if=/dev/urandom
sync
${DD_COMMON} bs=1M count=64 of="${DEVICE}" if=/dev/zero
sync

if [[ -n "${3:-}" ]]; then
    ${DD_COMMON} bs=512 seek=64 of="${DEVICE}" if="${UBOOT}"
else
    ${DD_COMMON} bs="$3" seek="$4" of="${DEVICE}" if="${UBOOT}"
fi
sync
