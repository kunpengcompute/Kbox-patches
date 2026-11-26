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
case "${1:-}" in -h|--help) sed -n '17,44p' "$0"; exit 0 ;; esac
# =============================================================================
# fix_node_quota.sh — 修复 cube-bench c50/n500 的 130597（节点配额不足）
#
# 背景（来源：Cubelet/CubeOps 源码）：
#   - 节点调度配额来自 Cubelet 的 host.quota.*；0/空值时按宿主机资源自动推导，
#     高密度压测下往往不足 → 创建请求被调度器拒绝，CubeMaster 返回
#     ret_code=130597 "no more resource"（sandbox/sandbox_run.go）。
#   - 配额只在节点注册时上报（buildRegisterRequest），周期心跳
#     （buildStatusRequest）不带 quota，所以改完配置必须重放一次注册才生效。
#   - RegisterNode 是整体 upsert：payload 缺 capacity/allocatable/host_facts
#     会被清空。本脚本从 CubeOps 现有节点视图重建完整注册体，只改 quota。
#
# 本脚本做三件事：
#   1) 备份并修改 Cubelet 动态配置 host.quota.mcpu_limit / mem_limit（持久化）；
#   2) 向 CubeOps 重放节点注册（无需重启 Cubelet，不中断上报）；
#   3) 校验 CubeOps 节点视图中的新配额。
#
# 用法：
#   bash fix_node_quota.sh                          # 默认 mcpu_limit=2560000, mem_limit=3500000Mi
#   QUOTA_CPU=3200000 QUOTA_MEM=4000000Mi bash fix_node_quota.sh
#
# 可覆盖环境变量：
#   QUOTA_CPU      mcpu_limit（默认 2560000；对应 2560 核，可容纳 640 个 4C 沙箱）
#   QUOTA_MEM      mem_limit，必须为 <数字>Mi（默认 3500000Mi）
#   CUBELET_CONF   默认 /usr/local/services/cubetoolbox/Cubelet/dynamicconf/conf.yaml
#   CUBEOPS_ADDR   默认 http://127.0.0.1:3010
#   NODE_ID        多节点时指定；默认取唯一节点
# =============================================================================
set -uo pipefail

QUOTA_CPU="${QUOTA_CPU:-2560000}"
QUOTA_MEM="${QUOTA_MEM:-3500000Mi}"
CUBELET_CONF="${CUBELET_CONF:-/usr/local/services/cubetoolbox/Cubelet/dynamicconf/conf.yaml}"
CUBEOPS_ADDR="${CUBEOPS_ADDR:-http://127.0.0.1:3010}"
NODE_ID="${NODE_ID:-}"

