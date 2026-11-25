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

## 配置BIOS

### 配置BIOS（鲲鹏920新型号）

1. 进入BIOS设置界面后，先按“F9”恢复默认设置。
2. 切换到“Advanced”页签，进入“Memory Configuration”页面：
   - 将“Memory Frequency”设置为“4800”。
   - 将“NUMA”设置为“Enabled”。
   - 将“One Numa Per Socket”设置为“Disabled”。
3. 返回上一页，进入“Power And Performance Configuration”页面：
   - 将“Power Policy”设置为“Performance”。该项对性能影响较大。
   - 进入“CPU PM Control”，将“SMT2”设置为“Enabled”。
4. 返回“Advanced”初始界面，进入“MISC Configuration”页面：
   - 将“Smmu”设置为“Disabled”。
5. 保存BIOS配置并退出设置界面。

配置项汇总：

|页面|配置项|设置值|
|---|---|---|
|Memory Configuration|Memory Frequency|4800|
|Memory Configuration|NUMA|Enabled|
|Memory Configuration|One Numa Per Socket|Disabled|
|Power And Performance Configuration|Power Policy|Performance|
|CPU PM Control|SMT2|Enabled|
|MISC Configuration|Smmu|Disabled|

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 不同BIOS版本的菜单名称可能略有差异，请以实际界面为准。

### 配置BIOS（鲲鹏950）

1. 进入BIOS设置界面后先按“F9”恢复默认设置。
2. 手动调整以下配置项：
   - 切换到“Advanced”页签，进入“Memory Configuration”页面，将“Memory Frequency”设置为“6400”。
3. 以下配置项在按F9恢复默认后通常已正确，需逐项确认：
   - “Advanced > Processor Configuration > Processor Information”页面：将“TDP”设置为“440W”。
   - “Advanced > Processor Configuration > Memory Configuration”页面：将“Custom Refresh”设置为“Enabled”。
   - “Advanced > Memory Configuration”页面：将“Custom Refresh Rate”设置为“Auto”。
   - “Advanced > Power And Performance Configuration”页面：将“Power Policy”设置为“Performance”。
   - “Advanced > Power And Performance Configuration > CPU PM Control”页面：将“HiBoost”和“SMT2”设置为“Enabled”。
   - “Advanced > MISC Configuration”页面：将“Support Smmu”设置为“Disabled”。
4. 保存BIOS配置并退出设置界面。

配置项汇总：

|页面|配置项|设置值|
|---|---|---|
|Advanced > Memory Configuration|Memory Frequency|6400|
|Advanced > Processor Configuration > Processor Information|TDP|440W|
|Advanced > Processor Configuration > Memory Configuration|Custom Refresh|Enabled|
|Advanced > Memory Configuration|Custom Refresh Rate|Auto|
|Advanced > Power And Performance Configuration|Power Policy|Performance|
|Advanced > Power And Performance Configuration > CPU PM Control|HiBoost|Enabled|
|Advanced > Power And Performance Configuration > CPU PM Control|SMT2|Enabled|
|Advanced > MISC Configuration|Support Smmu|Disabled|

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 不同BIOS版本的菜单名称可能略有差异，请以实际界面为准。

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

## 系统调优配置与Numa亲和

本节配置为一次性固化，机器重启后由systemd自动执行，无需每次重启后手工运行脚本。以下命令以root用户执行一次。

### 配置方法

1. 将Kbox-patches仓`deploy`目录下的`os_tune.sh`复制到稳定路径。

    ```bash
    install -m 755 ~/cube-workspace/Kbox-patches/deploy/os_tune.sh /usr/local/sbin/cube-os-tune.sh
    ```

    >![](./public_sys-resources/icon-note.gif) **说明：**
    >
    > 脚本路径以实际Kbox-patches克隆目录为准。

2. 将可通过sysctl接口配置的3项写入`/etc/sysctl.d/99-cube-density-os-tune.conf`，使开机早期生效。

    ```bash
    cat >/etc/sysctl.d/99-cube-density-os-tune.conf <<'EOF'
    kernel.numa_balancing = 0
    kernel.sched_cluster = 1
    vm.zone_reclaim_mode = 1
    EOF
    ```

