#!/usr/bin/env bash
# =============================================================================
# CubeSandbox PVM（鲲鹏嵌套虚拟化）一键构建脚本
#
# 在普通方案（build-cube.sh）之上增加 PVM 内核编译与注入路径，产出
# "PVM-ready"发布包（内含 vmlinux-pvm），安装方无需再手动替换 L2 内核。
#
# 基于 PVM 内核源码（pvm-OLK6.6，含 arch/arm64/configs/pvm_l1.config /
# pvm_l2.config）产出两类制品：
#   - PVM L1 内核 RPM    安装到 L1 虚拟机 /boot，提供 kvm_pvm 与 /dev/kvm
#   - PVM L2 guest Image 打包进发布包作为 vmlinux-pvm（PVM 沙箱 guest 内核）
#
# 用法:
#   bash build-cube-pvm.sh [check-config|pvm-l1|pvm-l2|bundle|all]
#     check-config         仅核对 L1 最终 .config 的 CubeSandbox 宿主功能配置
#     pvm-l1               仅编译 PVM L1 内核 RPM（自动先跑 check-config）
#     pvm-l2               仅编译 PVM L2 guest Image，并放入发布包内核输入目录
#                          （使用 patchForKernel/cube_pvm_openEuler_OLK-6.6/pvm_l2.config）
#     bundle               编译 CubeSandbox 一键发布包（普通内核缺失时自动补编译）
#     all                  按顺序执行 pvm-l1、pvm-l2、bundle（默认）
#
# 可覆盖的环境变量:
#   PVM_SRC             PVM 内核源码目录（默认 <工作区>/pvm-OLK6.6）
#   PVM_OUT             PVM 编译输出根目录（默认 $PVM_SRC/_output）
#   PVM_BUILD_JOBS      内核编译并发（默认 nproc）
#   CUBE_SRC            CubeSandbox 源码目录（默认 <工作区>/CubeSandbox）
#   PATCH_DIR           patchForCube 目录（默认 <脚本目录>/../patchForCube）
#   PVM_L2_CONFIG       PVM L2 内核配置文件（默认
#                       <脚本目录>/../patchForKernel/cube_pvm_openEuler_OLK-6.6/pvm_l2.config）
#   PVM_KERNEL_PATCH_DIR  PVM 内核源码补丁目录（默认
#                       <脚本目录>/../patchForKernel/cube_pvm_openEuler_OLK-6.6），
#                       编译 L2 前按文件名顺序合入 PVM 源码树
#   KERNEL_TARGET_ARCH   目标架构（默认 aarch64）
#   SKIP_L1_CONFIG_CHECK=1  跳过 L1 宿主功能配置核对（不建议）
#
# 说明:
#   - L1/L2 均在宿主机直接编译（要求 aarch64 环境），不进 builder 容器
#   - PVM L2 内核配置以 Kbox 仓库内维护的 pvm_l2.config 为准（可直接编辑），
#     编译时整体拷贝为 .config，再做 olddefconfig；不在脚本内做 patch 比对叠加
#   - 编译前需安装依赖:
#       dnf install -y gcc gcc-c++ make flex bison \
#         openssl-devel elfutils-libelf-devel rpm-build bc perl tar xz cpio dwarves
#   - bundle 子命令复用 build-cube.sh 的打包逻辑，不重复实现；
#     vmlinux-pvm 放入 assets/kernel-artifacts/ 即被上游 build-vm-assets.sh
#     默认回退路径自动打入发布包
#   - 每次构建向 $PVM_OUT/build.meta 追加记录（版本/路径/SHA256），供人工核对，
#     安装脚本运行时不依赖该文件
# =============================================================================
set -euo pipefail

# ===== 路径配置（相对脚本所在目录，与 build-cube.sh 布局一致）=====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
PATCH_DIR="${PATCH_DIR:-$SCRIPT_DIR/../patchForCube}"
# PVM L2 内核配置：由 Kbox 仓库统一维护，编译时直接拷贝，便于直接修改
PVM_L2_CONFIG="${PVM_L2_CONFIG:-$SCRIPT_DIR/../patchForKernel/cube_pvm_openEuler_OLK-6.6/pvm_l2.config}"
# PVM 内核源码补丁：只放源码级修改（配置类修改直接写进 pvm_l2.config）
PVM_KERNEL_PATCH_DIR="${PVM_KERNEL_PATCH_DIR:-$SCRIPT_DIR/../patchForKernel/cube_pvm_openEuler_OLK-6.6}"

