#!/usr/bin/env bash
#
# redroid_operation.sh —— CubeSandbox（Cube + Redroid）模板与沙箱统一管理脚本
#
# 依赖：bash、curl、cubemastercli、python3（生成 multirun 请求 JSON 与格式化输出）。
# 部署前提见 ../guide/user_guide.md；完整用法文档见 ../guide/redroid_user_guide.md。
#
# 配置文件 redroid_config.conf（与本脚本同目录，可用 --config 或环境变量
# REDROID_CONFIG 指定其他文件），bash 键值格式，分两段：
#   TPL_* 段 —— template-create 的默认参数（TPL_IMAGE 缺省镜像/TPL_CPU/TPL_MEMORY/
#                  TPL_WRITABLE_LAYER_SIZE/TPL_PROBE/TPL_PROBE_TIMEOUT_MS/
#                  TPL_ANNOTATIONS/TPL_REDROID_ARGS）；
#                  alias 必填于命令行 --alias，不再从配置读取
#   SBX_* 段 —— 启动沙箱的 multirun 请求体（SBX_INSTANCE_TYPE/SBX_NETWORK_TYPE/
#                  SBX_NAMESPACE/SBX_ANNOTATIONS/SBX_LABELS/SBX_SOURCE_ID）；
#                  模板/快照 ID 由脚本运行时注入
#                   （cube.master.appsnapshot.template.id 所在键）
#
# 环境变量：
#   CUBE_API_URL      CubeAPI 地址（默认 http://127.0.0.1:3000）
#   CUBE_API_KEY      CubeAPI 启用鉴权时填写（同时以 X-API-Key 与 Bearer 头发送）
#   CUBEMASTERCLI     cubemastercli 路径（默认取 PATH 中的 cubemastercli）
#   CUBE_API_TIMEOUT  CubeAPI 单次请求超时秒数（默认 300；快照/删除模板为服务端
#                     240s 档长操作，不要低于 300）
#   REDROID_CONFIG    配置文件路径（默认 <脚本目录>/redroid_config.conf）

set -euo pipefail

CUBE_API_URL="${CUBE_API_URL:-http://127.0.0.1:3000}"
CUBE_API_URL="${CUBE_API_URL%/}"
CUBE_API_KEY="${CUBE_API_KEY:-}"
CUBEMASTERCLI="${CUBEMASTERCLI:-cubemastercli}"
CUBE_API_TIMEOUT="${CUBE_API_TIMEOUT:-300}"

# 脚本目录（默认配置文件 redroid_config.conf 放在这里）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# --config 可覆盖的配置文件路径（空表示用 REDROID_CONFIG 或默认值）
OPT_CONFIG=""

