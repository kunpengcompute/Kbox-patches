# 用户指南（CubeSandbox + Redroid 部署与模板/沙箱管理）

本文档覆盖流程：**部署CubeSandbox → 加载redroid镜像 → 用 `redroid_operation.sh` 制作模板、启动沙箱**。

> **配套编译文档**（仅用于获取构建产物）：
>
> - [cube_compile_guide.md](cube_compile_guide.md)：CubeSandbox + guest 内核编译，产出发布包
> - [redroid_compile_guide.md](redroid_compile_guide.md)：Redroid 14 镜像构建，产出镜像 tar

## 1. 前置编译产物

### 1.1 CubeSandbox 发布包

| 产物 | 路径 |
| ---- | ---- |
| guest 内核 | `CubeSandbox/_output/kernel/aarch64/vmlinux` |
| 发布包 | `CubeSandbox/deploy/one-click/dist/cube-sandbox-one-click-<version>.tar.gz` |

> 注意：aarch64 下 `vmlinux` 实际是内核 `Image` 的副本（非 ELF），属部署脚本约定。编译细节、patch 清单、版本基线见 cube_compile_guide.md 附录。

### 1.2 redroid 镜像

最终产物：`aosp-14/redroid-14.0.0_r75_arm64_only-docker.tar`（约 1.6GB）。


## 2. 部署 CubeSandbox

> 本节是完整部署流程，请从 2.1 开始依次执行，不要在跳过任何一节的情况下直接运行安装脚本。核心要求：`/data` 为 XFS、Docker ≥ 20.10 且配置好数据目录与 Compose v2、日志轮转就绪。

### 2.1 把 `/data` 挂载到 `/home` 下的 loop 镜像

先确认 `/home` 与 `/` 不在同一分区，且 `/home` 容量充足；若两者同分区，本节无法达到目的，需先为 `/home` 准备独立存储。

```bash
df -h /home /
mkdir -p /home/cube-sandbox
truncate -s 400G /home/cube-sandbox/data-xfs.img   # 稀疏文件，按实际使用占用空间
mkfs.xfs -f /home/cube-sandbox/data-xfs.img
mkdir -p /data
mount -o loop /home/cube-sandbox/data-xfs.img /data
```

持久化挂载写入 `/etc/fstab`：

```
/home/cube-sandbox/data-xfs.img /data  xfs  loop,defaults,noatime  0 0
```

校验：

```bash
findmnt -no SOURCE,FSTYPE,TARGET /data
# 期望: <设备或镜像> xfs /data
df -h /data
```

**（可选）：`/home` 与 `/` 在同一分区时可采用`/data` 挂载独立数据盘，校验方式相同**

```bash
umount /dev/nvme0n1 2>/dev/null || true
mkfs.xfs -f /dev/nvme0n1
mkdir -p /data
mount /dev/nvme0n1 /data
```

持久化挂载写入 `/etc/fstab`：

```
/dev/nvme0n1                    /data  xfs  defaults,noatime       0 0
```

> **说明：** 直接挂载 `/data` 而非只挂 `/data/cubelet`——`install.sh` 的校验会从 `/data/cubelet` 向上找到最近的存在祖先，挂载 `/data` 即可满足 XFS 要求，同时把 `/data/log`、`/data/snapshot_pack`、`/data/CubeMaster/storage` 等全部纳入该挂载，一步到位。若另行挂载 `/data/cubelet`，该挂载点自身也必须是 XFS。

### 2.2 安装并配置 Docker（版本 / 数据目录 / 镜像加速 / Compose v2）

本节把 Docker 相关的**安装与全部配置一次性做完**，之后直到部署完成都**不需要再重启 Docker**。

```bash
# 1) 安装 Docker：openEuler 24.03 仓库中的包名是 moby（提供 25.0.3）；
#    若此前用 `dnf install docker` 装到了 18.09 之类的旧版本，先卸掉再装 moby。
sudo dnf list installed 'docker*' 'moby*'
sudo dnf remove -y docker docker-client docker-common 2>/dev/null || true
sudo dnf install -y moby moby-engine moby-client containerd
sudo systemctl enable --now docker

docker version
# 期望：Client / Server 均 ≥ 20.10（aarch64）

# 2) 数据目录 + 镜像加速一次写入 daemon.json（严格 JSON：不能有注释、不能有尾随逗号）
sudo mkdir -p /home/cube-sandbox/docker /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "data-root": "/home/cube-sandbox/docker",
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
EOF

# 3) 唯一一次重启 Docker（daemon.json 变更必须重启才生效）
sudo systemctl restart docker

# 校验
docker info | grep 'Docker Root Dir'
# 期望: Docker Root Dir: /home/cube-sandbox/docker
docker info | grep -A1 'Registry Mirrors'

# 4) 安装 Compose v2
#    Cube 的 MySQL / Redis / MinIO / CoreDNS / WebUI / cube-proxy / cube-lifecycle-manager 等
#    支撑组件全部以 compose 方式启动，必须是 v2；系统自带的 python 版 docker-compose 1.x
#    与新版 python docker SDK 不兼容（报 kwargs_from_env() got an unexpected keyword argument 'ssl_version'）。
curl -fL --retry 3 -o /usr/local/bin/docker-compose \
  https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-aarch64
chmod +x /usr/local/bin/docker-compose
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo install -m 0755 /usr/local/bin/docker-compose /usr/libexec/docker/cli-plugins/docker-compose

# 校验（两种调用方式都必须落到 v2）
docker compose version       # 期望: Docker Compose version v2.x
docker-compose version       # 期望: v2.x（/usr/local/bin 优先于 /usr/bin 下的 1.x）
```

