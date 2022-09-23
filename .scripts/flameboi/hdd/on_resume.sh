#!/usr/bin/env bash

/usr/bin/updatedb &
sleep 600s

/home/pratham/.scripts/flameboi/hdd/notify_user.sh "critical" "Check HDDs" "Check if the HDDs are in standby (resumed from suspend)" && exit 0
