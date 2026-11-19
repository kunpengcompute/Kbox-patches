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

android_patch_wl=(
bionic-0001.patch
build-make-0001.patch
build-soong-0001.patch
device-generic-goldfish-0001.patch
device-google-cuttlefish-0001.patch
external-libdrm-0001.patch
external-libva-0001.patch
external-llvm70-0001.patch
external-minijail-0001.patch
external-selinux-0001.patch
frameworks-av-0001.patch
frameworks-base-0001.patch
frameworks-native-0001.patch
frameworks-opt-net-wifi-0001.patch
hardware-interfaces-0001.patch
hardware-libhardware-0001.patch
libcore-0001.patch
packages-apps-ManagedProvisioning-0001.patch
packages-apps-SecureElement-0001.patch
packages-apps-Settings-0001.patch
packages-apps-Traceur-0001.patch
packages-providers-DownloadProvider-0001.patch
system-bpf-0001.patch
system-bt-0001.patch
system-core-0001.patch
system-hwservicemanager-0001.patch
system-libhwbinder-0001.patch
system-libvintf-0001.patch
system-memory-lmkd-0001.patch
system-memory-libion-0001.patch
system-netd-0001.patch
system-sepolicy-0001.patch
system-vold-0001.patch
)

android_only64_patch=(
build-make-0037.patch
frameworks-av-0038.patch
hardware-interfaces-0039.patch
platform_testing-0040.patch
device-google-vrservices-0041.patch
)

soft_render_patch=(
vendor-kbox-0042.patch
)