> **说明：** 必须在执行 `install.sh` **之前**完成。Cube 的支撑组件以容器运行，数据存于 Docker 命名卷（`cube-sandbox-mysql-data` 等），随模板与沙箱规模持续增长；同时 redroid 镜像（约 1.6GB）也存放在这里。
>
> **说明：** `registry-mirrors` 仅在从 Docker Hub 拉镜像时生效。本方案只有 §3.2 的 `registry:2` 来自 Docker Hub，Cube 自身组件镜像来自 `*.tencentcloudcr.com`；目标机若可直连 Docker Hub 可省略该项。
>
> **说明：** 目标机需要经 HTTP 代理出网时，**在本节一并配好**，与上面的 `daemon.json` 共用同一次重启：在 `/etc/systemd/system/docker.service.d/http-proxy.conf` 中写入 `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY`（用 `systemctl edit docker` 亦可），随后 `systemctl daemon-reload && systemctl restart docker`。部署开始后不要再重启 Docker。
>
> **说明：** Compose v2 的二进制需按目标架构下载（aarch64 用 `docker-compose-linux-aarch64`）。目标机不能访问 GitHub 时，从任意可联网机器下载同名二进制后拷入同两个路径即可。
>
> **说明：** 该机若已存在 `/var/lib/docker` 且其中有镜像，先 `sudo systemctl stop docker`，用 `cp -a` 迁移到新目录（文件数校验一致）后再删除源目录，然后回到上面第 2 步。

### 2.3 配置日志轮转

Cube 不自带日志轮转配置，需手工添加：

```bash
dnf install -y logrotate

cat > /etc/logrotate.d/cube-sandbox <<'EOF'
/data/log/Cubelet/*.log
/data/log/CubeShim/*.log
/data/log/CubeVmm/*.log
/data/log/CubeMaster/*.log
/data/log/CubeAPI/*.log
/data/log/CubeOps/*.log
/data/log/cube-proxy/*.log
/data/log/rcow/*.log
/data/log/cubecow/*.log
{
    size 500M
    maxsize 2G
    rotate 3
    missingok
    notifempty
    copytruncate
    compress
}
EOF
```

校验：

```bash
logrotate -d /etc/logrotate.d/cube-sandbox   # 干跑，应无 error
systemctl is-active crond                    # 或 systemctl is-active logrotate.timer
```

> **说明：** 用 `copytruncate` 是因为 Cube 组件不会因收到信号而重开日志文件句柄；`maxsize 2G` 是硬上限，即使轮转条件未满足，单文件也不会超过该值。

### 2.4 安装系统依赖与部署前自检

Docker 及其全部配置已在 §2.2 完成，这里只装其余依赖：

```bash
sudo dnf install -y e2fsprogs util-linux iproute procps-ng curl tar gzip logrotate android-tools
```

校验：

```bash
ls /dev/kvm
# 必须存在，否则无法创建沙箱
docker version && docker compose version   # 复核 §2.2 的成果
adb version                                # 验证沙箱内 Android 时用；
```

> **说明：** 后续所有步骤需在**不受路径白名单限制的 root shell** 中执行——部分 IDE / 沙箱环境会拦截 `/home`、`/data`、`/usr/local` 等路径的 `cp` / `rm`，导致 §2.8 的目录迁移失败。
>
> **说明：** 如需 S3 卷能力，额外安装 `s3fs-fuse`：`sudo dnf install -y epel-release && sudo dnf install -y s3fs-fuse`；缺失仅影响 S3 卷挂载，不影响模板与沙箱。

部署前自检（全部通过后再进入 §2.5）：

```bash
df -h /data /home /
findmnt -no FSTYPE /data || findmnt -no FSTYPE /data/cubelet   # 期望: xfs（/data 或 /data/cubelet 其一为 XFS）
docker info | grep 'Docker Root Dir'          # 期望: /home/cube-sandbox/docker
docker compose version                        # 期望: Docker Compose version v2.x
logrotate -d /etc/logrotate.d/cube-sandbox    # 期望无 error
```

