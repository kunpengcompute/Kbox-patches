# 安装指南

## 环境准备

### 硬件环境

| 配置项 | 硬件配置方案一 | 硬件配置方案二 |
| ---- | ---- | ---- |
| CPU  | 2*鲲鹏920 7280Z处理器，80核，2.9Ghz | 2*鲲鹏950 7592C处理器，96核，2.3Ghz |
| 内存 | 16*DDR5 DIMM内存-64GB-4800MT/s | 24*DDR5 DIMM内存-64GB-6400MT/s |
| 操作系统 | openEuler 24.03 LTS SP3 | openEuler 24.03 LTS SP3 |

### 软件环境

|序号|软件|说明|获取地址|
| ---- | ---- | ---- | ---- |
|1| CubeSandbox源码 | 版本：v0.7.1 | [下载连接](https://gitcode.com/boostkit/CubeSandbox.git) |
|2| Kbox-patches-dev_AndroidSandbox.zip | Kbox AOSP补丁、脚本Demo包 | [获取链接](https://gitcode.com/boostkit/Kbox-patches.git)<br>分支：dev_AndroidSandbox |
|3| OpenCloud OS内核源码 | 版本：6.6.119-49.6 | [下载连接](https://gitee.com/OpenCloudOS/OpenCloudOS-Kernel.git) |

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

## 构建CubeSandbox和Guest内核

### 一键构建<a id="一键构建"></a>

根据实际环境配置环境变量：

| 变量 | 默认值 | 说明 |
| -- | -- | -- |
| CUBE_SRC | ~/CubeSandbox | CubeSandbox源码目录 |
| KERNEL_SRC | ~/opencloudos-kernel | guest内核源码目录 |

```bash
cd ~/cube-workspace/Kbox-patches/build
./build-cube.sh all
```

### 分步构建

本脚本提供分布构建能力，若已执行[一键构建](#一键构建)则可跳过本章节。

```bash
cd ~/cube-workspace/Kbox-patches/build
./build-cube.sh patch     # 1) 合入 patchForCube/ 下的 6 个 patch
./build-cube.sh kernel    # 2) 编译 guest 内核
./build-cube.sh bundle    # 3) 编译 CubeSandbox 一键发布包
```

### 产物与注意事项

| 产物       | 路径                                                                          |
| -------- | --------------------------------------------------------------------------- |
| guest内核 | CubeSandbox/_output/kernel/aarch64/vmlinux                                |
| 发布包      | CubeSandbox/deploy/one-click/dist/cube-sandbox-one-click-\<version\>.tar.gz |

## 部署CubeSandbox

### `/data` 目录配置

CubeSandbox工作路径在`/data`，文件格式需要为xfs。建议在安装系统时给/data目录划分足够的空间（分区大小可根据需要酌情配置，建议>200GB），或者参考下文将一块独立的nvme硬盘挂载到该路径，以方便灵活配置。下文以`nvme0n1`为例，请根据实际磁盘名称替换相关字段：

```bash
umount /dev/nvme0n1 2>/dev/null || true
mkfs.xfs -f /dev/nvme0n1
mkdir -p /data
mount /dev/nvme0n1 /data
```

建议将磁盘挂载持久化配置到`/etc/fstab`文件，以实现开机自动挂载磁盘。配置示例：

```bash
/dev/nvme0n1                    /data  xfs  defaults,noatime       0 0
```

校验：

```bash
findmnt -no SOURCE,FSTYPE,TARGET /data
# shell返回 <设备或镜像> xfs /data
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
# 1) 安装 Docker：
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
curl -fL --retry 3 -o /usr/local/bin/docker-compose \
  https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-aarch64
chmod +x /usr/local/bin/docker-compose
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
sudo dnf install -y e2fsprogs util-linux iproute procps-ng curl tar gzip logrotate
```

部署前自检，需确保全部自检通过：

```bash
ls /dev/kvm                                                   # 必须存在，否则无法创建沙箱  
df -h /data /home /                                           # 期望 /data 和/home、/目录不在一个数据盘，/data为独立数据盘
findmnt -no FSTYPE /data || findmnt -no FSTYPE /data/cubelet  # 期望: xfs（/data 或 /data/cubelet 其一为 XFS）
docker info | grep 'Docker Root Dir'                          # 期望: /data/docker
docker compose version                                        # 期望: Docker Compose version v2.x
logrotate -d /etc/logrotate.d/cube-sandbox                    # 期望无 error
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 若两处 `findmnt` 返回的都不是xfs，`install.sh` 会直接终止并给出 `Cube Sandbox requires the /data/cubelet directory to reside on an XFS filesystem`。

### 解压发布包

```bash
mkdir -p /home/cube-sandbox/bundle && cd /home/cube-sandbox/bundle
tar -xzf /path/to/cube-sandbox-one-click-<version>.tar.gz
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

# 把 WEB_UI_HOST_PORT 从 12088 改成 8088（10000~19999 临时端口范围之外）
WEB_UI_HOST_PORT=8088
```

### 执行安装

```bash
sudo ./install.sh --mode=install
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> - 目标机已存在CubeSandbox时，不带 `--mode` 的 `./install.sh` 默认走「保留配置的升级」。**从零部署必须显式指定 `--mode=install`。

### 迁移CubeSandbox工作目录

`CubeSandbox`工作目录中的`cubebox_os_image`和`cube-snapshot`两个目录会随着加载镜像和沙箱数快速增长，建议迁移到磁盘空间充足的分区，本文档以/data目录为例。

```bash
TC=/usr/local/services/cubetoolbox

sudo systemctl stop cube-sandbox-control.target

for d in cubebox_os_image cube-snapshot; do
  src="$TC/$d"; dst="/data/cube-sandbox/$d"          # ← 改这里
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
> `若`cubebox_os_image`尚不存在（首次模板构建时才生成），脚本会自动创建目标目录并建链，无数据损失。

### 一键健康校验

```bash
bash ~/Kbox-patches/deploy/cube_healthcheck.sh
```

或者进入工作区路径

```bash
cd ~/Kbox-patches/deploy

sudo bash cube_healthcheck.sh                        
sudo bash cube_healthcheck.sh --sandbox 10.100.xx.xx  # 具体某一个容器
```
