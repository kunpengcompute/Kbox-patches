# Release Notes<a name="ZH-CN_TOPIC_0000002521624118"></a>

## Version Mapping<a name="ZH-CN_TOPIC_0000002549825975"></a>

### Product Version<a name="ZH-CN_TOPIC_0000002549705973"></a>

<a name="table617mcpsimp"></a>
<table><tbody><tr id="row622mcpsimp"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.1.1"><p id="p624mcpsimp"><a name="p624mcpsimp"></a><a name="p624mcpsimp"></a>Product Name</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.1.1 "><p id="p109881314494"><a name="p109881314494"></a><a name="p109881314494"></a>Kunpeng BoostKit</p>
</td>
</tr>
<tr id="row627mcpsimp"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.2.1"><p id="p629mcpsimp"><a name="p629mcpsimp"></a><a name="p629mcpsimp"></a>Product Version</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.2.1 "><p id="p11388205913278"><a name="p11388205913278"></a><a name="p11388205913278"></a><span id="text1622794474512"><a name="text1622794474512"></a><a name="text1622794474512"></a>26.0.RC1</span></p>
</td>
</tr>
<tr id="row1039215083618"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.3.1"><p id="p297244215265"><a name="p297244215265"></a><a name="p297244215265"></a>Software Name</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.3.1 "><p id="p17634966286"><a name="p17634966286"></a><a name="p17634966286"></a>Kbox cloud phone container</p>
</td>
</tr>
<tr id="row19702204394518"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.4.1"><p id="p6702174394516"><a name="p6702174394516"></a><a name="p6702174394516"></a>Software Package Version</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.4.1 "><p id="p47026438455"><a name="p47026438455"></a><a name="p47026438455"></a>7.3.0_11</p>
</td>
</tr>
</tbody>
</table>

### Software Version Mapping<a name="ZH-CN_TOPIC_0000002518346116"></a>

|Software|Version|Remarks|
|--|--|--|
|Kunpeng BoostKit|Kunpeng BoostKit 26.0.RC1|-|
|OS|openEuler-22.03-LTS-SP4-AArch64 (kernel 5.10.0-216.0.0)|-|
|ExaGear|ExaGear_ARM32-ARM64_V2.5|Transcoding software|

### Hardware Version Mapping<a name="ZH-CN_TOPIC_0000002518346118"></a>

|Server|Processor|BIOS|CPLD|BMC|
|--|--|--|--|--|
|Kunpeng server|Kunpeng 920 processor|6.56|5.09|5.96|
|Kunpeng server|New Kunpeng 920 processor model|20.55|5.08|5.05.12.15|

### Virus Scan Results<a name="ZH-CN_TOPIC_0000002518186200"></a>

The software package and related documents have been scanned by antivirus software and no risks have been found.

|Antivirus Software|Antivirus Software Version|Virus Library Version|Scan Time|Scan Result|
|--|--|--|--|--|
|QiAnXin|8.0.5.5260|2025-12-12 08:00:00.0|2025-12-13 17:54:51|OK|
|Bitdefender|7.5.1.200224|7.99967|2025-12-13 17:55:11|OK|
|Kaspersky|12.0.0.6672|2025-12-13 10:03:00|2025-12-13 17:53:47|OK|

## Important Notes<a name="ZH-CN_TOPIC_0000002549705971"></a>

For details, see the feature guide of the corresponding version, for example, [Feature Guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/en/feature_guide.md).

## V7.3.0_11<a name="ZH-CN_TOPIC_0000002549825973"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186202"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Graphics acceleration layer|Enables the graphics acceleration layer in Kbox and provides steps for enabling related functions.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002549705975"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002549825953"></a>

None

## V7.2.RC1<a name="ZH-CN_TOPIC_0000002549825947"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186192"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Generalization of adaptive frame synchronization| Expands the benefits of adaptive frame synchronization to many applications.|
|2|Support for thread-level shader cache| The shader binary can be pre-built to reduce the first launch time of large OpenGL ES rendering applications by 40% and the frame freezing rate in high-dynamic scenarios by 50%.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002549825967"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002549705951"></a>

None

## V7.1.RC1<a name="ZH-CN_TOPIC_0000002549705955"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186186"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Added the memory overcommitment feature.| If the GPU load is greater than or equal to 90%, enabling the memory overcommitment feature can reduce the RAM usage by 10% when launching an identical number of 720p@30 fps cloud phones.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518346100"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002549825949"></a>

None

## V7.0.RC1<a name="ZH-CN_TOPIC_0000002549705947"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186190"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Android lightweight trimming| Removes unnecessary system services and built-in applications to reduce cloud phone resource usage, thereby improving system performance and optimizing user experience.|
|2|Dynamic frame rate adjustment| Dynamically decreases the frame rate to reduce rendering overhead when the client is disconnected from the cloud phone in the away from keyboard (AFK) scenario. When the client is disconnected from the cloud phone, the frame rate is decreased. When the client is reconnected to the cloud phone, the frame rate is restored to the normal value.|
|3|Resource monitoring| Monitors GPU memory and other memory resources so that ISVs can perform operations based on resource usage.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002549705965"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518186184"></a>

