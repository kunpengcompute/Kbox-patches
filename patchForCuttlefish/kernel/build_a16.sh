#!/bin/bash
# =============================================================================
# build_kernel_a16_612.sh —— 为 a16 编译 6.12 DAMON 内核 (trunk_staging 用的是 6.12)
# 用法: ~/code/cuttlefish-workspace/build_kernel_a16_612.sh
# =============================================================================
set -euo pipefail

W="${1:?用法: $0 <AOSP_ROOT>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"; SRC="$SCRIPT_DIR/src/kernel-a16"
OUT="$SCRIPT_DIR/out/kernel-a16"
CLANG="$W/prebuilts/clang/host/linux-x86/clang-r547379/bin"
BASE_CFG="$OUT/baseline.config"; mkdir -p "$OUT"; bash "$SCRIPT_DIR/extract_config.sh" "$W/kernel/prebuilts/6.12/arm64/kernel-6.12" > "$BASE_CFG" 2>/dev/null
KPRE="$W/kernel/prebuilts/6.12/arm64"
BACKUP="$SCRIPT_DIR/kernel-6.12.stock.bak"
MARKER="$SCRIPT_DIR/.installed_kernel_a16"
EXPECT_VER="6.12.38-android16-5-g501f58f107ab-ab13974591-4k"

log() { echo -e "\n===== [build_kernel_a16_612] $* ====="; }

# ---------- 0. 前置 ----------
avail=$(df -BG --output=avail $OUT | tail -1 | tr -dc '0-9')
[ "$avail" -ge 30 ] || { echo "!! 磁盘不足"; exit 1; }
[ -f "$BASE_CFG" ] || { echo "!! 缺 $BASE_CFG"; exit 1; }
[ -x "$CLANG/clang" ] || { echo "!! 缺 clang: $CLANG"; exit 1; }
export PATH="$CLANG:$PATH"
export LOCALVERSION=""
log "clang: $(clang --version | head -1)"

# ---------- 1. 源码 (android16-6.12-2025-08, SUBLEVEL=38 精确匹配) ----------
if [ ! -d "$SRC/.git" ]; then
  log "克隆 kernel_common android16-6.12-2025-08"
  git clone --depth 1 -b android16-6.12-2025-08 \
      https://github.com/aosp-mirror/kernel_common.git "$SRC"
fi
cd "$SRC"
grep "^SUBLEVEL" Makefile

# ---------- 2. config ----------
log "准备 config"
mkdir -p "$OUT"
cp "$BASE_CFG" "$OUT/.config"
sc() { "$SRC/scripts/config" --file "$OUT/.config" "$@"; }

# DAMON (预编译完全没有)
sc -e DAMON -e DAMON_PADDR -e DAMON_RECLAIM

# vd 模块缺口
sc -m VIRTIO_NET -m FAILOVER -m NET_FAILOVER
sc -m DRM_VIRTIO_GPU -m HW_RANDOM_VIRTIO -m VIRTIO_INPUT
sc -m VIRTIO_DMA_SHARED_BUFFER -m VIRTIO_PMEM -m DMABUF_HEAPS_SYSTEM
sc -m CFG80211 -m MAC80211 -m MAC80211_HWSIM -m VIRT_WIFI
sc -m VIRTIO_MMIO

# 兼容性
sc -d MODULE_SIG_PROTECT -d MODULE_SIG_ALL
sc --set-str MODULE_SIG_PROTECT_LIST ""   # 6.12 新增的
sc -d LOCALVERSION_AUTO
sc --set-str LOCALVERSION "-android16-5-g501f58f107ab-ab13974591-4k"
sc -d TRIM_UNUSED_KSYMS
sc --set-str UNUSED_KSYMS_WHITELIST ""
sc -d GENDWARFKSYMS   # 6.12 新工具, clang 21 编译不了, 自编模块不需要
sc -d DEBUG_INFO_BTF -d DEBUG_INFO_BTF_MODULES

make O="$OUT" ARCH=arm64 LLVM=1 olddefconfig

# 自检
grep -q '^CONFIG_DAMON_RECLAIM=y' "$OUT/.config" || { echo "!! DAMON_RECLAIM 未生效"; exit 1; }
grep -q '^CONFIG_LOCALVERSION="-android16-5-g501f58f107ab-ab13974591-4k"$' "$OUT/.config" \
  || { echo "!! LOCALVERSION 不正确"; exit 1; }
if grep -q "^CONFIG_MODULE_SIG_PROTECT=y" "$OUT/.config"; then echo "!! PROTECT=y"; exit 1; fi
for c in VIRTIO_NET FAILOVER NET_FAILOVER DRM_VIRTIO_GPU HW_RANDOM_VIRTIO \
         VIRTIO_INPUT VIRTIO_DMA_SHARED_BUFFER VIRTIO_PMEM DMABUF_HEAPS_SYSTEM \
         CFG80211 MAC80211 MAC80211_HWSIM VIRTIO_MMIO; do
  grep -q "^CONFIG_${c}=m" "$OUT/.config" \
    || { echo "!! CONFIG_${c} 未能设为 m"; exit 1; }
done

# ---------- 3. 编译 ----------
log "编译 Image"
make O="$OUT" ARCH=arm64 LLVM=1 -j"$(nproc)" Image

# ---------- 4. 校验 ----------
IMG="$OUT/arch/arm64/boot/Image"
got=$(strings "$IMG" | grep -m1 '^Linux version ' | awk '{print $3}' || true)
log "版本串: ${got:-<未找到>}"
[ "$got" = "$EXPECT_VER" ] || { echo "!! 不匹配: 期望 $EXPECT_VER"; exit 1; }

"$SRC/scripts/extract-ikconfig" "$IMG" > "$OUT/built.config" 2>/dev/null || true
grep -q '^CONFIG_DAMON_RECLAIM=y' "$OUT/built.config" \
  || { echo "!! Image 内无 DAMON"; exit 1; }
log "校验通过; CRC: $(grep -w module_layout "$OUT/vmlinux.symvers" 2>/dev/null | awk '{print $1}')"

# ---------- 5. 替换 ----------
[ -f "$BACKUP" ] || cp -a "$KPRE/kernel-6.12" "$BACKUP"
[ -f "$W/System.map-6.12.stock.bak" ] || cp -a "$KPRE/System.map" "$W/System.map-6.12.stock.bak"
cp "$IMG"            "$KPRE/kernel-6.12"
cp "$OUT/System.map" "$KPRE/System.map"
sha=$(sha256sum "$KPRE/kernel-6.12" | awk '{print $1}')
echo "damon $sha $(date '+%F %T')" > "$MARKER"
log "完成; 下一步: modules_a16.sh $W"
