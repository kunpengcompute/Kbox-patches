#!/bin/bash
# =============================================================================
# build_a15.sh —— 为 a15 (CF arm64) 编译 DAMON 替换内核
#
# 用法: build_a15.sh <AOSP_ROOT>
#
# 此脚本经过端到端实测验证, 逻辑与原始测试版本完全一致。
# 唯一改动: 路径从硬编码改为参数化。
# =============================================================================
set -euo pipefail

W="${1:?用法: $0 <AOSP_ROOT>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$SCRIPT_DIR/src/kernel-a15"
OUT="$SCRIPT_DIR/out/kernel-a15"
MODE="damon"

CLANG="$W/prebuilts/clang/host/linux-x86/clang-r522817/bin"
export PATH="$CLANG:$PATH"
export LOCALVERSION=""

log() { echo -e "\n===== [build_a15] $* ====="; }

[ -x "$CLANG/clang" ] || { echo "!! 缺 clang: $CLANG"; exit 1; }

# ── 1. 内核源码 ─────────────────────────────────────────
if [ ! -d "$SRC/.git" ]; then
    log "克隆 kernel_common deprecated/android15-6.6-2024-08"
    git clone --depth 1 -b deprecated/android15-6.6-2024-08 \
        https://github.com/aosp-mirror/kernel_common.git "$SRC"
fi
cd "$SRC"

# VIRTIO_PCI_LEGACY: bool → tristate (产出 .ko)
if grep -A1 "^config VIRTIO_PCI_LEGACY$" drivers/virtio/Kconfig | grep -q "bool"; then
    sed -i "/^config VIRTIO_PCI_LEGACY\$/{n;s/^\([ \t]*\)bool /\1tristate /}" drivers/virtio/Kconfig
    log "VIRTIO_PCI_LEGACY: bool → tristate"
fi

# ── 2. 基准 config ─────────────────────────────────────
log "从预编译内核提取基准 config"
mkdir -p "$OUT"
bash "$SCRIPT_DIR/extract_config.sh" "$W/kernel/prebuilts/6.6/arm64/kernel-6.6" > "$OUT/.config" 2>/dev/null
LINES=$(wc -l < "$OUT/.config")
log "提取 $LINES 行"

# ── 3. 修改 config ─────────────────────────────────────
log "应用 DAMON config"
sc() { "$SRC/scripts/config" --file "$OUT/.config" "$@"; }

# DAMON
sc -e DAMON -e DAMON_PADDR -e DAMON_RECLAIM

# vd 模块缺口 (预编译 vd 与我们内核 CRC 不兼容, 必须全部自编)
sc -m VIRTIO_NET -m FAILOVER -m NET_FAILOVER
sc -m DRM_VIRTIO_GPU -m HW_RANDOM_VIRTIO -m VIRTIO_INPUT
sc -m VIRTIO_DMA_SHARED_BUFFER -m VIRTIO_PMEM -m DMABUF_HEAPS_SYSTEM
sc -m VIRTIO_BLK -m VIRTIO_CONSOLE -m VIRTIO_PCI
sc -m VIRTIO_PCI_LEGACY -m VIRTIO_BALLOON -m ZRAM -m ZSMALLOC
sc -m VIRTIO_MMIO -m VIRTIO_VSOCKETS
sc -m CFG80211 -m MAC80211 -m MAC80211_HWSIM -m VIRT_WIFI

# 兼容性: 放行自编模块 + 钉死版本串
sc -d MODULE_SIG_PROTECT -d MODULE_SIG_ALL
sc -d LOCALVERSION_AUTO
sc --set-str LOCALVERSION "-android15-8-g02f25b80c91c-ab12341571-4k"
sc -d TRIM_UNUSED_KSYMS 2>/dev/null || true
sc --set-str UNUSED_KSYMS_WHITELIST "" 2>/dev/null || true
sc -d DEBUG_INFO_BTF -d DEBUG_INFO_BTF_MODULES

make O="$OUT" ARCH=arm64 LLVM=1 olddefconfig

# ── 4. 自检 ─────────────────────────────────────────────
log "config 自检"
grep -q "^CONFIG_DAMON_RECLAIM=y" "$OUT/.config" || { echo "!! DAMON_RECLAIM 未生效"; exit 1; }
grep -q "^CONFIG_LOCALVERSION=\"-android15-8-g02f25b80c91c-ab12341571-4k\"$" "$OUT/.config" \
    || { echo "!! LOCALVERSION 不正确"; exit 1; }
for c in VIRTIO_NET FAILOVER NET_FAILOVER DRM_VIRTIO_GPU HW_RANDOM_VIRTIO \
         VIRTIO_INPUT VIRTIO_DMA_SHARED_BUFFER VIRTIO_PMEM DMABUF_HEAPS_SYSTEM \
         VIRTIO_BLK VIRTIO_CONSOLE VIRTIO_PCI VIRTIO_PCI_LEGACY VIRTIO_BALLOON \
         ZRAM ZSMALLOC VIRTIO_MMIO VIRTIO_VSOCKETS; do
    grep -q "^CONFIG_${c}=m" "$OUT/.config" \
        || { echo "!! CONFIG_${c} 未能设为 m"; exit 1; }
done
echo "  全部通过"

# ── 5. 编译 ─────────────────────────────────────────────
log "编译 Image ($(nproc) 核)"
make O="$OUT" ARCH=arm64 LLVM=1 -j"$(nproc)" Image

# ── 6. 校验 ─────────────────────────────────────────────
IMG="$OUT/arch/arm64/boot/Image"
got=$(strings "$IMG" | grep -m1 "^Linux version " | awk "{print \$3}" || true)
log "版本串: ${got:-<未找到>}"
[ "$got" = "6.6.30-android15-8-g02f25b80c91c-ab12341571-4k" ] \
    || { echo "!! 不匹配: 期望 6.6.30-android15-8-g02f25b80c91c-ab12341571-4k"; exit 1; }

"$SRC/scripts/extract-ikconfig" "$IMG" > "$OUT/built.config" 2>/dev/null || true
grep -q "^CONFIG_DAMON_RECLAIM=y" "$OUT/built.config" \
    || { echo "!! Image 内无 DAMON"; exit 1; }
log "校验通过"

# ── 7. 替换预编译内核 ───────────────────────────────────
log "替换预编译内核"
KPRE="$W/kernel/prebuilts/6.6/arm64"
[ ! -f "$SCRIPT_DIR/kernel-6.6.stock.bak" ] && cp "$KPRE/kernel-6.6" "$SCRIPT_DIR/kernel-6.6.stock.bak" 2>/dev/null || true
cp "$IMG"            "$KPRE/kernel-6.6"
cp "$OUT/System.map" "$KPRE/System.map" 2>/dev/null || true
log "完成。下一步: modules_a15.sh $W"