die() { printf '错误：%s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'EOF'
redroid_operation.sh —— CubeSandbox（Cube + Redroid）模板与沙箱管理脚本

用法：
  bash redroid_operation.sh <命令> [参数]

模板操作（模板生命周期管理）：
  template-create --alias <别名> [--image <镜像名>] [--config <文件>]
                                    从 OCI 镜像创建 redroid 模板（前台等待构建完成）。
                                    --alias 必填（重复时报错）；--image 缺省用配置
                                    template.image；其余参数（cpu/memory/注解等）取自
                                    配置文件的 template 段
  template-list [--wide]             列举模板
  template-info <tpl-id>             查询模板详情（含各节点副本状态）
  template-delete <tpl-id>           删除模板
  template-commit <sandbox-id>       把运行中的沙箱提交为新模板

沙箱操作（沙箱生命周期管理）：
  sandbox-create --alias <模板别名> [--config <文件>]
                                    按模板别名创建沙箱（脚本查 template list 换算为
                                    tpl-…）
  sandbox-create --snapshot <snap-id> [--config <文件>]
                                    从快照派生新沙箱（--alias 与 --snapshot 二选一，必填）
                                    multirun 请求体取自配置文件的 sandbox 段
  sandbox-list [--all] [--wide]     列举沙箱
  sandbox-info <sandbox-id>         查询沙箱详情
  sandbox-pause <sandbox-id>        暂停沙箱（保留内存快照，暂停期间零资源占用）
  sandbox-connect <sandbox-id> [--timeout <秒>]
                                    连接（唤醒）已暂停沙箱；--timeout 顺带设置空闲超时
                                    （-1 表示永不过期）
  sandbox-destroy <sandbox-id> [sandbox-id ...]
                                    销毁沙箱（可一次多个）

快照操作（沙箱状态管理）：
  snapshot-create <sandbox-id> [--name <显示名>]
                                    为运行中的沙箱打快照（制作期间沙箱会被短暂暂停）
  snapshot-list [--sandbox <sandbox-id>] [--limit <N>]
                                    列举快照（--sandbox 按源沙箱过滤）
  snapshot-delete <snap-id>         删除快照（快照独立于沙箱生命周期，需显式删除）
  sandbox-clone <sandbox-id> [--count <N>] [--config <文件>]
                                    克隆：给源沙箱打快照，再从快照派生 N 个新沙箱；
                                    源沙箱保持运行不受影响
  sandbox-rollback <sandbox-id> <snap-id>
                                    把沙箱原地回滚到指定快照（沙箱 ID 不变）

其他：
  health                            检查 CubeAPI 健康状态
  -h, --help                        显示本帮助

配置文件（默认 <脚本目录>/redroid_config.conf）：
  TPL_* 段   template-create 的默认参数：TPL_IMAGE（缺省镜像全名）、TPL_CPU、
            TPL_MEMORY、TPL_WRITABLE_LAYER_SIZE、TPL_PROBE、TPL_PROBE_TIMEOUT_MS、
            TPL_ANNOTATIONS、TPL_REDROID_ARGS（androidboot.redroid_width/height/dpi/fps）。
            alias 不再从配置读取，--alias 为必填命令行参数
  SBX_* 段   启动沙箱的 multirun 请求体：SBX_INSTANCE_TYPE、SBX_NETWORK_TYPE、
            SBX_NAMESPACE、SBX_ANNOTATIONS、SBX_LABELS（模板/快照 ID 由脚本运行时注入）
  可用 --config <文件> 或环境变量 REDROID_CONFIG 指定其他配置文件
  注意：cube.vm.cgroup.unified_hierarchy=false 为 redroid 必需注解，缺失时脚本会
        自动补上（勿改为其他值，否则沙箱会进入重启循环）

环境变量（均有默认值，可不配置）：
  CUBE_API_URL      CubeAPI 地址（默认 http://127.0.0.1:3000）
  CUBE_API_KEY      CubeAPI 启用鉴权时填写
  CUBEMASTERCLI     cubemastercli 路径（默认 PATH 中的 cubemastercli）
  CUBE_API_TIMEOUT  CubeAPI 请求超时秒数（默认 300）
  REDROID_CONFIG    配置文件路径

示例：
  bash redroid_operation.sh health
  bash redroid_operation.sh template-create --alias android14-4c8g
  bash redroid_operation.sh template-create --alias android14-4c8g --image 127.0.0.1:5000/redroid:14.0.0_r75_arm64_only_zp
  bash redroid_operation.sh sandbox-create --alias android14-4c8g
  bash redroid_operation.sh sandbox-create --snapshot snap-xxxxxxxxxxxxxxxxxxxxxxxx
  bash redroid_operation.sh snapshot-create sbx-xxxxxxxxxxxxxxxxxxxxxxxx --name cocos-scene
  bash redroid_operation.sh sandbox-clone sbx-xxxxxxxxxxxxxxxxxxxxxxxx --count 3
  bash redroid_operation.sh sandbox-rollback sbx-xxxxxxxxxxxxxxxxxxxxxxxx snap-xxxxxxxxxxxxxxxxxxxxxxxx
  bash redroid_operation.sh sandbox-destroy sbx-xxxxxxxxxxxxxxxxxxxxxxxx

详细文档：../guide/redroid_user_guide.md
EOF
    exit 0
}

# ---------------------------------------------------------------- 通用工具

need_curl() {
    command -v curl >/dev/null 2>&1 \
        || die "未找到 curl，请先安装：dnf install -y curl"
}

need_cli() {
    command -v "$CUBEMASTERCLI" >/dev/null 2>&1 || die \
"未找到 cubemastercli（$CUBEMASTERCLI）。若已部署 CubeSandbox，可执行：
  ln -sf /usr/local/services/cubetoolbox/CubeMaster/bin/cubemastercli /usr/local/bin/cubemastercli"
}

# ---------------------------------------------------------------- 配置文件

need_python3() {
    command -v python3 >/dev/null 2>&1 \
        || die "未找到 python3（解析配置文件需要）：dnf install -y python3"
}

# 生效的配置文件路径：--config > 环境变量 REDROID_CONFIG > <脚本目录>/redroid_config.conf
resolve_config() {
    local cfg="${OPT_CONFIG:-${REDROID_CONFIG:-$SCRIPT_DIR/redroid_config.conf}}"
    [ -f "$cfg" ] || die "配置文件不存在：$cfg
可用 --config <文件> 指定，或设环境变量 REDROID_CONFIG；默认值随脚本同目录（redroid_config.conf）"
    printf '%s' "$cfg"
}

