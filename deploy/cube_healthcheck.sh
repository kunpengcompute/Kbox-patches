#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# CubeSandbox 健康校验
#
# 一次性确认：系统前置 / systemd 单元 / 支撑容器 / 关键端口 / HTTP 健康 /
#            组件版本化目录一致性 / 节点注册；可选校验单个沙箱的 envd 与 adb 端口。
#
# 用法：
#   sudo bash cube_healthcheck.sh
#   sudo bash cube_healthcheck.sh --sandbox 10.100.2.44
#
# 退出码：0 = 全部通过（可有 WARN）；1 = 存在 FAIL。
set -uo pipefail

TC="${CUBE_SANDBOX_INSTALL_ROOT:-/usr/local/services/cubetoolbox}"
CV="${CUBE_COMPONENT_VERSIONS_ROOT:-/data/cubelet/root/component_versions}"
SANDBOX_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sandbox) SANDBOX_IP="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

FAIL=0
WARN=0
PASS_N=0

section() { printf '\n== %s ==\n' "$*"; }
pass() { printf '  [ OK ] %s\n' "$*"; PASS_N=$((PASS_N + 1)); }
warn() { printf '  [WARN] %s\n' "$*"; WARN=$((WARN + 1)); }
fail() { printf '  [FAIL] %s\n' "$*"; FAIL=$((FAIL + 1)); }

# cubemastercli：优先 PATH，其次安装目录
CMCLI="$(command -v cubemastercli 2>/dev/null || true)"
[[ -n "${CMCLI}" ]] || { [[ -x "${TC}/CubeMaster/bin/cubemastercli" ]] && CMCLI="${TC}/CubeMaster/bin/cubemastercli"; }

# ---------------------------------------------------------------------------
section "1. 系统前置"
if [[ -e /dev/kvm ]]; then
  pass "/dev/kvm 存在"
else
  fail "/dev/kvm 不存在，无法创建沙箱"
fi

DATA_FSTYPE="$(findmnt -no FSTYPE /data 2>/dev/null || true)"
[[ -n "${DATA_FSTYPE}" ]] || DATA_FSTYPE="$(findmnt -no FSTYPE /data/cubelet 2>/dev/null || true)"
if [[ "${DATA_FSTYPE}" == "xfs" ]]; then
  pass "/data 为 XFS"
else
  fail "/data 不是 XFS（当前: ${DATA_FSTYPE:-未挂载}），install.sh 会直接终止"
fi

if docker info >/dev/null 2>&1; then
  pass "docker 可用（Server $(docker version --format '{{.Server.Version}}' 2>/dev/null)）"
else
  fail "docker 不可用（docker info 失败）"
fi

COMPOSE_V2=0
if docker compose version >/dev/null 2>&1; then
  COMPOSE_V2=1
  pass "docker compose v2 可用（$(docker compose version 2>/dev/null | head -1)）"
elif COMPOSE_OUT="$(docker-compose version 2>/dev/null)" && [[ "${COMPOSE_OUT}" == *"version v2"* ]]; then
  COMPOSE_V2=1
  pass "docker-compose v2 可用（${COMPOSE_OUT}）"
fi
if [[ "${COMPOSE_V2}" != "1" ]]; then
  fail "未找到 Compose v2（需 docker compose 插件，或 v2 的 docker-compose 独立二进制）"
fi

# ---------------------------------------------------------------------------
section "2. systemd 单元"
unit_state() { systemctl is-active "$1" 2>/dev/null || true; }

if [[ "$(systemctl is-active cube-sandbox-control.target 2>/dev/null)" == "active" ]]; then
  pass "cube-sandbox-control.target active"
else
  fail "cube-sandbox-control.target 非 active（systemctl start cube-sandbox-control.target）"
fi

for u in cubelet cubemaster cube-api cubeops; do
  st="$(unit_state "cube-sandbox-${u}")"
  if [[ "${st}" == "active" ]]; then
    pass "cube-sandbox-${u} active"
  else
    fail "cube-sandbox-${u} = ${st:-unknown}"
  fi
done