None

## V6.0.0<a name="ZH-CN_TOPIC_0000002518346094"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186198"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Adaptive scalable texture compression (ASTC)| Implements the ASTC function through Vulkan.|
|2|Texture compression| Enables texture compression for cloud phones to reduce the video RAM usage. A switch is provided for toggling this function (enabled by default).|
|3|YCbCr_420_888 format| Implements the YCbCr_420_888 image format for the Kbox Gralloc module.|
|4|Adaptive frame synchronization| Implements the adaptive vertical synchronization (vsync) function. After one frame is rendered, SurfaceFlinger immediately composes the frame and sends it to the screen, reducing the cloud-side latency by 15 ms. In addition, a test report is output based on cloud-side latency measurement.|
|5|Configurable camera simulation data| Supports the configuration of camera simulation data using the `adb` command.|
|6|ART DEX compilation optimization| Accelerates application startup and execution. The CPU and memory usage can also be reduced.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518186182"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518346104"></a>

None

## V6.0.RC2<a name="ZH-CN_TOPIC_0000002549825963"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002549705949"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Android system property customization|Allows users to customize system properties and overwrite original system properties as required.|
|2|Process restart upon unexpected exits|Delivers the process of the binary file. After the process exits abnormally (for example, the process crashes or is forcibly terminated), you can restart the process to resume the functions.|
|3|Document updates|Provides updates related to the server information in the cloud phone documentation.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002549825951"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518346092"></a>

None

## V6.0.RC1<a name="ZH-CN_TOPIC_0000002549705945"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002549705967"></a>

**New Features<a name="section78241436103817"></a>**

None

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518186196"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518346098"></a>

<a name="zh-cn_topic_0000001498002964_table1077520124617"></a>
<table><tbody><tr id="zh-cn_topic_0000001498002964_row07751817464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001498002964_p177751174618"><a name="zh-cn_topic_0000001498002964_p177751174618"></a><a name="zh-cn_topic_0000001498002964_p177751174618"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.1.1 "><p id="p12376102249"><a name="p12376102249"></a><a name="p12376102249"></a>DTS2024031108664</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row157751511464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001498002964_p167751810462"><a name="zh-cn_topic_0000001498002964_p167751810462"></a><a name="zh-cn_topic_0000001498002964_p167751810462"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.2.1 "><p id="p5376142147"><a name="p5376142147"></a><a name="p5376142147"></a>Minor</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row11775191144616"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001498002964_p20775919467"><a name="zh-cn_topic_0000001498002964_p20775919467"></a><a name="zh-cn_topic_0000001498002964_p20775919467"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.3.1 "><p id="p193760213410"><a name="p193760213410"></a><a name="p193760213410"></a>The music playback process remains after KuGou is terminated in the multi-window screen.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row12775151134619"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001498002964_p197756111466"><a name="zh-cn_topic_0000001498002964_p197756111466"></a><a name="zh-cn_topic_0000001498002964_p197756111466"></a>Cause Analysis</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.4.1 "><p id="p133761021544"><a name="p133761021544"></a><a name="p133761021544"></a>The process termination API is not invoked when the app is being terminated in the multi-window screen. It is suspected that the app bypasses process termination through some detection.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1677518118466"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001498002964_p97756164616"><a name="zh-cn_topic_0000001498002964_p97756164616"></a><a name="zh-cn_topic_0000001498002964_p97756164616"></a>Impact Assessment</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.5.1 "><p id="p53778219413"><a name="p53778219413"></a><a name="p53778219413"></a>The process cannot be terminated in the multi-window screen, but can be terminated in the notification panel or app info screen.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1177581134617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001498002964_p677517114617"><a name="zh-cn_topic_0000001498002964_p677517114617"></a><a name="zh-cn_topic_0000001498002964_p677517114617"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.6.1 "><p id="p53771212415"><a name="p53771212415"></a><a name="p53771212415"></a>Terminate the app in the notification panel or forcibly stop the app in the app info screen.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1777511154617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001498002964_p87762154616"><a name="zh-cn_topic_0000001498002964_p87762154616"></a><a name="zh-cn_topic_0000001498002964_p87762154616"></a>Progress</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.7.1 "><p id="p83771424412"><a name="p83771424412"></a><a name="p83771424412"></a>The issue is being located.</p>
</td>
</tr>
</tbody>
</table>

## V5.0.0<a name="ZH-CN_TOPIC_0000002549825969"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518186176"></a>

**New Features<a name="section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Custom patch modification for the Kbox kernel|Provides custom ashmem and binder patch modification for Kbox kernel 5.15 to reduce kernel customization and reuse kernel capabilities.|
|2|Network emulation modification for Kbox|Provides the emulation of Kbox network functions. With the IP address, gateway, subnet mask, and DNS information, it can enable the cloud phone to access the network.|
|3|Telephony emulation modification for Kbox|Implements the emulation of the IMEI, IMSI, network operator information, and SIM card based on Trable modification for Kbox telephony simulation.|
|4|Audio simulation function for Kbox|Previously, Kbox lacked audio emulation support, which could lead to compatibility issues when running audio-dependent applications. Therefore, the audio emulation function needs to be added to Kbox. Constraints: Only audio output emulation is supported. Input emulation is not supported.|

