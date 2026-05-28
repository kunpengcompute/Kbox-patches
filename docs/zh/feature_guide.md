# 特性指南<a name="ZH-CN_TOPIC_0000002521623660"></a>

## 1 特性描述<a name="ZH-CN_TOPIC_0000002549825543"></a>

Kbox云手机容器是鲲鹏BoostKit云手机Turbo套件的核心能力组件，本文介绍了Kbox云手机容器的基本概念，提供Kbox云手机容器的编译、部署及相关配置流程。

云手机是基于ARM服务器虚拟出的带有AOSP （Android Open Source Project，安卓开放源代码项目）系统的虚拟手机服务。简而言之，云手机=ARM服务器+Android OS。您可以远程实时控制云手机，实现Android APP的云端运行；也可以基于云手机的基础算力，高效搭建应用，如云游戏、移动办公、直播互娱等场景。

Kbox云手机容器是鲲鹏BoostKit云手机Turbo套件的重要组成部分，是实现Android应用运行的基础软件。它将AOSP系统直接运行在容器内，实现GPS、加速度传感器、陀螺仪、IMEI、Wi-Fi等外设硬件的数据Mock功能，以及Gralloc&HWComposor模块，确保AOSP系统可以正常启动运行；以及一系列可选特性，用于在各种业务场景下增强云手机功能或性能。

