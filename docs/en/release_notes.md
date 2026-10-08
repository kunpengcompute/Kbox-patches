# Release Notes<a id="ZH-CN_TOPIC_0000002521624118"></a>

<!-- md-trans-meta sourceCommit=02a348ddea444e53ed81ec9766237f52d740d877 translatedAt=2026-09-18T10:38:33.395Z pushedAt=2026-09-22T08:20:26.238Z -->

## Version Mapping<a id="ZH-CN_TOPIC_0000002549825975"></a>

### Product Version<a id="ZH-CN_TOPIC_0000002549705973"></a>

| Item | Content |
|---|---|
| Product Name | Kunpeng BoostKit |
| Product Version | 26.2.RC1 |
| Software Name | Kbox cloud phone container |
| Software Package Version | 8.2.RC1_11 |

### Software Version Mapping<a id="ZH-CN_TOPIC_0000002518346116"></a>

|Software|Version|Remarks|
|--|--|--|
|Kunpeng BoostKit|Kunpeng BoostKit 26.2.RC1|-|
|OS|openEuler-22.03-LTS-SP4-AArch64 (kernel 5.10.0-216.0.0)|-|
|ExaGear|ExaGear_ARM32-ARM64_V2.5|Transcoding software|

### Hardware Version Mapping<a id="ZH-CN_TOPIC_0000002518346118"></a>

|Server|Processor|BIOS|CPLD|BMC|
|--|--|--|--|--|
|Kunpeng server|Kunpeng 920 processor|6.57|5.09|6.49|
|Kunpeng server|New Kunpeng 920 processor model|33.70|5.10|26.01.62.25|

## Version Usage Notes<a id="ZH-CN_TOPIC_0000002549705971"></a>

Please refer to the *Feature Guide* of the corresponding version, for example, [Feature Guide](feature_guide.md).

## V8.2.RC1_11<a id="ZH-CN_TOPIC_0000002549825973"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|---|---|---|
|1|Shared data volume|Kbox supports the shared data volume feature.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V8.1.RC1_11<a id="ZH-CN_TOPIC_0000002549825973"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|---|---|---|
|1|NFS mount|Kbox supports NFS mount.|
|2|Enhanced CPU/F2FS file system/System partition/init process emulation|To enhance system emulation capabilities.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V8.0.RC1_11<a id="ZH-CN_TOPIC_0000002549825973"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|---|---|---|
|1|Codec 2.0|Kbox supports the Codec 2.0 encoding and decoding framework.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V7.3.0_11<a id="ZH-CN_TOPIC_0000002549825973"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186202"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Graphics acceleration layer|Enables the graphics acceleration layer in Kbox and provides steps for enabling related functions.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825953"></a>

None

## V7.2.RC1<a id="ZH-CN_TOPIC_0000002549825947"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186192"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Generalization of adaptive frame synchronization| Expands the benefits of adaptive frame synchronization to most applications.|
|2|Support for thread-level shader cache| The shader binary can be pre-built to reduce the first launch time of large OpenGL ES rendering applications by 40% and the frame freezing rate in high-dynamic scenarios by 50%.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549825967"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549705951"></a>

None

## V7.1.RC1<a id="ZH-CN_TOPIC_0000002549705955"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186186"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Memory overcommitment| If the GPU load is greater than or equal to 90%, enabling the memory overcommitment feature can reduce the RAM usage by 10% when launching an identical number of 720p@30 fps cloud phones.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518346100"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549825949"></a>

None

## V7.0.RC1<a id="ZH-CN_TOPIC_0000002549705947"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186190"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Android lightweight trimming| Removes unnecessary system services and built-in applications to reduce cloud phone resource usage, thereby improving system performance and optimizing user experience.|
|2|Dynamic frame rate adjustment| Dynamically decreases the frame rate to reduce rendering overhead when the client is disconnected from the cloud phone in the away from keyboard (AFK) scenario. When the client is disconnected from the cloud phone, the frame rate is decreased. When the client is reconnected to the cloud phone, the frame rate is restored to the normal value.|
|3|Resource monitoring| Monitors GPU memory and other memory resources so that ISVs can perform operations based on resource usage.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549705965"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518186184"></a>