for u in mysql redis minio coredns cube-proxy cube-lifecycle-manager cube-egress webui dns; do
  st="$(unit_state "cube-sandbox-${u}")"
  case "${u}" in
    mysql|redis|minio)
      [[ "${st}" == "active" ]] && pass "cube-sandbox-${u} active" || fail "cube-sandbox-${u} = ${st:-unknown}" ;;
    *)
      [[ "${st}" == "active" ]] && pass "cube-sandbox-${u} active" || warn "cube-sandbox-${u} = ${st:-unknown}（非关键单元，可能不影响沙箱）" ;;
  esac
done

FAILED_UNITS="$(systemctl --failed --no-legend --plain 2>/dev/null | awk '{print $1}' | grep '^cube-sandbox-' | tr '\n' ' ' || true)"
if [[ -n "${FAILED_UNITS}" ]]; then
  warn "存在 failed 的 cube 单元: ${FAILED_UNITS}（修复依赖后 systemctl reset-failed）"
fi

# ---------------------------------------------------------------------------
section "3. 支撑容器"
container_running() {
  local name="$1"
  [[ "$(docker inspect -f '{{.State.Running}}' "${name}" 2>/dev/null)" == "true" ]]
}
for c in cube-sandbox-mysql cube-sandbox-redis cube-sandbox-minio; do
  if container_running "${c}"; then
    pass "容器 ${c} 运行中"
  else
    fail "容器 ${c} 未运行（systemctl restart cube-sandbox-${c#cube-sandbox-}）"
  fi
done
for c in cube-proxy-coredns cube-proxy cube-sandbox-cube-lifecycle-manager cube-egress cube-sandbox-webui; do
  if docker inspect "${c}" >/dev/null 2>&1; then
    container_running "${c}" && pass "容器 ${c} 运行中" || warn "容器 ${c} 未运行"
  fi
done

# ---------------------------------------------------------------------------
section "4. 关键端口"
# 先一次性取出所有监听端口，再用纯 bash 匹配：避免 `ss | awk | grep -q` 在
# pipefail 下因 grep 提前退出产生 SIGPIPE，导致检测结果不稳定。
LISTEN_PORTS="$(ss -H -lnt 2>/dev/null | awk '{n = split($4, a, ":"); if (n > 1) print a[n]}' | sort -u)"
port_listening() { [[ $'\n'"${LISTEN_PORTS}"$'\n' == *$'\n'"$1"$'\n'* ]]; }
for p in 3306 6379 9000 8089 3000 3010; do
  if port_listening "${p}"; then
    pass "端口 ${p} 监听中"
  else
    case "${p}" in
      3306) fail "端口 3306（MySQL）未监听" ;;
      6379) fail "端口 6379（Redis）未监听" ;;
      9000) warn "端口 9000（MinIO）未监听" ;;
      *) fail "端口 ${p} 未监听" ;;
    esac
  fi
done

# ---------------------------------------------------------------------------
section "5. HTTP 健康"
http_ok() { # $1=名称 $2=url
  if curl -fsS -o /dev/null -m 5 "$2" 2>/dev/null; then
    pass "$1 正常（$2）"
  else
    fail "$1 异常（$2）"
  fi
}
http_ok "CubeMaster" "http://127.0.0.1:8089/notify/health"
http_ok "CubeAPI" "http://127.0.0.1:3000/health"
http_ok "CubeOps" "http://127.0.0.1:3010/health"

if curl -fsS -o /dev/null -m 5 "http://127.0.0.1:9998/v1/policies/dump" 2>/dev/null; then
  pass "Cubelet 内嵌网络运行时（egress dump）正常"
else
  warn "Cubelet 内嵌网络运行时未响应（127.0.0.1:9998），首个沙箱创建后会自动就绪"
fi

# ---------------------------------------------------------------------------
section "6. 组件版本化目录一致性"
# 模板构建读取 /usr/local 下的组件，沙箱恢复读取 component_versions/<版本>/ 下的副本；
# 两者内容必须一致，否则模板能建但沙箱起不来。
same_file() { # $1=名称 $2=live $3=versioned
  local name="$1" live="$2" ver="$3"
  if [[ ! -f "${live}" ]]; then fail "${name}: 缺少 ${live}"; return; fi
  if [[ ! -f "${ver}" ]]; then fail "${name}: 缺少 ${ver}"; return; fi
  if [[ "$(sha256sum "${live}" | awk '{print $1}')" == "$(sha256sum "${ver}" | awk '{print $1}')" ]]; then
    pass "${name}: 一致"
  else
    fail "${name}: 不一致（需以 ${live} 覆盖 ${ver}，再重建模板）"
  fi
}