Kbox支持的所有基础功能和可选特性见[**表 1** Kbox基础功能清单](#Kbox基础功能清单)和[**表 2** Kbox可选特性清单](#Kbox可选特性清单)。对于Kbox基础功能，可按照[编译指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/zh/compile_guide.md)与[安装指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/zh/install_guide.md)中描述集成Kbox云手机容器组件，即可支持。可选功能的相关信息在下文章节中详细描述。

**表 1** Kbox基础功能清单<a id="Kbox基础功能清单"></a>

|名称|说明|
|--|--|
|支持Android Kbox云手机容器方案| 支持基于openEuler（Host OS）和Android（Guest OS）的Kbox云手机容器参考方案。CTS 兼容性>98% |
|支持GPU直接渲染和主流的图形API| 容器内GPU直接渲染，支持OpenGL ES 2.0/3.0/3.1/3.2和Vulkan 1.1图形API。dEQP兼容性>98% |
|云手机视频播放支持硬件加速| 云手机视频播放支持硬件加速，实现视频播放H.264/H.265解码硬件加速，降低CPU负载，提升媒体场景性能 |
|Kbox内核支持动态开关|提供动态开关实现云手机使用的Host OS镜像可供其他业务共用|
|Gralloc模块支持YCbCr_420_888格式| 修改Gralloc模块支持YCbCr_420_888的处理，修复黑屏问题 |
|提供GPU显存、内存等资源监控能力| 提供GPU显存、内存等资源的实时监控，便于客户根据资源的使用情况进行相应的处理 |

**表 2** Kbox可选特性清单<a id="Kbox可选特性清单"></a>

|名称|说明|
|--|--|
|支持纹理自适应压缩| 基于Mesa开源上实现纹理自适应压缩，支持Vulkan RGB和RGBA纹理转DXT纹理 |
|支持自适应帧同步| 实现自适应vsync功能，在应用渲染完成一帧后，Surfaceflinger立即合成上屏 |
|Kbox动态帧率调整| 在挂机场景下，云手机与客户端断开连接时，动态向下调整帧率以减少渲染性能开销 |
|Android轻量化裁剪| Android系统的轻量化裁剪通过去除不必要的系统服务和内置应用来降低云手机的资源占用，从而提升系统性能、优化用户体验 |
|Android composer优化| 当游戏应用全屏时，仅有游戏应用图层，可以跳过合成步骤，并省略图像由横屏翻转为竖屏的操作，降低GPU的性能开销 |
|支持线程级Shader Cache| 通过预构建二进制消除着色器编译链接等处理时间，提升大型应用场景下的渲染效率  |
|支持F2FS文件格式启动|通过添加配置项支持云手机以f2fs文件格式启动，和真实手机采用一样的文件系统，提高仿真能力|
|支持/system分区大小调节|通过添加配置项支持自主调节云手机容器内/system分区大小，和真机具备相近的/system分区大小，提高仿真能力|

## 2 支持纹理自适应压缩

### 2.1 特性介绍

#### 2.1.1 简介

在移动应用中ETC、ASTC等压缩纹理被大量使用，他们被移动端GPU原生支持，降低显存占用和节省带宽。然而，云手机部署在服务器上，而服务器级GPU不支持这些压缩纹理，需要先将这些纹理解压成RGBA纹理，导致显存占用显著增大，影响云手机在服务器上的部署密度。本特性支持在OpenGL ES和Vulkan应用中被解压出的RGBA纹理压缩成BC纹理，有效降低显存占用。

#### 2.1.2 约束与限制

1. 本特性Vulkan目前只支持ETC纹理解压并压缩成BC纹理；OpenGL ES目前只支持ASTC纹理解压并压缩成BC纹理。
2. 本特性不支持在应用运行期间修改，如需修改，需先关闭应用，然后重新启动应用。
3. 该功能不支持纹理后处理，如应用存在此种应用场景可能造成渲染异常，此时需关闭纹理压缩功能后重新打开应用。

#### 2.1.3 应用场景

本特性在大量使用ETC纹理的Vulkan应用、或者大量使用ASTC纹理的OpenGL ES应用使用效果最佳，其他场景或者没优化或者优化不明显。

### 2.2 安装特性

该特性默认集成到安卓镜像中。

### 2.3 使用特性

可按以下步骤使用该特性：

1. 设置`sys.vmi.vk.texturecompress`为1，支持Vulkan应用的纹理压缩，默认已开启。
2. 设置`sys.vmi.gl.texturecompress`为1，支持OpenGL ES应用的纹理压缩，默认已开启。

## 3 自适应帧同步<a name="ZH-CN_TOPIC_0000002518185772"></a>

### 3.1 特性介绍<a name="ZH-CN_TOPIC_0000002518345690"></a>

#### 3.1.1 简介<a name="ZH-CN_TOPIC_0000002549825541"></a>

影响云手机用户体验的关键因素之一是端到端操作时延，而E2E时延主要可以分为3段：云侧时延+网络时延+端侧时延。Kbox云手机方案主要聚焦云侧时延的极致优化。

自适应帧同步特性提供对安卓系统图形渲染流程的优化功能，可在主流场景下优化云侧时延（定义为从触控事件到对应图像编码完成所需要的时间）。

#### 3.1.2 约束与限制<a name="ZH-CN_TOPIC_0000002549705545"></a>

1、自适应帧同步功能打开时，在部分应用场景可能会出现短暂的出流帧率高于容器配置帧率的现象。这是本特性实现方案在多图层渲染场景下的预期内行为，但特性会自动识别该场景并动态使能，因此不会长时间发生这种现象。可通过配置阈值vmi.adaptive.vsync.threshold调节识别的精度，配置值较小时可以降低发生帧率异常冲高现象的概率，但可能导致自适应帧同步的收益不稳定。

#### 3.1.3 应用场景<a name="ZH-CN_TOPIC_0000002518185774"></a>

本特性没有特别的应用场景限制，但在部分场景下可能存在收益不稳定的现象。经过实测，在主流游戏应用场景下，可以取得稳定收益。

### 3.2 安装特性<a name="ZH-CN_TOPIC_0000002549825537"></a>

可按以下步骤集成本特性：

1. 安卓镜像中，合入patchForAndroid/frameworks-native-0001.patch（取自Kbox-patches-AOSP11.zip，见[**表 1** Kbox基础功能清单](#Kbox基础功能清单)）
2. 将AdaptiveVsync.kbox.so（取自BoostKit-boostcph-kbox_\*.zip，见[软件环境](compile_guide.md#Kbox安卓镜像编译构建软件环境要求)）集成至安卓镜像的/system/vendor/lib64/hw/路径下

### 3.3 使用特性<a name="ZH-CN_TOPIC_0000002518345688"></a>

1. 云机配置属性 ro.vmi.adaptive.vsync 为1，即打开特性。
2. 在运行时，观察云机属性vmi.enable.adaptive.vsync的值是否为1，为1时说明特性正在使能，为0时说明为规避帧率冲高现象，暂时去使能特性。

### 3.4 特性收益

在1080P@60fps游戏场景下，优化服务器端时延约10ms。

## 4 Kbox动态帧率调整

### 4.1 特性介绍

#### 4.1.1 简介

云手机在未出流时仍然会在后台保持运行，画面也会按照生效的帧率不断地刷新。在游戏挂机或其他出流比较低的场景中，可能服务器上大量云机都处于不出流的状态，但仍消耗大量硬件资源用于画面刷新，影响整体性能。本功能针对该场景进行优化，当云手机不出流时，降低云机的渲染帧率，减少不出流云机的性能开销。当云机出流时，则恢复正常的渲染帧率，保证用户的正常使用体验。

#### 4.1.2 约束与限制

为保证出流断开后，渲染帧率降低后应用运行不出现异常，配置的帧率下降目标值约束为两档：12/24。

#### 4.1.3 应用场景

本特性没有特别的应用场景限制，在出流比例越低的场景上可获得越大的性能收益。

### 4.2 安装特性

集成25.0.RC1或更高版本的Kbox云手机组件即包含本功能。<br>
涉及patchForAndroid目录下的frameworks-native-0001.patch/hardware-interfaces-0001.patch/hardware-libhardware-0001.patch（取自Kbox-patches-AOSP11.zip，见[**表 1** Kbox基础功能清单](#Kbox基础功能清单)）

### 4.3 使用特性

1. 云机配置属性 ro.hardware.dynamicfps 为1，即使能特性
2. ro.hardware.downfps为动态帧率调整目标值，可配置为12/24。
3. 云机启动后，连接再断开云机出流，观察云机出流帧率，若正常生效应该在断开后出流帧率与配置的ro.hardware.downfps属性值一致（渲染帧率会最终体现在出流帧率上）。

## 5 Android轻量化裁剪

### 5.1 特性介绍

#### 5.1.1 简介

Android系统中默认包含了许多内置应用与系统服务进程，在系统启动流程中，这些系统进程会自动启动与运行，以提供基础的系统功能和服务。对于云手机解决方案，Android系统中部分系统服务是非必要的，而这些冗余的系统进程占用了一部分性能资源。现考虑到极致性能场景，提供了剪裁冗余系统进程的能力，从而最大化降低系统资源消耗，提升性能。

#### 5.1.2 约束与限制

无

#### 5.1.3 应用场景

本特性没有特别的应用场景限制。

### 5.2 安装特性

请按照以下步骤使能本特性：

1. 编译安卓镜像时，参考[编译指南](compile_guide.md)，选择`kbox_arm64_optimized-user`编译选项。
2. 完成其余编译步骤，获得Kbox安卓轻量化裁剪镜像。

### 5.3 使用特性

使用编译得到的Kbox安卓轻量化裁剪镜像文件android.tar部署云手机容器方案，启动的云手机即为轻量化裁剪Android系统。

### 5.4 特性收益

挂机场景下，单路云手机启动后，降低5%+内存占用，进程数减少10+。

## 6 Android composer优化

### 6.1 特性介绍

#### 6.1.1 简介

安卓图形子系统中，应用可创建多个图层进行渲染，最终在安卓SurfaceFlinger模块中合成为1帧图像后送显。而在常见的全屏游戏场景中，应用均采用单图层渲染。在这种情况下可以对SurfaceFlinger模块中的合成流程进行优化，降低合成步骤所带来的性能开销。

#### 6.1.2 约束与限制

1. 在使用硬件配置方案一（[安装指南](./install_guide.md)）时，若打开合成优化功能，可能在进入/退出游戏、拉起输入栏等行为时，发生画面旋转现象，可根据具体场景评估影响，决定是否需要打开。
2. 在25.3.0或更高版本的Kbox云手机组件上，该功能在硬件配置方案二、三、四上无法生效（[安装指南](./install_guide.md)）

#### 6.1.3 应用场景

本特性没有特别的应用场景限制，在全屏游戏场景上可取得预期性能收益。在其他场景上可能没有性能收益，但不会影响正常显示画面。

### 6.2 安装特性

集成25.1.RC1或更高版本的Kbox云手机组件即包含本功能。

### 6.3 使用特性

1. 云机配置属性 ro.hardware.compositionBypass 为1，即使能特性
2. 云机配置属性 ro.hardware.compositionBypass.offset，该属性可控制合成优化功能在连续一定帧数满足生效条件后再实际生效，可以改善合成优化功能开启后可能出现的画面旋转现象。可根据实际情况调整。
3. 启动云机即功能生效。

### 6.4 特性收益

在满足生效条件的全屏游戏场景下，优化GPU占用率10%。

## 7 支持线程级Shader Cache

### 7.1 特性介绍

#### 7.1.1 简介

通常大型移动应用在启动前会预构建一些着色器，但在大型应用涉及场景切换、模型特效加载时仍存在着色器处理行为，包括着色器源码加载、编译、链接等，部分着色器处理时间长导致渲染抖动。本特性通过预构建二进制着色器文件，依托云侧多容器文件共享，来消除着色器编译、链接等处理时间，提升大型应用场景下的渲染效率。同时让应用在启动前跳过编译着色器阶段，大幅降低游戏启动时间。本特性通过读取配置文件支持对缓存行为按应用级别进行定制。

#### 7.1.2 约束与限制

1. 本特性只适用于使用OpenGL ES 3.0及以上的应用。
2. 在使能Shader Cache后，若应用没有在云侧缓存场景所需的二进制着色器文件，在首次运行该应用时会十分卡顿。可以先启动一路云手机预收集尽可能完整的着色器。
3. 该特性没有缓存淘汰机制，若缓存文件系统存储已满，请清理整个文件系统的缓存并调大存储容量；若游戏版本更新，为避免旧版本的缓存的空间占用，需要清理旧版本的缓存文件。

#### 7.1.3 应用场景

本特性在某些运行过程中存在大量的着色器编译、链接的应用使用效果最佳，其他场景或者没优化或者优化不明显。

### 7.2 安装特性

本特性仅提供二进制so文件，安装时需将 RenderAccLayer\.kbox\.so（取自BoostKit-boostcph-kbox_*.zip，见[软件环境](compile_guide.md#Kbox安卓镜像编译构建软件环境要求)））集成至安卓镜像的/system/vendor/lib64/hw/路径下。

### 7.3 使用特性

该特性的使用步骤如下：

1. 首先需要使能该特性，即将配置文件（Kbox镜像的配置文件为**kbox_config.cfg**，视频流镜像则为**cfct_config**）中的**ENABLE_RENDER_LAYER**设置为1；
2. 从软件包Kbox-patches-AOSP11.zip中拷贝kbox_render_accelerating_configuration.xml配置文件到当前启动路径；
3. 打开kbox_render_accelerating_configuration.xml配置文件，对应用的Shader缓存行为进行配置。具体配置项描述请参见[3.1.2 图形加速层配置项](https://gitcode.com/boostkit/vmi/blob/CloudPhone/docs/zh/user_guide.md#312-图形加速层配置项)。
4. 启动一个云手机，运行已配置好的应用，可查看到容器内vender/shader_cache路径下已生成对应应用的缓存文件。
   > **注意**：使能该特性以及设置`SHADER_CACHE_DIR_SIZE`均需要启动一个新的云手机才能生效。
5. 若要修改Shader Cache的模式，修改kbox_render_accelerating_configuration.xml配置文件中的`SHADER_CACHE_MODE`参数，并将配置文件拷贝至云手机容器内/data/local/tmp/目录下，重启应用即可生效。

## 8 以f2fs文件格式启动

### 8.1 特性介绍

#### 8.1.1 简介

在移动终端硬件领域，F2FS文件格式是现代安卓真机的标准文件系统格式。当前云手机运行在宿主机环境中，文件格式一般是ext4格式，文件格式的不同将显著降低设备的仿真置信度，增加被风控策略拦截的风险。因此，为了提升云手机的仿真度，可以实现云手机容器对 F2FS 格式的底层支持。

#### 8.1.2 约束与限制

1. 内核兼容性限制：宿主机操作系统内核必须包含并启用 F2FS 内核模块支持。若内核缺失相关驱动或编译选项，系统将无法识别并挂载 F2FS 格式的存储介质。
2. 存储资源前置条件：系统环境中必须存在已完成 F2FS 格式化的物理磁盘、分区或逻辑卷设备。该设备需处于可用状态，且具备被挂载至数据卷 data 目录的物理前提。

#### 8.1.3 应用场景

本特性没有特别的应用场景限制。

### 8.2 使用介绍

#### 8.2.1  **使用介绍**<a name="ZH-CN_TOPIC_0000002549865941"></a>

##### 8.2.1.1  **环境准备**

   确认f2fs工具是否已安装且宿主机内核是否已加载F2FS模块，并安装用户态工具。

   ```shell
   yum install f2fs-tools
   ```

   检查当前内核是否支持f2fs。

   ```shell
   cat /proc/filesystems | grep f2fs
   ```

若回显中出现"f2fs"，则直接跳到下方"新建f2fs磁盘并挂载指定目录"章节继续执行。

如果回显为空，说明当前内核不支持f2fs文件格式，则需要重新编一个支持f2fs格式的内核，编译时在”配置内核编译选项“步骤中需要把.config文件里的CONFIG_F2FS_FS设置为Y，重新编内核的步骤可以参照install_guide.md的[编译及安装内核](install_guide.md#ZH-CN_TOPIC_0000002549832103)章节。

##### 8.2.1.2 **新建f2fs磁盘并挂载指定目录**

注意：该步骤并非必要操作，如果数据卷目录下的data目录没有挂载f2fs格式磁盘，在打开f2fs文件系统开关之后，可能会对性能产生影响。

输入下面命令查找当前环境磁盘情况。

   ```shell
   lsblk -f
   ```

如果已经有f2fs格式的硬盘挂载在数据卷目录下的data目录，那么可以直接跳到下方[使用特性](feature_guide.md#ZH-CN_TOPIC_0000002549745952)章节继续执行。

输入如下命令新建物理盘分区。

   ```shell
   fdisk /dev/${打算新建分区的物理盘名字}
   ```

系统重新读取分区表。

   ```shell
   partprobe /dev/${打算新建分区的物理盘名字}
   ```

将新分区设置为f2fs格式。

   ```shell
   mkfs.f2fs /dev/${新创建的逻辑盘名字}
   ```

修改挂载配置文件，确保使用 `f2fs` 类型挂载。
   
输入如下命令编辑挂载信息。

   ```shell
   vim /etc/fstab
   ```

输入如下挂载信息。

   ```text
   UUID=${UUID} ${data_disk_mount_dir}/data  f2fs defaults
   ```

挂载新分区，使能新分区挂载生效。

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
3. 参数配置限制：system分区可设置的大小并不是无限大，当设置的参数大于docker根目录的大小的时候，设置给system分区的大小会自动变成docker根目录的大小。

#### 9.1.3 应用场景<a name="ZH-CN_TOPIC_0000002518226174"></a>

本特性没有特别的应用场景限制。

### 9.2 使用介绍<a name="ZH-CN_TOPIC_0000002549865942"></a>

#### 9.2.1 安装特性<a name="ZH-CN_TOPIC_0000002518386093"></a>

##### 9.2.1.1 **新建xfs盘并挂载**

   输入下面命令查找当前环境磁盘情况。

   ```shell
   lsblk -f
   ```

如果已经有xfs格式的硬盘挂载在docker的根目录，一般默认是/var/lib/docker目录，那么可以直接跳到[触发分区扩容逻辑](feature_guide.md#ZH-CN_TOPIC_0000002549832550)章节继续执行。

输入如下命令新建物理盘分区。

   ```shell
   fdisk /dev/${打算新建分区的所在物理盘名字}
   ```

系统重新读取分区表。

   ```shell
   partprobe /dev/${打算新建分区的所在物理盘名字}
   ```

将新分区设置为xfs格式。

   ```shell
   mkfs.xfs /dev/${新创建的逻辑盘分区名字}
   ```

修改挂载配置文件，确保使用 `xfs` 类型挂载。
   
输入如下命令编辑挂载信息。

   ```shell
   vim /etc/fstab
   ```

输入如下命令查看新建的磁盘分区的UUID。

   ```shell
   lsblk -f
   ```

在UUID属性列看到的一串由数字和字母组成的id即为uuid。

输入如下挂载信息。

   ```text
   UUID=${UUID} ${docker_root_dir}  xfs defaults,pquota 0 2
   ```

挂载新分区，输入如下命令使能新分区挂载生效。

   ```shell
   mount -a
   systemctl daemon-reload
   ```

##### 9.2.1.2 **触发分区扩容逻辑**<a name="ZH-CN_TOPIC_0000002549832550"></a>

   在云手机配置文件kbox_config.cfg里，将SYSTEM_PARTITION_SIZE_MB设置为预期要实现的/system分区大小值，单位为MB。

   ```txt
   SYSTEM_PARTITION_SIZE_MB=${预期要实现的/system分区大小值(MB)}
   ```

#### 9.2.2 使用特性<a name="ZH-CN_TOPIC_0000002549745950"></a>

1. 容器配置属性 SYSTEM_PARTITION_SIZE_MB 来控制是否使用该特性，默认值为0，表示不使能；输入非0值即表示打开，这个值为预期设置的/system分区大小，单位是MB。

2. 在运行时，观察云机属性/system分区的大小的值是否等于配置属性，如果相等则说明特性正在使能，若不相等则说明未生效。

## 10 支持NFS挂载<a name="支持NFS挂载"></a>

### 10.1 特性介绍

#### 10.1.1 简介

当前云手机方案采用的是存算一体，数据本地存储，存储无法复用。因此为了实现存算分离，存储复用，该特性支持将数据存储通过NFS挂载到远端。NFS是一种网络文件系统，它允许你像访问本地磁盘一样，通过网络访问远程服务器上的文件。

#### 10.1.2 约束与限制

NFS采用典型的**客户端/服务器（C/S）**架构，客户端/服务器均需要包含内核模块nfs、nfsd、nfsv4，安装nfs-utils、rpcbind。

#### 10.1.3 应用场景

存算分离，存储复用等场景

### 10.2 安装特性

#### 10.2.1 客户端/服务器公共操作

1、确认内核是否加载nfs模块。

```shell
cat /lib/modules/$(name -r)/build/.config
```

CONFIG_NFS_FS、CONFIG_NFS_V4、CONFIG_NFSD为m需要执行如下命令加载该模块。

```shell
modprobe nfs
modprobe nfsd
modprobe nfsv4
```

2、安装nfs-utils软件包

```shell
yum install nfs-utils rpcbind
```

#### 10.2.2 服务器配置

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

#### 10.2.3 客户端配置

1、创建挂载点

```shell
mkdir -p /tmp/nfs
```

2、挂载服务器的nfs目录

```shell
mount -t nfs4 192.168.20.XX:/nfs /tmp/nfs
```

>![](public_sys-resources/icon-note.gif) **说明：**
>由于服务器的/etc/exports对/home目录配置了fsid=0，因此在客户端时不可见的，所以只需要挂载/nfs目录即可

### 10.3 使用特性

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

本特性没有特别的应用场景限制。

### 11.2 使用介绍<a name="ZH-CN_TOPIC_00000025498659431"></a>

#### 11.2.1 安装特性<a name="ZH-CN_TOPIC_0000002518386097"></a>

##### 11.2.1.1 **权限检测**

   在容器内输入下面命令查找目标数据路径中的目标文件是否具备写入权限,若权限不足，会直接导致数据写入失败。

   ```shell
   ls -ld /sys/devices/system/cpu/cpu${需要查询权限的cpu的编号}/cpufreq/scaling_cur_freq
   ```

   ```shell
   ls -ld /sys/devices/system/cpu/cpu${需要查询权限的cpu的编号}/cpufreq/cpuinfo_cur_freq
   ```

如果包含 w（如 -rw-r--r--），说明文件的所有者（通常是 root）拥有写入权限。请直接跳到[文件说明](feature_guide.md#ZH-CN_TOPIC_0000002549832553)。

如果没有 w（如 -r--r--r--），说明它是只读的，此时权限不足，无法直接写入。请按照如下步骤。

##### 11.2.1.2 **新增权限**<a name="ZH-CN_TOPIC_0000002549832559"></a>

在容器内输入如下命令给scaling_cur_freq添加写入（w）权限。

```shell
chmod u+w /sys/devices/system/cpu/cpu${需要新增权限的cpu的编号}/cpufreq/scaling_cur_freq
```

在容器内输入如下命令给cpuinfo_cur_freq添加写入（w）权限。

```shell
chmod u+w /sys/devices/system/cpu/cpu${需要新增权限的cpu的编号}/cpufreq/cpuinfo_cur_freq
```

##### 11.2.1.3 **文件说明**<a name="ZH-CN_TOPIC_0000002549832553"></a>

   容器内的/sys/devices/system/cpu/cpu\${需要查询权限的cpu的编号}/cpufreq/目录下一般有如下文件，下面表格对各个文件的作用进行说明。

   | 文件名 | 记载的信息和作用 | 建议和说明（功能实现指南） |
| :--- | :--- | :--- |
| **`scaling_cur_freq`** | **内核调优器（Governor）决定的当前运行频率。** 绝大多数 App 和安全风控系统会读取此文件来判断设备的实时运行状态 |  如果进行cpu频率动态调节，核心是往该文件覆写数值。 |
| **`scaling_governor`** | 当前的 CPU 频率调节策略（调度器）。 |   |
| **`scaling_setspeed`** | 用户空间请求的目标频率。 | |
| **`scaling_available_frequencies`** | **当前硬件及驱动所支持的所有可用频率档位列表。**（例如：`300000 600000 1000000 ...`） | 在进行频率调节时，切勿写入任意数字。建议读取此文件，并在这些支持的频率列表中选取数值进行写入，以防被风控系统通过“非法频段”识别。 |
| **`scaling_available_governors`** | **系统当前支持的所有调节策略（调度器）列表。** |   |
| **`scaling_max_freq`** | **软件策略允许达到的最高频率限制。** | **频率上限封顶。** 如果要实现“降频省电”或“模拟低端设备”功能时，则可能会修改此文件，确保模拟出的最高频率不超过此设定值。 |
| **`scaling_min_freq`** | **软件策略允许达到的最低频率限制。** | **频率下限托底。** 如果要实现“性能保底”或“模拟高性能设备待机”功能，则可能会修改此文件，防止频率降得过低导致伪装失真。 |
| **`scaling_driver`** | **当前使用的 CPU 频率驱动程序名称。**  |  |
| **`cpuinfo_cur_freq`** | **CPU 硬件底层真实的当前运行频率。** | 如果仅修改 `scaling_cur_freq` 可能会被识别并拦截，因此在修改了scaling_cur_freq后建议同步修改该文件。 |
| **`cpuinfo_max_freq`** | **CPU 硬件物理支持的最大频率。** | 用于初始化时获取该云手机实例分配到的 CPU 物理性能上限。 |
| **`cpuinfo_min_freq`** | **CPU 硬件物理支持的最小频率。** | 用于辅助生成合理的频率波动曲线的下限边界 |
| **`cpuinfo_transition_latency`** | **CPU 切换不同频率所需的时间延迟（纳秒）。** | 两次 `echo` 写入的时间间隔，不应低于此延迟数值。 |
| **`affected_cpus`** | **需要同时进行频率调整的 CPU 逻辑核列表。** 某些架构下，同一个簇（Cluster）的 CPU 频率必须绑定。 | 在编写群控调频脚本时，需读取此文件。例如修改了 CPU0 的频率，必须确保此列表中的其他 CPU 也被同步修改或显示相同数值。 |
| **`related_cpus`** | **物理上属于同一组的所有 CPU 列表（无论当前是否在线/唤醒）。** | 与 `affected_cpus` 类似，主要用于分析底层 CPU 簇拓扑结构，指导多核频率仿真脚本的编写。 |

#### 11.2.2 实施修改 <a name="ZH-CN_TOPIC_0000002549745956"></a>

当前第三方检测应用一般通过读取scaling_cur_freq和cpuinfo_cur_freq这两个文件来获取当前设备的cpu运行频率，为了提高云机设备的仿真能力，在修改前先在容器内输入如下命令读取cpu所支持的频率列表。并且要对这两个文件都进行修改。

   ```shell
   cat /sys/devices/system/cpu/cpu${准备进行频率修改的cpu的编号}/cpufreq/scaling_available_frequencies
   ```

   随后在容器内输入如下两个命令进行修改，输入的频率值最好是刚刚查询到的当前cpu支持的频率值。

   ```shell
   echo ${预期修改的值} > /sys/devices/system/cpu/cpu${准备进行频率修改的cpu的编号}/cpufreq/scaling_cur_freq
   ```

   ```shell
   echo ${预期修改的值} > /sys/devices/system/cpu/cpu${准备进行频率修改的cpu的编号}/cpufreq/cpuinfo_cur_freq
   ```

   如果容器重启，那么之前的修改值会失效，CPU频率值会恢复默认。
   
   要实现cpu频率的动态调节，可以将如下shell命令直接复制粘贴到容器内任意路径中执行，即可在如“手机设备信息大全”这样的第三方应用中观察到cpu频率的动态变化，此处的“sleep 1”表示每隔1s变化一次，此处的“1”可以修改为其他时间值，FREQS数组里存放的是CPU频率的可能值，CPU_ID存放的是预期进行修改的CPU的编号，这三个值可以根据实际需求进行修改。

   ```shell
   CPU_ID=0
   FREQS=(554000 860000 956000 1042000 1128000 1224000 1320000 1397000 1512000 1628000 1748000 1858000 1954000)

   while true; do
      for FREQ in "${FREQS[@]}"; do
         echo $FREQ > /sys/devices/system/cpu/cpu${CPU_ID}/cpufreq/scaling_cur_freq 2>/dev/null
         echo $FREQ > /sys/devices/system/cpu/cpu${CPU_ID}/cpufreq/cpuinfo_cur_freq 2>/dev/null
         echo "CPU${CPU_ID} 频率已动态调节为: $FREQ"
         sleep 1
      done
   done
   ```
