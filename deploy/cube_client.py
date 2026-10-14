#!/usr/bin/env python3
"""Cube Sandbox 最简客户端（Cube + Redroid）。

覆盖 7 类常用操作：
  模板  : template-create / template-commit / template-list / template-info / template-delete
  沙箱  : sandbox-create  / sandbox-list  / sandbox-info  / sandbox-delete
  快照  : snapshot-create / snapshot-list / snapshot-delete
  恢复  : sandbox-rollback

实现方式（优先使用 Cube 自身提供的命令 / API，不依赖 E2B SDK）：
  1) 模板创建、沙箱创建 —— 调 cubemastercli。这两步必须携带注解
     cube.vm.cgroup.unified_hierarchy=false（否则 Android 沙箱会因 guest 侧 cgroup v2
     预挂载冲突而重启循环），而 CubeAPI 的 CreateTemplateRequest / NewSandbox 请求模型
     不暴露 annotations 字段，HTTP 侧无法表达。
  2) 其余操作（模板查询/删除、沙箱查询/删除、快照制作/查询/删除、回滚）——
     走 CubeAPI 的 E2B 兼容 HTTP 接口（Cube 官方 API）。

  上述操作在 Cube 侧均有对应命令，等价用法见 ../guide/user_guide.md 第 5 章。

环境变量：
  CUBE_API_URL    CubeAPI 地址，默认 http://127.0.0.1:3000
  CUBE_API_KEY    启用鉴权时填写（作为 X-API-Key 与 Bearer 发送）
  CUBEMASTERCLI   cubemastercli 路径，默认取 PATH 中的 cubemastercli

用法示例：
  python3 cube_client.py template-create --image 127.0.0.1:5000/redroid:14 --alias android14
  python3 cube_client.py template-list
  python3 cube_client.py sandbox-create --template tpl-xxxxxxxxxxxxxxxxxxxxxxxx
  python3 cube_client.py snapshot-create <sandbox-id>
  python3 cube_client.py sandbox-rollback <sandbox-id> <snap-id>
  python3 cube_client.py sandbox-delete <sandbox-id>
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request

API = os.environ.get("CUBE_API_URL", "http://127.0.0.1:3000").rstrip("/")
KEY = os.environ.get("CUBE_API_KEY", "")
CLI = os.environ.get("CUBEMASTERCLI", "cubemastercli")

ANNO_CGROUP = "cube.vm.cgroup.unified_hierarchy=false"
RE_TEMPLATE_ID = re.compile(r"tpl-[0-9a-f]{24}")


def http(method, path, body=None, timeout=300):
    """调用 CubeAPI；模板/快照删除与快照制作最长可能等待 240s，故默认超时取 300s。"""
    req = urllib.request.Request(
        API + path,
        data=json.dumps(body).encode() if body is not None else None,
        method=method,
    )
    req.add_header("Content-Type", "application/json")
    if KEY:
        req.add_header("X-API-Key", KEY)
        req.add_header("Authorization", "Bearer " + KEY)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {"status": resp.status}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "replace")
        sys.exit("HTTP %s %s -> %s\n%s" % (method, path, exc.code, detail))
    except urllib.error.URLError as exc:
        sys.exit("无法连接 CubeAPI (%s): %s\n请确认 CUBE_API_URL，以及服务状态: "
                 "systemctl is-active cube-sandbox-cube-api" % (API, exc.reason))


def run_cli(args, capture=False):
    print("+ %s %s" % (CLI, " ".join(args)))
    if capture:
        proc = subprocess.run([CLI] + args, text=True, capture_output=True)
        sys.stdout.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        if proc.returncode != 0:
            sys.exit("cubemastercli 执行失败（exit %d）" % proc.returncode)
        return proc.stdout
    if subprocess.run([CLI] + args).returncode != 0:
        sys.exit("cubemastercli 执行失败")
    return ""


def show(obj):
    print(json.dumps(obj, ensure_ascii=False, indent=2))


# ---------------------------------------------------------------- 模板


def template_create(a):
    args = [
        "template", "create-from-image",
        "--image", a.image,
        "--writable-layer-size", a.writable_layer_size,
        "--probe", str(a.probe),
        "--probe-timeout-ms", str(a.probe_timeout_ms),
        "--annotation", ANNO_CGROUP,
        "--cpu", str(a.cpu),
        "--memory", str(a.memory),
        "--instance-type", "cubebox",
        "--network-type", "tap",
        "--with-cube-ca=false",
    ]
    if a.alias:
        args += ["--alias", a.alias]
    for key, value in (
        ("androidboot.redroid_width", a.width),
        ("androidboot.redroid_height", a.height),
        ("androidboot.redroid_dpi", a.dpi),
        ("androidboot.redroid_fps", a.fps),
    ):
        args += ["--arg", "%s=%s" % (key, value)]

    out = run_cli(args, capture=True)
    match = RE_TEMPLATE_ID.search(out or "")
    if match:
        print("\nTEMPLATE_ID=%s" % match.group(0))


def template_commit(a):
    out = run_cli(["template", "commit", "--sandbox-id", a.sandbox_id], capture=True)
    template = RE_TEMPLATE_ID.search(out or "")
    build = re.search(r"build-[0-9a-zA-Z]+", out or "")
    if template:
        print("\nTEMPLATE_ID=%s" % template.group(0))
    if build:
        print("BUILD_ID=%s（跟踪进度: cubemastercli template build-watch --build-id %s）"
              % (build.group(0), build.group(0)))


def template_list(_a):
    show(http("GET", "/templates"))


def template_info(a):
    show(http("GET", "/templates/%s" % a.template_id))


def template_delete(a):
    show(http("DELETE", "/templates/%s" % a.template_id))


# ---------------------------------------------------------------- 沙箱


def sandbox_create(a):
    request = {
        "instance_type": "cubebox",
        "network_type": "tap",
        "namespace": "default",
        "annotations": {
            "cube.master.appsnapshot.template.id": a.template,
            "cube.master.appsnapshot.template.version": "v2",
            "cube.master.appsnapshot.version": "v2",
            "cube.vm.cgroup.unified_hierarchy": "false",
        },
        "labels": {
            "X-Caller": "mastercli",
            "cube.master.appsnapshot.template.id": a.template,
            "cube.master.instance.type": "cubebox",
        },
    }
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as fh:
        json.dump(request, fh)
        path = fh.name
    try:
        run_cli(["multirun", "--norm", "--runcnt", "1", "--runcc", "1", path])
    finally:
        os.unlink(path)


def sandbox_list(_a):
    show(http("GET", "/sandboxes"))


def sandbox_info(a):
    show(http("GET", "/sandboxes/%s" % a.sandbox_id))


def sandbox_delete(a):
    for sandbox_id in a.sandbox_id:
        show(http("DELETE", "/sandboxes/%s" % sandbox_id))
        print("deleted: %s" % sandbox_id)


def sandbox_rollback(a):
    show(http("POST", "/sandboxes/%s/rollback" % a.sandbox_id,
              {"snapshotID": a.snapshot_id}))


# ---------------------------------------------------------------- 快照


def snapshot_create(a):
    body = {"name": a.name} if a.name else {}
    show(http("POST", "/sandboxes/%s/snapshots" % a.sandbox_id, body))


def snapshot_list(_a):
    show(http("GET", "/snapshots"))


def snapshot_delete(a):
    # 快照与模板共用 DELETE /templates/{id}：CubeAPI 按 id 前缀（snap-/tpl-）区分。
    show(http("DELETE", "/templates/%s" % a.snapshot_id))


def health(_a):
    show(http("GET", "/health", timeout=10))


# ---------------------------------------------------------------- 入口


def main():
    parser = argparse.ArgumentParser(
        description="Cube Sandbox 最简客户端（Cube + Redroid）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("health", help="检查 CubeAPI 健康状态")
    p.set_defaults(func=health)

    p = sub.add_parser("template-create", help="从 OCI 镜像制作模板（调 cubemastercli）")
    p.add_argument("--image", required=True, help="镜像全名，须带 registry 前缀")
    p.add_argument("--alias", help="模板别名")
    p.add_argument("--writable-layer-size", default="10Gi")
    p.add_argument("--probe", type=int, default=49983, help="envd 探活端口")
    p.add_argument("--probe-timeout-ms", type=int, default=180000)
    p.add_argument("--cpu", type=int, default=4000, help="millicores")
    p.add_argument("--memory", type=int, default=8192, help="MB")
    p.add_argument("--width", default="720")
    p.add_argument("--height", default="1280")
    p.add_argument("--dpi", default="240")
    p.add_argument("--fps", default="60")
    p.set_defaults(func=template_create)

    p = sub.add_parser("template-list", help="列出模板")
    p.set_defaults(func=template_list)

    p = sub.add_parser("template-commit", help="把运行中的沙箱提交成模板（调 cubemastercli）")
    p.add_argument("sandbox_id")
    p.set_defaults(func=template_commit)

    p = sub.add_parser("template-info", help="查看模板详情")
    p.add_argument("template_id")
    p.set_defaults(func=template_info)

    p = sub.add_parser("template-delete", help="删除模板")
    p.add_argument("template_id")
    p.set_defaults(func=template_delete)

    p = sub.add_parser("sandbox-create", help="基于模板/快照启动沙箱（调 cubemastercli）")
    p.add_argument("--template", required=True, help="模板或快照 ID（tpl-… / snap-…）")
    p.set_defaults(func=sandbox_create)

    p = sub.add_parser("sandbox-list", help="列出沙箱")
    p.set_defaults(func=sandbox_list)

    p = sub.add_parser("sandbox-info", help="查看沙箱详情")
    p.add_argument("sandbox_id")
    p.set_defaults(func=sandbox_info)

    p = sub.add_parser("sandbox-delete", help="删除沙箱（可多个）")
    p.add_argument("sandbox_id", nargs="+")
    p.set_defaults(func=sandbox_delete)

    p = sub.add_parser("sandbox-rollback", help="把沙箱回滚到指定快照")
    p.add_argument("sandbox_id")
    p.add_argument("snapshot_id")
    p.set_defaults(func=sandbox_rollback)

    p = sub.add_parser("snapshot-create", help="为运行中的沙箱制作快照")
    p.add_argument("sandbox_id")
    p.add_argument("--name", help="快照显示名")
    p.set_defaults(func=snapshot_create)

    p = sub.add_parser("snapshot-list", help="列出快照")
    p.set_defaults(func=snapshot_list)

    p = sub.add_parser("snapshot-delete", help="删除快照")
    p.add_argument("snapshot_id")
    p.set_defaults(func=snapshot_delete)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
