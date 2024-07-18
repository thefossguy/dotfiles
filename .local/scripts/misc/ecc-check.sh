#!/usr/bin/env bash

if ! grep -q -i debian /etc/os-release; then
    echo 'Not Debian-based, not running.'
    exit 1
fi

set -xeuf -o pipefail
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=true

sudo apt-get update
sudo apt-get install --assume-yes --no-install-recommends \
    dmidecode \
    lshw \
    rasdaemon \
    #EOF

echo '--------------------------------------------------------------------------------'
sudo dmesg | grep -i edac
echo '--------------------------------------------------------------------------------'
sudo dmidecode -t memory
echo '--------------------------------------------------------------------------------'
sudo lshw -class memory
echo '--------------------------------------------------------------------------------'
sudo systemctl start --now rasdaemon.service
sudo ras-mc-ctl --register-labels
sudo ras-mc-ctl --status
sudo ras-mc-ctl --layout
sudo ras-mc-ctl --summary
echo '--------------------------------------------------------------------------------'
