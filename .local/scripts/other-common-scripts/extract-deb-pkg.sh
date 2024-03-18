#!/usr/bin/env bash

set -xeu
PATH="$HOME/.local/$USER/bin:$PATH"

ar x "$1"
tar xf data.tar.xz
