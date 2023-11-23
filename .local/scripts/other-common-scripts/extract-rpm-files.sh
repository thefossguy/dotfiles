#!/usr/bin/env dash

if [ -z "$1" ]; then
    echo "ERROR: provide [S]RPM path"
fi

rpm2cpio "$1" | cpio -idmv
