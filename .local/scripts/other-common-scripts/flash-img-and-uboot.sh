#!/usr/bin/env bash

set -euf -o pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo 'sudo !!'
    exit 1
fi

if [[ -z "${1:-}" ]]; then
    echo 'USAGE: <image> <uboot> <seek> <bs> <dev>'
fi

IMAGE="$1"
UBOOT="$2"
SEEK="$3"
BS="$4"
DEVICE="$5"

if [[ ! -f "${IMAGE}" ]]; then
    echo "file not found: ${IMAGE}"
    exit 1
fi

if [[  ! -f "${UBOOT}" ]]; then
    echo "file not found: ${UBOOT}"
    exit 1
fi

if [[ ! -b "${DEVICE}" ]]; then
    echo "device not found: ${DEVICE}"
    exit 1
fi

echo "dd conv=sync of=${DEVICE} bs=4M if=${IMAGE}"
echo "dd conv=sync of=${DEVICE} bs=${BS} seek=${SEEK} if=${UBOOT}"
echo 'press Ctrl-c if this is not okay'
set -x
read useless_variable
dd conv=sync of="${DEVICE}" bs=4M if="${IMAGE}"
dd conv=sync of="${DEVICE}" bs="${BS}" seek="${SEEK}" if="${UBOOT}"
hdparm -z "${DEVICE}"
sync; sync; sync; sync