**Modified Features<a name="section540mcpsimp"></a>**

None

**Removed Features<a name="section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002549825957"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518186180"></a>

None

## V5.0.RC2<a name="ZH-CN_TOPIC_0000002518186178"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002518346102"></a>

**New Features<a name="zh-cn_topic_0000001549282537_section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Hardware acceleration for video playback on cloud phones based on codec cards|Implements H.264/H.265 decoding hardware acceleration for video playback on cloud phones based on the NETINT T432 hardware codec card and OMX media framework adaptation.|
|2|Query and display of the Kbox component version|Supports the query and standard display of the Kbox component version.|
|3|Upgrade for adaptation to the kernel of a later version|Modifies the kernel patch related to the Kbox basic cloud phone to adapt to kernel 5.15.|
|4|Adapts the Kbox basic cloud phone to Mesa 22.1.7.|Adapts the Kbox basic cloud phone to Mesa 22.1.7.|
|5|Update of the video stream and Kbox documentations|Updates descriptions of Mesa, kernel, and GPU in the video stream and Kbox documentations.|
|6|Supports detection and rectification of Android system running exceptions.|Checks key processes and services such as SurfaceFlinger, SystemServer, and Zygote of the cloud phone and restores the processes and services if an exception occurs.|
|7|Supports the conversion from Vulkan RGB and RGBA textures to DXT textures.|Implements the conversion from Vulkan RGB/RGBA textures to the DXT textures based on the Mesa open-source software.|
|8|Stack protection and anti-exploitation|Implements stack protection and anti-exploitation.|

**Modified Features<a name="zh-cn_topic_0000001549282537_section540mcpsimp"></a>**

None

**Removed Features<a name="zh-cn_topic_0000001549282537_section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518346106"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518186194"></a>

