#!/usr/bin/env bash

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
OPENZFS_DIR=$HOME/openzfs
OPENZFS_TAG_VER=$(git ls-remote --refs --tags https://github.com/openzfs/zfs | cut --delimiter='/' --fields=3 | sort --version-sort | tail --lines=2 | head --lines=1)

if [[ ! -d $OPENZFS_DIR ]]; then
	mkdir -p $OPENZFS_DIR

	if [[ ! -d $OPENZFS_DIR/.git ]]; then
		git clone --depth 1 --branch $OPENZFS_TAG_VER https://github.com/openzfs/zfs $OPENZFS_DIR
		cd $OPENZFS_DIR/

	fi
fi

sudo dnf install autoconf automake dkms elfutils-libelf-devel gcc git kernel-devel-$(uname -r) kernel-rpm-macros libaio-devel libattr-devel libblkid-devel libcurl-devel libffi-devel libtirpc-devel libtool libudev-devel libuuid-devel make ncompress openssl-devel python3 python3-cffi python3-devel python3-packaging python3-setuptools rpm-build zlib-devel -y

cd $OPENZFS_DIR

sh autogen.sh

if [ $? -eq 0 ]; then
	./configure

	if [ $? -eq 0 ]; then
		make -j1 rpm-utils rpm-dkms

		if [ $? -eq 0 ]; then
			echo -ne "\n\n\nOpenZFS was compiled successfully.

			To install OpenZFS, run the following command:
			${BOLD}sudo yum localinstall *.$(uname -p).rpm *.noarch.rpm${NORMAL}

			Load ZFS:
			${BOLD}sudo modprobe zfs${NORMAL}

			Enable ZFS-related services:
			${BOLD}
			sudo systemctl enable --now zfs-import-cache.service zfs-import-scan.service zfs-mount.service zfs-share.service zfs.target zfs-zed.service
			${NORMAL}

			Recreate the ZFS cache file:
			${BOLD}zpool set cachefile=/etc/zfs/zpool.cache trayimurti${NORMAL}\n"

			fi
	fi
fi
