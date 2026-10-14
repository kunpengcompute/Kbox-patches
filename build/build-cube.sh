#!/usr/bin/env bash
# =============================================================================
# CubeSandbox + guest 内核 自动化构建脚本
#
# 基于以下本地预制代码仓（工作区根为脚本所在目录的上上级目录）：
#   - CubeSandbox/          CubeSandbox v0.7.0 源码
#   - opencloudos-kernel/   guest 内核源码
#   - Kbox-patches/         patchForCube/ 下增量 patch
#
# 用法:
#   bash build-cube.sh [patch|kernel|bundle|all]
#     patch    仅合入 patchForCube/ 下的所有 patch
#     kernel   仅编译 guest 内核（builder 容器内，产物 vmlinux）
#     bundle   仅编译 CubeSandbox 一键发布包（自动放入内核制品）
#     all      按顺序执行以上全部（默认）
#
# 可覆盖的环境变量:
#   CUBE_SRC             CubeSandbox 源码目录（默认 <工作区>/CubeSandbox）
#   KERNEL_SRC           guest 内核源码目录（默认 <工作区>/opencloudos-kernel）
#   KERNEL_TARGET_ARCH   目标架构（默认 aarch64）
#   KERNEL_BUILD_JOBS    内核编译并发（默认 nproc）
#   GOPROXY              受限网络下的 Go module 代理（透传给 bundle 步骤）
#   ENVD_LOCAL_PATH      指定时把该 envd 二进制内嵌进发布包的 cubemastercli
#
# 说明:
#   - patch 需在“干净”源码树上应用（重复执行会因已应用而失败）
#   - 组件编译与内核编译均在 builder 镜像 cube-sandbox-builder:ubuntu2004 内进行
#   - 文件系统布局与依赖关系详见 ../guide/cube_compile_guide.md
# =============================================================================
set -euo pipefail

# ===== 路径配置（相对脚本所在目录，与当前目录结构一致）=====
# 脚本位于 Kbox-patches/build/ 下，工作区根为其上上级目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
PATCH_DIR="$SCRIPT_DIR/../patchForCube"

CUBE_SRC="${CUBE_SRC:-$WORKSPACE/CubeSandbox}"
KERNEL_SRC="${KERNEL_SRC:-$WORKSPACE/opencloudos-kernel}"
KERNEL_TARGET_ARCH="${KERNEL_TARGET_ARCH:-aarch64}"
KERNEL_BUILD_JOBS="${KERNEL_BUILD_JOBS:-$(nproc)}"

KERNEL_CONFIG="$CUBE_SRC/configs/kernel-oc9.$KERNEL_TARGET_ARCH.config"
# make guest-kernel 在容器内固定使用 /workspace/_output/kernel/<arch>，
# 映射到宿主机即 $CUBE_SRC/_output/kernel/<arch>，不可通过变量改写
KERNEL_OUTPUT_DIR="$CUBE_SRC/_output/kernel/$KERNEL_TARGET_ARCH"
KERNEL_ARTIFACT="$CUBE_SRC/deploy/one-click/assets/kernel-artifacts/vmlinux"

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

# ===== 步骤 1：合入 patchForCube 下的所有 patch =====
apply_patches() {
    log "[1/3] 合入 Kbox-patches/patchForCube 下的所有 patch"
    [ -d "$PATCH_DIR" ] || die "patch 目录不存在: $PATCH_DIR"
    [ -d "$CUBE_SRC/.git" ] || die "不是 git 仓: $CUBE_SRC"

    # CubeSandbox 是单一 git 仓库（无多仓相对路径问题），直接在该仓内应用。
    # 文件名前缀含编号（0001/0002...），sort 保证按编号升序应用；
    # 依赖只存在于同文件内（0002 依赖 0001、0006 依赖 0005）。
    local patch_file count=0
    while IFS= read -r patch_file; do
        log "  apply $(basename "$patch_file")"
        git -C "$CUBE_SRC" apply "$patch_file" || die "应用失败: $patch_file（源码树可能不干净）"
        count=$((count + 1))
    done < <(find "$PATCH_DIR" -type f -name '*.patch' | sort)

    [ "$count" -gt 0 ] || die "未在 $PATCH_DIR 下找到任何 *.patch"
    log "  共应用 $count 个 patch，修改文件数: $(git -C "$CUBE_SRC" status --porcelain | wc -l)"
}

# ===== 步骤 2：编译 guest 内核 =====
build_kernel() {
    log "[2/3] 编译 guest 内核（builder 容器内）"
    [ -d "$KERNEL_SRC" ] || die "内核源码目录不存在: $KERNEL_SRC（先按编译说明 §2.3 拉取）"
    [ -f "$KERNEL_CONFIG" ] || die "内核配置不存在: $KERNEL_CONFIG"
    command -v make >/dev/null || die "未找到 make"

    # 走 CubeSandbox 自带的 guest-kernel 目标：把内核源码挂载到 builder 容器的
    # /kernel-src，在容器内执行 scripts/build-kernel.sh（out-of-tree，源码树不被改动）
    make -C "$CUBE_SRC" guest-kernel \
        KERNEL_SRC="$KERNEL_SRC" \
        KERNEL_TARGET_ARCH="$KERNEL_TARGET_ARCH" \
        KERNEL_BUILD_JOBS="$KERNEL_BUILD_JOBS"

    [ -f "$KERNEL_OUTPUT_DIR/vmlinux" ] || die "内核编译未产出: $KERNEL_OUTPUT_DIR/vmlinux"
    ls -lh "$KERNEL_OUTPUT_DIR/vmlinux"
}

# ===== 步骤 3：编译 CubeSandbox 一键发布包 =====
build_bundle() {
    log "[3/3] 编译 CubeSandbox 一键发布包"
    command -v docker >/dev/null || die "未找到 docker"
    [ -f "$KERNEL_OUTPUT_DIR/vmlinux" ] \
        || die "缺少 guest 内核产物: $KERNEL_OUTPUT_DIR/vmlinux（先执行 kernel 步骤）"

    install -m 0644 "$KERNEL_OUTPUT_DIR/vmlinux" "$KERNEL_ARTIFACT"

    local build_env="$CUBE_SRC/deploy/one-click/build.env"
    if [ ! -f "$build_env" ]; then
        cp "$CUBE_SRC/deploy/one-click/build.env.example" "$build_env"
        log "  已生成 $build_env（默认全部组件从源码编译）"
    fi

    ( cd "$CUBE_SRC" && ./deploy/one-click/build-release-bundle-builder.sh )

    log "  发布包产物:"
    ls -lh "$CUBE_SRC"/deploy/one-click/dist/*.tar.gz
}

# ===== 主流程 =====
case "${1:-all}" in
    patch)  apply_patches ;;
    kernel) build_kernel ;;
    bundle) build_bundle ;;
    all)    apply_patches; build_kernel; build_bundle ;;
    *) die "未知步骤: $1（可选: patch|kernel|bundle|all）" ;;
esac
