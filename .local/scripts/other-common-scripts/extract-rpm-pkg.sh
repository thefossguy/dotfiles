#!/usr/bin/env bash

set -xeu
PATH="$HOME/.local/$USER/bin:$PATH"

rpm2cpio "$1" | cpio -idm
