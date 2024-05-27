#!/usr/bin/env bash

set -xeuf -o pipefail

chvt 7
DISPLAY=:0 import -window root "$HOME/$(date).png"
chvt 1
