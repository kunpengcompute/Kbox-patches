#!/usr/bin/env bash
# Copyright 2026 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# =============================================================================
# CubeSandbox PVM 模式安装脚本（在 L1 虚拟机内以 root 运行）
#
# 在上游 install.sh 之上自动完成 PVM 方案专属配置：
#   - 前置自检 kvm_pvm / /dev/kvm（PVM 主机硬性要求）
#   - 自动探测并写入 .env 的 CUBE_PVM_ENABLE / CUBE_SANDBOX_NODE_IP /
#     CUBE_SANDBOX_NETWORK_CIDR / WEB_UI_HOST_PORT
#   - 调用发布包自带 ./install.sh --mode=install
#   - 安装后验证运行时 PVM 状态（活动内核必须解析到 vmlinux-pvm）
#
# 用法:
#   bash install-cube-pvm.sh [发布包解压目录]
#   发布包解压目录缺省时探测当前目录下唯一的 cube-sandbox-one-click-*
#
# 可覆盖的环境变量:
#   ASSUME_YES=1           跳过配置确认交互（无人值守部署）
#   NODE_IP=...            手动指定 CUBE_SANDBOX_NODE_IP（跳过自动探测）
#   NETWORK_CIDR=...       手动指定沙箱网段（跳过自动避让选择）
# =============================================================================
set -euo pipefail