# 从配置文件 template 段（TPL_* 键）生成 create-from-image 参数链
# （每行一个，供 mapfile 使用；提示信息走 stderr，stdout 只含参数行）。
# 必需注解缺失时自动补 false（缺失会导致 redroid 沙箱重启循环，见文件头说明第 1 条）。
# $1 配置文件  $2 可选：--image 覆盖值（空则用配置 TPL_IMAGE）
#             $3 可选：--alias 覆盖值（命令行必填，不读配置）
cfg_template_args() {
    local cfg="$1" image="${2-}" alias="${3-}"
    # shellcheck disable=SC1090
    source "$cfg"
    image="${image:-${TPL_IMAGE:-}}"
    if [ -z "$image" ]; then
        die "未指定 --image，且配置文件的 TPL_IMAGE 为空（须为带 registry 前缀的镜像全名，如 127.0.0.1:5000/redroid:14.0.0_r75_arm64_only）"
    fi
    TPL_WRITABLE_LAYER_SIZE="${TPL_WRITABLE_LAYER_SIZE:-10Gi}"
    TPL_PROBE="${TPL_PROBE:-49983}"
    TPL_PROBE_TIMEOUT_MS="${TPL_PROBE_TIMEOUT_MS:-180000}"
    TPL_CPU="${TPL_CPU:-4000}"
    TPL_MEMORY="${TPL_MEMORY:-8192}"
    local -a TPL_ANNOTATIONS=("${TPL_ANNOTATIONS[@]:-}")
    local -a TPL_REDROID_ARGS=("${TPL_REDROID_ARGS[@]:-}")

    local ANNO="cube.vm.cgroup.unified_hierarchy"
    local -a args=(
        "template" "create-from-image"
        "--image" "$image"
        "--writable-layer-size" "$TPL_WRITABLE_LAYER_SIZE"
        "--probe" "$TPL_PROBE"
        "--probe-timeout-ms" "$TPL_PROBE_TIMEOUT_MS"
        "--cpu" "$TPL_CPU"
        "--memory" "$TPL_MEMORY"
        "--instance-type" "cubebox"
        "--network-type" "tap"
        "--with-cube-ca=false"
    )
    local found=0 a
    for a in "${TPL_ANNOTATIONS[@]}"; do
        case "$a" in
            "$ANNO="*) found=1 ;;
        esac
        args+=( "--annotation" "$a" )
    done
    if [ "$found" = 0 ]; then
        args+=( "--annotation" "$ANNO=false" )
        echo "注意：template.annotations 缺少 $ANNO，已自动补 false" >&2
    fi
    [ -n "$alias" ] && args+=( "--alias" "$alias" )
    for a in "${TPL_REDROID_ARGS[@]}"; do
        args+=( "--arg" "$a" )
    done
    printf '%s\n' "${args[@]}"
}

# 从配置文件 sandbox 段（SBX_* 键）生成 multirun 请求 JSON，写入 $3。
# $1 配置文件  $2 模板/快照 ID（注入 annotations 与 labels；可省略，省略时按
#              SBX_SOURCE_ID → 已有的 cube.master.appsnapshot.template.id 值
#              （占位符 __SANDBOX_SOURCE_ID__ 视为未指定）的顺序取，仍缺则报错）
#              $3 输出文件
# 必需注解缺失时同样自动补 false。
cfg_sandbox_request() {
    local cfg="$1" src_id="${2-}" out="$3"
    # shellcheck disable=SC1090
    source "$cfg"
    SBX_INSTANCE_TYPE="${SBX_INSTANCE_TYPE:-cubebox}"
    SBX_NETWORK_TYPE="${SBX_NETWORK_TYPE:-tap}"
    SBX_NAMESPACE="${SBX_NAMESPACE:-default}"
    SBX_SOURCE_ID="${SBX_SOURCE_ID:-}"
    # 数组转多行文本（每行 k=v）传给 python3
    local ann_text lbl_text
    ann_text="$(printf '%s\n' "${SBX_ANNOTATIONS[@]:-}")"
    lbl_text="$(printf '%s\n' "${SBX_LABELS[@]:-}")"

    SRCD_ID="$src_id" SBX_SOURCE_ID="$SBX_SOURCE_ID" \
    SBX_INSTANCE_TYPE="$SBX_INSTANCE_TYPE" \
    SBX_NETWORK_TYPE="$SBX_NETWORK_TYPE" \
    SBX_NAMESPACE="$SBX_NAMESPACE" \
    SBX_ANN_TEXT="$ann_text" SBX_LBL_TEXT="$lbl_text" \
    OUT_PATH="$out" python3 <<'PY'
import json, os, sys

ANNO = "cube.vm.cgroup.unified_hierarchy"
TID = "cube.master.appsnapshot.template.id"

def kv(text):
    d = {}
    for line in (text or "").splitlines():
        key, sep, val = line.partition("=")
        if sep:
            d[key] = val
    return d

src_id = os.environ["SRCD_ID"]
ann = kv(os.environ.get("SBX_ANN_TEXT", ""))
labels = kv(os.environ.get("SBX_LBL_TEXT", ""))
if not src_id:
    src_id = os.environ.get("SBX_SOURCE_ID", "") or ann.get(TID) or labels.get(TID) or ""
    if src_id == "__SANDBOX_SOURCE_ID__":
        src_id = ""
if not src_id:
    sys.exit("未指定模板/快照 ID：请用 --alias <模板别名> / --snapshot <snap-id> 传入，"
             "或在配置文件的 SBX_SOURCE_ID（或 cube.master.appsnapshot.template.id）中填写")
if not (src_id.startswith("tpl-") or src_id.startswith("snap-")):
    sys.exit("模板/快照 ID 非法: %s（须为 tpl-… 或 snap-…）" % src_id)
if ANNO not in ann:
    ann[ANNO] = "false"
    print("注意：sandbox.annotations 缺少 %s，已自动补 false" % ANNO, file=sys.stderr)
ann[TID] = src_id
labels[TID] = src_id
req = {
    "instance_type": os.environ.get("SBX_INSTANCE_TYPE", "cubebox"),
    "network_type": os.environ.get("SBX_NETWORK_TYPE", "tap"),
    "namespace": os.environ.get("SBX_NAMESPACE", "default"),
    "annotations": ann,
    "labels": labels,
}
with open(os.environ["OUT_PATH"], "w") as fh:
    json.dump(req, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
PY
}

# 回显并执行 cubemastercli
run_cli() {
    printf '+ %s %s\n' "$CUBEMASTERCLI" "$*"
    "$CUBEMASTERCLI" "$@"
}

# JSON 输出美化：有 python3 则格式化，否则原样输出
pretty() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c '
import json, sys
data = sys.stdin.read()
try:
    sys.stdout.write(json.dumps(json.loads(data), ensure_ascii=False, indent=2) + "\n")
except Exception:
    sys.stdout.write(data)
'
    else
        cat
    fi
}

