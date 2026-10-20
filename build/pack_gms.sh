#!/usr/bin/env bash
# =============================================================================
# GMS 统一维护脚本 —— 所有 GMS 相关操作集中于此
#
# 职责:
#   1. 集中维护 GMS 全部下载源与目录结构清单（APK 与 XML 均不入库）
#   2. 自动下载官方 MindTheGapps zip → sha256 校验 → 解出 APK/XML 还原到GMS目录
#      （<工作区>/gms-payload/，位于 git 仓库之外：项目内不保留任何 prebuilts
#       目录，fetch 时按清单自动创建目录并下载填充）
#   3. 输出镜像注入所需的 tar 参数（build_redroid.sh pack 拼入 Docker rootfs 流）
#
# 用法:
#   bash pack_gms.sh fetch      下载/校验/还原（幂等；pack 前自动执行，可提前单独跑）
#   bash pack_gms.sh tar-args   输出 tar 注入参数（每行一个，供 build_redroid.sh mapfile 读取）
#   bash pack_gms.sh            同 fetch
#
# 环境变量:
#   GMS_ZIP_URL    覆盖 zip 下载地址（自建代理/镜像），内容仍以 ZIP_SHA256 校验兜底
#   GMS_ZIP_CACHE  覆盖 zip 缓存目录（默认 <工作区>/downloads）
#   GMS_SKIP=1     跳过 GMS 下载与注入（产出无 GMS 基础镜像）
# =============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                # Kbox-patches-cubesanbox
WORKSPACE="$(cd "$REPO_ROOT/.." && pwd)"                # 工作区根（aosp-14 同级）
# GMS根路径（tar -C 目标）：位于仓库外的工作区（与 downloads/ 缓存同级），
# 项目内不保留任何 prebuilts 目录；fetch 时自动创建并下载填充
GMS_DIR="$WORKSPACE/gms-payload"
CACHE_DIR="${GMS_ZIP_CACHE:-$WORKSPACE/downloads}"

