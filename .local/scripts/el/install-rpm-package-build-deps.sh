#!/usr/bin/env dash

set -xeuf
rpmbuild -ba "$1" 2>&1 | grep ' is needed by ' | awk '{ print $1 }' | xargs sudo dnf install "${2:-}"
