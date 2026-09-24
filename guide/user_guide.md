# CubeSandbox 部署与使用指南（Cube + Redroid）

本文档说明如何在**干净的 openEuler 24.03 SP3 鲲鹏（aarch64）服务器**上部署 CubeSandbox，把数据集中存放在 `/home` 以规避根分区写满，并给出基于 Cube + Redroid 的常用命令与一个最简 Python 客户端。

> **目标**：从零部署 CubeSandbox，基于 redroid 镜像制作 Android 模板、启动沙箱，并掌握模板 / 沙箱 / 快照的日常操作。
>
> **部署机要求**：aarch64 裸金属（`/dev/kvm` 可用），openEuler 24.03 SP3，root 权限，`/home` 有独立且容量充足的分区，Docker ≥ 20.10 且 Compose v2（安装与配置见 §1.3）。
>
> **前置产物**（由另两篇编译文档产出）：
>
> - `cube-sandbox-one-click-<version>.tar.gz` —— CubeSandbox 一键发布包（见 [cube_compile_guide.md](cube_compile_guide.md)）
> - `redroid-14.0.0_r75_arm64_only-docker.tar` —— redroid 14 镜像（见 [redroid_compile_guide.md](redroid_compile_guide.md)）

## 1. 空间规划（部署前必读）

### 1.1 默认落盘位置与风险

| 路径                                                  | 内容                                        | 默认所在文件系统      |
| --------------------------------------------------- | ----------------------------------------- | ------------- |
| `/data/cubelet`                                     | 沙箱可写层、cubecow 存储、节点状态（须 XFS）               | 需为 XFS        |
| `/data/log`                                         | Cubelet / CubeShim / CubeVmm / CubeMaster / CubeAPI / CubeOps / cube-proxy 全部日志 | 根分区           |
| `/data/snapshot_pack/disks`、`/data/cube-shim/disks` | 快照与磁盘文件                                   | 根分区           |
| `/data/cube-shared`、`/data/shared`                  | 共享目录                                      | 根分区           |
| `/data/CubeMaster/storage`                          | 模板 / 快照制品（`rfs-*`）                         | 根分区           |
| `/usr/local/services/cubetoolbox/cubebox_os_image`  | guest 镜像解包目录（实测约 2GB）                      | 根分区           |
| `/usr/local/services/cubetoolbox/cube-snapshot`     | 快照目录                                      | 根分区           |
| `/var/lib/docker`                                   | 容器镜像 + MySQL / Redis / MinIO 数据卷           | 根分区           |

