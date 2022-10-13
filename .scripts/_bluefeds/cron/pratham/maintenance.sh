#!/usr/bin/env bash

CUSTOM_LOGFILE=$HOME/.log/cron/pratham/log

if [[ -f /usr/sbin/zpool ]]; then
    if [[ ! -d /trayimurti/containers &&
        ! -d /trayimurti/sanaatana-dharma &&
        ! -d /trayimurti/torrents &&
        ! -d /trayimurti/containers/volumes ]]; then

            CURR_DATE=$(date +'(UTC%:::z) %Y/%m/%d %H:%M:%S')
            MAILCONTENT=$HOME/.scripts/_bluefeds/mail/containers/missing_zpool.mailcontents

            echo "$CURR_DATE: \"missing_zpool\"" >> $CUSTOM_LOGFILE

            # send e-mail about the service that was restarted
            /usr/sbin/ssmtp thefirst1322@gmail.com < $MAILCONTENT

            # since the zool which has container volumes is not mounted, exit
            exit 1
    fi
fi

# systemd services for each of my podman container
CONTAINER_SERVICES=(
    "container-gitea-chitragupta.service" \
    "container-gitea-govinda.service" \
    "container-hugo-vaikunthnatham.service" \
    "container-hugo-mahayogi.service" \
    "container-nextcloud-chitragupta.service" \
    "container-nextcloud-govinda.service" \
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

                if [[ "$INDV_SERVICE" == "container-nextcloud-chitragupta.service" ]]; then

                    systemctl --user start "$INDV_SERVICE" && systemctl --user restart container-nextcloud-govinda.service && echo "$CURR_DATE: \"$INDV_SERVICE\"" >> $CUSTOM_LOGFILE
                elif "$INDV_SERVICE" == "container-gitea-chitragupta.service" ]]; then

                    systemctl --user start "$INDV_SERVICE" && systemctl --user restart container-gitea-govinda.service && echo "$CURR_DATE: \"$INDV_SERVICE\"" >> $CUSTOM_LOGFILE
                else

                    # restart $INDV_SERVICE _AND_ container-caddy-vishwambhar.service
                    systemctl --user start "$INDV_SERVICE" && systemctl --user restart container-caddy-vishwambhar.service && echo "$CURR_DATE: \"$INDV_SERVICE\"" >> $CUSTOM_LOGFILE
                fi

                # send e-mail about the service that was restarted
                /usr/sbin/ssmtp thefirst1322@gmail.com < $MAILCONTENT
            fi
        fi
    done
fi