None

## V6.0.0<a id="ZH-CN_TOPIC_0000002518346094"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186198"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Adaptive scalable texture compression (ASTC)| Implements the ASTC function through Vulkan.|
|2|Texture compression| Enables texture compression for cloud phones to reduce the video RAM usage. A switch is provided for toggling this function (enabled by default).|
|3|YCbCr_420_888 format| Implements the YCbCr_420_888 image format for the Kbox Gralloc module.|
|4|Adaptive frame synchronization| Implements the adaptive vertical synchronization (vsync) function. After one frame is rendered, SurfaceFlinger immediately composes the frame and sends it to the screen, reducing the cloud-side latency by 15 ms. In addition, a test report is output based on cloud-side latency measurement.|
|5|Configurable camera emulation data| Supports the configuration of camera emulation data using the `adb` command.|
|6|ART DEX compilation optimization| Accelerates application startup and execution. The CPU and memory usage can also be reduced.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518186182"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518346104"></a>

None

## V6.0.RC2<a id="ZH-CN_TOPIC_0000002549825963"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002549705949"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Android system property customization|Allows users to customize system properties and override original system properties as required.|
|2|Process restart upon unexpected exits|Delivers the process of the binary file. After the process exits abnormally (for example, the process crashes or is forcibly terminated), you can restart the process to resume the functions.|
|3|Document updates|Provides updates related to the server information in the cloud phone documentation.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549825951"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518346092"></a>

None

## V6.0.RC1<a id="ZH-CN_TOPIC_0000002549705945"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002549705967"></a>

#### New Features<a id="section78241436103817"></a>

None

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518186196"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518346098"></a>

| Item | Content |
|---|---|
| Severity | Minor |
| Symptom | The music playback process remains after KuGou is terminated in the multi-window screen. |
| Cause Analysis | The process termination API is not invoked when the app is being terminated in the multi-window screen. It is suspected that the app bypasses process termination through some detection. |
| Impact Assessment | The process cannot be terminated in the multi-window screen, but can be terminated in the notification panel or app info screen. |
| Workaround | Terminate the app in the notification panel or forcibly stop the app in the app info screen. |
| Progress | This issue is under investigation and resolution. |

## V5.0.0<a id="ZH-CN_TOPIC_0000002549825969"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518186176"></a>

#### New Features<a id="section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Custom patch modification for the Kbox kernel|Provides custom ashmem and binder patch modification for Kbox kernel 5.15 to reduce kernel customization and reuse kernel capabilities.|
|2|Network emulation modification for Kbox|Provides the emulation of Kbox network functions. With the IP address, gateway, subnet mask, and DNS information, it can enable the cloud phone to access the network.|
|3|Telephony emulation modification for Kbox|Implements the emulation of the IMEI, IMSI, network operator information, and SIM card information based on Treble  modification for Kbox telephony emulation.|
|4|Audio emulation for Kbox|Previously, Kbox lacked audio emulation support, which could lead to compatibility issues when running audio-dependent applications. Therefore, the audio emulation function needs to be added to Kbox. Constraints: Only audio output emulation is supported. Input emulation is not supported.|

#### Modified Features<a id="section540mcpsimp"></a>

None

#### Removed Features<a id="section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002549825957"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518186180"></a>

None

## V5.0.RC2<a id="ZH-CN_TOPIC_0000002518186178"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002518346102"></a>