> **说明：** 若两处 `findmnt` 返回的都不是 xfs，`install.sh` 会直接终止并给出 `Cube Sandbox requires the /data/cubelet directory to reside on an XFS filesystem`。

### 2.5 解压发布包

```bash
mkdir -p /home/cube-sandbox/bundle && cd /home/cube-sandbox/bundle
tar -xzf /path/to/cube-sandbox-one-click-<version>.tar.gz
cd cube-sandbox-one-click-<version>
```

### 2.6 配置 .env

```bash
cp env.example .env
```

编辑 `.env`，至少确认以下项：

```bash
# 单机 all-in-one（控制面 + 计算面同机）
ONE_CLICK_DEPLOY_ROLE=control

# 本机内网 IP；不设置时自动探测 eth0
CUBE_SANDBOX_NODE_IP=<本机IP>

# 沙箱网段：必须避开物理网段（物理网段为 192.168.x.x 时改用 10.100.0.0/16）
CUBE_SANDBOX_NETWORK_CIDR=10.100.0.0/16

# 裸金属部署，不使用 PVM guest 内核
CUBE_PVM_ENABLE=0
```

> **说明：** `CUBE_SANDBOX_NETWORK_CIDR` 掩码范围 /16–/24，默认 `192.168.0.0/18`；与宿主网卡、路由或 DNS nameserver 冲突时安装预检会终止。
>
> **说明：** 目标机若已存在 Cube 网络（历史安装残留的 `cube-dev` 与 `z10.*` TAP 设备），改用不同网段前需先重置，否则安装预检会以 `overlaps an existing cube-dev network` 终止：

```bash
sudo systemctl stop 'cube-sandbox-*.target'
sudo ip link delete cube-dev 2>/dev/null || true
sudo ip link delete cube-router 2>/dev/null || true
ip tuntap show | awk -F: '/^z[0-9]+\./{print $1}' \
  | xargs -r -n1 -I{} sudo ip tuntap del dev {} mode tap
```

### 2.7 执行安装

```bash
sudo ./install.sh --mode=install
```

> **说明：** 目标机已存在 CubeSandbox 时，不带 `--mode` 的 `./install.sh` 默认走「保留配置的升级」。**从零部署必须显式指定 `--mode=install`。**
>
> **说明：** 安装固定落在 `/usr/local/services/cubetoolbox`，由 systemd 统一托管（控制节点 target 为 `cube-sandbox-control.target`）。
>
> **说明：** 目标机若已部署过 Cube，安装会**保留既有的版本化组件目录**（`/data/cubelet/root/component_versions/`）。请先完成 §2.9 的校验，再进入后续章节。

### 2.8 把两个大目录迁到 `/home`

`cubebox_os_image` 与 `cube-snapshot` 默认落在 Cubelet 插件配置的 `BasePath` 下（默认 `/usr/local/services/cubetoolbox`）。本方案不改插件配置，直接用软链迁移：

```bash
TC=/usr/local/services/cubetoolbox

# 迁移前先停控制面，避免运行中读写
sudo systemctl stop cube-sandbox-control.target

for d in cubebox_os_image cube-snapshot; do
  src="$TC/$d"; dst="/home/cube-sandbox/$d"
  [ -L "$src" ] && continue
  sudo mkdir -p "$dst"
  [ -d "$src" ] && sudo cp -a "$src/." "$dst/" && sudo rm -rf "$src"
  sudo ln -s "$dst" "$src"
done

ls -ld "$TC"/cubebox_os_image "$TC"/cube-snapshot
# 期望: 两个均为指向 /home/cube-sandbox/... 的符号链接

sudo systemctl start cube-sandbox-control.target
```

> **说明：** `cp -a` 之后建议用 `find | wc -l` 对比源与目标的文件数再删除源目录。若 `cubebox_os_image` 尚不存在（首次模板构建时才生成），脚本会自动创建目标目录并建链，无数据损失。

### 2.9 验证安装

