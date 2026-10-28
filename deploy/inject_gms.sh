#!/usr/bin/env bash
# ==============================================================================
# inject_gms.sh
# ------------------------------------------------------------------------------
# 将 GMS 载荷注入无 GMS 基础镜像，生成带 GMS 的新镜像。
#
# 原理：
#   build_redroid.sh pack（ENABLE_GMS=0）产出的镜像里分区内容是直接展开在
#   rootfs 的（无 system.img/vendor.img 文件），GMS 目标是 /system 下的普通
#   目录（product/priv-app、system_ext/priv-app、etc/permissions）。因此可
#   在部署期用与 inject_kbox.sh 同构的方式注入：
#     1) docker create 基础镜像（空容器，不启动）
#     2) docker cp 把 GMS 文件写入容器 rootfs 的 /system/...（overlay upper 层）
#     3) docker commit 生成新镜像
#   与打包期 tar 注入（pack_gms.sh tar-args）产出等价：同为 rootfs 普通文件。
#
# 载荷与校验复用 pack_gms.sh（唯一事实来源）：
#   - bash pack_gms.sh fetch   下载/校验/还原 GMS（幂等，sha256 兜底）
#   - bash pack_gms.sh tar-args  输出注入成员清单（-C GMS_DIR + 每行一个成员）
#   本脚本不重复维护清单与哈希：成员与载荷根均取自 tar-args 输出，不依赖
#   仓库外的固定工作区布局；本地产物全部落在临时目录（WORK_DIR）中。
#
# 用法：
#   sudo bash inject_gms.sh                     # 基础镜像默认取无 GMS 打包产物
#   BASE_IMAGE=... NEW_IMAGE=... sudo bash inject_gms.sh   # 覆盖镜像名
#
# 依赖：root（chown root:root + docker 操作，与 pack_image/inject_kbox 一致）
# ==============================================================================

set -e

# ==============================================================================
# 一、配置区
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"     # Kbox-patches

# GMS 统一维护脚本（清单/下载/校验唯一来源，与 build_redroid.sh 共用）
GMS_SCRIPT="$REPO_ROOT/build/pack_gms.sh"
# GMS 载荷根不在此预设：以 pack_gms.sh tar-args 输出的实际路径为准（见
# resolve_members），本脚本不依赖仓库外的固定工作区布局。

# 临时工作目录（脚本结束时自动清理，不落任何产物到仓库/工作区）
WORK_DIR="${WORK_DIR:-/tmp/gms_inject_$$}"
WORKSPACE="$WORK_DIR/workspace"  # 临时工作区（注入树/校验文件均在其下）
STAGE="$WORKSPACE/rootfs"        # 组装后的注入树（rootfs 相对布局）
VERIFY_DIR="$WORKSPACE/verify"   # 校验用临时目录

# 基础镜像：build_redroid.sh 以 ENABLE_GMS=0 打包的无 GMS 产物
BASE_IMAGE="${BASE_IMAGE:-redroid:14.0.0_r75_arm64_only}"
# 注入完成后生成的新镜像标签
NEW_IMAGE="${NEW_IMAGE:-redroid:14.0.0_r75_arm64_only_gms}"

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

# ==============================================================================
# 二、执行区
# ==============================================================================

# 1. 确保 GMS 载荷就位（fetch 幂等，sha256 校验；失败即中止）
prepare_payload() {
    echo "[1/6] 检查/下载 GMS 载荷（复用 pack_gms.sh fetch）..."
    bash "$GMS_SCRIPT" fetch
}

