#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    >&2 echo "fail: you are not root"
    exit 1
fi

systemctl restart gdm.service