# api <METHOD> <PATH> [JSON_BODY]
# 调用 CubeAPI（E2B 兼容接口）。成功（2xx）时把响应体打到 stdout；
# 失败时把状态码与响应体打到 stderr 并以非零码退出。
api() {
    local method="$1" path="$2" body="${3-}"
    local tmp status
    need_curl
    tmp="$(mktemp)"
    local -a args=(
        -sS -o "$tmp" -w '%{http_code}' -X "$method"
        -H 'Content-Type: application/json'
        --connect-timeout 10 --max-time "$CUBE_API_TIMEOUT"
        "${CUBE_API_URL}${path}"
    )
    if [ -n "$CUBE_API_KEY" ]; then
        args+=( -H "X-API-Key: $CUBE_API_KEY" -H "Authorization: Bearer $CUBE_API_KEY" )
    fi
    if [ -n "$body" ]; then
        args+=( --data "$body" )
    fi
    if ! status="$(curl "${args[@]}")"; then
        rm -f "$tmp"
        die "调用 CubeAPI 失败（$CUBE_API_URL $method $path）。
请确认 CUBE_API_URL 是否正确、网络是否可达、CUBE_API_TIMEOUT（当前 $CUBE_API_TIMEOUT 秒）是否足够，
以及服务状态：systemctl is-active cube-sandbox-cube-api"
    fi
    case "$status" in
        2*)
            if [ -s "$tmp" ]; then cat "$tmp"; echo; fi
            ;;
        *)
            printf 'HTTP %s %s %s\n' "$status" "$method" "$path" >&2
            sed 's/^/  /' "$tmp" >&2
            rm -f "$tmp"
            exit 1
            ;;
    esac
    rm -f "$tmp"
}

# 从文本中取第一个正则匹配（grep 无匹配时返回空串而不是让 set -e 生效）
first_match() {
    printf '%s\n' "$1" | grep -oE "$2" | head -n1 || true
}

# ---------------------------------------------------------------- 沙箱启动（cubemastercli multirun）

