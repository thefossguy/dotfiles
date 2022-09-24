#!/usr/bin/env bash

# set standby timeout to 5 minutes (60*5 seconds)
/usr/sbin/hdparm -S 60 /dev/sda
/usr/sbin/hdparm -S 60 /dev/sdb
/usr/sbin/hdparm -S 60 /dev/sdc
/usr/sbin/hdparm -S 60 /dev/sdd

/usr/bin/updatedb &
sleep 600s

# don't use $HOME, root is running this
/home/pratham/.scripts/_flameboi/hdd/notify_user.sh "critical" "Check HDDs" "Check if the HDDs are in standby ([re]boot-ed)" && exit 0
