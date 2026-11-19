#!/bin/bash
# Copyright 2026 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ******************************************************************************** #
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