3. 创建systemd oneshot服务，在`tuned.service`之后重新施加全部 5 项 OS + 3 项 TLBI 调优。`tuned`的`throughput-performance`策略可能在开机时把THP改回`never`、把`numa_balancing`改回原值，因此需要在`tuned`之后执行。

    ```bash
    cat >/etc/systemd/system/cube-os-tune.service <<'EOF'
    [Unit]
    Description=CubeSandbox OS tuning (persistent)
    After=tuned.service systemd-modules-load.service

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=/usr/local/sbin/cube-os-tune.sh

    [Install]
    WantedBy=multi-user.target
    EOF
    ```

4. 启用服务并立即执行一次。

    ```bash
    systemctl daemon-reload
    systemctl enable --now cube-os-tune.service
    systemctl status cube-os-tune.service --no-pager
    ```

脚本包含 5 项 OS 调优 + 3 项 TLBI 调优：

|配置项|作用|
|---|---|
|kernel.numa_balancing=0|关闭auto-numa自动页迁移|
|kernel.sched_cluster=1|启用鲲鹏cluster级调度|
|transparent_hugepage=madvise|大页从always退回madvise|
|vm.zone_reclaim_mode=1|内存回收优先在本zone内完成|
|kvm.halt_poll_ns=0|关闭vCPU空转轮询|
|kvm-arm.tlbi_ipi=1|开启KVM Stage-2 TLBI IPI优化|
|kvm-arm.tlbi_ipi_lazy=1|允许延迟合并TLBI IPI|
|arm64_tlbi_ipi.flags=31|打开全部TLBI IPI标志（现行基线）|

> ![](./public_sys-resources/icon-note.gif) **说明：**
>
> `kernel.numa_balancing`、`kernel.sched_cluster`、`vm.zone_reclaim_mode`有sysctl接口，提前写入`sysctl.d`；大页、`halt_poll_ns` 和 3 项 TLBI 通过oneshot服务在开机后施加。
>
> TLBI 3 项与「编译内核」章节的 `KVM_ARM_TLBI_IPI`、`ARM64_TLBI_IPI` 配套。脚本会先尝试 `modprobe kvm-arm`、`modprobe arm64_tlbi_ipi` 加载参数所在模块，再写入 `/sys/module/kvm-arm/parameters/tlbi_ipi`、`tlbi_ipi_lazy` 和 `/sys/module/arm64_tlbi_ipi/parameters/flags`；写入失败时提示模块未加载或内核未包含 TLBI 优化，不得在未生效的环境上继续性能测试。

### 回读确认

```bash
cat /proc/sys/kernel/numa_balancing                       # 0
cat /proc/sys/kernel/sched_cluster                        # 1
cat /sys/kernel/mm/transparent_hugepage/enabled           # [madvise]
cat /proc/sys/vm/zone_reclaim_mode                        # 1
cat /sys/module/kvm/parameters/halt_poll_ns               # 0
cat /sys/module/kvm-arm/parameters/tlbi_ipi               # Y 或 1
cat /sys/module/kvm-arm/parameters/tlbi_ipi_lazy          # Y 或 1
cat /sys/module/arm64_tlbi_ipi/parameters/flags           # 31
```

预期结果依次为：`0`、`1`、`always [madvise] never`、`1`、`0`、`Y/1`、`Y/1`、`31`。

> ![](./public_sys-resources/icon-note.gif) **说明：**
>
> 本节为一次性固化配置，机器重启后由`cube-os-tune.service`自动执行，无需重复执行本节命令。

## 编译与安装Host内核

### 获取内核源码和补丁

#### 获取内核源码

使用src.rpm获取与当前系统版本一致的内核源码。

