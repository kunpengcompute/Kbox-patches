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
# 环境变量（GMS_LOCAL / GMS_LOCAL_DIR / GMS_ZIP_FILE / GMS_SKIP 默认在
# pack_gms.conf 中配置，同名环境变量可覆盖）:
#   GMS_LOCAL=1    本地模式：用本地 GMS 文件打包（GMS_LOCAL_DIR 或 GMS_ZIP_FILE），
#                  校验不通过即报错、绝不联网下载；缺省/0 走 ZIP_URL 下载
#   GMS_LOCAL_DIR  本地已还原的 GMS 载荷根目录（3 APK + 2 XML 已就位且校验通过）
#   GMS_ZIP_FILE   本地已下载好的 GMS zip 文件路径（sha256 校验通过即用）
#   GMS_ZIP_URL    覆盖 zip 下载地址（自建代理/镜像），内容仍以 ZIP_SHA256 校验兜底
#   GMS_ZIP_CACHE  覆盖 zip 缓存目录（默认 <工作区>/downloads）
#   GMS_SKIP=1     跳过 GMS 下载与注入（产出无 GMS 基础镜像）
# =============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"                # Kbox-patches-cubesanbox
WORKSPACE="$(cd "$REPO_ROOT/.." && pwd)"                # 工作区根（aosp-14 同级）
# GMS 载荷根目录（GMS_DIR，tar -C 目标）与 zip 缓存目录。
# GMS_DIR 在 source pack_gms.conf 之后依据 GMS_LOCAL 开关决定：
#   本地模式 = GMS_LOCAL_DIR（现成载荷）；下载模式 = 工作区默认目录 gms-payload
CACHE_DIR="${GMS_ZIP_CACHE:-$WORKSPACE/downloads}"

# 日志走 stderr：tar-args 的 stdout 必须只含注入参数（供 mapfile 捕获）
log() { echo -e "\033[1;32m$*\033[0m" >&2; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

gms_skip() { [ "${GMS_SKIP:-0}" = "1" ]; }

# ===== 下载源与GMS清单 =====
# 下载源（ZIP_URL / ZIP_SHA256 / ZIP_MIRRORS）含第三方下载链接，随库提交在
# 同目录 pack_gms.conf（脚本启动时 source，可用环境变量 GMS_CONFIG_FILE 覆盖
# 路径）；GMS 成员清单（MANIFEST，仅路径与 sha256）随脚本入库。
# 升级 GMS 时两处需同步修改。
CONFIG_FILE="${GMS_CONFIG_FILE:-$SCRIPT_DIR/pack_gms.conf}"
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
else
    die "未找到 GMS 下载源配置文件: $CONFIG_FILE
请基于 pack_gms.conf 创建并填写 ZIP_URL / ZIP_SHA256 / ZIP_MIRRORS，
或设置 GMS_CONFIG_FILE 指向已有配置文件。"
fi

# ===== 本地/下载来源开关（GMS_LOCAL 等默认在 pack_gms.conf 中配置）=====
# 兜底默认值：pack_gms.conf 缺项时取环境变量或如下缺省，保证变量必定义。
GMS_LOCAL="${GMS_LOCAL:-0}"
GMS_LOCAL_DIR="${GMS_LOCAL_DIR:-}"
GMS_ZIP_FILE="${GMS_ZIP_FILE:-}"
if [ "$GMS_LOCAL" = "1" ]; then
    # 本地模式：GMS_LOCAL_DIR 与 GMS_ZIP_FILE 至少填一个
    [ -n "$GMS_LOCAL_DIR" ] || [ -n "$GMS_ZIP_FILE" ] \
        || die "GMS_LOCAL=1 但未配置本地来源：pack_gms.conf 中的 GMS_LOCAL_DIR（已还原载荷目录）或 GMS_ZIP_FILE（本地 zip）至少填一个"
    if [ -n "$GMS_LOCAL_DIR" ]; then
        GMS_DIR="$GMS_LOCAL_DIR"              # 直接用现成载荷
    else
        GMS_DIR="$WORKSPACE/gms-payload"       # 仅指定 zip：解压还原到默认载荷目录
    fi
else
    # 下载模式：载荷落工作区默认目录，GMS_LOCAL_DIR 不参与
    GMS_DIR="$WORKSPACE/gms-payload"
fi

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
    # 本地直接指定 zip 文件：sha256 校验通过即用（免下载）；不通过则报错终止
    if [ -n "${GMS_ZIP_FILE:-}" ]; then
        if [ -f "$GMS_ZIP_FILE" ] \
           && echo "$ZIP_SHA256  $GMS_ZIP_FILE" | sha256sum -c --status 2>/dev/null; then
            log "  使用本地指定 zip: $GMS_ZIP_FILE"
            echo "$GMS_ZIP_FILE"; return 0
        fi
        die "本地指定 zip 校验不通过: $GMS_ZIP_FILE（sha256 与 ZIP_SHA256 不符，或文件不存在）"
    fi
    # 本地模式（GMS_LOCAL=1）严禁回退下载：走到这里说明 GMS_LOCAL_DIR 载荷不完整
    # /校验失败、且未配置可用 GMS_ZIP_FILE，直接报错终止而非联网下载。
    if [ "${GMS_LOCAL:-0}" = "1" ]; then
        die "GMS_LOCAL=1：本地 GMS 载荷校验未通过且无可用本地 zip（GMS_ZIP_FILE）。请检查 pack_gms.conf 中的 GMS_LOCAL_DIR 内容，或改 GMS_LOCAL=0 走下载。"
    fi
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