# 用 multirun 从模板/快照启动沙箱。
# $1: 模板 ID（tpl-…）或快照 ID（snap-…）；可省略，省略时从配置 sandbox.source_id 读取
# $2: 启动个数（默认 1）
# 说明：请求体取自配置文件的 sandbox 段（写法沿用 user_guide.md §5.2 验证过的内容），
#       脚本运行时把模板/快照 ID 注入 annotations 与 labels 两个
#       cube.master.appsnapshot.template.id 键；redroid 必需注解
#       cube.vm.cgroup.unified_hierarchy=false 若被误删会自动补回。
sandbox_run() {
    local tpl="${1-}" count="${2:-1}"
    local cfg req out ids id ip
    need_python3
    cfg="$(resolve_config)"
    req="$(mktemp /tmp/redroid-ops-req-XXXXXX.json)"
    cfg_sandbox_request "$cfg" "$tpl" "$req" \
        || { rm -f "$req"; die "生成 multirun 请求失败（配置文件：$cfg）"; }
    if [ -z "$tpl" ]; then
        # 未显式传模板/快照 ID 时，从已生成的请求 JSON 中取回注入的源 ID（供日志/提示用）
        tpl="$(python3 -c '
import json, sys
with open(sys.argv[1]) as fh:
    req = json.load(fh)
TID = "cube.master.appsnapshot.template.id"
print(req.get("annotations", {}).get(TID, ""))' "$req")"
    fi
    # multirun 的日志（含 sandBoxId/Ip）输出到 stderr，需 2>&1 一并捕获供解析
    out="$(run_cli multirun --norm --runcnt "$count" --runcc 1 "$req" 2>&1)" || {
        rm -f "$req"
        die "沙箱启动失败（模板/快照：$tpl）。常见原因见 ../guide/user_guide.md 附录 B"
    }
    rm -f "$req"
    printf '%s\n' "$out"
    ids="$(printf '%s\n' "$out" | grep -oE 'sandBoxId:[0-9a-fA-F]{32}|sbx-[0-9A-Za-z]+' | sed -E 's/^sandBoxId://' || true)"
    ip="$(printf '%s\n' "$out" | grep -i 'ip' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1 || true)"
    echo
    if [ -z "$ids" ]; then
        echo "（未能从输出中解析出沙箱 ID，请检查上方 multirun 原始输出，期望 code:200）"
        return 0
    fi
    if [ "$count" -eq 1 ]; then
        id="$(printf '%s\n' "$ids" | head -n1)"
        echo "SANDBOX_ID=$id"
        if [ -n "$ip" ]; then
            echo "SANDBOX_IP=$ip"
            echo "验证 Android 就绪：curl -s http://$ip:49983/metrics （返回 JSON 即就绪，见 user_guide.md §5.8）"
        fi
    else
        echo "SANDBOX_IDS："
        printf '%s\n' "$ids" | sed 's/^/  /'
    fi
}

# ---------------------------------------------------------------- 模板操作

# 按 alias 精确查找模板 ID（tpl-…）；无匹配输出空串。
# 模板列表 ALIAS 列与 TEMPLATE_ID 列以空白分隔，alias 规则 [a-z0-9-] 无内嵌空格。
# 注意：awk 不能匹配后立即 exit——那样会关闭管道使 CLI 收到 SIGPIPE（141），
#       set -euo pipefail 下会让整个脚本静默崩溃。
template_alias_to_id() {
    cubemastercli template list -o wide 2>/dev/null \
        | awk -v a="$1" '$1 ~ /^tpl-/ && $2 == a { print $1 }' \
        || true
}

# alias 是否已存在（0=存在，1=不存在）
template_alias_exists() {
    [ -n "$(template_alias_to_id "$1")" ]
}

# ：模板生命周期管理-创建（cubemastercli）
# --image <镜像名> 可覆盖配置 template.image（缺省用配置值）
# --alias <别名>   必填；重复时报错
cmd_template_create() {
    local image="" alias=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --image)  [ $# -ge 2 ] || die "--image 需要一个值";  image="$2";  shift 2 ;;
            --alias)  [ $# -ge 2 ] || die "--alias 需要一个值";  alias="$2";  shift 2 ;;
            --config) [ $# -ge 2 ] || die "--config 需要一个值"; OPT_CONFIG="$2"; shift 2 ;;
            *) die "template-create：未知参数 '$1'" ;;
        esac
    done
    [ -n "$alias" ] || die "template-create：必须指定 --alias <别名>（alias 必填，无法创建模板）"
    need_cli
    need_python3
    if template_alias_exists "$alias"; then
        die "模板已存在：alias=$alias（$(template_alias_to_id "$alias")），勿重复创建"
    fi
    local cfg argtext
    cfg="$(resolve_config)"
    echo "配置文件：$cfg"
    argtext="$(cfg_template_args "$cfg" "$image" "$alias")" || die "解析配置文件的 template 段失败"
    local -a args=()
    mapfile -t args <<<"$argtext"
    [ "${#args[@]}" -gt 0 ] || die "解析配置文件的 template 段失败"

    local out tpl
    out="$(run_cli "${args[@]}")" || die "模板创建失败。常见原因见 ../guide/user_guide.md 附录 B（Cubelet 未就绪 / 节点未注册 / 镜像拉取超时）"
    printf '%s\n' "$out"
    tpl="$(first_match "$out" 'tpl-[0-9a-f]+')"
    if [ -n "$tpl" ]; then
        echo
        echo "TEMPLATE_ID=$tpl"
        echo "启动沙箱：bash $0 sandbox-create --alias $alias"
    fi
}

