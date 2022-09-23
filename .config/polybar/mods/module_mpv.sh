#!/usr/bin/env bash

if [[ $(pidof mpv) ]]; then
	POS=$(echo '{ "command": ["get_property_string", "time-pos"] }' | socat - /tmp/mpvsocket | jq .data | tr '"' ' ' | cut -d'.' -f 1)
	DUR=$(echo '{ "command": ["get_property_string", "duration"] }' | socat - /tmp/mpvsocket | jq .data | tr '"' ' ' | cut -d'.' -f 1)
	METADATA=$(echo '{ "command": ["get_property", "media-title"] }' | socat - /tmp/mpvsocket | awk -F "\"*,\"*" '{print $1}' | awk -F "\"*:\"*" '{print $2}' )

	printf "$METADATA"
	printf ' (%d:%02d:%02d' $(($POS/3600)) $(($POS%3600/60)) $(($POS%60))
	printf ' / %d:%02d:%02d)\n' $(($DUR/3600)) $(($DUR%3600/60)) $(($DUR%60))

else
	exit
fi
