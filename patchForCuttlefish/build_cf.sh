#!/bin/bash
# Build cuttlefish for arm64 target with patches applied.
#
# Usage:
#   ./build_cf.sh <AOSP_ROOT> [ANDROID_VERSION] [TARGET] [TARGET_TYPE] [--damon] [--trim-secure-env=true|false]
#
#   AOSP_ROOT       : (required) absolute path to AOSP source tree
#   ANDROID_VERSION : (optional) target Android version: a14|a15|a16, default: a14
#   TARGET          : (optional) lunch target override, auto-detected by version
#   TARGET_TYPE     : (optional) build variant: user|userdebug|eng, default: eng
#   --damon         : (optional) build DAMON kernel and replace prebuilt kernel/modules
#   --trim-secure-env=true|false
#                   : (optional) apply *trim-secure-env* patches or not.
#                     default: a14=true (false not supported), a15/a16=false
#
# Examples:
#   ./build_cf.sh /home/user/aosp
#   ./build_cf.sh /home/user/aosp a16
#   ./build_cf.sh /home/user/aosp a14 aosp_cf_arm64_only_phone eng

set -euo pipefail

# ── DAMON / trim-secure-env 选项解析 ───────────────────
DAMON_MODE=false
TRIM_SECURE_ENV=""    # empty: use version default below
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --damon)
            DAMON_MODE=true ;;
        --trim-secure-env=true|--trim-secure-env=false)
            TRIM_SECURE_ENV="${arg#*=}" ;;
        --trim-secure-env*)
            echo "ERROR: invalid '$arg', use --trim-secure-env=true or --trim-secure-env=false."
            exit 1 ;;
        *)
            ARGS+=("$arg") ;;
    esac
done
set -- ${ARGS[@]+"${ARGS[@]}"}

# ── arguments ──────────────────────────────────────────────
AOSP_ROOT="${1:?Usage: $0 <AOSP_ROOT> [ANDROID_VERSION] [TARGET] [TARGET_TYPE]}"
ANDROID_VERSION="${2:-a14}"

if [ ! -d "$AOSP_ROOT" ]; then
    echo "ERROR: AOSP_ROOT '$AOSP_ROOT' does not exist."
    exit 1
fi
AOSP_ROOT="$(cd "$AOSP_ROOT" && pwd -P)"

# ── version-specific defaults ──────────────────────────────
case "$ANDROID_VERSION" in
    a14)
        UBOOT_REV="b3cc1cd24d1b30b8965bbe71bae97fec319fc526"
        UBOOT_CLANG_VERSION="clang-r487747c"
        DEFAULT_TARGET="aosp_cf_arm64_only_phone"
        TARGET="${3:-$DEFAULT_TARGET}"
        TARGET_TYPE="${4:-eng}"
        # a14 does not need secure_env, and later a14 patches depend on trim-secure-env
        TRIM_SECURE_ENV="${TRIM_SECURE_ENV:-true}"
        if [ "$TRIM_SECURE_ENV" = "false" ]; then
            echo "ERROR: --trim-secure-env=false is not supported for a14 (later a14 patches depend on it)."
            exit 1
        fi
        ;;
    a15)
        UBOOT_REV="1ed8f8bde33ebbe2d12ccec4d882810bdbd3c3dd"
        UBOOT_CLANG_VERSION="clang-r530567"
        DEFAULT_TARGET="aosp_cf_arm64_only_phone"
        TARGET="${3:-$DEFAULT_TARGET}"
        TARGET_TYPE="${4:-eng}"
        # a15 needs secure_env (keymaster/gatekeeper/oemlock/keymint FIFOs)
        TRIM_SECURE_ENV="${TRIM_SECURE_ENV:-false}"
        ;;
    a16)
        UBOOT_REV="7b79f5b573949b55c0c794ee971a57849ad6ec1c"
        UBOOT_CLANG_VERSION="clang-r563880c"
        DEFAULT_TARGET="aosp_cf_arm64_only_phone"
        TARGET="${3:-$DEFAULT_TARGET}"
        TARGET_TYPE="${4:-eng}"
        # a16 needs secure_env (keymaster/gatekeeper/oemlock/keymint FIFOs)
        TRIM_SECURE_ENV="${TRIM_SECURE_ENV:-false}"
        ;;
    *)
        echo "ERROR: Unsupported ANDROID_VERSION '$ANDROID_VERSION'. Use 'a14', 'a15' or 'a16'."
        exit 1
        ;;
