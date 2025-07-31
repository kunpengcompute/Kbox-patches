#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2020-2022. All rights reserved.
# File Name: create-package.sh
# Description: android镜像打tar包.
# Usage: create-package.sh
# ******************************************************************************** #

set -ex

system=$1
destdir=$PWD

if [ -z "$system" ]; then
    echo "Usage: $0 <system image>"
    exit 1
fi

workdir=$(mktemp -d)
rootfs=$workdir/rootfs

mkdir -p "$rootfs"

mkdir "$workdir"/system
sudo mount -o loop,ro "$system" "$workdir"/system
sudo cp -ar "$workdir"/system/* "$rootfs"/
sudo umount "$workdir"/system

sudo cp -ar "$rootfs"/system/apex/com.android.runtime "$rootfs"/apex/

# FIXME
sudo chmod +x "$rootfs"/kbox-init.sh

if [ -e android.tar ]; then
    DATE=$(date +%F_%R)
    SAVETO=android-old-$DATE.tar

    echo "#########################################################"
    echo "# WARNING: Old android.tar still exists.                 "
    echo "#          Moving it to $SAVETO.                         "
    echo "#########################################################"

    mv android.tar "$SAVETO"
fi

#sudo mksquashfs $rootfs $destdir/android.tar -comp xz -no-xattrs
cd "$rootfs"
sudo tar --numeric-owner -cf "$destdir"/android.tar ./
sudo chown "$USER":"$USER" "$destdir"/android.tar

cd "$destdir"
sudo rm -rf "$workdir"
