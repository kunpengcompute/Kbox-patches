# Feature Guide<a name="ZH-CN_TOPIC_0000002552895805"></a>

## 1 Feature Description<a name="ZH-CN_TOPIC_0000002518226180"></a>

The Kbox cloud phone container is the core component of the cloud phone Turbo toolkit in Kunpeng BoostKit. This document describes the basic concepts of the Kbox cloud phone container and how to compile, deploy, and configure the Kbox cloud phone container.

The cloud phone solution is a virtual phone service virtualized based on the Arm server and runs the Android Open Source Project (AOSP). In short, cloud phones are Arm servers that run the Android OS and function as virtual phones. You can remotely control the cloud phone in real time to run Android applications on the cloud. Based on the basic computing power of cloud phones, you can also efficiently build applications for scenarios like cloud gaming, mobile office, and live streaming interaction.

As the foundational software for running Android applications, the Kbox cloud phone container is an important part of the cloud phone Turbo toolkit in Kunpeng BoostKit. It directly runs the AOSP system in a container, mocks peripheral hardware such as the GPS sensor, acceleration sensor, gyroscope, international mobile equipment identity (IMEI), and Wi-Fi, and implements the Gralloc and HWComposer (HWC) modules, ensuring normal startup and running of the AOSP system. With a series of optional features, the Kbox cloud phone container can enhance the functions or performance of cloud phones in various service scenarios.

