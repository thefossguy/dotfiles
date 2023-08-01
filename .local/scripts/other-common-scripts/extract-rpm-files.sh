#!/usr/bin/env dash

rpm2cpio "$1" | cpio -idmv
