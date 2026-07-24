#!/bin/bash
# Build cuttlefish for arm64 target with patches applied.
#
# Usage:
#   ./build_cf.sh <AOSP_ROOT> [TARGET] [TARGET_TYPE]
#
#   AOSP_ROOT     : (required) absolute path to AOSP source tree
#   TARGET        : (optional) lunch target, default: aosp_cf_arm64_only_phone
#   TARGET_TYPE   : (optional) build variant: user|userdebug|eng, default: eng
#
# Example:
#   ./build_cf.sh /home/user/aosp
#   ./build_cf.sh /home/user/aosp aosp_cf_arm64_only_phone-trunk_staging-userdebug userdebug

set -euo pipefail

# ── arguments ──────────────────────────────────────────────
AOSP_ROOT="${1:?Usage: $0 <AOSP_ROOT> [TARGET] [TARGET_TYPE]}"
TARGET="${2:-aosp_cf_arm64_only_phone}"
TARGET_TYPE="${3:-eng}"

if [ ! -d "$AOSP_ROOT" ]; then
    echo "ERROR: AOSP_ROOT '$AOSP_ROOT' does not exist."
    exit 1
fi

# ── paths ───────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATCH_ROOT="$SCRIPT_DIR/patchForCuttlefish-a14"
ENVD_BINARY="$SCRIPT_DIR/envd-android-arm64"
CF_DIR="$AOSP_ROOT/device/google/cuttlefish"
ENVD_DEST="$CF_DIR/envd/envd-android-arm64"

# ── validate ───────────────────────────────────────────────
if [ ! -d "$PATCH_ROOT" ]; then
    echo "ERROR: patch directory not found: $PATCH_ROOT"
    exit 1
fi

if [ ! -f "$ENVD_BINARY" ]; then
    echo "ERROR: envd binary not found: $ENVD_BINARY"
    exit 1
fi

echo "============================================"
echo "  Cuttlefish Build Script"
echo "  AOSP root : $AOSP_ROOT"
echo "  Target    : $TARGET"
echo "  Variant   : $TARGET_TYPE"
echo "============================================"

# ── Step 1: apply all patches ──────────────────────────────
echo ""
echo "[1/4] Applying patches from $PATCH_ROOT ..."

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
        git -C "$repo_dir" clean -fdq 2>/dev/null || true
    fi
done

# Apply all patches using patch -p1 from each repo root
echo "  Applying patches..."
find "$PATCH_ROOT" -name '*.patch' -type f | sort | while read -r patch_file; do
    rel_path="${patch_file#$PATCH_ROOT/}"
    repo_subdir="$(dirname "$rel_path")"
    repo_absdir="$AOSP_ROOT/$repo_subdir"
    echo "    Patching: $rel_path"
    (cd "$repo_absdir" && patch -p1 < "$patch_file") || exit 1
done
echo "  All patches applied."

# ── Step 2: copy envd binary ───────────────────────────────
echo ""
echo "[2/4] Copying envd binary..."
mkdir -p "$(dirname "$ENVD_DEST")"
cp "$ENVD_BINARY" "$ENVD_DEST"
chmod 755 "$ENVD_DEST"
echo "  Copied to $ENVD_DEST"

# ── Step 3: clean .orig backup files across all patched repos
for repo in $PATCHED_REPOS; do
    repo_dir="$AOSP_ROOT/$repo"
    find "$repo_dir" -name '*.orig' -delete 2>/dev/null || true
done

# ── Step 4: build ──────────────────────────────────────────
echo ""
echo "[3/4] Building target: $TARGET-$TARGET_TYPE ..."

cd "$AOSP_ROOT"

# Remove personal info from build fingerprint
export BUILD_USERNAME=android-build
export BUILD_HOSTNAME=build-host

# envsetup.sh may use unset variables (TOP); relax -u temporarily
set +u
source build/envsetup.sh
lunch "${TARGET}-${TARGET_TYPE}"
set -u

JOBS=$(nproc)
echo "[4/4] Running 'make dist -j${JOBS}' (with ninja proto pipe fix) ..."
# ARM servers have ninja protobuf pipe instability.
# Setting ANDROID_QUIET_BUILD disables the proto status channel entirely.
ANDROID_QUIET_BUILD=true make dist -j"${JOBS}"

echo ""
echo "============================================"
echo "  Build completed."
echo "  Output artifacts: $AOSP_ROOT/out/dist/"
echo "============================================"