```bash
sudo ./smoke.sh

# 核心服务必须全部 active
systemctl is-active cube-sandbox-cubelet
systemctl is-active cube-sandbox-cubemaster
systemctl is-active cube-sandbox-cube-api
systemctl is-active cube-sandbox-cubeops

# CLI 可用
cubemastercli --help 2>&1 | head -3
# 若 command not found：
# ln -sf /usr/local/services/cubetoolbox/CubeMaster/bin/cubemastercli /usr/local/bin/cubemastercli

# 组件一致性：模板构建读 /usr/local 下的组件，沙箱恢复读 component_versions/<版本>/ 下的副本，
# 两者必须同源，否则模板能建、沙箱起不来。
TC=/usr/local/services/cubetoolbox
CV=/data/cubelet/root/component_versions

# cube-shim（版本目录名取自 release-manifest.json 中记录的版本）
SHIM_VER=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["components"]["containerd-shim-cube-rs"]["version"])' \
  "$TC/release-manifest.json")
sha256sum "$TC/cube-shim/bin/containerd-shim-cube-rs" "$CV/cube-shim/$SHIM_VER/bin/containerd-shim-cube-rs"
sha256sum "$TC/cube-shim/bin/cube-runtime"            "$CV/cube-shim/$SHIM_VER/bin/cube-runtime"

# cube-agent / cube-image（版本目录名即 /usr/local 下 version 文件的内容）
sha256sum "$TC/cube-agent/cube-agent.ext4" \
  "$CV/cube-agent/$(cat "$TC/cube-agent/version")/cube-agent.ext4"
sha256sum "$TC/cube-image/cube-guest-image-cpu.img" \
  "$CV/cube-image/$(cat "$TC/cube-image/version")/cube-guest-image-cpu.img"
# 期望：每组两行哈希一致

# 若不一致：以 /usr/local 副本为准覆盖版本化目录
# （先停控制面；用「临时文件 + 原子 rename」避免 Text file busy）
sudo systemctl stop cube-sandbox-control.target

for f in containerd-shim-cube-rs cube-runtime; do
  sudo install -m 0755 "$TC/cube-shim/bin/$f" "$CV/cube-shim/$SHIM_VER/bin/$f.new" \
    && sudo mv -f "$CV/cube-shim/$SHIM_VER/bin/$f.new" "$CV/cube-shim/$SHIM_VER/bin/$f"
done
for c in cube-agent cube-image; do
  case "$c" in
    cube-agent) f=cube-agent.ext4 ;;
    cube-image) f=cube-guest-image-cpu.img ;;
  esac
  v=$(cat "$TC/$c/version")
  sudo install -m 0644 "$TC/$c/$f" "$CV/$c/$v/$f.new" \
    && sudo mv -f "$CV/$c/$v/$f.new" "$CV/$c/$v/$f"
done

sudo systemctl start cube-sandbox-control.target
```

> **说明：** `webui`、`cube-sandbox-dns` 等非关键单元失败不影响沙箱创建；判断部署成功的核心标准是上述 4 个服务均为 `active`。
>
> **说明：** `cube-sandbox-cube-egress` 在首次启动瞬间可能报失败——它依赖 `cube-dev` 设备，而该设备由 cubelet 在创建第一个沙箱时建立，随后自行 `active`，属固有行为。

### 2.10 等待 Cubelet 就绪

Cubelet 启动后还需初始化 network plugin，期间发起模板创建会报 `template creation failed on all nodes`：

```bash
grep -a "starting cri plugin" /data/log/Cubelet/Cubelet-req.log | tail -1
cubemastercli listinventory        # 期望返回数值（节点已注册）
```

上述时间戳之后（约 120s）再执行脚本操作；节点未注册时模板创建会报 `template has no ready replica`。

### 2.11 一键健康校验

把 §2.9、§2.10 的检查合并为一条命令。脚本：`<工作区>/Kbox-patches/deploy/cube_healthcheck.sh`。

```bash
cd <工作区>/Kbox-patches/deploy

sudo bash cube_healthcheck.sh                        # 部署后自检 / 日常巡检
sudo bash cube_healthcheck.sh --sandbox 10.100.1.40  # 顺带校验某个沙箱
```

## 3. 加载 redroid 镜像

### 3.1 加载镜像

```bash
docker load -i /path/to/redroid-14.0.0_r75_arm64_only-docker.tar

# 校验并记录镜像名（供后续步骤使用）
docker images | grep redroid
```

取「仓库名:标签」两部分（不要只写标签），下面为示例，请以实际输出为准：

```bash
REDROID_IMAGE=redroid:14.0.0_r75_arm64_only
```

### 3.2 启动本地 Registry 并推送

创建模板时按 `--image` 全名拉取镜像，裸镜像名会解析到 docker.io 导致超时，因此需要本地 registry：

> **说明：** `registry:2` 是 Docker Hub 上的镜像。若本机无法直连 Docker Hub，需先配置镜像加速（在 `/etc/docker/daemon.json` 中追加 `"registry-mirrors": ["https://<mirror>"]` 后重启 Docker；`daemon.json` 须为严格 JSON，不能带注释与尾随逗号），或在其它机器上 `docker save registry:2` 后拷贝到本机 `docker load`。校验连通性：`curl -sI https://<mirror>/v2/ | head -1`。

