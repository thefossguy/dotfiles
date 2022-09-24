#!/usr/bin/env bash

CHK_DATE=$(date +'%Y/%m/%d')
LOG_FILE=$HOME/.log/cron/pratham/log

if [[ -f "$LOG_FILE" ]]; then
    echo "-----------"
    cat "$LOG_FILE" | grep "${CHK_DATE}" | grep --color=auto -E "container.*service"
    echo "-----------"
fi