<a name="zh-cn_topic_0000001498002964_table1077520124617"></a>
<table><tbody><tr id="zh-cn_topic_0000001498002964_row07751817464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001498002964_p177751174618"><a name="zh-cn_topic_0000001498002964_p177751174618"></a><a name="zh-cn_topic_0000001498002964_p177751174618"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001498002964_p377511134615"><a name="zh-cn_topic_0000001498002964_p377511134615"></a><a name="zh-cn_topic_0000001498002964_p377511134615"></a>DTS2023051802653</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row157751511464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001498002964_p167751810462"><a name="zh-cn_topic_0000001498002964_p167751810462"></a><a name="zh-cn_topic_0000001498002964_p167751810462"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001498002964_p87750114611"><a name="zh-cn_topic_0000001498002964_p87750114611"></a><a name="zh-cn_topic_0000001498002964_p87750114611"></a>Minor</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row11775191144616"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001498002964_p20775919467"><a name="zh-cn_topic_0000001498002964_p20775919467"></a><a name="zh-cn_topic_0000001498002964_p20775919467"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001498002964_p1987484454610"><a name="zh-cn_topic_0000001498002964_p1987484454610"></a><a name="zh-cn_topic_0000001498002964_p1987484454610"></a>After the BIOS is upgraded to 6.56 and the server is restarted, the encoding card chip intermittently fails to be detected.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row12775151134619"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001498002964_p197756111466"><a name="zh-cn_topic_0000001498002964_p197756111466"></a><a name="zh-cn_topic_0000001498002964_p197756111466"></a>Cause Analysis</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001498002964_p37759110469"><a name="zh-cn_topic_0000001498002964_p37759110469"></a><a name="zh-cn_topic_0000001498002964_p37759110469"></a>Following a server reboot, the encoding card chip occasionally fails to be detected. This low-probability issue can be resolved by a subsequent reboot, but it impacts normal customer operations.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1677518118466"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001498002964_p97756164616"><a name="zh-cn_topic_0000001498002964_p97756164616"></a><a name="zh-cn_topic_0000001498002964_p97756164616"></a>Impact Assessment</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.5.1 "><p id="zh-cn_topic_0000001498002964_p19775813469"><a name="zh-cn_topic_0000001498002964_p19775813469"></a><a name="zh-cn_topic_0000001498002964_p19775813469"></a>If the T432 encoding card is used, cloud phone density is affected when this problem occurs.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1177581134617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001498002964_p677517114617"><a name="zh-cn_topic_0000001498002964_p677517114617"></a><a name="zh-cn_topic_0000001498002964_p677517114617"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.6.1 "><a name="zh-cn_topic_0000001498002964_ol88617589303"></a><a name="zh-cn_topic_0000001498002964_ol88617589303"></a><ol id="zh-cn_topic_0000001498002964_ol88617589303"><li>Use the iBMC to set the server fan modules to the high-performance mode. </li><li>Occasional identification failure: The fault can be rectified by a cold reboot. </li><li>Damaged connector pins: Contact the manufacturer for a card replacement.</li></ol>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1777511154617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001498002964_p87762154616"><a name="zh-cn_topic_0000001498002964_p87762154616"></a><a name="zh-cn_topic_0000001498002964_p87762154616"></a>Progress</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.7.1 "><a name="zh-cn_topic_0000001498002964_ol7508324455"></a><a name="zh-cn_topic_0000001498002964_ol7508324455"></a><ol id="zh-cn_topic_0000001498002964_ol7508324455"><li>The T432 encoding card is outside Huawei's sales scope. We will add a restriction notice regarding the missing T432 chip and include workaround instructions in the official documentation to alert customers. </li><li> This issue will remain open while we track the manufacturer's final root cause investigation.</li></ol>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001498002964_table82294384613"></a>
<table><tbody><tr id="zh-cn_topic_0000001498002964_row22292034467"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001498002964_p132293318462"><a name="zh-cn_topic_0000001498002964_p132293318462"></a><a name="zh-cn_topic_0000001498002964_p132293318462"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001498002964_p7230438463"><a name="zh-cn_topic_0000001498002964_p7230438463"></a><a name="zh-cn_topic_0000001498002964_p7230438463"></a>DTS2023051004239</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row92301316468"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001498002964_p1523053184614"><a name="zh-cn_topic_0000001498002964_p1523053184614"></a><a name="zh-cn_topic_0000001498002964_p1523053184614"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001498002964_p202309318461"><a name="zh-cn_topic_0000001498002964_p202309318461"></a><a name="zh-cn_topic_0000001498002964_p202309318461"></a>Minor</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row8230173164616"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001498002964_p6230163184615"><a name="zh-cn_topic_0000001498002964_p6230163184615"></a><a name="zh-cn_topic_0000001498002964_p6230163184615"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001498002964_p202301232462"><a name="zh-cn_topic_0000001498002964_p202301232462"></a><a name="zh-cn_topic_0000001498002964_p202301232462"></a>When using XPlayer for hardware video decoding, the system occasionally falls back to its own software decoding. This prevents stable utilization of Kbox's hardware decoding capabilities, indicating a compatibility issue between Kbox and XPlayer.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row623015313469"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001498002964_p1823083134620"><a name="zh-cn_topic_0000001498002964_p1823083134620"></a><a name="zh-cn_topic_0000001498002964_p1823083134620"></a>Cause Analysis</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001498002964_p182301233464"><a name="zh-cn_topic_0000001498002964_p182301233464"></a><a name="zh-cn_topic_0000001498002964_p182301233464"></a>NETINT destruction or initialization occasionally responds slowly. As a result, XPlayer detects that the hardware decoding capability is insufficient, and software decoding is used instead.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row14230934466"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001498002964_p17230037467"><a name="zh-cn_topic_0000001498002964_p17230037467"></a><a name="zh-cn_topic_0000001498002964_p17230037467"></a>Impact Assessment</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.5.1 "><p id="zh-cn_topic_0000001498002964_p20230143154618"><a name="zh-cn_topic_0000001498002964_p20230143154618"></a><a name="zh-cn_topic_0000001498002964_p20230143154618"></a>Low-probability container fallback from hardware to software decoding; no impact on actual video playback.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row223043134614"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001498002964_p13230123114613"><a name="zh-cn_topic_0000001498002964_p13230123114613"></a><a name="zh-cn_topic_0000001498002964_p13230123114613"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.6.1 "><p id="zh-cn_topic_0000001498002964_p72304313464"><a name="zh-cn_topic_0000001498002964_p72304313464"></a><a name="zh-cn_topic_0000001498002964_p72304313464"></a>XPlayer enforces strict response time limits on hardware decoding interfaces. Since falling back to software decoding does not disrupt video playback, no immediate workaround is required.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row6230433467"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001498002964_p18230103194612"><a name="zh-cn_topic_0000001498002964_p18230103194612"></a><a name="zh-cn_topic_0000001498002964_p18230103194612"></a>Progress</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.7.1 "><p id="zh-cn_topic_0000001498002964_p72301337464"><a name="zh-cn_topic_0000001498002964_p72301337464"></a><a name="zh-cn_topic_0000001498002964_p72301337464"></a>Continue joint investigation with NETINT to locate and resolve the slow response issue.</p>
</td>
</tr>
</tbody>
</table>

## V5.0.RC3<a name="ZH-CN_TOPIC_0000002518186188"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002549825959"></a>

**New Features<a name="zh-cn_topic_0000001473962058_section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|ExaGear+openEuler 22.03 LTS transcoding| Adapts Kbox to openEuler 22.03 LTS by running ExaGear.|
|2|Kbox adaptation based on openEuler 22.03 LTS| Enhances the OS compatibility.|

**Modified Features<a name="zh-cn_topic_0000001473962058_section540mcpsimp"></a>**

None

**Removed Features<a name="zh-cn_topic_0000001473962058_section543mcpsimp"></a>**

Deleted Android 9-related content because this version does not support Android 9.

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518346112"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002549705963"></a>