CUBE_SRC="${CUBE_SRC:-$WORKSPACE/CubeSandbox}"
# PVM 源码目录：兼容 pvm-OLK6.6 与 pvm 两种克隆目录名
if [ -z "${PVM_SRC:-}" ]; then
    for _d in "$WORKSPACE/pvm-OLK6.6" "$WORKSPACE/pvm"; do
        if [ -f "$_d/Makefile" ] && [ -d "$_d/arch/arm64/configs" ]; then
            PVM_SRC="$_d"
            break
        fi
    done
    PVM_SRC="${PVM_SRC:-$WORKSPACE/pvm-OLK6.6}"
fi
PVM_OUT="${PVM_OUT:-$PVM_SRC/_output}"
KERNEL_TARGET_ARCH="${KERNEL_TARGET_ARCH:-aarch64}"
PVM_BUILD_JOBS="${PVM_BUILD_JOBS:-$(nproc)}"

PVM_L1_OUT="$PVM_OUT/l1"
PVM_L2_OUT="$PVM_OUT/l2"
KERNEL_ARTIFACTS_DIR="$CUBE_SRC/deploy/one-click/assets/kernel-artifacts"
PVM_L2_ARTIFACT="$KERNEL_ARTIFACTS_DIR/vmlinux-pvm"
BUILD_META="$PVM_OUT/build.meta"

log() { echo -e "\033[1;32m$*\033[0m"; }
warn() { echo -e "\033[1;33m警告: $*\033[0m" >&2; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

# PVM 快照恢复对 cube-agent 的构建产物敏感：优先使用仓库内已验证的 agent，
# 避免 bundle 每次按当前源码树重新编译出不同二进制（详见 docs/zh/install_guide.md）。
VERIFIED_AGENT_BIN="$SCRIPT_DIR/../assets/cube-agent-verified"
if [ -z "${ONE_CLICK_CUBE_AGENT_BIN:-}" ]; then
    if [ -f "$VERIFIED_AGENT_BIN" ]; then
        export ONE_CLICK_CUBE_AGENT_BIN="$VERIFIED_AGENT_BIN"
    else
        warn "未找到 $VERIFIED_AGENT_BIN，bundle 将重新编译 cube-agent（PVM 上可能触发快照恢复崩溃）"
    fi
fi

append_meta() { # append_meta <KEY> <VALUE>
    echo "$1=$2" >>"$BUILD_META"
}

# ===== 前置检查 =====
ensure_pvm_src() {
    [ -f "$PVM_SRC/Makefile" ] || die "PVM 内核源码目录不存在: $PVM_SRC
请选择其一:
  1) 把源码解压/clone 到 $WORKSPACE/pvm-OLK6.6
  2) export PVM_SRC=<实际源码目录> 后重跑（例如 export PVM_SRC=/home/yp/pvm-OLK6.6）
  3) git clone https://gitcode.com/boostkit/pvm.git $WORKSPACE/pvm-OLK6.6"
    [ -f "$PVM_SRC/arch/arm64/configs/pvm_l1.config" ] \
        || die "$PVM_SRC 下缺少 arch/arm64/configs/pvm_l1.config（疑似非 PVM 内核源码）"
    [ -f "$PVM_SRC/arch/arm64/configs/pvm_l2.config" ] \
        || die "$PVM_SRC 下缺少 arch/arm64/configs/pvm_l2.config（疑似非 PVM 内核源码）"
}

ensure_host_deps() {
    local dep
    for dep in make gcc flex bison rpmbuild bc perl python3 pahole; do
        command -v "$dep" >/dev/null \
            || die "宿主机缺少构建依赖: $dep
请执行: dnf install -y gcc gcc-c++ make flex bison \\
  openssl-devel elfutils-libelf-devel rpm-build bc perl tar xz cpio dwarves"
    done
    [ -f /usr/include/libelf.h ] \
        || die "缺少 elfutils-libelf-devel（binrpm-pkg 的 BuildRequires）
请执行: dnf install -y elfutils-libelf-devel dwarves"
    [ -f /usr/include/openssl/ssl.h ] \
        || die "缺少 openssl-devel
请执行: dnf install -y openssl-devel"
}

