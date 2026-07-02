# User Guide <a name="ZH-CN_TOPIC_0000002521463654"></a>

## 1 Starting and Uninstalling a Cloud Phone Instance<a name="ZH-CN_TOPIC_0000002549712545"></a>

### 1.1 Mounting an Android Image<a name="ZH-CN_TOPIC_0000002518192786"></a>

The official Kbox demo image provided by Huawei Mirrors repository does not contain the Android Kbox binary. Therefore, containers cannot be normally started using this image. If you use this demo image, download the Android Kbox binary to the local host and use the script to create an original Kbox image that can start containers properly. After mounting the original Kbox image, create a new Kbox image that integrates the NETINT codec library if hardware decoding is required.

**Table 1** Obtaining and using images<a id="obtaining-and-using-images"></a>

|Image Name + Tag|How to Obtain|Usage|
|--|--|--|
|Compiled by the user|Compiled by the user| Compile the image based on the instructions in the corresponding section. This image contains the Android Kbox binary, and containers can be started properly.|
|kbox:demo|Official Kbox demo image provided by Huawei Mirrors repository| This image does not contain the Android Kbox binary, and containers cannot be started properly. You need to create a Kbox image and apply commercial binaries.|
|kbox:origin|Created using a script| This image is created based on <code>kbox:demo</code> and the Android Kbox binary, and containers can be started properly.|
|kbox:latest|Created using a script| This image is created based on <code>kbox:origin</code> and the codec library to enable hardware decoding. Containers can be started properly.|

**Mounting the Kbox Demo Image<a name="section16531422174717"></a>**