For details about all basic features and optional features supported by Kbox, see [**Table 1** Kbox basic features](#kbox-basic-features) and [**Table 2** Kbox optional features](#kbox-optional-features). To enable Kbox basic features, simply integrate the Kbox cloud phone container components by following the instructions in [Compilation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/compile_guide.md) and [Installation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/install_guide.md). The optional features are described in detail in the following sections.

**Table 1** Kbox basic features<a id="kbox-basic-features"></a>

|Name|Description|
|--|--|
| Android Kbox cloud phone container solution| Kbox cloud phone container reference solution based on openEuler (host OS) and Android (guest OS). The CTS compatibility rate is greater than 98%.|
| Direct GPU rendering and mainstream graphics APIs| Direct GPU rendering in containers, supporting OpenGL ES 2.0/3.0/3.1/3.2 and Vulkan 1.1 graphics APIs. The dEQP compatibility rate is greater than 98%.|
| Hardware acceleration for video playback on cloud phones| Hardware acceleration for video playback on cloud phones, implementing H.264 and H.265 decoding hardware acceleration for video playback, reducing CPU load, and improving performance in media scenarios.|
|Dynamic Kbox kernel switch|Dynamic switch, enabling the host OS image used by the cloud phone to be shared by other services.|
| YCbCr_420_888 format| YCbCr_420_888 supported by the Gralloc module, resolving the black screen issue.|
| Resource monitoring (including GPU memory and other memory resources)| Real-time monitoring of GPU memory and other memory resources, enabling customers to take appropriate actions based on resource usage.|

**Table 2** Kbox optional features<a id="kbox-optional-features"></a>

|Name|Description|
|--|--|
| Adaptive texture compression| Adaptive texture compression based on open-source Mesa, supporting conversions of Vulkan RGB and RGBA textures to DXT textures.|
| Adaptive frame synchronization| Adaptive vsync, enabling SurfaceFlinger to compose one frame immediately after it is rendered and send it to the screen.|
| Kbox dynamic frame rate adjustment| Dynamic frame rate reduction when the client is disconnected from the cloud phone in the away from keyboard (AFK) scenario to cut rendering overhead.|
| Android lightweight trimming| Removing unnecessary system services and built-in applications to reduce cloud phone resource usage, thereby improving system performance and optimizing user experience.|
| Android composer optimization| When a game app is displayed in full screen and only the game app layer is present, the composition step can be skipped and image rotation from landscape to portrait can be omitted, reducing GPU overhead.|
| Thread-level shader cache| Pre-built binaries cut shader compilation and linking time, improving rendering efficiency of large-scale applications. |
|Boot with the F2FS file system|A configuration item is added to allow cloud phones to boot with the F2FS file system, aligning them with physical devices to enhance emulation capabilities.|
|Resizable **/system** partition|A configuration item is added to adjust the size of the **/system** partition within the cloud phone container to closely match that of a physical device, thereby enhancing simulation capabilities.|

## 2 Adaptive Texture Compression

### 2.1 Feature Description

#### 2.1.1 Overview

In mobile applications, compressed textures such as ETC and ASTC are widely used. They are natively supported by mobile GPUs to reduce video RAM footprint and save bandwidth. However, cloud phones are deployed on servers whose server-level GPUs do not support these compressed textures. Consequently, these textures must be decompressed into RGBA textures, which significantly increases video RAM usage and lowers the deployment density of cloud phones on servers. This feature allows RGBA textures decompressed in OpenGL ES and Vulkan applications to be compressed into BC textures, effectively reducing video RAM usage.

#### 2.1.2 Constraints

1. For Vulkan, this feature currently supports only decompressing ETC textures (into RGBA) and then compressing them into BC textures. For OpenGL ES, this feature currently supports only decompressing ASTC textures (into RGBA) and then compressing them into BC textures.
2. This feature cannot be modified while the application is running. To apply changes, stop the application and then restart it.
3. The feature does not support texture postprocessing. If postprocessing is applied, rendering exceptions may occur. In this case, you need to disable texture compression and restart the application.

#### 2.1.3 Application Scenarios

This feature delivers the best performance in Vulkan applications that heavily use ETC textures, or OpenGL ES applications that heavily use ASTC textures. Other scenarios may show insignificant or no optimization.

### 2.2 Installing the Feature

This feature is integrated into the Android image by default.

### 2.3 Using the Feature

Perform the following steps to use this feature:

1. Set `sys.vmi.vk.texturecompress` to **1** to enable texture compression for Vulkan applications. It is enabled by default.
2. Set `sys.vmi.gl.texturecompress` to **1** to enable texture compression for OpenGL ES applications. It is enabled by default.

## 3 Adaptive Frame Synchronization<a name="ZH-CN_TOPIC_0000002549865947"></a>

### 3.1 Feature Description<a name="ZH-CN_TOPIC_0000002549865949"></a>

#### 3.1.1 Overview<a name="ZH-CN_TOPIC_0000002549745953"></a>

One of the key factors that affect user experience of cloud phones is E2E latency, which can be divided into three parts: cloud-side latency, network latency, and device-side latency. The Kbox cloud phone solution focuses on the ultimate optimization of cloud-side latency.

The adaptive frame synchronization feature optimizes the graphics rendering pipeline of the Android system, reducing cloud-side latency (defined as the duration from a touch event to the completion of the corresponding image encoding) in mainstream scenarios.

#### 3.1.2 Constraints<a name="ZH-CN_TOPIC_0000002549865951"></a>

1. When adaptive frame synchronization is enabled, the streaming frame rate may briefly exceed the container-configured frame rate in some scenarios. This is an expected behavior of this feature's implementation in multi-layer rendering scenarios. However, the feature automatically identifies such scenarios and dynamically adjusts its regulation, preventing this phenomenon from persisting. You can adjust the identification precision by configuring the threshold **vmi.adaptive.vsync.threshold**. A smaller value can reduce the probability of abnormal frame rate spikes, but may result in unstable performance gains from adaptive frame synchronization.

#### 3.1.3 Application Scenarios<a name="ZH-CN_TOPIC_0000002518226178"></a>

This feature has no specific application scenario restrictions. However, the performance gains may be unstable in some scenarios. According to the test results, stable gains can be obtained in mainstream gaming scenarios.

### 3.2 Installing the Feature<a name="ZH-CN_TOPIC_0000002518386098"></a>

Perform the following steps to integrate this feature:

1. In the Android image, apply the patch **patchForAndroid15/frameworks/native/frameworks-native-0001.patch** (extracted from **Kbox-patches-AOSP15.zip**). For details, see [**Table 1** Kbox basic features](#kbox-basic-features).
2. Integrate **AdaptiveVsync.kbox.so** (extracted from **BoostKit-boostcph-kbox_\*.zip**) into the **/system/vendor/lib64/hw/** directory of the Android image. For details, see [Software Environment](compile_guide.md#software-requirements).

### 3.3 Using the Feature<a name="ZH-CN_TOPIC_0000002549745951"></a>

1. Set the container configuration attribute **ro.vmi.adaptive.vsync** to **1** to enable this feature.
2. During the running, check whether the value of the cloud phone attribute **vmi.enable.adaptive.vsync** is **1**. If the value is **1**, the feature is enabled. If the value is **0**, the feature is temporarily disabled to prevent the frame rate from increasing sharply.

### 3.4 Feature Benefits

In a 1080P@60fps gaming scenario, this feature reduces server-side latency by approximately 10 ms.

## 4 Kbox Dynamic Frame Rate Adjustment

### 4.1 Feature Description

#### 4.1.1 Overview

When there is no active streaming, cloud phones continue running in the background, and the display keeps refreshing at the active frame rate. In scenarios such as AFK gaming or low-streaming periods, a large number of cloud phones on a server may remain in a non-streaming state while still consuming significant hardware resources for display refresh, thereby degrading overall server performance. This feature optimizes such scenarios. When a cloud phone is not streaming, its rendering frame rate is throttled to minimize performance overhead. Once the cloud phone resumes streaming, the normal rendering frame rate is restored to guarantee a seamless user experience.

#### 4.1.2 Constraints

To ensure that the application runs properly after the stream disconnects and the rendering frame rate drops, the target frame rate is constrained to two options: 12 or 24 fps.

#### 4.1.3 Application Scenarios

This feature has no specific application scenario restrictions. It delivers greater performance gains in scenarios with lower streaming ratios.

### 4.2 Installing the Feature

This feature is natively included in the Kbox cloud phone component version 25.3.0 or later.<br>
The following files in the **patchForAndroid15** directory are involved:

1. ./frameworks/native/frameworks-native-0002-dynamic-fps.patch
2. ./hardware/interfaces/hardware-interfaces-0001-dynamic-fps.patch
3. ./hardware/libhardware/hardware-libhardware-0002-dynamic-fps.patch
Extracted from **Kbox-patches-AOSP15.zip**. For details, see [**Table 1** Kbox basic features](#kbox-basic-features).

### 4.3 Using the Feature

1. Set the cloud phone configuration attribute **ro.hardware.dynamicfps** to **1** to enable the feature.
2. Set **ro.hardware.downfps** to **12** or **24** to specify the target rate for dynamic frame rate adjustment.
3. Start the cloud phone, connect to and disconnect from the stream, and monitor the streaming frame rate. If the configuration takes effect, the streaming frame rate after the disconnection should match the configured value of **ro.hardware.downfps** (the rendering frame rate is reflected in the streaming frame rate).

## 5 Android Lightweight Trimming

### 5.1 Feature Description

#### 5.1.1 Overview

By default, the Android system contains many built-in applications and system service processes. During system startup, these processes automatically start and run to provide basic system functions and services. For the cloud phone solution, some Android system services are unnecessary, and these redundant processes consume performance resources. Targeting extreme performance scenarios, this feature provides the capability to trim redundant system processes, thereby minimizing system resource consumption and improving overall performance.

#### 5.1.2 Constraints

None

#### 5.1.3 Application Scenarios

This feature has no specific application scenario restrictions.

### 5.2 Installing the Feature

Perform the following steps to enable this feature:

1. When compiling the Android image, follow the instructions in [Compilation Guide](compile_guide.md) and select the `kbox_arm64_optimized-trunk_staging-user` compilation option.
2. Complete the remaining compilation steps to obtain the lightweight trimmed Kbox Android image.

### 5.3 Using the Feature

Use the compiled lightweight trimmed Kbox Android image file **android.tar** to deploy the cloud phone container solution. The started cloud phone will run the lightweight trimmed Android OS.

### 5.4 Feature Benefits

In AFK scenarios, after a single cloud phone instance is started, memory usage is reduced by over 5%.

## 6 Android Composer Optimization

### 6.1 Feature Description

#### 6.1.1 Overview

In the Android graphics subsystem, an application can create multiple layers for rendering, which are ultimately composited into a single frame by the Android SurfaceFlinger module before being displayed. However, in common full-screen gaming scenarios, applications typically utilize single-layer rendering. In such cases, the composition process within the SurfaceFlinger module can be optimized to bypass unnecessary steps, thereby reducing the performance overhead introduced by composition.

#### 6.1.2 Constraints

1. When hardware configuration scheme 1 (see [Installation Guide](./install_guide.md)) is used, if you enable this feature, the screen may rotate when you enter or exit a game or bring up the text input field. Evaluate the impact to determine whether to enable this feature.
2. This feature is not available for hardware configuration schemes 2, 3, and 4 (see [Installation Guide](./install_guide.md)) in Kbox cloud phone component versions 25.3.0 or later.

#### 6.1.3 Application Scenarios

This feature has no specific application scenario restrictions. It delivers the expected performance benefits in full-screen gaming scenarios. In other scenarios, it may not yield performance gains, but it will not affect the normal screen display.

### 6.2 Installing the Feature

This feature is natively included in the Kbox cloud phone component version 25.3.0 or later.

### 6.3 Using the Feature

1. Set the cloud phone configuration attribute **ro.hardware.compositionBypass** to **1** to enable the feature.
2. **ro.hardware.compositionBypass.offset** controls how many consecutive frames must satisfy the activation conditions before the feature takes effect. This helps reduce potential screen rotation issues that may occur after the feature is enabled. You can adjust the value based on your needs.
3. The feature takes effect when the cloud phone is started.

### 6.4 Feature Benefits

In full-screen gaming scenarios that satisfy the triggering conditions, GPU usage is optimized and reduced by 10%.

## 7 Thread-level Shader Cache

### 7.1 Feature Description

#### 7.1.1 Overview

Generally, large mobile applications pre-build some shaders before startup. However, shader processing behaviors, including shader source code loading, compilation, and linking, still occur during scene transitions and model effect loading. Some of these shader processing operations take a long time, leading to rendering jitter. By pre-building binary shader files and leveraging multi-container file sharing on the cloud, this feature eliminates processing times for shader compilation and linking, significantly improving rendering efficiency in large application scenarios. Furthermore, it allows applications to skip the shader compilation phase upon launch, drastically reducing game startup times. This feature also supports application-level customization of caching behavior by reading a dedicated configuration file.

#### 7.1.2 Constraints

1. This feature is applicable only to applications utilizing OpenGL ES 3.0 or later.
2. After shader cache is enabled, if the required binary shader files have not been pre-cached on the cloud, the application will experience severe lagging during its initial run. You can start a cloud phone beforehand to pre-collect a comprehensive set of shaders.
3. This feature does not include a cache eviction mechanism. If the cache file system becomes full, clear the entire cache and increase the storage capacity. When a game version is updated, old cache files must be cleared to prevent unnecessary space consumption.

#### 7.1.3 Application Scenarios

This feature delivers optimal performance gains for applications that involve extensive shader compilation and linking during runtime. For other scenarios, performance optimization may be marginal or unnoticeable.

### 7.2 Installing the Feature

This feature provides only the binary .so file. During installation, you need to integrate **RenderAccLayer\.kbox\.so** (extracted from **BoostKit-boostcph-kbox_*******.zip**) into the **/system/vendor/lib64/hw/** directory of the Android image. For details, see [Software Environment](compile_guide.md#software-requirements).

### 7.3 Using the Feature

To use this feature, perform the following steps:

1. Enable this feature by setting **ENABLE_RENDER_LAYER** in the configuration file (**kbox_config.cfg** for Kbox images and **cfct_config** for video stream images) to **1**.
2. Copy the **kbox_render_accelerating_configuration.xml** configuration file from the **Kbox-patches-AOSP11.zip** software package to the current startup path.
3. Open the **kbox_render_accelerating_configuration.xml** file to configure the shader caching behavior for a specific application. For details about the configuration items, see [3.1.2 Configuration Items of the Graphics Acceleration Layer](https://gitcode.com/boostkit/vmi/blob/CloudPhone15/docs/en/user_guide.md#312-configuration-items-of-the-graphics-acceleration-layer).
4. Launch a cloud phone and run the configured application. You can view that the cache files of the corresponding application have been generated in the **vender/shader_cache** directory inside the container.
   > **Note**: Enabling this feature and setting `SHADER_CACHE_DIR_SIZE` require launching a new cloud phone to take effect.
5. To change the shader cache mode, modify the `SHADER_CACHE_MODE` setting in the **kbox_render_accelerating_configuration.xml** configuration file, copy the configuration file to the **/data/local/tmp/** directory inside the cloud phone container, and restart the application for the modification to take effect.

## 8 Boot with the F2FS File System<a name="ZH-CN_TOPIC_0000002549865949"></a>

### 8.1 Feature Description<a name="ZH-CN_TOPIC_0000002549865950"></a>

#### 8.1.1 Overview<a name="ZH-CN_TOPIC_0000002549745954"></a>

In the mobile hardware domain, F2FS is the standard file system format for modern physical Android devices. Currently, cloud phones run within host environments that typically utilize the ext4 file system. This discrepancy in file systems significantly lowers the device's emulation fidelity, increasing the risk of being intercepted by risk control policies. Therefore, to enhance emulation fidelity of cloud phones, underlying support for F2FS can be implemented within the cloud phone containers.

#### 8.1.2 Constraints<a name="ZH-CN_TOPIC_0000002549865959"></a>

1. Kernel compatibility: The host OS kernel must contain and enable the F2FS kernel module. If the kernel lacks the required driver or compilation options, the system will fail to recognize and mount storage media formatted in F2FS.
2. Storage resource prerequisites: A physical drive, partition, or logical volume device formatted in F2FS must be available in the system environment. This device must be in an available state and meet the physical prerequisites for being mounted to the **data** directory of the data volume.

#### 8.1.3 Application Scenarios<a name="ZH-CN_TOPIC_0000002518226179"></a>

This feature has no specific application scenario restrictions.

### 8.2 Usage<a name="ZH-CN_TOPIC_0000002549865941"></a>

#### 8.2.1 **Usage Guide**

##### 8.2.1.1 Preparing the Environment<a name="ZH-CN_TOPIC_000000254986594100"></a>

   Check whether the F2FS tool has been installed, whether the F2FS module has been loaded to the host kernel, and whether the user-space tool has been installed.

   ```shell
   yum install f2fs-tools
   ```

   Check whether the current kernel supports F2FS.

   ```shell
   cat /proc/filesystems | grep f2fs
   ```

If "f2fs" is returned, proceed directly to the section "Creating an F2FS Drive and Mounting It to a Specified Directory".

If the command output is empty, the current kernel does not support F2FS. In this case, you need to compile a kernel that supports F2FS. During the compilation, set **CONFIG_F2FS_FS** in the .config file to **Y** in the step of configuring kernel compilation options. For details about how to recompile the kernel, see [Compiling and Installing the Kernel](install_guide.md#ZH-CN_TOPIC_0000002518385420).

##### 8.2.1.2 **Creating an F2FS Drive and Mounting It to a Specified Directory**

Note: This step is optional. If no F2FS drive is mounted to the data directory in the data volume directory, the performance may be affected after the F2FS file system is enabled.

Run the following command to check the drive status in the current environment:

   ```shell
   lsblk -f
   ```

If an F2FS drive has been mounted to the data directory in the data volume directory, go to [Using the Feature](feature_guide.md#ZH-CN_TOPIC_0000002549745952).

Run the following command to create a physical drive partition:

   ```shell
   fdisk /dev/${target_physical_drive_name}
   ```

The system re-reads the partition table.

   ```shell
   partprobe /dev/${target_physical_drive_name}
   ```

Format the new partition to F2FS:

   ```shell
   mkfs.f2fs /dev/${new_logical_drive_name}
   ```

Modify the mounting configuration file to enforce the `f2fs` mount type.
   
Run the following command to open the mounting configuration file for editing:

   ```shell
   vim /etc/fstab
   ```

Enter the following mount information:

   ```text
   UUID=${UUID of the new F2FS drive}$ ${Mount directory of the data volume}/data  f2fs defaults
   ```

Mount the new partition and apply the configuration to make the mount take effect.

   ```shell
   mount -a  
   systemctl daemon-reload
   ```

#### 8.2.2 Using the Feature<a name="ZH-CN_TOPIC_0000002549745952"></a>

1. The **ENABLE_F2FS** parameter in the **kbox_config.cfg** file is used to control the F2FS file system. The default value is **0**, indicating that the F2FS file system is disabled.

2. In the container configuration file **kbox_config.cfg**, set **ENABLE_F2FS** to **1** to enable the feature.

3. When the container is running, run the following command inside the container to check whether the file system format is F2FS. If it is F2FS, the feature is enabled. If it is not F2FS, the feature does not take effect.

```shell
mount | grep -i /data
```

## 9 Resizable /system Partition Size Inside the Container<a name="ZH-CN_TOPIC_0000002549865943"></a>

### 9.1 Feature Description<a name="ZH-CN_TOPIC_0000002549865944"></a>

#### 9.1.1 Overview<a name="ZH-CN_TOPIC_0000002549745956"></a>

On physical Android devices, the **/system** partition is typically fixed in size, with a capacity ranging from approximately 2 GB to 15 GB. However, in the existing cloud phone architecture, the core file system layer, such as the **/system** directory inside the container, is generally mapped using the Docker's Overlay2 union file system. By default, OverlayFS directly inherits the total capacity of the drive where the underlying Docker data root directory of the host is located, which often reaches the terabyte (TB) scale in server environments. Such a huge abnormality in storage space is likely to trigger the device environment review mechanism of third-party applications. To improve the emulation capabilities of cloud phone containers, this solution provides dynamic restriction and adjustment of the **/system** partition size at the cloud phone instance level.

#### 9.1.2 Constraints<a name="ZH-CN_TOPIC_0000002549865952"></a>

1. Strong dependency on the underlying file system: The target drive on the host used to carry cloud phone container data must be formatted as XFS. If the file system does not support this feature, the capacity configuration will become invalid.
2. Mount option compliance: The O&M script or **/etc/fstab** configuration for mounting the data drive must contain and successfully apply the **pquota** parameter. If the drive is mounted with default parameters, Docker will throw an exception or fail to apply the quota when attempting to launch the cloud phone using the **--storage-opt size** parameter, even if the underlying file system is XFS.
3. Parameter configuration limit: The configurable size of the system partition is bounded. If the configured size exceeds the total size of the Docker root directory, the assigned capacity of the system partition will automatically cap at the maximum size of the Docker root directory.

#### 9.1.3 Application Scenarios<a name="ZH-CN_TOPIC_0000002518226174"></a>

This feature has no specific application scenario restrictions.

### 9.2 Usage Guide <a name="ZH-CN_TOPIC_0000002549865942"></a>

#### 9.2.1 Installing the Feature<a name="ZH-CN_TOPIC_0000002518386093"></a>

##### 9.2.1.1 **Creating and Mounting an XFS Drive**

   Run the following command to check the drive status in the current environment:

   ```shell
   lsblk -f
   ```

If an XFS-formatted drive has been mounted to the Docker root directory (**/var/lib/docker** by default), go to [Triggering the Partition Expansion Logic](#ZH-CN_TOPIC_0000002549832550).

Run the following command to create a physical drive partition:

   ```shell
   fdisk /dev/${target_physical_drive_name}
   ```

The system re-reads the partition table.

   ```shell
   partprobe /dev/${target_physical_drive_name}
   ```

Format the new partition to XFS:

   ```shell
   mkfs.xfs /dev/${new_logical_partition_name}
   ```

Modify the mounting configuration file to enforce the `xfs` mount type.
   
Run the following command to open the mounting configuration file for editing:

   ```shell
   vim /etc/fstab
   ```

Run the following command to view the UUID of the new drive partition:

   ```shell
   lsblk -f
   ```

The ID consisting of digits and letters in the UUID column is the UUID.

Enter the following mount information:

   ```text
   UUID=${UUID} ${docker_root_dir}  xfs defaults,pquota 0 2
   ```

Mount the new partition by loading the XFS drive first, and then apply the configuration to make the mount take effect.

   ```shell
   modprobe xfs
   mount -a 
   systemctl daemon-reload
   ```

##### 9.2.1.2 **Triggering the Partition Expansion Logic**<a name="ZH-CN_TOPIC_0000002549832550"></a>

   In the cloud phone configuration file **kbox_config.cfg**, set **SYSTEM_PARTITION_SIZE_MB** to the target capacity for the **/system** partition, in MB.

   ```txt
   SYSTEM_PARTITION_SIZE_MB=${target_/system_partition_size_in_MB}
   ```

#### 9.2.2 Using the Feature<a name="ZH-CN_TOPIC_0000002549745950"></a>

1. The container configuration attribute **SYSTEM_PARTITION_SIZE_MB** controls whether to use this feature. The default value is **0**, indicating that this feature is disabled. If a non-zero value is entered, this feature is enabled. The value indicates the target size for the **/system** partition, in MB.
2. During the running, check whether the size of the **/system** partition of the cloud phone is the same as the configured value. If yes, the feature is enabled. If no, the feature does not take effect.

## 10 NFS Mount Support<a name="nfs-mount-support"></a>

### 10.1 Feature Description

#### 10.1.1 Overview

The current cloud phone solution uses the coupled storage and compute architecture, where data is stored locally and storage resources cannot be reused. Therefore, to implement decoupled storage and compute and storage reuse, this feature allows you to mount data storage to a remote location through NFS. NFS is a network file system that allows you to access files on a remote server over a network as if you were accessing a local drive.

#### 10.1.2 Constraints

NFS adopts on a typical **client/server (C/S)** architecture. Both the client and the server must include the kernel modules nfs, nfsd, and nfsv4, and must have nfs-utils and rpcbind installed.

#### 10.1.3 Application Scenarios

Scenarios such as decoupled storage and compute and storage reuse

### 10.2 Installing the Feature

#### 10.2.1 Client/Server Common Operations

1. Check whether the NFS module is loaded to the kernel.

   ```shell
   cat /lib/modules/$(uname -r)/build/.config | grep NFS
   ```

   If you expect **CONFIG_NFS_FS**, **CONFIG_NFS_V4**, and **CONFIG_NFSD** to be **m**, run the following commands to load the modules:

   ```shell
   modprobe nfs
   modprobe nfsd
   modprobe nfsv4
   ```

2. Install the nfs-utils software package.

   ```shell
   yum install nfs-utils rpcbind
   ```

#### 10.2.2 Server Configuration

1. Create the target export directory.

   ```shell
   mkdir -p /home/nfs
   ```

2. Edit the **/etc/exports** file as follows:

   ```shell
   /home 192.168.20.0/24(rw,fsid=0,sync,no_root_squash)
   /home/nfs 192.168.20.0/24/(rw,sync,no_root_squash)
   ```

3. Restart related services.

   ```shell
   systemctl restart rpcbind
   systemctl restart nfs
   ```

4. Check whether the directory is exported.

   ```shell
   exportfs
   ```

   Expected output: the directory configured in step 2.

#### 10.2.3 Client Configuration

1. Create a mount point.

   ```shell
   mkdir -p /tmp/nfs
   ```

2. Mount the NFS directory of the server.

   ```shell
   mount -t nfs4 192.168.20.XX:/nfs /tmp/nfs
   ```

   >
   >- Since **/etc/exports** on the server has **fsid=0** configured for the **/home** directory, it is invisible to the client. Therefore, you only need to mount the **/nfs** directory.

### 10.3 Using the Feature

1. In the container configuration file **kbox_config.cfg**, set the **NFS_DIR** attribute to **/tmp/nfs** and run the **nstart** command to start the cloud phone.

   ```shell
   ./android_kbox.sh nstart kbox:origin 1
   ```

2. After the container is started, check whether the **data/containerd** content in the mount directory matches the container ID.

   ```shell
   cat /tmp/nfs/data/kbox_1/data/containerd
   ```

## 11 Dynamic CPU Frequency Simulation and Regulation<a name="ZH-CN_TOPIC_00000025498659400"></a>

### 11.1 Feature Description<a name="ZH-CN_TOPIC_000000254986592"></a>

#### 11.1.1 Overview<a name="ZH-CN_TOPIC_000000254974595"></a>

On physical mobile devices, the system dynamically adjusts the CPU operating frequency based on the CPUFreq subsystem and the current computational load to achieve a balance between performance and power consumption. In contrast, cloud phones run within containerized environments on server hosts, where their underlying physical CPU frequencies typically remain constant. Such significant differences in underlying hardware behavior characteristics can be easily and accurately detected by security risk control systems. As a result, cloud phone instances may be flagged as non-physical devices, and subsequently blocked or downgraded. To elevate the underlying hardware behavior fidelity of cloud phones, this solution introduces the dynamic CPU frequency simulation and regulation feature to enhance their overall emulation capabilities.

#### 11.1.2 Constraints<a name="ZH-CN_TOPIC_0000002549865950"></a>

During system initialization or container startup, ensure that write access to the destination data directory and its core files is properly granted to processes performing frequency write operations. Insufficient permissions will directly cause node data overwriting to fail, preventing the feature from taking effect.

#### 11.1.3 Application Scenarios<a name="ZH-CN_TOPIC_0000002518226175"></a>

This feature has no specific application scenario restrictions.

### 11.2 Usage Guide<a name="ZH-CN_TOPIC_00000025498659431"></a>

#### 11.2.1 Installing the Feature<a name="ZH-CN_TOPIC_0000002518386097"></a>

##### 11.2.1.1 **Checking Permissions**

   Run the following commands inside the container to check whether target files in the destination data path are writable. Insufficient permissions will directly cause data write failures.

  ```shell
   ls -ld /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```shell
   ls -ld /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/cpuinfo_cur_freq
   ```

If the output contains **w** (such as **-rw-r--r--**), the file owner (typically **root**) possesses write permissions. Proceed directly to [File Description](feature_guide.md#ZH-CN_TOPIC_0000002549832553).

If the output does not contain **w** (for example, the output contains **-r--r--r--**), the file is read-only. Perform the following steps.

##### 11.2.1.2 **Granting Permissions**<a name="ZH-CN_TOPIC_0000002549832559"></a>

Run the following command inside the container to grant write access to **scaling_cur_freq**:

```shell
chmod u+w /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/scaling_cur_freq
```

Run the following command inside the container to grant write access to **cpuinfo_cur_freq**:

```shell
chmod u+w /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/cpuinfo_cur_freq
```

##### 11.2.1.3 **File Description**<a name="ZH-CN_TOPIC_0000002549832553"></a>

   Inside the container, the **/sys/devices/system/cpu/cpu$***{cpu_id}***/cpufreq/ directory** typically contains the following files. The following table describes the function of each file.

   | File Name| Recorded Information and Function| Suggestion and Description (Function Implementation Guide)|
| :--- | :--- | :--- |
| **`scaling_cur_freq`** | **Current operating frequency determined by the kernel governor.**. Most applications s and security risk control systems read this file to determine the real-time device status.| For dynamic CPU frequency regulation, the core mechanism involves overwriting values into this file.|
| **`scaling_governor`** | CPU frequency regulation policy (governor) currently in effect.|  |
| **`scaling_setspeed`** | Target frequency requested by the user space.|  |
| **`scaling_available_frequencies`** | **List of all available frequencies supported by the current hardware and drivers** (for example, `300000 600000 1000000 ...`).| When adjusting the frequency, avoid writing arbitrary numbers. You are advised to read this file and select a value from this supported frequency list to prevent the value from being identified as a non-standard frequency value by the risk control system.|
| **`scaling_available_governors`** | **List of all frequency regulation policies (governors) supported by the system.**|  |
| **`scaling_max_freq`** | **Maximum frequency allowed by the software policy.**| **Upper frequency limit.** To implement features like downclocking for power saving or low-end device simulation, you may need to modify this file to ensure that the simulated maximum frequency does not exceed the specified value.|
| **`scaling_min_freq`** | **Minimum frequency allowed by the software policy.**| **Lower frequency limit.** To ensure baseline performance or simulate a high-performance device in a standby state, you may need to modify this file to prevent the frequency from dropping too low, which may compromise the fidelity of the emulation.|
| **`scaling_driver`** | **Name of the CPU frequency driver in use.**|  |
| **`cpuinfo_cur_freq`** | **Actual current operating frequency of the CPU hardware.**| If only `scaling_cur_freq` is modified, it may be identified and intercepted. Therefore, you are advised to modify this file after modifying **scaling_cur_freq**.|
| **`cpuinfo_max_freq`** | **Maximum frequency supported by the CPU hardware physically.**| It is used to obtain the upper limit of the physical performance of the CPU allocated to the cloud phone instance during initialization.|
| **`cpuinfo_min_freq`** | **Minimum frequency supported by the CPU hardware physically.**| It is used to assist in generating the lower boundary of a reasonable frequency fluctuation curve.|
| **`cpuinfo_transition_latency`** | **Time delay (nanoseconds) required for switching between different CPU frequencies.**| The interval between two `echo` writes must not be less than this value.|
| **`affected_cpus`** | **List of logical CPU cores that require simultaneous frequency adjustment.** In some architectures, the CPU frequencies of the same cluster must be bound.| When writing a script for cluster-wide frequency control, you need to read this file. For example, if the frequency of CPU0 is changed, ensure that the frequencies of other CPUs in the list are also changed or the same value is displayed.|
| **`related_cpus`** | **List of all CPUs that belong to the same group physically (regardless of whether they are currently online or woken up).**| Similar to `affected_cpus`, it is used to analyze the underlying CPU cluster topology and guide the development of the multi-core frequency simulation script.|

#### 11.2.2 Implementing Changes<a name="ZH-CN_TOPIC_0000002549745956"></a>

Currently, third-party detection applications obtain the CPU operating frequency of the current device by reading the **scaling_cur_freq** and **cpuinfo_cur_freq** files. To improve emulation fidelity of cloud phones, run the following command inside the container to read the list of frequencies supported by the CPU before the modification. In addition, you need to modify both files.

   ```shell
   cat /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/scaling_available_frequencies
   ```

   Next, run the following two commands inside the container to modify the frequencies. It is recommended that the input frequency values match one of the supported CPU frequencies retrieved in the previous step.

   ```shell
   echo ${target_frequency} > /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```shell
   echo ${target_frequency} > /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/cpuinfo_cur_freq
   ```

   If the container restarts, the previous modifications will become invalid, and the CPU frequency values will restore to defaults.

   To achieve dynamic CPU frequency regulation, you can copy and paste the following shell script to any path inside the container and execute it. This allows you to observe dynamic CPU frequency changes in third-party applications (such as "Device Info"). In this script, **sleep 1** specifies a 1-second interval between changes, which can be modified as required. The **FREQS** array stores the potential CPU frequency values, and **CPU_ID** specifies the ID of the CPU to be modified. These three values can be adjusted based on your actual requirements.

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
