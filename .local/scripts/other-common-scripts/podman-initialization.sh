#!/usr/bin/env dash

CONTAINER_MOUNT_MASTER='/trayimurti/containers/volumes'
PODMAN_SECRETS="${HOME}/.local/share/containers/storage/secrets/secrets.json"
PODMAN_NETWORKS_PATH="${HOME}/.local/share/containers/storage/networks/containers_default.json"
TIME_TAKEN=0

while [ ! -d "${CONTAINER_MOUNT_MASTER}" ]; do
    >&2 echo "$0: directory ${CONTAINER_MOUNT_MASTER} is not mounted (${TIME_TAKEN})"
    sleep 1s
    TIME_TAKEN=$((TIME_TAKEN + 1))

    if [ "${TIME_TAKEN}" -gt 120 ]; then
        >&2 echo "$0: directory ${CONTAINER_MOUNT_MASTER} is not mounted"
        >&2 echo "$0: exiting due to previous error..."
        exit 1
    fi
done

if ! grep -q 'nextcloud_database_user_password' "${PODMAN_SECRETS}"; then
    >&2 echo "$0: secret 'nextcloud_database_user_password' is absent"
    echo "use this command: 'openssl rand -base64 20 | podman secret create nextcloud_database_user_password -'"
    exit 1
fi


if ! grep -q 'gitea_database_user_password' "${PODMAN_SECRETS}"; then
    >&2 echo "$0: secret 'gitea_database_user_password' is absent"
    echo "use this command: 'openssl rand -base64 20 | podman secret create gitea_database_user_password -'"
    exit 1
fi

if [ ! -f "${PODMAN_NETWORKS_PATH}" ]; then
    >&2 echo "$0: network 'containers_default' is absent"
    echo "use this command: 'podman network create containers_default'"
    exit 1
fi

