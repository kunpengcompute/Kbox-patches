#!/usr/bin/env bash
# =============================================================================
# 将 aosp-14 恢复到 Kbox-patches 增量 patch 未合入的干净状态
#
# 撤销 patchForRedroid/ 下所有增量 patch，回到「redroid 官方 patch 已合入、
# 可直接编译官方 redroid 镜像」的基线状态。
#
# 原理：这些增量 patch 通过 `git apply` 合入（仅产生工作区未提交修改），
#       本脚本对每个涉及的 git 仓执行：
#         1) git checkout -- .   还原已跟踪文件到 HEAD（官方 patch 基线）
#         2) 删除 patch 新增的未跟踪文件（diff 中的 new file）
#
# 用法:
#   bash reset-aosp.sh
#
# 说明:
#   - 仅撤销 patchForRedroid 的增量修改，不影响 redroid 官方 patch（git am 已提交）
#   - 编译产物（如 vendor/redroid/envd/envd 二进制）不在 patch 内，不会被删除
#   - 脚本幂等，可重复执行
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/../.." && pwd)"
AOSP="$WORKSPACE/aosp-14"
PATCH_DIR="$SCRIPT_DIR/../patchForRedroid"

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

[ -d "$AOSP" ] || die "aosp-14 不存在: $AOSP"
[ -d "$PATCH_DIR" ] || die "patch 目录不存在: $PATCH_DIR"

# 收集涉及的 git 仓（去重）
mapfile -t REPOS < <(find "$PATCH_DIR" -type f -name '*.patch' \
    | sed "s|^$PATCH_DIR/||" \
    | xargs -n1 dirname \
    | sort -u)

[ ${#REPOS[@]} -gt 0 ] || die "未找到任何 patch"

log "涉及的 git 仓（${#REPOS[@]} 个）:"
printf '  %s\n' "${REPOS[@]}"

for repo in "${REPOS[@]}"; do
    dir="$AOSP/$repo"
    [ -d "$dir/.git" ] || die "不是 git 仓: $dir"

    # 1) 还原已跟踪文件到 HEAD（撤销对已有文件的修改）
    log "[$repo] 还原已跟踪文件 ..."
    git -C "$dir" checkout -- . || die "checkout 失败: $repo"

    # 2) 提取并删除 patch 新增的文件（new file mode）
    while IFS= read -r nf; do
        [ -n "$nf" ] || continue
        if [ -e "$dir/$nf" ]; then
            log "  [$repo] 删除新增文件: $nf"
            rm -rf "$dir/$nf"
        fi
    done < <(for pf in "$PATCH_DIR/$repo"/*.patch; do
        [ -f "$pf" ] || continue
        awk '
            /^diff --git/  { f=$0; sub(/^diff --git a\//, "", f); sub(/ b\/.*/, "", f) }
            /^new file mode/ { print f }
        ' "$pf"
    done | sort -u)

    # 3) 校验该仓已跟踪文件是否已干净（untracked 可能是编译产物，不视为残留）
    if git -C "$dir" status --porcelain | grep -q '^[MADRCU]'; then
        log "  [$repo] 警告：仍有已跟踪文件的修改未还原："
        git -C "$dir" status --porcelain | grep '^[MADRCU]' | sed 's/^/    /'
    else
        log "  [$repo] 已干净"
    fi
done

log "完成：aosp-14 已恢复到 patch 未合入的干净基线。"