log() { echo -e "\033[1;32m$*\033[0m"; }
die() { echo -e "\033[1;31m错误: $*\033[0m" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "本脚本需在 L1 内以 root 运行"

# ===== 解析发布包目录 =====
BUNDLE_DIR="${1:-}"
if [ -z "$BUNDLE_DIR" ]; then
    # 尾部 / 只匹配目录，避免误匹配同名的 .tar.gz 压缩包
    count=0
    for d in ./cube-sandbox-one-click-*/; do
        [ -d "$d" ] || continue
        count=$((count + 1))
        BUNDLE_DIR="$d"
    done
    [ "$count" -eq 1 ] \
        || die "当前目录须恰好存在一个 cube-sandbox-one-click-* 目录（找到 $count 个），或显式传入目录"
fi
[ -f "$BUNDLE_DIR/install.sh" ] || die "$BUNDLE_DIR 下没有 install.sh（请先解压发布包 tar.gz）"
[ -f "$BUNDLE_DIR/env.example" ] || die "$BUNDLE_DIR 下没有 env.example"
log "发布包目录: $BUNDLE_DIR"

# ===== 前置自检：PVM 主机硬性要求 =====
lsmod | grep '^kvm_pvm' >/dev/null \
    || die "kvm_pvm 未加载，请先用 install-pvm-l1.sh 完成 PVM L1 内核安装与加载"
[ -e /dev/kvm ] || die "/dev/kvm 不存在，请先完成 PVM L1 内核安装（install-pvm-l1.sh）"
log "前置自检通过：kvm_pvm 已加载、/dev/kvm 存在"

# ===== 前置自检：安装根目录顶层符号链接 =====
# 上游 install.sh 清空安装根目录前会拒绝任何顶层符号链接（lib/common.sh 的安全防护），
# 常见现场是把 cube-snapshot / cubebox_os_image 指到 /data。这里自动备份并移走，
# 仅移动链接本身，链接目标目录中的内容不受影响；安装完成后由 restore_symlinks 自动重建。
INSTALL_ROOT="${CUBE_INSTALL_PREFIX:-/usr/local/services/cubetoolbox}"
backup_dir=""
restore_failed=0
if [ -d "$INSTALL_ROOT" ]; then
    top_links="$(find "$INSTALL_ROOT" -mindepth 1 -maxdepth 1 -type l 2>/dev/null || true)"
    if [ -n "$top_links" ]; then
        backup_dir="$HOME/cube-backup/symlinks-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        log "检测到安装根目录顶层符号链接（上游 install.sh 重装时会拒绝清空），备份并移走："
        while IFS= read -r link; do
            [ -n "$link" ] || continue
            target="$(readlink -f "$link" 2>/dev/null || true)"
            mv "$link" "$backup_dir/"
            log "  $link -> ${target:-<失效链接>}（链接已移至 $backup_dir/$(basename "$link")）"
        done <<< "$top_links"
    fi
fi

# restore_symlinks：安装完成后按备份自动重建被移走的顶层符号链接
#   - 未做过目录迁移（无备份）→ 直接返回
#   - 目标目录仍存在 → ln -sfn 恢复
#   - 安装过程在同名位置新建了真实目录 → 把内容并入目标后替换为链接
#   - 链接本身已失效（目标不存在）→ 保留备份中的链接并告警，脚本末尾以失败退出，提示人工恢复
restore_symlinks() {
    local l dst target
    [ -n "$backup_dir" ] && [ -d "$backup_dir" ] || return 0
    log "恢复安装前移走的顶层符号链接 ..."
    for l in "$backup_dir"/*; do
        [ -L "$l" ] || continue
        dst="$INSTALL_ROOT/$(basename "$l")"
        target="$(readlink "$l")"
        if [ ! -d "$target" ]; then
            log "  [警告] $(basename "$l")：目标目录 $target 不存在，链接仍保留在 $l，请人工确认后恢复"
            restore_failed=1
            continue
        fi
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            log "  [合并] $dst 已由安装过程创建，内容并入 $target 后替换为链接"
            if ! cp -a "$dst/." "$target/"; then
                log "  [警告] $(basename "$l")：合并到 $target 失败，未删除 $dst，请人工处理"
                restore_failed=1
                continue
            fi
            rm -rf "$dst"
        fi
        if ln -sfn "$target" "$dst"; then
            log "  [恢复] $dst -> $target"
        else
            log "  [警告] $(basename "$l")：创建链接失败，请人工执行: ln -sfn $target $dst"
            restore_failed=1
        fi
    done
}

# ===== 准备 .env（保护已有配置）=====
ENV_FILE="$BUNDLE_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    cp -a "$ENV_FILE" "$ENV_FILE.bak"
    log "检测到已有 .env，已备份为 .env.bak，在其基础上修改"
else
    cp "$BUNDLE_DIR/env.example" "$ENV_FILE"
fi

# set_env <KEY> <VALUE>：兼容“有值行”与“注释行”两种形态
set_env() {
    local key="$1" val="$2"
    if grep -qE "^[#[:space:]]*$key=" "$ENV_FILE"; then
        sed -i -E "s|^[#[:space:]]*$key=.*|$key=$val|" "$ENV_FILE"
    else
        printf '%s=%s\n' "$key" "$val" >>"$ENV_FILE"
    fi
}

# ===== 自动探测 NODE_IP =====
NODE_IP="${NODE_IP:-}"
if [ -z "$NODE_IP" ]; then
    NODE_IP=$(ip route get 1.1.1.1 2>/dev/null \
        | awk '{for(i=1;i<=NF;i++)if($i=="src"){print $(i+1);exit}}')
fi
[ -n "$NODE_IP" ] || die "无法探测本机内网 IP，请手动设置: export NODE_IP=<本机IP> 后重跑"

# ===== 自动选择不冲突的沙箱网段 =====
choose_cidr() {
    local cidrs
    cidrs=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}')
    if command -v python3 >/dev/null 2>&1 && [ -n "$cidrs" ]; then
        python3 - "$cidrs" <<'PY'
import sys, ipaddress

local_nets = [ipaddress.ip_network(c, strict=False)
              for c in sys.argv[1].split() if "/" in c]
for cand in ("10.100.0.0/16", "10.101.0.0/16", "172.16.0.0/16"):
    net = ipaddress.ip_network(cand)
    if not any(net.overlaps(l) for l in local_nets):
        print(cand)
        break
PY
    else
        # 无 python3 的退化选择：本机已有 10.x 地址则换 172.16 网段
        if echo "$cidrs" | grep -qE '^10\.'; then echo "172.16.0.0/16"
        else echo "10.100.0.0/16"; fi
    fi
}
NETWORK_CIDR="${NETWORK_CIDR:-$(choose_cidr)}"
[ -n "$NETWORK_CIDR" ] \
    || die "候选沙箱网段均与本机网段冲突，请手动设置: export NETWORK_CIDR=<不冲突网段> 后重跑"

# ===== 写入 .env =====
set_env CUBE_PVM_ENABLE 1
set_env CUBE_SANDBOX_NODE_IP "$NODE_IP"
set_env CUBE_SANDBOX_NETWORK_CIDR "$NETWORK_CIDR"
set_env WEB_UI_HOST_PORT 8088

log "已写入 .env 关键配置:"
log "  CUBE_PVM_ENABLE=1          （PVM 模式，活动内核将指向 vmlinux-pvm）"
log "  CUBE_SANDBOX_NODE_IP=$NODE_IP"
log "  CUBE_SANDBOX_NETWORK_CIDR=$NETWORK_CIDR"
log "  WEB_UI_HOST_PORT=8088"

# ===== 确认（ASSUME_YES=1 跳过）=====
if [ "${ASSUME_YES:-0}" != "1" ]; then
    read -r -p "确认以上配置无误，回车继续安装（Ctrl+C 终止）: " _ans \
        || die "stdin 不可用（非交互环境），无人值守部署请前置 ASSUME_YES=1"
fi

# ===== 执行上游安装 =====
log "执行 ./install.sh --mode=install ..."
( cd "$BUNDLE_DIR" && ./install.sh --mode=install )

# ===== 安装后修复：恢复被移走的顶层符号链接 =====
restore_symlinks

TC=/usr/local/services/cubetoolbox

# ===== 安装后修复：刷新同版本号的组件缓存 =====
# 上游 install.sh 把发布包内的组件入库到 /data/cubelet/root/component_versions/<组件>/<版本>/，
# 但目标目录已存在时直接跳过（install.sh 中 inventory_* 系列的 "inventory skip (exists)"）。
# 因此"版本号不变的重装"会继续复用上一次安装留下的旧制品：实测重装后沙箱仍在跑旧
# cube-agent（PVM 下快照恢复后 agent 触发 PC Alignment 崩溃），以及旧 guest 镜像。
# 这里按内容比对，与本次安装制品不一致时覆盖缓存；有覆盖则重启 cubelet 使其重新加载。
refresh_component_cache() { # <组件名> <安装目录内的制品文件> <缓存内相对路径> [版本] [组件根目录]
    # 返回 0=已刷新 1=一致或无需刷新 2=刷新失败
    local comp="$1" src="$2" file="$3" ver="${4:-}" root="${5:-$(dirname "$2")}" cached
    if [ ! -f "$src" ]; then
        log "  [跳过] $comp：未找到 $src"
        return 1
    fi
    [ -n "$ver" ] || ver="$(cat "$root/version" 2>/dev/null || true)"
    [ -n "$ver" ] || { log "  [跳过] $comp：无法确定组件版本"; return 1; }
    cached="/data/cubelet/root/component_versions/$comp/$ver/$file"
    [ -f "$cached" ] || { log "  [跳过] $comp：组件缓存尚未入库（$ver）"; return 1; }
    if cmp -s "$src" "$cached"; then
        log "  [通过] $comp/$file 组件缓存与本次安装制品一致（$ver）"
        return 1
    fi
    log "  [更新] $comp/$file 组件缓存为旧制品，刷新: $cached"
    # 先复制到同目录临时文件再 mv，避免直接覆盖正在运行的二进制（cube-shim / cube-runtime）
    if ! cp -f "$src" "$cached.new"; then
        log "  [失败] $comp/$file 复制到 $cached.new 失败"
        return 2
    fi
    if ! mv -f "$cached.new" "$cached"; then
        rm -f "$cached.new" 2>/dev/null || true
        log "  [失败] $comp/$file 原子替换失败（$cached）"
        return 2
    fi
    return 0
}

# cube-shim 目录下没有 version 文件，版本取自 release-manifest.json
SHIM_VER="$(python3 -c '
import json, sys
print((json.load(open(sys.argv[1])).get("components", {}).get("containerd-shim-cube-rs") or {}).get("version", ""))
' "$TC/release-manifest.json" 2>/dev/null || true)"

log "校验组件缓存是否与本次安装制品一致 ..."
cache_changed=0
refresh_one() { # 参数同 refresh_component_cache；刷新失败直接终止，避免带着旧组件继续
    local rc=0
    refresh_component_cache "$@" || rc=$?
    case "$rc" in
        0) cache_changed=1 ;;
        2) die "组件缓存刷新失败：$1/$3（详见上方日志）" ;;
    esac
}
refresh_one cube-agent "$TC/cube-agent/cube-agent.ext4" "cube-agent.ext4"
refresh_one cube-image "$TC/cube-image/cube-guest-image-cpu.img" "cube-guest-image-cpu.img"
refresh_one cube-shim "$TC/cube-shim/bin/containerd-shim-cube-rs" "bin/containerd-shim-cube-rs" "$SHIM_VER" "$TC/cube-shim"
refresh_one cube-shim "$TC/cube-shim/bin/cube-runtime" "bin/cube-runtime" "$SHIM_VER" "$TC/cube-shim"
if [ "$cache_changed" = 1 ]; then
    log "组件缓存已刷新，重启 cubelet 以重新加载（节点重新注册约需 1-2 分钟）..."
    systemctl restart cube-sandbox-cubelet.service \
        || die "重启 cube-sandbox-cubelet.service 失败"
fi

# ===== 安装后验证 =====
log "安装后验证 PVM 运行时状态 ..."
failed=0
grep -q '^CUBE_PVM_ENABLE=1' "$TC/.one-click.env" 2>/dev/null \
    || { log "  [失败] $TC/.one-click.env 中 CUBE_PVM_ENABLE 不为 1"; failed=1; }
ACTIVE_KERNEL=$(readlink -f "$TC/cube-kernel-scf/vmlinux" 2>/dev/null || true)
case "$ACTIVE_KERNEL" in
    *vmlinux-pvm) log "  [通过] 活动内核: $ACTIVE_KERNEL" ;;
    *) log "  [失败] 活动内核未指向 vmlinux-pvm: ${ACTIVE_KERNEL:-<空>}"; failed=1 ;;
esac
lsmod | grep '^kvm_pvm' >/dev/null || { log "  [失败] kvm_pvm 未加载"; failed=1; }
[ -e /dev/kvm ] || { log "  [失败] /dev/kvm 不存在"; failed=1; }

[ "$failed" = 0 ] || die "安装后验证存在失败项，请按上述提示排查"

[ "$restore_failed" = 0 ] \
    || die "存在未能自动恢复的顶层符号链接（见上方 [警告]），请按提示人工恢复后再使用"

log "CubeSandbox PVM 模式安装验证全部通过"
log "后续步骤:"
log "  1) bash cube_healthcheck.sh 做整体健康校验"
log "  2) 访问 WebUI: http://$NODE_IP:8088"
log "  3) 创建模板后在沙箱内核对 uname -r（应为 PVM L2 内核版本）"
