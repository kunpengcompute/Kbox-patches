#!/bin/bash
# replace_modules_a14.sh —— a14 模块替换 + 致命路径审计
set -euo pipefail
W="${1:?用法: $0 <AOSP_ROOT>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"; S="$SCRIPT_DIR/src/kernel-a14"
OUT="$SCRIPT_DIR/out/kernel-a14"
MODSTAGE="$SCRIPT_DIR/out/kernel-a14-mods"
CLANG="$W/prebuilts/clang/host/linux-x86/clang-r487747c/bin"
GKI="$W/kernel/prebuilts/6.1/arm64"
VD="$W/kernel/prebuilts/common-modules/virtual-device/6.1/arm64"

export PATH="$CLANG:$PATH"
export LOCALVERSION=""

log() { echo -e "\n===== [replace_modules_a14] $* ====="; }

# ---------- 1. 编译模块并收集 ----------
log "编译模块"
make -C "$S" O="$OUT" ARCH=arm64 LLVM=1 -j"$(nproc)" modules
rm -rf "$MODSTAGE"
make -C "$S" O="$OUT" ARCH=arm64 LLVM=1 INSTALL_MOD_STRIP=1 \
     INSTALL_MOD_PATH="$MODSTAGE" modules_install >/dev/null
REL=$(ls "$MODSTAGE/lib/modules/" | head -1)
echo "release: $REL"
echo "自编模块数: $(find "$MODSTAGE/lib/modules/$REL" -name "*.ko" | wc -l)"

declare -A IDX
while read -r f; do IDX["$(basename "$f")"]="$f"; done < <(find "$MODSTAGE/lib/modules/$REL" -name "*.ko")

# ---------- 2. 替换 ----------
replace_flat() {
  local d="$1" label="$2" total=0 ok=0 miss=""
  local f n
  for f in "$d"/*.ko; do
    [ -e "$f" ] || continue
    total=$((total+1)); n="$(basename "$f")"
    if [ -n "${IDX[$n]:-}" ]; then
      cp -f "${IDX[$n]}" "$f"; ok=$((ok+1))
    else
      miss="$miss $n"
    fi
  done
  echo "[$label] 替换 $ok/$total"
  if [ -n "$miss" ]; then echo "  保留:$miss"; fi
}

# 删除无法从 kernel_common 构建或不适用于沙箱的模块
rm -f "$VD/goldfish_address_space.ko"
rm -f "$VD/goldfish_sync.ko"
rm -f "$VD/mt76.ko"
rm -f "$VD/mt76-usb.ko"
rm -f "$VD/mt76x0-common.ko"
rm -f "$VD/mt76x02-lib.ko"
rm -f "$VD/mt76x02-usb.ko"
rm -f "$VD/mt76x0u.ko"
rm -f "$VD/mt76x2-common.ko"
rm -f "$VD/mt76x2u.ko"
echo "  已删除 goldfish_address_space goldfish_sync (无源码)"
echo "  已删除 mt76 系列 (物理WiFi驱动, 沙箱用 virt_wifi)"

log "替换 vd 6.1"
replace_flat "$VD" "vd集"
log "替换 gki 6.1"
replace_flat "$GKI" "gki集"

# ---------- 2.5 致命路径审计 ----------

# Verify deleted modules are not in the fatal path (vendor ramdisk) list
DELETED_MODULES=$(ls "$VD" 2>/dev/null | wc -l)
BC="$W/device/google/cuttlefish/shared/BoardConfig.mk"
if [ -f "$BC" ]; then
    FATAL_LIST=$(sed -n '/RAMDISK_KERNEL_MODULES/,/libarc4\|virtio-rng/p' "$BC" 2>/dev/null | grep -oE "[A-Za-z0-9_.-]+\.ko" | sort -u)
    for m in $FATAL_LIST; do
        if [ ! -f "$VD/$m" ] && [ ! -f "$GKI/$m" ]; then
            # Check if it was deleted by us
            case "$m" in
                goldfish_address_space*|goldfish_sync*|mt76*|v4l2loopback*|snd-aloop*|v4l2-tpg*|vivid*|virtio-media*|rust_binder*)
                    echo "  [WARNING] $m was deleted but is in ramdisk list - verify this is safe"
                    ;;
            esac
        fi
    done
fi

log "致命路径审计"
DEV="$W/device/google/cuttlefish"
BC="$DEV/shared/BoardConfig.mk"
ALL_KO=$( { sed -n '/RAMDISK_KERNEL_MODULES/,/libarc4\|virtio-rng/p' "$BC"; \
            grep -rh "VENDOR_RAMDISK_KERNEL_MODULES *+=" "$DEV" --include="*.mk"; } \
          | grep -oE "[A-Za-z0-9_.-]+\.ko" | sort -u ) || true
FATAL_FAIL=0
for m in $ALL_KO; do
  src=""
  [ -e "$VD/$m" ] && src="$VD/$m"
  [ -z "$src" ] && [ -e "$GKI/$m" ] && src="$GKI/$m"
  if [ -z "$src" ]; then
    echo "  [跳过] $m (目录中不存在)"
  elif [ -n "${IDX[$m]:-}" ]; then
    echo "  [OK]   $m"
  else
    echo "  [致命缺口] $m"
    FATAL_FAIL=1
  fi
done
[ "$FATAL_FAIL" -eq 0 ] || { echo "!! 存在致命缺口, 拒绝"; exit 1; }

# ---------- 3. 抽查 ----------
log "抽查"
KCRC=$(grep -w module_layout 2>/dev/null "$OUT/vmlinux.symvers" | awk '{print $1}') || KCRC=""
echo "  CRC: $KCRC"
strings "$VD/virtio_blk.ko" 2>/dev/null | grep -m1 "vermagic=" || true
log "完成"