esac

# ── paths ───────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_ROOT="$SCRIPT_DIR/patchForCuttlefish-$ANDROID_VERSION"
ENVD_BINARY="$SCRIPT_DIR/envd-android-arm64"
CF_DIR="$AOSP_ROOT/device/google/cuttlefish"
ENVD_DEST="$CF_DIR/envd/envd-android-arm64"
UBOOT_SRC="$AOSP_ROOT/u-boot"
UBOOT_OUT="$AOSP_ROOT/out/bootloader-stratovirt"
UBOOT_REPO_URL="${UBOOT_REPO_URL:-https://android.googlesource.com/platform/external/u-boot}"
UBOOT_CLANG_BIN="${UBOOT_CLANG_BIN:-$AOSP_ROOT/prebuilts/clang/host/linux-x86/$UBOOT_CLANG_VERSION/bin}"
JOBS="${JOBS:-$(nproc)}"

prepare_uboot_source() {
    for tool in clang ld.lld llvm-ar llvm-nm llvm-objcopy llvm-objdump llvm-strip; do
        if [ ! -x "$UBOOT_CLANG_BIN/$tool" ]; then
            echo "ERROR: missing $UBOOT_CLANG_BIN/$tool; set UBOOT_CLANG_BIN to the Clang bin directory."
            return 1
        fi
    done
    for source_file in external/dtc/libfdt/libfdt.h bootable/libbootloader/libxbc/libxbc.c; do
        if [ ! -f "$AOSP_ROOT/$source_file" ]; then
            echo "ERROR: missing AOSP source dependency: $AOSP_ROOT/$source_file"
            return 1
        fi
    done
    if [ ! -e "$UBOOT_SRC/.git" ]; then
        if [ -e "$UBOOT_SRC" ]; then
            echo "ERROR: $UBOOT_SRC exists and is not a Git checkout."
            return 1
        fi
        git init -q "$UBOOT_SRC"
    fi
    if ! git -C "$UBOOT_SRC" rev-parse --verify HEAD >/dev/null 2>&1; then
        echo "  Fetching U-Boot source at $UBOOT_REV ..."
        git -C "$UBOOT_SRC" fetch --depth=1 "$UBOOT_REPO_URL" "$UBOOT_REV"
        git -C "$UBOOT_SRC" checkout -q --detach FETCH_HEAD
    fi
    if [ "$(git -C "$UBOOT_SRC" rev-parse HEAD)" != "$UBOOT_REV" ]; then
        echo "ERROR: $UBOOT_SRC must be at $UBOOT_REV for $ANDROID_VERSION."
        return 1
    fi
}