<a name="zh-cn_topic_0000001473642402_table1170965710134"></a>
<table><tbody><tr id="zh-cn_topic_0000001473642402_row8709457201314"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001473642402_p5709557171320"><a name="zh-cn_topic_0000001473642402_p5709557171320"></a><a name="zh-cn_topic_0000001473642402_p5709557171320"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001473642402_p127092057121318"><a name="zh-cn_topic_0000001473642402_p127092057121318"></a><a name="zh-cn_topic_0000001473642402_p127092057121318"></a>DTS2023022301216</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row1870915712137"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001473642402_p18526151631413"><a name="zh-cn_topic_0000001473642402_p18526151631413"></a><a name="zh-cn_topic_0000001473642402_p18526151631413"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001473642402_p1170917579131"><a name="zh-cn_topic_0000001473642402_p1170917579131"></a><a name="zh-cn_topic_0000001473642402_p1170917579131"></a>Notice</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row11709125791311"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001473642402_p23481921101416"><a name="zh-cn_topic_0000001473642402_p23481921101416"></a><a name="zh-cn_topic_0000001473642402_p23481921101416"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001473642402_p1709105716136"><a name="zh-cn_topic_0000001473642402_p1709105716136"></a><a name="zh-cn_topic_0000001473642402_p1709105716136"></a>When installing and opening the game on Kbox Basic Cloud Phone, attempting to log in with an account that has no registered characters triggers a "Device Data Anomaly" error, preventing the creation of a new character.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row1670912572131"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001473642402_p15709657161312"><a name="zh-cn_topic_0000001473642402_p15709657161312"></a><a name="zh-cn_topic_0000001473642402_p15709657161312"></a>Cause Analysis</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001473642402_p27661527174117"><a name="zh-cn_topic_0000001473642402_p27661527174117"></a><a name="zh-cn_topic_0000001473642402_p27661527174117"></a>The exact root cause is still under investigation. Two potential angles are currently being explored:</p>
<a name="zh-cn_topic_0000001473642402_ol2224634194113"></a><a name="zh-cn_topic_0000001473642402_ol2224634194113"></a><ol id="zh-cn_topic_0000001473642402_ol2224634194113"><li>Incomplete device emulation: Kbox device emulation is not yet fully optimized and may lack specific data required by the game. This will need to be evaluated in future Kbox evolution strategies. </li><li>The game may have detected that Kbox is a virtual environment rather than a physical device, thereby triggering its anti-cheat mechanism.</li></ol>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row7709757101310"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001473642402_p7709205711310"><a name="zh-cn_topic_0000001473642402_p7709205711310"></a><a name="zh-cn_topic_0000001473642402_p7709205711310"></a>Impact Assessment</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.5.1 "><p id="zh-cn_topic_0000001473642402_p5709957101312"><a name="zh-cn_topic_0000001473642402_p5709957101312"></a><a name="zh-cn_topic_0000001473642402_p5709957101312"></a>Mitigation measures are available, and the impact is small. Sky: Children of the Light is not currently on the official compatibility list; the primary testing objective was to verify ETC2 texture support, which has been successfully validated. Furthermore, logging in with an existing character account works as expected.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row8709257141319"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001473642402_p1270925719137"><a name="zh-cn_topic_0000001473642402_p1270925719137"></a><a name="zh-cn_topic_0000001473642402_p1270925719137"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.6.1 "><p id="zh-cn_topic_0000001473642402_p6709175721310"><a name="zh-cn_topic_0000001473642402_p6709175721310"></a><a name="zh-cn_topic_0000001473642402_p6709175721310"></a>Logging in with an existing character account works as expected.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row14709857101313"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001473642402_p968328140"><a name="zh-cn_topic_0000001473642402_p968328140"></a><a name="zh-cn_topic_0000001473642402_p968328140"></a>Progress</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.7.1 "><p id="zh-cn_topic_0000001473642402_p117104572137"><a name="zh-cn_topic_0000001473642402_p117104572137"></a><a name="zh-cn_topic_0000001473642402_p117104572137"></a>This issue will remain open. A final decision on whether to close it will be evaluated after a thorough baseline assessment of device emulation capabilities.</p>
</td>
</tr>
</tbody>
</table>

## V3.0.0<a name="ZH-CN_TOPIC_0000002549705969"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002549705959"></a>

**New Features<a name="zh-cn_topic_0000001468009680_section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Adapted cloud phones for more GPUs.| Enhanced hardware compatibility.|
|2|Added basic cloud phone documentation.| Provides guidance for users to use the Kbox cloud phone container.|
|3|Adapted Kbox Android 11 cloud phones for more servers.| Supports new hardware platforms.|

**Modified Features<a name="zh-cn_topic_0000001468009680_section540mcpsimp"></a>**

None

**Removed Features<a name="zh-cn_topic_0000001468009680_section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518346108"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002518346110"></a>

None

## V2.0.0<a name="ZH-CN_TOPIC_0000002518346096"></a>

### Change Description<a name="ZH-CN_TOPIC_0000002549825965"></a>

This release inherits all features available from release 2.0.RC1 to release 2.0.RC2.

**New Features<a name="zh-cn_topic_0000001420053428_section78241436103817"></a>**

|No.|Description|Purpose|
|--|--|--|
|1|Trustworthiness enhancement during the use of open-source software and Docker containers|Remediates open-source software and Docker container usage during development to meet trustworthiness and compliance requirements.|

**Modified Features<a name="zh-cn_topic_0000001420053428_section540mcpsimp"></a>**