#### New Features<a id="zh-cn_topic_0000001549282537_section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Hardware-based acceleration for video playback on cloud phones based on codec cards|Implements hardware-based H.264/H.265 decoding acceleration for video playback on cloud phones based on the NETINT T432 hardware codec card and OMX media framework adaptation.|
|2|Query and display of the Kbox component version|Supports the query and standard display of the Kbox component version.|
|3|Upgrade for adaptation to the kernel of a later version|Modifies the kernel patch related to the Kbox basic cloud phone to adapt to kernel 5.15.|
|4|Adaptation to Mesa 22.1.7|Adapts the Kbox basic cloud phone to Mesa 22.1.7.|
|5|Update of the video stream and Kbox documentations|Updated descriptions of Mesa, kernel, and GPU in the video stream and Kbox documentations.|
|6|Detection and rectification of Android system running exceptions|Checks key processes and services such as SurfaceFlinger, SystemServer, and Zygote of the cloud phone and restores the processes and services if an exception occurs.|
|7|Conversion from Vulkan RGB and RGBA textures to DXT textures|Implements the conversion from Vulkan RGB/RGBA textures to the DXT textures based on the Mesa open-source software.|
|8|Stack protection and anti-exploitation|Implements stack protection and anti-exploitation.|

#### Modified Features<a id="zh-cn_topic_0000001549282537_section540mcpsimp"></a>

None

#### Removed Features<a id="zh-cn_topic_0000001549282537_section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518346106"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518186194"></a>

| Item | Content |
|---|---|
| Severity | Severe |
| Symptom | After the BIOS version is upgraded to 6.56, when the server is restarted, the encoding card chip may fail to be detected. |
| Cause Analysis | Following a server reboot, the encoding card chip occasionally fails to be detected. This low-probability issue can be resolved by a subsequent reboot, but it impacts user experience. |
| Impact Assessment | If the T432 encoding card is used, cloud phone density is affected when this problem occurs. |
| Workaround | 1. Set the server fan modules to high-performance mode via iBMC.<br>2. Intermittent detection failure can be recovered after a power-off restart.<br>3. Damaged key contact pin: Contact the vendor for a card replacement. |
| Progress | 1. Add prompts related to T432 chip loss in the constraints, and add workaround instructions in the documentation to notify users.<br>2. This issue remains open, and the vendor's final root cause analysis result will be tracked. |

| Item | Content |
|---|---|
| Severity | Minor |
| Symptom | When using XPlayer for hardware decoding, the system occasionally falls back to its own software decoding. This prevents stable utilization of Kbox's hardware decoding capabilities, indicating a compatibility issue between Kbox and XPlayer. |
| Cause Analysis | NETINT destruction or initialization occasionally responds slowly. As a result, XPlayer detects that the hardware decoding capability is insufficient, and software decoding is used instead. |
| Impact Assessment | Low-probability container fallback from hardware to software decoding; no impact on actual video playback. |
| Workaround | XPlayer enforces strict response time limits on hardware decoding interfaces. Since falling back to software decoding does not disrupt video playback, no immediate workaround is required. |
| Progress | Continue joint investigation with NETINT to locate and resolve the slow response issue. |

## V5.0.RC3<a id="ZH-CN_TOPIC_0000002518186188"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002549825959"></a>

#### New Features<a id="zh-cn_topic_0000001473962058_section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|ExaGear+openEuler 22.03 LTS transcoding| Enables Kbox to run ExaGear adapted for openEuler 22.03 LTS|
|2|Kbox adaptation based on openEuler 22.03 LTS| Enhances the OS compatibility.|

#### Modified Features<a id="zh-cn_topic_0000001473962058_section540mcpsimp"></a>

None

#### Removed Features<a id="zh-cn_topic_0000001473962058_section543mcpsimp"></a>

Deleted Android 9-related content because this version does not support Android 9.

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518346112"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549705963"></a>

