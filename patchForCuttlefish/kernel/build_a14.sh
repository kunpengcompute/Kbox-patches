#!/bin/bash
# =============================================================================
# build_kernel_a14.sh —— 为 a14 (CF arm64, 6.1) 编译 DAMON 内核
# 注意: 6.1 没有 skip_anon 参数 (cmdline 里传了会被忽略, 无影响)
# =============================================================================
set -euo pipefail

W="${1:?用法: $0 <AOSP_ROOT>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"; SRC="$SCRIPT_DIR/src/kernel-a14"
OUT="$SCRIPT_DIR/out/kernel-a14"
CLANG="$W/prebuilts/clang/host/linux-x86/clang-r487747c/bin"
BASE_CFG="$OUT/baseline.config"; mkdir -p "$OUT"; bash "$SCRIPT_DIR/extract_config.sh" "$W/kernel/prebuilts/6.1/arm64/kernel-6.1" > "$BASE_CFG" 2>/dev/null
KPRE="$W/kernel/prebuilts/6.1/arm64"
BACKUP="$SCRIPT_DIR/kernel-6.1.stock.bak"
MARKER="$SCRIPT_DIR/.installed_kernel_a14"
EXPECT_VER="6.1.23-android14-4-00257-g7e35917775b8-ab9964412"

log() { echo -e "\n===== [build_kernel_a14] $* ====="; }

# ---------- 0. 前置 ----------
avail=$(df -BG --output=avail $OUT | tail -1 | tr -dc '0-9')
[ "$avail" -ge 30 ] || { echo "!! 磁盘不足"; exit 1; }
[ -f "$BASE_CFG" ] || { echo "!! 缺 $BASE_CFG"; exit 1; }
[ -x "$CLANG/clang" ] || { echo "!! 缺 clang"; exit 1; }
export PATH="$CLANG:$PATH"
export LOCALVERSION=""
log "clang: $(clang --version | head -1)"

# ---------- 1. 源码 (android14-6.1-2023-05-exp, SUBLEVEL=25 → patch 23) ----------
if [ ! -d "$SRC/.git" ]; then
  log "克隆 kernel_common android14-6.1-2023-05-exp"
  git clone --depth 1 -b android14-6.1-2023-05-exp \
      https://github.com/aosp-mirror/kernel_common.git "$SRC"
fi
cd "$SRC"

# Patch SUBLEVEL 25 -> 23
if grep -q "^SUBLEVEL = 25$" Makefile; then
  sed -i "s/^SUBLEVEL = 25$/SUBLEVEL = 23/" Makefile
  log "SUBLEVEL: 25 -> 23"
fi

# Patch page_reporting: 6.1 unconditionally overwrites cmdline value.
# Use identical pattern for grep and sed to avoid silent mismatch.
PR_PATTERN="page_reporting_order = prdev->order ? : pageblock_order;"
if grep -q "respect cmdline" "$SRC/mm/page_reporting.c"; then
  log "page_reporting: already patched"
elif grep -Fq "$PR_PATTERN" "$SRC/mm/page_reporting.c"; then
  sed -i "s|$PR_PATTERN|if (page_reporting_order == MAX_ORDER) /* respect cmdline */\n\tpage_reporting_order = prdev->order ? : pageblock_order;|" "$SRC/mm/page_reporting.c"
  log "page_reporting: cmdline guard added"
else
  echo "!! WARNING: page_reporting pattern not found in kernel source"
fi

# VIRTIO_PCI_LEGACY 在 6.1 里可能是 bool, 检查并处理
if grep -A2 "^config VIRTIO_PCI_LEGACY" drivers/virtio/Kconfig 2>/dev/null | grep -q "bool"; then
  log "VIRTIO_PCI_LEGACY 是 bool (同 a15), 不需要 patch"
fi

# ---------- 2. config ----------
log "准备 config"
mkdir -p "$OUT"
cp "$BASE_CFG" "$OUT/.config"
sc() { "$SRC/scripts/config" --file "$OUT/.config" "$@"; }

# DAMON
sc -e DAMON -e DAMON_PADDR -e DAMON_RECLAIM