SHIM_VER=""
if command -v python3 >/dev/null 2>&1 && [[ -f "${TC}/release-manifest.json" ]]; then
  SHIM_VER="$(python3 -c '
import json, sys
d = json.load(open(sys.argv[1]))
print((d.get("components", {}).get("containerd-shim-cube-rs") or {}).get("version", ""))
' "${TC}/release-manifest.json" 2>/dev/null || true)"
fi
for f in containerd-shim-cube-rs cube-runtime; do
  if [[ -n "${SHIM_VER}" && -f "${CV}/cube-shim/${SHIM_VER}/bin/${f}" ]]; then
    same_file "cube-shim/${f}" "${TC}/cube-shim/bin/${f}" "${CV}/cube-shim/${SHIM_VER}/bin/${f}"
  else
    warn "cube-shim/${f}: 无法定位版本化副本（缺 release-manifest.json 或 python3），跳过"
  fi
done

AGENT_VER="$(tr -d '[:space:]' < "${TC}/cube-agent/version" 2>/dev/null || true)"
if [[ -n "${AGENT_VER}" ]]; then
  same_file "cube-agent" "${TC}/cube-agent/cube-agent.ext4" "${CV}/cube-agent/${AGENT_VER}/cube-agent.ext4"
else
  warn "cube-agent: 缺少 ${TC}/cube-agent/version，跳过"
fi

IMAGE_VER="$(tr -d '[:space:]' < "${TC}/cube-image/version" 2>/dev/null || true)"
if [[ -n "${IMAGE_VER}" ]]; then
  same_file "cube-image" "${TC}/cube-image/cube-guest-image-cpu.img" \
    "${CV}/cube-image/${IMAGE_VER}/cube-guest-image-cpu.img"
else
  warn "cube-image: 缺少 ${TC}/cube-image/version，跳过"
fi

KERNEL_VER="$(tr -d '[:space:]' < "${TC}/cube-kernel-scf/version" 2>/dev/null || true)"
KERNEL_HEX="${KERNEL_VER##*sha256:}"
KERNEL_KEY="sha256-${KERNEL_HEX:0:12}"
if [[ -n "${KERNEL_HEX}" && -f "${CV}/cube-kernel-scf/${KERNEL_KEY}/vmlinux-bm" ]]; then
  same_file "cube-kernel-scf" "${TC}/cube-kernel-scf/vmlinux-bm" \
    "${CV}/cube-kernel-scf/${KERNEL_KEY}/vmlinux-bm"
else
  warn "cube-kernel-scf: 未找到版本化副本 ${CV}/cube-kernel-scf/${KERNEL_KEY}/vmlinux-bm"
fi

# ---------------------------------------------------------------------------
section "7. 节点注册"
if [[ -z "${CMCLI}" ]]; then
  fail "找不到 cubemastercli"
else
  INV="$("${CMCLI}" listinventory 2>&1 || true)"
  if grep -qE '^[[:space:]]*[0-9]+[[:space:]]+[0-9]+' <<< "${INV}"; then
    pass "节点已注册（listinventory 有数值）"
  else
    warn "节点尚未注册（Cubelet 启动后约需 120s）: $(printf '%s' "${INV}" | head -1)"
  fi
fi

# ---------------------------------------------------------------------------
if [[ -n "${SANDBOX_IP}" ]]; then
  section "8. 沙箱 ${SANDBOX_IP}"
  tcp_open() { timeout 3 bash -c "</dev/tcp/$1/$2" 2>/dev/null; }
  if tcp_open "${SANDBOX_IP}" 49983; then
    pass "envd 49983 可达"
  else
    fail "envd 49983 不可达"
  fi
  if tcp_open "${SANDBOX_IP}" 5555; then
    pass "adb 5555 可达（Android adbd 已就绪）"
  else
    fail "adb 5555 不可达（Android 侧 adbd 未监听）"
  fi
fi

# ---------------------------------------------------------------------------
printf '\n== 汇总 ==\n  通过 %d 项，失败 %d 项，警告 %d 项\n' "${PASS_N}" "${FAIL}" "${WARN}"
if [[ "${FAIL}" -gt 0 ]]; then
  echo "  结论：存在 FAIL，Cube 功能尚不正常"
  exit 1
fi
echo "  结论：Cube 功能正常（WARN 项按说明确认）"
exit 0
