#!/usr/bin/env bash

POOL_NAME='flameboi_st'
USER_HOME='/home/pratham'

bash "$USER_HOME/.local/scripts/zfs/lib-import-zpool.sh" "$0" "${POOL_NAME}"