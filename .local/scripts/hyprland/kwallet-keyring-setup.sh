#!/usr/bin/env bash

# for some reason, the PAM_KWALLET5_LOGIN socket exist but doesn't work
# so re-execute the pam_kwallet_init file
if [[ -x "${NIXOS_PAM_KWALLET_INIT_FILE:-}" ]]; then
    $NIXOS_PAM_KWALLET_INIT_FILE
fi