# ：模板生命周期管理-列举（cubemastercli）
cmd_template_list() {
    local wide=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --wide|-w) wide=1; shift ;;
            *) die "template-list：未知参数 '$1'" ;;
        esac
    done
    need_cli
    if [ -n "$wide" ]; then
        run_cli template list -o wide
    else
        run_cli template list
    fi
}

# ：模板生命周期管理-查询（cubemastercli）
cmd_template_info() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 1 ] || die "用法：bash $0 template-info <tpl-xxxxxxxxxxxxxxxxxxxxxxxx>"
    need_cli
    run_cli template info "$1"
}

# ：模板生命周期管理-删除（cubemastercli）
cmd_template_delete() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 1 ] || die "用法：bash $0 template-delete <tpl-xxxxxxxxxxxxxxxxxxxxxxxx>"
    need_cli
    run_cli template delete --template-id "$1"
    echo
    echo "已请求删除模板：$1"
    echo "提示：若报 already in progress（t_cube_template_image_job 残留 PENDING 自锁），处理办法见 ../guide/user_guide.md §5.6。"
}

# ：模板生命周期管理-从运行中沙箱提交为新模板
# 说明：CubeAPI 无对应端点，走 cubemastercli template commit（user_guide.md §5.7）
cmd_template_commit() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 1 ] || die "用法：bash $0 template-commit <sandbox-id>（沙箱须为 running）"
    need_cli
    local out tpl build
    out="$(run_cli template commit --sandbox-id "$1")" || die "提交模板失败（沙箱须为 running 状态）"
    printf '%s\n' "$out"
    tpl="$(first_match "$out" 'tpl-[0-9a-f]+')"
    build="$(first_match "$out" 'build-[0-9A-Za-z]+')"
    echo
    if [ -n "$tpl" ]; then
        echo "TEMPLATE_ID=$tpl"
    fi
    if [ -n "$build" ]; then
        echo "BUILD_ID=$build"
        echo "跟踪构建进度：$CUBEMASTERCLI template build-watch --build-id $build"
    fi
}

# ---------------------------------------------------------------- 沙箱操作

# ：沙箱生命周期管理-创建 / 沙箱状态管理-从快照派生新沙箱
# --alias <模板别名>：按模板别名确定模板（脚本查 template list 换算为 tpl-…）
# --snapshot <snap-id>：从快照派生新沙箱（--alias 与 --snapshot 二选一，必填）
# 因 redroid 必需注解 CubeAPI 无法表达（见文件头说明第 1 条），统一走 cubemastercli multirun。
cmd_sandbox_create() {
    local alias_name="" snap=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --alias)    [ $# -ge 2 ] || die "--alias 需要一个值";    alias_name="$2"; shift 2 ;;
            --snapshot) [ $# -ge 2 ] || die "--snapshot 需要一个值"; snap="$2";      shift 2 ;;
            --config)   [ $# -ge 2 ] || die "--config 需要一个值";   OPT_CONFIG="$2"; shift 2 ;;
            --template) die "sandbox-create：--template 已废弃，改用 --alias <模板别名> 或 --snapshot <快照ID>" ;;
            *) die "sandbox-create：未知参数 '$1'" ;;
        esac
    done
    [ -n "$alias_name" ] && [ -n "$snap" ] && die "sandbox-create：--alias 与 --snapshot 只能二选一"
    [ -z "$alias_name" ] && [ -z "$snap" ] && die "sandbox-create：必须指定 --alias <模板别名> 或 --snapshot <快照ID>"
    local tpl
    if [ -n "$alias_name" ]; then
        tpl="$(template_alias_to_id "$alias_name")"
        [ -n "$tpl" ] || die "模板不存在：alias=$alias_name（先 template-list 确认，或 template-create --alias $alias_name 创建）"
    else
        case "$snap" in
            snap-*) tpl="$snap" ;;
            *) die "sandbox-create：--snapshot 须为快照 ID（snap-…）" ;;
        esac
    fi
    need_cli
    sandbox_run "$tpl" 1
}

# ：沙箱生命周期管理-列举（cubemastercli）
cmd_sandbox_list() {
    local all="" wide=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --all|-a)  all=1;  shift ;;
            --wide|-w) wide=1; shift ;;
            *) die "sandbox-list：未知参数 '$1'" ;;
        esac
    done
    need_cli
    if [ -n "$all" ]; then
        run_cli ls --all --wide
    elif [ -n "$wide" ]; then
        run_cli ls --wide
    else
        run_cli ls
    fi
}

# ：沙箱生命周期管理-查询（cubemastercli）
cmd_sandbox_info() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 1 ] || die "用法：bash $0 sandbox-info <sandbox-id>"
    need_cli
    run_cli info -s "$1"
}

