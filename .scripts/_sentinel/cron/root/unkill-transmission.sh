#!/usr/bin/env bash

transmission-daemon.service
CHECK_ENABLEMENT=$(systemctl --user is-enabled transmission-daemon.service)

# check if a service is enabled
# don't restart services that I manually disabled
if [[ "$CHECK_ENABLEMENT" == "enabled" ]]; then

    # check if a service is active or not
    CONTAINER_STAT=1
    systemctl --user is-active --quiet service transmission-daemon.service && CONTAINER_STAT=0

    # if container is not running
    # start it
    if [[ $CONTAINER_STAT -eq 1 ]]; then

        systemctl --user start transmission-daemon.service

    fi
else
    exit 1
fi