| Item | Content |
|---|---|
| Severity | Suggestion |
| Symptom | When Sky: Children of the Light is installed and opened on a Kbox basic cloud phone, and a login is attempted with an account that has no registered character, the device data is displayed as abnormal and a new character cannot be created. |
| Cause Analysis | The root cause has not been located yet. Two directions can be explored:<br>1. The Kbox device emulation is not yet complete enough and lacks the data required by this game app, which prevents character creation. This needs to be evaluated in the subsequent Kbox evolution strategy.<br>2. The game itself detects that Kbox is not a real physical device, which triggers the anti-cheat mechanism. |
| Impact Assessment | Mitigation measures are available, and the impact is minor. Sky: Children of the Light is not currently in the compatibility list. The purpose of the test is to verify ETC2 texture support, which has been implemented normally. In addition, login can be performed with an account that already has a created character. |
| Workaround | The game can be logged in normally using an account that already has a created character. |
| Progress | This issue remains open. A final decision on whether to close it will be evaluated after a thorough baseline assessment of device emulation capabilities. |

## V3.0.0<a id="ZH-CN_TOPIC_0000002549705969"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002549705959"></a>

#### New Features<a id="zh-cn_topic_0000001468009680_section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|GPU adaptation| Enhances hardware compatibility.|
|2|Bsic cloud phone documentation| Provides guidance for users to use the Kbox cloud phone container.|
|3|Kbox Android 11 cloud phone adaptation| Supports new hardware platforms.|

#### Modified Features<a id="zh-cn_topic_0000001468009680_section540mcpsimp"></a>

None

#### Removed Features<a id="zh-cn_topic_0000001468009680_section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518346108"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002518346110"></a>

None

## V2.0.0<a id="ZH-CN_TOPIC_0000002518346096"></a>

### Change Description<a id="ZH-CN_TOPIC_0000002549825965"></a>

This release inherits all features available from release 2.0.RC1 to release 2.0.RC2.

#### New Features<a id="zh-cn_topic_0000001420053428_section78241436103817"></a>

|No.|Feature|Purpose|
|--|--|--|
|1|Trustworthiness enhancement during the use of open-source software and Docker containers|Remediates open-source software and Docker container usage during development to meet trustworthiness and compliance requirements.|

#### Modified Features<a id="zh-cn_topic_0000001420053428_section540mcpsimp"></a>

None

#### Removed Features<a id="zh-cn_topic_0000001420053428_section543mcpsimp"></a>

None

### Resolved Issues<a id="ZH-CN_TOPIC_0000002518346090"></a>

None

### Known Issues<a id="ZH-CN_TOPIC_0000002549705961"></a>

| Item | Content |
|---|---|
| Symptom | Condition: The CTS test suite is used in the CI daily build scenario.<br>Symptom: Test cases in some modules of the test suite failed to pass corresponding tests in a container. After another container was used, the test cases passed the corresponding tests.<br>Root cause: In this issue, the failed test case in `296 CtsUiAutomationTestCases` is not a baseline test case but an additional test case. The test case will be further analyzed in the CTS special work.<br>The failed test case in `26 CtsAssistTestCases` is caused by the test case itself, whose Google bug ID is 30859355. This issue may be eligible for an exemption.<br>Two failed test cases in `69 CtsGraphicsTestCases` are related to Vulkan enablement. After the two test cases that do not support the extension properties and image format are masked, this module can pass the test.<br>From July 2 to September 3, CI CTS daily build was performed 28 times, among which `CtsWidgetTestCases` failed 4 times, `CtsJvmtiRunTest993HostTestCases` and `CtsAtraceHostTestCases` each failed once, and `CtsAccessibilityTestCases` did not fail. The general failure rate is low. Increasing the number of retries can improve the pass rate of the preceding modules.<br>Impact: The issues occurred occasionally. The module with the highest failure rate failed four times in 28 times of CI daily build, and other modules failed once or did not fail. This affected the CTS pass rate in the CI environment. |
| Severity | Minor |
| Workaround | Increase the number of retries for failed test cases. |