```bash
# 已存在同名容器时直接复用（幂等）
docker start cube-registry 2>/dev/null || docker run -d --name cube-registry --restart=always \
  -p 127.0.0.1:5000:5000 registry:2

REGISTRY_IMAGE=127.0.0.1:5000/${REDROID_IMAGE}
docker tag "${REDROID_IMAGE}" "${REGISTRY_IMAGE}"
docker push "${REGISTRY_IMAGE}"

# 校验
curl -s "http://127.0.0.1:5000/v2/$(echo "${REDROID_IMAGE}" | cut -d: -f1)/tags/list"
```

推送完成后，把镜像全名（`127.0.0.1:5000/redroid:14.0.0_r75_arm64_only`）填进 `redroid_config.conf` 的 `TPL_IMAGE`。

## 4. 安卓沙箱基本操作

`redroid_operation.sh` 把模板、沙箱、快照的日常管理封装成一条命令，无需手工拼 JSON 请求文件或记忆 `cubemastercli` 的长参数：

```bash
bash redroid_operation.sh <命令> [参数]
```

依赖（部署机默认均满足）：

| 依赖 | 用途 | 缺失时的处理 |
| ---- | ---- | ---- |
| bash | 脚本运行环境 | 系统自带 |
| curl | 调用 CubeAPI | `dnf install -y curl` |
| cubemastercli | 模板/沙箱的 CLI 操作 | 见 §2.9 |
| python3 | 生成 multirun 请求 JSON（sandbox-create / sandbox-clone）与 JSON 输出格式化 | `dnf install -y python3` |

模板与沙箱的创建参数**不在命令行传入**，统一放在配置文件 `redroid_config.conf`（随脚本同目录）中，见第 4.2 节。

### 4.1 操作总览（速查表）

统一前缀：`bash redroid_operation.sh <命令> [参数]`。方括号 `[ ]` 内为可选项；`…` 表示可重复。各命令的详细说明见 4.3–4.5。

**模板操作**

| 脚本命令 | 用途 | 完整用法 | 实际调用路径 |
| ---- | ---- | -------- | ------------ |
| `template-create` | 从镜像创建模板（`--alias` 必填，`--image` 缺省用配置） | `template-create --alias <别名> [--image <镜像名>] [--config <文件>]` | `cubemastercli template create-from-image` |
| `template-list` | 列举模板 | `template-list [--wide]` | `cubemastercli template list` |
| `template-info` | 查询模板详情 | `template-info <tpl-id>` | `cubemastercli template info` |
| `template-delete` | 删除模板 | `template-delete <tpl-id>` | `cubemastercli template delete` |
| `template-commit` | 把运行中沙箱提交为新模板 | `template-commit <sandbox-id>` | `cubemastercli template commit` |

**沙箱操作**

| 脚本命令 | 用途 | 完整用法 | 实际调用路径 |
| ---- | ---- | -------- | ------------ |
| `sandbox-create` | 按模板别名创建沙箱（`--alias` 与 `--snapshot` 二选一、必填） | `sandbox-create --alias <模板别名> [--config <文件>]` | `cubemastercli multirun` |
| `sandbox-create` | 从快照派生新沙箱 | `sandbox-create --snapshot <snap-id> [--config <文件>]` | `cubemastercli multirun`（同创建） |
| `sandbox-list` | 列举沙箱 | `sandbox-list [--all] [--wide]` | `cubemastercli ls` |
| `sandbox-info` | 查询沙箱详情 | `sandbox-info <sandbox-id>` | `cubemastercli info -s` |
| `sandbox-pause` | 暂停沙箱（内存快照落盘，零占用） | `sandbox-pause <sandbox-id>` | `POST /sandboxes/{id}/pause` |
| `sandbox-connect` | 连接 / 唤醒已暂停沙箱，可设空闲超时 | `sandbox-connect <sandbox-id> [--timeout <秒>\|-1]` | `POST /sandboxes/{id}/connect` |
| `sandbox-destroy` | 销毁沙箱（可一次多个） | `sandbox-destroy <sandbox-id> [sandbox-id …]` | `cubemastercli cubebox destroy` |

**快照操作**

| 脚本命令 | 用途 | 完整用法 | 实际调用路径 |
| ---- | ---- | -------- | ------------ |
| `snapshot-create` | 对运行中沙箱打快照（内存 + 文件系统） | `snapshot-create <sandbox-id> [--name <显示名>]` | `POST /sandboxes/{id}/snapshots` |
| `snapshot-list` | 列举快照 | `snapshot-list [--sandbox <sandbox-id>] [--limit <N>]` | `GET /snapshots` |
| `snapshot-delete` | 删除快照（需先解除沙箱运行时引用） | `snapshot-delete <snap-id>` | `DELETE /templates/{snap-id}` |
| `sandbox-clone` | 克隆：打快照 + 从快照派生 N 个沙箱 | `sandbox-clone <sandbox-id> [--count <N>] [--config <文件>]` | 快照（CubeAPI）+ multirun 派生 N 个 |
| `sandbox-rollback` | 把沙箱原地回滚到指定快照（ID 不变） | `sandbox-rollback <sandbox-id> <snapshot-id>` | `POST /sandboxes/{id}/rollback` |

