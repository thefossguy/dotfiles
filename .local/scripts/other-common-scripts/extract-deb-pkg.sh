#!/usr/bin/env dash

if [ -z "$1" ]; then
    echo "ERROR: provide .deb file's path"
fi

ar x "$1"
tar xf data.tar.xz
