#!/usr/bin/env bash
# =============================================================================
# PVM L1 内核安装脚本（在 L1 虚拟机内以 root 运行）
#
# 两次运行模型（幂等，重复运行安全，无需记忆两套命令）:
#   第 1 次: 安装 PVM 内核 RPM 并设为默认引导 → 提示 reboot
#   第 2 次: 重启后已运行 PVM 内核 → 加载 kvm_pvm 并验证 /dev/kvm
#
# 用法:
#   bash install-pvm-l1.sh [内核RPM路径] [kernelrelease]
#
# 参数说明:
#   内核RPM路径   缺省时探测当前目录下唯一的 kernel-*.aarch64.rpm
#   kernelrelease 可选。缺省时按 RPM 版本号自动匹配 /boot/vmlinuz-<ver>*；
#                 LOCALVERSION 等特殊场景不匹配时，把构建侧
#                 $PVM_OUT/build.meta 里的 L1_KERNELRELEASE 传入本参数
#
# 通过标准:
#   - 当前内核为本次安装的 PVM 内核（uname -r 一致）
#   - kvm_pvm 已加载且已写入 /etc/modules-load.d/（开机自动加载）
#   - /dev/kvm 存在
# =============================================================================
set -euo pipefail

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "本脚本需在 L1 内以 root 运行"

# ===== 解析内核 RPM 路径 =====
KERNEL_RPM="${1:-}"
if [ -z "$KERNEL_RPM" ]; then
    mapfile -t candidates < <(compgen -G "./kernel-*.aarch64.rpm" || true)
    if [ "${#candidates[@]}" -ne 1 ]; then
        die "当前目录须恰好存在一个 kernel-*.aarch64.rpm（找到 ${#candidates[@]} 个），或显式传入 RPM 路径"
    fi
    KERNEL_RPM="${candidates[0]}"
fi
[ -f "$KERNEL_RPM" ] || die "内核 RPM 不存在: $KERNEL_RPM"
log "内核 RPM: $KERNEL_RPM"

# ===== 安装（幂等，同版本重复安装不报错）=====
# 只安装内核主包；binrpm-pkg 产出的 kernel-headers 供编译用，宿主机无需安装
log "安装内核 RPM ..."
dnf localinstall -y "$KERNEL_RPM"

# ===== 解析目标内核版本 =====
RPM_VER=$(rpm -qp --qf '%{VERSION}' "$KERNEL_RPM")
KVER="${2:-$(ls /boot/vmlinuz-"$RPM_VER"* 2>/dev/null | sed 's|.*/vmlinuz-||' | sort -V | tail -1)}"
[ -n "$KVER" ] || die "未能从 /boot/vmlinuz-$RPM_VER* 解析出目标内核版本，请显式传入 kernelrelease 参数"
[ -f "/boot/vmlinuz-$KVER" ] || die "/boot/vmlinuz-$KVER 不存在（安装可能未成功）"
log "目标 PVM 内核版本: $KVER"

# ===== 两态分支 =====
if [ "$(uname -r)" != "$KVER" ]; then
    grubby --set-default "/boot/vmlinuz-$KVER"
    log "已把 PVM 内核设为默认引导: $(grubby --default-kernel)"
    log "请执行 reboot；重启后【再次运行本脚本】完成 kvm_pvm 加载与验证"
    exit 0
fi

# 当前已运行 PVM 内核 → 加载并验证
log "当前已运行 PVM 内核 $KVER，开始加载 kvm_pvm ..."
modprobe kvm_pvm || die "modprobe kvm_pvm 失败（请检查 dmesg 中 kvm_pvm 初始化错误）"
printf 'kvm_pvm\n' > /etc/modules-load.d/kvm-pvm.conf

failed=0
lsmod | grep '^kvm_pvm' >/dev/null || { log "  [失败] kvm_pvm 未加载"; failed=1; }
[ -e /dev/kvm ] || { log "  [失败] /dev/kvm 不存在"; failed=1; }
if [ "$failed" = 0 ]; then
    log "L1 PVM 状态验证全部通过:"
    log "  uname -r  = $KVER"
    log "  kvm_pvm   = 已加载（开机自动加载已配置）"
    log "  /dev/kvm  = 存在"
    log "下一步: 用 install-cube-pvm.sh 以 PVM 模式安装 CubeSandbox"
else
    die "存在失败项，PVM 状态未就绪"
fi