# ===== 步骤 1：核对 L1 的 CubeSandbox 宿主功能配置 =====
# L1 内核将作为 CubeSandbox 宿主运行，缺容器/网络/文件系统等功能时
# 后续安装必然失败，故作为 pvm-l1 的强制前置（SKIP_L1_CONFIG_CHECK=1 跳过）。
check_config() {
    log "[check-config] 核对 L1 .config 的 CubeSandbox 宿主功能配置"
    [ -f "$PVM_L1_OUT/.config" ] \
        || die "尚未生成 $PVM_L1_OUT/.config，请先执行 pvm-l1（本子命令用于复核已生成的 .config）"

    PVM_L1_OUT="$PVM_L1_OUT" python3 - <<'PY'
import os
from pathlib import Path

config = {}
for line in (Path(os.environ["PVM_L1_OUT"]) / ".config").read_text().splitlines():
    if line.startswith("CONFIG_") and "=" in line:
        key, value = line.split("=", 1)
        config[key] = value

required = """
KVM KVM_PVM MODULES
CGROUPS MEMCG CGROUP_SCHED CFS_BANDWIDTH CPUSETS CGROUP_PIDS
CGROUP_DEVICE CGROUP_CPUACCT BLK_CGROUP
NAMESPACES UTS_NS IPC_NS USER_NS PID_NS NET_NS
VETH TUN BRIDGE BRIDGE_NETFILTER NETFILTER NF_CONNTRACK NF_NAT
IP_NF_IPTABLES IP_NF_FILTER IP_NF_NAT
XFS_FS OVERLAY_FS EXT4_FS
VIRTIO_PCI VIRTIO_BLK VIRTIO_NET VSOCKETS VHOST_VSOCK
BPF BPF_SYSCALL CGROUP_BPF SECCOMP SECCOMP_FILTER
""".split()
missing = ["CONFIG_" + key for key in required
           if config.get("CONFIG_" + key) not in ("y", "m")]
if missing:
    raise SystemExit("缺少宿主功能配置: " + ", ".join(missing)
                    + "\n请用 menuconfig 补齐后重跑 olddefconfig 与本检查")
print("CubeSandbox 宿主基础配置检查通过")
PY
}

# ===== 步骤 2：编译 PVM L1 内核 RPM =====
build_pvm_l1() {
    log "[1/3] 编译 PVM L1 内核 RPM（宿主机直接编译）"
    ensure_pvm_src
    ensure_host_deps

    mkdir -p "$PVM_L1_OUT"
    cp "$PVM_SRC/arch/arm64/configs/pvm_l1.config" "$PVM_L1_OUT/.config"
    make -s -C "$PVM_SRC" O="$PVM_L1_OUT" ARCH=arm64 olddefconfig

    if [ "${SKIP_L1_CONFIG_CHECK:-0}" != "1" ]; then
        check_config
    else
        warn "SKIP_L1_CONFIG_CHECK=1，已跳过 L1 宿主功能配置核对"
    fi

    INSTALL_MOD_STRIP=1 make -C "$PVM_SRC" \
        O="$PVM_L1_OUT" ARCH=arm64 \
        binrpm-pkg -j"$PVM_BUILD_JOBS"

    local l1_release l1_rpm
    l1_release=$(make -s -C "$PVM_SRC" O="$PVM_L1_OUT" ARCH=arm64 kernelrelease)
    l1_rpm=$(find "$PVM_L1_OUT/rpmbuild/RPMS/$KERNEL_TARGET_ARCH" \
        -maxdepth 1 -type f -name "kernel-[0-9]*.$KERNEL_TARGET_ARCH.rpm" -print -quit)
    [ -n "$l1_rpm" ] || die "未找到 L1 内核 RPM 产物"
    ls -lh "$l1_rpm"

    mkdir -p "$PVM_OUT"
    {
        echo "# [$(date '+%F %T')] build-cube-pvm.sh pvm-l1"
        append_meta "L1_KERNELRELEASE" "$l1_release"
        append_meta "L1_RPM" "$l1_rpm"
        append_meta "L1_RPM_SHA256" "$(sha256sum "$l1_rpm" | awk '{print $1}')"
    }
    log "  L1 内核: $l1_release，RPM 产物: $l1_rpm"
}

