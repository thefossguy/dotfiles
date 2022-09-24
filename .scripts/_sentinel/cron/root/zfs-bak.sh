#!/usr/bin/env bash

DATE=$(date +"%Y_%m_%d__%H_%M_%S");
/usr/sbin/zfs snapshot libertine/container-vols/test@$DATE