log() { echo "[$(date '+%F %T')] $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

[[ "$QUOTA_CPU" =~ ^[1-9][0-9]*$ ]] || die "QUOTA_CPU 需为正整数（单位 mcpu），当前: $QUOTA_CPU"
[[ "$QUOTA_MEM" =~ ^[1-9][0-9]*Mi$ ]] || die "QUOTA_MEM 需为 <正整数>Mi（如 3500000Mi），当前: $QUOTA_MEM"
QUOTA_MEM_MB="${QUOTA_MEM%Mi}"

# ---- 1) 修改 Cubelet 动态配置（持久化，重启/重注册后仍生效）----
[ -f "$CUBELET_CONF" ] || die "未找到 Cubelet 配置: $CUBELET_CONF"
bak="$CUBELET_CONF.bak.$(date +%Y%m%d%H%M%S)"
cp "$CUBELET_CONF" "$bak" || die "备份失败: $bak"
log "已备份 -> $bak"
sed -i -E "s/^([[:space:]]*)mcpu_limit:.*/\1mcpu_limit: ${QUOTA_CPU}/; \
           s/^([[:space:]]*)mem_limit:.*/\1mem_limit: \"${QUOTA_MEM}\"/" "$CUBELET_CONF" \
  || die "写入失败: $CUBELET_CONF"
grep -qE "^[[:space:]]*mcpu_limit:[[:space:]]*${QUOTA_CPU}[[:space:]]*$" "$CUBELET_CONF" \
  || die "配置中未找到 mcpu_limit 或未更新成功，请检查 $CUBELET_CONF"
grep -qE "^[[:space:]]*mem_limit:[[:space:]]*\"${QUOTA_MEM}\"[[:space:]]*$" "$CUBELET_CONF" \
  || die "配置中未找到 mem_limit 或未更新成功，请检查 $CUBELET_CONF"
log "配置已更新："
grep -nE '^[[:space:]]*(mcpu_limit|mem_limit):' "$CUBELET_CONF" | sed 's/^/  /'

# ---- 2) 从 CubeOps 取当前节点视图，重建完整注册体（只改 quota）----
NODES_JSON="$(curl -s --max-time 15 "$CUBEOPS_ADDR/internal/v1/nodes" || true)"
[ -n "$NODES_JSON" ] || die "无法访问 CubeOps: $CUBEOPS_ADDR/internal/v1/nodes"

BODY="$(NODES_JSON="$NODES_JSON" NODE_ID="$NODE_ID" QUOTA_CPU="$QUOTA_CPU" QUOTA_MEM_MB="$QUOTA_MEM_MB" python3 - <<'PY'
import json, os, sys
nodes = json.loads(os.environ["NODES_JSON"])
want = os.environ.get("NODE_ID", "")
sel = [n for n in nodes if (n.get("InstanceID") == want or n.get("uuid") == want)] if want else nodes
if len(sel) != 1:
    sys.stderr.write("需要精确匹配 1 个节点，当前 %d 个（可用 NODE_ID 指定）\n" % len(sel))
    sys.exit(2)
n = sel[0]

cap = n.get("Capacity") or n.get("capacity")
if isinstance(cap, dict):
    cpu_total = int(cap.get("milli_cpu") or cap.get("cpuMilli") or 0)
    mem_total = int(cap.get("memory_mb") or cap.get("memoryMB") or 0)
else:
    cpu_total = int(n.get("CpuTotal") or 0) * 1000
    mem_total = int(n.get("MemMBTotal") or 0)
if cpu_total <= 0 or mem_total <= 0:
    sys.stderr.write("节点视图缺少有效容量（Capacity/CpuTotal/MemMBTotal），中止以免把节点容量写成 0\n")
    sys.exit(3)

alloc = n.get("Allocatable") or n.get("allocatable")
if isinstance(alloc, dict):
    alloc_cpu = int(alloc.get("milli_cpu") or alloc.get("cpuMilli") or 0)
    alloc_mem = int(alloc.get("memory_mb") or alloc.get("memoryMB") or 0)
else:
    alloc_cpu = alloc_mem = 0
if alloc_cpu <= 0 or alloc_mem <= 0:
    # 视图不含 allocatable 时与 capacity 一致：Cubelet 配置 host.quota 后两者相同。
    alloc_cpu, alloc_mem = cpu_total, mem_total

facts = n.get("HostFacts") or n.get("host_facts")
if not facts:
    sys.stderr.write("节点视图无 HostFacts，提交会清空该字段，已中止\n")
    sys.exit(4)

body = {
    "node_id": n.get("uuid") or n.get("InstanceID"),
    "host_ip": n.get("IP") or n.get("InstanceID"),
    "labels": n.get("NodeLabels") or {},
    "capacity": {"milli_cpu": cpu_total, "memory_mb": mem_total},
    "allocatable": {"milli_cpu": alloc_cpu, "memory_mb": alloc_mem},
    "instance_type": n.get("InstanceType") or "cubebox",
    "cluster_label": n.get("ClusterLabel") or "default-cluster",
    "quota_cpu": int(os.environ["QUOTA_CPU"]),
    "quota_mem_mb": int(os.environ["QUOTA_MEM_MB"]),
    "create_concurrent_num": int(n.get("CreateConcurrentNum") or 0),
    "max_mvm_num": int(n.get("MaxMvmLimit") or 0),
    "host_facts": facts,
}
print(json.dumps(body, ensure_ascii=False, indent=2))
PY
)" || die "构建注册体失败"

log "将提交的节点注册体："
printf '%s\n' "$BODY" | sed 's/^/  /'

# ---- 3) 重放节点注册 ----
resp="$(printf '%s' "$BODY" | curl -s --max-time 15 -X POST \
  "$CUBEOPS_ADDR/internal/v1/node-agent/nodes/register" \
  -H 'Content-Type: application/json' --data @- || true)"
log "注册响应：$(printf '%s' "$resp" | python3 -c 'import sys,json;d=json.load(sys.stdin);print({k:d.get(k) for k in ["node_id","quota_cpu","quota_mem_mb","healthy"]})' 2>/dev/null || printf '%s' "$resp")"

# ---- 4) 校验（CubeMaster 每隔数秒从 CubeOps 同步节点视图）----
sleep 5
log "校验（CubeOps 节点视图）："
curl -s --max-time 15 "$CUBEOPS_ADDR/internal/v1/nodes" | python3 -c '
import sys, json
for n in json.load(sys.stdin):
    print("  node=%s QuotaCpu=%s QuotaMem=%s Healthy=%s" % (
        n.get("InstanceID"), n.get("QuotaCpu"), n.get("QuotaMem"), n.get("Healthy")))
' 2>/dev/null || log "  校验查询失败"
log "完成：新配额已上报。可重跑 c50 档验证 130597 是否消失。"