```bash
# 安装依赖
dnf install -y bc bison flex openssl-devel elfutils-libelf-devel dwarves gcc make

# 下载内核源码包：src.rpm，下载到当前路径
mkdir -p ~/cube-workspace/oe_kernel_src_rpm
cd ~/cube-workspace/oe_kernel_src_rpm
dnf download "https://repo.openeuler.org/openEuler-24.03-LTS-SP3/update/source/Packages/kernel-6.6.0-145.3.34.165.oe2403sp3.src.rpm"

# 解压展开内核源码
rpm -ivh ./kernel-6.6.0-145.3.34.165.oe2403sp3.src.rpm
rpmbuild -bp --nodeps /root/rpmbuild/SPECS/kernel.spec

# 进入展开后的源码目录
cd /root/rpmbuild/BUILD/kernel-6.6.0/linux-6.6.0-145.3.34.165.aarch64
```

#### 获取内核补丁并应用

`dev_AndroidSandbox`分支已包含`patchForKernel/openEuler_6.6.0-145.3.34/`补丁目录。使用“获取Kbox软件包”章节已克隆的Kbox-patches仓库，更新代码后合入内核补丁。

```bash
cd /root/rpmbuild/BUILD/kernel-6.6.0/linux-6.6.0-145.3.34.165.aarch64
for p in ~/cube-workspace/Kbox-patches/patchForKernel/openEuler_6.6.0-145.3.34/*.patch; do
    patch -p1 < "$p" || exit 1
done
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 补丁路径以实际Kbox-patches克隆目录为准。src.rpm展开后的源码目录不是git仓库，使用`patch -p1`合入补丁。

### 编译和安装内核

#### 配置内核

1. 使用SP3发行配置作为基础配置：

    ```bash
    cp /boot/config-6.6.0-145.3.34.165.oe2403sp3.aarch64 .config
    ```

2. 使用`scripts/config`统一配置以下内核选项，并生成`.config`：

    ```bash
    ./scripts/config --enable KVM_ARM_TLBI_IPI
    ./scripts/config --enable ARM64_TLBI_IPI
    ./scripts/config --set-str SYSTEM_TRUSTED_KEYS ""
    make olddefconfig
    ```

    |配置项|说明|.config中预期结果|
    |---|---|---|
    |KVM_ARM_TLBI_IPI|开启KVM Stage-2 range失效IPI优化|`CONFIG_KVM_ARM_TLBI_IPI=y`|
    |ARM64_TLBI_IPI|开启Host Stage-1 TLB失效IPI优化|`CONFIG_ARM64_TLBI_IPI=y`|
    |SYSTEM_TRUSTED_KEYS|清空证书路径，避免编译报错|`CONFIG_SYSTEM_TRUSTED_KEYS=""`|

3. 回读确认配置结果。

    ```bash
    grep -E '^CONFIG_KVM_ARM_TLBI_IPI=|^CONFIG_ARM64_TLBI_IPI=|^CONFIG_SYSTEM_TRUSTED_KEYS=' .config
    ```

    预期输出：

    ```text
    CONFIG_KVM_ARM_TLBI_IPI=y
    CONFIG_ARM64_TLBI_IPI=y
    CONFIG_SYSTEM_TRUSTED_KEYS=""
    ```

#### 编译内核

进入内核工作目录后执行编译。

```bash
cd /root/rpmbuild/BUILD/kernel-6.6.0/linux-6.6.0-145.3.34.165.aarch64
make -j64
```

#### 安装内核

确认`vmlinux`和`arch/arm64/boot/Image`已生成后，执行安装。

```bash
make modules_install
make install
```

安装成功后重启，确认进入新编译的内核：

```bash
reboot
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 重启后执行`uname -r`，返回版本应与本次编译的内核版本一致。

