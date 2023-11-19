#!/usr/bin/env bash

set -x

if (! command -v mock > /dev/null) || (! groups | grep 'mock' > /dev/null); then
    # shellcheck disable=SC2088
    echo '~/.local/scripts/el/rhel-setup.sh'
    exit 1
fi

if [[ -z $1 ]]; then
    echo "Need a SOURCES directory."
    exit 1
fi

if [[ -z $2 ]]; then
    echo "Need an RPM SPEC file."
    exit 1
fi

# shellcheck disable=SC1090
source <(grep ID /etc/os-release)
MARCH="$(uname -m)"
DNF_RELEASEVER="$(dnf config-manager --dump-variables | grep 'releasever' | awk '{print $3}')"
MOCK_ROOT="$ID-$DNF_RELEASEVER-$MARCH"
MOCK_OUT="$HOME/mockbuild/out"
MOCK_COMMON="
    --verbose \
    --isolation nspawn \
    --root $MOCK_ROOT \
    --resultdir $MOCK_OUT \
    --sources $1 "

if [[ ! -d "/var/lib/mock/$MOCK_ROOT" ]]; then
    mock --root "$MOCK_ROOT" --init
fi

# shellcheck disable=SC2086
# $MOCK_COMMON **must not** be in quotes
# it **needs** to be expanded for the command expansion "magic" to work
mock $MOCK_COMMON \
    --buildsrpm \
    --spec $2

# shellcheck disable=SC2086
mock $MOCK_COMMON --no-cleanup-after $MOCK_OUT/*.src.rpm
