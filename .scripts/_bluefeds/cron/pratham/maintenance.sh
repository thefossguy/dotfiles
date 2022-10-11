#!/usr/bin/env bash

# systemd services for each of my podman container
CONTAINER_SERVICES=(
    "container-nextcloud-govinda.service" \
    "container-gitea-govinda.service" \
    "container-gitea-chitragupta.service" \
    "container-nextcloud-chitragupta.service" \
    "container-hugo-mahayogi.service" \
    "container-hugo-vaikunthnatham.service" \
    "container-caddy-vishwambhar.service" \
)

# calculate uptime in MINUTES
SECONDS_SINCE=$(date --date "$(uptime -s)" +%s)
SECONDS_NOW=$(date +%s)
SECONDS_DIFF=$((SECONDS_NOW - SECONDS_SINCE))
UPTIME_MINUTES=$((SECONDS_DIFF / 60))
UPTIME_CMP=20

# Nextcloud takes time to start
# So don't immediately restart services (and send e-mail)
# until the uptime is greater than 20 minutes
if [[ "$UPTIME_MINUTES" -gt "$UPTIME_CMP" ]]; then

    # loop through all services in $CONTAINER_SERVICES
    for INDV_SERVICE in ${CONTAINER_SERVICES[@]}; do

        CHECK_ENABLEMENT=$(systemctl --user is-enabled "$INDV_SERVICE")

        # check if a service is enabled
        # don't restart services that I manually disabled
        if [[ "$CHECK_ENABLEMENT" == "enabled" ]]; then

            # check if a service is active or not
            CONTAINER_STAT=1
            systemctl --user is-active --quiet service "$INDV_SERVICE" && CONTAINER_STAT=0

            # if container is not running
            # start it
            if [[ $CONTAINER_STAT -eq 1 ]]; then

                # pretty date format
                CURR_DATE=$(date +'(UTC%:::z) %Y/%m/%d %H:%M:%S')
                # what should be in the e-mail _IF_ the service is restarted?
                MAILCONTENT=$HOME/.scripts/_bluefeds/mail/containers/"$INDV_SERVICE".mailcontents

                # restart $INDV_SERVICE _AND_ container-caddy-vishwambhar.service
                systemctl --user start "$INDV_SERVICE" && systemctl --user restart container-caddy-vishwambhar.service && echo "$CURR_DATE: \"$INDV_SERVICE\"" >> $HOME/.log/cron/pratham/log

                # send e-mail about the service that was restarted
                /usr/sbin/ssmtp thefirst1322@gmail.com < $MAILCONTENT
            fi
        fi
    done
fi
