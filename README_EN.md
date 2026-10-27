# Kbox Cloud Phone Overview<a name="ZH-CN_TOPIC_0000002550238281"></a>

<!-- md-trans-meta sourceCommit=a711f4eb3188133e9806d1767fbc959395e715b9 translatedAt=2026-10-22T10:56:05.526Z pushedAt=2026-10-23T03:41:29.469Z -->

[简体中文](./README.md)|English

## What's New

- \[2026-06-30\]: Added support for NFS mount, and enhanced the emulation of the CPU, F2FS file system, system partition, and init process.

- \[2026-03-30\]: Added support for the Android Codec 2.0 framework.

- \[2025-12-30\]: Added support for Android 15.

## Project Overview<a name="ZH-CN_TOPIC_0000002518598550"></a>

### Introduction<a name="ZH-CN_TOPIC_0000002518758442"></a>

The Kbox cloud phone container is a core capability component of the Kunpeng BoostKit cloud phone Turbo toolkit. This document provides the compilation, deployment, and related configuration procedures for the Kbox cloud phone container, and covers the basic concepts, software architecture, and specifications of the Kbox cloud phone. It does not include detailed installation steps (see [Installation Guide](./docs/en/install_guide.md)).

The cloud phone solution is a virtual phone service virtualized based on the Arm server and runs the Android Open Source Project (AOSP). In short, cloud phones are Arm servers that run the Android OS and function as virtual phones. You can remotely control the cloud phone in real time to run Android applications on the cloud. Based on the basic computing power of cloud phones, you can also efficiently build applications for scenarios like cloud gaming, mobile office, and live streaming interaction.

As the foundational software for running Android applications, the Kbox cloud phone container is an important part of the cloud phone Turbo toolkit in Kunpeng BoostKit. It directly runs the AOSP system in a container, mocks peripheral hardware such as the GPS sensor, acceleration sensor, gyroscope, international mobile equipment identity (IMEI), and Wi-Fi, and implements the Gralloc and HWComposer (HWC) modules, ensuring normal startup and running of the AOSP system.

### Software Architecture<a name="ZH-CN_TOPIC_0000002550238279"></a>

This section describes the context logical structure and modules (including module functions) of the Kbox cloud phone container.

