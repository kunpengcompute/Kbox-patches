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

nic=$(ip a | grep 192 | head -n 1 | awk '{print $NF}')
echo "nic: $nic"
pci=$(lshw -c network -businfo | grep -w ${nic} | awk '{print $1}' | cut -d'@' -f2)
echo "pci: $pci"

vfs_max=$(cat /sys/bus/pci/devices/${pci}/sriov_totalvfs)
echo "max vfs : $vfs_max"

echo $vfs_max > /sys/bus/pci/devices/${pci}/sriov_numvfs

lshw -c network -businfo | grep -w "Virtual Function" | awk '{print $1}' | cut -d':' -f2- > vfNic.txt