**其他**

| 脚本命令 | 用途 | 完整用法 |
| ---- | ---- | -------- |
| `health` | 检查 CubeAPI 健康状态 | `health` |
| `--help` / `help` | 显示完整帮助（含全部用法与示例） | `--help` |

> 所有命令都支持 `--config <文件>` 或环境变量 `REDROID_CONFIG` 指定配置文件（`health` 除外，仅当命令依赖配置文件时生效，如 `template-create` / `sandbox-create` / `sandbox-clone`）。

### 4.2 配置文件 redroid_config.conf

`template-create`、`sandbox-create`、`sandbox-clone` 三个命令的创建参数统一取自配置文件，文件为 bash 键值格式，分 `TPL_*` 与 `SBX_*` 两段。默认文件随脚本同目录（`<工作区>/Kbox-patches-cubesanbox/deploy/redroid_config.conf`），开箱可用。

```bash
# -------------------------------- template 段 --------------------------------
TPL_IMAGE="127.0.0.1:5000/redroid:14.0.0_r75_arm64_only_zp"
TPL_CPU=4000
TPL_MEMORY=8192
TPL_WRITABLE_LAYER_SIZE="10Gi"
TPL_PROBE=49983
TPL_PROBE_TIMEOUT_MS=180000
TPL_ANNOTATIONS=(
    "cube.vm.cgroup.unified_hierarchy=false"
)
TPL_REDROID_ARGS=(
    "androidboot.redroid_width=720"
    "androidboot.redroid_height=1280"
    "androidboot.redroid_dpi=240"
    "androidboot.redroid_fps=60"
)

# -------------------------------- sandbox 段 --------------------------------
SBX_INSTANCE_TYPE="cubebox"
SBX_NETWORK_TYPE="tap"
SBX_NAMESPACE="default"
SBX_SOURCE_ID=""
SBX_ANNOTATIONS=(
    "cube.master.appsnapshot.template.id=tpl-c78f09daaea749aeb814367e"
    "cube.master.appsnapshot.template.version=v2"
    "cube.master.appsnapshot.version=v2"
    "cube.vm.cgroup.unified_hierarchy=false"
)
SBX_LABELS=(
    "X-Caller=mastercli"
    "cube.master.appsnapshot.template.id=tpl-c78f09daaea749aeb814367e"
    "cube.master.instance.type=cubebox"
)
```

**TPL_* 段**（供 `template-create` 使用）：

| 配置项 | 默认值 | 说明 |
| ------ | ------ | ---- |
| `TPL_IMAGE` | （缺省镜像） | registry 全名，必须带 `127.0.0.1:5000/` 前缀；命令行 `--image` 可覆盖 |
| `TPL_CPU` | `4000` | CPU（millicores），模板与沙箱规格须一致 |
| `TPL_MEMORY` | `8192` | 内存（MB） |
| `TPL_WRITABLE_LAYER_SIZE` | `10Gi` | 可写层大小 |
| `TPL_PROBE` / `TPL_PROBE_TIMEOUT_MS` | `49983` / `180000` | envd 探活端口与超时（Android 冷启动约 32–49s，勿用默认 30s） |
| `TPL_ANNOTATIONS` | 见上 | 创建模板时携带的注解（`--annotation k=v`），数组每行一个 `k=v` |
| `TPL_REDROID_ARGS` | 见上 | redroid 显示参数（`--arg k=v`），构建时固化进模板 |

未写的键自动取表中默认值。

**SBX_* 段**（供 `sandbox-create` / `sandbox-clone` 使用）：即 `cubemastercli multirun` 的请求体，字段含义与 CLI 一致。其中：

- `SBX_ANNOTATIONS` / `SBX_LABELS` 数组里 `cube.master.appsnapshot.template.id` 键的值由脚本在运行时覆盖注入为实际的模板或快照 ID（`--alias` / `--snapshot` 传入），**无需手工修改**；`SBX_SOURCE_ID` 留空即可，非空时作为未显式传 ID 情况下的后备取值。

**使用规则**：

1. 优先级：`--config <文件>` > 环境变量 `REDROID_CONFIG` > 默认文件。
2. `cube.vm.cgroup.unified_hierarchy=false` 是 redroid 必需注解：若在配置中被误删，脚本会自动补回并提示；**勿改为其他值**，否则沙箱会进入重启循环（Android `init` 在 cgroup v2 下挂载失败导致）。
3. 需要维护多套规格时，复制整份文件只改需要的键，用 `--config` 指定即可，例如 `bash redroid_operation.sh template-create --alias android15-8c16g --config /path/to/android15_8c16g.config`。

