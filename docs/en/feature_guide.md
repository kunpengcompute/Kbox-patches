# Feature Guide<a id="ZH-CN_TOPIC_0000002521623660"></a>

<!-- md-trans-meta sourceCommit=fe4602aaa53ae3325430d3d6870389fdbf1acc74 translatedAt=2026-09-18T10:23:00.301Z pushedAt=2026-09-20T10:40:01.650Z -->

## Feature Description<a id="ZH-CN_TOPIC_0000002549825543"></a>

The Kbox cloud phone container is the core component of the cloud phone Turbo toolkit in Kunpeng BoostKit. This document describes the basic concepts of the Kbox cloud phone container and how to compile, deploy, and configure the Kbox cloud phone container.

The cloud phone solution is a virtual phone service virtualized based on the Arm server and runs the Android Open Source Project (AOSP). In short, cloud phones are Arm servers that run the Android OS and function as virtual phones. You can remotely control the cloud phone in real time to run Android applications on the cloud. Based on the basic computing power of cloud phones, you can also efficiently build applications for scenarios like cloud gaming, mobile office, and live streaming interaction.

As the foundational software for running Android applications, the Kbox cloud phone container is an important part of the cloud phone Turbo toolkit in Kunpeng BoostKit. It directly runs the AOSP system in a container, mocks peripheral hardware such as the GPS sensor, acceleration sensor, gyroscope, international mobile equipment identity (IMEI), and Wi-Fi, and implements the Gralloc and HWComposer (HWC) modules, ensuring normal startup and running of the AOSP system. With a series of optional features, the Kbox cloud phone container can enhance the functions or performance of cloud phones in various service scenarios.

