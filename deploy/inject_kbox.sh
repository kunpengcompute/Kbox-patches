#!/usr/bin/env bash
# ==============================================================================
# inject_kbox.sh
# ------------------------------------------------------------------------------
# 将 Kbox so 库压缩包导入基础 redroid 镜像，生成沙箱的新镜像。
#
# 原理：
#   redroid 镜像内的 Android 分区以 system.img / vendor.img 文件形式存在，
#   容器启动时才挂载。因此只需替换 vendor.img：
#     1) 用 debugfs 把 Kbox so库 写入 /lib64/hw/
#     2) docker commit 生成新镜像
#
# 支持的压缩包格式（二选一）：
#   A. Kbox-BoostKit-boostcph*-sbx-*.zip          直接含 product_prebuilt
#   B. BoostKit-boostcph-kbox*.zip                外层壳包，解压后含 A 包
#   脚本自动识别：壳包会先解压并定位内层 A 包，再按 A 包流程处理。
#
# 用法：
#   bash inject_kbox.sh                      # 自动匹配当前目录 A/B 包
#   bash inject_kbox.sh <zip路径>            # 显式指定（A/B 均可）
#   BASE_IMAGE=... NEW_IMAGE=... bash inject_kbox.sh   # 覆盖镜像名
# ==============================================================================

set -e

# ==============================================================================
# 一、配置区
# ==============================================================================

# 基础镜像：不含 kbox so 库（由 redroid 编译流程直接产出）
BASE_IMAGE="${BASE_IMAGE:-redroid:14.0.0_r75_arm64_only_base}"

# 注入完成后生成的新镜像标签
NEW_IMAGE="${NEW_IMAGE:-redroid:14.0.0_r75_arm64_only_withkbox}"

# 临时工作目录（脚本结束时自动清理）
WORK_DIR="${WORK_DIR:-/tmp/kbox_inject_$$}"

# 已创建的临时容器 ID（track 全部，供任何失败路径下统一清理）
TMP_CONTAINERS=()

# 注入到 vendor 分区的目标路径（arm64-only 构建只有 64 位目录；zip 含 32 位
# 产物时也一并注入，保证兼容）
SO_TARGET_64="/lib64/hw"
SO_TARGET_32="/lib/hw"

# 有效载荷 zip：优先取参数 $1 或环境变量，否则自动匹配两种命名格式
#   A 包：Kbox-BoostKit-boostcph*-sbx-*.zip
#   B 包：BoostKit-boostcph-kbox*.zip
ZIP_FILE="${1:-${ZIP_FILE:-}}"
if [[ -z "$ZIP_FILE" ]]; then
    ZIP_FILE=$(ls -1 Kbox-BoostKit-boostcph*-sbx-*.zip 2>/dev/null | head -n 1 || true)
    if [[ -z "$ZIP_FILE" ]]; then
        ZIP_FILE=$(ls -1 BoostKit-boostcph-kbox*.zip 2>/dev/null | head -n 1 || true)
    fi
fi

if [[ -z "$ZIP_FILE" || ! -f "$ZIP_FILE" ]]; then
    echo "错误：未找到 zip 文件" >&2
    echo "  请显式传入路径，或将符合以下任一命名的 zip 置于当前目录：" >&2
    echo "    A: Kbox-BoostKit-boostcph*-sbx-*.zip" >&2
    echo "    B: BoostKit-boostcph-kbox*.zip" >&2
    exit 1
fi

# 内层有效载荷 zip（当输入为壳包时定位到的 A 包）
PAYLOAD_ZIP="$ZIP_FILE"

# ==============================================================================
# 二、执行区
# ==============================================================================

# 将单个文件写入 vendor.img 内的指定路径（debugfs write 目标已存在会失败，先 rm）
write_into_vendor_img() {
    local img="$1" src="$2" dst="$3"
    debugfs -w -R "rm $dst" "$img" >/dev/null 2>&1 || true
    debugfs -w -R "write $src $dst" "$img" >/dev/null 2>&1 || {
        echo "  WARN: 写入 $dst 失败" >&2
        return 1
    }
}

# 若输入为B包，解压并定位内层 A 包
resolve_payload_zip() {
    if ! unzip -l "$ZIP_FILE" 2>/dev/null | awk '{print $4}' | grep -qE '\.zip$'; then
        return 0    # 已是 A 包，直接使用
    fi
    echo "[0/6] 检测到 $ZIP_FILE，解压定位内层载荷包 ..."
    mkdir -p "$WORK_DIR/outer"
    unzip -q -o "$ZIP_FILE" -d "$WORK_DIR/outer"
    PAYLOAD_ZIP=$(find "$WORK_DIR/outer" -name 'Kbox-BoostKit-boostcph*-sbx-*.zip' | head -n 1 || true)
    if [[ -z "$PAYLOAD_ZIP" ]]; then
        PAYLOAD_ZIP=$(find "$WORK_DIR/outer" -name 'Kbox-*.zip' | head -n 1 || true)
    fi
    if [[ -z "$PAYLOAD_ZIP" ]]; then
        PAYLOAD_ZIP=$(find "$WORK_DIR/outer" -name '*.zip' | head -n 1 || true)
    fi
    if [[ -z "$PAYLOAD_ZIP" || ! -f "$PAYLOAD_ZIP" ]]; then
        echo "错误：BoostKit-boostcph-kbox*.zip 包内未找到 Kbox-BoostKit-boostcph*-sbx-*.zip" >&2
        exit 1
    fi
    echo "    内层载荷包: $(basename "$PAYLOAD_ZIP")"
}