[**Figure 1** Kbox cloud phone container architecture](#kbox-cloud-phone-container-architecture) shows the overall architecture of the Kbox cloud phone container.

**Figure 1** Kbox cloud phone container architecture<a name="fig89529117514"></a><a id="kbox-cloud-phone-container-architecture"></a>

![Four-layer structure of the Android container, Docker, OS, and hardware environment](docs/en/figures/kbox-cloud-phone-container-architecture.png)

Android container: The closed-source component Kbox and the AOSP are used to enable basic cloud phones running Android in containers.

Kbox implements hardware emulation (including VInput, sensors, GPS, and IMEI/Wi-Fi mock) and GPU device passthrough, enabling the Android cloud phone container solution. Kbox consists of binary deliverables and demos.

- Binary deliverables include VInput (touchscreen input module), Sensor (sensor emulation), GPS (GPS emulation), IMEI/Wi-Fi mock, Gralloc (off-screen rendering), HWC (image composition), Audio (audio module), and OMX (decoding module).
- Demos (including Media Framework, vold, adbd, init, and netd) provide patches (for reference) based on open-source code of the Android system.

Docker: The open-source Docker software is used to provide a software runtime environment for the Android system.

OS: Open-source openEuler is used as the Docker host OS. The integrated GPU kernel driver is shared by upper-layer container instances and drives GPUs to complete rendering. Ashmem and binder provide basic memory management functions for Android containers.

Hardware: The Arm server, including GPUs, memory, and drives, is used as the hardware platform.

### Cloud Phone Specifications<a name="ZH-CN_TOPIC_0000002518758446"></a>

**Table 1** Kbox basic cloud phone specifications<a id="kbox-basic-cloud-phone-specifications"></a>

|**Item**|**Configuration**|
|--|--|
|CPU core binding policy|2 containers/2 cores|
|Number of cores|2|
|Memory|6 GB|
|Storage|16 GB|
|Resolution|720 x 1280|

## Directory Structure<a name="ZH-CN_TOPIC_0000002550238277"></a>

```shell
├── docs                                           # Project document directory
│   └── en                                         # English document directory
│       ├── figures                                # Directory of figures in documents
│       ├── public_sys-resources                   # Public resources directory
│       ├── best_practices.md                         # Kbox Cloud Phone Best Practices
│       ├── compile_guide.md                          # Kbox Cloud Phone Compilation Guide
│       ├── feature_guide.md                          # Kbox Cloud Phone Feature Guide
│       ├── install_guide.md                           # Kbox Cloud Phone Installation Guide
│       ├── menu.md                                    # Kbox Cloud Phone Document Menu
│       ├── release_notes.md                           # Kbox Cloud Phone Release Notes
│       ├── routine_maintenance.md                     # Kbox Cloud Phone Routine Maintenance
│       ├── security_statement.md                     # Kbox Cloud Phone Security Statement
│       ├── test_guide.md                             # Kbox Cloud Phone Acceptance Test Guide
│       ├── troubleshooting.md                         # Kbox Cloud Phone Troubleshooting
│       ├── user_guide.md                             # Kbox Cloud Phone User Guide
├── deploy_scripts                                 # Container deployment scripts
├── make_img_sample                                # Reference script
├── patchForAndroid15                              # Android patch
├── patchForExagear                                # Transcoding patch
├── patchForKernel                                 # Kernel patch
```

## Version Description<a name="ZH-CN_TOPIC_0000002550278289"></a>

The Kbox cloud phone has two branch versions: Android 11 and Android 15. This section describes the differences and feature changes between the two versions.

**Version Introduction<a name="section10131916143616"></a>**

The Kbox cloud phone is developed based on AOSP and currently supports AOSP 11 and AOSP 15. Due to differences in Android versions, the Kbox cloud phone has code branches `AOSP11` and `AOSP15` to support different Android code.

**Table 2** Code branch differences<a id="code-branch-differences"></a>

|Code Branch|AOSP11|AOSP15|
|--|--|--|
|Supported Kernel Version|5.10|6.6|
|Supported Docker Version|18.0|24.0|
|Corresponding AOSP Version|11|15|

**Change Description<a name="section4408930144513"></a>**

For details about feature changes in each release, see [Release Notes](./docs/en/release_notes.md).

## Environment Setup<a name="ZH-CN_TOPIC_0000002550278295"></a>

For details about the hardware environment and OSs supported by the Kbox cloud phone and the software packages required for environment setup, see "Environment Setup" in [Installation Guide](./docs/en/install_guide.md).

The Kbox cloud phone can be deployed on bare metal servers and VMs. For details, see [Installation Guide](./docs/en/install_guide.md).

## Related Documents<a name="ZH-CN_TOPIC_0000002518598548"></a>

| Resource Type | Resource Name | Description |
|--|--|--|
| Document | [Release Notes](./docs/en/release_notes.md) | Provides basic information and feature updates for each release of the Kbox cloud phone. |
| Document | [Feature Guide](./docs/en/feature_guide.md) | Provides an introduction to the functions and features supported by the Kbox cloud phone. |
| Document | [Compilation Guide](./docs/en/compile_guide.md) | Provides the compilation and build process and operation instructions for the Kbox cloud phone. |
| Document | [Installation Guide](./docs/en/install_guide.md) | Provides detailed guidance for deploying the Kbox cloud phone in both bare metal and VM environments. |
| Document | [User Guide](./docs/en/user_guide.md) | Provides operation guidance for starting and uninstalling Kbox cloud phone instances. |
| Document | [Routine Maintenance](./docs/en/routine_maintenance.md) | Provides content related to routine maintenance of Kbox cloud phone containers. |
| Document | [Best Practices](./docs/en/best_practices.md) | Provides practice cases of the Kbox cloud phone in Docker and Kubernetes environments. |
| Document | [Troubleshooting Cases](./docs/en/troubleshooting.md) | Provides troubleshooting methods for the Kbox cloud phone. |
| Document | [Acceptance Test Guide](./docs/en/test_guide.md) | Provides guidance for product acceptance testing of the Kbox cloud phone. |
| Document | [Security Statement](./docs/en/security_statement.md) | Provides security instructions for using the Kbox cloud phone. |

## Version Maintenance Policy<a name="ZH-CN_TOPIC_0000002518758444"></a>

The Kbox version maintenance policy is as follows.

|**Kbox Version**|**Maintenance Policy**|**Status**|**Release Date**|**Subsequent Status**|**EOL Date**|
|--|--|--|--|--|--|
|Kbox11|Long-term branch|In development|2025/10/15|Maintenance status effective from March 15, 2026 (expected)|-|
|Kbox15|Long-term branch|In development|2025/10/15|Maintenance status effective from March 15, 2026 (expected)|-|

## Disclaimer<a name="ZH-CN_TOPIC_0000002518598546"></a>

This repository contains only AOSP- and Linux kernel-related patches and feature demonstration code. It is intended to demonstrate how to use and integrate specific features. Do not use the code in this repository directly in production environments. All code is for technical reference only and does not inherit or guarantee any security design or protection mechanisms of upstream or downstream software. The sample code in this repository may contain security defects, vulnerabilities, or incomplete implementations. The Kunpeng Computing community assumes no responsibility for the security, stability, or compliance of the code. Users should assess risks on their own and perform security hardening based on their actual scenarios. Any security issues arising from the use of the code in this repository shall be borne by the user. It is recommended to stay informed about security advisories and version updates from upstream open-source projects.

**To Users of This Project**

- This project is intended solely for debugging and development. You are responsible for any risks and should carefully review the following information:
    - Data processing and deletion: Users are responsible for managing and deleting any data generated while using this project. You are advised to promptly delete any related data after use to prevent information leaks.
    - Data confidentiality and transmission: Users understand and agree not to share or transmit any data generated by this project. Neither the project nor its developers are responsible for any information leaks, data breaches, or other negative consequences.
    - User input security: Users are responsible for the security of any commands they enter and for any risks or losses resulting from improper input. The project and its developers are not liable for issues caused by incorrect command usage.

- Disclaimer scope: This disclaimer applies to all individuals and entities using this project. By using the project, you acknowledge and accept this statement and assume all risks and responsibilities arising from its use. If you do not agree, please stop using the project immediately.
- Before using this project, **please read and understand the preceding disclaimer**. If you have any questions, contact the developer.

**To Data Owners**

If you do not want your model or dataset to be mentioned in this project, or if you wish to update its description, please submit an issue on GitCode. We will delete or update your description according to your request. Thank you for your understanding and contribution to this project.

## License<a name="ZH-CN_TOPIC_0000002518758448"></a>

- This project is licensed under Apache License 2.0. For details, see [LICENSE](LICENSE).
- The documents of this project are licensed under CC-BY 4.0. For details, see [LICENSE](docs/LICENSE).

## Contributor Statement<a name="ZH-CN_TOPIC_0000002550238283"></a>

We welcome your contributions to the community. If you have any questions/suggestions or want to provide feedback on feature requirements and bug reports, you can submit [issues](https://gitcode.com/boostkit/community/blob/master/docs/contributor/issue-submit.md). For details, see [Contribution Guideline](https://gitcode.com/boostkit/community/blob/master/docs/contributor/contributing.md). You are also welcome to share insights in [Discussions](https://gitcode.com/boostkit/community/discussions). Thank you for your support.

## Acknowledgement<a name="ZH-CN_TOPIC_0000002550278293"></a>

Thank you to everyone in the community for your PRs. We warmly welcome contributions to Kbox!