> **说明：** `install.sh` 只在 `/data/cubelet` 上做 XFS 校验（[install.sh](file:///home/maoyue/cube-workspace/code/CubeSandbox/deploy/one-click/install.sh#L943-L979)），`/data` 下的其余目录、Docker 数据与 MySQL 数据卷默认全部落在根分区。鲲鹏服务器的根分区通常只有几十 GB，且 **Cube 不自带 logrotate**，`/data/log/CubeVmm/vmm.log` 单个文件可涨到数十 GB。
>
> **根分区写满的故障链与磁盘无关**：根分区满 → MySQL 无法写 binlog → cubeops 起不来 → cubelet 注册节点超时 → `listinventory` 为空 → 模板创建 / 删除全部报 `invalid connection`。因此第 1 节必须在部署前完成。

### 1.2 把 `/data` 挂载到 `/home`

先确认 `/home` 与 `/` 不在同一分区，且 `/home` 容量充足；若两者同分区，本节无法达到目的，需先为 `/home` 准备独立存储。

```bash
df -h /home /
```

**方案 A：有独立数据盘**

```bash
umount /dev/nvme0n1 2>/dev/null || true
mkfs.xfs -f /dev/nvme0n1
mkdir -p /data
mount /dev/nvme0n1 /data
```

**方案 B：无独立数据盘，用 `/home` 下的 loop 镜像**

```bash
mkdir -p /home/cube-sandbox
truncate -s 400G /home/cube-sandbox/data-xfs.img   # 稀疏文件，按实际使用占用空间
mkfs.xfs -f /home/cube-sandbox/data-xfs.img
mkdir -p /data
mount -o loop /home/cube-sandbox/data-xfs.img /data
```

持久化挂载（按所用方案二选一写入 `/etc/fstab`）：

```
/dev/nvme0n1                    /data  xfs  defaults,noatime       0 0
/home/cube-sandbox/data-xfs.img /data  xfs  loop,defaults,noatime  0 0
```

校验：

```bash
findmnt -no SOURCE,FSTYPE,TARGET /data
# 期望: <设备或镜像> xfs /data
df -h /data
```

> **说明：** 直接挂载 `/data` 而非只挂 `/data/cubelet`——`install.sh` 的校验会从 `/data/cubelet` 向上找到最近的存在祖先，挂载 `/data` 即可满足 XFS 要求，同时把 `/data/log`、`/data/snapshot_pack`、`/data/CubeMaster/storage` 等全部纳入该挂载，一步到位。
>
> **说明：** 若另行挂载 `/data/cubelet`，该挂载点自身也必须是 XFS（`install.sh` 优先校验它）。

### 1.3 安装并配置 Docker（版本 / 数据目录 / 镜像加速 / Compose v2）

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
> **说明：** `registry-mirrors` 仅在从 Docker Hub 拉镜像时生效。本方案只有 §4.2 的 `registry:2` 来自 Docker Hub，Cube 自身组件镜像来自 `*.tencentcloudcr.com`；目标机若可直连 Docker Hub 可省略该项。
>
> **说明：** 目标机需要经 HTTP 代理出网时，**在本节一并配好**，与上面的 `daemon.json` 共用同一次重启：在 `/etc/systemd/system/docker.service.d/http-proxy.conf` 中写入 `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY`（用 `systemctl edit docker` 亦可），随后 `systemctl daemon-reload && systemctl restart docker`。部署开始后不要再重启 Docker。
>
> **说明：** Compose v2 的二进制需按目标架构下载（aarch64 用 `docker-compose-linux-aarch64`）。目标机不能访问 GitHub 时，从任意可联网机器下载同名二进制后拷入同两个路径即可。
>
> **说明：** 该机若已存在 `/var/lib/docker` 且其中有镜像，先 `sudo systemctl stop docker`，用 `cp -a` 迁移到新目录（文件数校验一致）后再删除源目录，然后回到上面第 2 步。

### 1.4 配置日志轮转

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

## 2. 部署机准备

### 2.1 安装系统依赖

Docker 及其全部配置已在 §1.3 完成，这里只装其余依赖：

```bash
sudo dnf install -y e2fsprogs util-linux iproute procps-ng curl tar gzip logrotate android-tools
```

校验：

```bash
ls /dev/kvm
# 必须存在，否则无法创建沙箱
docker version && docker compose version   # 复核 §1.3 的成果
adb version                                # §5.8 用；报缺库时见 §5.8 说明
```

> **说明：** 后续所有步骤需在**不受路径白名单限制的 root shell** 中执行——部分 IDE / 沙箱环境会拦截 `/home`、`/data`、`/usr/local` 等路径的 `cp` / `rm`，导致 §3.4 的目录迁移失败。
>
> **说明：** 如需 S3 卷能力，额外安装 `s3fs-fuse`：`sudo dnf install -y epel-release && sudo dnf install -y s3fs-fuse`；缺失仅影响 S3 卷挂载，不影响模板与沙箱。

### 2.2 部署前自检

```bash
df -h /data /home /
findmnt -no FSTYPE /data || findmnt -no FSTYPE /data/cubelet   # 期望: xfs（/data 或 /data/cubelet 其一为 XFS）
docker info | grep 'Docker Root Dir'          # 期望: /home/cube-sandbox/docker
docker compose version                        # 期望: Docker Compose version v2.x
logrotate -d /etc/logrotate.d/cube-sandbox    # 期望无 error
```

> **说明：** 全部通过后再进入第 3 节。若两处 `findmnt` 返回的都不是 xfs，`install.sh` 会直接终止并给出 `Cube Sandbox requires the /data/cubelet directory to reside on an XFS filesystem`。

## 3. 部署 CubeSandbox

### 3.1 解压发布包

```bash
mkdir -p /home/cube-sandbox/bundle && cd /home/cube-sandbox/bundle
tar -xzf /path/to/cube-sandbox-one-click-<version>.tar.gz
cd cube-sandbox-one-click-<version>
```

### 3.2 配置 .env

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

### 3.3 执行安装

```bash
sudo ./install.sh --mode=install
```

> **说明：** 目标机已存在 CubeSandbox 时，不带 `--mode` 的 `./install.sh` 默认走「保留配置的升级」。**从零部署必须显式指定 `--mode=install`。**
>
> **说明：** 安装固定落在 `/usr/local/services/cubetoolbox`，由 systemd 统一托管（控制节点 target 为 `cube-sandbox-control.target`）。
>
> **说明：** 目标机若已部署过 Cube，安装会**保留既有的版本化组件目录**（`/data/cubelet/root/component_versions/`）。请先完成 §3.5 的校验，再进入第 5 节。

### 3.4 把两个大目录迁到 `/home`

`cubebox_os_image` 与 `cube-snapshot` 默认落在 Cubelet 插件配置的 `BasePath` 下（默认 `/usr/local/services/cubetoolbox`，见 [cubebox.go](file:///home/maoyue/cube-workspace/code/CubeSandbox/Cubelet/plugins/cbri/cubeboxcbri/cubebox.go#L63-L72)）。本方案不改插件配置，直接用软链迁移：

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

### 3.5 验证安装

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
>
> **说明：** §3.7 的健康校验脚本会把本节与 §3.6 的检查合并为一条命令，推荐直接用脚本。

### 3.6 等待 Cubelet 就绪

Cubelet 启动后还需初始化 network plugin，期间发起模板创建会报 `template creation failed on all nodes`：

```bash
grep -a "starting cri plugin" /data/log/Cubelet/Cubelet-req.log | tail -1
cubemastercli listinventory        # 期望返回数值（节点已注册）
```

上述时间戳之后（约 120s）再执行第 5 节；节点未注册时模板创建会报 `template has no ready replica`。

### 3.7 一键健康校验

把 §3.5、§3.6 的检查合并为一条命令。脚本随本方案提供：`<工作区>/Kbox-patches/deploy/cube_healthcheck.sh`。

```bash
cd <工作区>/Kbox-patches/deploy

sudo bash cube_healthcheck.sh                        # 部署后自检 / 日常巡检
sudo bash cube_healthcheck.sh --sandbox 10.100.1.40  # 顺带校验某个沙箱（IP 用 §5.2 打印的 Ip）
```

覆盖范围：

| 分组        | 检查内容                                                                                                    |
| --------- | ------------------------------------------------------------------------------------------------------- |
| 1 系统前置    | `/dev/kvm`、`/data` 为 XFS、Docker 可用、Compose v2 可用                                                          |
| 2 systemd | `cube-sandbox-control.target` 与 4 个核心服务（不 active 即 FAIL）；其余单元（不 active 记 WARN）                            |
| 3 支撑容器    | `cube-sandbox-mysql` / `cube-sandbox-redis` / `cube-sandbox-minio`（FAIL）；coredns / cube-proxy / LCM / cube-egress / webui（WARN） |
| 4 关键端口    | `3306`、`6379`、`9000`、`8089`、`3000`、`3010`                                                                |
| 5 HTTP 健康 | CubeMaster `/notify/health`、CubeAPI `/health`、CubeOps `/health`、Cubelet 内嵌网络运行时                         |
| 6 组件一致性   | §3.5：cube-shim（shim + runtime）、cube-agent、cube-image、cube-kernel-scf 的 live 与版本化副本是否同源                 |
| 7 节点注册    | §3.6：`cubemastercli listinventory` 是否有数值                                                                |
| 8 沙箱（可选）  | 指定 `--sandbox <ip>` 时校验 envd `49983` 与 adb `5555` 是否可达                                                   |

判读：

- 退出码 `0` = 没有 FAIL（可能仍有 WARN）；退出码 `1` = 存在 FAIL。
- `[FAIL]` 需逐条解决；`[WARN]` 按提示确认即可，例如 `cube-egress` 在首个沙箱创建前未就绪、节点尚未注册（Cubelet 启动后约 120s）、MinIO 端口未监听等。

> **说明：** 沙箱“功能正常”的最终标准仍是 §5.2 打印 `code:200` 且 §5.8 的 adb 校验全部通过；本脚本用于在此之前把基础设施层面的问题全部拦掉。

## 4. 准备 redroid 镜像

### 4.1 加载镜像

```bash
docker load -i /path/to/redroid-14.0.0_r75_arm64_only-docker.tar

# 校验并记录镜像名（供后续步骤使用）
docker images | grep redroid
```

```bash
# 取「仓库名:标签」两部分（不要只写标签），下面为示例，请以 §4.1 的实际输出为准
REDROID_IMAGE=redroid:14.0.0_r75_arm64_only
```

### 4.2 启动本地 Registry 并推送

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

## 5. Cube 常用命令

以下命令均操作控制面 `cubemaster`（默认 `127.0.0.1:8089`），无需额外配置。

各操作对应的 Cube 命令、Cube API 与 E2B 支持情况总览（按「Cube 命令 → Cube API → E2B SDK」优先级排列）：

| 操作           | Cube 命令                                                          | Cube API（E2B 兼容）                                | E2B SDK                  |
| ------------ | ---------------------------------------------------------------- | ----------------------------------------------- | ------------------------ |
| 制作模板         | `cubemastercli template create-from-image`（5.1）                  | 不可（请求模型缺 `annotations` / 探活超时，见 6.2 说明）          | 不支持                      |
| 启动沙箱         | `cubemastercli multirun`（5.2）                                    | 不可（同上）                                          | `Sandbox.create()`       |
| 查看沙箱         | `cubemastercli ls` / `info`（5.3）                                 | `GET /sandboxes`、`GET /sandboxes/{id}`          | `Sandbox.list()` / `get_info()` |
| 查看模板         | `cubemastercli template list` / `info`（5.3）                      | `GET /templates`、`GET /templates/{id}`          | 不支持                      |
| 制作快照         | `cubemastercli snapshot create`（5.4）                             | `POST /sandboxes/{id}/snapshots`                | 不支持                      |
| 沙箱恢复         | `cubemastercli cubebox rollback` / 以 `snap-` id 起箱（5.5）          | `POST /sandboxes/{id}/rollback`                 | 不支持                      |
| 删除沙箱         | `cubemastercli cubebox destroy`（5.6）                             | `DELETE /sandboxes/{id}`                        | `sbx.kill()`             |
| 删除模板 / 快照     | `cubemastercli template delete` / `snapshot delete`（5.6）         | `DELETE /templates/{id}`                        | 不支持                      |

> **说明：** 模板与快照、回滚属 CubeSandbox 扩展能力，E2B SDK 无对应方法；模板与沙箱的**创建**又受 CubeAPI 请求模型限制（不暴露 `annotations`），因此本方案这两步以 `cubemastercli` 为准，其余操作两条路径等价。详见第 6 章。

### 5.1 制作模板

模板是「镜像 + 内核 + shim」的状态快照，三者任一更新都必须重建模板。

```bash
cubemastercli template create-from-image \
  --image "${REGISTRY_IMAGE}" \
  --alias android14-4c8g \
  --writable-layer-size 10Gi \
  --probe 49983 \
  --probe-timeout-ms 180000 \
  --annotation cube.vm.cgroup.unified_hierarchy=false \
  --cpu 4000 \
  --memory 8192 \
  --arg androidboot.redroid_width=720 \
  --arg androidboot.redroid_height=1280 \
  --arg androidboot.redroid_dpi=240 \
  --arg androidboot.redroid_fps=60 \
  --instance-type cubebox \
  --network-type tap \
  --with-cube-ca=false
```

命令默认前台等待构建完成，输出 `job_id` / `template_id` / `status`。

关键参数：

| 参数                                                     | 说明                                                                                     |
| ------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| `--image`                                              | registry 全名，必须带 `127.0.0.1:5000/` 前缀                                                      |
| `--writable-layer-size 10Gi`                           | 可写层大小，必填                                                                               |
| `--probe 49983` / `--probe-timeout-ms 180000`           | envd 探活端口与超时。Android 冷启动到 envd 就绪约 32–49s，默认 30s 必然超时                                     |
| `--annotation cube.vm.cgroup.unified_hierarchy=false`  | **必须**。置 `false` 时 shim 不向 guest 注入 cgroup v2 预挂载 cmdline，否则 Android `init` 挂载失败并触发重启循环         |
| `--cpu 4000 --memory 8192`                             | 4 核 / 8GB，模板与沙箱规格需一致                                                                    |
| `--arg androidboot.redroid_*`                          | redroid 显示参数，作为 init argv 在模板冷启动时固化进快照                                                   |
| `--with-cube-ca=false`                                 | redroid rootfs 已含 `/etc`，不设置会报 `mkdir .../etc: file exists`                            |

> **说明：** `--probe-timeout-ms` 与 `--annotation` 是本方案 patch 为 CLI 新增的参数。若 CLI 报 `flag provided but not defined`，说明 Cube 修改未编译进发布包，回到 [cube_compile_guide.md](cube_compile_guide.md) 重新构建。

记录模板 ID：

```bash
TEMPLATE_ID=<tpl-xxxxxxxxxxxxxxxxxxxxxxxx>
```

### 5.2 启动沙箱

请求文件 `redroid14_req.json`（注解必须与模板一致）：

```bash
cat > redroid14_req.json << EOF
{
  "instance_type": "cubebox",
  "network_type": "tap",
  "namespace": "default",
  "annotations": {
    "cube.master.appsnapshot.template.id": "${TEMPLATE_ID}",
    "cube.master.appsnapshot.template.version": "v2",
    "cube.master.appsnapshot.version": "v2",
    "cube.vm.cgroup.unified_hierarchy": "false"
  },
  "labels": {
    "X-Caller": "mastercli",
    "cube.master.appsnapshot.template.id": "${TEMPLATE_ID}",
    "cube.master.instance.type": "cubebox"
  }
}
EOF
```

```bash
cubemastercli multirun --norm --runcnt 1 --runcc 1 redroid14_req.json
```

期望输出 `code:200`，并打印 `sandBoxId` 与 `Ip`。

> **说明：** `--norm` 表示创建后不删除沙箱（不加会被当作压测、创建完即销毁）；`--runcnt` 为循环次数，`--runcc` 为并发数。
>
> **说明：** 把 `cube.master.appsnapshot.template.id` 换成 `snap-` 前缀的快照 ID，即可**基于快照启动新沙箱**。

### 5.3 查看沙箱与模板

```bash
# 沙箱列表（--wide 追加 template_id / namespace / host_ip / labels）
cubemastercli ls
cubemastercli ls --all --wide

# 沙箱详情（-s 指定沙箱 ID）
cubemastercli info -s <sandbox-id>

# 模板列表（--output/-o wide 追加 LAST_ERROR 列；`template` 可简写为 `tpl`）
cubemastercli template list
cubemastercli template list -o wide

# 模板详情（含各节点副本状态）
cubemastercli template info <tpl-xxxxxxxxxxxxxxxxxxxxxxxx>

# 模板预览：查看该模板实际会下发的沙箱请求
cubemastercli template render --template-id <tpl-xxxxxxxxxxxxxxxxxxxxxxxx>

# 资源清单
cubemastercli listinventory
```

`ls` 表头：`sandbox_id status backend remote pause_snap host_id create_at pause_at`，`status` 取值 `created / running / exited / pausing / paused`。

`info` 关键字段：`SANDBOX_ID / STATUS / HOST_IP / SANDBOX_IP / TEMPLATE_ID / ANNOTATIONS / LABELS`，以及容器表 `NAME / IMAGE / STATUS / CPU / MEM / CONTAINER_TYPE`。

### 5.4 制作快照

快照是对**运行中沙箱**的即时状态保存，可直接当作模板用来创建新沙箱。

```bash
# 制作快照（沙箱须为 running）
cubemastercli snapshot create --sandbox-id <sandbox-id> --display-name cocos-scene

# 列表（-o wide 追加 DISPLAY_NAME / RUNTIME_REFS / LAST_ERROR）
cubemastercli snapshot list
cubemastercli snapshot list -o wide

# 详情
cubemastercli snapshot info --snapshot-id <snap-xxxxxxxxxxxxxxxxxxxxxxxx>

# 快照存储状态（各节点磁盘水位）
cubemastercli storage status --refresh
```

快照 ID 形如 `snap-` + 24 位十六进制。制作完成后即可直接起新沙箱：

```bash
cubemastercli multirun --norm --runcnt 1 --runcc 1 redroid14_req.json
# 其中 cube.master.appsnapshot.template.id 改为 <snap-xxxxxxxxxxxxxxxxxxxxxxxx>
```

### 5.5 沙箱恢复

**方式一：原地回滚到某个快照**

```bash
cubemastercli cubebox rollback \
  --sandbox-id <sandbox-id> \
  --snapshot-id <snap-xxxxxxxxxxxxxxxxxxxxxxxx>
```

**方式二：从快照派生新沙箱**（推荐，不影响原沙箱）

见 5.4 节末尾，把快照 ID 填入沙箱请求文件即可。

> **说明：** 回滚与快照制作都是长耗时操作（服务端 240s 档），可通过异步操作查询进度：
>
> ```bash
> cubemastercli operation status --operation-id <op-id>
> cubemastercli operation watch  --operation-id <op-id>
> ```

### 5.6 删除沙箱、模板与快照

```bash
# 删除沙箱（别名 rm，可一次多个）
cubemastercli cubebox destroy <sandbox-id> [sandbox-id ...]

# 删除模板
cubemastercli template delete --template-id <tpl-xxxxxxxxxxxxxxxxxxxxxxxx>

# 删除快照
cubemastercli snapshot delete --snapshot-id <snap-xxxxxxxxxxxxxxxxxxxxxxxx>
```

> **说明：** 删除沙箱后可能残留 `containerd-shim-cube-rs` 进程（内含 redroid + 渲染线程），持续占 CPU。检查与清理：
>
> ```bash
> pgrep -f containerd-shim-cube-rs
> kill <PID>          # 按 PID kill；勿用 pkill -f，会匹配到自身 shell
> ```
>
> **说明：** 模板 / 快照删不掉且报 `already in progress` 时，是 `t_cube_template_image_job` 里残留 `PENDING` 的 `SNAPSHOT_DELETE` job 造成自锁（`DeleteTemplate` 只认终态 `READY`/`FAILED`）：
>
> ```bash
> docker exec cube-sandbox-mysql mysql -ucube -pcube_pass cube_mvp -e "
> UPDATE t_cube_template_image_job SET status='FAILED', phase='FAILED'
>  WHERE template_id LIKE 'snap-%' AND operation='SNAPSHOT_DELETE'
>    AND status IN ('PENDING','RUNNING');"
> ```

### 5.7 模板与运维的其他命令

| 命令                                                                  | 用途                                   |
| ------------------------------------------------------------------- | ------------------------------------ |
| `cubemastercli template set-alias <tpl-id> --alias <alias>`          | 设置 / 修改模板别名（`--clear` 清除）             |
| `cubemastercli template commit --sandbox-id <id>`                    | 把现有沙箱提交成模板（输出 `template_id` / `build_id`） |
| `cubemastercli template build-watch --build-id <build-id>`            | 跟踪 commit 构建进度                       |
| `cubemastercli template redo <tpl-id> [--failed-only]`                | 在全部 / 指定 / 失败节点重做模板副本                 |
| `cubemastercli template watch --job-id <job-id>`                      | 跟踪 create-from-image 构建进度             |
| `cubemastercli volume list`                                           | 查看卷                                 |
| `systemctl status cube-sandbox-control.target`                        | 查看控制面整体状态                            |
| `sudo ./down.sh` / `systemctl start cube-sandbox-control.target`      | 停止 / 启动所有服务（不删数据）                    |

### 5.8 验证沙箱为 Android

先做一次**免 adb** 的就绪判定（推荐）：`envd` 由 guest 的 `sys.boot_completed=1` 触发启动，它能响应即表示沙箱内 Android 已完成启动。

```bash
curl -s "http://<SANDBOX_IP>:49983/metrics"
# 期望返回 JSON：{"cpu_count":4,"mem_total_mib":7943,"disk_used":..., ...}
```

再进行 adb 验证：

```bash
adb connect <SANDBOX_IP>:5555
adb -s <SANDBOX_IP>:5555 shell getprop sys.boot_completed        # 期望 1
adb -s <SANDBOX_IP>:5555 shell "ps -A | grep -E 'zygote64|surfaceflinger|system_server'"
adb -s <SANDBOX_IP>:5555 shell "cat /proc/pressure/memory"        # PSI 可用（patch 0005）
adb -s <SANDBOX_IP>:5555 shell "ip rule show | head -5"           # 策略路由可用（patch 0006）
adb -s <SANDBOX_IP>:5555 shell "ping -c 2 -W 3 223.5.5.5"         # 期望 0% 丢包
```

> **说明：** 宿主需有可用的 `adb`（§2.1 已安装 `android-tools`）。若报缺库（`libadb.so.0: cannot open shared object file`），说明用的是手工放置的二进制，用 `LD_LIBRARY_PATH=<adb 库目录>` 重跑即可，与沙箱无关。
>
> **说明：** **adb 是否可用取决于 redroid 镜像的构建变体**：`userdebug` 变体默认启动 adbd，`user` 变体不会（缺少 `persist.sys.usb.config=adb` 且 `ro.adb.secure=1`）。因此 `Connection refused` 时先用上面的 `/metrics` 确认 Android 已就绪——若就绪，则是镜像变体导致的 adbd 未启动，处理办法见 [redroid_user_build_adb_fix.md](redroid_user_build_adb_fix.md)。
>
> **说明：** guest 控制台（`/data/log/CubeShim/`）不适合作为"Android 是否启动完成"的判据：`vendor.bluetooth-1-1` 会在所有沙箱上持续以 `signal 4` 崩溃刷屏，正常与异常沙箱的控制台形态一致。

## 6. Python 客户端（cube_client.py）

第 5 章的 `cubemastercli` 是这套操作的标准入口，覆盖全部用例。需要脚本化时用配套的
[cube_client.py](../deploy/cube_client.py)：它同样**优先调用 Cube 自身的命令与 API**
（模板/沙箱创建走 `cubemastercli`，其余走 CubeAPI），**仅依赖 Python 标准库**，无需 `pip install`。

### 6.1 环境变量

| 变量               | 默认值                     | 说明                                     |
| ---------------- | ----------------------- | -------------------------------------- |
| `CUBE_API_URL`   | `http://127.0.0.1:3000` | CubeAPI 地址（Cube 官方 HTTP API，E2B 兼容）      |
| `CUBE_API_KEY`   | 空                       | 启用鉴权时填写（同时以 `X-API-Key` 与 `Bearer` 发送） |
| `CUBEMASTERCLI`  | `cubemastercli`         | CLI 路径                                 |

> **说明：** one-click 默认不启用 CubeAPI 鉴权（`env.example` 中 `CUBE_API_KEY` 为空），此时任意请求放行。

### 6.2 命令一览

```bash
cd <工作区>/Kbox-patches/deploy

python3 cube_client.py health                                     # 健康检查

# —— 走 cubemastercli（Cube 官方 CLI）
python3 cube_client.py template-create --image <img> --alias <a>   # 从 OCI 镜像制作模板
python3 cube_client.py template-commit <sandbox-id>                # 把沙箱提交成模板
python3 cube_client.py sandbox-create --template <tpl-id|snap-id>  # 启动沙箱

# —— 走 CubeAPI（Cube 官方 HTTP API，E2B 兼容）
python3 cube_client.py template-list                              # 列出模板
python3 cube_client.py template-info   <tpl-id>                   # 模板详情
python3 cube_client.py template-delete <tpl-id>                   # 删除模板
python3 cube_client.py sandbox-list                               # 列出沙箱
python3 cube_client.py sandbox-info   <sandbox-id>                # 沙箱详情
python3 cube_client.py sandbox-delete <sandbox-id> [...]          # 删除沙箱
python3 cube_client.py snapshot-create <sandbox-id> [--name n]    # 制作快照
python3 cube_client.py snapshot-list                              # 列出快照
python3 cube_client.py snapshot-delete <snap-id>                  # 删除快照
python3 cube_client.py sandbox-rollback <sandbox-id> <snap-id>    # 沙箱回滚
```

> **说明：** 模板创建与沙箱创建由脚本转调 `cubemastercli`。原因：这两步必须携带注解 `cube.vm.cgroup.unified_hierarchy=false`，而 CubeAPI 的 `NewSandbox` / `CreateTemplateRequest` 请求模型不暴露 `annotations` 字段（只会注入 `cube.master.appsnapshot.*`），HTTP 侧无法表达。其余命令均直接调用 CubeAPI。

### 6.3 完整操作示例

```bash
cd <工作区>/Kbox-patches/deploy
export CUBE_API_URL=http://127.0.0.1:3000
CLI="python3 $(pwd)/cube_client.py"

# 1) 制作模板（打印 TEMPLATE_ID）
$CLI template-create \
  --image 127.0.0.1:5000/redroid-14.0.0_r75_arm64_only:latest \
  --alias android14-4c8g

# 2) 启动沙箱
$CLI sandbox-create --template tpl-0518ac1f993044a09134cc66

# 3) 查看
$CLI sandbox-list
$CLI sandbox-info sbx-xxxxxxxxxxxxxxxxxxxxxxxx

# 4) 制作快照，并基于快照再起一个沙箱
$CLI snapshot-create sbx-xxxxxxxxxxxxxxxxxxxxxxxx --name cocos-scene
$CLI snapshot-list
$CLI sandbox-create --template snap-yyyyyyyyyyyyyyyyyyyyyyyy

# 5) 回滚
$CLI sandbox-rollback sbx-xxxxxxxxxxxxxxxxxxxxxxxx snap-yyyyyyyyyyyyyyyyyyyyyyyy

# 6) 清理
$CLI sandbox-delete sbx-xxxxxxxxxxxxxxxxxxxxxxxx sbx-zzzzzzzzzzzzzzzzzzzzzzzz
$CLI snapshot-delete snap-yyyyyyyyyyyyyyyyyyyyyyyy
$CLI template-delete tpl-0518ac1f993044a09134cc66
```

### 6.4 可选：直接用 E2B SDK

第 5 章的操作全部可用 Cube 自身的命令与 API 完成，E2B SDK 只是**可选的编程接口**。把 `E2B_API_URL` 指向 CubeAPI 即可直连，但 E2B SDK 只覆盖**沙箱运行期能力**，控制面能力（模板构建、快照、回滚）在 E2B 侧没有对应方法：

| 能力                        | E2B SDK（`e2b` / `e2b_code_interpreter`） | CubeSandbox                 |
| ------------------------- | ------------------------------------- | --------------------------- |
| 启动沙箱 / 详情 / 列表 / 删除        | 支持                                    | 支持（`cubemastercli` / CubeAPI） |
| 命令执行 / 文件读写 / 代码执行        | 支持                                    | 支持                          |
| pause / resume / connect  | 支持                                    | 支持                          |
| set_timeout / 网络出入策略      | 支持                                    | 支持                          |
| **制作模板 / 删除模板**           | **不支持**                               | 支持（`cubemastercli` / CubeAPI） |
| **制作快照 / 列出快照 / 删除快照**     | **不支持**                               | 支持（同上）                      |
| **沙箱回滚 / 从快照克隆**           | **不支持**                               | 支持（同上）                      |

若已有基于 E2B SDK 的代码且只需沙箱生命周期，可直接复用（依赖 `pip install e2b-code-interpreter`）：

```python
import os
from e2b_code_interpreter import Sandbox

os.environ["E2B_API_URL"] = "http://127.0.0.1:3000"
os.environ.setdefault("E2B_API_KEY", "e2b_000000")   # 未启用鉴权时占位即可

with Sandbox.create(template="tpl-0518ac1f993044a09134cc66") as sbx:
    print(sbx.get_info())
    print(sbx.commands.run("getprop sys.boot_completed").stdout)
```

> **说明：** E2B SDK 通过 `Authorization: Bearer <E2B_API_KEY>` 认证；已知 `e2b>=2.38.0` 与 `e2b-code-interpreter==2.9.0` 组合存在 `TypeError: get_transport() got an unexpected keyword argument 'http2'`，锁定到仓库已验证的版本区间（如 `e2b==2.26.0`）可规避。
>
> **说明：** 模板构建等控制面操作仍需回到 `cubemastercli` 或 CubeAPI（见第 5 章），这是 Cube 的既定分工，不是 E2B SDK 的缺失配置问题。

<br />

## 附录 A：路径与服务速查

| 类别   | 路径 / 单元                                                                                       |
| ---- | ------------------------------------------------------------------------------------------- |
| 安装目录 | `/usr/local/services/cubetoolbox`                                                           |
| 运行时配置 | `/usr/local/services/cubetoolbox/.one-click.env`                                            |
| 健康校验脚本 | `<工作区>/Kbox-patches/deploy/cube_healthcheck.sh`（§3.7）                                        |
| 数据 / 日志 | `/data/cubelet`、`/data/log`、`/data/CubeMaster/storage`（第 1.2 节后均在 `/home` 后端）                |
| Docker 数据 | `/home/cube-sandbox/docker`                                                                 |
| 控制面 target | `cube-sandbox-control.target`                                                               |
| 核心单元 | `cube-sandbox-cubelet` / `cube-sandbox-cubemaster` / `cube-sandbox-cube-api` / `cube-sandbox-cubeops` |
| 常用端口 | CubeAPI `3000`、CubeMaster `8089`、WebUI `12088`、MySQL `3306`、Redis `6379`                      |

## 附录 B：故障速查

| 现象                                                                 | 处理                                                                                              |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| `install.sh` 报 `requires the /data/cubelet directory to reside on an XFS filesystem` | `/data` 未挂 XFS，按 1.2 节处理                                                                         |
| `install.sh` 报 `overlaps an existing cube-dev network`               | 目标机存在历史 cube 网络，按 3.2 节重置后重跑                                                                    |
| 模板创建报 `template creation failed on all nodes`                       | Cubelet 未就绪，按 3.6 节等待后重试                                                                         |
| 模板创建报 `template has no ready replica`                               | 节点未注册完成，按 3.6 节确认 `listinventory` 有数值后重试                                                          |
| `cubemastercli` 缺 `--annotation` / `--probe-timeout-ms`              | 发布包未包含本方案 patch，回到编译文档重新构建                                                                       |
| 模板能建、沙箱报 GICv3ITS 恢复失败                                              | 两处 cube-shim 非同一构建，按 3.5 节校验并同步后再重建模板                                                            |
| 支撑组件起不来，日志报 `kwargs_from_env() got an unexpected keyword argument 'ssl_version'` | 未安装 Compose v2，按 §1.3 第 4 步安装                                                                     |
| 重启过 `docker.service` 后核心服务一直起不来                                     | 依赖 `docker.service` 的单元会判依赖失败：`systemctl reset-failed && systemctl restart cube-sandbox-control.target` |
| 模板能建、沙箱起箱异常或 `adb 5555` 连不上                                        | 组件版本化目录与 `/usr/local` 不同源，按 §3.5 校验并同步后重建模板                                                       |
| `adb connect <沙箱IP>:5555` 报 `Connection refused`，而 `curl http://<沙箱IP>:49983/metrics` 正常 | 镜像为 `user` 变体，adbd 未被启动（Android 本身已就绪），见 5.8 节与 [redroid_user_build_adb_fix.md](redroid_user_build_adb_fix.md) |
| 定位不了当前是哪个环节异常                                                     | 跑 §3.7 的 `cube_healthcheck.sh`，按 `[FAIL]` 项逐条处理                                              |
| 沙箱创建即 reboot 循环                                                    | 模板与沙箱请求都缺 `cube.vm.cgroup.unified_hierarchy=false`                                              |
| 应用无法上公网、`ping` 报 `Network is unreachable`                           | guest 内核缺策略路由（patch `0006`），重编内核并重建模板                                                            |
| `listinventory` 为空 / 模板删除报 `invalid connection`                     | 根分区（或 `/data` 所在分区）写满导致 MySQL 异常，按第 1 节排查                                                           |
| 沙箱一直 `created` 不变 `running`                                        | 查 `/data/log/CubeVmm/vmm.log` 与 `/data/log/CubeShim/`                                             |
| 删沙箱后 `containerd-shim-cube-rs` 残留吃 CPU                              | 按 PID kill（勿用 `pkill -f`）                                                                        |
| 宿主**重启后**模板建箱报 `failed to create shim task: ttrpc: closed`         | 模板快照不跨宿主重启有效：用同一镜像**重建模板**即可恢复                                                                   |

## 附录 C：已知限制

1. **模板与内核 / cube-shim 强绑定**：更换 guest 内核或 Cube 组件后必须重建模板。
2. **模板快照不跨宿主重启**：宿主重启后需重建模板（同一 redroid 镜像与内核即可）。
3. **Android 沙箱必须关闭 cgroup 预挂载**：模板创建与沙箱创建两处都要带 `cube.vm.cgroup.unified_hierarchy=false`。
4. **`/data/cubelet` 必须位于 XFS**：`install.sh` 强制校验，非 XFS 直接终止。
5. **`cubebox_os_image` / `cube-snapshot` 默认不在 `/data` 下**：其位置由 Cubelet 插件 `BasePath`（默认 `/usr/local/services/cubetoolbox`）决定，本方案用软链迁移到 `/home`。
