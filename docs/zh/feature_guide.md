# 特性指南<a name="ZH-CN_TOPIC_0000002552895805"></a>

## 1 特性描述<a name="ZH-CN_TOPIC_0000002518226180"></a>

Kbox云手机容器是鲲鹏BoostKit云手机Turbo套件的核心能力组件，本文介绍了Kbox云手机容器的基本概念，提供Kbox云手机容器的编译、部署及相关配置流程。

云手机是基于ARM服务器虚拟出的带有AOSP （Android Open Source Project，安卓开放源代码项目）系统的虚拟手机服务。简而言之，云手机=ARM服务器+Android OS。您可以远程实时控制云手机，实现Android APP的云端运行；也可以基于云手机的基础算力，高效搭建应用，如云游戏、移动办公、直播互娱等场景。

Kbox云手机容器是鲲鹏BoostKit云手机Turbo套件的重要组成部分，是实现Android应用运行的基础软件。它将AOSP系统直接运行在容器内，实现GPS、加速度传感器、陀螺仪、IMEI、Wi-Fi等外设硬件的数据Mock功能，以及Gralloc&HWComposor模块，确保AOSP系统可以正常启动运行；以及一系列可选特性，用于在各种业务场景下增强云手机功能或性能。

Kbox支持的所有基础功能和可选特性见[**表 1** Kbox基础功能清单](#Kbox基础功能清单)和[**表 2** Kbox可选特性清单](#Kbox可选特性清单)。对于Kbox基础功能，可按照[compile_guild](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/zh/compile_guild.md)与[install_guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/zh/install_guide.md)中描述集成Kbox云手机容器组件，即可支持。可选功能的相关信息在下文章节中详细描述。

**表 1** Kbox基础功能清单<a id="Kbox基础功能清单"></a>

|名称|说明|
|--|--|
|支持Android Kbox云手机容器方案|支持基于openEuler（Host OS）和Android（Guest OS）的Kbox云手机容器参考方案。CTS 兼容性>98%。|
|支持GPU直接渲染和主流的图形API|容器内GPU直接渲染，支持OpenGL ES 2.0/3.0/3.1/3.2和Vulkan 1.1图形API。dEQP兼容性>98%。|
|云手机视频播放支持硬件加速|云手机视频播放支持硬件加速，实现视频播放H.264/H.265解码硬件加速，降低CPU负载，提升媒体场景性能。|
|Kbox内核支持动态开关|提供动态开关实现云手机使用的Host OS镜像可供其他业务共用|
|Gralloc模块支持YCbCr_420_888格式|修改Gralloc模块支持YCbCr_420_888的处理，修复黑屏问题。|
|提供GPU显存、内存等资源监控能力|提供GPU显存、内存等资源的实时监控，便于客户根据资源的使用情况进行相应的处理。|

**表 2** Kbox可选特性清单<a id="Kbox可选特性清单"></a>

|名称|说明|
|--|--|
|支持纹理自适应压缩|基于Mesa开源上实现纹理自适应压缩，支持Vulkan RGB和RGBA纹理转DXT纹理。|
|支持自适应帧同步|实现自适应vsync功能，在应用渲染完成一帧后，Surfaceflinger立即合成上屏。|
|Kbox动态帧率调整|在挂机场景下，云手机与客户端断开连接时，动态向下调整帧率以减少渲染性能开销。|
|Android轻量化裁剪|Android系统的轻量化裁剪通过去除不必要的系统服务和内置应用来降低云手机的资源占用，从而提升系统性能、优化用户体验。|
|Android composer优化|当游戏应用全屏时，仅有游戏应用图层，可以跳过合成步骤，并省略图像由横屏翻转为竖屏的操作，降低GPU的性能开销。|
|支持线程级Shader Cache|通过预构建二进制消除着色器编译链接等处理时间，提升大型应用场景下的渲染效率 。|
|支持F2FS文件格式启动|通过添加配置项支持云手机以f2fs文件格式启动，和真实手机采用一样的文件系统，提高仿真能力|
|支持/system分区大小调节|通过添加配置项支持自主调节云手机容器内/system分区大小，和真机具备相近的/system分区大小，提高仿真能力|

## 2 支持纹理自适应压缩

### 2.1 特性介绍

#### 2.1.1 简介

#### 2.1.2 约束与限制

#### 2.1.3 应用场景

### 2.2 安装特性

### 2.3 使用特性

## 3 自适应帧同步<a name="ZH-CN_TOPIC_0000002549865947"></a>

### 3.1 特性介绍<a name="ZH-CN_TOPIC_0000002549865949"></a>

#### 3.1.1 简介<a name="ZH-CN_TOPIC_0000002549745953"></a>

影响云手机用户体验的关键因素之一是端到端操作时延，而E2E时延主要可以分为3段：云侧时延+网络时延+端侧时延。Kbox云手机方案主要聚焦云侧时延的极致优化。

自适应帧同步特性提供对安卓系统图形渲染流程的优化功能，可在主流场景下优化云侧时延（定义为从触控事件到对应图像编码完成所需要的时间）。

#### 3.1.2 约束与限制<a name="ZH-CN_TOPIC_0000002549865951"></a>

1、自适应帧同步功能打开时，在部分应用场景可能会出现短暂的出流帧率高于容器配置帧率的现象。这是本特性实现方案在多图层渲染场景下的预期内行为，但特性会自动识别该场景并动态使能，因此不会长时间发生这种现象。可通过配置阈值vmi.adaptive.vsync.threshold调节识别的精度，配置值较小时可以降低发生帧率异常冲高现象的概率，但可能导致自适应帧同步的收益不稳定。

#### 3.1.3 应用场景<a name="ZH-CN_TOPIC_0000002518226178"></a>

本特性没有特别的应用场景限制，但在部分场景下可能存在收益不稳定的现象。经过实测，在主流游戏应用场景下，可以取得稳定收益。

### 3.2 安装特性<a name="ZH-CN_TOPIC_0000002518386098"></a>

可按以下步骤集成本特性：

1. 安卓镜像中，合入patchForAndroid15/frameworks/native/frameworks-native-0001.patch（取自Kbox-patches-AOSP15.zip，见[**表 1** Kbox基础功能清单](#Kbox基础功能清单)）
2. 将AdaptiveVsync.kbox.so（取自BoostKit-boostcph-kbox\_\*.zip，见[软件环境](compile_guide.md#Kbox安卓镜像编译构建软件环境要求)）集成至安卓镜像的/system/vendor/lib64/hw/路径下

### 3.3 使用特性<a name="ZH-CN_TOPIC_0000002549745951"></a>

1. 容器配置属性 ro.vmi.adaptive.vsync 为1，即打开特性。
2. 在运行时，观察云机属性vmi.enable.adaptive.vsync的值是否为1，为1时说明特性正在使能，为0时说明为规避帧率冲高现象，暂时去使能特性。

### 3.4 特性收益

在1080P@60fps游戏场景下，优化服务器端时延约10ms。

## 4 Kbox动态帧率调整

### 4.1 特性介绍

#### 4.1.1 简介

#### 4.1.2 约束与限制

#### 4.1.3 应用场景

### 4.2 安装特性

### 4.3 使用特性

## 5 Android轻量化裁剪

### 5.1 特性介绍

#### 5.1.1 简介

#### 5.1.2 约束与限制

#### 5.1.3 应用场景

### 5.2 安装特性

### 5.3 使用特性

## 6 Android composer优化

### 6.1 特性介绍

#### 6.1.1 简介

#### 6.1.2 约束与限制

#### 6.1.3 应用场景

### 6.2 安装特性

### 6.3 使用特性

## 7 支持线程级Shader Cache

### 7.1 特性介绍

#### 7.1.1 简介

#### 7.1.2 约束与限制

#### 7.1.3 应用场景

### 7.2 安装特性

### 7.3 使用特性

## 8 以f2fs文件格式启动<a name="ZH-CN_TOPIC_0000002549865949"></a>

### 8.1 特性介绍<a name="ZH-CN_TOPIC_0000002549865950"></a>

#### 8.1.1 简介<a name="ZH-CN_TOPIC_0000002549745954"></a>

在移动终端硬件领域，F2FS文件格式是现代安卓真机的标准文件系统格式。当前云手机运行在宿主机环境中，文件格式一般是ext4格式，文件格式的不同将显著降低设备的仿真置信度，增加被风控策略拦截的风险。因此，为了提升云手机的仿真度，可以实现云手机容器对 F2FS 格式的底层支持。

#### 8.1.2 约束与限制<a name="ZH-CN_TOPIC_0000002549865959"></a>

1. 内核兼容性限制：宿主机操作系统内核必须包含并启用 F2FS 内核模块支持。若内核缺失相关驱动或编译选项，系统将无法识别并挂载 F2FS 格式的存储介质。
2. 存储资源前置条件：系统环境中必须存在已完成 F2FS 格式化的物理磁盘、分区或逻辑卷设备。该设备需处于可用状态，且具备被挂载至数据卷 data 目录的物理前提。

#### 8.1.3 应用场景<a name="ZH-CN_TOPIC_0000002518226179"></a>

本特性没有特别的应用场景限制

### 8.2 使用介绍<a name="ZH-CN_TOPIC_0000002549865941"></a>

#### 8.2.1  **使用介绍。**

##### 8.2.1.1  环境准备<a name="ZH-CN_TOPIC_000000254986594100"></a>

   确认f2fs工具是否已安装且宿主机内核是否已加载F2FS模块，并安装用户态工具。

   ```shell
   yum install f2fs-tools
   ```

   检查当前内核是否支持f2fs

   ```shell
   cat /proc/filesystems | grep f2fs
   ```

若回显中出现"f2fs"，则直接跳到3.2.1.2章节继续执行。

如果回显为空，说明当前内核不支持f2fs文件格式，则需要重新编一个支持f2fs格式的内核，编译时在”配置内核编译选项“步骤中需要把.config文件里的CONFIG_F2FS_FS设置为Y，重新编内核的步骤可以参照install_guide.md的[编译及安装内核](install_guide.md#ZH-CN_TOPIC_0000002518385420)章节

##### 8.2.1.2 **新建f2fs磁盘并挂载指定目录。**

输入下面命令查找当前环境磁盘情况

   ```shell
   lsblk -f
   ```

如果已经有f2fs格式的硬盘挂载在数据卷目录下的data目录，那么可以直接跳到[使用特性](feature_guide.md#ZH-CN_TOPIC_0000002549745952)章节继续执行

输入如下命令新建物理盘分区

   ```shell
   fdisk /dev/${打算新建分区的物理盘名字}
   ```

系统重新读取分区表

   ```shell
   partprobe /dev/${打算新建分区的物理盘名字}
   ```

将新分区设置为f2fs格式

   ```shell
   mkfs.f2fs /dev/${新创建的逻辑盘名字}
   ```

修改挂载配置文件，确保使用 `f2fs` 类型挂载。
   
输入如下命令编辑挂载信息

   ```shell
   vim /etc/fstab
   ```

输入如下挂载信息

   ```text
   UUID=${新建的f2fs磁盘的uuid信息}$ ${数据卷挂载目录}/data  f2fs defaults
   ```

挂载新分区，使能新分区挂载生效

   ```shell
   mount -a  
   systemctl daemon-reload
   ```

#### 8.2.2 使用特性<a name="ZH-CN_TOPIC_0000002549745952"></a>

1. kbox_config.cfg中的 ENABLE_F2FS负责控制F2FS文件系统开关，默认值是0，0表示不使能。

2. 在容器配置文件kbox_config.cfg中将属性 ENABLE_F2FS设置为1，即打开特性。

3. 在容器运行时，在容器内输入如下命令观察文件格式是否为f2fs，为f2fs时说明特性正在使能，为其他格式时说明未生效。

```shell
mount | grep -i /data
```

## 9 容器内/system分区大小可调节<a name="ZH-CN_TOPIC_0000002549865943"></a>

### 9.1 特性介绍<a name="ZH-CN_TOPIC_0000002549865944"></a>

#### 9.1.1 简介<a name="ZH-CN_TOPIC_0000002549745956"></a>

在物理移动设备（真机）中，Android 系统的 /system 分区容量通常处于一个相对固定且有限的区间（约 2GB 至 15GB）。而在现有的云手机架构中，容器内的 /system 目录等核心文件系统层，普遍采用 Docker 的 Overlay2联合文件系统进行映射。默认情况下，OverlayFS 会直接继承宿主机底层 Docker 数据根目录所在磁盘的整体容量，该容量在服务器环境中往往达到 TB 级别。这种存储空间量级上的巨大异常特征，极易触发第三方应用的设备环境审查机制。为了提升云手机容器的仿真能力，本方案将提供云手机实例级别的 /system 分区容量动态限制与调节能力。

#### 9.1.2 约束与限制<a name="ZH-CN_TOPIC_0000002549865952"></a>

1. 底层文件系统强依赖：宿主机用于承载云机容器数据的目标磁盘，必须被格式化为 XFS 格式。若文件系统不支持该特性，容量配置将直接失效。
2. 挂载选项合规性：负责挂载该数据盘的运维脚本或 /etc/fstab 配置中，必须包含并成功应用了 pquota 参数。若磁盘以默认参数挂载，即使底层是 XFS，Docker 在尝试应用  --storage-opt size 参数启动云机时也会抛出异常或导致配额下发失败。
3. 参数配置限制：system分区可设置的大小并不是无限大，当设置的参数大于docker根目录的大小的时候，设置给system分区的大小会自动变成docker根目录的大小

#### 9.1.3 应用场景<a name="ZH-CN_TOPIC_0000002518226174"></a>

本特性没有特别的应用场景限制

### 9.2 使用介绍<a name="ZH-CN_TOPIC_0000002549865942"></a>

#### 9.2.1 安装特性<a name="ZH-CN_TOPIC_0000002518386093"></a>

##### 9.2.1.1 **新建xfs盘并挂载。**

   输入下面命令查找当前环境磁盘情况

   ```shell
   lsblk -f
   ```

如果已经有xfs格式的硬盘挂载在/var/lib/docker目录，那么可以直接跳到[触发分区扩容逻辑](ZH-CN_TOPIC_0000002549832550)章节继续执行

输入如下命令新建物理盘分区

   ```shell
   fdisk /dev/${打算新建分区的所在物理盘名字}
   ```

系统重新读取分区表

   ```shell
   partprobe /dev/${打算新建分区的所在物理盘名字}
   ```

将新分区设置为xfs格式

   ```shell
   mkfs.xfs /dev/${新创建的逻辑盘分区名字}
   ```

修改挂载配置文件，确保使用 `xfs` 类型挂载。
   
输入如下命令编辑挂载信息

   ```shell
   vim /etc/fstab
   ```

输入如下命令查看新建的磁盘分区的UUID
   ```shell
   lsblk -f
   ```
在UUID属性列看到的一串由数字和字母组成的id即为uuid

输入如下挂载信息

   ```text
   UUID=${UUID} /var/lib/docker  xfs defaults,pquota 0 2
   ```

挂载新分区，先启动xfs驱动，随后使能新分区挂载生效

   ```shell
   modprobe xfs
   mount -a 
   systemctl daemon-reload
   ```

##### 9.2.1.2 **触发分区扩容逻辑。**<a name="ZH-CN_TOPIC_0000002549832550"></a>

   在云手机配置文件kbox_config.cfg里，将SYSTEM_PARTITION_SIZE_MB设置为预期要实现的/system分区大小值，单位为MB

   ```txt
   SYSTEM_PARTITION_SIZE_MB=${预期要实现的/system分区大小值(MB)}
   ```

#### 9.2.2 使用特性<a name="ZH-CN_TOPIC_0000002549745950"></a>

1. 容器配置属性 SYSTEM_PARTITION_SIZE_MB 来控制是否使用该特性，默认值为0，表示不使能；输入非0值即表示打开，这个值为预期设置的/system分区大小，单位是MB.
2. 在运行时，观察云机属性/system分区的大小的值是否等于配置属性，如果相等则说明特性正在使能，若不相等则说明未生效。

## 10 支持NFS挂载<a name="支持NFS挂载"></a>

### 10.1 特性介绍

#### 10.1.1 简介

当前云手机方案采用的是存算一体，数据本地存储，存储无法复用。因此为了实现存算分离，存储复用，该特性支持将数据存储通过NFS挂载到远端。NFS是一种网络文件系统，它允许你像访问本地磁盘一样，通过网络访问远程服务器上的文件。

#### 10.1.2约束与限制

NFS采用典型的**客户端/服务器（C/S）**架构，客户端/服务器均需要包含内核模块nfs、nfsd、nfsv4，安装nfs-utils、rpcbind。

#### 10.1.3 应用场景

存算分离，存储复用等场景

### 10.2安装特性

#### 2.1、客户端/服务器公共操作

1、确认内核是否加载nfs模块

```shell
cat /boot/config-$(uname -r) | grep NFS
```

CONFIG_NFS_FS、CONFIG_NFS_V4、CONFIG_NFSD为y，则说明该内核支持NFS，为m则需要执行如下命令加载改模块。其他值则需要改成y或m重新编译内核。

```shell
modprobe nfs
modprobe nfsd
modprobe nfsv4
```

2、安装nfs-utils软件包

```shell
yum install nfs-utils rpcbind
```

#### 2.2、服务器配置

1、新建要导出的目录

```shell
mkdir -p /home/nfs
```

2、编写/etc/exports文件，文件内容如下

```shell
/home 192.168.20.0/24(rw,fsid=0,sync,no_root_squash)
/home/nfs 192.168.20.0/24/(rw,sync,no_root_squash)
```

3、重启相关服务

```shell
systemctl restart rpcbind
systemctl restart nfs
```

4、查看目录是否导出

```shell
exportfs
```

期望有步骤2中编写的目录输出。

#### 2.3、客户端配置

1、创建挂载点

```shell
mkdir -p /tmp/nfs
```

2、挂载服务器的nfs目录

```shell
mount -t nfs4 192.168.20.XX:/nfs /tmp/nfs
```

>
>- 由于服务器的/etc/exports对/home目录配置了fsid=0，因此在客户端时不可见的，所以只需要挂载/nfs目录即可

### 3、使用特性

1、在容器配置文件kbox_config.cfg中配置NFS_DIR属性为/tmp/nfs，启动云手机使用nstart命令

```shell
./android_kbox.sh nstart kbox:origin 1
```

2、在容器启动后，查看挂载目录下对应data/containerd内容是否跟容器id一致

```shell
cat /tmp/nfs/data/kbox_1/data/containerd
```

## 11 CPU频率动态模拟与调节<a name="ZH-CN_TOPIC_00000025498659400"></a>

### 11.1 特性介绍<a name="ZH-CN_TOPIC_000000254986592"></a>

#### 11.1.1 简介<a name="ZH-CN_TOPIC_000000254974595"></a>

在真实的移动终端设备中，系统通常会基于 CPUFreq 子系统及当前的计算负载，动态调节 CPU 的运行频率，以达到性能与功耗的平衡。相比之下，云手机依托于服务器宿主机的容器化环境运行，其底层物理 CPU 的频率通常处于恒定状态。这种底层硬件行为特征的显著差异，极易被安全风控系统精准识别，进而导致云手机实例被判定为非真实设备并遭到拦截或降级处理。为了提升云手机的底层硬件行为仿真度，该方案提出“CPU频率动态模拟与调节”功能，从而增强云机仿真能力。

#### 11.1.2 约束与限制<a name="ZH-CN_TOPIC_0000002549865950"></a>

系统在初始化或容器启动阶段，必须确保目标数据路径目录及其内部核心文件对执行频率写入操作的进程开放写入权限。若权限不足，将直接导致节点数据覆写失败，功能无法生效。

#### 11.1.3 应用场景<a name="ZH-CN_TOPIC_0000002518226175"></a>

本特性没有特别的应用场景限制

### 11.2 使用介绍<a name="ZH-CN_TOPIC_00000025498659431"></a>

#### 11.2.1 安装特性<a name="ZH-CN_TOPIC_0000002518386097"></a>

##### 11.2.1.1 **权限检测**

   输入下面命令查找目标数据路径是否具备写入权限,若权限不足，会直接导致数据写入失败

   ```shell
   ls -ld /sys/devices/system/cpu/cpu${需要查询权限的cpu的编号}/cpufreq/
   ```

如果包含 w（如 -rw-r--r--），说明文件的所有者（通常是 root）拥有写入权限。请直接跳到[文件说明](feature_guide.md#ZH-CN_TOPIC_0000002549832553)

如果没有 w（如 -r--r--r--），说明它是只读的，此时权限不足，无法直接写入。请按照如下步骤

##### 11.2.1.2 **新增权限**<a name="ZH-CN_TOPIC_0000002549832559"></a>
输入如下命令进入 root 用户身份
```shell
su root
```

输入如下命令添加写入（w）权限
```shell
chmod a+w /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq
```

##### 11.2.1.3 **文件说明**<a name="ZH-CN_TOPIC_0000002549832553"></a>

   容器内的/sys/devices/system/cpu/cpu${需要查询权限的cpu的编号}/cpufreq/目录下一般有如下文件，下面表格对各个文件的作用进行说明

   | 文件名 | 记载的信息和作用 | 建议和说明（功能实现指南） |
| :--- | :--- | :--- |
| **`scaling_cur_freq`** | **内核调优器（Governor）决定的当前运行频率。** 绝大多数 App 和安全风控系统会读取此文件来判断设备的实时运行状态。 |  如果进行cpu频率动态调节，核心是往该文件覆写数值。 |
| **`scaling_governor`** | 当前的 CPU 频率调节策略（调度器）。  |   |
| **`scaling_setspeed`** | 用户空间请求的目标频率。  | |
| **`scaling_available_frequencies`** | **当前硬件及驱动所支持的所有可用频率档位列表。**（例如：`300000 600000 1000000 ...`）。 | 在进行频率调节时，切勿写入随机瞎编的数字。建议读取此文件，并在这些支持的频率列表中选取数值进行写入，以防被风控系统通过“非法频段”识别。 |
| **`scaling_available_governors`** | **系统当前支持的所有调节策略（调度器）列表。** |   |
| **`scaling_max_freq`** | **软件策略允许达到的最高频率限制。** | **频率上限封顶。** 如果要实现“降频省电”或“模拟低端设备”功能时，则可能会修改此文件，确保模拟出的最高频率不超过此设定值。 |
| **`scaling_min_freq`** | **软件策略允许达到的最低频率限制。** | **频率下限托底。** 如果要实现“性能保底”或“模拟高性能设备待机”功能，则可能会修改此文件，防止频率降得过低导致伪装失真。 |
| **`scaling_driver`** | **当前使用的 CPU 频率驱动程序名称。**  |  |
| **`cpuinfo_cur_freq`** | **CPU 硬件底层真实的当前运行频率。** | 如果仅修改 `scaling_cur_freq` 可能会被识别并拦截，因此在修改了scaling_cur_freq后建议同步修改该文件。 |
| **`cpuinfo_max_freq`** | **CPU 硬件物理支持的最大频率。** | 用于初始化时获取该云手机实例分配到的 CPU 物理性能上限。 |
| **`cpuinfo_min_freq`** | **CPU 硬件物理支持的最小频率。** | 用于辅助生成合理的频率波动曲线的下限边界。 |
| **`cpuinfo_transition_latency`** | **CPU 切换不同频率所需的时间延迟（纳秒）。** |  两次 `echo` 写入的时间间隔，不应低于此延迟数值。 |
| **`affected_cpus`** | **需要同时进行频率调整的 CPU 逻辑核列表。** 某些架构下，同一个簇（Cluster）的 CPU 频率必须绑定。 | 在编写群控调频脚本时，需读取此文件。例如修改了 CPU0 的频率，必须确保此列表中的其他 CPU 也被同步修改或显示相同数值 |
| **`related_cpus`** | **物理上属于同一组的所有 CPU 列表（无论当前是否在线/唤醒）。** |  与 `affected_cpus` 类似，主要用于分析底层 CPU 簇拓扑结构，指导多核频率仿真脚本的编写。 |

#### 11.2.2 实施修改 <a name="ZH-CN_TOPIC_0000002549745956"></a>

当前第三方检测应用一般通过读取scaling_cur_freq和cpuinfo_cur_freq这两个文件来获取当前设备的cpu运行频率，为了提高云机设备的仿真能力，在修改前先输入如下命令读取cpu所支持的频率列表。并且要对这两个文件都进行修改
   ```shell
   cat /sys/devices/system/cpu/cpu${准备进行频率修改的cpu的编号}/cpufreq/scaling_available_frequencies
   ```
   随后输入如下两个命令进行修改，输入的频率值最好是刚刚查询到的当前cpu支持的频率值
   ```shell
   echo ${预期修改的值} > /sys/devices/system/cpu/cpu${准备进行频率修改的cpu的编号}/cpufreq/scaling_cur_freq
   ```

   ```shell
   echo ${预期修改的值} > /sys/devices/system/cpu/cpu${准备进行频率修改的cpu的编号}/cpufreq/cpuinfo_cur_freq
   ```