| Item | Content |
|---|---|
| Symptom | Condition: The video stream cloud phone is used to test Cocos.<br>Symptom: When playing a game in landscape mode, touch and hold the notification bar and click the home button on the server side. As a result, the notification bar is forcibly pulled out.<br>Root cause: The pulled-out notification bar needs to be masked. However, this is not implemented in the complex operation scenario described in the symptom part. The masking solution in this scenario is still under discussion and is not modified before this release.<br>Impact: The trigger condition is highly specific and rare. Generally, a user is unlikely to press and hold the notification bar with the left hand while simultaneously pressing and holding the home button with the right hand. In addition, this problem strictly occurs during landscape-to-portrait orientation switches. Even if the notification bar appears, it does not disrupt normal functionality. Therefore, the practical impact is negligible. |
| Severity | Minor |
| Workaround | This issue is rarely triggered in normal use. |

| Item | Content |
|---|---|
| Symptom | Condition: Video stream cloud phone testing with Cocos during CI daily builds.<br>Symptom: After running Cocos test cases in the CI video stream daily build, the server-side cloud phone main interface displays screen artifacts.<br>Root cause: CI log analysis indicates that while Cocos test cases are running, an out-of-bounds memory access occurred within Mesa's `gallium_dri.so`, leading to a Mesa crash. The call stack points to the `eglSwapBuffersWithDamageKHR` interface in the Mesa library. The visible symptom is screen artifacts. Initial findings suggest the issue is related to the third-party Mesa driver component, and further analysis is required to pin down the exact root cause.<br>Impact:<br>1. There is a low probability that this problem occurs. This problem occurred twice on the video stream daily build server (on July 20 and September 4, with a gap of more than one month). In subsequent 6,000 dedicated tests, this problem did not recur.<br>2. Only the cloud phone that runs the test case is affected. Other cloud phones started on the server are not affected. |
| Severity | Minor |
| Workaround | Restart the affected cloud phone. |

| Item | Content |
|---|---|
| Symptom | Condition: Upgrade the server firmware (BIOS 177, CPLD 5.14, and iBMC 3.01.12.23).<br>Symptom: The server uses a new motherboard to upgrade BIOS 177, CPLD 5.14, and iBMC 3.01.12.23, but the upgrade fails, and the server hangs. Currently, no official new versions are available for the new motherboard.<br>Root cause: The server model has two motherboard versions. The link to the BIOS version matching the old motherboard is invalid. In this test, the new motherboard is used. According to the Kunpeng computing hardware developers, the BIOS version matching the new motherboard has not been released. If the latest BIOS version on the Support website is used, the upgrade fails. To solve this problem, the BIOS team needs to release the BIOS version matching the new motherboard to the Support website.<br>Impact: If a customer uses the new motherboard, the customer cannot obtain the matching BIOS version from the Support website. |
| Severity | Minor |
| Workaround | None |

## Documentation<a id="ZH-CN_TOPIC_0000002549825961"></a>

### V7.3.0_11 Documentation<a id="ZH-CN_TOPIC_0000002549825955"></a>

|No.|Document|Description|How to Obtain|
|--|--|--|--|
|1|best_practices| Describes the best practices of the Kbox cloud phone container.|[Best Practices](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/best_practices.md)|
|2|compile_guide| Explains how to compile the Kbox cloud phone container.|[Compilation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/compile_guide.md)|
|3|feature_guide| Describes the features of the Kbox cloud phone container.|[Feature Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/feature_guide.md)|
|4|install_guide| Explains how to install the Kbox cloud phone container.|[Installation Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/install_guide.md)|
|5|release_notes| Describes version information about the Kbox cloud phone container.|[Release Notes](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/release_notes.md)|
|6|test_guide| Explains how to test the Kbox cloud phone container.|[Acceptance Test Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/test_guide.md)|
|7|troubleshooting| Describes the troubleshooting cases of the Kbox cloud phone container.|[Troubleshooting Cases](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/troubleshooting.md)|
|8|user_guide| This document describes how to use the Kbox cloud phone container.|[User Guide](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/user_guide.md)|
|9|routine_maintenance| Describes the maintenance methods and tools for the Kbox cloud phone container.|[Routine Maintenance](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/en/routine_maintenance.md)|

### Obtaining Documentation<a id="ZH-CN_TOPIC_0000002549705957"></a>

View or download required documents from [menu](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/en/menu.md).
