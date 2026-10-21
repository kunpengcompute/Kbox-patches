#!/bin/bash
# =============================================================================
# replace_modules.sh —— 用自编模块替换 AOSP 树里的预编译模块(三处), 内核+模块自洽
#
# 背景: 预编译 .ko 的 module_layout CRC(0x4e276f37) 与自编内核(0x6500052f)不一致,
#       无法混用; 必须整体替换。vd 集中 out-of-tree 来源的模块(goldfish/mt76/bt/
#       v4l2loopback 等)保留原厂——它们不在 first_stage 模块清单里, 不加载即无影响。
# =============================================================================
set -euo pipefail
W="${1:?用法: $0 <AOSP_ROOT>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"; S="$SCRIPT_DIR/src/kernel-a15"
OUT="$SCRIPT_DIR/out/kernel-a15"
MODSTAGE="$SCRIPT_DIR/out/kernel-a15-mods"
CLANG="$W/prebuilts/clang/host/linux-x86/clang-r522817/bin"
GKI="$W/kernel/prebuilts/6.6/arm64"
VD="$W/kernel/prebuilts/common-modules/virtual-device/6.6/arm64"

export PATH="$CLANG:$PATH"
export LOCALVERSION=""

log() { echo -e "\n===== [replace_modules] $* ====="; }

# ---------- 1. 编译模块并收集 ----------
log "编译并收集模块"
make -C "$S" O="$OUT" ARCH=arm64 LLVM=1 -j"$(nproc)" modules
rm -rf "$MODSTAGE"
make -C "$S" O="$OUT" ARCH=arm64 LLVM=1 INSTALL_MOD_STRIP=1 \
     INSTALL_MOD_PATH="$MODSTAGE" modules_install >/dev/null
REL=$(ls "$MODSTAGE/lib/modules/" | head -1)
echo "release: $REL"
echo "自编模块总数: $(find "$MODSTAGE/lib/modules/$REL" -name "*.ko" | wc -l)"

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
  if [ -n "$miss" ]; then
    echo "  保留原厂(不在自编集合):$miss"
  fi
}

log "替换 vd 集(vendor ramdisk + vendor_dlkm)"
replace_flat "$VD" "vd集"
log "替换 gki 集(system_dlkm)"
replace_flat "$GKI" "gki集"

log "替换 system_dlkm_staging"
s_ok=0; s_total=0
while read -r f; do
  s_total=$((s_total+1)); n="$(basename "$f")"
  if [ -n "${IDX[$n]:-}" ]; then cp -f "${IDX[$n]}" "$f"; s_ok=$((s_ok+1)); fi
done < <(find "$GKI/system_dlkm_staging" -name "*.ko")
echo "[staging] 替换 $s_ok/$s_total"

# ---------- 2.5 致命路径全量审计 ----------
# vendor ramdisk(first_stage insmod)里的每一个模块都必须是自编的,
# 只要有一个是原厂(CRC不匹配)就拒绝出包, 杜绝致命循环重启。
log "致命路径审计: vendor ramdisk 模块必须全部自编"
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
    echo "  [跳过] $m (目录中不存在, wildcard 为空, 不会打包)"
  elif [ -n "${IDX[$m]:-}" ]; then
    echo "  [OK]   $m"
  else
    echo "  [致命缺口] $m 仍是原厂! 需要在 build_kernel.sh 补 CONFIG 后重编"
    FATAL_FAIL=1
  fi
done
if [ "$FATAL_FAIL" -ne 0 ]; then
  echo "!! 存在致命缺口, 拒绝继续出包"
  exit 1
fi

# ---------- 3. 抽查: vermagic 与 module_layout CRC 必须与自编内核一致 ----------
log "抽查自编模块"
VM=$(strings "$VD/virtio_blk.ko" | grep -m1 "vermagic=" || true)
echo "  vd/virtio_blk.ko  $VM"
strings "$VD/nd_virtio.ko" | grep -m1 "vermagic=" || true
"$CLANG/llvm-objcopy" --dump-section __versions=/tmp/rv.bin "$VD/virtio_blk.ko"
KCRC=$(grep -w module_layout 2>/dev/null "$OUT/vmlinux.symvers" | awk '{print $1}') || KCRC=""
python3 - "$KCRC" <<'PYEOF'
import struct, sys
want = sys.argv[1]
d = open("/tmp/rv.bin","rb").read()
for i in range(0, len(d)-63, 64):
    crc, name = struct.unpack_from("<Q56s", d, i)
    n = name.split(b"\x00")[0].decode(errors="ignore")
    if n == "module_layout":
        got = "0x%08x" % crc
        print("  自编 virtio_blk.ko 期望 CRC = %s, 自编内核 = %s, %s" %
              (got, want, "一致 ✓" if got == want else "不一致 !!"))
        if got != want:
            sys.exit(1)
        break
PYEOF

log "完成。下一步: bash $W/package_a15.sh 重出包"
