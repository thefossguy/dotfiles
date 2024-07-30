#!/usr/bin/env bash

KWALLET_FLAG_FILE="${XDG_RUNTIME_DIR}/${USER}/tmp/.kde_wallet_init_done"
if [[ -x "${NIXOS_PAM_KWALLET_INIT_FILE:-}" ]] && [[ ! -f "${KWALLET_FLAG_FILE}" ]]; then
    mkdir -p "$(dirname "${KWALLET_FLAG_FILE}")"
    $NIXOS_PAM_KWALLET_INIT_FILE
    touch "${KWALLET_FLAG_FILE}"
fi