# ===== 合入 PVM 内核源码补丁 =====
# 约定：配置类修改直接写进 patchForKernel/<内核目录>/pvm_l2.config；
#       只有源码级修改（如新增 ashmem 驱动）才做成 patch 放同目录下。
# 幂等：可正向合入则合入；否则试反向 dry-run 判定为已合入并跳过；
#       两者都不成立说明源码树不干净或版本不匹配，直接终止。
apply_pvm_kernel_patches() {
    local patch_file applied=0
    [ -d "$PVM_KERNEL_PATCH_DIR" ] || return 0
    while IFS= read -r patch_file; do
        [ -n "$patch_file" ] || continue
        if ( cd "$PVM_SRC" && patch -p1 --dry-run --forward --batch <"$patch_file" ) >/dev/null 2>&1; then
            log "  合入源码补丁: $(basename "$patch_file")"
            ( cd "$PVM_SRC" && patch -p1 --forward --batch <"$patch_file" ) >/dev/null \
                || die "源码补丁合入失败: $patch_file"
            applied=$((applied + 1))
        elif ( cd "$PVM_SRC" && patch -p1 --dry-run --reverse --batch <"$patch_file" ) >/dev/null 2>&1; then
            log "  源码补丁已合入，跳过: $(basename "$patch_file")"
        else
            die "源码补丁无法合入，也不处于已合入状态: $patch_file
PVM 源码树可能不干净或版本不匹配（要求基线 6f549048513c39fa44f1dc9e38df3bfc967082a6）"
        fi
    done < <(find "$PVM_KERNEL_PATCH_DIR" -maxdepth 1 -type f -name '*.patch' | sort)
    [ "$applied" -gt 0 ] && log "  本次合入 $applied 个 PVM 内核源码补丁"
    return 0
}

# ===== 步骤 3：编译 PVM L2 guest Image 并注入发布包内核输入目录 =====
build_pvm_l2() {
    log "[2/3] 编译 PVM L2 guest Image（宿主机直接编译）"
    ensure_pvm_src
    ensure_host_deps
    apply_pvm_kernel_patches

    mkdir -p "$PVM_L2_OUT"
    # 直接使用 Kbox 仓库内维护的 L2 配置（便于直接编辑），整体拷贝后解析依赖
    [ -f "$PVM_L2_CONFIG" ] \
        || die "缺少 PVM L2 配置文件: $PVM_L2_CONFIG
请在 Kbox 仓库内维护该文件（可从 $PVM_SRC/arch/arm64/configs/pvm_l2.config 复制后按需修改）"
    cp "$PVM_L2_CONFIG" "$PVM_L2_OUT/.config"
    make -s -C "$PVM_SRC" O="$PVM_L2_OUT" ARCH=arm64 olddefconfig
    make -C "$PVM_SRC" O="$PVM_L2_OUT" ARCH=arm64 -j"$PVM_BUILD_JOBS" Image

    local l2_release l2_image
    l2_release=$(make -s -C "$PVM_SRC" O="$PVM_L2_OUT" ARCH=arm64 kernelrelease)
    l2_image="$PVM_L2_OUT/arch/arm64/boot/Image"
    [ -s "$l2_image" ] || die "未找到 L2 Image 产物: $l2_image"

    # 放入上游 build-vm-assets.sh 的默认回退路径，bundle 时无需 export 变量
    mkdir -p "$KERNEL_ARTIFACTS_DIR"
    install -m 0644 "$l2_image" "$PVM_L2_ARTIFACT"

    mkdir -p "$PVM_OUT"
    {
        echo "# [$(date '+%F %T')] build-cube-pvm.sh pvm-l2"
        append_meta "L2_KERNELRELEASE" "$l2_release"
        append_meta "L2_IMAGE" "$l2_image"
        append_meta "VMLINUX_PVM" "$PVM_L2_ARTIFACT"
        append_meta "VMLINUX_PVM_SHA256" "$(sha256sum "$PVM_L2_ARTIFACT" | awk '{print $1}')"
    }
    log "  L2 内核: $l2_release，vmlinux-pvm 已就位: $PVM_L2_ARTIFACT"
}