None

**Removed Features<a name="zh-cn_topic_0000001420053428_section543mcpsimp"></a>**

None

### Resolved Issues<a name="ZH-CN_TOPIC_0000002518346090"></a>

None

### Known Issues<a name="ZH-CN_TOPIC_0000002549705961"></a>

<a name="zh-cn_topic_0000001420053432_table41842027194519"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row2236202774512"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p123692754520"><a name="zh-cn_topic_0000001420053432_p123692754520"></a><a name="zh-cn_topic_0000001420053432_p123692754520"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p323612273450"><a name="zh-cn_topic_0000001420053432_p323612273450"></a><a name="zh-cn_topic_0000001420053432_p323612273450"></a>DTS202105190IPKB9P1300</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row1823632717450"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p172361627124515"><a name="zh-cn_topic_0000001420053432_p172361627124515"></a><a name="zh-cn_topic_0000001420053432_p172361627124515"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p1236102794512"><a name="zh-cn_topic_0000001420053432_p1236102794512"></a><a name="zh-cn_topic_0000001420053432_p1236102794512"></a>Condition: The CTS test suite is used in the CI daily build scenario.</p>
<p id="zh-cn_topic_0000001420053432_p1323602794510"><a name="zh-cn_topic_0000001420053432_p1323602794510"></a><a name="zh-cn_topic_0000001420053432_p1323602794510"></a>Symptom: Test cases in some modules of the test suite failed to pass corresponding tests in a container. After another container was used, the test cases passed the corresponding tests.</p>
<p id="zh-cn_topic_0000001420053432_p7236142794516"><a name="zh-cn_topic_0000001420053432_p7236142794516"></a><a name="zh-cn_topic_0000001420053432_p7236142794516"></a>Root cause: In this trouble ticket, the failed test case in <code>296 CtsUiAutomationTestCases</code> is not a baseline test case but an additional test case. The test case will be further analyzed in the CTS special work.</p>
<p id="zh-cn_topic_0000001420053432_p11236182754512"><a name="zh-cn_topic_0000001420053432_p11236182754512"></a><a name="zh-cn_topic_0000001420053432_p11236182754512"></a>The failed test case in <code>26 CtsAssistTestCases</code> is caused by the test case itself, whose Google bug ID is 30859355. This issue may be eligible for an exemption.</p>
<p id="zh-cn_topic_0000001420053432_p823612794512"><a name="zh-cn_topic_0000001420053432_p823612794512"></a><a name="zh-cn_topic_0000001420053432_p823612794512"></a>Two failed test cases in <code>69 CtsGraphicsTestCases</code> are related to Vulkan enablement. After the two test cases that do not support the extended properties and image format are masked according to the last CCB decision, this module can pass the test.</p>
<p id="zh-cn_topic_0000001420053432_p1723672744511"><a name="zh-cn_topic_0000001420053432_p1723672744511"></a><a name="zh-cn_topic_0000001420053432_p1723672744511"></a>From July 2 to September 3, CI CTS daily build was performed for 28 times, among which <code>CtsWidgetTestCases</code> failed for 4 times, <code>CtsJvmtiRunTest993HostTestCases</code> and <code>CtsAtraceHostTestCases</code> each failed once, and <code>CtsAccessibilityTestCases</code> did not fail. The general failure rate is low. Increasing the number of retries can improve the pass rate of the preceding modules.</p>
<p id="zh-cn_topic_0000001420053432_p10236172711455"><a name="zh-cn_topic_0000001420053432_p10236172711455"></a><a name="zh-cn_topic_0000001420053432_p10236172711455"></a>Impact: The issues in this trouble ticket occurred occasionally. The module with the highest failure rate failed four times in 28 times of CI daily build, and other modules failed once or did not fail. This affected the CTS pass rate in the CI environment.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row22361727144513"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p023672734513"><a name="zh-cn_topic_0000001420053432_p023672734513"></a><a name="zh-cn_topic_0000001420053432_p023672734513"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p523672754510"><a name="zh-cn_topic_0000001420053432_p523672754510"></a><a name="zh-cn_topic_0000001420053432_p523672754510"></a>Minor</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row18236132774513"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p14236132710456"><a name="zh-cn_topic_0000001420053432_p14236132710456"></a><a name="zh-cn_topic_0000001420053432_p14236132710456"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p1428148141616"><a name="zh-cn_topic_0000001420053432_p1428148141616"></a><a name="zh-cn_topic_0000001420053432_p1428148141616"></a>Workaround: Increase the number of retries for failed test cases.</p>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001420053432_table164784818466"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row1766915482465"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p1166914481464"><a name="zh-cn_topic_0000001420053432_p1166914481464"></a><a name="zh-cn_topic_0000001420053432_p1166914481464"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p136691548154615"><a name="zh-cn_topic_0000001420053432_p136691548154615"></a><a name="zh-cn_topic_0000001420053432_p136691548154615"></a>Blue zone issue 15</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row266924810467"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p266924854619"><a name="zh-cn_topic_0000001420053432_p266924854619"></a><a name="zh-cn_topic_0000001420053432_p266924854619"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p966904815460"><a name="zh-cn_topic_0000001420053432_p966904815460"></a><a name="zh-cn_topic_0000001420053432_p966904815460"></a>Condition: The video stream cloud phone is used to test Cocos.</p>
<p id="zh-cn_topic_0000001420053432_p126694481469"><a name="zh-cn_topic_0000001420053432_p126694481469"></a><a name="zh-cn_topic_0000001420053432_p126694481469"></a>Symptom: When playing a game in landscape mode, touch and hold the notification bar and click the home button on the server side. As a result, the notification bar is forcibly pulled out.</p>
<p id="zh-cn_topic_0000001420053432_p142981337141712"><a name="zh-cn_topic_0000001420053432_p142981337141712"></a><a name="zh-cn_topic_0000001420053432_p142981337141712"></a><span>Root cause: </span>This requires that the drop-down notification bar be masked. However, this is not implemented in the complex operation scenario described in the symptom part. As a result, the drop-down notification bar can still be displayed. The masking solution in this scenario is still under discussion and is not modified before this release.</p>
<p id="zh-cn_topic_0000001420053432_p136691448134610"><a name="zh-cn_topic_0000001420053432_p136691448134610"></a><a name="zh-cn_topic_0000001420053432_p136691448134610"></a>Impact: The trigger condition is highly specific and rare. Generally, a user is unlikely to press and hold the notification bar with the left hand while simultaneously pressing and holding the home button with the right hand. In addition, this problem strictly occurs during landscape-to-portrait orientation switches. Even if the notification bar appears, it does not disrupt normal functionality. Therefore, the practical impact is negligible.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row16691448204616"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p866934894617"><a name="zh-cn_topic_0000001420053432_p866934894617"></a><a name="zh-cn_topic_0000001420053432_p866934894617"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p1266917482462"><a name="zh-cn_topic_0000001420053432_p1266917482462"></a><a name="zh-cn_topic_0000001420053432_p1266917482462"></a>Blue zone</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row466974815461"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p18669048134614"><a name="zh-cn_topic_0000001420053432_p18669048134614"></a><a name="zh-cn_topic_0000001420053432_p18669048134614"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p106691048184618"><a name="zh-cn_topic_0000001420053432_p106691048184618"></a><a name="zh-cn_topic_0000001420053432_p106691048184618"></a>No workaround required; rarely triggered under normal usage conditions.</p>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001420053432_table85082284479"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row115371528134717"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p953792815479"><a name="zh-cn_topic_0000001420053432_p953792815479"></a><a name="zh-cn_topic_0000001420053432_p953792815479"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p553715286471"><a name="zh-cn_topic_0000001420053432_p553715286471"></a><a name="zh-cn_topic_0000001420053432_p553715286471"></a>DTS202107210KJTJ7P1400</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row205371728164714"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p19537192894712"><a name="zh-cn_topic_0000001420053432_p19537192894712"></a><a name="zh-cn_topic_0000001420053432_p19537192894712"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p353772874720"><a name="zh-cn_topic_0000001420053432_p353772874720"></a><a name="zh-cn_topic_0000001420053432_p353772874720"></a>Condition: Video streaming cloud phone testing with Cocos during CI daily builds.</p>
<p id="zh-cn_topic_0000001420053432_p1353772818475"><a name="zh-cn_topic_0000001420053432_p1353772818475"></a><a name="zh-cn_topic_0000001420053432_p1353772818475"></a>After running Cocos test cases in the CI video streaming daily build, the server-side cloud phone main interface displays screen artifacts.</p>
<p id="zh-cn_topic_0000001420053432_p2537202817476"><a name="zh-cn_topic_0000001420053432_p2537202817476"></a><a name="zh-cn_topic_0000001420053432_p2537202817476"></a>Root Cause Analysis: CI log analysis indicates that while Cocos test cases are running, an out-of-bounds memory access occurred within Mesa's <code>gallium_dri.so</code>, leading to a Mesa crash. The call stack points to the <code>eglSwapBuffersWithDamageKHR</code> interface in the Mesa library. The visible symptom is screen artifacts. Initial findings suggest the issue is related to the third-party Mesa driver component, and further deep-dive analysis is required to pin down the exact root cause.</p>
<p id="zh-cn_topic_0000001420053432_p12538428184718"><a name="zh-cn_topic_0000001420053432_p12538428184718"></a><a name="zh-cn_topic_0000001420053432_p12538428184718"></a>Impact:</p>
<a name="ol16754121113013"></a><a name="ol16754121113013"></a><ol id="ol16754121113013"><li>There is a low probability that this problem occurs. This problem occurred twice on the video stream daily build server (on July 20 and September 4, with a gap of more than one month). In subsequent 6,000 dedicated tests, this problem did not recur. </li><li>Only the cloud phone that runs the test case is affected. Other cloud phones started on the server are not affected.</li></ol>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row75381285471"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p17538728144719"><a name="zh-cn_topic_0000001420053432_p17538728144719"></a><a name="zh-cn_topic_0000001420053432_p17538728144719"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p2538102816477"><a name="zh-cn_topic_0000001420053432_p2538102816477"></a><a name="zh-cn_topic_0000001420053432_p2538102816477"></a>Minor</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row12538202816473"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p1753812824714"><a name="zh-cn_topic_0000001420053432_p1753812824714"></a><a name="zh-cn_topic_0000001420053432_p1753812824714"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p961105117193"><a name="zh-cn_topic_0000001420053432_p961105117193"></a><a name="zh-cn_topic_0000001420053432_p961105117193"></a>Restart the cloud phone.</p>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001420053432_table919416369514"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row16268203685118"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p192681636145116"><a name="zh-cn_topic_0000001420053432_p192681636145116"></a><a name="zh-cn_topic_0000001420053432_p192681636145116"></a>Trouble Ticket No.</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p10268133611512"><a name="zh-cn_topic_0000001420053432_p10268133611512"></a><a name="zh-cn_topic_0000001420053432_p10268133611512"></a>DTS2021090912581</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row172689368517"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p926833695111"><a name="zh-cn_topic_0000001420053432_p926833695111"></a><a name="zh-cn_topic_0000001420053432_p926833695111"></a>Symptom</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p16268173665114"><a name="zh-cn_topic_0000001420053432_p16268173665114"></a><a name="zh-cn_topic_0000001420053432_p16268173665114"></a>Condition: Upgrade the server firmware (BIOS 177, CPLD 5.14, and iBMC 3.01.12.23).</p>
<p id="zh-cn_topic_0000001420053432_p1526873685116"><a name="zh-cn_topic_0000001420053432_p1526873685116"></a><a name="zh-cn_topic_0000001420053432_p1526873685116"></a>Symptom: The server (model 5220) uses a new motherboard to upgrade BIOS 177, CPLD 5.14, and iBMC 3.01.12.23, but the upgrade fails, and the server hangs. <span>Currently, no official new versions are available for the new motherboard</span>.</p>
<p id="zh-cn_topic_0000001420053432_p148522050143713"><a name="zh-cn_topic_0000001420053432_p148522050143713"></a><a name="zh-cn_topic_0000001420053432_p148522050143713"></a><span>root cause: Model 5220 has two versions corresponding to the old and new motherboards. The link to the BIOS version matching the old motherboard at the Support website is invalid. In this test, the new motherboard is used. According to the Kunpeng computing hardware developers of the 5220 motherboard, the BIOS version matching the new 5220 motherboard has not been released. If the latest BIOS version on the Support website is used, the upgrade fails. To solve this problem, the BIOS team needs to release the BIOS version matching the new motherboard to the Support website.</span></p>
<p id="zh-cn_topic_0000001420053432_p52681436185115"><a name="zh-cn_topic_0000001420053432_p52681436185115"></a><a name="zh-cn_topic_0000001420053432_p52681436185115"></a>Impact: If a customer uses the new motherboard, the customer cannot obtain the matching BIOS version from the Support website.</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row19268193605118"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p826823611513"><a name="zh-cn_topic_0000001420053432_p826823611513"></a><a name="zh-cn_topic_0000001420053432_p826823611513"></a>Severity</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p42684364512"><a name="zh-cn_topic_0000001420053432_p42684364512"></a><a name="zh-cn_topic_0000001420053432_p42684364512"></a>Minor</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row13268163620519"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p02681236205117"><a name="zh-cn_topic_0000001420053432_p02681236205117"></a><a name="zh-cn_topic_0000001420053432_p02681236205117"></a>Workaround</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p856694613200"><a name="zh-cn_topic_0000001420053432_p856694613200"></a><a name="zh-cn_topic_0000001420053432_p856694613200"></a>None</p>
</td>
</tr>
</tbody>
</table>