[**Table 1**](#kbox-core-functions) lists the core functions of Kbox and [**Table 2**](#optional-features-of-kbox) details its optional features. To enable Kbox core functions, simply integrate the Kbox cloud phone container by following the instructions in [Compilation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/compile_guide.md) and [Installation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/install_guide.md). Information on the optional features is detailed in the sections below.

**Table 1** Kbox core functions<a id="kbox-core-functions"></a>

|Name|Description|
|--|--|
|Android Kbox cloud phone container solution| Kbox cloud phone container reference solution based on openEuler (host OS) and Android (guest OS). The CTS compatibility rate is greater than 98%.|
|Direct GPU rendering and mainstream graphics APIs| Direct GPU rendering in containers, supporting OpenGL ES 2.0/3.0/3.1/3.2 and Vulkan 1.1 graphics APIs. The dEQP compatibility rate is greater than 98%.|
|Hardware acceleration for video playback on cloud phones| Hardware acceleration for video playback on cloud phones, implementing hardware-based H.264 and H.265 decoding acceleration for video playback, reducing CPU load, and improving performance in media scenarios.|
|Kbox kernel dynamic switch|Dynamic switch, enabling the host OS image used by the cloud phone to be shared by other services.|
|YCbCr_420_888 format| YCbCr_420_888 supported by the Gralloc module, resolving the black screen issue.|
|Resource monitoring| Monitoring GPU memory and other memory resources in real time so that customers can perform operations based on resource usage.|

**Table 2** Optional features of Kbox<a id="optional-features-of-kbox"></a>

|Name|Description|
|--|--|
|Adaptive texture compression| Adaptive texture compression based on open-source Mesa, supporting conversions of Vulkan RGB and RGBA textures to DXT textures.|
|Adaptive frame synchronization| Adaptive vertical synchronization (vsync), enabling SurfaceFlinger to compose one frame immediately after it is rendered and send it to the screen.|
|Kbox dynamic frame rate adjustment| Dynamically decreases the frame rate to reduce rendering overhead when the client is disconnected from the cloud phone in the away from keyboard (AFK) scenario.|
|Android lightweight trimming| Removes unnecessary system services and built-in applications to reduce cloud phone resource usage, thereby improving system performance and optimizing user experience.|
|Android composer optimization| When a game app is displayed in full screen and only the game app layer is present, the composition step can be skipped and image rotation from landscape to portrait can be omitted, reducing GPU overhead.|
|Thread-level shader cache| Pre-built binaries cut shader compilation and linking time, improving rendering efficiency of large-scale applications.|
|Boot in F2FS format|Enables the cloud phone to boot using the Flash-Friendly File System (F2FS) file format by adding specific configuration options. This utilizes the same file system as physical phones, thereby enhancing emulation capabilities.|
|`/system` partition size adjustment|Allows users to manually adjust the `/system` partition size within the cloud phone container by adding configuration options. This aligns the partition closer to that of a physical device, thereby enhancing emulation capabilities.|

## Adaptive Texture Compression

### Feature Description

#### Overview

In mobile applications, compressed textures such as ETC and ASTC are widely used. They are natively supported by mobile GPUs to reduce video RAM footprint and save bandwidth. However, cloud phones are deployed on servers whose server-level GPUs do not support these compressed textures. Consequently, these textures must be decompressed into RGBA textures, which significantly increases video RAM usage and lowers the deployment density of cloud phones on servers. This feature allows RGBA textures decompressed in OpenGL ES and Vulkan applications to be compressed into BC textures, effectively reducing video RAM usage.

#### Constraints

- For Vulkan, this feature currently supports only decompressing ETC textures and then compressing them into BC textures. For OpenGL ES, this feature currently supports only decompressing ASTC textures and then compressing them into BC textures.
- Runtime modification is not supported. To modify this feature, you must stop the application, apply the changes, and then restart the application.
- The function does not support texture postprocessing. If postprocessing is applied, rendering exceptions may occur. In this case, you need to disable texture compression and restart the application.

#### Application Scenarios

This feature delivers optimal performance in Vulkan applications that heavily use ETC textures, or OpenGL ES applications that heavily use ASTC textures. Other scenarios may show insignificant or no optimization.

### Installing the Feature

This feature is integrated into the Android image by default.

### Using the Feature

Perform the following steps to use this feature:

1. Set `sys.vmi.vk.texturecompress` to `1` to enable texture compression for Vulkan applications. This function is enabled by default.
2. Set `sys.vmi.gl.texturecompress` to `1` to enable texture compression for OpenGL ES applications. This function is enabled by default.

## Adaptive Frame Synchronization<a id="ZH-CN_TOPIC_0000002518185772"></a>

### Feature Description<a id="ZH-CN_TOPIC_0000002518345690"></a>

#### Overview<a id="ZH-CN_TOPIC_0000002549825541"></a>

One of the key factors affecting user experience of cloud phones is the end-to-end (E2E) operation latency. E2E latency can be divided into three segments: cloud-side latency, network latency, and device-side latency. The Kbox cloud phone solution focuses on the ultimate optimization of cloud-side latency.

The adaptive frame synchronization feature optimizes the graphics rendering pipeline of the Android system, reducing cloud-side latency (defined as the duration from a touch event to the completion of the corresponding image encoding) in mainstream scenarios.

#### Constraints<a id="ZH-CN_TOPIC_0000002549705545"></a>

When adaptive frame synchronization is enabled, the streaming frame rate may briefly exceed the container-configured frame rate in some scenarios. This is expected behavior of this feature's implementation in multi-layer rendering scenarios. However, the feature automatically identifies such scenarios and dynamically adjusts its regulation, preventing this phenomenon from persisting. You can adjust the identification precision by configuring the threshold `vmi.adaptive.vsync.threshold`. A smaller value can reduce the probability of abnormal frame rate spikes, but may result in unstable performance gains from adaptive frame synchronization.

#### Application Scenarios<a id="ZH-CN_TOPIC_0000002518185774"></a>

This feature has no specific application scenario restrictions, though the performance gains may be unstable in some scenarios. Benchmark tests indicate that stable gains can be achieved in mainstream gaming scenarios.

### Installing the Feature<a id="ZH-CN_TOPIC_0000002549825537"></a>

Perform the following steps to integrate this feature:

1. In the Android image, apply the patch `patchForAndroid/frameworks-native-0001.patch` (extracted from `Kbox-patches-AOSP11.zip`; for details, see [Table 1](#kbox-core-functions)).
2. Integrate `AdaptiveVsync.kbox.so` (extracted from `BoostKit-boostcph-kbox_*.zip`; for details, see [Software Environment](compile_guide.md#software-requirements)), into the `/system/vendor/lib64/hw/` directory of the Android image.

### Using the Feature<a id="ZH-CN_TOPIC_0000002518345688"></a>

1. Set the container configuration property `ro.vmi.adaptive.vsync` to `1` to enable the feature.
2. At runtime, check whether the value of the cloud phone property `vmi.enable.adaptive.vsync` is `1`. A value of `1` indicates that the feature is enabled; a value of `0` indicates that the feature is temporarily disabled to work around frame rate spikes.

### Feature Benefits

In a 1080p@60 fps gaming scenario, this feature reduces server-side latency by approximately 10 ms.

## Kbox Dynamic Frame Rate Adjustment

### Feature Description

#### Overview

When there is no active streaming, cloud phones continue running in the background, and the display keeps refreshing at the active frame rate. In scenarios such as AFK gaming or low-streaming periods, a large number of cloud phones on a server may remain in a non-streaming state while still consuming significant hardware resources for rendering, thereby degrading overall server performance. This feature optimizes such scenarios. When a cloud phone is not streaming, its rendering frame rate is throttled to minimize performance overhead. Once the cloud phone resumes streaming, the normal rendering frame rate is restored to guarantee a seamless user experience.

#### Constraints

To ensure that applications run stably without rendering exceptions after streaming is disconnected and the frame rate drops, the target down-frame-rate configuration is restricted to two values: 12/24 fps.

#### Application Scenarios

This feature has no specific application scenario restrictions. Scenarios with lower streaming ratios will yield higher performance gains.

### Installing the Feature

This feature is included in the Kbox cloud phone components version 25.0.RC1 or later.
This function requires applying `frameworks-native-0001.patch`/`hardware-interfaces-0001.patch`/`hardware-libhardware-0001.patch` located in the `patchForAndroid` directory (extracted from `Kbox-patches-AOSP11.zip`); for details, see [**Table 1**](#kbox-core-functions).

### Using the Feature

1. Set the container configuration property `ro.hardware.dynamicfps` to `1` to enable the feature.
2. Set `ro.hardware.downfps` to `12` or `24` to indicate the target value of the dynamic frame rate.
3. Start the cloud phone, establish a connection, and then disconnect the stream. Observe the stream output frame rate of the cloud phone. If the feature is working properly, the frame rate after disconnection should match the configured value of the `ro.hardware.downfps` property (the rendering frame rate is ultimately reflected in the stream output frame rate).

## Android Lightweight Trimming

### Feature Description

#### Overview

By default, the Android system contains many built-in applications and system service processes. During the system startup process, these processes automatically start and run to provide basic system functions and services. For the cloud phone solution, some Android system services are unnecessary, and these redundant processes consume performance resources. Targeting extreme performance scenarios, this feature provides the capability to trim redundant system processes, thereby minimizing system resource consumption and improving overall performance.

#### Constraints

None

#### Application Scenarios

This feature has no specific application scenario restrictions.

### Installing the Feature

Perform the following steps to enable this feature:

1. When compiling the Android image, follow the instructions in [Compilation Guide](compile_guide.md) and select the `kbox_arm64_optimized-user` compilation option.
2. Complete the remaining compilation steps to obtain the lightweight trimmed Kbox Android image.

### Using the Feature

Use the compiled lightweight trimmed Kbox Android image file `android.tar` to deploy the cloud phone container solution. The started cloud phone will run the lightweight trimmed Android OS.

### Feature Benefits

In AFK scenarios, after a single cloud phone instance is started, memory usage is reduced by over 5%, and the number of processes is reduced by more than 10.

## Android Composer Optimization

### Feature Description

#### Overview

In the Android graphics subsystem, an application can create multiple layers for rendering, which are ultimately composited into a single frame by the Android SurfaceFlinger module before being displayed. However, in common full-screen gaming scenarios, applications typically utilize single-layer rendering. In such cases, the composition process within the SurfaceFlinger module can be optimized to bypass unnecessary steps, thereby reducing the performance overhead introduced by composition.

#### Constraints

- When using hardware configuration scheme 1 (see [Installation Guide](./install_guide.md)), enabling the composition bypass feature may cause screen rotation anomalies during specific actions, such as entering/exiting a game or triggering the soft keyboard. Please evaluate the impact based on your specific application scenarios to determine whether to enable this feature.
- For Kbox cloud phone components version `25.3.0` or later, this feature does not take effect in hardware configuration schemes 2, 3, and 4 (see [Installation Guide](./install_guide.md)).

#### Application Scenarios

This feature has no specific application scenario restrictions. It delivers the expected performance benefits in full-screen gaming scenarios. In other scenarios, it may not yield performance gains, but it will not affect the normal screen display.

### Installing the Feature

This feature is natively included in the Kbox cloud phone components version 25.1.RC1 or later.

### Using the Feature

1. Set the container configuration property `ro.hardware.compositionBypass` to `1` to enable this feature.
2. The container property `ro.hardware.compositionBypass.offset` controls the composition bypass feature to take effect only after a specified number of consecutive frames meet the triggering conditions. This property can be adjusted based on actual conditions to mitigate the potential screen rotation anomalies that may occur after enabling composition bypass.
3. The feature automatically takes effect upon starting the cloud phone.

### Feature Benefits

In full-screen gaming scenarios that satisfy the triggering conditions, GPU usage is optimized and reduced by 10%.

## Thread-Level Shader Cache

### Feature Description

#### Overview

Generally, large-scale mobile applications pre-build some shaders before startup. However, runtime shader processing, including source code loading, compilation, and linking, is still frequently triggered during scene transitions and model effect loading. The prolonged processing time of specific shaders often leads to rendering stutter. By pre-building binary shader files and leveraging multi-container file sharing on the cloud, this feature eliminates runtime compilation and linking overhead, significantly improving rendering efficiency in demanding application scenarios. Furthermore, it allows applications to skip the shader compilation phase upon launch, drastically reducing game startup times. This feature also supports application-level customization of caching behavior via a dedicated configuration file.

#### Constraints

- This feature is applicable only to applications utilizing OpenGL ES 3.0 or later.
- After shader cache is enabled, if the required binary shader files have not been pre-cached on the cloud, the application will experience severe lagging during its initial run. It is advised to launch a single cloud phone instance beforehand to pre-collect a comprehensive set of shader files.
- This feature does not include a cache eviction mechanism. If the file system storage becomes full, manually clear the entire cache directory and expand the storage capacity. When a game version updates, old cache files must be cleared to prevent unnecessary space consumption.

#### Application Scenarios

This feature works best with applications that involve a large amount of shader compilation and linking during runtime. In other scenarios, there may be no optimization or the optimization may be negligible.

### Installing the Feature

This feature is delivered solely as a binary shared object (`.so`) file. To install it, integrate the `RenderAccLayer.kbox.so` file (extracted from `BoostKit-boostcph-kbox_*.zip`; for details, see [Software Environment](compile_guide.md#software-requirements)) into the `/system/vendor/lib64/hw/` path of the Android image.

### Using the Feature

To use this feature, perform the following steps:

1. Enable the feature by setting `ENABLE_RENDER_LAYER` to `1` in the main configuration file (`kbox_config.cfg` for Kbox images or `cfct_config` for video stream images).
2. Copy the `kbox_render_accelerating_configuration.xml` configuration file from the `Kbox-patches-AOSP11.zip` package to your current startup directory.
3. Open the `kbox_render_accelerating_configuration.xml` file to configure the shader caching behavior for specific applications. For details about the configuration items, see [Configuration Items of the Graphics Acceleration Layer](https://gitcode.com/boostkit/vmi/blob/CloudPhone/docs/en/user_guide.md#configuration-items-of-the-graphics-acceleration-layer).
4. Launch a cloud phone and run the configured application. Verify that the corresponding application cache files have been generated in the `vendor/shader_cache` directory on the container.
   > **Note**: Enabling this feature and setting the `SHADER_CACHE_DIR_SIZE` parameter both require launching a new cloud phone to take effect.
5. To modify the shader cache mode, update the `SHADER_CACHE_MODE` parameter in the `kbox_render_accelerating_configuration.xml` file, copy it to the `/data/local/tmp/` directory within the cloud phone container, and restart the target application.

## Boot in F2FS Format

### Feature Description

#### Overview

In the mobile hardware domain, F2FS is the standard file system format for modern Android retail devices. Currently, cloud phones operate within host environments that typically utilize the ext4 file system. This discrepancy in file formats significantly degrades device emulation fidelity and escalates the risk of detection and interception by risk control policies. Therefore, to enhance the emulation fidelity of cloud phones, underlying support for the F2FS format has been implemented within the cloud phone containers.

#### Constraints

- Kernel compatibility: The host OS kernel must contain and enable the F2FS kernel module. If the kernel lacks the required driver or compilation options, the system will fail to recognize and mount storage media formatted in F2FS.
- Storage resource prerequisites: A physical disk, partition, or logical volume device formatted in F2FS must be available in the system environment. This device must be functional and meet the physical prerequisites for being mounted to the `data` directory under the data volume.

#### Application Scenarios

This feature has no specific application scenario restrictions.

### Usage Guide

#### Usage<a id="ZH-CN_TOPIC_0000002549865941"></a>

##### Preparing the Environment

1. Verify whether the f2fs tool package is installed, confirm that the F2FS module is loaded into the host kernel, and install the user-space tools:

   ```bash
   yum install f2fs-tools
   ```

2. Check whether the current kernel supports F2FS.

   ```bash
   cat /proc/filesystems | grep f2fs
   ```

If "f2fs" is returned, proceed directly to the section "Creating an F2FS Disk and Mounting It to a Specified Directory".

If the output is empty, the current kernel does not support the F2FS file system. In this case, rebuild a kernel that supports F2FS. During compilation, set the kernel compilation option `CONFIG_F2FS_FS` to `Y` in the `.config` file. For the steps to rebuild the kernel, refer to the [Compiling and Installing the Kernel](install_guide.md#ZH-CN_TOPIC_0000002549832103) section in **install_guide.md**.

##### Creating an F2FS Disk and Mounting It to a Specified Directory

Note: This step is optional. If the `data` directory under the data volume is not mounted to an F2FS disk, enabling the F2FS file system switch may adversely impact performance.

1. Run the following command to check the disk status in the current environment:

   ```bash
   lsblk -f
   ```

   If an F2FS disk is already mounted to the `data` directory under the data volume, skip directly to [Using the Feature](feature_guide.md#ZH-CN_TOPIC_0000002549745952).

2. Run the following command to create a physical disk partition:

   ```bash
   fdisk /dev/${target_physical_disk_name}
   ```

3. The system re-reads the partition table.

   ```bash
   partprobe /dev/${target_physical_disk_name}
   ```

4. Format the new partition to F2FS.

   ```bash
   mkfs.f2fs /dev/${new_logical_partition_name}
   ```

5. Modify the mounting configuration file to enforce the `f2fs` mount type.

   1. Edit the mounting configuration.

      ```bash
      vim /etc/fstab
      ```

   2. Append the following mounting entry:

      ```text
      UUID=${UUID} ${data_disk_mount_dir}/data  f2fs defaults
      ```

   3. Mount the new partition and apply changes.

      ```bash
      mount -a
      systemctl daemon-reload
      ```

#### Using the Feature<a id="ZH-CN_TOPIC_0000002549745952"></a>

1. The `ENABLE_F2FS` parameter in `kbox_config.cfg` controls the F2FS file system switch. The default value is `0`, which indicates the feature is disabled.

2. To enable the feature, set `ENABLE_F2FS` to `1` in the container configuration file `kbox_config.cfg`.

3. While the container is running, execute the following command inside the container to verify the file system format. If "f2fs" is returned, the feature is active and taking effect; if any other format appears, the configuration has not taken effect.

    ```bash
    mount | grep -i /data
    ```

## /system Partition Size Adjustment<a id="ZH-CN_TOPIC_0000002549865943"></a>

### Feature Description<a id="ZH-CN_TOPIC_0000002549865944"></a>

#### Overview<a id="ZH-CN_TOPIC_0000002549745956"></a>

On physical mobile devices (real devices), the capacity of the Android `/system` partition typically falls within a relatively fixed and limited range (approximately 2 GB to 15 GB). In existing cloud phone architectures, however, core file system layers such as the `/system` directory inside the container are generally mapped using Docker's Overlay2 union file system. By default, OverlayFS directly inherits the total capacity of the disk hosting the underlying Docker data root directory on the host, which in server environments often reaches the terabyte level. This huge discrepancy in storage capacity magnitude can easily trigger the device environment inspection mechanisms of third-party applications. To improve the emulation capability of cloud phone containers, this solution provides instance-level dynamic adjustment of the `/system` partition capacity for cloud phone instances.

#### Constraints<a id="ZH-CN_TOPIC_0000002549865952"></a>

1. Underlying filesystem dependency: The target disk hosting the cloud phone container data must be formatted with the XFS filesystem. If the filesystem does not support this capability, the capacity configuration will fail to take effect.
2. Mount option compliance: The operations scripts or `/etc/fstab` configurations responsible for mounting the data disk must include and successfully apply the `pquota` parameter. If the disk is mounted with default parameters, even if the underlying file system is XFS, Docker will throw an exception or fail to apply the quota when attempting to launch the cloud phone using the `--storage-opt size` parameter.
3. Parameter configuration limit: The configurable size of the `/system` partition is bounded. If the configured parameter exceeds the total size of the Docker root directory, the assigned capacity of the `/system` partition will automatically cap at the maximum size of the Docker root directory.

#### Application Scenarios<a id="ZH-CN_TOPIC_0000002518226174"></a>

This feature has no specific application scenario restrictions.

### Usage Guide<a id="ZH-CN_TOPIC_0000002549865942"></a>

#### Installing the Feature<a id="ZH-CN_TOPIC_0000002518386093"></a>

##### Creating and Mounting an XFS Disk

1. Run the following command to check the disk status in the current environment:

   ```bash
   lsblk -f
   ```

   If an XFS-formatted disk is already mounted to the Docker root directory (typically `/var/lib/docker` by default), skip directly to [Triggering Partition Expansion Logic](feature_guide.md#ZH-CN_TOPIC_0000002549832550).

2. Run the following command to create a physical disk partition:

   ```bash
   fdisk /dev/${target_physical_disk_name}
   ```

3. The system re-reads the partition table.

   ```bash
   partprobe /dev/${target_physical_disk_name}
   ```

4. Format the new partition to XFS.

   ```bash
   mkfs.xfs /dev/${new_logical_partition_name}
   ```

5. Modify the mounting configuration file to enforce the `xfs` mount type.

   1. Edit the mounting configuration.

      ```bash
      vim /etc/fstab
      ```

   2. Run the following command to retrieve the UUID of the newly created disk partition:

      ```bash
      lsblk -f
      ```

      The string of alphanumeric characters displayed under the UUID column is the partition's UUID.

   3. Append the following mounting entry:

      ```text
      UUID=${UUID} ${docker_root_dir}  xfs defaults,pquota 0 2
      ```

   4. Mount the new partition. Start the xfs driver first, and then enable the new partition mount to take effect.

      ```bash
      modprobe xfs
      mount -a
      systemctl daemon-reload
      ```

##### Triggering Partition Expansion Logic<a id="ZH-CN_TOPIC_0000002549832550"></a>

In the cloud phone configuration file `kbox_config.cfg`, set `SYSTEM_PARTITION_SIZE_MB` to the target capacity for the `/system` partition, in MB.

```txt
SYSTEM_PARTITION_SIZE_MB=${target_system_partition_size}
```

#### Using the Feature<a id="ZH-CN_TOPIC_0000002549745950"></a>

1. The container configuration property `SYSTEM_PARTITION_SIZE_MB` controls whether this feature is active. The default value is `0`, which indicates the feature is disabled. Specifying a non-zero integer enables the feature and sets the target size of the `/system` partition in MB.

2. During runtime, inspect whether the actual size of the cloud phone's `/system` partition matches the configured property value. If they match, the feature is active and taking effect; if they do not match, the configuration has not taken effect.

## NFS Mount Support<a id="NFS-Mount-Support"></a>

### Feature Description

#### Overview

The current cloud phone solution uses a converged compute-storage architecture where data is stored locally, preventing storage resource reuse. To achieve disaggregated storage and compute as well as storage resource reuse, this feature supports mounting the data storage layer to a remote server via the Network File System (NFS). NFS allows instances to access files on a remote server over the network as if they were interacting with a local disk.

#### Constraints

NFS adopts a typical client/server (C/S) architecture. Both the client and the server must include the kernel modules nfs, nfsd, and nfsv4, and have nfs-utils and rpcbind installed.

#### Application Scenarios

This feature applies to scenarios including storage-compute disaggregation and storage resource reuse.

### Installing the Feature

#### Client/Server Common Operations

1. Check whether the NFS module is loaded to the kernel.

   ```bash
   cat /lib/modules/$(uname -r)/build/.config | grep NFS
   ```

   If the parameters `CONFIG_NFS_FS`, `CONFIG_NFS_V4`, or `CONFIG_NFSD` are output with a value of `m`, execute the following commands to load the modules:

   ```bash
   modprobe nfs
   modprobe nfsd
   modprobe nfsv4
   ```

2. Install the nfs-utils software package.

   ```bash
   yum install nfs-utils rpcbind
   ```

#### Server Configuration

1. Create the directory to be exported.

   ```bash
   mkdir -p /home/nfs
   ```

2. Edit the `/etc/exports` file as follows:

   ```bash
   /home 192.168.20.0/24(rw,fsid=0,sync,no_root_squash)
   /home/nfs 192.168.20.0/24/(rw,sync,no_root_squash)
   ```

3. Restart the related services.

   ```bash
   systemctl restart rpcbind
   systemctl restart nfs
   ```

4. Check whether the directory has been successfully exported.

   ```bash
   exportfs
   ```

   Expected output: the directories configured in step 2.

#### Client Configuration

1. Create a mount point.

   ```bash
   mkdir -p /tmp/nfs
   ```

2. Mount the NFS directory of the server.

   ```bash
   mount -t nfs4 192.168.20.XX:/nfs /tmp/nfs
   ```

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>Because the server's `/etc/exports` file configures `fsid=0` for the `/home` directory, the `/home` path remains hidden from the client. Therefore, the client only needs to mount the `/nfs` directory.

### Using the Feature

1. In the container configuration file `kbox_config.cfg`, set the `NFS_DIR` attribute to `/tmp/nfs`. Start the cloud phone using the `nstart` command:

   ```bash
   ./android_kbox.sh nstart kbox:origin 1
   ```

2. After the container starts, run the following command to check:

   ```bash
   docker inspect kbox_1 | jq -r '.[].Mounts[] | select(.Destination=="/data") | .Source'
   ```

   The expected result is `/tmp/nfs/data/kbox_1/data`.

## Dynamic CPU Frequency Emulation and Regulation<a id="ZH-CN_TOPIC_00000025498659400"></a>

### Feature Description<a id="ZH-CN_TOPIC_000000254986592"></a>

#### Overview<a id="ZH-CN_TOPIC_000000254974595"></a>

On physical mobile terminal devices, the OS utilizes the CPUFreq subsystem to dynamically regulate the operating frequency of the CPU based on the real-time computational load, balancing performance and power consumption. In contrast, cloud phones run inside containerized environments on server hosts, meaning their underlying physical CPU frequencies remain constant. Such distinct hardware behavioral anomalies can be easily and accurately detected by risk control systems. This subsequently leads to the cloud phone instance being flagged as a non-authentic device, triggering immediate blocking or performance degradation. To enhance the low-level hardware behavior emulation fidelity, this solution introduces the dynamic CPU frequency emulation and regulation feature to significantly harden cloud phone container masking.

#### Constraints<a id="ZH-CN_TOPIC_0000002549865950"></a>

During the system initialization or container startup phase, the target data directories and their internal core files must have write permissions explicitly granted to the processes executing the frequency-writing operations. Insufficient permissions will result in node data override failures, causing the feature to fail.

#### Application Scenarios<a id="ZH-CN_TOPIC_0000002518226175"></a>

This feature has no specific application scenario restrictions.

### Usage Guide<a id="ZH-CN_TOPIC_00000025498659431"></a>

#### Installing the Feature<a id="ZH-CN_TOPIC_0000002518386097"></a>

##### Checking Permissions

   Run the following commands inside the container to check whether write permissions are granted to the target files in the data path. Insufficient privileges will cause data write failure.

   ```bash
   ls -ld /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```bash
   ls -ld /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/cpuinfo_cur_freq
   ```

If the output contains `w` (such as `-rw-r--r--`), the file owner (typically `root`) possesses write permissions. Proceed directly to [File Description](feature_guide.md#ZH-CN_TOPIC_0000002549832553).

If the output does not contain `w` (for example, the output contains `-r--r--r--`), the file is read-only. Follow the steps below.

##### Granting Write Permissions<a id="ZH-CN_TOPIC_0000002549832559"></a>

Run the following command inside the container to append user write (`w`) permissions to `scaling_cur_freq`:

```bash
chmod u+w /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
```

Run the following command inside the container to append user write (`w`) permissions to `cpuinfo_cur_freq`:

```bash
chmod u+w /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/cpuinfo_cur_freq
```

##### File Description<a id="ZH-CN_TOPIC_0000002549832553"></a>

Inside the container, the `/sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/` directory typically contains the following files. Check the table below for details.

| File Name| Function and Tracked Info| Suggestion and Description (Function Implementation Guide)|
| :--- | :--- | :--- |
| `scaling_cur_freq` | The current operating frequency determined by the kernel governor. Most apps and risk control systems read this file to determine the real-time operating status of the device. |  When performing dynamic CPU frequency regulation, the core operation is to overwrite the value in this file. |
| `scaling_governor` | The current CPU frequency scaling policy (governor). |   |
| `scaling_setspeed` | The target frequency requested by user space. | |
| `scaling_available_frequencies` | The list of all available frequency levels supported by the current hardware and driver. (For example: `300000 600000 1000000 ...`) | When adjusting the frequency, never write an arbitrary number. It is recommended to read this file and select a value from the supported frequency list, to prevent being identified by the risk control system through an "illegal frequency band". |
| `scaling_available_governors` | The list of all scaling policies (governors) currently supported by the system. |   |
| `scaling_max_freq` | The maximum frequency limit allowed by the software policy. | The frequency upper limit is capped. When implementing "frequency reduction for power saving" or "emulating a low-end device", this file may be modified to ensure that the emulated maximum frequency does not exceed this set value. |
| `scaling_min_freq` | The minimum frequency limit allowed by the software policy. | The frequency lower limit serves as the floor. When implementing "performance guarantee" or "emulating a high-performance device in standby", this file may be modified to prevent the frequency from dropping too low and causing disguise distortion. |
| `scaling_driver` | The name of the CPU frequency driver currently in use.  |  |
| `cpuinfo_cur_freq` | The actual current operating frequency at the CPU hardware level. | If only `scaling_cur_freq` is modified, it may be identified and intercepted. Therefore, after modifying `scaling_cur_freq`, it is recommended to modify this file synchronously. |
| `cpuinfo_max_freq` | The maximum frequency physically supported by the CPU hardware. | Used to obtain the upper limit of the CPU physical performance allocated to this cloud phone instance during initialization. |
| `cpuinfo_min_freq` | The minimum frequency physically supported by the CPU hardware. | Used to assist in generating the lower boundary of a reasonable frequency fluctuation curve. |
| `cpuinfo_transition_latency` | The time latency (in nanoseconds) required for the CPU to switch between different frequencies. | The time interval between two `echo` writes should not be less than this latency value. |
| `affected_cpus` | The list of CPU logical cores that need to be frequency-adjusted simultaneously. Under certain architectures, the CPU frequencies of the same cluster must be bound. | When writing a group-control frequency regulation script, this file needs to be read. For example, if the frequency of CPU0 is modified, it must be ensured that the other CPUs in this list are also modified synchronously or display the same value. |
| `related_cpus` | The list of all CPUs that physically belong to the same group (regardless of whether they are currently online/awake). | Similar to `affected_cpus`, it is mainly used to analyze the underlying CPU cluster topology and guide the writing of multi-core frequency emulation scripts. |

#### Modification Method<a id="ZH-CN_TOPIC_0000002549745956"></a>

Current third-party detection applications generally read the two files `scaling_cur_freq` and `cpuinfo_cur_freq` to retrieve the current device's CPU operating frequency. To improve the emulation capabilities of the cloud phone device, enter the following command in the container to read the frequency list supported by the CPU before modification. In addition, you need to modify both files.

   ```bash
   cat /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_available_frequencies
   ```

   Next, run the following two commands inside the container to modify the frequencies. It is recommended that the input frequency values match one of the supported CPU frequencies retrieved in the previous step.

   ```bash
   echo ${target_frequency} > /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```bash
   echo ${target_frequency} > /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/cpuinfo_cur_freq
   ```

   If the container restarts, the previous modifications will become invalid, and the CPU frequency values will restore to defaults.

   To achieve dynamic CPU frequency regulation, you can copy and paste the following shell script to any path inside the container and execute it. This allows you to observe dynamic CPU frequency changes in third-party applications (such as "Device Info"). In this script, `sleep 1` specifies a 1-second interval between changes, which can be modified as required. The `FREQS` array stores the potential CPU frequency values, and `CPU_ID` specifies the index of the CPU to be modified. These three values can be adjusted based on your actual requirements.

   ```bash
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

## Shared Data Volume

### Feature Description

#### Overview

  Before the shared data volume is enabled, the data of each container is stored in a separate mount directory on the host, and data cannot be shared between containers. After the shared data volume is enabled, the `/data` directory of the cloud phone is created by Docker based on the Overlay2 file system as a writable layer. After completing application installation, login, and image quality and frame rate settings, commit the container as a new image (this image will be noticeably larger than the initial video stream cloud phone image, because the new image contains the data under the cloud phone's `/data` directory). At this point, the cloud phone's `/data` directory is frozen as a new image layer. Then, based on this new image, start new cloud phones. The new cloud phones use the `/data` layer in the image as the initial read-only layer, and each container creates its own writable layer. Modifications made by the cloud phone to the `/data` directory are written to its own writable layer through copy-on-write.

#### Constraints

- The `android_base` or `android_base.img` data volume cannot be created.
- Account data cannot be saved using the `tstart` or `tdelete` method. Only `start/delete/restart` are supported for creating/deleting/restarting containers.
- When a game update is required, it is recommended to recreate the image of the shared data volume.
- The F2FS and NFS mount solutions are not supported.
- The Kubernetes solution is not supported.
- After the shared data volume is enabled, container data is stored in the Docker working path. Before starting a container, ensure that the Docker working path has sufficient capacity.

#### Application Scenarios

This feature has no special application scenario restrictions.

### Installing the Feature

### Using the Feature

1. Set the configuration item `START_SHARE_DATA` in the cloud phone configuration file `kbox_config.cfg` and the video stream configuration file `cfct_config`. This configuration item defaults to `0`, meaning disabled. Set it to `1` to enable the shared data volume feature.

2. After setting `START_SHARE_DATA` to `1`, create an image following the original video stream process, and launch an Android cloud phone instance. After configuring the cloud phone instance, for example, downloading games and software, execute the following command:

    ```bash
     docker commit cloud_phone_instance image_name
     ```

   Example:

    ```bash
     docker commit kbox_1 kbox11:wzry
     ```

   At this point, the data of the cloud phone instance is frozen as a new image layer. Then, based on this new image, start new cloud phones, and all new cloud phone instances can share the data in the new image.

### Feature Benefits

Game data is shared between containers through Docker images. This reduces DDR memory access bandwidth pressure, thereby improving overall device performance.

## Change History

|Release|Date|Description|
|--|--|--|
|01|2026-09-30|This is the first official release.|