# 日志走 stderr：tar-args 的 stdout 必须只含注入参数（供 mapfile 捕获）
log() { echo -e "\033[1;32m$*\033[0m" >&2; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

gms_skip() { [ "${GMS_SKIP:-0}" = "1" ]; }

# ===== 下载源与GMS清单（GMS 唯一事实来源，升级 GMS 只改这里）=====
# 官方来源: MindTheGapps 14.0.0 arm64 —— GitHub Releases（Android 14 官方 GApps 包）
#           主页 https://mindthegapps.com/   仓库 https://github.com/MindTheGapps/14.0.0-arm64
# 只取核心三件套 + 两份 privapp 白名单；完整 GApps 含 SetupWizard/CarrierConfig 等
# 多余组件会触发 APEX 元数据冲突导致容器无法 boot，禁止整包拷入。
ZIP_URL="https://github.com/MindTheGapps/14.0.0-arm64/releases/download/MindTheGapps-14.0.0-arm64-20250203_200051/MindTheGapps-14.0.0-arm64-20250203_200051.zip"
ZIP_SHA256="6e1c3616862ce5b33e2b96074f86ae846eb1351a26a980e1ed140f8a7e7a4fd6"
# GitHub 直连慢时的公共镜像回退（内容一致性由 ZIP_SHA256 校验兜底，镜像不可信无影响）
ZIP_MIRRORS=(
    "https://gh-proxy.com/"
    "https://hub.gitmirror.com/"
    "https://ghfast.top/"
)
# GMS清单: "zip 内相对路径（= GMS目录相对路径）| 成员 sha256"
# 布局依据: 本 product 无独立 product/system_ext 分区镜像，分区内容实体在 system
# 分区内（system/product/...、system/system_ext/...），rootfs 根下以
# /product -> /system/product、/system_ext -> /system/system_ext 符号链接呈现，
# 运行时 PMS 依此把 GMS 识别为标准特权应用并按白名单授予 privileged 权限。
# 两个 XML 为 user 版 privapp 特权权限白名单，缺失则 GMS 无法通过开机强制校验。
MANIFEST=(
    "system/product/priv-app/GmsCore/GmsCore.apk|dfca71b10a2d5c99a36fb7b15436f2e6b529a439caf500aa7ff855bfa1aaa0a8"
    "system/product/priv-app/Phonesky/Phonesky.apk|a11f673c924a5900672793ec631408d0a8b0f50191cc22208da6bd5202e8bdf1"
    "system/system_ext/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk|e12c09b9af8e97397b68a464ea5613033c0404471d5c8259906f24c4aaed8783"
    "system/product/etc/permissions/privapp-permissions-google-product.xml|af730bf23ca2408fd642d64b5ca8a846b1d31c9a348368e6df26e91905b7bc11"
    "system/system_ext/etc/permissions/privapp-permissions-google-system-ext.xml|5ad3816372042840de3b9953cb6582fa84e55416100afca4da93b0dcf470aadb"
)

# ===== 内部函数 =====

# 全部GMS成员就位且 sha256 校验通过 → 返回 0
all_present() {
    local e path want sha
    for e in "${MANIFEST[@]}"; do
        path="${e%%|*}"; want="${e##*|}"
        [ -f "$GMS_DIR/$path" ] || return 1
        sha="$(sha256sum "$GMS_DIR/$path" | awk '{print $1}')"
        [ "$sha" = "$want" ] || return 1
    done
    return 0
}

# 确保 zip 就绪（缓存命中或下载），成功后向 stdout 输出 zip 路径
ensure_zip() {
    local zip_file="$CACHE_DIR/${ZIP_URL##*/}"
    if [ -f "$zip_file" ] && echo "$ZIP_SHA256  $zip_file" | sha256sum -c --status 2>/dev/null; then
        log "  使用已缓存的 zip: $zip_file"
        echo "$zip_file"; return 0
    fi
    rm -f "$zip_file"; mkdir -p "$CACHE_DIR"
    local -a sources=()
    [ -n "${GMS_ZIP_URL:-}" ] && sources+=("$GMS_ZIP_URL")
    sources+=("$ZIP_URL")
    local m; for m in "${ZIP_MIRRORS[@]}"; do sources+=("${m}${ZIP_URL}"); done
    local src ok=0
    for src in "${sources[@]}"; do
        log "  下载 GMS zip (~430MB): $src"
        if curl -fL --retry 3 --retry-delay 2 -C - -o "$zip_file" "$src" \
           && echo "$ZIP_SHA256  $zip_file" | sha256sum -c --status 2>/dev/null; then
            ok=1; break
        fi
        rm -f "$zip_file"
        log "  下载失败或校验不通过，尝试下一个源 ..."
    done
    [ "$ok" -eq 1 ] || die "GMS zip 下载失败。可 export GMS_ZIP_URL=<可用地址> 后重试，或手动下载 $ZIP_URL 放到 $zip_file"
    log "  zip sha256 校验通过: ${zip_file##*/}"
    echo "$zip_file"
}

# ===== 子命令 =====

# fetch: 下载/校验/还原全部GMS（幂等）
cmd_fetch() {
    gms_skip && { log "[gms] GMS_SKIP=1，跳过 GMS 下载"; return 0; }
    log "[gms] 检查/下载 GMS （3 APK + 2 XML）"
    command -v curl >/dev/null   || die "未找到 curl（GMS 下载需要）"
    command -v unzip >/dev/null || die "未找到 unzip（GMS 解压需要）"

    if all_present; then
        log "  5 个GMS成员均已就位且校验通过，跳过下载"
        return 0
    fi

    local zip_file; zip_file="$(ensure_zip)"

    local e path want sha
    for e in "${MANIFEST[@]}"; do
        path="${e%%|*}"; want="${e##*|}"
        mkdir -p "$(dirname "$GMS_DIR/$path")"
        unzip -p "$zip_file" "$path" > "$GMS_DIR/$path" || die "从 zip 解压失败: $path"
        sha="$(sha256sum "$GMS_DIR/$path" | awk '{print $1}')"
        [ "$sha" = "$want" ] || die "GMS成员 sha256 不匹配: $path（期望 $want，实际 $sha）"
        log "  还原并校验通过: $path"
    done

    # sudo 场景下把产物属主还给真实用户，避免工作区出现 root 属主文件
    if [ -n "${SUDO_USER:-}" ]; then
        chown "$SUDO_USER":"$(id -gn "$SUDO_USER")" "$zip_file" 2>/dev/null || true
        chown -R "$SUDO_USER":"$(id -gn "$SUDO_USER")" "$GMS_DIR" 2>/dev/null || true
    fi
}

# tar-args: 向 stdout 输出 tar 注入参数（-C GMS根路径 + 5 个成员），stdout 不得混入其他内容
cmd_tar_args() {
    gms_skip && return 0
    all_present || cmd_fetch          # 正常流程 pack 已先 fetch，这里只是幂等兜底
    echo "-C"
    echo "$GMS_DIR"
    local e p
    for e in "${MANIFEST[@]}"; do
        p="${e%%|*}"
        case "$p" in
            *.apk) echo "$(dirname "$p")" ;;   # priv-app APK 以其所在目录为归档成员
            *)     echo "$p" ;;
        esac
    done
}

case "${1:-fetch}" in
    fetch)    cmd_fetch ;;
    tar-args) cmd_tar_args ;;
    *) die "未知子命令: $1（可选: fetch|tar-args）" ;;
esac