### 4.3 模板操作

#### template-create —— 从 OCI 镜像创建模板

```bash
bash redroid_operation.sh template-create --alias <别名> [--image <镜像名>] [--config <文件>]
```

`--alias` **必填**（若该别名已存在会直接报错「模板已存在」，不会重复创建）；`--image` 缺省使用配置 `template.image`；cpu/memory/注解等其余参数取自配置文件 `template` 段（见 4.2）。成功后前台等待构建完成并打印 `TEMPLATE_ID=`。

> 说明：`--instance-type cubebox`、`--network-type tap`、`--with-cube-ca=false` 由脚本固定携带，不暴露为配置项（改了会导致沙箱起不来或构建失败）。

#### template-list / template-info / template-delete

```bash
bash redroid_operation.sh template-list [--wide]      # --wide 追加 LAST_ERROR 列
bash redroid_operation.sh template-info  <tpl-id>     # 详情，含各节点副本状态
bash redroid_operation.sh template-delete <tpl-id>
```

#### template-commit —— 把运行中沙箱提交为新模板

```bash
bash redroid_operation.sh template-commit <sandbox-id>    # 沙箱须为 running
```

成功后打印 `TEMPLATE_ID=` 与 `BUILD_ID=`，并提示用 `cubemastercli template build-watch --build-id <id>` 跟踪构建进度。适合把调试好的沙箱环境固化为新模板。

> 注意：commit 生成的模板**不带 ALIAS 与 IMAGE_INFO 元数据**（CLI 无 alias 参数、不走镜像路径），属正常行为；需要带别名的模板请用 `template-create`。

### 4.4 沙箱操作

#### sandbox-create —— 创建沙箱 / 从快照派生新沙箱

```bash
bash redroid_operation.sh sandbox-create --alias <模板别名> [--config <文件>]      # 按模板别名创建
bash redroid_operation.sh sandbox-create --snapshot <snap-id> [--config <文件>]    # 从快照派生
```

`--alias` 与 `--snapshot` **二选一、必填**（旧参数 `--template` 已废弃）：`--alias` 按模板别名创建沙箱（脚本查 `template list` 自动换算为 `tpl-…`，别名不存在会报错）；`--snapshot` 传快照 ID（`snap-…`）即 op.md 的「从快照派生新沙箱」。成功后打印 `SANDBOX_ID` 与 `SANDBOX_IP`。

> 说明：由于 redroid 注解限制（见 4.2 使用规则第 2 条），创建统一走 `cubemastercli multirun`。请求体取自配置文件的 `sandbox` 段（见 4.2），脚本把模板/快照 ID 注入后生成临时请求文件并在用后删除。

#### sandbox-list / sandbox-info

```bash
bash redroid_operation.sh sandbox-list [--all] [--wide]  # --all 含已退出沙箱，--wide 追加模板/命名空间等列
bash redroid_operation.sh sandbox-info <sandbox-id>      # 详情：状态/沙箱 IP/模板/注解/容器表
```

#### sandbox-pause —— 暂停沙箱

```bash
bash redroid_operation.sh sandbox-pause <sandbox-id>
```

暂停后沙箱内存快照落盘，暂停期间**零 CPU/内存占用**，但状态完整保留。命令完成后回显沙箱详情，`state=paused` 即暂停完成；若为 `pausing` 稍候用 `sandbox-info` 复查。

#### sandbox-connect —— 连接（唤醒）已暂停沙箱

```bash
bash redroid_operation.sh sandbox-connect <sandbox-id> [--timeout <秒>|-1]
```

对 `paused` 沙箱调用会**自动唤醒**（百毫秒级恢复内存快照），对 `running` 沙箱等同查询连接信息。`--timeout` 顺带设置空闲超时：正数表示至少保留 N 秒，`-1` 表示永不过期，不传保持现状。

#### sandbox-destroy —— 销毁沙箱

```bash
bash redroid_operation.sh sandbox-destroy <sandbox-id> [sandbox-id ...]   # 可一次多个
```

删除 `paused` 状态的沙箱也是允许的（不会先唤醒）。销毁后如怀疑有残留进程占用 CPU，按脚本提示用 `pgrep -f containerd-shim-cube-rs` 检查并按 PID kill（勿用 `pkill -f`）。

### 4.5 快照操作

#### snapshot-create —— 打快照

```bash
bash redroid_operation.sh snapshot-create <sandbox-id> [--name <显示名>]
```

对**运行中**沙箱保存完整状态（内存 + 文件系统），制作期间沙箱会被短暂暂停。快照独立于沙箱生命周期——源沙箱销毁后快照依然可用。成功后打印 `SNAPSHOT_ID=snap-…`。