build_stratovirt_bootloader() (
    export PATH="$UBOOT_CLANG_BIN:$PATH"
    ROOT_DIR="$AOSP_ROOT"
    # Reuse the same configuration as the native U-Boot Bazel target.
    source "$UBOOT_SRC/build.config.stratovirt.aarch64"
    export KCONFIG_CONFIG="$UBOOT_SRC/configs/$DEFCONFIG"
    local defconfig_path="$KCONFIG_CONFIG"
    trap 'rm -f "$defconfig_path"' EXIT
    # Native build configs split command arguments across lines.
    eval "${PRE_DEFCONFIG_CMDS//$'\n'/ }"
    unset KCONFIG_CONFIG

    local make_args=(
        -C "$UBOOT_SRC" O="$UBOOT_OUT" ARCH=arm
        HOSTCC=cc CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=llvm-
        LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy
        OBJDUMP=llvm-objdump STRIP=llvm-strip
    )
    make "${make_args[@]}" "$DEFCONFIG"
    if ! grep -qx 'CONFIG_STRATOVIRT_MEM_MAP=y' "$UBOOT_OUT/.config" ||
        grep -qx 'CONFIG_CROSVM_MEM_MAP=y' "$UBOOT_OUT/.config"; then
        echo "ERROR: U-Boot configuration did not select the StratoVirt memory map."
        return 1
    fi
    make "${make_args[@]}" -j"$JOBS" u-boot.bin
    install -D -m 644 "$UBOOT_OUT/u-boot.bin" "$CF_DIR/build/bootloader/bootloader.stratovirt"
    install -m 644 "$UBOOT_SRC/Licenses/gpl-2.0.txt" "$CF_DIR/build/bootloader/LICENSE"
)

# ── validate ───────────────────────────────────────────────
if [ ! -d "$PATCH_ROOT" ]; then
    echo "ERROR: patch directory not found: $PATCH_ROOT"
    exit 1
fi

if [ ! -f "$ENVD_BINARY" ]; then
    echo "ERROR: envd binary not found: $ENVD_BINARY"
    exit 1
fi

prepare_uboot_source

echo "============================================"
echo "  Cuttlefish Build Script"
echo "  AOSP root       : $AOSP_ROOT"
echo "  Android version : $ANDROID_VERSION"
echo "  Target          : $TARGET"
echo "  Variant         : $TARGET_TYPE"
echo "  Trim secure_env : $TRIM_SECURE_ENV"
echo "============================================"

# ── Step 1: apply all patches ──────────────────────────────
echo ""
# ── [0/5] DAMON 内核构建 (仅 --damon 模式) ──────
if $DAMON_MODE; then
    echo "[0/5] Building DAMON kernel for $ANDROID_VERSION..."
    bash "$SCRIPT_DIR/kernel/build_$ANDROID_VERSION.sh" "$AOSP_ROOT"
    bash "$SCRIPT_DIR/kernel/modules_$ANDROID_VERSION.sh" "$AOSP_ROOT"
    echo "[0/5] DAMON kernel build complete."
    echo ""
fi

echo "[1/5] Applying patches from $PATCH_ROOT ..."

# Auto-discover all unique repo directories from patch paths,
# reset each to clean state before applying patches.
# The relative path under PATCH_ROOT maps to $AOSP_ROOT/<relative-dir>
# as the repo root where patch -p1 is applied.
PATCHED_REPOS=$(find "$PATCH_ROOT" -name '*.patch' -type f | sort | while read -r pf; do
    rel="${pf#$PATCH_ROOT/}"
    dirname "$rel"
done | sort -u)

echo "  Resetting patched repos to clean state..."
for repo in $PATCHED_REPOS; do
    repo_dir="$AOSP_ROOT/$repo"
    if [ -d "$repo_dir" ]; then
        echo "    Reset: $repo"
        git -C "$repo_dir" checkout -q HEAD -- . 2>/dev/null || true
        if [ "$repo" = "u-boot" ]; then
            # Android 15/16 ignore /build*, including this patch-added file.
            git -C "$repo_dir" clean -fqx -- build.config.stratovirt.aarch64
        fi
        git -C "$repo_dir" clean -fdq 2>/dev/null || true
    fi
done

# Apply all patches using git apply from each repo root.
# git apply is required (not patch) because some patches contain binary diffs
# (GIT binary patch) which the traditional patch tool does not support.
echo "  Applying patches..."
find "$PATCH_ROOT" -name '*.patch' -type f | sort | while read -r patch_file; do
    rel_path="${patch_file#$PATCH_ROOT/}"
    repo_subdir="$(dirname "$rel_path")"
    repo_absdir="$AOSP_ROOT/$repo_subdir"
    if [ "$TRIM_SECURE_ENV" = "false" ] && [[ "$rel_path" == *trim-secure-env* ]]; then
        echo "    Skipping: $rel_path (--trim-secure-env=false)"
        continue
    fi
    echo "    Patching: $rel_path"
    (cd "$repo_absdir" && git apply -p1 < "$patch_file") || exit 1