# 1. 解压载荷包，得到 product_prebuilt 目录
extract_zip() {
    echo "[1/6] 解压 $(basename "$PAYLOAD_ZIP") ..."
    mkdir -p "$WORK_DIR"
    unzip -q -o "$PAYLOAD_ZIP" -d "$WORK_DIR"
    if [[ ! -d "$WORK_DIR/product_prebuilt" ]]; then
        echo "错误：包中未找到 product_prebuilt 目录" >&2
        exit 1
    fi
}

# 2. 从基础镜像取出 vendor.img
fetch_vendor_img() {
    echo "[2/6] 从 $BASE_IMAGE 取出 vendor.img ..."
    CID=$(docker create "$BASE_IMAGE" true)
    TMP_CONTAINERS+=("$CID")
    docker cp "${CID}:/vendor.img" "$WORK_DIR/vendor.img"
    docker rm "$CID" >/dev/null 2>&1 || true
}

# 3. 将 kbox so 库注入 vendor.img 的 /lib64/hw/（及 /lib/hw/）
inject_so_libs() {
    echo "[3/6] 注入 kbox so 库 (gps.kbox.so / gralloc.kbox_soft.so) ..."
    local pk="$WORK_DIR/product_prebuilt"
    write_into_vendor_img "$WORK_DIR/vendor.img" "$pk/gps/lib64/hw/gps.kbox.so"           "$SO_TARGET_64/gps.kbox.so"
    write_into_vendor_img "$WORK_DIR/vendor.img" "$pk/soft_gralloc/lib64/hw/gralloc.kbox_soft.so" "$SO_TARGET_64/gralloc.kbox_soft.so"
    if [[ -f "$pk/gps/lib/hw/gps.kbox.so" ]]; then
        write_into_vendor_img "$WORK_DIR/vendor.img" "$pk/gps/lib/hw/gps.kbox.so"         "$SO_TARGET_32/gps.kbox.so"
    fi
    if [[ -f "$pk/soft_gralloc/lib/hw/gralloc.kbox_soft.so" ]]; then
        write_into_vendor_img "$WORK_DIR/vendor.img" "$pk/soft_gralloc/lib/hw/gralloc.kbox_soft.so" "$SO_TARGET_32/gralloc.kbox_soft.so"
    fi
}

# 4. 将注入后的 vendor.img 写回并 commit 为新镜像
commit_new_image() {
    echo "[4/6] 生成新镜像 $NEW_IMAGE ..."
    NID=$(docker create "$BASE_IMAGE" true)
    TMP_CONTAINERS+=("$NID")
    docker cp "$WORK_DIR/vendor.img" "${NID}:/vendor.img"
    docker commit "$NID" "$NEW_IMAGE" >/dev/null
    docker rm "$NID" >/dev/null 2>&1 || true
}

# 5. 校验新镜像内的 so 与属性
verify_result() {
    echo "[5/6] 校验新镜像内容 ..."
    local vid
    vid=$(docker create "$NEW_IMAGE" true)
    TMP_CONTAINERS+=("$vid")
    docker cp "${vid}:/vendor.img" "$WORK_DIR/verify.img"
    docker rm "$vid" >/dev/null 2>&1 || true
    echo "--- /lib64/hw/ 下的 kbox so ---"
    debugfs -R "ls -l $SO_TARGET_64/" "$WORK_DIR/verify.img" 2>/dev/null | grep kbox || echo "(无)"
    echo "--- gpu_config.sh 的 gralloc 设置（应含 kbox_soft）---"
    debugfs -R "cat /bin/gpu_config.sh" "$WORK_DIR/verify.img" 2>/dev/null | grep 'setprop ro.hardware.gralloc' || echo "(无)"
    echo "--- vendor build.prop 中的 kbox 属性 ---"
    debugfs -R "cat /build.prop" "$WORK_DIR/verify.img" 2>/dev/null | grep -E 'kbox' || echo "(无)"
}

# 清理临时文件与残留容器（trap EXIT 保证正常结束与任何失败路径都执行）
cleanup() {
    local c
    rm -rf "$WORK_DIR"
    for c in "${TMP_CONTAINERS[@]}"; do
        docker rm -f "$c" >/dev/null 2>&1 || true
    done
}

# 注册退出清理：覆盖 set -e 中途失败、显式 exit 与 Ctrl-C（bash 对未处理信号
# 退出同样会执行 EXIT trap）
trap cleanup EXIT

# 主流程
main() {
    resolve_payload_zip
    extract_zip
    fetch_vendor_img
    inject_so_libs
    commit_new_image
    verify_result
    echo "==== 注入完成: $NEW_IMAGE ($(docker images -q "$NEW_IMAGE" | head -c 12)) ===="
}

main "$@"