## 修改本机网络配置

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

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 如需部署在鲲鹏 PVM（嵌套虚拟化）环境（L1 虚拟机内作为 CubeSandbox 宿主），请参见下文 [PVM（鲲鹏嵌套虚拟化）方案](#pvm鲲鹏嵌套虚拟化方案)，使用 `build-cube-pvm.sh` 构建已内置 PVM L2 内核的发布包。

## 部署CubeSandbox

### `/data` 目录配置<a id="data目录配置"></a>

CubeSandbox工作路径在`/data`，其中`/data/cubelet`目录必须位于xfs文件系统，`/data`其余目录可使用ext4。为保证沙箱性能，`/data`、`/data/cubelet`目录需挂载到固态硬盘，此处以4TB NVMe固态硬盘（`nvme0n1`）为例，将单块NVMe物理盘划分为两个逻辑分区，示例按整盘3:1划分（约`/data` 3T、`/data/cubelet` 1T），实际容量可根据业务需求调整。

如未安装分区与文件系统工具，先执行`dnf install -y parted e2fsprogs xfsprogs`。

```bash
# 示例：nvme0n1p1 -> /data（ext4，约3T），nvme0n1p2 -> /data/cubelet（xfs，约1T）
# 该操作会销毁 /dev/nvme0n1 上的所有数据，请确认数据已备份
umount /dev/nvme0n1p1 /dev/nvme0n1p2 2>/dev/null || true
parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart data ext4 1MiB 75%
parted -s /dev/nvme0n1 mkpart cubelet xfs 75% 100%
partprobe /dev/nvme0n1

mkfs.ext4 -F /dev/nvme0n1p1
mkfs.xfs -f /dev/nvme0n1p2

mkdir -p /data /data/cubelet
mount /dev/nvme0n1p1 /data
mount /dev/nvme0n1p2 /data/cubelet
```

建议将分区挂载持久化配置到`/etc/fstab`文件，以实现开机自动挂载磁盘。推荐使用分区UUID进行配置，可避免设备名（如`/dev/nvme0n1p1`）在重启或硬盘增减后发生变化导致挂载失败。先查询分区UUID：

```bash
blkid /dev/nvme0n1p1 /dev/nvme0n1p2
# 返回示例：
# /dev/nvme0n1p1: UUID="e7398a6b-XXXX-XXXX-XXXX-XXXXXXXXXXXX" TYPE="ext4"
# /dev/nvme0n1p2: UUID="f84a9b7c-XXXX-XXXX-XXXX-XXXXXXXXXXXX" TYPE="xfs"
```

将返回的UUID填入`/etc/fstab`，配置示例（`/data`需先于`/data/cubelet`挂载）：

```bash
UUID=e7398a6b-XXXX-XXXX-XXXX-XXXXXXXXXXXX  /data          ext4  defaults,noatime  0 0
UUID=f84a9b7c-XXXX-XXXX-XXXX-XXXXXXXXXXXX  /data/cubelet  xfs   defaults,noatime  0 0
```

校验：

```bash
findmnt -no SOURCE,FSTYPE,TARGET /data
# shell返回 /dev/nvme0n1p1（或按UUID挂载时的/dev/disk/by-uuid/...） ext4 /data
findmnt -no SOURCE,FSTYPE,TARGET /data/cubelet
# shell返回 /dev/nvme0n1p2（或按UUID挂载时的/dev/disk/by-uuid/...） xfs /data/cubelet
df -h /data /data/cubelet
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

### 安装系统依赖与部署前自检<a id="安装系统依赖与部署前自检"></a>

安装其余系统依赖：

```bash
sudo dnf install -y e2fsprogs xfsprogs parted util-linux iproute procps-ng curl tar gzip
```

部署前自检，需确保全部自检通过：

```bash
ls /dev/kvm                                                   # 必须存在，否则无法创建沙箱  
df -h /data /home /                                           # 期望： /data为独立数据盘
findmnt -no FSTYPE /data/cubelet                              # 期望: xfs
docker info | grep 'Docker Root Dir'                          # 期望: /data/docker
docker compose version                                        # 期望: Docker Compose version v2.x
ls -ld /usr/local/services/cubetoolbox/cubebox_os_image \
       /usr/local/services/cubetoolbox/cube-snapshot          # 期望: 均不存在；若为软链接需先删除（见下文）
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 若 `/data/cubelet` 不在xfs文件系统上，`install.sh` 会直接终止并给出 `Cube Sandbox requires the /data/cubelet directory to reside on an XFS filesystem`。

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

### 配置节点配额

高密度创建沙箱时，如果CubeMaster返回`ret_code=130597`（`no more resource`），说明节点调度配额不足。可使用`fix_node_quota.sh`修改Cubelet的`host.quota.mcpu_limit`和`mem_limit`，并向CubeOps重放节点注册，使新配额立即生效，无需重启Cubelet。

脚本位于Kbox-patches仓的`deploy/`目录。以root用户执行：

#### 默认配额

```bash
bash ~/cube-workspace/Kbox-patches/deploy/fix_node_quota.sh
```

默认配额为`mcpu_limit=2560000`（2560核，可容纳640个4C沙箱）、`mem_limit=3500000Mi`。

#### 配置示例

以4C8G起500路为例，按以下参数执行：

```bash
QUOTA_CPU=2000000 QUOTA_MEM=4096000Mi bash ~/cube-workspace/Kbox-patches/deploy/fix_node_quota.sh
```

计算方式如下：

|资源|单实例|500路|说明|
|---|---|---|---|
|CPU|4C=4000 mcpu|500×4000=2000000 mcpu|`QUOTA_CPU`单位为mcpu|
|内存|8G=8192Mi|500×8192=4096000Mi|`QUOTA_MEM`必须为`<数字>Mi`|

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 脚本默认`QUOTA_MEM=3500000Mi`，按8G/实例计算只能容纳约427路；4C8G起500路时必须显式提高内存配额。默认`QUOTA_CPU=2560000`可容纳640个4C沙箱，CPU不是瓶颈。

如需为系统预留余量，可适当上调，例如：

```bash
QUOTA_CPU=2200000 QUOTA_MEM=4500000Mi bash ~/cube-workspace/Kbox-patches/deploy/fix_node_quota.sh
```

配额是调度上限，不等于物理资源；CPU可按密度测试策略超分，但需确认节点实际资源和调度策略能够承载。

#### 参数说明

|环境变量|默认值|说明|
|---|---|---|
|QUOTA_CPU|2560000|`host.quota.mcpu_limit`，单位mcpu|
|QUOTA_MEM|3500000Mi|`host.quota.mem_limit`，必须为`<数字>Mi`|
|CUBELET_CONF|/usr/local/services/cubetoolbox/Cubelet/dynamicconf/conf.yaml|Cubelet动态配置文件|
|CUBEOPS_ADDR|`http://127.0.0.1:3010`|CubeOps地址|
|NODE_ID|空|多节点时指定节点；默认要求仅有一个节点|

#### 验证

脚本执行完成后会打印新配额和CubeOps节点视图。也可手动查询：

```bash
grep -nE '^[[:space:]]*(mcpu_limit|mem_limit):' /usr/local/services/cubetoolbox/Cubelet/dynamicconf/conf.yaml
curl -s http://127.0.0.1:3010/internal/v1/nodes | python3 -m json.tool | grep -E '"QuotaCpu"|"QuotaMem"'
```

确认`QuotaCpu`、`QuotaMem`与本次传入的`QUOTA_CPU`、`QUOTA_MEM`一致（默认分别为`2560000`、`3500000`；4C8G起500路示例分别为`2000000`、`4096000`）后，重新创建4C8G沙箱，确认不再返回130597。

## PVM方案部署<a id="pvm鲲鹏嵌套虚拟化方案"></a>

本章节介绍在鲲鹏物理服务器上部署PVM嵌套虚拟化方案的完整步骤，涵盖L1虚拟机创建、PVM L1与L2内核构建、L1环境部署与验证，适用于需要在鲲鹏服务器上搭建CubeSandbox沙箱环境的用户。

```text
L0：鲲鹏物理服务器
  |
  +-- L1：openEuler虚拟机 + PVM L1 内核
        |
        +-- L2：CubeSandbox Redroid 沙箱 + PVM L2 内核
```

与裸机方案相比增加了L1虚拟机，部署环节的主要差异点为以下2个制品：**PVM L1 内核**（`kernel-<ver>.aarch64.rpm`）和 **PVM L2 内核**（`vmlinux-pvm`）。其余步骤与裸机方案一致，可自行参考对应章节。

### 创建 L1 虚拟机（在L0执行）

#### 安装虚拟化组件

```bash
dnf install -y qemu libvirt edk2-aarch64 virt-install
systemctl enable --now libvirtd
virsh net-list --all            # default 需 active，否则 virsh net-start default
```

下载 `openEuler-24.03-LTS-SP3-aarch64-dvd.iso` 到 L0 的 `/home/` 选择Offline Standard ISO（下载页：<https://www.openeuler.org/zh/download/>）：

```bash
cd /home
curl -LO https://repo.openeuler.org/openEuler-24.03-LTS-SP3/ISO/aarch64/openEuler-24.03-LTS-SP3-aarch64-dvd.iso
```

#### 创建磁盘与虚拟机

```bash
mkdir -p /home/images
qemu-img create -f qcow2 /home/images/img.qcow2 100G     # 系统盘，可按需要设置大小
qemu-img create -f qcow2 /home/images/data.qcow2 300G    # 数据盘，可按需要设置大小

virt-install --name=pvm-l1 --vcpus=16 --ram=32768 \
  --cpu host-passthrough --osinfo openeuler24.03 --boot uefi \
  --disk path=/home/images/img.qcow2,format=qcow2,bus=virtio \
  --disk path=/home/images/data.qcow2,format=qcow2,bus=virtio \
  --location /home/openEuler-24.03-LTS-SP3-aarch64-dvd.iso \
  --extra-args 'console=ttyAMA0,115200 inst.text' \
  --network network=default,model=virtio \
  --nographics --noautoconsole
```

虚拟机已在后台启动，用串口控制台进入安装界面：

```bash
virsh console pvm-l1
# 连接后若黑屏，按回车刷新出 anaconda 文本安装界面
# 退出控制台：Ctrl + ]
# 若提示 Active console session exists：virsh console pvm-l1 --force
```

请自行安装L1虚拟机OS。

#### 安装后检查

```bash
# 1) 检查域 XML 是否残留 <kernel>/<initrd>/<cmdline>
#    作用：virt-install --location 安装时会把 ISO 内的内核写入域配置，装完若不清理，
#          下次启动仍从 ISO 引导，而不是从 L1 系统盘引导。
virsh dumpxml pvm-l1 | grep -E '<kernel|<initrd|<cmdline' #    预期输出：空（无任何匹配行）
#    若上面有输出：执行 virsh edit pvm-l1，删除这三行后保存；再 virsh destroy pvm-l1 && virsh start pvm-l1

# 2) 查询 L1 的 IP，后续所有 L1 操作都通过该地址进行
virsh domifaddr pvm-l1  # 预期输出：ipv4 192.168.122.x/24
```

### 构建CubeSandbox和L1、L2内核（在L0执行）

#### 准备 PVM 内核源码

```bash
cd ~/cube-workspace
git clone https://gitcode.com/boostkit/pvm.git pvm-OLK6.6
cd pvm-OLK6.6
git checkout 6f549048513c39fa44f1dc9e38df3bfc967082a6
```

#### 执行构建

安装依赖：

```bash
sudo dnf install -y gcc gcc-c++ make flex bison \
  openssl-devel elfutils-libelf-devel rpm-build bc perl tar xz cpio dwarves python3
```

可覆盖的环境变量：

| 变量 | 默认值 | 说明 |
| -- | -- | -- |
| PVM_SRC | \<工作区\>/pvm-OLK6.6 | PVM 内核源码目录 |
| PVM_OUT | $PVM_SRC/_output | 编译输出根目录（l1/l2 子目录） |
| PVM_BUILD_JOBS | nproc | 编译并发数 |
| CUBE_SRC | \<工作区\>/CubeSandbox | CubeSandbox 源码目录 |
| PATCH_DIR | \<Kbox 目录\>/patchForCube | CubeSandbox/Kbox 通用 patch 目录 |
| PVM_L2_CONFIG | \<Kbox\>/patchForKernel/cube_pvm_openEuler_OLK-6.6/pvm_l2.config | L2 内核配置（可直接编辑） |
| PVM_KERNEL_PATCH_DIR | \<Kbox\>/patchForKernel/cube_pvm_openEuler_OLK-6.6 | L2 源码补丁目录，编译前自动合入 |
| SKIP_L1_CONFIG_CHECK | 未设置 | 设为 1 跳过 L1 宿主功能配置核对 |

```bash
cd ~/cube-workspace/Kbox-patches/build
./build-cube-pvm.sh all

# 或分步
./build-cube-pvm.sh check-config   # 核对 L1 .config 的宿主功能配置
./build-cube-pvm.sh pvm-l1         # 编译 PVM L1 内核 RPM
./build-cube-pvm.sh pvm-l2         # 编译 L2 Image 并放入发布包内核输入目录
./build-cube-pvm.sh bundle         # 打包
```

构建完成后，将构建产物传输至L1虚拟机以供后续使用

产物：

| 产物 | 路径 |
| -------- | ---------------------------------------------------------------- |
| PVM L1 内核 RPM | pvm-OLK6.6/_output/l1/rpmbuild/RPMS/aarch64/kernel-\<ver\>.aarch64.rpm |
| PVM L2 guest 内核 | CubeSandbox/deploy/one-click/assets/kernel-artifacts/vmlinux-pvm |
| 发布包（PVM-ready） | CubeSandbox/deploy/one-click/dist/cube-sandbox-one-click-\<version\>.tar.gz |

### L1虚拟机环境部署（在L1执行）

#### 安装 PVM L1 内核

脚本需运行两次：第1次安装内核RPM包并设为默认内核，第2次（重启后）加载`kvm_pvm`并验证`/dev/kvm`。

```bash
# 准备工作路径和文件
mkdir ~/cube-workspace
# 将以下2个文件传输到该目录
# 1、Kbox-patches/deploy/install-pvm-l1.sh
# 2、pvm-OLK6.6/_output/l1/rpmbuild/RPMS/aarch64/kernel-*.aarch64.rpm

# 第 1 次（安装内核 + 设置为默认内核）
sudo bash install-pvm-l1.sh ./kernel-6.6.0-*.aarch64.rpm
sudo reboot

# 重启后第 2 次（加载 kvm_pvm + 验证）
sudo bash install-pvm-l1.sh ./kernel-6.6.0-*.aarch64.rpm
```

第 2 次运行输出 `L1 PVM 状态验证全部通过` 即完成（`kvm_pvm` 已加载并配置开机自动加载）。RPM 缺省时脚本自动探测当前目录下唯一的 `kernel-*.aarch64.rpm`。

#### 安装 CubeSandbox

请在安装前，确保完成以下前置步骤：

- [配置`/data`目录](#data目录配置)。
- [安装并配置Docker](#安装并配置Docker)。
- [安装系统依赖](#安装系统依赖与部署前自检)。

安装CubeSandbox

```bash
tar -xzf cube-sandbox-one-click-<version>.tar.gz
sudo bash install-cube-pvm.sh ./cube-sandbox-one-click-<version>
```

**安装常见问题**

1）无外网时卡在 `[s3-deps] install jq` 
请排查L0,L1的 net.ipv4.ip_forward 是否为1

```bash
sysctl -n net.ipv4.ip_forward   # 期望输出 1
#若不为 1 分别在L0 L1 执行下述指令，配置 net.ipv4.ip_forward 为 1 
sudo sed -i 's/^net.ipv4.ip_forward=0$/net.ipv4.ip_forward=1/' /etc/sysctl.conf # 或者vim修改
sudo sysctl -p
sysctl -n net.ipv4.ip_forward   # 期望输出 1
```

#### 验证

```bash
bash ~/Kbox-patches/deploy/cube_healthcheck.sh     # 期望全部通过

uname -r                                           # 预期与所装 PVM 内核版本一致， 6.6.0+
lsmod | grep '^kvm_pvm'                            # 预期输出 kvm_pvm 行，且被引用计数 > 0
grep '^CUBE_PVM_ENABLE=1' /usr/local/services/cubetoolbox/.one-click.env   # CUBE_PVM_ENABLE=1
readlink -f /usr/local/services/cubetoolbox/cube-kernel-scf/vmlinux   # 必须指向 /usr/local/services/cubetoolbox/cube-kernel-scf/vmlinux-pvm
```

## 修订记录

|文档版本|发布日期|修改说明|
|--|--|--|
|01|2026-12-30|第一次正式发布。|