## Documentation<a name="ZH-CN_TOPIC_0000002549825961"></a>

### V7.3.0_11 Documentation<a name="ZH-CN_TOPIC_0000002549825955"></a>

|No.|Document|Description|How to Obtain|
|--|--|--|--|
|1|best practices| Describes the best practices of the Kbox cloud phone container.|[best practices](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/best_practices.md)|
|2|compile guide| Explains how to compile the Kbox cloud phone container.|[compile guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/compile_guide.md)|
|3|feature guide| Describes the features of the Kbox cloud phone container.|[feature guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/feature_guide.md)|
|4|install guide| Explains how to install the Kbox cloud phone container.|[install guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/install_guide.md)|
|5|release notes| Describes version information about the Kbox cloud phone container.|[release notes](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/release_notes.md)|
|6|test guide| Explains how to test the Kbox cloud phone container.|[test guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/test_guide.md)|
|7|troubleshooting| Describes the troubleshooting cases of the Kbox cloud phone container.|[troubleshooting](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/troubleshooting.md)|
|8|user guide| This document describes how to use the Kbox cloud phone container.|[user guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/user_guide.md)|
|9|routine maintenance| Describes the maintenance methods and tools for the Kbox cloud phone container.|[routine maintenance](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/%E4%BE%8B%E8%A1%8C%E7%BB%B4%E6%8A%A4.md)|

### Obtaining Documentation<a name="ZH-CN_TOPIC_0000002549705957"></a>

View or download required documents from [menu](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/en/menu.md).
