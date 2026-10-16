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
#   bash build.sh [envd|patch|gms|redroid|pack|all]
#     envd     仅编译 envd 二进制（放入 aosp-14/vendor/redroid/envd/envd）
#     patch    仅应用 patchForRedroid/ 下的所有 patch
#     gms      仅按 .url 描述文件下载/还原 GMS 载荷 APK（无需 sudo，可提前执行）
#     redroid  仅编译 AOSP 镜像（lunch + make）
#     pack     仅打包 Docker 镜像（需 sudo；自动先执行 gms 步骤补齐缺失载荷）
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
# 大文件下载缓存目录（GMS zip 等，与代码仓分离避免误入库）
DOWNLOAD_CACHE="$WORKSPACE/downloads"

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

# ===== 步骤 1：编译 envd 二进制 =====
build_envd() {
    log "[1/5] 编译 envd 二进制"
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
    log "[2/5] 应用 Kbox-patches/patchForRedroid 下的所有 patch"
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

# ===== 步骤 3：下载/还原 GMS prebuilt 载荷 =====
# APK 二进制不入库（gitcode 仓库不允许托管 APK），仅入库 *.apk.url 下载源描述
# 文件；本步骤按描述文件从官方源下载 MindTheGapps zip，解出三个 APK 还原到
# 载荷目录并逐个 sha256 校验。优先使用 $DOWNLOAD_CACHE 缓存避免重复下载。
# 下载源依次尝试：环境变量 GMS_ZIP_URL 覆盖 → GitHub 官方直连 → 公共镜像；
# 所有源内容一致，最终以 zip_sha256/apk_sha256 校验兜底，镜像不可信无影响。
fetch_gms_payload() {
    log "[3/5] 检查/下载 GMS prebuilt 载荷"
    command -v curl >/dev/null   || die "未找到 curl（GMS 下载需要）"
    command -v unzip >/dev/null || die "未找到 unzip（GMS 解压需要）"

    local gms_dir="$PATCH_DIR/prebuilts/gms"
    local -a apks=(
        "system/product/priv-app/GmsCore/GmsCore.apk"
        "system/product/priv-app/Phonesky/Phonesky.apk"
        "system/system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk"
    )

    # 三个 APK 均已就位且 sha256 校验通过 → 跳过下载
    local apk want sha missing=0
    for apk in "${apks[@]}"; do
        want="$(awk -F= '$1=="apk_sha256"{print $2}' "$gms_dir/$apk.url" 2>/dev/null)" || true
        if [ -z "$want" ] || [ ! -f "$gms_dir/$apk" ]; then missing=1; break; fi
        sha="$(sha256sum "$gms_dir/$apk" | awk '{print $1}')"
        [ "$sha" = "$want" ] || { missing=1; break; }
    done
    if [ "$missing" -eq 0 ]; then
        log "  三个 APK 均已就位且校验通过，跳过下载"
        return 0
    fi

    # 读取 zip 下载源（三个 .url 文件指向同一 zip，取第一个即可）
    local desc="$gms_dir/${apks[0]}.url"
    [ -f "$desc" ] || die "缺少 GMS 下载源描述文件: $desc"
    local zip_url zip_sha256
    zip_url="$(awk -F= '$1=="zip_url"{print $2}' "$desc")"
    zip_sha256="$(awk -F= '$1=="zip_sha256"{print $2}' "$desc")"
    [ -n "$zip_url" ] && [ -n "$zip_sha256" ] || die "下载源描述文件缺 zip_url/zip_sha256: $desc"

    mkdir -p "$DOWNLOAD_CACHE"
    local zip_file="$DOWNLOAD_CACHE/${zip_url##*/}"

    # 缓存命中（校验通过）直接使用，否则依次尝试各下载源
    if [ -f "$zip_file" ] && echo "$zip_sha256  $zip_file" | sha256sum -c --status 2>/dev/null; then
        log "  使用已缓存的 zip: $zip_file"
    else
        rm -f "$zip_file"
        local -a sources=()
        [ -n "${GMS_ZIP_URL:-}" ] && sources+=("${GMS_ZIP_URL}")
        sources+=(
            "$zip_url"
            "https://gh-proxy.com/$zip_url"
            "https://hub.gitmirror.com/$zip_url"
            "https://ghfast.top/$zip_url"
        )
        local ok=0 src
        for src in "${sources[@]}"; do
            log "  下载 GMS zip (~430MB): $src"
            if curl -fL --retry 3 --retry-delay 2 -C - -o "$zip_file" "$src" \
               && echo "$zip_sha256  $zip_file" | sha256sum -c --status 2>/dev/null; then
                ok=1; break
            fi
            rm -f "$zip_file"
            log "  下载失败或校验不通过，尝试下一个源 ..."
        done
        [ "$ok" -eq 1 ] || die "GMS zip 下载失败。可 export GMS_ZIP_URL=<可用地址> 后重试，或手动下载 $zip_url 放到 $zip_file"
        log "  zip sha256 校验通过: ${zip_file##*/}"
    fi

    # 从 zip 还原三个 APK（zip 内路径与载荷目录内相对路径一致）并逐个校验
    for apk in "${apks[@]}"; do
        want="$(awk -F= '$1=="apk_sha256"{print $2}' "$gms_dir/$apk.url" 2>/dev/null)" || true
        [ -n "$want" ] || die "缺少下载源描述文件: $gms_dir/$apk.url"
        mkdir -p "$(dirname "$gms_dir/$apk")"
        unzip -p "$zip_file" "$apk" > "$gms_dir/$apk" || die "从 zip 解压失败: $apk"
        sha="$(sha256sum "$gms_dir/$apk" | awk '{print $1}')"
        [ "$sha" = "$want" ] || die "APK sha256 不匹配: $apk（期望 $want，实际 $sha）"
        log "  还原并校验通过: $apk"
    done

    # sudo 场景下把产物属主还给真实用户，避免工作区出现 root 属主文件
    if [ -n "${SUDO_USER:-}" ]; then
        chown "$SUDO_USER":"$(id -gn "$SUDO_USER")" "$zip_file" \
            "$gms_dir"/system/product/priv-app/*/*.apk \
            "$gms_dir"/system/system_ext/priv-app/*/*.apk 2>/dev/null || true
    fi
}

# ===== 步骤 4：编译 AOSP 镜像 =====
build_redroid() {
    log "[4/5] 编译 redroid arm64-only 镜像"
    cd "$AOSP"
    source build/envsetup.sh
    lunch "$LUNCH_TARGET"
    make -j"$(nproc)"
}

# ===== 步骤 5：打包 Docker 镜像 =====
pack_image() {
    log "[5/5] 打包 Docker 镜像"
    [ "$(id -u)" -eq 0 ] || die "打包需 root（loop 挂载镜像），请用 sudo 运行"
    [ -f "$PROD_DIR/system.img" ] || die "缺少 system.img: $PROD_DIR"
    [ -f "$PROD_DIR/vendor.img" ] || die "缺少 vendor.img: $PROD_DIR"

    # 打包前补齐 GMS 载荷（缺失时按 .url 描述自动下载；无网络且已有缓存/文件则直接通过）
    fetch_gms_payload

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
    # GMS 三件套（MindTheGapps 14 核心组件）以 prebuilt 载荷形式在打包期叠加。
    # 载荷位于 patchForRedroid/prebuilts/gms/system/，成员路径带 system/ 前缀，
    # 与镜像内 /product -> /system/product、/system_ext -> /system/system_ext 布局一致。
    # 注意：只显式列出"新增目录 + 文件"叶子成员——显式列举不会带出父目录条目，
    # 若带出会与 system.img 已有目录重复，docker import 拒绝重复路径。
    # 载荷不存在时跳过，产出无 GMS 的基础镜像。
    local gms_dir="$SCRIPT_DIR/../patchForRedroid/prebuilts/gms"
    local gms_args=()
    if [ -f "$gms_dir/system/product/priv-app/GmsCore/GmsCore.apk" ]; then
        log "  叠加 GMS prebuilt 载荷 ..."
        gms_args=(-C "$gms_dir" \
            system/product/priv-app/GmsCore \
            system/product/priv-app/Phonesky \
            system/system_ext/priv-app/GoogleServicesFramework \
            system/product/etc/permissions/privapp-permissions-google-product.xml \
            system/system_ext/etc/permissions/privapp-permissions-google-system-ext.xml)
    else
        log "  未找到 GMS prebuilt 载荷，打包无 GMS 基础镜像"
    fi
    # --owner=0 --group=0：payload 在构建机上 checkout 后 owner 是构建用户
    # （uid 可能为 1000，在 Android 里恰好是 system），统一固化为 root:root，
    # 与 system.img 原有文件（uid 0）及已验证的镜像布局保持一致。
    tar --xattrs --owner=0 --group=0 \
        -c vendor -C system --exclude="./vendor" . "${gms_args[@]}" \
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
    gms)     fetch_gms_payload ;;
    redroid) build_redroid ;;
    pack)    pack_image ;;
    all)     build_envd; apply_patches; build_redroid; pack_image ;;
    *) die "未知步骤: $1（可选: envd|patch|gms|redroid|pack|all）" ;;
esac
