#!/usr/bin/env bash
# =============================================================================
# CubeSandbox + Redroid 14 自动化构建脚本
#
# 基于以下本地预制代码仓：
#   - runtime/        e2b-dev/runtime（envd 源码，packages/envd）
#   - Kbox-patches/   patchForRedroid/ 下增量 patch
#   - aosp-14/        AOSP 14.0.0_r75 源码（已应用 redroid 官方 patch）
#
# 用法:
#   bash build.sh [envd|patch|redroid|pack|all]
#     envd     仅编译 envd 二进制（放入 aosp-14/vendor/redroid/envd/envd）
#     patch    仅应用 patchForRedroid/ 下的所有 patch
#     redroid  仅编译 AOSP 镜像（lunch + make）
#     pack     仅打包 Docker 镜像（需 sudo）
#     all      按顺序执行以上全部（默认）
#
# 说明:
#   - 假设代码仓已本地预制、目录结构与当前一致
#   - patch 需在“干净”源码树上应用（重复执行会因已应用而失败）
#   - pack 步骤需要 root（loop 挂载镜像），用 sudo bash build.sh pack 执行
# =============================================================================
# 不启用 set -u（nounset）：source build/envsetup.sh 内部会引用未定义变量
# （如 $TOP），启用 -u 会报 "TOP: unbound variable"。
set -eo pipefail

# ===== 路径配置（相对脚本所在目录，与当前目录结构一致）=====
# 脚本位于 Kbox-patches/build/ 下，工作区根为其上上级目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
AOSP="$WORKSPACE/aosp-14"
RUNTIME="$WORKSPACE/runtime"
PATCH_DIR="$SCRIPT_DIR/../patchForRedroid"
ENVD_SRC="$RUNTIME/packages/envd"
ENVD_DST="$AOSP/vendor/redroid/envd/envd"
PRODUCT="redroid_arm64_only"
LUNCH_TARGET="redroid_arm64_only-trunk_staging-user"
TAG="redroid:14.0.0_r75_arm64_only"
OUT_TAR="$AOSP/redroid-14.0.0_r75_arm64_only-docker.tar"
PROD_DIR="$AOSP/out/target/product/$PRODUCT"

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

# ===== 步骤 1：编译 envd 二进制 =====
build_envd() {
    log "[1/4] 编译 envd 二进制"
    command -v go >/dev/null || die "未找到 go。runtime 的 envd 需要 go 1.26.x（建议安装 go ≥ 1.21 并启用 GOTOOLCHAIN=auto 自动下载）"
    [ -d "$ENVD_SRC" ] || die "envd 源码目录不存在: $ENVD_SRC"

    mkdir -p "$(dirname "$ENVD_DST")"
    (
        cd "$ENVD_SRC"
        export GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"
        export GOSUMDB="${GOSUMDB:-off}"
        export GOTOOLCHAIN="${GOTOOLCHAIN:-auto}"
        # 纯 Go 静态交叉编译到 Android arm64，无需 NDK
        CGO_ENABLED=0 GOOS=android GOARCH=arm64 \
            go build -trimpath -ldflags "-s -w -buildid=" -o "$ENVD_DST" .
    )
    chmod +x "$ENVD_DST"
    file "$ENVD_DST" | grep -q "aarch64" || die "envd 产物不是 aarch64 ELF"
    ls -lh "$ENVD_DST"
}

