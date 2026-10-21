#!/bin/bash
# replace_modules_a16_612.sh —— a16 6.12 模块替换 + 致命路径审计
set -euo pipefail
W="${1:?用法: $0 <AOSP_ROOT>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"; S="$SCRIPT_DIR/src/kernel-a16"
OUT="$SCRIPT_DIR/out/kernel-a16"
MODSTAGE="$SCRIPT_DIR/out/kernel-a16-mods"
CLANG="$W/prebuilts/clang/host/linux-x86/clang-r547379/bin"
GKI="$W/kernel/prebuilts/6.12/arm64"
VD="$W/kernel/prebuilts/common-modules/virtual-device/6.12/arm64"

export PATH="$CLANG:$PATH"
export LOCALVERSION=""

log() { echo -e "\n===== [replace_modules_a16_612] $* ====="; }

# ---------- 1. 编译并收集 ----------
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

log "替换 vd 6.12"
replace_flat "$VD" "vd集"
log "替换 gki 6.12"
replace_flat "$GKI" "gki集"

# ---------- 2.5 致命路径审计 ----------
log "致命路径审计"
DEV="$W/device/google/cuttlefish"
BC="$DEV/shared/BoardConfig.mk"
ALL_KO=$( { sed -n '/RAMDISK_KERNEL_MODULES/,/libarc4/p' "$BC"; \
            grep -rh "VENDOR_RAMDISK_KERNEL_MODULES *+=" "$DEV" --include="*.mk"; } \
          | grep -oE "[A-Za-z0-9_.-]+\.ko" | sort -u ) || true
FATAL_FAIL=0
for m in $ALL_KO; do
  src=""
  [ -e "$VD/$m" ] && src="$VD/$m"
  [ -z "$src" ] && [ -e "$GKI/$m" ] && src="$GKI/$m"
  if [ -z "$src" ]; then
    echo "  [跳过] $m"
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
strings "$VD/virtio_blk.ko" 2>/dev/null | grep -m1 "vermagic=" || \
  strings "$GKI/virtio_blk.ko" 2>/dev/null | grep -m1 "vermagic=" || true
log "完成"
