#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2025-2025. All rights reserved.
# File Name: create-package_aosp15.sh
# Description: android镜像打tar包.
# Usage: create-package_aosp15.sh
# ******************************************************************************** #

system=$1
destdir=$PWD
RM_BINARY=$2

if [ -z "$system" ]; then
    echo "Usage: $0 <system image>"
    exit 1
fi

trap '[-n "${workdir}"] && rm -rf "${workdir}"' EXIT
local save_mask=$(umask)
umask 077
workdir=$(mktemp -d)
if [ $? -ne 0 ]
then
    umask "${save_mask}"
    exit 1
fi
umask "${save_mask}"

rootfs=$workdir/rootfs

mkdir -p "$rootfs"

mkdir "$workdir"/system
sudo mount -o loop,rw "$system" "$workdir"/system
sudo cp -ar "$workdir"/system/* "$rootfs"/
sudo umount "$workdir"/system

apexlist=($(ls "$rootfs"/system/apex | grep apex))

trap '[-n "${apexworkdir}"] && rm -rf "${apexworkdir}"' EXIT
local save_mask=$(umask)
umask 077
apexworkdir=$(mktemp -d)
if [ $? -ne 0 ]
then
    umask"${save_mask}"
    exit 1
fi
umask"${save_mask}"

for((i=0;i<${#apexlist[@]};i++)) do
    mkdir -p "$apexworkdir"/mnt
    sudo cp -anr "$rootfs"/system/apex/"${apexlist[$i]}" "$apexworkdir"
    basename=$(basename "${apexlist[$i]}" .apex)
    sudo unzip "$apexworkdir"/"${apexlist[$i]}" -d "$apexworkdir"
    sudo mount -o loop,ro "$apexworkdir"/apex_payload.img "$apexworkdir"/mnt
    sudo mkdir -p "$rootfs"/apex/"$basename"
    sudo cp -anr "$apexworkdir"/mnt/* "$rootfs"/apex/"$basename"
    sudo rm -rf "$rootfs"/apex/"$basename"/'lost+found'
    sudo cp -anr "$apexworkdir"/apex_pubkey "$rootfs"/apex/"$basename"
    sudo umount "$apexworkdir"/mnt
    sudo rm -rf "$apexworkdir"/*
done

if [ -e android.tar ]; then
    DATE=$(date +%F_%R)
    SAVETO=android-old-$DATE.tar

    echo "#########################################################"
    echo "# WARNING: Old android.tar still exists.                 "
    echo "#          Moving it to $SAVETO.                         "
    echo "#########################################################"

    mv android.tar "$SAVETO"
fi

sudo cp "$destdir"/out/target/product/kbox_arm64/obj/MESON_MESA3D/install/usr/local/lib/dri/radeonsi_drv_video.so $rootfs/system/vendor/lib64/dri/

cd "$rootfs"
sudo tar --numeric-owner -cf "$destdir"/android.tar ./
sudo chown "$USER":"$USER" "$destdir"/android.tar

cd "$destdir"
