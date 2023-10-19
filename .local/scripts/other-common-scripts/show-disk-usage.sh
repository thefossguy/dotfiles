#!/usr/bin/env bash

set -euf -o pipefail

ROOT_DEVICE=$(mount | grep ' on / ' | awk '{print $1}')

if [[ ${ROOT_DEVICE} =~ "mmcblk" || ${ROOT_DEVICE} =~ "nvme" ]]; then
    ROOT_DEVICE=$(echo "${ROOT_DEVICE}" | rev | sed -r 's/^.{2}//' | rev)
elif [[ ${ROOT_DEVICE} =~ "vd" || ${ROOT_DEVICE} =~ "sd" ]]; then
    ROOT_DEVICE=$(echo "${ROOT_DEVICE}" | rev | sed -r 's/^.{1}//' | rev)
else
    >&2 echo "$0: device type unsupported"
    exit 1
fi

df -kh | head -n 1 && df -kh | grep "${ROOT_DEVICE}" | sort
