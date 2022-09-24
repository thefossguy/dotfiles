#!/usr/bin/env bash

ORIGDIR="/var/lib/transmission-daemon/.config/transmission-daemon/torrents"
CONFDIR="/libertine/config_dir"
TORRDIR="/libertine/torrents"

rsync --size-only $ORIGDIR/*.* $CONFDIR/
chmod 664 $CONFDIR/*.*
chown ubuntu:ubuntu -v $CONFDIR/*.*
sleep 5

chmod 775 -R $TORRDIR
chown ubuntu:debian-transmission -R $TORRDIR
find $TORRDIR -type f -exec chmod 664 {} \;
find $TORRDIR -type f -name "*.DS_Store" -exec rm {} \;
sleep 5

updatedb