Obtain the `android.tar` package based on [Software Environment](install_guide.md#software-requirements), upload it to the `~/dependency` directory (this directory is used as an example and can be customized), and mount the package.

You can customize the image name and tag in the format of *{Name}:{Tag}*. In this example, the image name is `kbox:demo`.

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>The image name and tag can contain only digits and letters. The image name must start with a digit or lowercase letter.

```shell
cd ~/dependency
docker import android.tar kbox:demo
```

**Creating a Kbox Image and Applying Commercial Binaries<a name="section8328138123920"></a>**

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>If you use the official Kbox demo image provided by Huawei Mirrors repository, perform the operations in this part to ensure that the image contains the Android Kbox binary.
>If you use an image prepared by yourself:
>
>- If you adopt configuration scheme 1, skip all steps in this part.
>- If you adopt hardware configuration scheme 2/3/4, skip step 2 in this part.

1. Obtain `Kbox-patches-AOSP11.zip` based on [Software Environment](install_guide.md#software-requirements), decompress it, and upload the `deploy_scripts` directory in the `Kbox-patches-AOSP11` folder to the `~/dependency` directory on the server.
2. Obtain the Android Kbox binary file package `Boostkit-boostcph-kbox_*.zip` based on [Software Environment](install_guide.md#software-requirements) and upload it to the `~/dependency/deploy_scripts` directory.
3. (Hardware configuration scheme 2/3/4) If hardware configuration scheme 2/3/4 is used, decompress the GPU driver package `VAGPU-25.03.01.01-RC20.tgz` (which c can be obtained based on [Software Environment](install_guide.md#software-requirements)) to obtain `va_driver.tgz` and upload it to the `~/dependency/deploy_scripts` directory on the server.
4. Create a Kbox image that contains the Android Kbox binary. In the following commands, `kbox:demo` is the official Kbox demo image imported in the previous step, and `kbox:origin` is the new image that contains the Android Kbox binary.
    - For hardware configuration scheme 1:

        ```shell
        cd ~/dependency/deploy_scripts
        chmod +x make_image.sh
        ./make_image.sh kbox:demo kbox:origin
        ```

    - For hardware configuration scheme 2/3/4:

        ```shell
        cd ~/dependency/deploy_scripts
        chmod +x make_image.sh
        ./make_image.sh kbox:demo kbox:origin va_driver.tgz
        ```

**(Configuration Scheme 1, Optional) Creating a Kbox Image and Enabling Hardware Decoding<a name="section1799111466509"></a>**

If no encoding card is used in the environment, you cannot create and use an image with the hardware decoding function enabled.

1. Decompress `Kbox-patches-AOSP11.zip` and upload the `Kbox-patches-AOSP11/make_img_sample` directory to the `~/dependency` directory on the server.
2. Obtain `NETINT-vXXX.tar.gz` based on [Software Environment](install_guide.md#software-requirements), rename it `NETINT.tar.gz`, and place it in the `~/dependency/make_img_sample/decode_iso_build` directory. Grant execute permissions on the image creation script in this directory.

    ```shell
    cd ~/dependency/make_img_sample/decode_iso_build
    chmod +x Dockerfile make_image.sh
    ```

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >The `NETINT.tar.gz` package for Quadra is different from that for T432. Select the correct version.

3. Create an image with hardware decoding enabled.

    Create a `kbox:latest` image based on the `kbox:origin` image. The two image names can be customized.

    ```shell
    ./make_image.sh kbox:origin kbox:latest
    ```

    The parameters entered during instance startup must be the same as the name and tag you specify when creating an image. In the following, the image name `kbox:latest` is used as an example.

### 1.2 Starting and Uninstalling a Cloud Phone Instance<a name="ZH-CN_TOPIC_0000002518192802"></a>

Ensure that the `kbox_config.cfg` file exists in the startup path of the cloud phone instance. The container uses the configuration in this file. Therefore, ensure that the configuration in the `kbox_config.cfg` file is correct. If the configuration file does not exist in the startup path, the cloud phone cannot be started.

You can change map configurations (see [Parameters for configuring the GPU, CPU, and path to the data volume in kbox_config.cfg](#kbox-configuration-description)) of a channel to select the GPU, CPU, and path to the data volume used by the container of this channel. In this way, you can flexibly configure resources used by cloud phones to achieve optimal performance.

**Table 1** Parameters for configuring the GPU, CPU, and path to the data volume in kbox_config.cfg<a id="kbox-configuration-description"></a>

|Parameter|Description|Configuration Description|
|--|--|--|
|KBOX_GPU_MAP (hardware configuration scheme 1) KBOX_VA_GPU_MAP (configuration scheme 2/3/4)| Selects the GPU used by a container.|The first entry in the `KBOX_GPU_MAP` list indicates the Kbox cloud phone whose index is 1. The allocated GPU node is `/dev/dri/renderD128`. The `renderD128` node belongs to NUMA0, and therefore, the CPU core range configured in `KBOX_CPUSET_MAP` for NUMA0 of the Kunpeng 920 processor should be 0 to 31. The first entry in the `KBOX_VA_GPU_MAP` list indicates the Kbox cloud phone whose index is 1. The allocated GPU node is `/dev/dri/renderD128`. The `renderD128` to `renderD135` nodes belong to NUMA0, and therefore, the CPU core range configured in `KBOX_CPUSET_MAP` for NUMA0 of the Kunpeng 920 processor should be 0 to 31, and that for NUMA0 of the new Kunpeng 920 processor model should be 0 to 79.|
|KBOX_CPUSET_MAP| Selects the CPU used by a container.|Same as above.|
|KBOX_MOUNT_MAP| Selects the path to the data volume used by a container.|None|

>![](public_sys-resources/icon-note.gif) **NOTE**
>
>To ensure the stable running and optimal performance of the Kbox cloud phone, ensure that the physical CPU cores and GPU rendering nodes bound to a container belong to the same CPU chip.

The Kbox cloud phone container allows users to customize system properties and override original system properties as required. To use custom properties, create a `local.prop` file in the startup path to record custom system properties. After a container is started, properties in this file are parsed and applied to override the original properties during container initialization. For details, see section "Customizing Android System Properties" in [Kbox Cloud Phone Container Routine Maintenance](routine_maintenance.md).

The Kbox cloud phone container supports the graphics acceleration layer. You can enable this feature by setting `ENABLE_RENDER_LAYER` in the `kbox_config.cfg` file to `1`. You can also configure the graphics acceleration layer in the `kbox_render_accelerating_configuration.xml` file in the `~/dependency/deploy_scripts` directory. For details about the configuration items, see section "Configuration Items of the Graphics Acceleration Layer" in [Video Stream Engine User Guide](https://gitcode.com/boostkit/vmi/blob/CloudPhone/docs/en/user_guide.md). If you need to modify the configuration of the graphics acceleration layer when starting the cloud phone container for the first time, modify the application-specific settings in the configuration file, manually copy the file to the `/data/local/tmp` directory of the cloud phone container, and restart the application for the modification to take effect.

1. Decompress `Kbox-patches-AOSP11.zip` and upload the `deploy_scripts` directory in the `Kbox-patches-AOSP11` folder to the `~/dependency` directory on the server.
2. (Optional) Enable hardware decoding.
    1. Modify the `kbox_config.cfg` file in the `deploy_scripts` directory by setting `ENABLE_HARD_DECODE` to `1`.

        >![](public_sys-resources/icon-note.gif) **NOTE:**
        >
        >If software decoding is used when a cloud phone is started, that is, `ENABLE_HARD_DECODE` is set to `0`, the decoding mode can be switched to hardware decoding after setting `ENABLE_HARD_DECODE` to `1` and restarting the cloud phone.

    2. (Hardware configuration scheme 1) If hardware configuration scheme 1 is used, perform the following operations to configure NETINT card nodes:
        1. <a name="li12677451102912"></a>Run the following command to view the nodes of the encoding card chips.

            ```shell
            nvme list
            ```

            The following is an example of the command output. The information in bold indicates the NVMe nodes of the chips of the NETINT Quadra encoding card. One encoding card has two chips.

            ```shell
            Node          SN                   Model            Namespace Usage                    Format           FW Rev
            ------------- -------------------- ---------------- --------- ------------------------ ---------------- --------
            /dev/nvme0n1  Q2A325A11DC082-0454A QuadraT2A        1         8.59  TB /   8.59  TB    4 KiB +  0 B     48F6rKr1
            /dev/nvme1n1  Q2A325A11DC082-0454B QuadraT2A        1         8.59  TB /   8.59  TB    4 KiB +  0 B     48F6rKr1
            ```

        2. Check the mapping between NVMe nodes and PCIe bus numbers.

            *{index}* indicates the NVMe node number returned in [2.b.i](#li12677451102912). For example, in `/dev/nvme0n1`, the value of *{index}* is `0`.

            ```shell
            find /sys/devices/ -name nvme{index}
            ```

            In the following command output, `0000:05:00.0` indicates the bus number of the device.

            ```shell
            /sys/devices/pci0000:00/0000:00:0e.0/0000:05:00.0/nvme/nvme0
            /sys/devices/virtual/nvme-subsystem/nvme-subsys0/nvme0
            ```

        3. Check the mapping between the node and NUMA based on the bus number.

            *{busID}* indicates the bus number obtained in the previous step. For example, in the command output for nvme0, *{busID}* is `0000:05:00.0`.

            ```shell
            lspci -vvvs {busID} | grep NUMA
            ```

            Command output:

            ```shell
            NUMA node: 0
            ```

        4. Change the value of `NETINT` in the `kbox_config.cfg` file based on the NUMA information corresponding to the NVMe node of the encoding card.

            For servers powered by Kunpeng 920 7260 processors, write NVMe nodes belonging to NUMA0 and NUMA1 in the `NETINT0` field, and NVMe nodes belonging to NUMA2 and NUMA3 in the `NETINT1` field.

            Two nodes need to be added for each device in a field. For example, for NVMe device 2, you need to add nodes `/dev/nvme2` and `/dev/nvme2n1`.

            ```shell
            # Nodes of NETINT encoding card devices
            NETINT0="/dev/nvme0,/dev/nvme0n1,/dev/nvme1,/dev/nvme1n1"
            NETINT1="/dev/nvme2,/dev/nvme2n1,/dev/nvme3,/dev/nvme3n1"
            ```

            >![](public_sys-resources/icon-note.gif) **NOTE:**
            >
            >- If the value of `NETINT` is empty when the container is started for the first time, do not set `ENABLE_HARD_DECODE` to `1`. Do not set `ENABLE_HARD_DECODE` to `1` also when the container is restarted. Otherwise, a black screen will occur for a short period of time when you play a video.
            >- To enable hardware decoding of the NETINT encoding card, set `ENABLE_HARD_DECODE` to `1` in `kbox_config.cfg`.
            >- For an environment where one Quadra T2A encoding card is installed, configure the device node information based on the site requirements. The following configuration is for reference.
            >
            > ```shell
            >
            > # Nodes of NETINT encoding card devices
            >
            > NETINT0="/dev/nvme0,/dev/nvme0n1,/dev/nvme1,/dev/nvme1n1"
            > NETINT1="/dev/nvme0,/dev/nvme0n1,/dev/nvme1,/dev/nvme1n1"
            >    ```

3. (Optional) To start a video stream cloud phone instance with the C2 decoder enabled (applicable to configuration scheme 1), set `ENABLE_AMD_C2_DECODE` to `1` in the `kbox_config.cfg` file in the `deploy_scripts` directory. `0` (default) and any other values indicate disabled. The C2 decoder needs to be enabled or disabled during the initial container startup; dynamic switching is not supported. Built-in cloud phone applications will automatically select the appropriate decoder based on their specific requirements.

    ```shell
    ENABLE_AMD_C2_DECODE=0
    ```

4. Run the `android_kbox.sh` script to start containers.

    ```shell
    cd ~/dependency/deploy_scripts
    chmod +x android_kbox.sh
    ./android_kbox.sh start *{image_name:tag}*  *${index1}*  *${index2}* 
    ```

    [**Table 2** Default configurations](#default-configurations) lists the default configurations of a Kbox basic cloud phone.

    **Table 2** Default configurations<a id="default-configurations"></a>

    |Configuration Item|Kbox Basic Cloud Phone|
    |--|--|
    |Scenario|Mobile office/hosting|
    |vCPUs|2|
    |CPU core binding policy|2 containers/2 cores|
    |Memory|6 GB|
    |System storage|16 GB|
    |Resolution|720\*1280|

    The following are examples of using the startup script:

    - Start instance 1.

        ```shell
        ./android_kbox.sh start kbox:origin  1
        ```

    - Start instances 1 to 5.

        ```shell
        ./android_kbox.sh start kbox:origin  1 5
        ```

        >![](public_sys-resources/icon-note.gif) **NOTE:**
        >
        >When a Kbox cloud phone container is started, the dynamic Kbox kernel switch is automatically enabled to enable necessary Linux kernel functions.
        >You can run the following command to query the dynamic switch status:
        >
        >```shell
        >cat /sys/kernel/kbox/kbox_enable
        >```
        >
        >If `1` is displayed, the switch is enabled. If `0` is displayed, the switch is disabled.
        >You can run the following command to manually enable the switch:
        >
        >```shell
        >echo 1 > /sys/kernel/kbox/kbox_enable
        >```

5. Run the following command to check whether a Kbox container is started successfully. *${index}* indicates the ID of the instance.

    ```shell
    docker exec -it kbox_${index} getprop | grep boot_completed
    ```

    In the output, if the value of `sys.boot_completed` is `1`, the startup is successful.

6. Stop and delete a Kbox container.

    In the Kbox solution, data volumes are mounted by default. The default `docker stop` and `docker rm` commands cannot completely clear container data. Run the following script to completely clear files on the host.

    Run the `android_kbox.sh` script to stop and delete running Kbox containers.

    - Stop and delete a container whose ID is *${index}*.

        ```shell
        ./android_kbox.sh delete ${index}
        ```

    - Stop and delete all the containers numbered from `${index1}` to `${index2}`.

        ```shell
        ./android_kbox.sh delete ${index1} ${index2}
        ```

7. Restart Kbox containers.

    In the Kbox solution, data volumes are mounted by default. The default `docker restart` command cannot restart a container. Instead, run the following script to restart a container.

    Run the `android_kbox.sh` script to restart Kbox containers.

    - Restart the container numbered `${index}`.

        ```shell
        ./android_kbox.sh restart ${index}
        ```

    - Restart all the containers numbered from `${index1}` to `${index2}`.

        ```shell
        ./android_kbox.sh restart ${index1} ${index2}
        ```

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>If hardware configuration scheme 1 is used, you must enable or disable the C2 decoder during the initial container startup; dynamic switching is not supported. Built-in cloud phone applications will automatically select the appropriate decoder based on their specific requirements.

### 1.3 Querying Version Information<a name="ZH-CN_TOPIC_0000002549832569"></a>

This section provides two methods to obtain the Kbox version information.

- Method 1: using the obtained software packages

    Obtain `BoostKit-boostcph-kbox_*.zip` based on [**Table 1** Software requirements](install_guide.md#software-requirements), decompress it, and query the `kbox_version.txt` file to check the version number of the current software package.

    ```shell
    unzip BoostKit-boostcph-kbox_*.zip
    unzip Kbox-Boostkit-boostcph-kbox_*.zip
    cat ./products/kbox_version.txt
    ```

    The command output shows the Kbox version information. An example is as follows:

    ```shell
    Product Name: Kunpeng BoostKit
    Product Version: 26.0.RC1
    Component Name: BoostKit-boostcph-kbox
    Component Version: 8.0.RC1
    Component AppendInfo: 11.0.0_r48
    ```

- Method 2: Running the following command to query the version of the started container. In the command, *${index}* indicates the ID of the started instance. For details about the command output example, see the query result of method 1.

    ```shell
    docker exec -it kbox_${index} cat /system/vendor/etc/kbox_version.txt
    ```

### 1.4 (Optional) Enabling Memory Overcommitment <a name="ZH-CN_TOPIC_0000002549832547"></a>

If multiple cloud phone instances use the same image for containerized deployment on a server, there will be many identical memory pages, wasting memory resources. If you use the openEuler 5.10.0-182.0.0 or 5.10.0-216.0.0 kernel, you can enable the Kernel Samepage Merging (KSM) feature for container data deduplication. This feature merges identical anonymous pages to release memory space.

1. Enable the KSM daemon on the server.

    ```shell
    echo 1 > /sys/kernel/mm/ksm/run
    ```

    Adjusting the KSM parameters `pages_to_scan` and `sleep_millisecs` can reduce the optimization time, but the CPU usage will increase.

    - `pages_to_scan` indicates the number of pages to be scanned before the KSM daemon sleeps.
    - `sleep_millisecs` indicates the sleep time (in milliseconds) of the kernel thread of the daemon after completing a scan.

    Modify the parameters using `echo _xx_ > /sys/kernel/mm/ksm/_$param_`. In the command, `xx` indicates the new parameter value, and `$param` indicates the parameter to be modified.

2. Enable automatic full KSM deduplication for a container.

    ```shell
    echo 1 > /sys/fs/cgroup/memory/docker/CONTAINER_ID/memory.ksm
    ```

    *CONTAINER_ID* indicates the ID of the cloud phone container. Check whether the feature is enabled successfully.

    ```shell
    cat /sys/fs/cgroup/memory/docker/CONTAINER_ID/memory.ksm
    ```

    If the value of `merge any tasks` is not `0`, the feature is enabled successfully.

3. Disable KSM deduplication.

    ```shell
    echo 0 > /sys/fs/cgroup/memory/docker/CONTAINER_ID/memory.ksm
    ```

### 1.5 (Optional) Enabling Containers to Boot with the F2FS File System<a name="ZH-CN_TOPIC_0000002549832548"></a>

Previously, cloud phone containers used the ext4 file system, which is commonly used on servers but differs from the F2FS file system used by physical devices. The following steps describe how to enable cloud phones to boot with the F2FS file system, aligning them with physical devices to improve emulation fidelity.

#### 1.5.1 **Environment Setup**

   Set up the environment by following the instructions in [Usage](feature_guide.md#ZH-CN_TOPIC_0000002549865941) of chapter "Boot with the F2FS File System".
  
#### 1.5.2 **Enabling the Configuration Item** <a name="ZH-CN_TOPIC_0000002549832549"></a>

   Set `ENABLE_F2FS` in the `kbox_config.cfg` file to `1`.

   ```text
   ENABLE_F2FS=1
   ```

#### 1.5.3 **Verifying Whether the Configuration Takes Effect**

   After the container is started, access the container environment to view the mount point information.

   ```shell
   mount | grep -i /data
   ```

   If the output indicates that the mount type of the corresponding partition is f2fs, the feature is enabled successfully.

### 1.6 (Optional) Resizing the /system Partition Inside the Container<a name="ZH-CN_TOPIC_0000002549832549"></a>

A detection tool revealed that the size of the `/system` partition inside the cloud phone container was identical to the root directory space on the host, reaching nearly 1 TB. This creates a massive discrepancy compared with physical devices. The following steps describe how to resize the `/system` partition of the cloud phone to match real phones, thereby improving emulation fidelity.

#### 1.6.1 **Environment Setup**

   Set up the environment by following the instructions in [Usage Guide](feature_guide.md#ZH-CN_TOPIC_0000002549865942) of chapter "Adjustable /system Partition Size Within Containers".

#### 9.2.1.2 **Triggering the Partition Expansion Logic**<a name="ZH-CN_TOPIC_0000002549832550"></a>

   In the cloud phone configuration file `kbox_config.cfg`, set `SYSTEM_PARTITION_SIZE_MB` to the target capacity for the `/system` partition, in MB.

   ```txt
   SYSTEM_PARTITION_SIZE_MB=${target_system_partition_size_in_MB}
   ```

#### 1.6.3 **Verifying Whether the Configuration Takes Effect**

   After the container is started, run the following command in the container to check the actual capacity of the system partition:

   ```shell
   df -h /system
   ```

   If the size displayed in the `Size` column matches the configured size, the partition has been resized successfully.

### 1.7 (Optional) Enabling Containers to Boot with NFS mounting

This feature allows data storage to be mounted to a remote location through NFS, implementing decoupled storage and compute and storage reuse.

#### 1.7.1 **Environment Setup**

Seu tp the environment by following the instructions in [NFS Mount Support](feature_guide.md#nfs-mount-support).

#### 1.7.2 **NFS Mount**

In the container configuration file `kbox_config.cfg`, set the `NFS_DIR` attribute to `/tmp/nfs`. Start the cloud phone using the `nstart` command:.

```shell
./android_kbox.sh nstart kbox:origin 1
```

Run the `ndelete` command to delete the cloud phone.

```shell
./android_kbox.sh ndelete kbox:origin 1
```

#### 1.7.3 **Verifying Whether the Configuration Takes Effect**

Check whether the `data/containerd` content in the mount directory matches the container ID.

```shell
cat /tmp/nfs/data/kbox_1/data/containerd
```

### 1.8 (Optional) Dynamically Regulating the CPU Frequency of the Cloud Phone<a name="ZH-CN_TOPIC_000000254983254923"></a>

On physical devices, the system dynamically regulates the CPU frequency to balance load and power consumption. In contrast, cloud phones run in a containerized environment relying on the host, where the underlying physical CPU frequency typically remains constant, differing from physical devices. The following steps describe how to implement dynamic CPU frequency regulation for cloud phones to improve emulation fidelity.

#### 1.8.1 **Environment Setup**

   Set up the environment by following the instructions in [Installing the Feature](feature_guide.md#ZH-CN_TOPIC_0000002518386097) of chapter "Dynamic CPU Frequency Simulation and Regulation".

#### 1.8.2 **Execution of Modification** <a name="ZH-CN_TOPIC_000000254983255011"></a>

   Current third-party detection applications generally read the two files `scaling_cur_freq` and `cpuinfo_cur_freq` to retrieve the current device's CPU operating frequency. To improve the simulation capabilities of the cloud phone device, enter the following command in the container to read the frequency list supported by the CPU before modification. In addition, you need to modify both files.

   ```shell
   cat /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_available_frequencies
   ```

   Subsequently, enter the following two commands inside the container to execute modifications. The entered frequency value should ideally be the current CPU-supported frequency values just retrieved.

   ```shell
   echo ${target_frequency} > /sys/devices/system/cpu/cpu${target_cpu_id}/cpufreq/scaling_cur_freq
   ```

   ```shell
   echo ${target_frequency} > /sys/devices/system/cpu/cpu${cpu_id}/cpufreq/cpuinfo_cur_freq
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

#### 1.8.3 **Verifying Whether the Configuration Takes Effect**

   After starting the container, install a third-party application (such as "Device Info") inside the container to check whether the CPU frequency matches the expected value. If it matches, the CPU frequency regulation has successfully taken effect.

## 2 ARDC Test <a name="ZH-CN_TOPIC_0000002549712565"></a>

On Windows, you are advised to use the ARDC software for debugging and accessing Kbox containers in graphics mode. Obtain ARDC from the official source and install it.

To connect to a started Kbox instance using ADB on Windows, perform the following steps:

1. Open ARDC and switch to the console page.
2. In the CMD box, input the following command and press `Enter` to connect ARDC to the cloud phone instance. *$ip* indicates the server IP address and *$port* indicates the ADB port.

    ```shell
    adb connect $ip:$port
    ```

    If the connection is successful, the following figure is displayed.

    ![](figures/adb2.png)

3. Query the devices that are successfully connected to ARDC.

    ```shell
    adb devices
    ```

4. From the menu, select the device that you want to start and wait for the connection.
5. Drag the APK to be tested to the page and wait for the installation.
6. After the APK is successfully installed, run the APK to start the test.

## 3 (Optional) Configuring the Docker Environment<a name="ZH-CN_TOPIC_0000002518352702"></a>

Docker is not within the delivery scope of this solution. The environment configuration provided in this section is for reference only. You are not advised to use Kunpeng BoostKit for Cloud Phone demos as a commercial solution. Customers or ISVs must perform necessary security assessment before commercial use. Using the Kunpeng BoostKit for Cloud Phone demos implies the user's acceptance of all associated security risks.

**Creating a Separate Partition and Enabling IPv6 for Containers<a name="section66764141138"></a>**

1. The default Docker directory is `/var/lib/docker`, which stores all Docker files including images. This directory may be fully occupied. As a result, Docker and the host may become unavailable. For this reason, it is a good practice to create a separate partition (logical volume) for Docker files.
2. By default, IPv6 is disabled for Docker. However, some applications depend on the IPv6 protocol. If IPv6 is disabled, some functions of these applications may be abnormal. The following provides a method to enable the IPv6 protocol for Docker.

Recommended modification method:

1. Create a directory for Docker files. Mount an idle drive whose file system type is ext4 as an independent partition. The following uses `sda` as an example.

    Create a `/root/sda/docker` directory and add a line `/dev/sda /root/sda/docker ext4 defaults 0 0` to the `/etc/fstab` file. If `/dev/sda` has been mounted or it has a non-ext4 file system, replace `sda` in the following command with the name of a valid drive.

    ```shell
    mkdir -p /root/sda/docker
    echo "/dev/sda /root/sda/docker ext4 defaults 0 0" >> /etc/fstab
    ```

2. Go to the `/root/sda/docker` path.

    1. Open the `/etc/docker/daemon.json` file.

        ```shell
        vim /etc/docker/daemon.json
        ```

    2. Press `i` to enter the insert mode and add the `"data-root": "/root/sda/docker", "ipv6": true,"fixed-cidr-v6": "2001:db8::/64"` properties to the file to configure the Docker data storage location and enable the IPv6 protocol. The file must comply with the JSON format.

        ```shell
        {
        "debug": true,
        "data-root": "/root/sda/docker",
        "ipv6": true,
        "fixed-cidr-v6": "2001:db8::/64"
        }
        ```

    3. Press `Esc`, type `:wq!`, and press `Enter` to save the file and exit.

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >Modify the `/etc/docker/daemon.json` file. If the file does not exist, run the following commands to create the file and write related content to the file:
    >
    >```shell
    >touch /etc/docker/daemon.json
    >cat >/etc/docker/daemon.json <<EOF
    >{
    >"debug":true,
    >"data-root":"/root/sda/docker",
    >"ipv6":true,
    >"fixed-cidr-v6":"2001:db8::/64"
    >}
    >EOF
    >```

3. Restart the Docker service.

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >Before restarting the Docker service, ensure that no other container is running. If any other container is running in the environment, clear it.

    ```shell
    systemctl restart docker
    ```

4. Reload the content of the `/etc/fstab` file.

    ```shell
    mount -a
    ```

## 4 Emulation Device Parameter Configuration<a name="ZH-CN_TOPIC_0000002518352680"></a>

### 4.1 Property Configuration Methods<a name="ZH-CN_TOPIC_0000002518192812"></a>

Before configuring properties, you need to connect to and access the container.

This document provides two methods for accessing a container: [Using the CLI on a PC](#section155521166386) and [Using the Server Terminal](#section473111277384). You can select either method as required.

**Using the CLI on a PC<a name="section155521166386"></a>**

1. Start the Kbox container.
2. Connect to the container instance via `adb` on the PC CLI.

    ```shell
    adb connect ip:port
    ```

    Some commands (such as `getevent`) require root permissions.

    ```shell
    adb -s ip:port root
    ```

3. Access the container using the `adb` CLI.

    ```shell
    adb -s ip:port shell
    ```

    After accessing the container, run corresponding commands to configure cloud phone parameters.

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >In the `adb` commands used in this document, *ip* indicates the IP address of the server and *port* indicates the ADB port number.

**Using the Server Terminal<a name="section473111277384"></a>**

1. Start the Kbox container.
2. On the server terminal interface, access the container using the `docker` CLI.

    ```shell
    docker exec -it kbox_${index} sh
    ```

    After accessing the container, run corresponding commands to configure cloud phone parameters.

### 4.2 Configuring System Properties<a name="ZH-CN_TOPIC_0000002549712553"></a>

#### 4.2.1 Configuring GPS System Properties<a name="ZH-CN_TOPIC_0000002549712537"></a>

##### 4.2.1.1 GPS Properties<a name="ZH-CN_TOPIC_0000002518352678"></a>

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>Data types of the parameters in the following table are described as follows:
>
>- A valid double-type parameter value contains 15 or 16 digits. If a value is outside the valid range, use the scientific notation. Otherwise, garbled characters are displayed. Due to the type conversion of double-precision floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the range.
>- A valid float-type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.

|Configuration Item|Meaning|Type|Value Range|Default Value|Description|
|--|--|--|--|--|--|
|persist.gps.mock.latitude| Latitude|double|[-90°, 90°]|30.188433°| The default value is the latitude of Hangzhou, China. Due to code restrictions, the longitude and latitude cannot be set to `0` at the same time in the Android 11 environment.|
|persist.gps.mock.longitude| Longitude|double|[-180°, 180°]|120.199818°| The default value is the longitude of Hangzhou, China. Due to code restrictions, the longitude and latitude cannot be set to `0` at the same time in the Android 11 environment.|
|persist.gps.mock.altitude| Altitude, in meters.|double|Unlimited. It can be positive, negative, or 0.|0| The default value indicates that the current altitude is 0 m.|
|persist.gps.mock.speed| Current moving speed, in meters per second|float|[0, 400] m/s|0 m/s| The initial value indicates that the device is in the static state. If the speed exceeds 400 m/s, the Android system stops reporting GPS data.|
|persist.gps.mock.bearing| Current steering angle, in degrees|float|[0°, 360°)|0°| The initial value indicates due north.|
|persist.gps.mock.accuracy| Current positioning accuracy, in meters|float|Greater than or equal to 0 m|20 m| The initial value indicates that the positioning error is ±20 m.|

##### 4.2.1.2 Example Configuration<a name="ZH-CN_TOPIC_0000002549712541"></a>

1. Call the setprop method to set property values. The following uses `gps.mock.latitude` and `gps.mock.longitude` as an example. The methods for setting other properties are the same.

    ```shell
    setprop persist.gps.mock.latitude 30.188433
    setprop persist.gps.mock.longitude 120.193818
    ```

2. Check the current GPS properties.

    ```shell
    getprop | grep "persist.gps.mock."
    ```

    Command output:

    ```shell
    [persist.gps.mock.latitude]: [30.188433]
    [persist.gps.mock.longitude]: [120.193818]
    ```

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >To query string texts on Windows, use the `findstr` command instead of the `grep` command. In the following scenarios where the `grep` command is used in this chapter, perform operations based on your service scenario.
    >
    >```shell
    >adb -s ip:port shell getprop | findstr "persist.gps.mock."
    >```

3. After the container is restarted, query the GPS data of the location service. Run the following command in the container to query the latest GPS data:

    ```shell
    dumpsys location | grep -A 1 "gps provider:"
    ```

    Check whether the GPS properties take effect based on the returned value. Example command output:

    ```shell
        gps provider:
          last location=Location[gps 30.188433,120.199818 hAcc=20 et=+2h17m10s384ms alt=0.0 vel=0.0 bear=0.0 vAcc=??? sAcc=??? bAcc=??? {Bundle[{}]}]
    ```

    |Returned Frame Parameter|Meaning|
    |--|--|
    |gps|Location information. The format is [Latitude],[Longitude].|
    |hAcc|Current positioning error, in meters|
    |alt|Altitude, in meters|
    |bear|Current steering angle, in degrees|
    |vel|Current moving speed, in meters per second|

4. Check whether the GPS data of the location service matches the preset value.

#### 4.2.2 Configuring Telephony Properties<a name="ZH-CN_TOPIC_0000002549832551"></a>

##### 4.2.2.1 Telephony Properties<a name="ZH-CN_TOPIC_0000002518352692"></a>

|Configuration Item|Meaning|Type|Value Range|Default Value|Description|
|--|--|--|--|--|--|
|persist.sys.prop.writeimei| International mobile equipment identity (IMEI)|int|A numeric string of 15 to 17 digits|86 + a string of 15 random digits|`86`: China|
|persist.gsm.operator.alphacph| Network operator name|string|A string of 1 to 20 letters or digits|CMCC|-|
|persist.gsm.operator.numericcph| Network operator code|int|A numeric string of 5 to 6 digits|46000| The value consists of a three-digit country/region code of the network operator and a two-digit or three-digit mobile network code. For example, `460` indicates China (cn), and `00` indicates China Mobile.|
|persist.sys.prop.writeimsi| International mobile subscriber identity (IMSI)|int|A numeric string of 15 digits|46011 + a string of random digits| The first five to six digits indicate the operator code of the SIM card. The composition of the operator code is the same as that of the network operator code. `460` indicates China (cn), and `11` indicates China Mobile.|
|persist.gsm.sim.operator.alphacph| Operator name of the SIM card|string|A string of 1 to 20 letters or digits|CMCC|-|
|persist.sys.prop.writesimserial| Serial number of the SIM card|int|A numeric string of 20 digits|898600 + a string of random digits| `89` indicates the international dialing prefix, `86` indicates China, and `00` indicates China Mobile.|
|persist.sys.prop.writephonenum| Mobile number.|int|A numeric string of 0 to 20 digits|Left empty.|-|

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>- You need to restart the container for the property settings to take effect.
>- During container startup, the system checks whether the characters and value length are valid. If they are invalid, the default values are used.

##### 4.2.2.2 Example Configuration<a name="ZH-CN_TOPIC_0000002549712549"></a>

1. Call the `setprop` method to set the `IMEI` value.

    ```shell
    setprop persist.sys.prop.writeimei 861456987456321
    ```

    Restart the container and enter `*#06#` on the dialing screen.

    ![](figures/zh-cn_image_0000002518352734.png)

2. Call the `setprop` method to set the network operator name and code.

    ```shell
    setprop persist.gsm.operator.alphacph CMCC
    setprop persist.gsm.operator.numericcph 46000
    ```

    Restart the container and query the setting result in the application.

    ![](figures/zh-cn_image_0000002518352736.png)

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >You can use a relevant application for verification.

3. Call the `setprop` method to set IMSI and SIM card operator name.

    ```shell
    setprop persist.sys.prop.writeimsi 460110123456789
    setprop persist.gsm.sim.operator.alphacph CMCC
    ```

    Restart the container, enter `*#*#4636#*#*` on the dialing screen, and query the mobile phone information. The IMSI can be queried.

    ![](figures/zh-cn_image_0000002549712583.png)

    The SIM card operator name and SIM card operator code are displayed.

    ![](figures/zh-cn_image_0000002549832595.png)

4. Call the `setprop` method to set the SIM card serial number.

    ```shell
    setprop persist.sys.prop.writesimserial 01234567890123456789
    ```

    Restart the container and run the following command to query the setting result:

    ```shell
    dumpsys isub | grep iccid
    ```

    ![](figures/zh-cn_image_0000002549832593.png)

    You can also query the setting result in the application.

    ![](figures/zh-cn_image_0000002549712585.png)

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >1. When you run the command to query the SIM card serial number, some numbers may be masked with asterisks (*). This is normal and does not affect the functions.
    >2. You can use a relevant application for verification.

5. Call the `setprop` method to set the phone number.

    ```shell
    setprop persist.sys.prop.writephonenum 12345678901
    ```

    Restart the container and query the setting result in the application.

    ![](figures/zh-cn_image_0000002518192822.png)

#### 4.2.3 Configuring Properties of the Acceleration Sensor and Gyroscope Sensor<a name="ZH-CN_TOPIC_0000002549832553"></a>

##### 4.2.3.1 Properties of the Acceleration Sensor and Gyroscope Sensor<a name="ZH-CN_TOPIC_0000002518352686"></a>

|Configuration Item|Meaning|Type|Value Range|Default Value|Description|
|--|--|--|--|--|--|
|persist.sensors.mock.delaytime| Data collection frequency, in microseconds|int|[20000,1000000]|200000| If the value of `persist.sensors.mock.delaytime` is not within the range [20000, 1000000], the default value is used.|
|persist.sensors.mock.acce.data.x| `persist.sensors.mock.acce.data.x` indicates the acceleration (gravity included, m/s²) along the x-axis.|float|[-3.402823466e+38,3.402823466e+38]| Both the default values of the acceleration and gyroscope on the x-axis are `9.833359`. You can query the default value using a related application. The default value is not displayed in `persist.sensors.mock.acce.data.x` or `persist.sensors.mock.gyro.data.x`. Android 11 quantizes the data collected at the underlying layer together with the resolution value into a new value. The acceleration resolution is 1/4032, and the gyroscope resolution is 1/1000.|If the value of `persist.sensors.mock.acce.data.x` or `persist.sensors.mock.gyro.data.x` contains invalid characters that are neither digits nor decimal points, the setting is invalid and the default value is used. Note that a valid float type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation, for example, 3.40282e+38. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.|
|persist.sensors.mock.gyro.data.x| `persist.sensors.mock.acce.data.x` indicates the acceleration (gravity included, m/s²) along the x-axis.|float|[-3.402823466e+38,3.402823466e+38]| Both the default values of the acceleration and gyroscope on the x-axis are `9.833359`. You can query the default value using a related application. The default value is not displayed in `persist.sensors.mock.acce.data.x` or `persist.sensors.mock.gyro.data.x`. Android 11 quantizes the data collected at the underlying layer together with the resolution value into a new value. The acceleration resolution is 1/4032, and the gyroscope resolution is 1/1000.|If the value of `persist.sensors.mock.acce.data.x` or `persist.sensors.mock.gyro.data.x` contains invalid characters that are neither digits nor decimal points, the setting is invalid and the default value is used. Note that a valid float type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation, for example, 3.40282e+38. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.|
|persist.sensors.mock.acce.data.y| `persist.sensors.mock.acce.data.y` indicates the acceleration (gravity included) along the y-axis.|float|[-3.402823466e+38,3.402823466e+38]| Both the default values of the acceleration and gyroscope on the y-axis are `0.184357`. You can query the default value using a related application. The default value is not displayed in `persist.sensors.mock.acce.data.y` or `persist.sensors.mock.gyro.data.y`. Android 11 quantizes the data collected at the underlying layer together with the resolution value into a new value. The acceleration resolution is 1/4032, and the gyroscope resolution is 1/1000.|If the value of `persist.sensors.mock.acce.data.y` or `persist.sensors.mock.gyro.data.y` contains invalid characters that are neither digits nor decimal points, the setting is invalid and the default value is used. Note that a valid float type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation, for example, 3.40282e+38. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.|
|persist.sensors.mock.gyro.data.y| `persist.sensors.mock.gyro.data.y` indicates the rotation rate along the y-axis.|float|[-3.402823466e+38,3.402823466e+38]| Both the default values of the acceleration and gyroscope on the y-axis are `0.184357`. You can query the default value using a related application. The default value is not displayed in `persist.sensors.mock.acce.data.y` or `persist.sensors.mock.gyro.data.y`. Android 11 quantizes the data collected at the underlying layer together with the resolution value into a new value. The acceleration resolution is 1/4032, and the gyroscope resolution is 1/1000.|If the value of `persist.sensors.mock.acce.data.y` or `persist.sensors.mock.gyro.data.y` contains invalid characters that are neither digits nor decimal points, the setting is invalid and the default value is used. Note that a valid float type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation, for example, 3.40282e+38. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.|
|persist.sensors.mock.acce.data.z| `persist.sensors.mock.acce.data.z` indicates the acceleration (gravity included) along the z-axis.|float|[-3.402823466e+38,3.402823466e+38]| Both the default values of the acceleration and gyroscope on the z-axis are `0.101028`. You can query the default value using a related application. The default value is not displayed in `persist.sensors.mock.acce.data.z` or `persist.sensors.mock.gyro.data.z`. Android 11 quantizes the data collected at the underlying layer together with the resolution value into a new value. The acceleration resolution is 1/4032, and the gyroscope resolution is 1/1000.|If the value of `persist.sensors.mock.acce.data.z` or `persist.sensors.mock.gyro.data.z` contains invalid characters that are neither digits nor decimal points, the setting is invalid and the default value is used. Note that a valid float type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation, for example, 3.40282e+38. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.|
|persist.sensors.mock.gyro.data.z| `persist.sensors.mock.gyro.data.z` indicates the rotation rate along the z-axis.|float|[-3.402823466e+38,3.402823466e+38]| Both the default values of the acceleration and gyroscope on the z-axis are `0.101028`. You can query the default value using a related application. The default value is not displayed in `persist.sensors.mock.acce.data.z` or `persist.sensors.mock.gyro.data.z`. Android 11 quantizes the data collected at the underlying layer together with the resolution value into a new value. The acceleration resolution is 1/4032, and the gyroscope resolution is 1/1000.|If the value of `persist.sensors.mock.acce.data.z` or `persist.sensors.mock.gyro.data.z` contains invalid characters that are neither digits nor decimal points, the setting is invalid and the default value is used. Note that a valid float type parameter value contains 6 or 7 digits. If a value is outside the valid range, use the scientific notation, for example, 3.40282e+38. Otherwise, garbled characters are displayed. Due to the type conversion of floating-point data, some upper-layer applications may encounter precision fluctuations even if the value is within the value range.|

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>Value conversion formula for Android 11: If the input value is of the float type and the resolution is of the double type, `double incRes = 0.125 x resolution`, and `value = round(static_cast<double>(value)/incRes) x incRes`, where the round function is used to round a value of the double type.

##### 4.2.3.2 Example Configuration<a name="ZH-CN_TOPIC_0000002518192774"></a>

1. Call the `setprop` method to input the acceleration sensor data.

    ```shell
    setprop persist.sensors.mock.acce.data.x 5432.43
    setprop persist.sensors.mock.acce.data.y 456
    setprop persist.sensors.mock.acce.data.z 756
    ```

2. View the configured acceleration data.

    ![](figures/zh-cn_image_0000002518192818.png)

    >![](public_sys-resources/icon-note.gif) **NOTE:**
    >
    >You can use a relevant application for verification.

3. Call the `setprop` method to input the gyroscope data.

    ```shell
    setprop persist.sensors.mock.gyro.data.x 1.12
    setprop persist.sensors.mock.gyro.data.y 2.12
    setprop persist.sensors.mock.gyro.data.z 3.12
    ```

4. View the gyroscope data.

    ![](figures/zh-cn_image_0000002518352726.png)

#### 4.2.4 Configuring Properties of Multiple VInput Devices<a name="ZH-CN_TOPIC_0000002518352684"></a>

##### 4.2.4.1 VInput Properties<a name="ZH-CN_TOPIC_0000002549832585"></a>

|Configuration Item|Meaning|Type|Value Requirement|Description|
|--|--|--|--|--|
|persist.sys.input.mouse.name| Creating device identity properties for the mouse|string| The value is a string of 1 to 64 characters, which can contain only letters, digits, and underscores (_).|If the configured value does not meet the requirements, the value is invalid.|
|persist.sys.input.gamepad1.name| Creating device identity properties for handle 1|string| The value is a string of 1 to 64 characters, which can contain only letters, digits, and underscores (_).|If the configured value does not meet the requirements, the value is invalid.|
|persist.sys.input.gamepad2.name| Creating device identity properties for handle 2|string| The value is a string of 1 to 64 characters, which can contain only letters, digits, and underscores (_).|If the configured value does not meet the requirements, the value is invalid.|

##### 4.2.4.2 Example Configuration<a name="ZH-CN_TOPIC_0000002518192790"></a>

1. Call the `setprop` method to create a mouse device, and view the result using the `getevent` method.

    ```shell
    setprop persist.sys.input.mouse.name mouse
    getevent
    ```

    Command output:

    ```shell
    add device 1: /dev/input/event4
      name:     "mouse"
    add device 2: /dev/input/event3
      name:     "Touch Pad"
    could not get driver version for /dev/input/event0, Inappropriate ioctl for device
    could not get driver version for /dev/input/event1, Inappropriate ioctl for device
    ```

2. Call the `setprop` method to create the first handle device, and view the result using the `getevent` method.

    ```shell
    setprop persist.sys.input.gamepad1.name gamepad1
    getevent
    ```

    Command output:

    ```shell
    add device 1: /dev/input/event5
      name:     "gamepad1"
    add device 2: /dev/input/event4
      name:     "mouse"
    add device 3: /dev/input/event3
      name:     "Touch Pad"
    could not get driver version for /dev/input/event0, Inappropriate ioctl for device
    could not get driver version for /dev/input/event1, Inappropriate ioctl for device
    ```

3. Call the `setprop` method to create the second handle device, and view the result using the `getevent` method.

    ```shell
    setprop persist.sys.input.gamepad2.name gamepad2
    getevent
    ```

    Command output:

    ```shell
    add device 1: /dev/input/event6
      name:     "gamepad2"
    add device 2: /dev/input/event5
      name:     "gamepad1"
    add device 3: /dev/input/event4
      name:     "mouse"
    add device 4: /dev/input/event3
      name:     "Touch Pad"
    could not get driver version for /dev/input/event0, Inappropriate ioctl for device
    could not get driver version for /dev/input/event1, Inappropriate ioctl for device
    ```

### 4.3 System Function Parameter Configuration <a name="ZH-CN_TOPIC_0000002518192782"></a>

|Configuration Item|Meaning|Type|Value Range|Default Value|Description|
|--|--|--|--|--|--|
|sys.vmi.vk.texturecompress| Texture compression switch. Vulkan RGB and RGBA textures can be compressed into BC7 textures. ETC2 textures can be decoded into RGBA textures and then compressed into BC7 textures.|int|<code>0</code>: disabled<br><code>1</code>: enabled|1| The setting of texture compression cannot be changed during application running. To change the setting, exit the application first. The function does not support texture postprocessing. If postprocessing is applied, rendering exceptions may occur. In this case, you need to disable texture compression and restart the application.|
|sys.vmi.gl.texturecompress| Texture compression switch. Textures can be converted into the RGBA format through OpenGL ES adaptive scalable texture compression (ASTC) and then compressed into BC3 textures.|int|<code>0</code>: disabled<br><code>1</code>: enabled|1| The setting of texture compression cannot be changed during application running. To change the setting, exit the application first.|
|ro.vmi.adaptive.vsync| Switch for toggling the adaptive vertical synchronization (vsync) function, which is disabled by default.|int|<code>0</code>: disabled<br><code>1</code>: enabled|0| The modification of this item takes effect upon a restart.|

## 5 Troubleshooting<a name="ZH-CN_TOPIC_0000002518352706"></a>

### 5.1 Overview <a name="ZH-CN_TOPIC_0000002549712533"></a>

#### 5.1.1 Troubleshooting Principles<a name="ZH-CN_TOPIC_0000002518352700"></a>

- Fault analysis, locating, and troubleshooting principles:
  - Restore services as soon as possible.
  - Collect fault data immediately and save the data to mobile storage media or other computers.
  - Before crafting a troubleshooting solution, evaluate the impact to ensure service continuity.
  - If a fault occurs on a third-party hardware device, view the documentation of the device or call the service hotline of the third party for assistance.
  - If a fault cannot be located or rectified according to the manual, contact technical support in a timely manner to minimize the service interruption time.

- Precautions:
  - Strictly comply with operation regulations and industrial safety regulations to ensure personnel and equipment safety.
  - Analyze the fault symptom, identify the cause, and then rectify the fault. If the cause is unknown, do not perform operations to prevent the fault from worsening.
  - Before rectifying a fault, keep all on-site records relevant to the fault and do not delete any data or logs.
  - To ensure customer network security and privacy, obtain the customer's consent and authorization before collecting fault logs.
  - Before making any modifications, back up data manually or using a script.
  - Take electrostatic discharge (ESD) prevention measures, for example, wearing an ESD wrist strap when replacing or maintaining devices.
  - Record original information in detail when any problem occurs during maintenance.
  - All major operations such as restarting processes must be documented. In addition, these operations must be performed by qualified personnel who have confirmed the feasibility of the operations, backed up necessary files, and taken contingency and security measures.
  - When the system recovers, check the system running status to confirm that the fault has been rectified. Write associated troubleshooting reports in a timely manner.
  - Exercise caution when performing risky operations and running risky commands.

- Requirements for maintenance personnel:
  - Have basic knowledge of network devices, OSs, and databases, and be skilled at running common commands for maintenance.
  - Understand the logical structure of the on-site service system, mapping relationship between components and on-site devices, and physical connections between on-site devices.
  - Be familiar with the service processes and system structure and be skilled at operating the software and hardware related to a specific service.
  - Know how to locate and rectify common faults.
  - Know how to remotely access systems.

#### 5.1.2 Troubleshooting Process<a name="ZH-CN_TOPIC_0000002549712555"></a>

The troubleshooting process consists of the following operations: collecting fault information, diagnosing the fault, locating the fault, and rectifying the fault.

**Figure 1** General troubleshooting process<a name="fig1890714518232"></a><a id="general-troubleshooting-process"></a>

![](figures/general-troubleshooting-process.png "general-troubleshooting-process")

**Fault Information Collection<a name="section196271610142212"></a>**

Collect as much fault information as possible to facilitate fault location and rectification.

**Fault Diagnosis<a name="section4572941192214"></a>**

Determine the type and scope of the fault based on the collected information.

**Fault Location<a name="section3895552182410"></a>**

Identify the possible causes of the fault. You need to analyze and compare the possible causes of the fault and determine the root cause.

The commonly used methods for fault location are as follows:

- View client logs, especially the alarms.
- View server logs, especially the alarms.
- View OS logs, especially the alarms.
- Check the resource usage, especially the full load and overload of resources.
- Check operation logs for misoperations.
- View configuration files and check whether configurations are correct.

**Fault Rectification<a name="section18134350132614"></a>**

Fault rectification refers to the process of rectifying a fault according to different causes of the fault. This process involves checking and repairing devices, modifying configurations, and restarting processes, containers, and servers.

>![](public_sys-resources/icon-note.gif) **NOTE:**
>
>Contact technical support for handling critical faults.
>During the troubleshooting, the maintenance personnel may perform operations that may affect service data, such as modifying configurations and restarting VMs. Therefore, to ensure data security, save onsite data and back up related databases, alarm information, and log files before the troubleshooting.
>If system maintenance personnel cannot rectify the fault, contact technical support for assistance.

### 5.2 Information Collection<a name="ZH-CN_TOPIC_0000002518192810"></a>

#### 5.2.1 Statement <a name="ZH-CN_TOPIC_0000002549712567"></a>

Observe the following principles during information collection:

- Perform maintenance operations only after receiving explicit approval from the customer. Any operation without explicit customer approval is prohibited.
- Do not transfer fault locating data out of the customer's network without the customer's approval.

#### 5.2.2 Basic Information Collection<a name="ZH-CN_TOPIC_0000002549712559"></a>

**Collecting Site Information<a name="section4323131116418"></a>**

After a fault occurs, collect site information for technical support and R&D engineers to learn about the site. In addition, provide the phone numbers of onsite engineers to ensure smooth communication.

The following table lists the site information to be collected.

**Table 1** Site information to be collected<a id="site-information-to-be-collected"></a>

|Carrier or Enterprise|Site|Networking Diagram|Onsite Engineer Name and Phone Number|Customer Name and Phone Number|
|--|--|--|--|--|
|Version information|-|-|-|-|
|Remote maintenance information|-|-|-|-|

**Collecting Basic Fault Information<a name="section19389174953610"></a>**

Collect basic fault information to learn about the site, current device status, device status before the fault occurred, and possible causes of the fault. For details, see the following table.

**Table 2** Basic fault information to be collected<a id="basic-fault-information-to-be-collected"></a>

|Required Information|Collected Information|
|--|--|
|Symptom|-|
|Fault occurrence time|-|
|Fault occurrence frequency|-|
|Impact on services|-|
|Fault handling progress|-|
|Operations performed in the system when the fault occurs|-|
|Operations performed for rectifying the fault that occurred during maintenance|-|
|Measures taken to handle the fault|-|
|Effect of the measures taken to handle the fault|-|
|Whether alarms are generated|-|
|Whether site alarm information is collected|-|

**Collecting Fault-related Alarm Information<a name="section350713449381"></a>**

Collect alarm information related to the fault for further analyzing, locating, and rectifying the fault. For details, see the following table.

**Table 3** Alarm information to be collected<a id="alarm-information-to-be-collected"></a>

|Parameter|Value|
|--|--|
|Alarm ID|-|
|Severity|-|
|Alert name|-|
|Alarm source/object|-|
|Generated at|-|
|Region|-|
|Type|-|
|Possible causes|-|
|Additional information|-|

**Collecting Log Information<a name="section168781199405"></a>**

Collect system logs and view details about user operations and operation time in the system to analyze and locate the fault. The following table lists the logs to be collected.

**Table 4** Logs to be collected<a id="logs-to-be-collected"></a>

|Category|Details|
|--|--|
|Android logs| Run the `logcat` command to collect logs in the log buffer.|
| Collect the application stack information (in `/data/anr`) during an ANR.||
| Run the `dumpsys activity`, `dumpsys meminfo`, and `dumpsys input` commands to collect necessary dumpsys information.||
| Run the `ps -a` command to collect process information.||
| Run the `getprop` command to collect system property information.||
|Server logs| Collect syslog and kernel logs in `/var/log`.|
| Run the `dmesg -T` command to collect and view the startup information.||
| Run the `docker stats/docker inspect` command to collect Docker logs.||

The Kbox_maintainer tool provides the one-click log collection capability. For details about how to use Kbox_maintainer to collect logs, see section "Collecting Logs" in [Routine Maintenance](routine_maintenance.md).
