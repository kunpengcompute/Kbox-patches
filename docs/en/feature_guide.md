# Feature Guide<a name="ZH-CN_TOPIC_0000002521623660"></a>

## 1 Feature Description <a name="ZH-CN_TOPIC_0000002549825543"></a>

The Kbox cloud phone container is the core component of the cloud phone Turbo toolkit in Kunpeng BoostKit. This document describes the basic concepts of the Kbox cloud phone container and how to compile, deploy, and configure the Kbox cloud phone container.

The cloud phone solution is a virtual phone service virtualized based on the Arm server and runs the Android Open Source Project (AOSP). In short, cloud phones are Arm servers that run the Android OS and function as virtual phones. You can remotely control the cloud phone in real time to run Android applications on the cloud. Based on the basic computing power of cloud phones, you can also efficiently build applications for scenarios like cloud gaming, mobile office, and live streaming interaction.

As the foundational software for running Android applications, the Kbox cloud phone container is an important part of the cloud phone Turbo toolkit in Kunpeng BoostKit. It directly runs the AOSP system in a container, mocks peripheral hardware such as the GPS sensor, acceleration sensor, gyroscope, international mobile equipment identity (IMEI), and Wi-Fi, and implements the Gralloc and HWComposer (HWC) modules, ensuring normal startup and running of the AOSP system. With a series of optional features, the Kbox cloud phone container can enhance the functions or performance of cloud phones in various service scenarios.

