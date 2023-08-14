#!/usr/bin/env nix-shell
#! nix-shell -i bash --packages bash choose coreutils curl findutils git gnugrep openssl podman

set -x

ZPOOL_MOUNT_PATH='/trayimurti/torrents'
PODMAN_SECRETS="${HOME}/.local/share/containers/storage/secrets/secrets.json"
PODMAN_NETWORKS_PATH="${HOME}/.local/share/containers/storage/networks/containers_default.json"
CONTAINER_VOLUME_PATH="${HOME}/container-data/volumes"
TIME_TAKEN=0

systemctl --user enable podman-restart.service

# pull images
podman pull \
    docker.io/gitea/gitea:latest-rootless \
    docker.io/klakegg/hugo:ext-debian \
    docker.io/library/caddy:latest \
    docker.io/library/postgres:15-bookworm \
    docker.io/louislam/uptime-kuma:debian \
    lscr.io/linuxserver/transmission:latest \
    || exit 1

# prune old images
podman images | grep '<none>' | choose 2 | xargs --max-lines=1 podman rmi

# setup secrets and network
if ! grep -q 'nextcloud_database_user_password' "${PODMAN_SECRETS}"; then
    openssl rand -base64 20 | podman secret create nextcloud_database_user_password - || exit 1
fi
if ! grep -q 'gitea_database_user_password' "${PODMAN_SECRETS}"; then
    openssl rand -base64 20 | podman secret create gitea_database_user_password - || exit 1
fi
if [ ! -f "${PODMAN_NETWORKS_PATH}" ]; then
    podman network create containers_default || exit 1
fi

# setup podman volumes
mkdir -vp "${CONTAINER_VOLUME_PATH}/uptimekuma"
mkdir -vp ${CONTAINER_VOLUME_PATH}/gitea/{database,ssh,web}
mkdir -vp ${CONTAINER_VOLUME_PATH}/caddy/{caddy_{data,config},site,ssl/{private,certs}}
chmod 700 "${CONTAINER_VOLUME_PATH}/caddy/ssl/private"
if [ ! -d "${CONTAINER_VOLUME_PATH}/blog" ]; then
    git clone --recursive https://gitlab.com/thefossguy/blog "${CONTAINER_VOLUME_PATH}/blog" || exit 1
fi
if [ ! -d "${CONTAINER_VOLUME_PATH}/mach" ]; then
    git clone --recursive https://gitlab.com/thefossguy/machines "${CONTAINER_VOLUME_PATH}/mach" || exit 1
fi
if [ ! -f "${CONTAINER_VOLUME_PATH}/caddy/Caddyfile" ]; then
    curl "https://gitlab.com/thefossguy/my-caddy-config/-/raw/master/Caddyfile" --output "${CONTAINER_VOLUME_PATH}/caddy/Caddyfile" || exit  1
fi
if [ ! -f "${CONTAINER_VOLUME_PATH}/caddy/ssl/private/key.pem" ] || [ ! -f "${CONTAINER_VOLUME_PATH}/caddy/ssl/certs/certificate.pem" ]; then
    >&2 echo "$0: Cloudflare certificates not found"
    >&2 echo "$0: fill: ${CONTAINER_VOLUME_PATH}/caddy/ssl/private/key.pem"
    >&2 echo "$0: fill: ${CONTAINER_VOLUME_PATH}/caddy/ssl/certs/certificate.pem"
    exit 1
else
    chmod 700 "${CONTAINER_VOLUME_PATH}/caddy/ssl/private"
    chmod 600 "${CONTAINER_VOLUME_PATH}/caddy/ssl/private/key.pem"
fi

# finally, at the end, wait for the ZFS pool to be mounted
while [ ! -d "${ZPOOL_MOUNT_PATH}" ]; do
    >&2 echo "$0: directory ${ZPOOL_MOUNT_PATH} is not mounted (${TIME_TAKEN})"
    sleep 1s
    TIME_TAKEN=$((TIME_TAKEN + 1))

    if [ "${TIME_TAKEN}" -gt 120 ]; then
        >&2 echo "$0: directory ${ZPOOL_MOUNT_PATH} is not mounted"
        >&2 echo "$0: exiting due to previous error..."
        exit 1
    fi
done
