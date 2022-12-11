#!/usr/bin/env bash

MY_DOMAINS=( \
    "blog.thefossguy.com" \
    "git.thefossguy.com" \
    "mach.thefossguy.com" \
    "cloud.thefossguy.com" \
    "admin.thefossguy.com" \
    "notify.thefossguy.com" \
    "torr.thefossguy.com" \
)

for DOMAIN in ${MY_DOMAINS[@]}; do
    echo "################################################################################"
    echo "For domain $DOMAIN:"
    openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" | openssl x509 -noout -dates
done