# ===== 步骤 2：应用 patchForRedroid 下的所有 patch =====
apply_patches() {
    log "[2/4] 应用 Kbox-patches/patchForRedroid 下的所有 patch"
    [ -d "$PATCH_DIR" ] || die "patch 目录不存在: $PATCH_DIR"

    # 参照 apply-patch.sh：用 patch 文件在 patchForRedroid/ 下的相对路径
    # （如 device/redroid/xxx.patch）定位 AOSP 源码树中对应的 git 仓根目录
    # （$AOSP/device/redroid），并在该仓内 git apply。
    # 文件名含仓内编号（0001/0002...），sort 保证同一仓内按编号升序应用；
    # 依赖只存在于同一仓内（如 vendor/redroid 的 0002 先于 0004），跨仓无依赖。
    local patch_file relpath repo dir count=0
    while IFS= read -r patch_file; do
        relpath="${patch_file#"$PATCH_DIR"/}"   # 如 device/redroid/xxx.patch
        repo="$(dirname "$relpath")"            # 如 device/redroid
        dir="$AOSP/$repo"
        [ -d "$dir/.git" ] || die "不是 git 仓: $dir（patch 相对路径 $repo）"
        log "  apply $(basename "$patch_file") -> $repo"
        git -C "$dir" apply "$patch_file" || die "应用失败: $patch_file"
        count=$((count + 1))
    done < <(find "$PATCH_DIR" -type f -name '*.patch' | sort)

    [ "$count" -gt 0 ] || die "未在 $PATCH_DIR 下找到任何 *.patch"
    log "  共应用 $count 个 patch"
}

# ===== 步骤 3：编译 AOSP 镜像 =====
build_redroid() {
    log "[3/4] 编译 redroid arm64-only 镜像"
    cd "$AOSP"
    source build/envsetup.sh
    lunch "$LUNCH_TARGET"
    make -j"$(nproc)"
}

# ===== 步骤 4：打包 Docker 镜像 =====
pack_image() {
    log "[4/4] 打包 Docker 镜像"
    [ "$(id -u)" -eq 0 ] || die "打包需 root（loop 挂载镜像），请用 sudo 运行"
    [ -f "$PROD_DIR/system.img" ] || die "缺少 system.img: $PROD_DIR"
    [ -f "$PROD_DIR/vendor.img" ] || die "缺少 vendor.img: $PROD_DIR"

    cd "$PROD_DIR"
    mkdir -p system vendor

    cleanup() {
        umount "$PROD_DIR/system" 2>/dev/null || true
        umount "$PROD_DIR/vendor" 2>/dev/null || true
    }
    trap cleanup EXIT

    log "  挂载镜像 ..."
    mount -o ro,loop system.img system
    mount -o ro,loop vendor.img vendor

    # 完整性检查
    [ -L system/init ] || die "system/init 符号链接缺失"
    [ -f system/system/bin/init ] || die "system/system/bin/init 缺失"
    [ -f vendor/build.prop ] || die "vendor/build.prop 缺失"
    [ -f vendor/bin/envd ] || die "vendor/bin/envd 缺失（envd 未编入镜像，检查步骤 1 与 vendor-redroid-0002 patch）"

    log "  tar + docker import ..."
    tar --xattrs -c vendor -C system --exclude="./vendor" . \
        | docker import --platform=linux/arm64 \
            -c 'ENTRYPOINT ["/init", "qemu=1", "androidboot.hardware=redroid"]' \
            - "$TAG"

    umount "$PROD_DIR/system" || true
    umount "$PROD_DIR/vendor" || true
    trap - EXIT

    log "  docker save ..."
    docker save -o "$OUT_TAR" "$TAG"
    if [ -n "${SUDO_USER:-}" ]; then
        chown "$SUDO_USER":"$(id -gn "$SUDO_USER")" "$OUT_TAR"
    fi

    docker inspect "$TAG" --format 'Entrypoint: {{.Config.Entrypoint}}  Arch: {{.Architecture}}'
    ls -lh "$OUT_TAR"
    log "完成: $OUT_TAR"
}

# ===== 主流程 =====
case "${1:-all}" in
    envd)    build_envd ;;
    patch)   apply_patches ;;
    redroid) build_redroid ;;
    pack)    pack_image ;;
    all)     build_envd; apply_patches; build_redroid; pack_image ;;
    *) die "未知步骤: $1（可选: envd|patch|redroid|pack|all）" ;;
esac
