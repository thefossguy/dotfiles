#!/usr/bin/env dash

set -xeu

rpm2cpio "$1" | cpio -idmv