# ：沙箱生命周期管理-暂停（CubeAPI：POST /sandboxes/{id}/pause）
cmd_sandbox_pause() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 1 ] || die "用法：bash $0 sandbox-pause <sandbox-id>"
    api POST "/sandboxes/$1/pause"
    echo "暂停请求已受理（保留内存快照，暂停期间零资源占用）。当前沙箱状态："
    api GET "/sandboxes/$1" | pretty
    echo "提示：state=paused 即暂停完成；若仍为 pausing，稍候用 sandbox-info 查看。"
    echo "      唤醒：bash $0 sandbox-connect $1"
}

# ：沙箱生命周期管理-连接（唤醒）已暂停沙箱（CubeAPI：POST /sandboxes/{id}/connect）
cmd_sandbox_connect() {
    local id="" timeout=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --timeout) [ $# -ge 2 ] || die "--timeout 需要一个值"; timeout="$2"; shift 2 ;;
            -*) die "sandbox-connect：未知参数 '$1'" ;;
            *) [ -z "$id" ] || die "sandbox-connect：只能指定一个沙箱 ID"; id="$1"; shift ;;
        esac
    done
    [ -n "$id" ] || die "用法：bash $0 sandbox-connect <sandbox-id> [--timeout <秒>|-1]"
    local body="{}"
    if [ -n "$timeout" ]; then
        [[ "$timeout" =~ ^-?[0-9]+$ ]] || die "--timeout 须为整数（秒；-1 表示永不过期）"
        body="{\"timeout\": $timeout}"
    fi
    api POST "/sandboxes/$id/connect" "$body" | pretty
    echo
    echo "已连接（若沙箱处于 paused 状态会自动唤醒）。"
}

# ：沙箱生命周期管理-销毁（cubemastercli）
cmd_sandbox_destroy() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -ge 1 ] || die "用法：bash $0 sandbox-destroy <sandbox-id> [sandbox-id ...]"
    need_cli
    run_cli cubebox destroy "$@"
    echo
    echo "已销毁：$*"
    echo "提示：若怀疑有残留进程持续占用 CPU，检查并按 PID 清理（勿用 pkill -f）："
    echo "  pgrep -f containerd-shim-cube-rs"
    echo "  kill <PID>"
}

# ---------------------------------------------------------------- 快照操作

# ：沙箱状态管理-打快照（CubeAPI：POST /sandboxes/{id}/snapshots）
cmd_snapshot_create() {
    local id="" name=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --name) [ $# -ge 2 ] || die "--name 需要一个值"; name="$2"; shift 2 ;;
            -*) die "snapshot-create：未知参数 '$1'" ;;
            *) [ -z "$id" ] || die "snapshot-create：只能指定一个沙箱 ID"; id="$1"; shift ;;
        esac
    done
    [ -n "$id" ] || die "用法：bash $0 snapshot-create <sandbox-id> [--name <显示名>]（沙箱须为 running）"
    local body="{}"
    if [ -n "$name" ]; then
        # 显示名做最小转义：去掉引号与反斜杠，避免破坏 JSON
        name="$(printf '%s' "$name" | tr -d '"\\')"
        body="{\"name\": \"$name\"}"
    fi
    local resp snap
    resp="$(api POST "/sandboxes/$id/snapshots" "$body")"
    printf '%s\n' "$resp" | pretty
    snap="$(first_match "$resp" 'snap-[0-9a-fA-F]+')"
    echo
    if [ -n "$snap" ]; then
        echo "SNAPSHOT_ID=$snap"
        echo "从快照派生新沙箱：bash $0 sandbox-create --snapshot $snap"
        echo "原地回滚：        bash $0 sandbox-rollback $id $snap"
        echo "删除快照：        bash $0 snapshot-delete $snap"
    fi
}

# ：沙箱状态管理-列举快照（CubeAPI：GET /snapshots）
cmd_snapshot_list() {
    local sbx="" limit="" query=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --sandbox) [ $# -ge 2 ] || die "--sandbox 需要一个值"; sbx="$2";   shift 2 ;;
            --limit)   [ $# -ge 2 ] || die "--limit 需要一个值";   limit="$2"; shift 2 ;;
            *) die "snapshot-list：未知参数 '$1'" ;;
        esac
    done
    if [ -n "$limit" ]; then
        [[ "$limit" =~ ^[0-9]+$ ]] || die "--limit 须为正整数"
    fi
    if [ -n "$sbx" ]; then
        query="?sandboxID=$sbx"
    fi
    if [ -n "$limit" ]; then
        if [ -n "$query" ]; then query="${query}&limit=$limit"; else query="?limit=$limit"; fi
    fi
    api GET "/snapshots${query}" | pretty
}

# ：沙箱状态管理-删除快照（CubeAPI：DELETE /templates/{snap-id}，
# 快照在存储层即模板，CubeAPI 按 snap-/tpl- 前缀区分）
cmd_snapshot_delete() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 1 ] || die "用法：bash $0 snapshot-delete <snap-xxxxxxxxxxxxxxxxxxxxxxxx>"
    api DELETE "/templates/$1"
    echo "已删除快照：$1"
    echo "提示：请先确认没有沙箱仍基于该快照运行（克隆出的沙箱销毁前不要删底座快照）。"
}