# vd 模块缺口
sc -m VIRTIO_BLK -m VIRTIO_CONSOLE -m VIRTIO_PCI
sc -m VIRTIO_BALLOON -m ZRAM -m ZSMALLOC
sc -m VIRTIO_NET -m FAILOVER -m NET_FAILOVER
sc -m DRM_VIRTIO_GPU -m HW_RANDOM_VIRTIO -m VIRTIO_INPUT
sc -m VIRTIO_DMA_SHARED_BUFFER -m VIRTIO_PMEM -m DMABUF_HEAPS_SYSTEM
sc -m VIRTIO_MMIO -m VIRTIO_VSOCKETS
# 无线栈 (vd 里有 mac80211_hwsim, 需要配套)
sc -m CFG80211 -m MAC80211 -m MAC80211_HWSIM 2>/dev/null || true
sc -m VIRT_WIFI 2>/dev/null || true

# 兼容性

# vd 全量模块补齐 (修复 vendor_dlkm CRC + dlkm_loader 崩溃)
sc -e GOLDFISH
sc -m SERIO_AMBAKMI -m MMC_ARMMMCI
sc -m BT_INTEL -m BT_RTL -m BT_HCIBTUSB -m BT_HCIVHCI
sc -m CLK_VEXPRESS_OSC -m DRM_GEM_DMA_HELPER
sc -m CPUFREQ_DUMMY -m USB_DUMMY_HCD
sc -m BATTERY_GOLDFISH -m GOLDFISH_PIPE
sc -m CAN_GS_USB -m MOUSE_PS2 -m USB_PULSE8_CEC
sc -m DRM_PL111 -m RTC_DRV_TEST
sc -m USBIP_CORE -m USBIP_VHCI_HCD
sc -m VEXPRESS_CONFIG -m MFD_VEXPRESS_SYSREG
sc -m SND_VIRTIO -m DRM_VKMS

sc -d MODULE_SIG_PROTECT -d MODULE_SIG_ALL
sc -d LOCALVERSION_AUTO
# 注意: a14 的 LOCALVERSION 为空, 整个后缀靠 LOCALVERSION_AUTO 生成
# 我们钉死完整后缀 (无 -4k 后缀, 与 a15/a16 不同)
sc --set-str LOCALVERSION "-android14-4-00257-g7e35917775b8-ab9964412"
sc -d TRIM_UNUSED_KSYMS 2>/dev/null || true
sc --set-str UNUSED_KSYMS_WHITELIST "" 2>/dev/null || true
sc -d DEBUG_INFO_BTF -d DEBUG_INFO_BTF_MODULES

make O="$OUT" ARCH=arm64 LLVM=1 olddefconfig

# 自检
grep -q '^CONFIG_DAMON_RECLAIM=y' "$OUT/.config" || { echo "!! DAMON_RECLAIM 未生效"; exit 1; }
grep -q "^CONFIG_LOCALVERSION=\"-android14-4-00257-g7e35917775b8-ab9964412\"\$" "$OUT/.config" \
  || { echo "!! LOCALVERSION 不正确: $(grep LOCALVERSION= "$OUT/.config")"; exit 1; }
for c in VIRTIO_BLK VIRTIO_CONSOLE VIRTIO_PCI VIRTIO_BALLOON ZRAM ZSMALLOC VIRTIO_NET FAILOVER NET_FAILOVER DRM_VIRTIO_GPU HW_RANDOM_VIRTIO \
         VIRTIO_INPUT VIRTIO_DMA_SHARED_BUFFER VIRTIO_PMEM DMABUF_HEAPS_SYSTEM VIRTIO_MMIO VIRTIO_VSOCKETS; do
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
[ "$got" = "$EXPECT_VER" ] || { echo "!! 不匹配: 期望 $EXPECT_VER, 实际 $got"; exit 1; }

"$SRC/scripts/extract-ikconfig" "$IMG" > "$OUT/built.config" 2>/dev/null || true
grep -q '^CONFIG_DAMON_RECLAIM=y' "$OUT/built.config" \
  || { echo "!! Image 内无 DAMON"; exit 1; }
log "校验通过; CRC: $(grep -w module_layout "$OUT/vmlinux.symvers" 2>/dev/null | awk '{print $1}')"

# ---------- 5. 替换 ----------
[ -f "$BACKUP" ] || cp -a "$KPRE/kernel-6.1" "$BACKUP"
[ -f "$W/System.map-6.1.stock.bak" ] || cp -a "$KPRE/System.map" "$W/System.map-6.1.stock.bak"
cp "$IMG"            "$KPRE/kernel-6.1"
cp "$OUT/System.map" "$KPRE/System.map"
sha=$(sha256sum "$KPRE/kernel-6.1" | awk '{print $1}')
echo "damon $sha $(date '+%F %T')" > "$MARKER"
log "完成; 下一步: modules_a14.sh $W"
