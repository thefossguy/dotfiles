#!/usr/bin/env bash

set -x

if (! command -v mock > /dev/null) || (! groups | grep 'mock' > /dev/null); then
    # shellcheck disable=SC2088
    echo 'run ~/.local/scripts/el/rhel-setup.sh to perform necessary setup'
    exit 1
fi

if [[ -z "${1:-}" ]]; then
    echo 'Need a SOURCES directory.'
    exit 1
fi
if [[ ! -d "$1" ]]; then
    echo "'$1' is not a directory"
    exit 1
fi

if [[ -z "${2:-}" ]]; then
    echo 'Need an RPM SPEC file.'
    exit 1
fi
if [[ ! -f "$2" ]]; then
    echo "'$2' is not a file"
    exit 1
fi

# shellcheck disable=SC1090
source <(grep ID /etc/os-release)
MARCH="$(uname -m)"
VERSION_ID="$(source <(grep VERSION_ID /etc/os-release) && awk -F '.' '{print $1}' <<< $VERSION_ID)"
MOCK_ROOT="$ID-$VERSION_ID-$MARCH"
MOCK_OUT="$HOME/mockbuild/out"

if [[ ! -d "/var/lib/mock/$MOCK_ROOT" ]]; then
    mock --root "$MOCK_ROOT" --init
fi

additional_args=( "$@" )
# shellcheck disable=SC2086
time mock \
    "${additional_args[@]:2}" \
    --isolation nspawn \
    --root "$MOCK_ROOT" \
    --resultdir "$MOCK_OUT" \
    --sources "$1" \
    --no-cleanup-after \
    --buildsrpm \
    --spec "$2" \
    --rebuild
