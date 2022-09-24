#!/usr/bin/env bash

MY_IP_ADDR=$(hostname -I | awk '{print $1}')
dig +time=2 +tries=1 +noall example.com @${MY_IP_ADDR}

if [[ $? -ne 0 ]]; then
    /usr/local/bin/pihole restartdns
fi
