#!/usr/bin/env nix-shell
#! nix-shell -i bash --packages bash qemu_kvm util-linux

set -xef -o pipefail

# $1: host port for SSH
# $2: disk image
# $3: ISO

if [ ! -c '/dev/kvm' ]; then
    echo 'ERROR: /dev/kvm does not exist, no KVM accel'
    exit 1
else
    if ! groups | grep kvm > /dev/null; then
        # shellcheck disable=SC2016
        echo 'ERROR: sudo usermod -aG kvm $USER'
        exit 1
    fi
fi

if [ -z "$1" ]; then
    echo "ERROR: expecting a binding port for SSH"
    exit 1
fi


if [ -z "$2" ]; then
    echo "ERROR: expecting a disk image"
    exit 1
fi

HOST_PORT="$1"
HDA="$2"
CDR="$3"

if [ "$(uname -m)" == 'aarch64' ]; then
    [[ -d "${HOME}/.vms" ]] || mkdir "${HOME}/.vms"
    BIOS="${HOME}/.vms/result/u-boot.bin"
    if [[ ! -f "${BIOS}" ]]; then
        pushd "${HOME}/.vms"
        nix build 'nixpkgs#ubootQemuAarch64'
        popd
    fi
    QEMU_MACHINE='virt'
    BIOS="-bios ${HOME}/.vms/result/u-boot.bin"
elif [ "$(uname -m)" == 'x86_64' ]; then
    QEMU_MACHINE='pc'
    BIOS="-drive file=${HOME}/.local/share/edk2/EDKII_CODE,if=pflash,format=raw,unit=0,readonly=on \
          -drive file=${HOME}/.local/share/edk2/EDKII_VARS,if=pflash,format=raw,unit=1"
fi

#taskset --all-tasks --cpu-list 4-7 <CMD>
#-drive file=/home/pratham/veeams/nvme0n1.img,if=none,id=nvme0n1 -device nvme,serial=deadbeea,drive=nvme0n1
QEMU_COMMON="qemu-kvm \
    -machine ${QEMU_MACHINE} \
    -cpu host \
    -smp 8 \
    -accel kvm \
    -m 4096 \
    ${BIOS} \
    -nographic \
    -sandbox on \
    -netdev user,id=mynet0,hostfwd=tcp::${HOST_PORT}-:22 \
    -device virtio-net-pci,netdev=mynet0"

if [ -z "${CDR}" ]; then
    ${QEMU_COMMON} \
        -hda "${HDA}"
else
    ${QEMU_COMMON} \
        -cdrom "${CDR}" \
        -hda "${HDA}"
fi