# 2. 从 tar-args 解析注入成员清单（stdout 前两行为 -C / GMS_DIR，其余为成员）
resolve_members() {
    echo "[2/6] 解析 GMS 注入成员清单..."
    local -a tar_lines
    mapfile -t tar_lines < <(bash "$GMS_SCRIPT" tar-args)
    # 载荷根以 pack_gms.sh 输出为准（其内部按自身脚本位置定位，此处不重复推算）
    GMS_DIR="${tar_lines[1]:-}"
    [[ -n "$GMS_DIR" && -d "$GMS_DIR" ]] || die "pack_gms.sh 未输出有效的 GMS 载荷根: $GMS_DIR"
    MEMBERS=("${tar_lines[@]:2}")
    [[ "${#MEMBERS[@]}" -gt 0 ]] || die "pack_gms.sh 未输出任何 GMS 成员"
    local m
    for m in "${MEMBERS[@]}"; do
        [[ -e "$GMS_DIR/$m" ]] || die "GMS 成员缺失: $GMS_DIR/$m"
    done
    echo "    载荷根: $GMS_DIR"
    echo "    共 ${#MEMBERS[@]} 个成员：$(printf '%s ' "${MEMBERS[@]//system\//}")"
}

# 3. 组装注入树并固化为 root:root（与打包期 tar --owner=0 --group=0 等价：
#    载荷下载后属主为构建用户 uid，在 Android 里恰好是 system，必须统一为 0:0）
stage_payload() {
    echo "[3/6] 组装注入树并固化为 root:root..."
    local m
    for m in "${MEMBERS[@]}"; do
        mkdir -p "$STAGE/$(dirname "$m")"
        cp -a "$GMS_DIR/$m" "$STAGE/$m"
    done
    chown -R 0:0 "$STAGE"
}

# 4. 从基础镜像创建临时容器（不启动）
create_container() {
    echo "[4/6] 从 $BASE_IMAGE 创建临时容器..."
    if [[ -z "$(docker images -q "$BASE_IMAGE" 2>/dev/null)" ]]; then
        die "基础镜像不存在: $BASE_IMAGE（请先以 ENABLE_GMS=0 完成 build_redroid.sh pack）"
    fi
    NID=$(docker create "$BASE_IMAGE" true)
}

# 5. 注入 GMS 并 commit 为新镜像
#    docker cp "$STAGE/." -> /：把注入树内容合并进 rootfs（/system 已存在，
#    逐路径 merge；GMS 路径在无 GMS 基础镜像中不存在，均为新增文件）。
#    cp 的 -a 保留 mode/uid/gid（staging 已 chown 0:0）；SELinux xattr 与打包期
#    tar 注入一致（zip 解出文件本就不带 Android file_contexts，运行时以镜像
#    默认 context 落盘），两路径行为对齐。
inject_and_commit() {
    echo "[5/6] 注入 GMS 并生成新镜像 $NEW_IMAGE..."
    docker cp "$STAGE/." "$NID:/"
    docker commit "$NID" "$NEW_IMAGE" >/dev/null
    docker rm "$NID" >/dev/null 2>&1 || true
    NID=""
}

# 6. 校验新镜像内的 GMS 成员（与 GMS_DIR 源文件 sha256 比对；fetch 已校验过源）
verify_result() {
    echo "[6/6] 校验新镜像内容..."
    local vid
    vid=$(docker create "$NEW_IMAGE" true)
    mkdir -p "$VERIFY_DIR"
    local m src apk want got out
    for m in "${MEMBERS[@]}"; do
        out="$VERIFY_DIR/$(basename "$m")"
        if [[ -f "$GMS_DIR/$m" ]]; then
            # 文件成员（白名单 XML）
            docker cp "$vid:/$m" "$out"
            want=$(sha256sum "$GMS_DIR/$m" | awk '{print $1}')
            got=$(sha256sum "$out" | awk '{print $1}')
        else
            # 目录成员（priv-app，内含唯一一个 APK）
            apk=$(find "$GMS_DIR/$m" -maxdepth 1 -name '*.apk' | head -n 1)
            [[ -n "$apk" ]] || die "GMS_DIR 成员目录内未找到 apk: $m"
            docker cp "$vid:/$m" "$out"
            want=$(sha256sum "$apk" | awk '{print $1}')
            got=$(sha256sum "$out/$(basename "$apk")" | awk '{print $1}')
        fi
        if [[ "$want" = "$got" ]]; then
            echo "    OK  $(basename "$m")"
        else
            echo "    FAIL $(basename "$m")"
            die "新镜像内成员 sha256 不一致: $m"
        fi
    done
    docker rm "$vid" >/dev/null 2>&1 || true
    echo "==== 注入完成: $NEW_IMAGE ($(docker images -q "$NEW_IMAGE" | head -c 12)) ===="
}

cleanup() {
    rm -rf "$WORK_DIR"
    if [[ -n "${NID:-}" ]]; then
        docker rm "$NID" >/dev/null 2>&1 || true
    fi
}

main() {
    [ "$(id -u)" -eq 0 ] || die "注入需 root（chown root:root 与 docker 操作），请用 sudo 运行"
    command -v docker >/dev/null || die "未找到 docker"
    command -v sha256sum >/dev/null || die "未找到 sha256sum"
    [ -f "$GMS_SCRIPT" ] || die "未找到 pack_gms.sh: $GMS_SCRIPT"

    trap cleanup EXIT
    prepare_payload
    resolve_members
    stage_payload
    create_container
    inject_and_commit
    verify_result
}

main "$@"
