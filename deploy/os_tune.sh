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
# =============================================================================
case "${1:-}" in -h|--help) sed -n '17,18p' "$0"; exit 0 ;; esac
# CubeSandbox(redroid) OS 调优固化脚本（5 项 OS + 3 项 TLBI）
# 用法: sudo bash os_tune.sh

[ "$(id -u)" -eq 0 ] || { echo "请用 root 运行: sudo bash $0"; exit 1; }

fail() { echo "错误: $*" >&2; exit 1; }

# 1. 关闭 NUMA balancing
echo 0 > /proc/sys/kernel/numa_balancing || fail "写入 numa_balancing 失败"

# 2. 启用 cluster 级调度
echo 1 > /proc/sys/kernel/sched_cluster || fail "写入 sched_cluster 失败"

# 3. THP always -> madvise
echo madvise > /sys/kernel/mm/transparent_hugepage/enabled || fail "切换 THP 失败"

# 4. zone_reclaim 本地优先回收
echo 1 > /proc/sys/vm/zone_reclaim_mode || fail "写入 zone_reclaim_mode 失败"

# 5. KVM halt_poll_ns -> 0
modprobe kvm 2>/dev/null || true
echo 0 > /sys/module/kvm/parameters/halt_poll_ns || fail "写入 halt_poll_ns 失败"

# 6. ARM64 KVM TLBI IPI 优化（需 tlbi_opt 内核）
#    tlbi_ipi=1 开启 TLBI IPI；tlbi_ipi_lazy=1 允许延迟合并；
#    arm64_tlbi_ipi.flags=31(0x1f) = 全开（现行基线）。
modprobe kvm-arm 2>/dev/null || true
modprobe arm64_tlbi_ipi 2>/dev/null || true
echo 1 > /sys/module/kvm-arm/parameters/tlbi_ipi 2>/dev/null ||
  fail "kvm-arm 模块未加载或内核未包含 TLBI 优化，见「编译与安装Host内核」章节"
echo 1 > /sys/module/kvm-arm/parameters/tlbi_ipi_lazy 2>/dev/null ||
  fail "kvm-arm 模块未加载或内核未包含 TLBI 优化，见「编译与安装Host内核」章节"
echo 31 > /sys/module/arm64_tlbi_ipi/parameters/flags 2>/dev/null ||
  fail "arm64_tlbi_ipi 模块未加载或内核未包含 TLBI 优化，见「编译与安装Host内核」章节"

echo "OK: 5 项 OS 调优 + 3 项 TLBI 优化已生效"
