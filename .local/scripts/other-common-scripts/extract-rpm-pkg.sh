#!/usr/bin/env bash

set -xeu

rpm2cpio "$1" | cpio -idm
