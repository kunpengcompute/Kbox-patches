# 安装指南

## 环境准备

### 硬件环境

| 配置项 | 硬件配置方案一 | 硬件配置方案二 |
| ---- | ---- | ---- |
| CPU  | 2*鲲鹏920 7280Z处理器，80核，2.9GHz | 2*鲲鹏950 7592C处理器，96核，2.3GHz |
| 内存 | 16*DDR5 DIMM内存-64GB-4800MT/s | 24*DDR5 DIMM内存-64GB-6400MT/s |
| 操作系统 | openEuler 24.03 LTS SP3 | openEuler 24.03 LTS SP3 |

### 软件环境

|序号|软件|说明|获取地址|
| ---- | ---- | ---- | ---- |
|1| CubeSandbox源码 | 版本：v0.7.1 | [CubeSandbox源码下载链接](https://gitcode.com/boostkit/CubeSandbox.git) |
|2| Kbox-patches源码 | Kbox AOSP补丁、脚本Demo包 | [Kbox-patches源码下载链接](https://gitcode.com/boostkit/Kbox-patches.git)<br>分支：dev_AndroidSandbox |
|3| Guest内核源码 | 版本：6.6.119-49.6 | [Guest内核源码下载链接](https://gitee.com/OpenCloudOS/OpenCloudOS-Kernel.git) |

### 安装编译依赖包

```bash
sudo dnf install -y git make tar gzip pigz python3 nodejs npm docker
sudo systemctl start docker && sudo systemctl enable docker
```

## 拉取源码

### 准备工作区

创建工作区根目录的位置自行指定，下文用`~`指代通用的创建位置，`~/cube-workspace/` 为工作区根目录。

```bash
mkdir -p ~/cube-workspace && cd ~/cube-workspace
```

### 拉取CubeSandbox v0.7.1源码

```bash
cd ~/cube-workspace
git clone https://gitcode.com/boostkit/CubeSandbox.git
cd CubeSandbox
git checkout febb88f92979ff116e3285e4ef6c8b9e399f4e75
```

### 拉取Guest内核源码

```bash
cd ~/cube-workspace
git clone https://gitee.com/OpenCloudOS/OpenCloudOS-Kernel.git opencloudos-kernel
cd opencloudos-kernel
git checkout 6.6.119-49.6
```

### 获取Kbox软件包

获取Kbox软件包

```bash
cd ~/cube-workspace
git clone https://gitcode.com/boostkit/Kbox-patches.git -b dev_AndroidSandbox
```

### 修改本机网络配置

沙箱网络依赖IP转发，`net.ipv4.ip_forward`为0时沙箱启动后网络会异常，需将其修改为1。先在shell命令行中手动修改并确认：

```bash
sudo sysctl -w net.ipv4.ip_forward=1
sysctl -n net.ipv4.ip_forward    # 期望返回 1
```

`sysctl -w`只修改内核当前运行值，**重启后会失效**。如需重启后仍生效，需将配置写入`/etc/sysctl.conf`：

```bash
# 取消注释并改值为 1（兼容 = 两侧有无空格）
sudo sed -i -E 's@^#?[[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=.*@net.ipv4.ip_forward = 1@' /etc/sysctl.conf
# 文件里原本没有这一行时兜底追加
grep -q '^net.ipv4.ip_forward' /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
#写入后重启系统时该配置会被自动加载；若不重启，执行此命令立即生效
sudo sysctl -p                
```

## 构建CubeSandbox和Guest内核

### 一键构建<a id="一键构建"></a>

根据实际环境配置环境变量：

| 变量 | 默认值 | 说明 |
| -- | -- | -- |
| CUBE_SRC | ~/cube-workspace/CubeSandbox | CubeSandbox源码目录 |
| KERNEL_SRC | ~/cube-workspace/opencloudos-kernel | Guest内核源码目录 |

```bash
cd ~/cube-workspace/Kbox-patches/build
./build-cube.sh all
```

### 分步构建

本脚本提供分步构建能力，若已执行[一键构建](#一键构建)则可跳过本章节。

```bash
cd ~/cube-workspace/Kbox-patches/build
./build-cube.sh patch     # 1) 合入 patchForCube/ 下的所有patch
./build-cube.sh kernel    # 2) 编译 Guest内核
./build-cube.sh bundle    # 3) 编译 CubeSandbox 一键发布包
```

### 产物与注意事项

| 产物       | 路径                                                                          |
| -------- | --------------------------------------------------------------------------- |
| Guest内核 | ~/cube-workspace/CubeSandbox/_output/kernel/aarch64/vmlinux                                |
| 发布包    | ~/cube-workspace/CubeSandbox/deploy/one-click/dist/cube-sandbox-one-click-\<version\>.tar.gz |

## 部署CubeSandbox

### `/data` 目录配置

CubeSandbox工作路径在`/data`，文件格式需要为xfs。建议在安装系统时给/data目录划分足够的空间（分区大小可根据需要酌情配置，建议>200GB），或者参考下文将一块独立的nvme硬盘挂载到该路径，以方便灵活配置。下文以`nvme0n1`为例，请根据实际磁盘名称替换相关字段：

```bash
umount /dev/nvme0n1 2>/dev/null || true
mkfs.xfs -f /dev/nvme0n1                # 该操作会销毁 /dev/nvme0n1 上的所有数据，请确认数据已备份
mkdir -p /data
mount /dev/nvme0n1 /data
```

建议将磁盘挂载持久化配置到`/etc/fstab`文件，以实现开机自动挂载磁盘。推荐使用磁盘UUID进行配置，可避免设备名（如`/dev/nvme0n1`）在重启或硬盘增减后发生变化导致挂载失败。先查询磁盘UUID：

```bash
blkid /dev/nvme0n1
# 返回示例：/dev/nvme0n1: UUID="e7398a6b-XXXX-XXXX-XXXX-XXXXXXXXXXXX" TYPE="xfs"
```

将返回的UUID填入`/etc/fstab`，配置示例：

```bash
UUID=e7398a6b-XXXX-XXXX-XXXX-XXXXXXXXXXXX  /data  xfs  defaults,noatime  0 0
```

校验：

```bash
findmnt -no SOURCE,FSTYPE,TARGET /data
# shell返回 /dev/nvme0n1（或按UUID挂载时的/dev/disk/by-uuid/...） xfs /data
df -h /data
```

**备选方案：**

以下备选方案可以在不依赖额外磁盘的情况下配置`/data`目录。**注意：本备选方案会对沙箱启动&运行性能造成不良影响，不建议在正式生产环境采用本备选方案。**
下文假设`/home`分区空间充足，以`/home`目录为例进行img文件创建和配置。

```bash
mkdir -p /home/cube-sandbox
truncate -s 400G /home/cube-sandbox/data-xfs.img   # 稀疏文件，按实际使用占用空间
mkfs.xfs -f /home/cube-sandbox/data-xfs.img
mkdir -p /data
mount -o loop /home/cube-sandbox/data-xfs.img /data
```

持久化挂载写入 `/etc/fstab`：

```bash
/home/cube-sandbox/data-xfs.img /data  xfs  loop,defaults,noatime  0 0
```

校验方式相同。

### 安装并配置Docker <a id="安装并配置Docker"></a>

本节把Docker相关的**安装与全部配置一次性做完**，之后直到部署完成都**不需要再重启Docker**。

```bash
# 1) 安装 Docker：openEuler 24.03 仓库中维护的包名是 moby（提供 25.0.3）；
#    此前用 `dnf install docker` 装到的是编译需要用到的18.09之类的版本，无法满足部署要求
#    （需 ≥ 20.10），且与 moby 包文件冲突，须先卸载再安装：
sudo dnf list installed 'docker*' 'moby*'
sudo dnf remove -y docker docker-client docker-common 2>/dev/null || true
sudo dnf install -y moby moby-engine moby-client containerd
sudo systemctl enable --now docker

docker version
# shell返回 Client / Server 均 ≥ 20.10（aarch64）

# 2) 数据目录 + 镜像加速一次写 kuicbox/docker /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "data-root": "/data/docker",
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
EOF

# 3) 唯一一次重启 Docker（daemon.json 变更必须重启才生效）
sudo systemctl restart docker

# 校验
docker info | grep 'Docker Root Dir'
# shell返回 Docker Root Dir: /data/docker
docker info | grep -A1 'Registry Mirrors'

# 4) 安装 Compose v2
#    Cube 的 MySQL / Redis / MinIO / CoreDNS / WebUI / cube-proxy / cube-lifecycle-manager 等
#    支撑组件全部以 compose 方式启动，必须是 v2；系统自带的 python 版 docker-compose 1.x
#    与新版 python docker SDK 不兼容（报 kwargs_from_env() got an unexpected keyword argument 'ssl_version'）。
sudo curl -fL --retry 3 -o /usr/local/bin/docker-compose \
  https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-aarch64
sudo chmod +x /usr/local/bin/docker-compose
sudo mkdir -p /usr/libexec/docker/cli-plugins
sudo install -m 0755 /usr/local/bin/docker-compose /usr/libexec/docker/cli-plugins/docker-compose

# 校验（两种调用方式都必须落到 v2）
docker compose version       # Docker Compose version v2.x
docker-compose version       # v2.x（/usr/local/bin 优先于 /usr/bin 下的 1.x）
```

### 配置日志轮转（可选）

防止CubeSandbox服务日志占用空间持续增长，占用磁盘空间，可选择配置日志轮转。

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
logrotate -d /etc/logrotate.d/cube-sandbox   
systemctl is-active crond                    
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 用 `copytruncate` 是因为Cube组件不会因收到信号而重开日志文件句柄；`maxsize 2G` 是硬上限，即使轮转条件未满足，单文件也不会超过该值。

### 安装系统依赖与部署前自检

安装其余系统依赖：

```bash
sudo dnf install -y e2fsprogs util-linux iproute procps-ng curl tar gzip
```

部署前自检，需确保全部自检通过：

```bash
ls /dev/kvm                                                   # 必须存在，否则无法创建沙箱  
df -h /data /home /                                           # 期望： /data为独立数据盘
findmnt -no FSTYPE /data || findmnt -no FSTYPE /data/cubelet  # 期望: /data 或 /data/cubelet 其一为 XFS
docker info | grep 'Docker Root Dir'                          # 期望: /data/docker
docker compose version                                        # 期望: Docker Compose version v2.x
ls -ld /usr/local/services/cubetoolbox/cubebox_os_image \
       /usr/local/services/cubetoolbox/cube-snapshot          # 期望: 均不存在；若为软链接需先删除（见下文）
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 若两处 `findmnt` 返回的都不是xfs，`install.sh` 会直接终止并给出 `Cube Sandbox requires the /data/cubelet directory to reside on an XFS filesystem`。

若目标机之前部署过 CubeSandbox，并且执行过下文的[迁移CubeSandbox工作目录](#迁移CubeSandbox工作目录)，`/usr/local/services/cubetoolbox` 下会残留 `cubebox_os_image` 和 `cube-snapshot` 两个软链接。重新部署时安装脚本会因目录已存在或类型冲突而失败，需先删除这两个软链接再继续：

```bash
sudo rm -f /usr/local/services/cubetoolbox/cubebox_os_image \
           /usr/local/services/cubetoolbox/cube-snapshot
```

`rm -f` 只删除软链接本身，不会删除 `/data/cube-sandbox` 下的真实数据。安装完成后如需继续使用原数据盘，重新执行[迁移CubeSandbox工作目录](#迁移CubeSandbox工作目录)一节即可恢复软链接。

### 解压发布包

```bash
mkdir -p /home/cube-sandbox/bundle && cd /home/cube-sandbox/bundle
tar -xzf ~/cube-workspace/CubeSandbox/deploy/one-click/dist/cube-sandbox-one-click-\<version\>.tar.gz
```

### 配置 .env

```bash
cd /home/cube-sandbox/bundle/cube-sandbox-one-click-<version>
cp env.example .env
```

编辑 `.env`，至少确认以下项：

```bash
# 本机内网 IP；不设置时自动探测 eth0
CUBE_SANDBOX_NODE_IP=<本机IP>

# 沙箱网段：必须避开物理网段（物理网段为 192.168.x.x 时改用 10.100.0.0/16）
CUBE_SANDBOX_NETWORK_CIDR=10.100.0.0/16

# 宿主机会监听10000~19999端口，随机分配给socket，需把WEB_UI_HOST_PORT从12088改成10000~19999范围之外的端口。
# 需确定8088端口未被占用，若8088端口已被占用，可改为其他未被使用的临时端口
WEB_UI_HOST_PORT=8088
```

### 执行安装

```bash
sudo ./install.sh --mode=install
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> - 目标机已存在CubeSandbox时，不带 `--mode` 的 `./install.sh` 默认走「保留配置的升级」。**从零部署必须显式指定 `--mode=install`**。

### 配置 CoW defrag（模板/快照整理，可选）<a id="配置CoW-defrag"></a>

CoW defrag 用于在模板构建、快照生成后对 CoW 层 rootfs 做一次顺序重写，降低派生沙箱的随机读放大；不做该配置不影响功能，仅影响性能。

前置条件：`Cubelet` 二进制已包含 Kbox 的 COW defrag 补丁（`patchForCube/0008-cubelet-cow-defrag.patch`），即使用本文档构建流程产出的发布包；官方原始 v0.7.1 包不含该补丁。

编辑 `/usr/local/services/cubetoolbox/Cubelet/config/config.toml`，在文件末尾追加（已存在则确认取值）：

```toml
[plugins."io.cubelet.internal.v1.storage".cow.defrag]
enable = true
template = true
snapshot = true
min_extents = 64
max_allocated_mib = 2048
timeout_seconds = 60
```

| 字段 | 作用 |
| ---- | ---- |
| enable | defrag 总开关 |
| template | 模板创建路径上的 CoW 层整理 |
| snapshot | 快照创建路径上的 CoW 层整理 |
| min_extents | 触发整理的最小 extent 数，默认 64 |
| max_allocated_mib | 单次整理允许处理的最大分配量（MiB），默认 2048 |
| timeout_seconds | 单次整理超时（秒），默认 60 |

修改后重启 cubelet 生效：

```bash
sudo systemctl restart cube-sandbox-cubelet.service
```

cubelet 冷启动约需 180–260 秒，`systemctl is-active` 不能作为就绪依据，以 9998 端口开始监听为准。确认配置已被加载：

```bash
grep -A7 "cow.defrag" /usr/local/services/cubetoolbox/Cubelet/config/config.toml
grep -h "cow defrag: config" /data/log/Cubelet/Cubelet-req.log | tail -1
ss -ltn | grep -E ":9998|:9999|:9966"
```

期望日志形如：

```text
cow defrag: config enable=true template=true snapshot=true min_extents=64 max_allocated_mib=2048 timeout_seconds=60
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> - Cubelet 侧开关只是允许整理；模板/快照是否需要整理，还由 `redroid_operation.sh` 读取的 `redroid_config.conf` 中 `TPL_COW_DEFRAG`、`SNAP_COW_DEFRAG` 控制（默认均为 1），用法见[用户指南](user_guide.md)的「模板与快照的 CoW defrag」章节。
> - 重新执行 `install.sh` 会重置 `config.toml`，升级或重装后需重新追加上述配置并重启 cubelet。
> - 每个整理对象在 Cubelet 日志中会留下 `cow defrag: candidate scope=... requested=true effective=true` 记录；只有日志中出现该行，才表示本次模板/快照真正执行了整理。

### 迁移CubeSandbox工作目录<a id="迁移CubeSandbox工作目录"></a>

`CubeSandbox`工作目录中的`cubebox_os_image`和`cube-snapshot`两个目录会随着加载镜像和沙箱数快速增长，建议迁移到磁盘空间充足的分区，本文档以/data目录为例。

```bash
TC=/usr/local/services/cubetoolbox

sudo systemctl stop cube-sandbox-control.target

for d in cubebox_os_image cube-snapshot; do
  src="$TC/$d"; dst="/data/cube-sandbox/$d"      
  [ -L "$src" ] && continue
  sudo mkdir -p "$dst"
  [ -d "$src" ] && sudo cp -a "$src/." "$dst/" && sudo rm -rf "$src"
  sudo ln -s "$dst" "$src"
done

ls -ld "$TC"/cubebox_os_image "$TC"/cube-snapshot    # 期望: 均指向 /data/cube-sandbox/...
sudo systemctl start cube-sandbox-control.target
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 若`cubebox_os_image`尚不存在（首次模板构建时才生成），脚本会自动创建目标目录并建链，无数据损失。

### 一键健康校验

```bash
bash ~/cube-workspace/Kbox-patches/deploy/cube_healthcheck.sh
```

或者进入工作区路径

```bash
cd ~/cube-workspace/Kbox-patches/deploy

sudo bash cube_healthcheck.sh                        
sudo bash cube_healthcheck.sh --sandbox 10.100.xx.xx  # 具体某一个沙箱
```