# ===== 校验 patchForCube 已合入 =====
# 前置：源码级快速探测（Kbox patch 0001 的独有标志），避免白跑一次完整打包。
# 后置：对打包产物里的 cubemastercli 实测 --probe-timeout-ms，作为硬门禁。
# 说明：曾出现“源码树未打 patch 却打出了发布包”，导致模板创建报
#       flag provided but not defined: -probe-timeout-ms。
verify_patch_sources() {
    local marker_file="$CUBE_SRC/CubeMaster/cmd/cubemastercli/commands/cubebox/template.go"
    [ -f "$marker_file" ] || die "源码树不完整: 缺少 $marker_file"
    grep -q 'probe-timeout-ms' "$marker_file" \
        || die "CubeSandbox 源码树未合入 patchForCube（缺少 probe-timeout-ms），发布包会缺 Kbox 增强功能。
  请先合入后重新打包：
    cd $CUBE_SRC
    for p in \$(ls $PATCH_DIR/*.patch | sort); do patch -p1 --forward < \"\$p\"; done"
    log "  patchForCube 已合入（源码标志 probe-timeout-ms 存在）"
}

# ===== 自动合入 patchForCube =====
# bundle/all 路径不经过 build-cube.sh 的 patch 步骤，且 zip 解出的源码树不是
# git 仓（build-cube.sh patch 会直接拒绝），因此打包前在这里自行合入：
# 已合入则跳过，未合入则按编号顺序应用（git 仓用 git apply，否则用 patch）。
ensure_patchforcube() {
    local marker_file="$CUBE_SRC/CubeMaster/cmd/cubemastercli/commands/cubebox/template.go"
    [ -f "$marker_file" ] || die "源码树不完整: 缺少 $marker_file"

    if grep -q 'probe-timeout-ms' "$marker_file"; then
        log "  patchForCube 已合入，跳过"
        return 0
    fi

    [ -d "$PATCH_DIR" ] || die "patch 目录不存在: $PATCH_DIR"
    local patch_file applied=0
    while IFS= read -r patch_file; do
        log "  apply $(basename "$patch_file")"
        if [ -d "$CUBE_SRC/.git" ]; then
            git -C "$CUBE_SRC" apply "$patch_file" \
                || die "应用失败: $patch_file（源码树可能不干净）"
        else
            ( cd "$CUBE_SRC" && patch -p1 --forward --batch < "$patch_file" ) \
                || die "应用失败: $patch_file（源码树可能不干净，请恢复原始源码后重试）"
        fi
        applied=$((applied + 1))
    done < <(find "$PATCH_DIR" -type f -name '*.patch' | sort)
    [ "$applied" -gt 0 ] || die "未在 $PATCH_DIR 下找到任何 *.patch"
    log "  已合入 $applied 个 patch"
}

verify_bundle_artifacts() {
    local cmcli="$CUBE_SRC/deploy/one-click/.work/prebuilt/cubemastercli"
    [ -f "$cmcli" ] || cmcli="$CUBE_SRC/deploy/one-click/.work/core-bin/cubemastercli"
    [ -f "$cmcli" ] || die "未找到打包产物 cubemastercli（检查 bundle 是否成功）"
    # 对应 Kbox 的 template-create（redroid_operation.sh 调 template create-from-image）
    "$cmcli" template create-from-image --help 2>&1 | grep -q -- '--probe-timeout-ms' \
        || die "产物 cubemastercli 不支持 --probe-timeout-ms：本次打包未包含 Kbox patch，模板创建会失败"
    log "  产物校验通过: cubemastercli 支持 --probe-timeout-ms"
}

# ===== 步骤 4：编译 PVM-ready 发布包（复用 build-cube.sh）=====
build_bundle() {
    log "[3/3] 编译 CubeSandbox PVM-ready 一键发布包"

    # 普通内核（builder 要求的 vmlinux）缺失时自动补编译，保证一条命令到黑
    if [ ! -f "$CUBE_SRC/_output/kernel/$KERNEL_TARGET_ARCH/vmlinux" ]; then
        log "  缺少普通 guest 内核，自动执行 build-cube.sh kernel"
        "$SCRIPT_DIR/build-cube.sh" kernel
    fi

    # patchForCube 必须已合入，否则发布包不含 Kbox 增强功能（如 template 的
    # --probe-timeout-ms，缺失会导致模板创建直接失败）。未合入时自动合入。
    ensure_patchforcube
    verify_patch_sources

    # vmlinux-pvm 必须就位（否则发布包退化为普通方案）
    [ -f "$PVM_L2_ARTIFACT" ] \
        || die "缺少 $PVM_L2_ARTIFACT（先执行 pvm-l2 生成 vmlinux-pvm）"

    log "  复用 build-cube.sh bundle 打包（vmlinux-pvm 走上游默认回退路径自动注入）"
    "$SCRIPT_DIR/build-cube.sh" bundle

    # 产物硬门禁：打包出的 cubemastercli 必须真的带 patch 功能
    verify_bundle_artifacts

    log "  发布包产物:"
    ls -lh "$CUBE_SRC"/deploy/one-click/dist/*.tar.gz
}

# ===== 主流程 =====
case "${1:-all}" in
    check-config)       check_config ;;
    pvm-l1)             build_pvm_l1 ;;
    pvm-l2)             build_pvm_l2 ;;
    bundle)             build_bundle ;;
    all)                build_pvm_l1; build_pvm_l2; build_bundle ;;
    *) die "未知步骤: $1（可选: check-config|pvm-l1|pvm-l2|bundle|all）" ;;
esac