#### snapshot-list / snapshot-delete

```bash
bash redroid_operation.sh snapshot-list [--sandbox <sandbox-id>] [--limit <N>]
bash redroid_operation.sh snapshot-delete <snap-id>
```

`--sandbox` 按源沙箱过滤。删除快照走 `DELETE /templates/{snap-id}`（快照在存储层即模板，CubeAPI 按 `snap-`/`tpl-` 前缀区分）。**克隆沙箱销毁之前不要删除其底座快照**。

> 删除快照报 `still has active runtime ref(s): <sandbox-id>` 时，说明该快照正被沙箱挂载（回滚/克隆后产生的运行时引用），需先销毁该沙箱再删快照。

#### sandbox-clone —— 克隆沙箱

```bash
bash redroid_operation.sh sandbox-clone <sandbox-id> [--count <N>] [--config <文件>]    # 默认 1 个
```

语义与官方 SDK `clone()` 一致：给源沙箱打快照 → 从快照派生 N 个新沙箱。三个要点：

1. 每个克隆完整继承调用时刻源沙箱的内存与文件系统状态，之后相互完全隔离；
2. 源沙箱保持运行，不受影响；
3. 底座快照**不会自动删除**——等所有克隆沙箱销毁后，用 `snapshot-delete` 清理（脚本结束时会打印该快照 ID）。

> 注意：与 SDK 不同，脚本不提供「部分失败自动回收」——若 `--count` 较大且中途失败，请用 `sandbox-list` 检查已创建的沙箱并手工 `sandbox-destroy`。

#### sandbox-rollback —— 回滚沙箱

```bash
bash redroid_operation.sh sandbox-rollback <sandbox-id> <snapshot-id>
```

把沙箱**原地**恢复到快照状态：沙箱 ID 不变，文件系统与内存一并恢复，恢复后可继续写入、可再打新快照。属长耗时操作（服务端 240s 档），命令会打印 `operationID`，可用 `cubemastercli operation status --operation-id <id>` 查询进度。回滚会重启沙箱内进程，此前建立的 TCP 连接失效属正常现象。

### 4.6 Windows adb连接+scrcpy投屏沙箱

沙箱 IP（`10.100.x.x`）属部署机 Cube 内部网络，Windows 本机无法直连。思路：在 Windows 上建一条 **SSH 本地端口转发**隧道，把本机某端口映射到沙箱的 adb 端口 5555，之后 `adb connect` 与 `scrcpy` 都走 `127.0.0.1` 即可。

前置条件：

- 部署机已运行 sshd：`sudo systemctl enable --now sshd`
- Windows 10/11 自带 OpenSSH 客户端（`ssh` 命令），无需额外安装

1. **拿到沙箱 IP**（部署机上执行）：

   ```bash
   bash redroid_operation.sh sandbox-list   # 取输出的 IP，形如 10.100.x.x
   ```

2. **Windows 建隧道**（PowerShell / CMD 均可，该窗口需保持不关闭）：

   ```bash
   ssh -p 3389 -L 5555:10.100.x.x:5555 <部署机用户>@<部署机IP>
   ```

   `-N` 只建隧道不执行远端命令；`-L 本机端口:沙箱IP:沙箱端口` 把本机 15555 端口转发到沙箱的 5555；端口号可自选，避开本机已占用端口。需密码时按提示输入，建议改用 SSH 密钥免密。

3. **adb 连接**（另开一个 Windows 窗口）：

   ```bash
   adb connect 127.0.0.1:5555
   ```

4. **scrcpy 投屏**：

   用cmd窗口打开scrcpy文件路径，执行以下命令投屏

   ```bash
   scrcpy.exe -s 127.0.0.1:5555
   ```

   常用参数：

   - `--no-audio`：沙箱无声卡时禁用音频，避免启动报错
   - `--max-fps 30`：限制帧率，投屏更流畅
   - `--turn-screen-off`：投屏时关闭沙箱屏幕（不影响操作）
   - `--window-title "redroid-<别名>"`：同时投多台沙箱时区分窗口

5. **用完清理**：先关 scrcpy 窗口，再执行 `adb disconnect`，最后关闭第 2 步的隧道窗口。

> **说明：** `adb` / `scrcpy` 需在 PATH 中；scrcpy 压缩包内的 `adb.exe` 与其同目录，可切到该目录执行，或把路径加入 PATH。
>
> **说明：** 如需在 Windows 本机直接查看沙箱 envd 探活指标（`/metrics`，端口 49983），再加一条隧道：`ssh -N -L 149983:10.100.x.x:49983 <部署机用户>@<部署机IP>`，随后访问 `http://127.0.0.1:149983/metrics`。

