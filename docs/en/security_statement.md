# Security Statement

## 1 Introduction

Kunpeng BoostKit for Cloud Phone enables the Android OS based on the Docker container. It adopts GPU instruction passthrough design and features high density and wide compatibility.

This chapter describes the security specifications of Kunpeng BoostKit for Cloud Phone.

## 2 Security Statement

Huawei provides self-developed binary files, open-source patch files, and script files of Kunpeng BoostKit for Cloud Phone. The open-source patch files and script files are for reference only, and no commercial commitment is made. In addition, customers or independent software vendors (ISVs) are responsible for the development and maintenance of other components involved in the solution, such as the OS on the host side, Docker, and Android OS.

To ensure that Kunpeng BoostKit for Cloud Phone runs reliably and securely in commercial scenarios, it is strongly recommended that customers or ISVs configure proper permission policies, secure transfer mechanisms, and privacy statements when using Kunpeng BoostKit for Cloud Phone, and install the latest security patches and take any necessary security hardening measures for the involved open-source software.

### 2.1 Permission Management

The cloud phone management system is not within the delivery scope of the solution. In commercial scenarios, the following permission management mechanisms are recommended:

1. Define separated permissions to allocate only necessary permissions to each user and develop a comprehensive user management mechanism. This is to prevent administrator or operator accounts of the cloud phone management system from being forged. In addition, key system operations must be logged for audits. Do not assign the system administrator, security administrator, and security auditor roles to the same person.
2. The cloud phone server performs identity authentication on the instructions sent by the management system to limit the number of connections from users who have not been authenticated or have failed the authentication. Identity authentication prevents unauthorized users from initiating malicious operations and DoS attacks.

### 2.2 Secure Transmission

1. To prevent information leakage, use a secure communication protocol for communication between the cloud phone management system and the cloud phone server.
2. When authorized users connect to cloud phones through the Android Debug Bridge (ADB), it is recommended that customers or ISVs provide the SSH certificate for the connection and record key user operations on the server to prevent repudiation.

### 2.3 Privacy Statement

1. The Global Positioning System (GPS), international mobile equipment identity (IMEI), acceleration sensor, and gyroscope sensor provide the data configuration emulation function. This function is generally used only in app hosting test scenarios. It is recommended that customers set non-real emulated data to prevent the leakage of real personal data.
2. When users install apps and games in the cloud phone system, guide them to mainstream app marketplaces or stores. Take measures to prevent unauthorized user data access and malicious operations such as listening.

### 2.4 Secure OS Update

1. When using openEuler, note the latest security updates. Using the latest security updates to repair the OS in a timely manner can prevent the OS from being affected by vulnerabilities or attacked by malicious software. In addition, security updates ensure the proper running of the Android container on the OS.

2. Periodically check whether security updates are available in the OS. If yes, install the updates in a timely manner. For details, see the description on the corresponding official website. The query command varies with the OS.

   ```shell
   yum updateinfo list available
   ```

3. In addition to installing the latest security patches, you also need to harden the security of the server OS, for example, configuring strong passwords and disabling unnecessary service ports. For details, see the description on the corresponding official website.

### 2.5 Android Security Updates

1. The Android ecosystem is supported by Google. The ecosystem not only provides system updates of improved functionality and stability, but also security updates that ensure device security. Security update patches are mainly provided by the Android Open Source Project (AOSP) and upstream Linux kernel and system on a chip (SoC) manufacturers to ensure that Android devices are not affected by the latest security vulnerabilities of hardware and software. Google periodically pushes security updates to devices and releases security update notices.

2. Use the source code provided by the AOSP and the patch links provided in security update notices to perform security updates in a timely manner based on the site requirements to ensure the proper running of Kunpeng BoostKit for Cloud Phone.

>![](public_sys-resources/icon-note.gif) **NOTE**
>
>Periodically update and harden the open-source software involved in the solution. For details, see the official documents of the open-source software.

## 3 Security Statement for the Compatibility Between the SELinux Module and Hosts

The Android virtualization solution provided by Kunpeng BoostKit for Cloud Phone is constructed based on a container. Due to the Docker characteristics, applications running in a container are actually executed on the host OS. In this solution, the Android OS uses the host Linux kernel instead of its own kernel. As a result, the SELinux function of the Android OS is unavailable. The deliverables of Kunpeng BoostKit for Cloud Phone do not contain the solution to this problem. If you want to enable SELinux in your commercial system, you need to find a solution by yourself.

We provide a method for quickly disabling SELinux. The host Linux, Android OS, and Docker are not within the delivery scope of Kunpeng BoostKit for Cloud Phone. The provided modification method is for reference only and is not a commercial deliverable. Therefore, no commercial commitment is made.

Disabling SELinux may cause security issues. If you do not plan to enable SELinux, it is recommended that an end-to-end solution be used to eliminate the risks caused by the lack of SELinux. Kunpeng BoostKit for Cloud Phone applies only to customers who do not demand SELinux. If you choose to use Kunpeng BoostKit for Cloud Phone, you need to bear the security risks.

## 4 Security Statement for Using Docker Containers

Docker is not within the delivery scope of this solution. For security purposes, check and harden the Docker service periodically to ensure proper running of Docker containers. For details, see [Security for developers](https://docs.docker.com/security/).

## 5 Enabling ASLR to Prevent Fixed-Address Attacks

Address space layout randomization (ASLR) is a security technology against buffer overflow. It randomizes the layout of linear areas such as heap, stack, and shared library mapping to make it difficult for attackers to predict target addresses and directly locate code, thereby preventing overflow attacks. ASLR applies to heaps, stacks, and memory mapping areas (mmap base addresses, shared libraries, and vdso pages).

To prevent fixed address attacks, you are advised to enable ASLR. To enable ASLR, run the following command:

```shell
echo 2 > /proc/sys/kernel/randomize_va_space
```