# ：沙箱状态管理-克隆
# CubeAPI 无独立 clone 端点，按官方 SDK 语义组合实现：
#   打快照（CubeAPI）→ multirun 从快照派生 N 个新沙箱；源沙箱不受影响。
cmd_sandbox_clone() {
    local id="" count=1
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage ;;
            --count|-n) [ $# -ge 2 ] || die "--count 需要一个值"; count="$2"; shift 2 ;;
            --config)   [ $# -ge 2 ] || die "--config 需要一个值"; OPT_CONFIG="$2"; shift 2 ;;
            -*) die "sandbox-clone：未知参数 '$1'" ;;
            *) [ -z "$id" ] || die "sandbox-clone：只能指定一个沙箱 ID"; id="$1"; shift ;;
        esac
    done
    [ -n "$id" ] || die "用法：bash $0 sandbox-clone <sandbox-id> [--count <N>]"
    [[ "$count" =~ ^[1-9][0-9]*$ ]] || die "--count 须为正整数"

    echo "==> [1/2] 为源沙箱打快照：$id"
    local resp snap
    resp="$(api POST "/sandboxes/$id/snapshots" '{}')"
    printf '%s\n' "$resp" | pretty
    snap="$(first_match "$resp" 'snap-[0-9a-fA-F]+')"
    [ -n "$snap" ] || die "未能从响应中解析出快照 ID，请检查上方输出"
    echo
    echo "SNAPSHOT_ID=$snap"

    echo
    echo "==> [2/2] 从快照派生 $count 个新沙箱（源沙箱 $id 保持运行不受影响）"
    sandbox_run "$snap" "$count"

    echo
    echo "克隆完成。注意："
    echo "  1. 克隆沙箱以快照 $snap 为底（CoW）。请在所有克隆沙箱销毁之后再删除该快照："
    echo "     bash $0 snapshot-delete $snap"
    echo "  2. 快照不免费：每个快照对应存储中的一份完整镜像，不再需要时应及时删除。"
}

# ：沙箱状态管理-回滚（CubeAPI：POST /sandboxes/{id}/rollback）
cmd_sandbox_rollback() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    [ $# -eq 2 ] || die "用法：bash $0 sandbox-rollback <sandbox-id> <snapshot-id>"
    local resp op
    resp="$(api POST "/sandboxes/$1/rollback" "{\"snapshotID\": \"$2\"}")"
    printf '%s\n' "$resp" | pretty
    op="$(printf '%s\n' "$resp" | grep -oE '"operationID"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 || true)"
    echo
    echo "回滚已受理：沙箱 $1 将原地恢复到快照 $2（沙箱 ID 不变，文件系统与内存一并恢复）。"
    if [ -n "$op" ]; then
        echo "长耗时操作，可查询进度：$CUBEMASTERCLI operation status --operation-id $op"
    fi
    echo "提示：回滚会重启沙箱内的进程，此前建立的 TCP 连接会失效，属正常现象。"
}

# ---------------------------------------------------------------- 其他

cmd_health() {
    if [ "${1-}" = "-h" ] || [ "${1-}" = "--help" ]; then usage; fi
    api GET /health | pretty
}

# ---------------------------------------------------------------- 入口

main() {
    if [ $# -eq 0 ]; then
        usage
    fi
    local cmd="$1"
    shift
    case "$cmd" in
        health)            cmd_health "$@" ;;
        template-create)   cmd_template_create "$@" ;;
        template-list)     cmd_template_list "$@" ;;
        template-info)     cmd_template_info "$@" ;;
        template-delete)   cmd_template_delete "$@" ;;
        template-commit)   cmd_template_commit "$@" ;;
        sandbox-create)    cmd_sandbox_create "$@" ;;
        sandbox-list)      cmd_sandbox_list "$@" ;;
        sandbox-info)      cmd_sandbox_info "$@" ;;
        sandbox-pause)     cmd_sandbox_pause "$@" ;;
        sandbox-connect)   cmd_sandbox_connect "$@" ;;
        sandbox-destroy)   cmd_sandbox_destroy "$@" ;;
        snapshot-create)   cmd_snapshot_create "$@" ;;
        snapshot-list)     cmd_snapshot_list "$@" ;;
        snapshot-delete)   cmd_snapshot_delete "$@" ;;
        sandbox-clone)     cmd_sandbox_clone "$@" ;;
        sandbox-rollback)  cmd_sandbox_rollback "$@" ;;
        -h|--help|help)    usage ;;
        *) die "未知命令 '$cmd'（完整用法：bash $0 --help）" ;;
    esac
}

main "$@"
