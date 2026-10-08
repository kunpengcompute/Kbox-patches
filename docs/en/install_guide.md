# Installation Guide<a id="ZH-CN_TOPIC_0000002521623658"></a>

<!-- md-trans-meta sourceCommit=4bfff361ae6ddb9d220f2eb3c086fb11de00d0f9 translatedAt=2026-09-18T10:37:25.038Z pushedAt=2026-09-21T13:39:28.853Z -->

## Deployment Description<a id="ZH-CN_TOPIC_0000002518192330"></a>

To help you quickly deploy Kbox, Kunpeng BoostKit provides demo deployment scripts and demo patches. The following describes how to use the cloud phone demos on a Kunpeng server.

## Environment Setup<a id="ZH-CN_TOPIC_0000002549832091"></a>

### Hardware Environment<a id="ZH-CN_TOPIC_0000002549832093"></a>

Before deploying the Kbox cloud phone container environment, ensure that your hardware environment meets the requirements.

For details, see [**Table 1** Hardware configuration schemes for deploying the Kbox cloud phone container](#hardware-configuration-schemes-for-deploying-the-kbox-cloud-phone-container).

**Table 1** Hardware configuration schemes for deploying the Kbox cloud phone container<a id="hardware-configuration-schemes-for-deploying-the-kbox-cloud-phone-container"></a>

|Configuration Item|Configuration Scheme 1|Configuration Scheme 2|Configuration Scheme 3|Configuration Scheme 4|Configuration Scheme 5|
|---|---|---|---|---|---|
|CPU|2 x Kunpeng 920, 64 cores@2.6 GHz|2 x Kunpeng 920, 64 cores@2.6 GHz|2 x new Kunpeng 920 processor model, 80 cores@2.9 GHz|2 x new Kunpeng 920 processor model, 64 cores@2.2 GHz|2 x new Kunpeng 920 processor model, 80 cores@2.9 GHz|
|Memory|16 x DDR4 RDIMM-32 GB-2933 MT/s|16 x DDR4 RDIMM-32 GB-2933 MT/s|16 x DDR5 DIMM-64 GB-4800 MT/s|16 x DDR5 DIMM-64 GB-5200 MT/s|16 x DDR4 DIMM-64 GB-3200 MT/s|
|Encoding card|1 x NETINT Quadra T2A (x8)|None|None|None|None|
|GPU|2 x AMD W6800|4 x DaoCloud DC1000|8 x DaoCloud DC1000 or 8 x DaoCloud DC1000C|8 x DaoCloud DC1000|8 x DaoCloud DC1000|
|OS|openEuler 22.03 LTS SP4|openEuler 22.03 LTS SP4|openEuler 22.03 LTS SP4|openEuler 22.03 LTS SP4|openEuler 22.03 LTS SP4|
|Kernel version|5.10.0-216.0.0|5.10.0-216.0.0|5.10.0-216.0.0|5.10.0-216.0.0|5.10.0-216.0.0|

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>- Select the Mellanox NICs compatible with the Kunpeng server. You can visit [Kunpeng Computing Compatibility Query](https://info.support.huawei.com/computing/tools/compatibility-query/enterprise/kunpeng-computing/component-compatibility?lang=en) to query compatible NIC models.
>- NETINT Quadra is the next generation of the NETINT T432 encoding card. The following content uses the Quadra encoding card as an example. You can refer to the content as well if the T432 encoding card is used.

### Software Environment<a id="ZH-CN_TOPIC_0000002518352230"></a>

Before deploying a Kbox Android container on openEuler 22.03 LTS SP4 (kernel version 5.10.0-216.0.0), obtain the required software packages from the addresses provided in this section and verify the integrity of the software packages provided by Huawei.

#### Obtaining Software Packages<a id="section18549163914575"></a>

Currently, the Kbox Android container supports Android 11. [**Table 2**](#software-requirements) lists the software requirements for environment deployment. Use the recommended software packages.

**Table 2** Software requirements<a id="software-requirements"></a>

|No.|Software Package|Description|How to Obtain|Configuration Scheme 1|Configuration Scheme 2|Configuration Scheme 3|Configuration Scheme 4|
|---|---|---|---|---|---|---|---|
|1|android.tar| Kbox Android image package, which is used to deploy the Kbox basic environment.|Prepare it by yourself. For details, see [Compilation Guide](compile_guide.md).|√|√|√|√|
|2|BoostKit-boostcph-kbox_*.zip| Android Kbox binary package, which contains required components.|Please submit an issue.|√|√|√|√|
|3|kernel-5.10.0-216.0.0.zip| openEuler 22.03 LTS SP4 kernel source code.|[Link](https://gitcode.com/openeuler/kernel/tree/5.10.0-216.0.0)|√|√|√|√|
|4|ExaGear_ARM32-ARM64_V2.5.tar.gz| Binary package for ExaGear transcoding.|[Link](https://raw.gitcode.com/boostkit/boostcph/blobs/7ef9a9a3e1f45f1d1d974d45ce191f5f8f9de076/ExaGear_ARM32-ARM64_V2.5.tar.gz)|√|√|√|√|
|5|linux-firmware-20210919.tar.gz| Firmware for running Kbox.|[Link](https://mirrors.aliyun.com/linux-kernel/firmware/linux-firmware-20210919.tar.gz)|√|-|-|-|
|6|Kbox-patches-AOSP11.zip| Demo kernel patch package and demo container deployment script package.|[Link](https://gitcode.com/boostkit/Kbox-patches)<br>Click the download icon on the AOSP11 branch page.|√|√|√|√|
|7|NETINT-vXXX.tar.gz| NETINT codec library. This software package is required for enabling hardware decoding. The matching version is 4.8.F-adapt.|[Link](https://www.netint.cn/kunpeng-quadra-firmware-downloads/)<br>Download password: test123|√|-|-|-|
|8|Quadra_V*XXX*.zip| Quadra software, firmware, and document packages of the NETINT encoding card.|[Link](https://www.netint.cn/kunpeng-quadra-firmware-downloads/)<br>Download password: test123|√|-|-|-|
|9|VAGPU-25.03.01.01-RC24-SP1.tgz| GPU driver|Please submit an issue.|-|√|√|√|

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>- **√** indicates that the software needs to be installed for the respective configuration scheme.
>- **-** indicates that the software is not required for the respective configuration scheme.
>- The preceding software package names are for reference only, and the actual package names are subject to the download methods. You are advised to rename the packages based on the preceding table to facilitate subsequent operations.

#### Verifying Software Package Integrity<a id="zh-cn_topic_0000001506119857_zh-cn_topic_0000001323011582_zh-cn_topic_0000001214652748_section1134661021416"></a>

To prevent software packages from being maliciously tampered with during transfer or storage, download also the corresponding SHA256 files for integrity verification while obtaining the software packages.

1. Obtain the software packages and the corresponding SHA256 files based on [**Table 2** Software requirement](#software-requirements).

2. Calculate the SHA256 checksum of a package. On Linux, execute the following command:

    ```bash
    sha256sum <package>
    ```

    On Windows, execute the following command:

    ```bash
    certutil -hashfile <package> SHA256
    ```

    After the command is executed, the checksum is output.

3. Compare the calculated checksum with the checksum in the SHA file. If the checksums are consistent, the package is intact. If the checksums are inconsistent, the package integrity has been compromised and you need to obtain the package again.

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>- If the verification fails, do not use the software package. Submit an issue for feedback.
>- Before a software package is used for installation or upgrade, its SHA256 checksum also needs to be verified to ensure that the software package is not tampered with.

## Deployment Process<a id="ZH-CN_TOPIC_0000002549832101"></a>

This section describes the process of deploying the Kbox Android container environment to help you better understand each phase of the deployment. If hardware configuration scheme 2, 3, or 4 is used, you need to install the GPU driver.

[**Figure 1** Deployment process](#deployment-process) shows the process of deploying a container environment.

**Figure 1** Deployment process<a name="fig269321515327"></a><a id="deployment-process"></a>

![Deployment process](./figures/deployment-process.png "deployment-process")

## Configuring the BIOS<a id="ZH-CN_TOPIC_0000002549832109"></a><a id="configuring-the-bios"></a>

### Inserting DIMMs<a id="ZH-CN_TOPIC_0000002549832089"></a>

The BIOS version of the specified server has restrictions on the DIMM insertion method. Before setting the BIOS, ensure that you have inserted DIMMs in the same way as described in this section.

[**Figure 2** DIMM insertion](#dimm-insertion) shows the DIMM insertion methods. Each row in the table corresponds to the CPU ID and each column corresponds to the number of inserted DIMMs. Insert the DIMMs based on the CPU ID and the number of inserted DIMMs, as well as their corresponding row and column in the table.

**Figure 2** DIMM insertion<a name="fig10693358191820"></a><a id="dimm-insertion"></a>
![DIMM insertion](./figures/dimm-insertion.png "dimm-insertion")

### (Hardware Configuration Scheme 1 or 2) Configuring the BIOS<a id="ZH-CN_TOPIC_0000002549712099"></a><a id="configuring-the-bios-for-scheme-1-or-2)"></a>

#### Restarting the Server and Entering the BIOS Setup Screen<a id="section2017525320112"></a>

1. Log in to the remote management platform of the server. On the Remote Virtual Console, press **Del** or **F4** after the system boot screen is displayed.

    ![Remote management platform startup interface](./figures/zh-cn_image_0000002549712111.png)

2. Enter the BIOS password to access the BIOS setup screen.

    ![BIOS setup screen](./figures/BIOS-2-0.png)

#### Configuring MISC Options<a id="section131715818217"></a>

Set **Support Smmu** and **Support 44Bit** as follows.

1. On the BIOS setup screen, choose **Advanced > MISC Config**.

    ![MISC Config](./figures/BIOS4.png)

2. On the **MISC Config** screen, set **Support Smmu** to **Disabled**.

    ![Support Smmu](./figures/zh-cn_image_0000002549712115.png)

3. (Hardware configuration scheme 1) Set **Support 44Bit** to **Enabled**.

    ![Support 44Bit](./figures/zh-cn_image_0000002549832119.png)

4. Save the settings and exit.

#### Configuring Performance Options<a id="section18236319121"></a>

1. On the BIOS setup screen, choose **Advanced > Performance Config**.

    ![Performance Config](./figures/BIOS6.png)

2. On the **Performance Config** screen, set **Power Policy** to **Performance**. Save the settings and exit.

    ![Power Policy](./figures/BIOS7.png)

#### Configuring Memory Options<a id="section2544330723"></a>

Set **Memory Frequency** and **Custom Refresh Rate** as follows.

1. On the BIOS setup screen, choose **Advanced > Memory Config**.
2. On the **Memory Config** screen, set **Memory Frequency** to **2933** and **Custom Refresh Rate** to **Auto**. Save the settings and exit.

    ![Memory Config](./figures/zh-cn_image_0000002549712119.png)

#### (Hardware Configuration Scheme 1, Optional) Configuring PCIe Options<<a id="section1053210511726"></a>

If hardware configuration scheme 1 is used and the hardware decoding function of the encoding card is required, you need to set PCIe options to configure encoding card bandwidth splitting. In this way, the encoding card can achieve better performance and compatibility in various scenarios.

1. On the BIOS setup screen, choose **Advanced > PCIe Config**.
2. On the **PCIe Config** screen, set the PCIe splitting option of the slot where the NETINT Quadra card is installed to **x4**, save the settings, and exit.

    For example, if the Quadra card is installed in slot 3, set **Slot3 BandWidth Splitting** to **x4**.

    ![PCIe Config](./figures/zh-cn_image_0000002549832123.png)

3. Access the server OS. Run the `nvme` command to confirm that the PCIe splitting setting takes effect.

    1. The NETINT encoding card uses the NVMe protocol. If NVMe is not installed in the environment, install it.

        ```bash
        yum install nvme-cli
        ```

    2. After installing the NETINT encoding card, run the following command to check whether the card is correctly identified:

        ```bash
        nvme list
        ```

        If information similar to the following is displayed, the NETINT card is correctly installed. The command output is only an example.

        ```bash
        Node          SN                   Model            Namespace Usage                    Format           FW Rev
        ------------- -------------------- ---------------- --------- ------------------------ ---------------- --------
        /dev/nvme0n1  Q2A325A11DC082-0454A QuadraT2A        1         8.59  TB /   8.59  TB    4 KiB +  0 B     48F6rKr1
        /dev/nvme1n1  Q2A325A11DC082-0454B QuadraT2A        1         8.59  TB /   8.59  TB    4 KiB +  0 B     48F6rKr1
        ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >- One NETINT Quadra card has two chips, corresponding to two device nodes. The preceding output shows one NETINT Quadra card, which corresponds to two device nodes.
    >- One T432 (x8) card has four chips. Therefore, the bandwidth after bandwidth splitting is x2. For example, if the T432 card is installed in slot 3, set **Slot3 BandWidth Splitting** to **x2**.

### (Hardware Configuration Scheme 3 or 4) Configuring the BIOS<a id="ZH-CN_TOPIC_0000002518352254"></a><a id="configuring-the-bios-for-scheme-3"></a>

This section describes how to configure the BIOS in hardware configuration scheme 3 or 4, including MISC, performance, and memory options, to improve server performance.

#### Restarting the Server and Entering the BIOS Setup Screen<a id="section2017525320112"></a>

1. Log in to the remote management platform of the server. On the Remote Virtual Console, press **Del** or **F4** after the system boot screen is displayed.

    ![BIOS](./figures/bios-setup-screen.png)

2. Enter the BIOS password to access the BIOS setup screen.

    ![BIOS](./figures/BIOS-2-0-0.png)

#### Configuring MISC Options<a id="section131715818217"></a>

Configure the **Support Smmu** option as follows.

1. On the BIOS setup screen, choose **Advanced > MISC Configuration**.

    ![MISC Configuration](./figures/zh-cn_image_0000002518352274.png)

2. On the **MISC Configuration** screen, set **Support Smmu** to **Disabled**. Save the settings and exit.

    ![Support Smmu](./figures/zh-cn_image_0000002549712125.png)

#### Configuring Performance Options<a id="section18236319121"></a>

1. On the BIOS setup screen, choose **Advanced > Power And Performance Configuration**.

    ![Power And Performance Configuration](./figures/zh-cn_image_0000002518192348.png)

2. On the **Power And Performance Configuration** screen, set **Power Policy** to **Performance**. Save the settings and exit.

    ![Power Policy](./figures/zh-cn_image_0000002549832129.png)

#### Configuring Memory Options<a id="section2544330723"></a>

Set **Memory Frequency** and **Custom Refresh Rate** as follows.

1. On the BIOS setup screen, choose **Advanced > Memory Configuration**.

    ![Memory Configuration](./figures/zh-cn_image_0000002549712123.png)

2. On the **Memory Configuration** screen, set **Memory Frequency** to **4800** for hardware configuration scheme 3, to **5200** for hardware configuration scheme 4, or to **3200** for hardware configuration scheme 5. Set **Custom Refresh Rate** to **Auto**, save the settings, and exit.

    ![Memory Frequency](./figures/zh-cn_image_0000002518352278.png)

## Binding NICs to CPUs<a id="ZH-CN_TOPIC_0000002518192328"></a>

When the CPU occupied by the network service is the same as the CPU bound to the container, the CPU resources in the container may be abnormal. To avoid this problem, bind NICs with heavy traffic and heavy load to idle CPUs.

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>- Perform the following operations each time the server is restarted.
>- If multiple NICs are used on the server, perform the following steps for each NIC.

1. <a id="zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li189522054171512"></a>Run the following command to check the PCI device number of a NIC. This document uses NIC `enp125s0f1` as an example.

    ```bash
    ethtool -i enp125s0f1 | grep bus-info | awk '{print $2}'
    ```

    In the following command output, the PCI device number of `enp125s0f1` is `0000:7d:00.1`.

    ```bash
    0000:7d:00.1
    ```

2. Run the following command to query the interrupts related to the NIC.

    In the command, ${id_pci} indicates the NIC device number obtained in [1](#zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li189522054171512).

    ```bash
    cat /proc/interrupts | grep "${id_pci}" | awk -F: '{print $1}'
    ```

    In the following command output, the interrupts corresponding to the NIC are `358` and `359`.

    ```bash
    358
    359
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >If the NIC involves a large number of interrupts, check whether the interrupts are bound to different CPUs and determine whether to change the bound CPUs based on the check result.

3. Query the CPUs to which the interrupts are bound. ${break_value} in the command is the NIC interrupt ID queried in the previous step.

    ```bash
    cat /proc/irq/${break_value}/smp_affinity_list
    ```

    - If the interrupts are bound to different CPUs and the CPUs bound to the NIC interrupts do not conflict with the CPUs bound to the container, skip the following steps in this section.
    - If most of the interrupts are on the same CPU or the NIC interrupts with high CPU usage need to be bound to an idle CPU, bind the NIC interrupts to a reserved CPU based on [4](#zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li1667182211497) and [5](#zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li1985492711497). The CPU in the NUMA node to which the NIC belongs is preferred.

4. <a id="zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li1667182211497"></a>Check the NUMA node to which the NIC belongs based on the PCI device number.

    In the command, ${id_pci} indicates the device number of the NIC. You can check the device number based on [1](#zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li189522054171512). Run the following command. The value of `NUMA node` in the command output is the NUMA node to which the NIC belongs.

    ```bash
    lspci -vvvs ${id_pci}
    ```

    In the following command output, the NUMA node of `enp125s0f1` obtained based on the PCI device number is 0.

    ```bash
    7d:00.1 Ethernet controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE Network Controller (rev 21)
            Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
            Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
            Latency: 0
            NUMA node: 0
            Region 0: Memory at 121040000 (64-bit, prefetchable) [size=64K]
            Region 2: Memory at 120400000 (64-bit, prefetchable) [size=1M]
            Capabilities: [40] Express (v2) Endpoint, MSI 00
    ```

5. <a id="zh-cn_topic_0000001259692597_zh-cn_topic_0000001256733899_li1985492711497"></a>Bind NIC interrupts to reserved CPUs. CPUs in the NUMA node to which the NIC belongs are preferred.

    In the following commands, ${break_1} and ${break_2} are the IDs of the two NIC interrupts.

    - Bind interrupt ${break_1} to CPU 1.

        ```bash
        echo 1 > /proc/irq/${break_1}/smp_affinity_list
        ```

    - Bind interrupt ${break_2} to CPU 2.

        ```bash
        echo 2 > /proc/irq/${break_2}/smp_affinity_list
        ```

    Take NIC `enp125s0f1` as an example. The corresponding interrupts are `358` and `359`, and the corresponding commands are as follows:

    ```bash
    echo 1 > /proc/irq/358/smp_affinity_list
    echo 2 > /proc/irq/359/smp_affinity_list
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >After obtaining the NUMA node to which the NIC belongs, run the following command to view the core range of the NUMA node:
    >
    >```bash
    >lscpu
    >```
    >
    >As shown in the command output, the core range of NUMA node 0 is 0 to 31.
    >
    >```bash
    >NUMA node0 CPU(s):               0-31
    >NUMA node1 CPU(s):               32-63
    >NUMA node2 CPU(s):               64-95
    >NUMA node3 CPU(s):               96-127
    >```

## (Hardware Configuration Scheme 1) Configuring the GPU Working Mode and CPU Binding<a id="ZH-CN_TOPIC_0000002518352232"></a><a id="configuring-the-gpu-working-mode-and-cpu binding"></a>

If hardware configuration scheme 1 is used, set the GPU working mode to the high-performance mode to enable the GPU to run at the maximum frequency and maintain the optimal GPU performance. This operation needs to be performed each time the system is restarted.

Run the following command:

```bash
find /sys -name power_dpm_force_performance_level | xargs -I {} sh -c "echo high > '{}'"
```

To ensure stable CPU resources, bind GPU driver processes to idle cores. The binding procedure is as follows:

1. Query GPU process identifiers (PIDs).

    ```bash
    ps -ef |grep gfx
    ```

    The following information is displayed:

    ```bash
    root        1703       2  1 Aug31 ?        07:31:36 [gfx_0.0.0]
    root        1739       2  1 Aug31 ?        09:13:08 [gfx_0.0.0]
    ```

2. Bind the first GPU process to idle cores.

    ```bash
    taskset -pc 32-33 1703
    ```

    Command output:

    ```bash
    pid 1703's current affinity list: 0-127
    pid 1703's new affinity list: 32,33
    ```

3. Bind the second GPU process to idle cores.

    ```bash
    taskset -pc 64-65 1739
    ```

    Command output:

    ```bash
    pid 1739's current affinity list: 0-127
    pid 1739's new affinity list: 64,65
    ```

    If four GPU driver processes are found, bind the first two driver processes to cores 32 to 33 and the last two driver processes to cores 64 to 65.

## Compiling the Kernel<a id="ZH-CN_TOPIC_0000002549712085"></a>

### One-Click Kernel Compilation Script<a id="ZH-CN_TOPIC_0000002549712089"></a>

Huawei provides the `kbox_install_kernel.sh` script for automatic kernel compilation and installation. This script includes all operations required for manually compiling and installing the kernel. You can run this script to quickly compile and install the kernel. Alternatively, you can manually compile and install the kernel based on the "Manual Compilation" part.

The `kbox_install_kernel.sh` script can be used to compile the kernel of openEuler 22.03 LTS SP4 (kernel version 5.10.0-216.0.0). To obtain the script, obtain the `Kbox-patches-AOSP11.zip` package and decompress it based on [Software Environment](#software-requirements). The script is stored in the `Kbox-patches-AOSP11/deploy_scripts/openEuler_deploy` directory. For details about how to use the script, see the comments at the beginning of the script.

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>The kernel configurations and modifications in the script are for functional reference only. It is not advised to use the Kunpeng BoostKit for Cloud Phone demos in commercial solutions. Customers or ISVs must perform necessary security assessment before commercial use. Using the Kunpeng BoostKit for Cloud Phone demos implies the user's acceptance of all associated security risks.

### (Optional) Manual Compilation<a id="ZH-CN_TOPIC_0000002549712101"></a>

#### Preparations<a id="ZH-CN_TOPIC_0000002518352252"></a>

The Kbox cloud phone container supports kernel source code compilation on openEuler 22.03 LTS SP4 (kernel version 5.10.0-216.0.0). Before the compilation, configure the network environment, software repository, and system time of the server for downloading the related compilation dependencies.

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>- The kernel configurations and modifications in this section are for functional reference only. It is not advised to use the Kunpeng BoostKit for Cloud Phone demos in commercial solutions. Customers or ISVs must perform necessary security assessment before commercial use. Using the Kunpeng BoostKit for Cloud Phone demos implies the user's acceptance of all associated security risks.
>- For details about how to install the openEuler OS, see [openEuler 22.03 LTS SP4 Installation Guide](https://docs.openeuler.openatom.cn/en/docs/22.03_LTS_SP4/server/installation_upgrade/installation/installation_preparations.html).

During the compilation, use the `root` user to log in and perform operations.

1. Disable the warning `your kernel does not support swap memory limit...` and add `cgroup_enable=memory swapaccount=1` to the end of the `GRUB_CMDLINE_LINUX` configuration item in the `/etc/default/grub` file.

    1. Check the current configuration.

        ```bash
        cat /etc/default/grub | grep "cgroup_enable=memory swapaccount=1"
        ```

    2. If the command output is empty, run the following command to configure the kernel boot items:

        ```bash
        sed -i '/GRUB_CMDLINE_LINUX/s/\"$//' /etc/default/grub; sed -i '/GRUB_CMDLINE_LINUX/s/$/ cgroup_enable=memory swapaccount=1\"/' /etc/default/grub
        ```

    3. Check the setting result.

        ```bash
        cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX"
        ```

        The following is a command output example. It is normal if there are other fixed parameters.

        ```bash
        GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
        ```

    4. Update the GRUB configuration file.

        ```bash
        grub2-mkconfig -o /boot/efi/EFI/openEuler/grub.cfg
        ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >The configuration takes effect after the system is restarted. You can restart the system after operations in [Compiling and Installing the Kernel](#compiling-and-installing-the-kernel) are completed to make all settings take effect.

2. Disable SELinux.

    1. Configure SELinux.

        ```bash
        sed -i "s|^SELINUX=.*|SELINUX=disabled|g" /etc/selinux/config
        ```

    2. Check the setting result.

        ```bash
        cat /etc/selinux/config | grep "^SELINUX="
        ```

        Ensure that the command output is as follows:

        ```bash
        SELINUX=disabled
        ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >- If there is no `/etc/selinux/config` file, run the following command to create a file and write the SELinux rule into the file:
    >
    > ```bash
    > echo "SELINUX=disabled" > /etc/selinux/config
    >    ```
    >
    >- The configuration takes effect after the system is restarted. You can restart the system after operations in [Compiling and Installing the Kernel](#compiling-and-installing-the-kernel) are completed to make all settings take effect.

3. When multiple Kbox containers are started, the file access workload is heavy on the host. In this case, adjust the maximum number of inotify instances that can be created.
    1. Check the current configuration.

        ```bash
        cat /etc/sysctl.conf | grep "fs.inotify.max_user_instances=8192"
        ```

    2. If the command output is empty, run the following command to configure the maximum number of inotify instances:

        ```bash
        echo "fs.inotify.max_user_instances=8192" >> /etc/sysctl.conf
        ```

    3. Check the setting result.

        ```bash
        cat /etc/sysctl.conf | grep "fs.inotify.max_user_instances"
        ```

        Ensure that the command output is as follows:

        ```bash
        fs.inotify.max_user_instances=8192
        ```

    4. Make the modification take effect.

        ```bash
        sysctl -p
        ```

4. Install base dependencies.

    ```bash
    yum install -y make dpkg dpkg-devel openssl openssl-devel ncurses ncurses-devel bison flex bc libdrm build elfutils-libelf-devel patch gcc dwarves
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >If a package fails to be obtained during the installation, you are advised to manually obtain its installation package based on the address displayed in the message and install it. After the installation is successful, continue to install the remaining dependency packages.

5. Install Docker and lxcfs. If Docker and lxcfs have been installed, skip this step.

    Run the following commands to install Docker and lxcfs, start the lxcfs service, and set the lxcfs service to automatically start upon system startup:

    ```bash
    yum install -y docker lxc lxcfs lxcfs-tools
    systemctl start lxcfs && systemctl enable lxcfs
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >If an error is reported during lxcfs startup, restart the service or submit an issue to report the problem.

6. (Hardware configuration scheme 1) Upgrade the Linux firmware if you use configuration scheme 1. If the firmware has been upgraded, skip this step.

    Download the `linux-firmware-20210919.tar.gz` file from the link provided in [Software Environment](#software-requirements).

    Upload the installation package to the server, for example, to the `/root` directory, and decompress the package.

    ```bash
    cd ~ && tar -xvpf linux-firmware-20210919.tar.gz
    ```

    After the decompression, the `linux-firmware-20210919` folder is generated in the `root` directory. Copy the firmware file to the standard Linux firmware directory.

    ```bash
    cp -ar linux-firmware-20210919/*gpu /usr/lib/firmware/
    ```

#### Compiling and Installing the Kernel<a id="ZH-CN_TOPIC_0000002549832099"></a>

##### Downloading the Kernel Source Code<a id="ZH-CN_TOPIC_0000002518192308"></a>

This section describes how to obtain the correct kernel source code version and decompress the kernel source code.

1. Download the kernel source package to the local PC based on [Software Environment](#software-requirements), upload the package to the `/usr/src/kernels` directory on the server, and decompress it.

    ```bash
    cd /usr/src/kernels
    unzip kernel-5.10.0-216.0.0.zip
    ```

2. Disable the local version number.

    ```bash
    cd /usr/src/kernels/kernel-5.10.0-216.0.0
    touch .scmversion
    ```

##### Applying Kernel Patches<a id="ZH-CN_TOPIC_0000002549712103"></a>

Apply kernel patches into the kernel source code directory to support Kbox.

1. Create a directory for storing the dependency packages required for environment setup and change the directory permission.

    ```bash
    mkdir ~/dependency
    chmod -R 700 ~/dependency
    ```

2. Decompress `Kbox-patches-AOSP11.zip` and upload the `patchForKernel` and `patchForExagear` directories in the `Kbox-patches-AOSP11` folder to the `~/dependency` directory on the server. Assign appropriate permissions on the uploaded files and directories. You are not advised to assign the write permission for other user groups.
3. Copy the transcoding patch to the kernel source code directory.

    ```bash
    cp ~/dependency/patchForExagear/hostOS/0001-exagear-kernel-module.patch /usr/src/kernels/kernel-5.10.0-216.0.0
    ```

4. Copy the kernel patches to the kernel source code directory.

    ```bash
    cp ~/dependency/patchForKernel/openEuler_22.03/kernel_5.10.0-216.0.0/*.patch /usr/src/kernels/kernel-5.10.0-216.0.0
    ```

5. Apply kernel patches.

    ```bash
    cd /usr/src/kernels/kernel-5.10.0-216.0.0
    for patch_name in *.patch; do echo $patch_name; patch -p1 < $patch_name; done
    ```

##### Compiling and Installing the Kernel<a id="ZH-CN_TOPIC_0000002549832103"></a>

###### Generating and Configuring a .config File<a id="ZH-CN_TOPIC_0000002518352248"></a>

Generate a `.config` file and configure kernel compilation options. This file is used to specify the functions and features to be enabled.

1. Copy the `config` file in the `/boot` directory to the kernel source code directory and rename the file `.config`.

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >- In the command, the name of the config file in the `/boot` directory is only an example. You can use the `uname -r` command to view the actual file name. The config file version must match the OS kernel version.
    >- If the config-\`uname -r\` file does not exist in the `/boot` directory, copy any file prefixed with `config-` in the `/boot` directory to the kernel source code directory on the server and rename the file `.config`.

    ```bash
    cp /boot/config-`uname -r` /usr/src/kernels/kernel-5.10.0-216.0.0/.config
    ```

2. Generate a `.config` file.

    ```bash
    cd /usr/src/kernels/kernel-5.10.0-216.0.0/
    make menuconfig
    ```

3. Select **Load** in the following page:

    ![Load](./figures/kernel-configure-load.png)

4. Select **OK** in the following page:

    ![](./figures/zh-cn_image_0000002518192344.png)

5. Configure the kernel compilation options.

    On the page shown in [**Figure 3** Kernel configuration page](#kernel-configuration-page), configure the kernel compilation options based on [**Table 3** Kernel compilation options](#kernel-compilation-options).

    **Figure 3** Kernel configuration page<a name="fig4732181117012"></a><a id="kernel-configuration-page"></a>
    ![](./figures/kernel-configuration-page.jpg "kernel-configuration-page")

    **Table 3** Kernel compilation options<a id="kernel-compilation-options"></a>

    |Configuration Item|Required Value|Configuration Prompt|Configuration Result Written to the .config File|
    |--|--|--|--|
    |KBOX|Y|[\*] Kernel support for Kbox|CONFIG_KBOX=y|
    |ANDROID_BINDER_DEVICES|binder,hwbinder,vndbinder|(binder,hwbinder,vndbinder) Android Binder devices|CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"|
    |HISI_PMU|M|`<M>` HiSilicon SoC PMU drivers|CONFIG_HISI_PMU=m|
    |SYSTEM_TRUSTED_KEYS|Clear out this field.|( ) Additional X.509 keys for default system keyring|CONFIG_SYSTEM_TRUSTED_KEYS=""|
    |DEBUG_INFO|N|[  ] Compile the kernel with debug info|# CONFIG_DEBUG_INFO is not set|
    |PID_RESERVE|N|[  ] Support for reserve pid|# CONFIG_PID_RESERVE is not set|
    |PSI_DEFAULT_DISABLED|N|[  ] Require boot parameter to enable pressure stall information tracking|# CONFIG_PSI_DEFAULT_DISABLED is not set|

    **Table 4** Configuration for enabling the F2FS kernel compilation option<a id="configuration-for-enabling-the-f2fs-kernel-compilation-option"></a>

    |Configuration Item|Required Value|Configuration Prompt|Configuration Result Written to the .config File|
    |--|--|--|--|
    |CONFIG_F2FS_FS|Y|<\*> F2FS filesystem support|CONFIG_F2FS_FS=y|

    To enable the container to start in F2FS format, you also need to configure the preceding kernel compilation option.

    **Table 5** (Optional) Configurations for enabling the NFS kernel compilation options<a id="configurations-for-enabling-the-nfs-kernel-compilation-options"></a>

    |Configuration Item|Required Value|Configuration Prompt|Configuration Result Written to the .config File|
    |--|--|--|--|
    |CONFIG_NFS_FS|M|[M] NFS client support|CONFIG_NFS_FS=m|
    |CONFIG_NFSD|M|[M] NFS server support|CONFIG_NFSD=m|
    |CONFIG_NFS_V4|M|[M] NFS client support for NFS version 4|CONFIG_NFS_V4=m|

    To enable the container to boot with NFS mount, you also need to configure the preceding kernel compilation options.

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >Configuration methods:
    >- Press the up, down, left, and right arrow keys to navigate the menu.
    >- Press **Enter** to select a submenu or edit the content of a selected item.
    >- Press **Esc** twice to exit.
    >- Press **/** for search.
    >- Press **Y** to compile the selected item into the kernel. The corresponding item is displayed as `[*]`.
    >- Press **N** to exclude the selected item. The corresponding item is displayed as `[ ]`.
    >- Press **M** to compile the selected item into a module (in KO format). The corresponding item is displayed as `<M>`.

    Example:

    1. On the configuration page, press **/** to search, type **STAGING**, and press **Enter**. The search result is displayed, as shown in the following figure.

        ![](./figures/Snipaste_2023-08-14_15-01-18.jpg)

    2. Confirm the number of the configuration item, for example, **(1)** in the following figure. Press **1** to select the configuration item.

        ![](./figures/Snipaste_2023-08-14_15-01-52.jpg)

    3. Press **y** to compile the selected item into the kernel, use the left and right arrow keys to navigate to `<Exit>`, and press **Enter**.

        ![](./figures/Snipaste_2023-08-14_15-02-39.jpg)

    4. On the kernel configuration home page, configure the next item as required.

6. After the configuration is complete, select **Save** on the kernel configuration home page.

    ![Kernel Configuration Save Interface](./figures/kernel_configure_save.png)

7. Select **OK** in the following page:

    ![](./figures/zh-cn_image_0000002518352272.png)

8. Select **Exit** in the following page:

    ![Exit](./figures/zh-cn_image_0000002549712117.png)

9. The home page is displayed. Select **Exit**. The `.config` file is generated in the current folder.

    ![](./figures/kernel-configure-exit.png)

###### Compiling and Installing the Kernel<a id="ZH-CN_TOPIC_0000002549832095"></a><a id="compiling-and-installing- the-kernel"></a>

1. <a id="zh-cn_topic_0000001505919657_zh-cn_topic_0000001373652281_zh-cn_topic_0000001259572633_zh-cn_topic_0000001212014022_li295103241"></a>Compile the kernel.

    ```bash
    cd /usr/src/kernels/kernel-5.10.0-216.0.0
    make -j64
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >If the following information is displayed during the compilation, ensure that the server system time is synchronized to the correct time.
    >
    >```bash
    >make[2]: warning:  Clock skew detected.  Your build may be incomplete.
    >   ```
    >
    >Run the `tzselect` command. Enter the numbers corresponding to your time zone in sequence. After the command is executed, copy the file to `/etc/localtime`.
    >
    >```bash
    >tzselect
    >cp -f /usr/share/zoneinfo/Asia/Beijing /etc/localtime
    >```

2. Check whether the kernel is compiled successfully.

    Check whether `vmlinux` files are generated in the compilation path. If `vmlinux` files are generated, the compilation is successful. You can proceed to the next step. If not, check whether an error is reported during compilation, rectify the fault, and perform [1](#zh-cn_topic_0000001505919657_zh-cn_topic_0000001373652281_zh-cn_topic_0000001259572633_zh-cn_topic_0000001212014022_li295103241) again.

    ```bash
    ll vmlinux*
    ```

    If the following three files are displayed, the compilation is successful.

    ```bash
    -rwxr-xr-x 1 root root 363795992 Nov 17 20:00 vmlinux*
    -rw-r--r-- 1 root root 892957960 Nov 17 20:00 vmlinux.o
    -rw-r--r-- 1 root root    613485 Nov 17 20:00 vmlinux.symvers
    ```

3. Install the kernel modules.

    ```bash
    make modules_install
    ```

4. Install the kernel.

    ```bash
    make install
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >- Before installing the kernel, ensure that dkms is not installed in the system. Otherwise, the error message "Error! Bad return status for module build on kernel: ..." may be displayed during kernel installation. The solution is as follows:
    >    1. Check whether dkms is installed in the system.
    >
    >        ```bash
    >        yum list installed | grep dkms
    >        ```
    >
    >        If a command output is displayed, dkms has been installed.
    >    2. Remove dkms.
    >
    >        ```bash
    >        yum remove -y dkms
    >        ```
    >
    >    3. Reinstall the kernel.
    >
    >        ```bash
    >        make install
    >        ```
    >
    >- During kernel installation, the following error message may be displayed. In this case, you need to run the `make install` command again.
    >
    >    ```bash
    >    dracut-install: Failed to find module 'uds' /lib/modules/5.10.0/kernel/drivers/block/uds.ko
    >    dracut-install: Failed to find module 'kvdo' /lib/modules/5.10.0/kernel/drivers/block/kvdo.ko
    >    ```

5. Update the boot items.

    ```bash
    grub2-mkconfig -o /boot/efi/EFI/openEuler/grub.cfg
    ```

    Set the boot kernel, for example, to `openEuler (5.10.0) 22.03 (LTS-SP4)`.

    ```bash
    grub2-set-default 'openEuler (5.10.0) 22.03 (LTS-SP4)'
    ```

    Reboot the OS for the new kernel to take effect.

    ```bash
    reboot
    ```

6. Check the version of the new kernel. If the version is `5.10.0`, the correct kernel is installed.

    ```bash
    uname -r
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >If the new kernel cannot be accessed after the reboot, select the new kernel to access the system after the BIOS enters the GRUB boot mode, or contact technical support.
    >If the amdgpu kernel module is not successfully installed after the reboot, run the `modprobe amdgpu` command to install it manually.

## Deploying Kbox<a id="ZH-CN_TOPIC_0000002518352236"></a>

### Determining the GPU Topology<a id="determining-the-gpu-topology"></a>

#### Hardware Configuration Scheme 1<a id="section15510204125011"></a>

1. <a id="li34656503552"></a>Query GPU rendering nodes.

    ```bash
    ll /dev/dri/by-path/ | grep renderD
    ```

    Example command output:

    ```bash
    lrwxrwxrwx 1 root root 13 Oct 25 10:58 pci-0000:03:00.0-render -> ../renderD128
    lrwxrwxrwx 1 root root 13 Oct 25 10:58 pci-0000:83:00.0-render -> ../renderD129
    ```

    This indicates that two AMD GPUs are installed in the server, and the rendering nodes are `renderD128` and `renderD129`.

2. Query the NUMA node to which a GPU rendering node belongs.

    ```bash
    cat /sys/bus/pci/devices/0000\:XX\:00.0/numa_node
    ```

    Replace *XX* in the command with the IP address of a node queried in [1](#li34656503552). Take `renderD128` as an example. The query command is as follows:

    ```bash
    cat /sys/bus/pci/devices/0000\:03\:00.0/numa_node
    ```

    Command output:

    ```bash
    0
    ```

    This indicates that `renderD128` belongs to NUMA node 0.

#### Hardware Configuration Scheme 2/3/4<a id="section1941402516517"></a>

Check the NUMA node to which the GPU nodes belong.

```bash
lspci -vvv -d :0200 | grep NUMA
```

Each DaoCloud DC1000/DC1000C has four GPU nodes. The following uses the 4 x DaoCloud DC1000 configuration as an example. Each line in the command output corresponds to a GPU node (renderD node, numbered from 128) in sequence. Example command output:

```bash
NUMA node: 0
NUMA node: 0
NUMA node: 0
NUMA node: 0
NUMA node: 0
NUMA node: 0
NUMA node: 0
NUMA node: 0
NUMA node: 2
NUMA node: 2
NUMA node: 2
NUMA node: 2
NUMA node: 2
NUMA node: 2
NUMA node: 2
NUMA node: 2
```

The command output shows that, in the `/dev/dri/` directory, rendering nodes `renderD128` to `renderD135` belong to NUMA0 and `renderD136` to `renderD143` belong to NUMA2.

### (Hardware Configuration Scheme 1, Optional) Upgrading the NVMe Firmware<a id="ZH-CN_TOPIC_0000002549712087"></a><a id="upgrading-the nvme-firmware"></a>

This section is required only when hardware configuration scheme 1 is used and the hardware decoding function of the encoding card needs to be enabled. If hardware decoding is not required, skip this section.

Before deploying the environment, check whether the encoding card is correctly detected by the NVMe driver and check the NVMe firmware version. If the version is different from that provided in this document, upgrade the firmware.

1. Check whether the encoding card is correctly detected by the NVMe driver.

    ```bash
    nvme list
    ```

    If the following information is displayed, the encoding card is correctly detected. The command output is only an example.

    ```bash
    Node          SN                   Model            Namespace Usage                    Format           FW Rev
    ------------- -------------------- ---------------- --------- ------------------------ ---------------- --------
    /dev/nvme0n1  Q2A325A11DC082-0454A QuadraT2A        1         8.59  TB /   8.59  TB    4 KiB +  0 B     48F6rKr1
    /dev/nvme1n1  Q2A325A11DC082-0454B QuadraT2A        1         8.59  TB /   8.59  TB    4 KiB +  0 B     48F6rKr1
    ```

    If the firmware version (the `FW Rev` column) is inconsistent with the 4.8.F-adapt firmware version, refer to the following steps to upgrade the encoding card firmware.

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >About the NVMe firmware version: The larger the numbers and the later the letters, the newer the version.

2. Extract the 4.8.F-adapt firmware upgrade package from `Quadra_V_XXX_.zip` (*XXX* indicates the version number. Use the actual package name in the following commands) and upgrade the firmware.

    ```bash
    unzip Quadra_VXXX.zip
    cd Quadra_VXXX/
    tar -zxvf Quadra_FW_VXXX.tar.gz
    cd Quadra_FW_VXXX/
    chmod +x quadra_auto_upgrade.sh
    ./quadra_auto_upgrade.sh
    ```

    The upgrade takes about 1 minute.

3. After the upgrade is complete, reboot the system for the upgrade to take effect.

    ```bash
    reboot
    ```

### (Hardware Configuration Scheme 2/3/4) Installing the GPU Driver<a id="ZH-CN_TOPIC_0000002549832107"></a><a id="installing-the-gpu-driver"></a>

You need to install the GPU driver each time the server is restarted if you use hardware configuration scheme 2/3/4.

1. Obtain `VAGPU-25.03.01.01-RC24-SP1.tgz` based on [Software Environment](#software-requirements), upload it to the `~/dependency/` directory, and decompress it to obtain the kernel-space GPU driver.

    ```bash
    cd ~/dependency/
    tar -zxvf VAGPU-25.03.01.01-RC24-SP1.tgz
    ```

2. Install the PCIe driver for the GPU.

    ```bash
    cd ~/dependency/VAGPU-25.03.01.01-RC24-SP1/openEuler-5.10.0/ko_fw/
    insmod va_pci.ko
    ```

3. Copy the firmware in the driver package to the `/lib/firmware/` directory.

    ```bash
    cp rgx* /lib/firmware/
    ```

4. Install the GPU driver.

    The GPU driver starts a kworker process for each GPU node. A single DC1000/DC1000C card has four nodes. To improve the performance of kworker processes, you are advised to use the `kworkerCores` parameter to bind kworker processes to CPU cores. Each value of the `kworkerCores` parameter indicates a core bound to the kworker process of the corresponding GPU node.

    When binding GPU driver processes to CPU cores, **ensure that the CPU cores bound to the kworker processes and GPU rendering nodes belong to the same CPU socket**. For details about how to query the CPU socket to which a GPU rendering node belongs, see [Determining the GPU Topology](#determining-the-gpu-topology).

    Taking DaoCloud DC1000/DC1000C as an example, the following core binding methods are for reference only. You can make adjustments based on actual circumstances.

    Hardware configuration scheme 2 (Kunpeng 920 + 4 x DaoCloud DC1000)

    ```bash
    insmod va_gfx.ko kworkerCores=0,0,1,1,32,32,33,33,64,64,65,65,96,96,97,97
    ```

    Hardware configuration scheme 3 (new Kunpeng 920 processor model + 8 x DaoCloud DC1000/DC1000C)

    ```bash
    insmod va_gfx.ko kworkerCores=80,80,81,81,82,82,83,83,0,0,1,1,2,2,3,3,240,240,241,241,242,242,243,243,160,160,161,161,162,162,163,163
    ```

    Hardware configuration scheme 4 (new Kunpeng 920 processor model + 8 x DaoCloud DC1000)

    ```bash
    insmod va_gfx.ko kworkerCores=64,64,65,65,66,66,67,67,0,0,1,1,2,2,3,3,192,192,193,193,194,194,195,195,128,128,129,129,130,130,131,131
    ```

5. Wait until the script execution is complete and check the kernel logs.

    ```bash
    dmesg | grep VAGPU | grep version
    ```

    In the command output, if the kernel-space driver version is consistent with the GPU firmware version, the GPU driver is installed successfully.

    ```bash
    PVR_K:(Log): 1732521: Meta firmware version: 1.18@6276027B20260608 build: release branch: VAGPU-25.03.01 commit: 033f037b tag: VAGPU-25.03.01.01-RC24-SP1
    ...
    ```

>![](./public_sys-resources/icon-note.gif) **NOTE**
>
>To change the driver version, you need to uninstall the drivers and install the drivers of another version.
>
>1. Delete all containers to release the drivers.
>2. Uninstall the drivers in sequence.
>
> ```bash
> rmmod va_gfx
> rmmod va_pci
>    ```

### Uploading the ExaGear Transcoding Package<a id="ZH-CN_TOPIC_0000002549712107"></a>

When a script is used to start the Kbox container, the ExaGear transcoding feature is automatically enabled based on the ExaGear transcoding package in the `~/dependency` directory. Therefore, you need to upload the ExaGear transcoding package to the directory in advance. If automatic enabling fails, you need to enable ExaGear transcoding manually.

1. Upload the ExaGear transcoding package `ExaGear_ARM32-ARM64_V2.5.tar.gz` to `~/dependency`. Assign appropriate permissions on the uploaded files and directories. You are not advised to assign the write permission for other user groups.
2. <a id="li178196349414"></a>Decompress the transcoding package and adjust the permissions.

    ```bash
    cd ~/dependency/
    tar -xzvf ExaGear_ARM32-ARM64_V2.5.tar.gz
    chown -R root:root ExaGear_ARM32-ARM64
    ```

    >![](./public_sys-resources/icon-note.gif) **NOTE**
    >
    >Only one ExaGear transcoding package can be retained in the `~/dependency` directory. If an earlier ExaGear transcoding package exists, delete it. Otherwise, the error message "Many ubt_a32a64 files exist!" is displayed when the Kbox container is started.

Generally, you do not need to perform the following steps.

If ExaGear transcoding fails to be automatically enabled, perform the following steps to manually enable this function after decompressing the transcoding package (that is, after [step 2](#li178196349414) is performed).

1. Mount the binfmt_misc file system.

    It is mounted by default. If not, manually mount it.

    ```bash
    mount -t binfmt_misc none /proc/sys/fs/binfmt_misc
    ```

2. Create an `/opt/exagear` directory for storing the `ubt_a32a64` file.

    ```bash
    mkdir -p /opt/exagear
    chmod -R 700 /opt/exagear
    ```

3. Copy the `ubt_a32a64` file to the `/opt/exagear` directory.

    ```bash
    cp ~/dependency/ExaGear_ARM32-ARM64/ubt_a32a64 /opt/exagear/
    ```

4. Mount and register the ExaGear transcoding rules.

    ```bash
    echo ":ubt_a32a64:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/opt/exagear/ubt_a32a64:POCF" > /proc/sys/fs/binfmt_misc/register
    ```

5. Check whether the ExaGear rules are successfully registered and ensure that the directories for storing the `ubt_a32a64` file are consistent with `/opt/exagear/ubt_a32a64`.

    ```bash
    cat /proc/sys/fs/binfmt_misc/ubt_a32a64
    ```

    If the following information is displayed, the registration is successful:

    ```bash
    enabled
    interpreter /opt/exagear/ubt_a32a64
    flags: POCF
    offset 0
    magic 7f454c4601010100000000000000000002002800
    mask ffffffffffffff00fffffffffffffffffeffffff
    ```

## Change History

|Release|Date|Description|
|--|--|--|
|01|2026-09-30|This is the first official release.|
