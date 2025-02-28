#!/usr/bin/env bash
set -xeuf -o pipefail

VM_BRIDGE="${VM_BRIDGE:-virbr0}"
if grep -q "${VM_BRIDGE}" /proc/net/dev; then
    VIRT_BRIDGE_ARG="--network bridge=${VM_BRIDGE},mac=52:54:00:00:00:${MAC_ADDR}"
fi

if [[ "${VM_GRAPHICS}" -eq 1 ]]; then
    VIRT_GRAPHCIS_ARGS='spice'
else
    VIRT_GRAPHCIS_ARGS='none'
fi

if [[ -n "${VM_CDROM:-}" ]]; then
    VIRT_DISK_ARGS="--cdrom ${VM_CDROM} \
        --disk size=${VM_SIZE:-64}"
else
    VIRT_DISK_ARGS="--disk ${VM_DISK},bus=${VM_DISK_BUS:-virtio},format=${VM_DISK_FORMAT:-qcow2} \
        --import"
fi

if [[ -z "${VM_OSVARIANT:-}" ]]; then
    virt-install --osinfo list
    # shellcheck disable=SC2016
    echo 'Please provide $VM_OSVARIANT'
    exit 1
fi

if [[ "${VM_AUTOSTART:-0}" -eq 1 ]]; then
    VIRT_AUTOSTART_ARGS='--autostart'
fi

# shellcheck disable=SC2086
virt-install --connect qemu:///session \
    --name "${VM_NAME}" \
    --memory "${VM_MEM:-2048}" \
    --vcpus "${VM_CPUS:-${VM_VCPUS:-2}}" \
    ${VIRT_DISK_ARGS:-} \
    --os-variant "${VM_OSVARIANT}" \
    ${VIRT_BRIDGE_ARG:-} \
    --graphics ${VIRT_GRAPHCIS_ARGS} \
    --virt-type kvm \
    ${VIRT_AUTOSTART_ARGS:-} \
    --boot uefi \
    --boot firmware=efi,firmware.feature0.enabled=no,firmware.feature0.name=secure-boot \
    "$@"
