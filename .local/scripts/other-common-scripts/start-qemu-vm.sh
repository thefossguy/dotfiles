#!/usr/bin/env nix-shell
#! nix-shell -i bash --packages bash qemu_kvm util-linux

set -xef -o pipefail

# $1: disk image
# $2: ISO

if [ -z "$1" ]; then
    echo "ERROR: expecting a disk image"
    exit 1
fi

[ -d "${HOME}/.vms" ] || mkdir "${HOME}/.vms"
if [ ! -f "${HOME}/.vms/result/u-boot.bin" ]; then
    if [ "$(uname -m)" == 'aarch64' ]; then
        NIX_UBOOT_ARCH='Aarch64'
    elif [ "$(uname -m)" == 'x86_64' ]; then
        NIX_UBOOT_ARCH='X86'
    fi
    NIX_UBOOT_PKG="nixpkgs#ubootQemu${NIX_UBOOT_ARCH}"
    pushd "${HOME}/.vms"
    nix build "${NIX_UBOOT_PKG}"
    popd
fi

QEMU_COMMON="--all-tasks --cpu-list 4-7 \
    qemu-kvm \
        -machine virt \
        -cpu host \
        -smp 4,sockets=1,cores=4,threads=1 \
        -accel kvm \
        -m 8192 \
        -nographic \
        -bios ${HOME}/.vms/result/u-boot.bin \
        -sandbox on \
        -netdev user,id=mynet0,hostfwd=tcp::6969-:22 \
        -device virtio-net-pci,netdev=mynet0"
if [ -z "$2" ]; then
    taskset \
        ${QEMU_COMMON} \
        -hda "$1"
else
    taskset \
        ${QEMU_COMMON} \
        -hda "$2" \
        -hdb "$1"
fi