done
echo "  All patches applied."

# ── Step 2: copy envd binary ───────────────────────────────
echo ""

# DAMON mode: remove binder.impl=rust (C binder is built into our kernel)
if $DAMON_MODE; then
    BC="$AOSP_ROOT/device/google/cuttlefish/shared/BoardConfig.mk"
    if grep -q "binder.impl=rust" "$BC"; then
        # Remove only the binder.impl=rust token, keep other flags on the same line
        sed -i "s/ binder.impl=rust//; s/^binder.impl=rust //; s/^BOARD_KERNEL_CMDLINE += binder.impl=rust$//" "$BC"
        sed -i "/^BOARD_KERNEL_CMDLINE += *$/d" "$BC"
        echo "  Removed binder.impl=rust (C binder is built-in)"
    fi
fi

echo "[2/5] Copying envd binary..."
mkdir -p "$(dirname "$ENVD_DEST")"
cp "$ENVD_BINARY" "$ENVD_DEST"
chmod 755 "$ENVD_DEST"
echo "  Copied to $ENVD_DEST"

# Clean up stale .orig backup files from previous patch runs.
# (git apply doesn't create .orig files, but old runs with patch may have left them.)
for repo in $PATCHED_REPOS; do
    repo_dir="$AOSP_ROOT/$repo"
    find "$repo_dir" -name '*.orig' -delete 2>/dev/null || true
done

echo "[3/5] Building StratoVirt bootloader from U-Boot source..."
build_stratovirt_bootloader

# ── Step 4: build ──────────────────────────────────────────
echo ""
echo "[4/5] Building target: $TARGET-$TARGET_TYPE ..."

cd "$AOSP_ROOT"

# Remove personal info from build fingerprint
export BUILD_USERNAME=android-build
export BUILD_HOSTNAME=build-host

# envsetup.sh may use unset variables (TOP); relax -u temporarily
set +u
source build/envsetup.sh
if [ "$ANDROID_VERSION" = "a15" ] || [ "$ANDROID_VERSION" = "a16" ]; then
    lunch "${TARGET}-trunk_staging-${TARGET_TYPE}"
else
    lunch "${TARGET}-${TARGET_TYPE}"
fi
set -u

echo "[5/5] Running 'make dist -j${JOBS}' (with ninja proto pipe fix) ..."
# ARM servers have ninja protobuf pipe instability.
# Setting ANDROID_QUIET_BUILD disables the proto status channel entirely.
ANDROID_QUIET_BUILD=true make dist -j"${JOBS}"

# Check that dist packaged this build's firmware, including its exact contents.
HOST_PACKAGE="${DIST_DIR:-${OUT_DIR:-$AOSP_ROOT/out}/dist}/cvd-host_package.tar.gz"
BOOTLOADER_MEMBER="$(tar -tzf "$HOST_PACKAGE" | grep -E '^(\./)?etc/bootloader_aarch64/bootloader\.stratovirt$')" || BOOTLOADER_MEMBER=""
if [ -z "$BOOTLOADER_MEMBER" ] ||
    ! tar -xOf "$HOST_PACKAGE" "$BOOTLOADER_MEMBER" | cmp - "$UBOOT_OUT/u-boot.bin"; then
    echo "ERROR: $HOST_PACKAGE does not contain the newly built StratoVirt bootloader."
    exit 1
fi

echo ""
echo "============================================"
echo "  Build completed."
if $DAMON_MODE; then
    echo "  DAMON kernel enabled."
fi
echo "  Output artifacts: $AOSP_ROOT/out/dist/"
echo "============================================"