[**Table 1**](#kbox-core-functions) lists the core functions of Kbox and [**Table 2**](#optional-features-of-kbox) details its the optional features. To enable Kbox core functions, simply integrate the Kbox cloud phone container by following the instructions in [Compilation Guide](https://gitcode.com/wyc3111/Kbox-patches/blob/AOSP11/docs/en/compile_guide.md) and [Installation Guide](https://gitcode.com/wyc3111/Kbox-patches/blob/AOSP11/docs/en/install_guide.md). Information on the optional features is detailed in the sections below.

**Table 1** Kbox core functions<a id="kbox-core-functions"></a>

|Name|Description|
|--|--|
|Android Kbox cloud phone container solution| Kbox cloud phone container reference solution based on openEuler (host OS) and Android (guest OS). The CTS compatibility rate is greater than 98%.|
|Direct GPU rendering and mainstream graphics APIs| Direct GPU rendering in containers, supporting OpenGL ES 2.0/3.0/3.1/3.2 and Vulkan 1.1 graphics APIs. The dEQP compatibility rate is greater than 98%.|
|Hardware acceleration for video playback on cloud phones| Hardware acceleration for video playback on cloud phones, implementing H.264 and H.265 decoding hardware acceleration for video playback, reducing CPU load, and improving performance in media scenarios.|
|Kbox kernel dynamic switch|Dynamic switch, enabling the host OS image used by the cloud phone to be shared by other services.|
|YCbCr_420_888 format| YCbCr_420_888 supported by the Gralloc module, resolving the black screen issue.|
|Supports resource monitoring (including GPU memory and other memory resources).| Monitoring GPU memory and other memory resources so that customers can perform operations based on resource usage.|

**Table 2** Optional features of Kbox<a id="optional-features-of-kbox"></a>;

|Name|Description|
|--|--|
|Adaptive texture compression| Adaptive texture compression based on open-source Mesa, supporting conversions of Vulkan RGB and RGBA textures to DXT textures.|
|Adaptive frame synchronization| Adaptive vertical synchronization (vsync), enabling SurfaceFlinger to compose one frame immediately after it is rendered and send it to the screen.|
|Kbox dynamic frame rate adjustment| Dynamically decreases the frame rate to reduce rendering overhead when the client is disconnected from the cloud phone in the away from keyboard (AFK) scenario.|
|Android lightweight trimming| Removes unnecessary system services and built-in applications to reduce cloud phone resource usage, thereby improving system performance and optimizing user experience.|
|Android composer optimization| When a game app is displayed in full screen and only the game app layer is present, the composition step can be skipped and image rotation from landscape to portrait can be omitted, reducing GPU overhead.|
|Support for thread-level shader cache| Pre-built binaries cut shader compilation and linking time, improving rendering efficiency of large-scale applications. |
|Boot in F2FS format|Enables the cloud phone to boot using the Flash-Friendly File System (F2FS) file format by adding specific configuration options. This utilizes the same file system as physical smartphones, thereby enhancing simulation capabilities.|
|Support for /system partition size adjustment|Allows users to manually adjust the /system partition size within the cloud phone container by adding configuration options. This aligns the partition closer to that of a physical device, thereby enhancing simulation capabilities.|

## 2 Adaptive Texture Compression

### 2.1 Feature Description

#### 2.1.1 Overview

In mobile applications, compressed textures such as ETC and ASTC are widely used. They are natively supported by mobile GPUs to reduce video RAM footprint and save bandwidth. However, cloud phones are deployed on servers whose server-level GPUs do not support these compressed textures. Consequently, these textures must be decompressed into RGBA textures, which significantly increases video RAM usage and lowers the deployment density of cloud phones on servers. This feature allows RGBA textures decompressed in OpenGL ES and Vulkan applications to be compressed into BC textures, effectively reducing video RAM usage.

#### 2.1.2 Constraints

1. For Vulkan, this feature currently supports only decompressing ETC textures (into RGBA) and then compressing them into BC textures. For OpenGL ES, this feature currently supports only decompressing ASTC textures (into RGBA) and then compressing them into BC textures.
2. Runtime modification is not supported. To modify this feature, you must stop the application, apply the changes, and then restart it.
3. The function does not support texture postprocessing. If postprocessing is applied, rendering exceptions may occur. In this case, you need to disable texture compression and restart the application.

#### 2.1.3 Application Scenarios

This feature delivers the best performance in Vulkan applications that heavily use ETC textures, or OpenGL ES applications that heavily use ASTC textures. Other scenarios may show insignificant or no optimization.

### 2.2 Installing the Feature

This feature is integrated into the Android image by default.

### 2.3 Using the Feature

Perform the following steps to use this feature:

1. Set `sys.vmi.vk.texturecompress` to `1` to enable texture compression for Vulkan applications. This function is enabled by default.
2. Set `sys.vmi.gl.texturecompress` to `1` to enable texture compression for OpenGL ES applications. This function is enabled by default.

## 3 Adaptive Frame Synchronization <a name="ZH-CN_TOPIC_0000002518185772"></a>

### 3.1 Feature Description <a name="ZH-CN_TOPIC_0000002518345690"></a>

#### 3.1.1 Overview <a name="ZH-CN_TOPIC_0000002549825541"></a>

One of the key factors affecting user experience of cloud phones is the end-to-end (E2E) operation latency. E2E latency can be divided into three segments: cloud-side latency, network latency, and device-side latency. The Kbox cloud phone solution focuses on the ultimate optimization of cloud-side latency.

The adaptive frame synchronization feature optimizes the graphics rendering pipeline of the Android system, reducing cloud-side latency (defined as the duration from a touch event to the completion of the corresponding image encoding) in mainstream scenarios.

#### 3.1.2 Constraints <a name="ZH-CN_TOPIC_0000002549705545"></a>

1. When adaptive frame synchronization is enabled, the streaming frame rate may briefly exceed the container-configured frame rate in some scenarios. This is expected behavior of this feature's implementation in multi-layer rendering scenarios. However, the feature automatically identifies such scenarios and dynamically adjusts its regulation, preventing this phenomenon from persisting. You can adjust the identification precision by configuring the threshold `vmi.adaptive.vsync.threshold`. A smaller value can reduce the probability of abnormal frame rate spikes, but may result in unstable performance gains from adaptive frame synchronization.

#### 3.1.3 Application Scenarios <a name="ZH-CN_TOPIC_0000002518185774"></a>

This feature has no specific application scenario restrictions, though the performance gains may be unstable in some scenarios. Benchmark tests indicate that stable gains can be achieved in mainstream gaming scenarios.

### 3.2 Installing the Feature <a name="ZH-CN_TOPIC_0000002549825537"></a>

Perform the following steps to integrate this feature:

1. In the Android image, apply the patch `patchForAndroid/frameworks-native-0001.patch` (extracted from `Kbox-patches-AOSP11.zip`; for details, see [Table 1](#kbox-core-functions)).
2. Integrate `AdaptiveVsync.kbox.so` (extracted from `BoostKit-boostcph-kbox_*.zip`; for details, see [Software Environment](compile_guide.md#software-requirements)), into the `/system/vendor/lib64/hw/` directory of the Android image.

### 3.3 Using the Feature <a name="ZH-CN_TOPIC_0000002518345688"></a>

1. Set the cloud phone configuration attribute `ro.vmi.adaptive.vsync` to `1` to enable the feature.
2. During runtime, monitor the value of the cloud phone attribute `vmi.enable.adaptive.vsync`. A value of `1` indicates that the feature is currently active and taking effect. A value of `0` indicates that the feature has been temporarily suspended to mitigate abnormal frame rate spikes.

### 3.4 Feature Benefits

In a 1080P@60fps gaming scenario, this feature reduces server-side latency by approximately 10 ms.

## 4 Kbox Dynamic Frame Rate Adjustment

### 4.1 Feature Description

#### 4.1.1 Overview

When there is no active streaming, cloud phones continue running in the background, and the display keeps refreshing at the active frame rate. In scenarios such AFK gaming or low-streaming periods, a large number of cloud phones on a server may remain in a non-streaming state while still consuming significant hardware resources for rendering, thereby degrading overall server performance. This feature optimizes such scenarios. When a cloud phone is not streaming, its rendering frame rate is throttled to minimize performance overhead. Once the cloud phone resumes streaming, the normal rendering frame rate is restored to guarantee a seamless user experience.

#### 4.1.2 Constraints

To ensure that applications run stably without rendering exceptions after streaming is disconnected and the frame rate drops, the target down-frame-rate configuration is restricted to two values: `12` or `24`.

#### 4.1.3 Application Scenarios

This feature has no specific application scenario restrictions. Scenarios with lower active streaming ratios will yield higher performance and resource-saving gains.

### 4.2 Installing the Feature

This feature is natively included in the Kbox cloud phone components version 25.0.RC1 or later.<br>
This function requires applying `frameworks-native-0001.patch`/`hardware-interfaces-0001.patch`/`hardware-libhardware-0001.patch` located in the `patchForAndroid` directory (extracted from `Kbox-patches-AOSP11.zip`); for details, see [**Table 1**](#kbox-core-functions).

### 4.3 Using the Feature

1. Set the cloud phone configuration attribute `ro.hardware.dynamicfps` to `1` to enable this feature.
2. Set `ro.hardware.downfps` to `12` or `24` to indicate the target value of the dynamic frame rate.
3. Start the cloud phone, establish a connection, and then disconnect the stream. Observe the rendering frame rate of the container (which determines the streaming frame rate). If the feature is working properly, the rendering frame rate will drop to match the configured value of the `ro.hardware.downfps` attribute.

## 5 Android Lightweight Trimming

### 5.1 Feature Description

#### 5.1.1 Overview

By default, the Android system contains many built-in applications and system service processes. During the system startup process, these processes automatically start and run to provide basic system functions and services. For the cloud phone solution, some Android system services are unnecessary, and these redundant processes consume performance resources. Targeting extreme performance scenarios, this feature provides the capability to trim redundant system processes, thereby minimizing system resource consumption and improving overall performance.

#### 5.1.2 Constraints

None

#### 5.1.3 Application Scenarios

This feature has no specific application scenario restrictions.

### 5.2 Installing the Feature

Perform the following steps to enable this feature:

1. When compiling the Android image, follow the instructions in [Compilation Guide](compile_guide.md) and select the `kbox_arm64_optimized-user` compilation option.
2. Complete the remaining compilation steps to obtain the lightweight trimmed Kbox Android image.

### 5.3 Using the Feature

Use the compiled lightweight trimmed Kbox Android image file `android.tar` to deploy the cloud phone container solution. The started cloud phone will run the lightweight trimmed Android OS.

### 5.4 Feature Benefits

In AFK scenarios, after a single cloud phone instance is started, memory usage is reduced by over 5%, and the number of processes is reduced by more than 10.

## 6 Android Composer Optimization

### 6.1 Feature Description

#### 6.1.1 Overview

In the Android graphics subsystem, an application can create multiple layers for rendering, which are ultimately composited into a single frame by the Android SurfaceFlinger module before being displayed. However, in common full-screen gaming scenarios, applications typically utilize single-layer rendering. In such cases, the composition process within the SurfaceFlinger module can be optimized to bypass unnecessary steps, thereby reducing the performance overhead introduced by composition.

#### 6.1.2 Constraints

1. When using Hardware Configuration Scheme 1 ([Installation Guide](./install_guide.md)), enabling the composition bypass feature may cause screen rotation anomalies during specific actions, such as entering/exiting a game or triggering the soft keyboard. Please evaluate the impact based on your specific application scenarios to determine whether to enable this feature.
2. For Kbox cloud phone components version `25.3.0` or later, this feature does not take effect in Hardware Configuration Schemes 2, 3, and 4 ([Installation Guide](./install_guide.md)).

#### 6.1.3 Application Scenarios

This feature has no specific application scenario restrictions. It delivers the expected performance benefits in full-screen gaming scenarios. In other scenarios, it may not yield performance gains, but it will not affect the normal screen display.

### 6.2 Installing the Feature

This feature is natively included in the Kbox cloud phone components version 25.1.RC1 or later.

### 6.3 Using the Feature

1. Set the cloud phone configuration attribute `ro.hardware.compositionBypass` to `1` to enable this feature.
2. The attribute `ro.hardware.compositionBypass.offset` controls the composition bypass feature to take effect only after a specified number of consecutive frames meet the triggering conditions. This attribute can be adjusted based on actual conditions to mitigate the potential screen rotation anomalies that may occur after enabling composition bypass.
3. The feature automatically takes effect upon starting the cloud phone.

### 6.4 Feature Benefits

In full-screen gaming scenarios that satisfy the triggering conditions, GPU usage is optimized and reduced by 10%.

## 7 Thread-Level Shader Cache

### 7.1 Feature Description

#### 7.1.1 Overview

Generally, large-scale mobile applications pre-build some shaders before startup. However, runtime shader processing, including source code loading, compilation, and linking, is still frequently triggered during scene transitions and model effect loading. The prolonged processing time of specific shaders often leads to rendering stutter. By pre-building binary shader files and leveraging multi-container file sharing on the cloud, this feature eliminates runtime compilation and linking overhead, significantly improving rendering efficiency in demanding application scenarios. Furthermore, it allows applications to skip the shader compilation phase upon launch, drastically reducing game startup times. This feature also supports application-level customization of caching behavior via a dedicated configuration file.

#### 7.1.2 Constraints

1. This feature is applicable only to applications utilizing OpenGL ES 3.0 or later.
2. After Shader Cache is enabled, if the required binary shader files have not been pre-cached on the cloud, the application will experience severe lagging during its initial run. It is advised to launch a single cloud phone instance beforehand to pre-collect a comprehensive set of shader files.
3. This feature does not include a cache eviction mechanism. If the file system storage becomes full, manually clear the entire cache directory and expand the storage capacity. When a game version updates, old cache files must be cleared to prevent unnecessary space consumption.

#### 7.1.3 Application Scenarios

This feature delivers optimal performance gains for applications that trigger extensive shader compilation and linking during runtime. For other scenarios, performance optimization may be marginal or unnoticeable.

### 7.2 Installing the Feature

This feature is delivered solely as a binary shared object (`.so`) file. To install it, integrate the `RenderAccLayer.kbox.so` file (extracted from `BoostKit-boostcph-kbox_*.zip`; for details, see [Software Environment](compile_guide.md#software-requirements)) into the `/system/vendor/lib64/hw/` path of the Android image.

### 7.3 Using the Feature

To use this feature, perform the following steps:

1. Enable the feature by setting `ENABLE_RENDER_LAYER` to `1` in the main configuration file (`kbox_config.cfg` for Kbox images or `cfct_config` for video stream images).
2. Copy the `kboxrenderaccelerating_configuration.xml` configuration file from the `Kbox-patches-AOSP11.zip` package to your current startup directory.
3. Open the `kboxrenderaccelerating_configuration.xml` file to configure the shader caching behavior for specific applications. For details about the configuration items, see [3.1.2 Configuration Items of the Graphics Acceleration Layer](https://gitcode.com/wyc3111/vmi/blob/CloudPhone/docs/en/user_guide.md#312-configuration-items-of-the-graphics-acceleration-layer).
4. Launch a cloud phone and run the configured application. Verify that the corresponding application cache files have been generated in the `vender/shader_cache` directory on the container.
   > **Note**: Enabling this feature or modifying the `SHADER_CACHE_DIR_SIZE` parameter requires launching a new cloud phone to take effect.
5. To modify the Shader Cache mode, update the `SHADER_CACHE_MODE` parameter in the `kbox_render_accelerating_configuration.xml` file, copy it to the `/data/local/tmp/` directory within the cloud phone container, and restart the target application.

## 8 Boot with the F2FS File System

### 8.1 Feature Description

#### 8.1.1 Overview

In the mobile hardware domain, F2FS is the standard file system format for modern Android retail devices. Currently, cloud phones operate within host environments that typically utilize the ext4 file system. This discrepancy in file formats significantly degrades device simulation fidelity and escalates the risk of detection and interception by risk control policies. Therefore, to enhance the simulation authenticity of cloud phones, underlying support for the F2FS format has been implemented within the cloud phone containers.

#### 8.1.2 Constraints

1. Kernel compatibility: The host OS kernel must contain and enable the F2FS kernel module. If the kernel lacks the required driver or compilation options, the system will fail to recognize and mount storage media formatted in F2FS.
2. Storage resource prerequisites: A physical disk, partition, or logical volume device formatted in F2FS must be available in the system environment. This device must be functional and meet the physical prerequisites for being mounted to the `data` directory under the data volume.

#### 8.1.3 Application Scenarios

This feature has no specific application scenario restrictions.

### 8.2 Usage Guide

#### 8.2.1 **Usage** <a name="ZH-CN_TOPIC_0000002549865941"></a>

##### 8.2.1.1 **Preparing the Environment**

   Verify whether the f2fs tool package is installed, confirm that the F2FS module is loaded into the host kernel, and install the user-space tools:

   ```shell
   yum install f2fs-tools
   ```

   Check whether the current kernel supports F2FS.

   ```shell
   cat /proc/filesystems | grep f2fs
   ```

If "f2fs" is returned, proceed directly to the section "Creating an F2FS Disk and Mounting It to a Specified Directory".

If the output is empty, the current kernel does not support the F2FS file system. You must recompile a kernel with F2FS support. During compilation, ensure that `CONFIG_F2FS_FS` is set to `y` in the `.config` file. For details on kernel compilation, see [Compiling and Installing the Kernel](install_guide.md#ZH-CN_TOPIC_0000002549832103) of the _Installation Guide_.

##### 8.2.1.2 **Creating an F2FS Disk and Mounting It to a Specified Directory**

Note: This step is optional. If the `data` directory under the data volume is not mounted to an F2FS disk, enabling the F2FS file system switch may adversely impact performance.

Run the following command to check the disk status in the current environment:

   ```shell
   lsblk -f
   ```

If an F2FS disk is already mounted to the `data` directory under the data volume, skip directly to [Using the Feature](feature_guide.md#ZH-CN_TOPIC_0000002549745952).

Run the following command to create a physical disk partition:

   ```shell
   fdisk /dev/${target_physical_disk_name}
   ```

The system re-reads the partition table:

   ```shell
   partprobe /dev/${target_physical_disk_name}
   ```

Format the new partition to F2FS:

   ```shell
   mkfs.f2fs /dev/${new_logical_partition_name}
   ```

Modify the mounting configuration file to enforce the `f2fs` mount type.

Edit the mounting configuration file:

   ```shell
   vim /etc/fstab
   ```

Append the following mounting entry:

   ```text
   UUID=${UUID} ${data_disk_mount_dir}/data  f2fs defaults
   ```

Mount the new partition and apply changes:

   ```shell
   mount -a
   systemctl daemon-reload
   ```

#### 8.2.2 Using the Feature <a name="ZH-CN_TOPIC_0000002549745952"></a>

1. The `ENABLE_F2FS` parameter in `kbox_config.cfg` controls the F2FS file system switch. The default value is `0`, which indicates the feature is disabled.

2. To enable the feature, set `ENABLE_F2FS` to `1` in the container configuration file `kbox_config.cfg`.

3. While the container is running, execute the following command inside the container to verify the file system format. If "f2fs" is returned, the feature is active and taking effect; if any other format appears, the configuration has not taken effect.

    ```shell
    mount | grep -i /data
    ```

## 9. Adjustable /system Partition Size Within Containers <a name="ZH-CN_TOPIC_0000002549865943"></a>

### 9.1 Feature Description <a name="ZH-CN_TOPIC_0000002549865944"></a>

#### 9.1.1 Overview <a name="ZH-CN_TOPIC_0000002549745956"></a>

On physical mobile terminal devices (retail devices), the capacity of the Android /system partition is typically bounded within a fixed and finite range (approximately 2 GB to 15 GB). In current cloud phone architectures, core filesystem layers such as the internal /system directory are universally mapped using Docker's Overlay2 unified filesystem. By default, OverlayFS directly inherits the total disk capacity of the host's underlying Docker data root directory, which frequently scales up to the terabyte (TB) level in server environments. This extreme storage capacity anomaly easily triggers environmental audits by third-party applications. To enhance the device simulation capabilities of cloud phone containers, this solution delivers dynamic restriction and adjustment capabilities for the /system partition capacity at the individual cloud phone instance level.

#### 9.1.2 Constraints <a name="ZH-CN_TOPIC_0000002549865952"></a>

1. Underlying filesystem dependency: The target disk hosting the cloud phone container data must be formatted with the XFS filesystem. If the filesystem does not support this capability, the capacity configuration will fail to take effect.
2. Mount option compliance: The operations scripts or `/etc/fstab` configuration responsible for mounting the data disk must include and successfully apply the `pquota` parameter. If the disk is mounted with default parameters, even if the underlying file system is XFS, Docker will throw an exception or fail to apply the quota when attempting to launch the cloud phone using the `--storage-opt size` parameter.
3. Parameter configuration limit: The configurable size of the /system partition is bounded. If the configured parameter exceeds the total size of the Docker root directory, the assigned capacity of the /system partition will automatically cap at the maximum size of the Docker root directory.

#### 9.1.3 Application Scenarios <a name="ZH-CN_TOPIC_0000002518226174"></a>

This feature has no specific application scenario restrictions.

### 9.2 Usage Guide<a name="ZH-CN_TOPIC_0000002549865942"></a>

#### 9.2.1 Installing the Feature <a name="ZH-CN_TOPIC_0000002518386093"></a>

##### 9.2.1.1 **Creating and Mounting an XFS Disk**

   Run the following command to check the disk status in the current environment:

   ```shell
   lsblk -f
   ```

If an XFS-formatted disk is already mounted to the Docker root directory (typically `/var/lib/docker` by default), skip directly to [Triggering Partition Expansion Logic](feature_guide.md#ZH-CN_TOPIC_0000002549832550).

Run the following command to create a physical disk partition:

   ```shell
   fdisk /dev/${target_physical_disk_name}
   ```

The system re-reads the partition table:

   ```shell
   partprobe /dev/${target_physical_disk_name}
   ```

Format the new partition to XFS:

   ```shell
   mkfs.xfs /dev/${new_logical_partition_name}
   ```

Modify the mounting configuration file to enforce the `xfs` mount type.

Edit the mounting configuration file:

   ```shell
   vim /etc/fstab
   ```

Run the following command to retrieve the UUID of the newly created disk partition:

   ```shell
   lsblk -f
   ```

The string of alphanumeric characters displayed under the UUID column is the partition's UUID.

Append the following mounting entry:

   ```text
   UUID=${UUID} ${docker_root_dir}  xfs defaults,pquota 0 2
   ```

Mount the new partition and apply changes:

   ```shell
   mount -a
   systemctl daemon-reload
   ```

##### 9.2.1.2 **Triggering the Partition Expansion Logic** <a name="ZH-CN_TOPIC_0000002549832550"></a>

   In the cloud phone configuration file `kbox_config.cfg`, set `SYSTEM_PARTITION_SIZE_MB` to the target capacity for the `/system` partition, in MB.

   ```txt
   SYSTEM_PARTITION_SIZE_MB=${target_system_partition_size_in_MB}
   ```

#### 9.2.2 Using the Feature <a name="ZH-CN_TOPIC_0000002549745950"></a>

1. The container configuration attribute `SYSTEM_PARTITION_SIZE_MB` controls whether this feature is active. The default value is `0`, which indicates the feature is disabled. Specifying a non-zero integer enables the feature and sets the target size of the /system partition in MB.

2. During runtime, inspect whether the actual size of the cloud phone's /system partition matches the configured attribute value. If they match, the feature is active and taking effect; if they do not match, the configuration has not taken effect.

## 10 NFS Mount Support <a name="nfs-mount-support"></a>

### 10.1 Feature Description

#### 10.1.1 Overview

The current cloud phone solution uses a converged compute-and-storage architecture where data is stored locally, preventing storage resource reuse. To achieve disaggregated storage and compute as well as storage resource reuse, this feature supports mounting the data storage layer to a remote server via the Network File System (NFS). NFS allows instances to access files on a remote server over the network as if they were interacting with a local disk.

#### 10.1.2 Constraints

NFS relies on a typical **Client/Server (C/S)** architecture. Both the client and the server must include the kernel modules nfs, nfsd, and nfsv4, and must have the nfs-utils and rpcbind packages installed.

#### 10.1.3 Application Scenarios

This feature applies to scenarios including storage-compute disaggregation and storage resource reuse.

### 10.2 Installing the Feature

#### 10.2.1 Client/Server Common Operations

1. Check whether the NFS module is loaded to the kernel.

```shell
cat /lib/modules/$(name -r)/build/.config | grep NFS
```

If the parameters `CONFIG_NFS_FS`, `CONFIG_NFS_V4`, or `CONFIG_NFSD` are output with a value of `m`, execute the following commands to load the modules:

```shell
modprobe nfs
modprobe nfsd
modprobe nfsv4
```

1. Install the nfs-utils software package.

```shell
yum install nfs-utils rpcbind
```

#### 10.2.2 Server Configuration

1. Create the target export directory:

```shell
mkdir -p /home/nfs
```

1. Edit the `/etc/exports` file as follows:

```shell
/home 192.168.20.0/24(rw,fsid=0,sync,no_root_squash)
/home/nfs 192.168.20.0/24/(rw,sync,no_root_squash)
```

1. Restart related services.

```shell
systemctl restart rpcbind
systemctl restart nfs
```

1. Check whether the directory has been successfully exported:

```shell
exportfs
```

Expected output: the directories configured in Step 2.

#### 10.2.3 Client Configuration

1. Create a mount point.

```shell
mkdir -p /tmp/nfs
```

1. Mount the NFS directory of the server.

```shell
mount -t nfs4 192.168.20.XX:/nfs /tmp/nfs
```

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>Because the server's `/etc/exports` file configures `fsid=0` for the `/home` directory, the `/home` path remains hidden from the client. Therefore, the client only needs to mount the `/nfs` directory.

### 10.3 Using the Feature

1. In the container configuration file `kbox_config.cfg`, set the `NFS_DIR` attribute to `/tmp/nfs`. Start the cloud phone using the `nstart` command:

```shell
./android_kbox.sh nstart kbox:origin 1
```

1. After the container starts up, verify whether the contents under the mapped `data/containerd` path match the active container ID:

```shell
cat /tmp/nfs/data/kbox_1/data/containerd
```

## 11 Dynamic CPU Frequency Simulation and Regulation <a name="ZH-CN_TOPIC_00000025498659400"></a>

### 11.1 Feature Description <a name="ZH-CN_TOPIC_000000254986592"></a>

#### 11.1.1 Overview <a name="ZH-CN_TOPIC_000000254974595"></a>

On physical mobile terminal devices, the OS utilizes the CPUFreq subsystem to dynamically regulate the operating frequency of the CPU based on the real-time computational load, balancing performance and power consumption. In contrast, cloud phones run inside containerized environments on server hosts, meaning their underlying physical CPU frequencies remain constant. Such distinct hardware behavioral anomalies can be easily and accurately detected by security and risk control systems. This subsequently leads to the cloud phone instance being flagged as a non-authentic device, triggering immediate blocking or performance degradation. To enhance the low-level hardware behavior simulation fidelity, this solution introduces the dynamic CPU frequency simulation and regulation feature to significantly harden cloud phone container masking.

#### 11.1.2 Constraints <a name="ZH-CN_TOPIC_0000002549865950"></a>

During the system initialization or container startup phase, the target data directories and their internal core files must have write permissions explicitly granted to the processes executing the frequency-writing operations. Insufficient permissions will result in node data override failures, causing the feature to fail.

#### 11.1.3 Application Scenarios <a name="ZH-CN_TOPIC_0000002518226175"></a>

This feature has no specific application scenario restrictions.

### 11.2 Usage Guide <a name="ZH-CN_TOPIC_00000025498659431"></a>

#### 11.2.1 Installing the Feature <a name="ZH-CN_TOPIC_0000002518386097"></a>

##### 11.2.1.1 **Checking Permissions**

   Run the following commands inside the container to check whether write permissions are granted to the target node files within the data path. Insufficient privileges will cause data write failures:

   ```shell
   ls -ld /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```shell
   ls -ld /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/cpuinfo_cur_freq
   ```

If the output contains `w` (such as `-rw-r--r--`), the file owner (typically `root`) possesses write permissions. Proceed directly to [File Description](feature_guide.md#ZH-CN_TOPIC_0000002549832553).

If the output does not contain `w` (for example, the output contains `-r--r--r--`), the file is read-only. Follow the steps below.

##### 11.2.1.2 **Granting Write Permissions** <a name="ZH-CN_TOPIC_0000002549832559"></a>

Run the following command inside the container to append user write (`w`) permissions to `scaling_cur_freq`:

```shell
chmod u+w /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
```

Run the following command inside the container to append user write (`w`) permissions to `cpuinfo_cur_freq`:

```shell
chmod u+w /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/cpuinfo_cur_freq
```

##### 11.2.1.3 **File Description** <a name="ZH-CN_TOPIC_0000002549832553"></a>

   Inside the container, the `/sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/` directory typically contains the following files. Check the table below for details.

   | File Name| Function and Tracked Info| Suggestion and Description (Function Implementation Guide)|
| :--- | :--- | :--- |
| **`scaling_cur_freq`** | **Current operating frequency determined by the active kernel governor.**. Most applications s and security risk control systems read this file to determine the real-time device status.|  For dynamic CPU frequency regulation, the core implementation relies on injecting values into the path.|
| **`scaling_governor`** | CPU frequency regulation policy (governor) currently in effect.|   |
| **`scaling_setspeed`** | Target frequency requested by the user space.| |
| **`scaling_available_frequencies`** | **List of all available discrete frequency steps supported by the current hardware and kernel drivers** (e.g., `300000 600000 1000000 ...`).| Never inject arbitrary numbers during frequency regulation. You are advised to read this file and select a value from this supported frequency list to prevent the value from being identified as a non-standard frequency value by the risk control system.|
| **`scaling_available_governors`** | **List of all frequency regulation policies (governors) supported by the system.**|   |
| **`scaling_max_freq`** | **Maximum frequency allowed by the software policy.**| **Upper frequency limit.** If you want to reduce the frequency to save power or simulate an entry-level device, you may need to modify this file to ensure that the maximum frequency does not exceed the specified value.|
| **`scaling_min_freq`** | **Minimum frequency allowed by the software policy.**| **Lower frequency limit.** If you want to ensure the minimum performance or simulate the standby state of a high-performance device, you may need to modify this file to prevent the frequency from being too low, which may cause simulation profile distortion (exposure of the device mask).|
| **`scaling_driver`** | **Name of the CPU frequency driver in use.** |  |
| **`cpuinfo_cur_freq`** | **Actual current running frequency of the CPU hardware.**| If only `scaling_cur_freq` is modified, it may be identified and intercepted. Therefore, you are advised to modify this file after modifying `scaling_cur_freq`.|
| **`cpuinfo_max_freq`** | **Maximum frequency supported by the CPU hardware physically.**| It is used to obtain the upper limit of the physical performance of the CPU allocated to the cloud phone instance during initialization.|
| **`cpuinfo_min_freq`** | **Minimum frequency supported by the CPU hardware physically.**| It is used to assist in generating the lower boundary of a reasonable frequency fluctuation curve.|
| **`cpuinfo_transition_latency`** | **Time delay (nanoseconds) required for switching between different CPU frequencies.**| The interval for writing `echo` twice consecutively should not be less than this delay value.|
| **`affected_cpus`** | **List of logical CPU cores that require simultaneous frequency adjustment.** In some architectures, the CPU frequencies of the same cluster must be bound.| When compiling a script for globally controlling the frequencies within a cluster, you need to read this file. For example, if the frequency of CPU0 is changed, ensure that the frequencies of other CPUs in the list are also changed or the same value is displayed.|
| **`related_cpus`** | **List of all CPUs that belong to the same group physically (regardless of whether they are currently online or woken up).**| Similar to `affected_cpus`, it is used to analyze the underlying CPU cluster topology and guide the compilation of the multi-core frequency simulation script.|

#### 11.2.2 Execution of Modification <a name="ZH-CN_TOPIC_0000002549745956"></a>

Current third-party detection applications generally read the two files `scaling_cur_freq` and `cpuinfo_cur_freq` to retrieve the current device's CPU operating frequency. To improve the simulation capabilities of the cloud phone device, enter the following command in the container to read the frequency list supported by the CPU before modification. In addition, you need to modify both files.

   ```shell
   cat /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_available_frequencies
   ```

   Subsequently, enter the following two commands inside the container to execute modifications. The entered frequency value should ideally be the current CPU-supported frequency values just retrieved.

   ```shell
   echo ${expected_value} > /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```shell
   echo ${expected_modified_value} > /sys/devices/system/cpu/cpu${CPU_number_prepared_for_frequency_modification}/cpufreq/cpuinfo_cur_freq
   ```

   If the container restarts, the previous modifications will become invalid, and the CPU frequency values will restore to defaults.

   To regulate the CPU frequency dynamically, you can directly copy and paste the following `shell` command into any path inside the container to execute it. Then, you can observe the dynamic changes of the CPU frequency in third-party applications such as "Device Info". `sleep 1` here indicates a change every 1 second, and `1` here can be modified to other time values. The `FREQS` array stores the possible values of the CPU frequency, and `CPU_ID` stores the number of the CPUs expected to be modified. These three values can be modified according to actual needs.

   ```shell
   CPU_ID=0
   FREQS=(554000 860000 956000 1042000 1128000 1224000 1320000 1397000 1512000 1628000 1748000 1858000 1954000)

   while true; do
      for FREQ in "${FREQS[@]}"; do
         echo $FREQ > /sys/devices/system/cpu/cpu${CPU_ID}/cpufreq/scaling_cur_freq 2>/dev/null
         echo $FREQ > /sys/devices/system/cpu/cpu${CPU_ID}/cpufreq/cpuinfo_cur_freq 2>/dev/null
         echo "CPU${CPU_ID} frequency dynamically regulated to: $FREQ"
         sleep 1
      done
   done
   ```
