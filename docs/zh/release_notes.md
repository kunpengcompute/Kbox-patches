# 版本说明书<a name="ZH-CN_TOPIC_0000002521624118"></a>

## 版本配套说明<a name="ZH-CN_TOPIC_0000002549825975"></a>

### 产品版本信息<a name="ZH-CN_TOPIC_0000002549705973"></a>

<a name="table617mcpsimp"></a>
<table><tbody><tr id="row622mcpsimp"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.1.1"><p id="p624mcpsimp"><a name="p624mcpsimp"></a><a name="p624mcpsimp"></a>产品名称</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.1.1 "><p id="p109881314494"><a name="p109881314494"></a><a name="p109881314494"></a>Kunpeng BoostKit</p>
</td>
</tr>
<tr id="row627mcpsimp"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.2.1"><p id="p629mcpsimp"><a name="p629mcpsimp"></a><a name="p629mcpsimp"></a>产品版本</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.2.1 "><p id="p11388205913278"><a name="p11388205913278"></a><a name="p11388205913278"></a><span id="text1622794474512"><a name="text1622794474512"></a><a name="text1622794474512"></a>26.0.RC1</span></p>
</td>
</tr>
<tr id="row1039215083618"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.3.1"><p id="p297244215265"><a name="p297244215265"></a><a name="p297244215265"></a>软件名称</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.3.1 "><p id="p17634966286"><a name="p17634966286"></a><a name="p17634966286"></a>Kbox云手机容器</p>
</td>
</tr>
<tr id="row19702204394518"><th class="firstcol" valign="top" width="14.000000000000002%" id="mcps1.1.3.4.1"><p id="p6702174394516"><a name="p6702174394516"></a><a name="p6702174394516"></a>软件包版本</p>
</th>
<td class="cellrowborder" valign="top" width="86%" headers="mcps1.1.3.4.1 "><p id="p47026438455"><a name="p47026438455"></a><a name="p47026438455"></a>7.3.0_11</p>
</td>
</tr>
</tbody>
</table>

### 软件版本配套说明<a name="ZH-CN_TOPIC_0000002518346116"></a>

|软件类型|版本|备注|
|--|--|--|
|Kunpeng BoostKit|Kunpeng BoostKit 26.0.RC1|-|
|OS|openEuler-22.03-LTS-SP4-aarch64 （内核5.10.0-216.0.0）|-|
|ExaGear|ExaGear_ARM32-ARM64_V2.5|转码软件|

### 硬件版本配套说明<a name="ZH-CN_TOPIC_0000002518346118"></a>

|服务器类型|处理器型号|BIOS版本|CPLD版本|BMC版本|
|--|--|--|--|--|
|鲲鹏服务器|鲲鹏920 7260处理器|6.56|5.09|5.96|
|鲲鹏服务器|鲲鹏920 7280Z处理器|20.55|5.08|5.05.12.15|

### 病毒扫描结果<a name="ZH-CN_TOPIC_0000002518186200"></a>

本软件包及相关文档经过防病毒软件扫描，没有发现病毒。

|防病毒软件名称|防病毒软件版本|病毒库版本|扫描时间|扫描结果|
|--|--|--|--|--|
|QiAnXin|8.0.5.5260|2025-12-12 08:00:00.0|2025-12-13 17:54:51|OK|
|Bitdefender|7.5.1.200224|7.99967|2025-12-13 17:55:11|OK|
|Kaspersky|12.0.0.6672|2025-12-13 10:03:00|2025-12-13 17:53:47|OK|

## 版本使用注意事项<a name="ZH-CN_TOPIC_0000002549705971"></a>

请参考相应版本的特性指南，例如《[feature guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/feature_guide.md)》。

## V7.3.0_11<a name="ZH-CN_TOPIC_0000002549825973"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186202"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|支持使能图形加速层| Kbox支持使能图形加速层，并提供相关功能使能步骤 |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002549705975"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002549825953"></a>

无

## V7.2.RC1<a name="ZH-CN_TOPIC_0000002549825947"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186192"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|自适应帧同步特性优化效果泛化| 自适应帧同步特性效果泛化到大部分应用 |
|2|支持线程级Shader Cache| 通过预构建着色器二进制，大型OpenGL ES渲染应用首次启动时间减少40%，高动态场景下运行卡顿率降低50% |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002549825967"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002549705951"></a>

无

## V7.1.RC1<a name="ZH-CN_TOPIC_0000002549705955"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186186"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|新增内存超分特性| 在满足GPU负载大于或等于90%，启动相同路数720P@30fps规格云手机，使用内存超分特性后相比使用前运行内存占用降低10% |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518346100"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002549825949"></a>

无

## V7.0.RC1<a name="ZH-CN_TOPIC_0000002549705947"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186190"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|Android轻量化裁剪| Android系统的轻量化裁剪通过去除不必要的系统服务和内置应用来降低云手机的资源占用，从而提升系统性能、优化用户体验 |
|2|支持动态帧率调整| 在挂机场景下，云手机与客户端断开连接时，动态向下调整帧率以减少渲染性能开销。检测到云手机客户端断连，动态向下调整帧率。检测到云手机客户端连接，恢复到正常帧率 |
|3|提供GPU显存、内存等资源监测能力| 提供实时的GPU显存和内存资源监测能力，便于ISV根据资源的使用情况进行相应的处理 |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002549705965"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518186184"></a>

无

## V6.0.0<a name="ZH-CN_TOPIC_0000002518346094"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186198"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|Vulkan支持的ASTC纹理| 实现Vulkan使用ASTC（Adaptive Scalable Texture Compression）自适应可缩放纹理压缩功能 |
|2|支持纹理压缩| 云手机支持纹理压缩，以降低显存占用。并提供开关支持纹理压缩功能可配置，默认启用纹理压缩 |
|3|Gralloc模块支持YCbCr_420_888格式| 在Kbox Gralloc模块中，增加YCbCr_420_888图像格式的实现 |
|4|支持自适应帧同步| 实现自适应vsync功能，在应用渲染完成一帧后，Surfaceflinger立即合成上屏，降低云侧时延15ms，并通过云侧时延度量，输出测试报告 |
|5|支持摄像头仿真数据配置| 支持通过**adb**命令配置摄像头仿真数据 |
|6|ART DEX编译优化| 通过优化DEX编译过程，减少应用启动时间。优化后的DEX编译提升应用在运行时的执行效率。在优化编译的同时，减少CPU和内存的消耗 |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518186182"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518346104"></a>

无

## V6.0.RC2<a name="ZH-CN_TOPIC_0000002549825963"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002549705949"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|支持Android系统属性可定制|支持根据客户需求定制系统属性，以覆盖原有系统属性|
|2|支持进程异常退出后进程重启恢复正常| 交付二进制所属进程，支持崩溃、被强制终止等异常退出后，进程重启功能可恢复正常 |
|3|提供相关资料文档| 更新云手机相关资料中的服务器相关信息 |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002549825951"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518346092"></a>

无

## V6.0.RC1<a name="ZH-CN_TOPIC_0000002549705945"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002549705967"></a>

**新增特性<a name="section78241436103817"></a>**

无

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518186196"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518346098"></a>

<a name="zh-cn_topic_0000001498002964_table1077520124617"></a>
<table><tbody><tr id="zh-cn_topic_0000001498002964_row07751817464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001498002964_p177751174618"><a name="zh-cn_topic_0000001498002964_p177751174618"></a><a name="zh-cn_topic_0000001498002964_p177751174618"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.1.1 "><p id="p12376102249"><a name="p12376102249"></a><a name="p12376102249"></a>DTS2024031108664</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row157751511464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001498002964_p167751810462"><a name="zh-cn_topic_0000001498002964_p167751810462"></a><a name="zh-cn_topic_0000001498002964_p167751810462"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.2.1 "><p id="p5376142147"><a name="p5376142147"></a><a name="p5376142147"></a>一般</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row11775191144616"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001498002964_p20775919467"><a name="zh-cn_topic_0000001498002964_p20775919467"></a><a name="zh-cn_topic_0000001498002964_p20775919467"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.3.1 "><p id="p193760213410"><a name="p193760213410"></a><a name="p193760213410"></a>使用多窗口终止酷狗音乐后仍会残留音乐播放进程。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row12775151134619"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001498002964_p197756111466"><a name="zh-cn_topic_0000001498002964_p197756111466"></a><a name="zh-cn_topic_0000001498002964_p197756111466"></a>根因分析</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.4.1 "><p id="p133761021544"><a name="p133761021544"></a><a name="p133761021544"></a>多窗口终止应用时未调用到终止进程的接口，因此怀疑应用做了某些检测后绕过了终止进程。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1677518118466"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001498002964_p97756164616"><a name="zh-cn_topic_0000001498002964_p97756164616"></a><a name="zh-cn_topic_0000001498002964_p97756164616"></a>影响评估</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.5.1 "><p id="p53778219413"><a name="p53778219413"></a><a name="p53778219413"></a>无法通过多窗口终止进程，但是可以通过通知栏或者应用详情终止掉。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1177581134617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001498002964_p677517114617"><a name="zh-cn_topic_0000001498002964_p677517114617"></a><a name="zh-cn_topic_0000001498002964_p677517114617"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.6.1 "><p id="p53771212415"><a name="p53771212415"></a><a name="p53771212415"></a>通知栏终止掉或者应用强制停止。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1777511154617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001498002964_p87762154616"><a name="zh-cn_topic_0000001498002964_p87762154616"></a><a name="zh-cn_topic_0000001498002964_p87762154616"></a>解决计划</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.7.1 "><p id="p83771424412"><a name="p83771424412"></a><a name="p83771424412"></a>该问题正在定位解决中。</p>
</td>
</tr>
</tbody>
</table>

## V5.0.0<a name="ZH-CN_TOPIC_0000002549825969"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186176"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|Kbox Kernel定制patch整改| 针对Kbox Kernel 5.15的定制ashmem/binder patch整改，减少内核Kernel定制，复用内核自身能力 |
|2|Kbox实现网络仿真整改| 针对Kbox网络相关功能的仿真，可以通过获取IP地址、网关、子网掩码、DNS信息，实现云手机可以正常访问网络 |
|3|Kbox实现Telephony仿真整改| 针对Kbox Telephony仿真进行Trable化整改，实现IMEI、IMSI、网络运营商信息、SIM卡等信息的仿真 |
|4|Kbox实现音频仿真功能| Kbox原先不支持音频仿真，在运行依赖音频的应用时可能会出现兼容性问题。因此，现在需要在Kbox中增加音频仿真功能。约束：仅支持音频输出仿真，不支持输入仿真 |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002549825957"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518186180"></a>

无

## V5.0.RC2<a name="ZH-CN_TOPIC_0000002518186178"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518346102"></a>

**新增特性<a name="zh-cn_topic_0000001549282537_section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|基于编解码卡支持云手机视频播放硬件加速| 基于NETINT T432硬件编解码卡，通过OMX媒体框架的适配，实现云手机视频播放H.264/H.265解码硬件加速特性 |
|2|支持Kbox组件版本号查询和显示| Kbox组件版本号查询方式及回显规范 |
|3|升级适配高版本Kernel| Kbox基础云手机相关Kernel patch适配Kernel 5.15版本进行修改 |
|4|Kbox基础云手机适配Mesa 22.1.7| Kbox基础云手机适配Mesa 22.1.7新版本 |
|5|视频流和Kbox相关资料刷新| 视频流和Kbox相关资料刷新Mesa，Kernel和GPU相关的描述 |
|6|Android系统运行异常检测和恢复| 对云手机的SurfaceFlinger、SystemServer、Zygote关键进程和服务进行检查，出现异常时进行恢复 |
|7|支持Vulkan RGB和RGBA纹理转DXT纹理| 在Mesa开源软件基础上实现Vulkan RGB/RGBA纹理转DXT纹理压缩 |
|8|堆栈保护和防漏洞利用| 堆栈保护和防漏洞利用需求 |

**修改特性<a name="zh-cn_topic_0000001549282537_section540mcpsimp"></a>**

无

**删除特性<a name="zh-cn_topic_0000001549282537_section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518346106"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518186194"></a>

<a name="zh-cn_topic_0000001498002964_table1077520124617"></a>
<table><tbody><tr id="zh-cn_topic_0000001498002964_row07751817464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001498002964_p177751174618"><a name="zh-cn_topic_0000001498002964_p177751174618"></a><a name="zh-cn_topic_0000001498002964_p177751174618"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001498002964_p377511134615"><a name="zh-cn_topic_0000001498002964_p377511134615"></a><a name="zh-cn_topic_0000001498002964_p377511134615"></a>DTS2023051802653</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row157751511464"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001498002964_p167751810462"><a name="zh-cn_topic_0000001498002964_p167751810462"></a><a name="zh-cn_topic_0000001498002964_p167751810462"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001498002964_p87750114611"><a name="zh-cn_topic_0000001498002964_p87750114611"></a><a name="zh-cn_topic_0000001498002964_p87750114611"></a>严重</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row11775191144616"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001498002964_p20775919467"><a name="zh-cn_topic_0000001498002964_p20775919467"></a><a name="zh-cn_topic_0000001498002964_p20775919467"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001498002964_p1987484454610"><a name="zh-cn_topic_0000001498002964_p1987484454610"></a><a name="zh-cn_topic_0000001498002964_p1987484454610"></a>升级BIOS版本到6.56之后，重启服务器，概率性出现编码卡芯片丢失情况。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row12775151134619"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001498002964_p197756111466"><a name="zh-cn_topic_0000001498002964_p197756111466"></a><a name="zh-cn_topic_0000001498002964_p197756111466"></a>根因分析</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001498002964_p37759110469"><a name="zh-cn_topic_0000001498002964_p37759110469"></a><a name="zh-cn_topic_0000001498002964_p37759110469"></a>服务器重启之后，发现编码卡芯片丢失，低概率出现，重启之后可以恢复，影响客户正常使用。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1677518118466"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001498002964_p97756164616"><a name="zh-cn_topic_0000001498002964_p97756164616"></a><a name="zh-cn_topic_0000001498002964_p97756164616"></a>影响评估</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.5.1 "><p id="zh-cn_topic_0000001498002964_p19775813469"><a name="zh-cn_topic_0000001498002964_p19775813469"></a><a name="zh-cn_topic_0000001498002964_p19775813469"></a>若搭配T432编码卡使用，出现该问题时影响云手机密度。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1177581134617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001498002964_p677517114617"><a name="zh-cn_topic_0000001498002964_p677517114617"></a><a name="zh-cn_topic_0000001498002964_p677517114617"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.6.1 "><a name="zh-cn_topic_0000001498002964_ol88617589303"></a><a name="zh-cn_topic_0000001498002964_ol88617589303"></a><ol id="zh-cn_topic_0000001498002964_ol88617589303"><li>通过iBMC将服务器风扇设置为高性能模式。</li><li>概率性无法识别：下电重启后可以恢复。</li><li>键撞针损坏：厂家换卡解决。</li></ol>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row1777511154617"><th class="firstcol" valign="top" width="20.830000000000002%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001498002964_p87762154616"><a name="zh-cn_topic_0000001498002964_p87762154616"></a><a name="zh-cn_topic_0000001498002964_p87762154616"></a>解决计划</p>
</th>
<td class="cellrowborder" valign="top" width="79.17%" headers="mcps1.1.3.7.1 "><a name="zh-cn_topic_0000001498002964_ol7508324455"></a><a name="zh-cn_topic_0000001498002964_ol7508324455"></a><ol id="zh-cn_topic_0000001498002964_ol7508324455"><li>T432不属于华为销售范围，可在约束中添加T432掉芯片相关提示，并在文档中添加规避相关说明，提示客户。</li><li>此问题单遗留，跟踪厂家最终定位结果。</li></ol>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001498002964_table82294384613"></a>
<table><tbody><tr id="zh-cn_topic_0000001498002964_row22292034467"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001498002964_p132293318462"><a name="zh-cn_topic_0000001498002964_p132293318462"></a><a name="zh-cn_topic_0000001498002964_p132293318462"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001498002964_p7230438463"><a name="zh-cn_topic_0000001498002964_p7230438463"></a><a name="zh-cn_topic_0000001498002964_p7230438463"></a>DTS2023051004239</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row92301316468"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001498002964_p1523053184614"><a name="zh-cn_topic_0000001498002964_p1523053184614"></a><a name="zh-cn_topic_0000001498002964_p1523053184614"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001498002964_p202309318461"><a name="zh-cn_topic_0000001498002964_p202309318461"></a><a name="zh-cn_topic_0000001498002964_p202309318461"></a>一般</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row8230173164616"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001498002964_p6230163184615"><a name="zh-cn_topic_0000001498002964_p6230163184615"></a><a name="zh-cn_topic_0000001498002964_p6230163184615"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001498002964_p202301232462"><a name="zh-cn_topic_0000001498002964_p202301232462"></a><a name="zh-cn_topic_0000001498002964_p202301232462"></a>使用xplayer进行硬解视频时候，有概率会从硬解视频切换为使用自身软解，无法稳定使用Kbox硬解能力，与xplayer存在兼容性问题。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row623015313469"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001498002964_p1823083134620"><a name="zh-cn_topic_0000001498002964_p1823083134620"></a><a name="zh-cn_topic_0000001498002964_p1823083134620"></a>根因分析</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001498002964_p182301233464"><a name="zh-cn_topic_0000001498002964_p182301233464"></a><a name="zh-cn_topic_0000001498002964_p182301233464"></a>NETINT销毁/初始化概率性响应慢，导致应用检测硬解能力不足，切换为软解。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row14230934466"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001498002964_p17230037467"><a name="zh-cn_topic_0000001498002964_p17230037467"></a><a name="zh-cn_topic_0000001498002964_p17230037467"></a>影响评估</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.5.1 "><p id="zh-cn_topic_0000001498002964_p20230143154618"><a name="zh-cn_topic_0000001498002964_p20230143154618"></a><a name="zh-cn_topic_0000001498002964_p20230143154618"></a>低概率容器从硬解切换为软解，对播放无影响。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row223043134614"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001498002964_p13230123114613"><a name="zh-cn_topic_0000001498002964_p13230123114613"></a><a name="zh-cn_topic_0000001498002964_p13230123114613"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.6.1 "><p id="zh-cn_topic_0000001498002964_p72304313464"><a name="zh-cn_topic_0000001498002964_p72304313464"></a><a name="zh-cn_topic_0000001498002964_p72304313464"></a>xplayer应用对硬解接口响应时间要求严格，切为软解后不影响视频播放，暂不进行规避。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001498002964_row6230433467"><th class="firstcol" valign="top" width="20.919999999999998%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001498002964_p18230103194612"><a name="zh-cn_topic_0000001498002964_p18230103194612"></a><a name="zh-cn_topic_0000001498002964_p18230103194612"></a>解决计划</p>
</th>
<td class="cellrowborder" valign="top" width="79.08%" headers="mcps1.1.3.7.1 "><p id="zh-cn_topic_0000001498002964_p72301337464"><a name="zh-cn_topic_0000001498002964_p72301337464"></a><a name="zh-cn_topic_0000001498002964_p72301337464"></a>联合NETINT继续定位响应慢的问题。</p>
</td>
</tr>
</tbody>
</table>

## V5.0.RC3<a name="ZH-CN_TOPIC_0000002518186188"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002549825959"></a>

**新增特性<a name="zh-cn_topic_0000001473962058_section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|支持Exagear+openEuler 22.03 LTS转码| 支持Kbox运行Exagear适配openEuler 22.03 LTS |
|2|基于openEuler 22.03 LTS进行Kbox适配| 增强操作系统兼容性 |

**修改特性<a name="zh-cn_topic_0000001473962058_section540mcpsimp"></a>**

无

**删除特性<a name="zh-cn_topic_0000001473962058_section543mcpsimp"></a>**

本版本不支持Android 9，故删除Android 9内容。

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518346112"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002549705963"></a>

<a name="zh-cn_topic_0000001473642402_table1170965710134"></a>
<table><tbody><tr id="zh-cn_topic_0000001473642402_row8709457201314"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001473642402_p5709557171320"><a name="zh-cn_topic_0000001473642402_p5709557171320"></a><a name="zh-cn_topic_0000001473642402_p5709557171320"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001473642402_p127092057121318"><a name="zh-cn_topic_0000001473642402_p127092057121318"></a><a name="zh-cn_topic_0000001473642402_p127092057121318"></a>DTS2023022301216</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row1870915712137"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001473642402_p18526151631413"><a name="zh-cn_topic_0000001473642402_p18526151631413"></a><a name="zh-cn_topic_0000001473642402_p18526151631413"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001473642402_p1170917579131"><a name="zh-cn_topic_0000001473642402_p1170917579131"></a><a name="zh-cn_topic_0000001473642402_p1170917579131"></a>提示</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row11709125791311"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001473642402_p23481921101416"><a name="zh-cn_topic_0000001473642402_p23481921101416"></a><a name="zh-cn_topic_0000001473642402_p23481921101416"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001473642402_p1709105716136"><a name="zh-cn_topic_0000001473642402_p1709105716136"></a><a name="zh-cn_topic_0000001473642402_p1709105716136"></a>Kbox基础云手机安装光遇并打开，使用未注册角色的账号进行登录时，显示设备数据异常，无法创建新角色。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row1670912572131"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001473642402_p15709657161312"><a name="zh-cn_topic_0000001473642402_p15709657161312"></a><a name="zh-cn_topic_0000001473642402_p15709657161312"></a>根因分析</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001473642402_p27661527174117"><a name="zh-cn_topic_0000001473642402_p27661527174117"></a><a name="zh-cn_topic_0000001473642402_p27661527174117"></a>目前尚未定位到根因，两点方向可以探究：</p>
<a name="zh-cn_topic_0000001473642402_ol2224634194113"></a><a name="zh-cn_topic_0000001473642402_ol2224634194113"></a><ol id="zh-cn_topic_0000001473642402_ol2224634194113"><li>Kbox设备仿真目前做的不够完善，缺少光遇需要的数据，导致无法创建角色，这一点在后续Kbox的演进策略需要评估。</li><li>光遇游戏本身检测到Kbox非真实物理设备，导致触发了防作弊机制。</li></ol>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row7709757101310"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.5.1"><p id="zh-cn_topic_0000001473642402_p7709205711310"><a name="zh-cn_topic_0000001473642402_p7709205711310"></a><a name="zh-cn_topic_0000001473642402_p7709205711310"></a>影响评估</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.5.1 "><p id="zh-cn_topic_0000001473642402_p5709957101312"><a name="zh-cn_topic_0000001473642402_p5709957101312"></a><a name="zh-cn_topic_0000001473642402_p5709957101312"></a>有消减措施，影响较小。目前光遇不在兼容性列表中，测试目的是验证ETC2纹理的支持，该功能已经正常实现。另，可以用已经创建角色的账号进行登录。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row8709257141319"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.6.1"><p id="zh-cn_topic_0000001473642402_p1270925719137"><a name="zh-cn_topic_0000001473642402_p1270925719137"></a><a name="zh-cn_topic_0000001473642402_p1270925719137"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.6.1 "><p id="zh-cn_topic_0000001473642402_p6709175721310"><a name="zh-cn_topic_0000001473642402_p6709175721310"></a><a name="zh-cn_topic_0000001473642402_p6709175721310"></a>使用已经创建角色的账号可正常登录游戏。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001473642402_row14709857101313"><th class="firstcol" valign="top" width="15.6%" id="mcps1.1.3.7.1"><p id="zh-cn_topic_0000001473642402_p968328140"><a name="zh-cn_topic_0000001473642402_p968328140"></a><a name="zh-cn_topic_0000001473642402_p968328140"></a>解决计划</p>
</th>
<td class="cellrowborder" valign="top" width="84.39999999999999%" headers="mcps1.1.3.7.1 "><p id="zh-cn_topic_0000001473642402_p117104572137"><a name="zh-cn_topic_0000001473642402_p117104572137"></a><a name="zh-cn_topic_0000001473642402_p117104572137"></a>问题单遗留，对设备仿真进行摸底后再评估是否关闭问题单。</p>
</td>
</tr>
</tbody>
</table>

## V3.0.0<a name="ZH-CN_TOPIC_0000002549705969"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002549705959"></a>

**新增特性<a name="zh-cn_topic_0000001468009680_section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|GPU卡适配| 增强硬件兼容性 |
|2|提供基础云手机资料文档| 指导用户使用Kbox云手机容器 |
|3|Kbox Android 11云手机适配服务器| Kbox Android 11云手机支持新的硬件平台 |

**修改特性<a name="zh-cn_topic_0000001468009680_section540mcpsimp"></a>**

无

**删除特性<a name="zh-cn_topic_0000001468009680_section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518346108"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518346110"></a>

无

## V2.0.0<a name="ZH-CN_TOPIC_0000002518346096"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002549825965"></a>

本版本继承本产品2.0.RC1到2.0.RC2所有版本的所有特性。

**新增特性<a name="zh-cn_topic_0000001420053428_section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
|1|开源软件和Docker容器使用过程可信整改| 针对开发过程中开源软件和Docker容器使用的可信要求进行整改 |

**修改特性<a name="zh-cn_topic_0000001420053428_section540mcpsimp"></a>**

无

**删除特性<a name="zh-cn_topic_0000001420053428_section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518346090"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002549705961"></a>

<a name="zh-cn_topic_0000001420053432_table41842027194519"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row2236202774512"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p123692754520"><a name="zh-cn_topic_0000001420053432_p123692754520"></a><a name="zh-cn_topic_0000001420053432_p123692754520"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p323612273450"><a name="zh-cn_topic_0000001420053432_p323612273450"></a><a name="zh-cn_topic_0000001420053432_p323612273450"></a>DTS202105190IPKB9P1300</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row1823632717450"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p172361627124515"><a name="zh-cn_topic_0000001420053432_p172361627124515"></a><a name="zh-cn_topic_0000001420053432_p172361627124515"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p1236102794512"><a name="zh-cn_topic_0000001420053432_p1236102794512"></a><a name="zh-cn_topic_0000001420053432_p1236102794512"></a>条件：CI日构建场景使用CTS测试套件进行测试。</p>
<p id="zh-cn_topic_0000001420053432_p1323602794510"><a name="zh-cn_topic_0000001420053432_p1323602794510"></a><a name="zh-cn_topic_0000001420053432_p1323602794510"></a>现象：部分模块出现在某个容器无法通过测试用例，更换为其他容器才能通过测试用例。</p>
<p id="zh-cn_topic_0000001420053432_p7236142794516"><a name="zh-cn_topic_0000001420053432_p7236142794516"></a><a name="zh-cn_topic_0000001420053432_p7236142794516"></a>根因分析：问题单中296 CtsUiAutomationTestCases中失败用例不是基线用例，是额外增加的测试用例，该用例会在CTS专项工作中继续分析；</p>
<p id="zh-cn_topic_0000001420053432_p11236182754512"><a name="zh-cn_topic_0000001420053432_p11236182754512"></a><a name="zh-cn_topic_0000001420053432_p11236182754512"></a>26 CtsAssistTestCases中失败用例是用例本身问题， Google bug id is 30859355，可申请豁免；</p>
<p id="zh-cn_topic_0000001420053432_p823612794512"><a name="zh-cn_topic_0000001420053432_p823612794512"></a><a name="zh-cn_topic_0000001420053432_p823612794512"></a>69 CtsGraphicsTestCases中两个失败用例与Vulkan使能相关，根据上次CCB结论屏蔽两个不支持扩展属性和image format相关用例后，该模块可正常通过；</p>
<p id="zh-cn_topic_0000001420053432_p1723672744511"><a name="zh-cn_topic_0000001420053432_p1723672744511"></a><a name="zh-cn_topic_0000001420053432_p1723672744511"></a>在7.2-9.3期间，CI CTS日构建一共执行了28次，其中CtsWidgetTestCases失败了4次，CtsAccessibilityTestCases失败了0次，CtsJvmtiRunTest993HostTestCases失败了1次，CtsAtraceHostTestCases失败了1次，总体来看失败概率较低，增加retry次数能够提高上述模块通过率。</p>
<p id="zh-cn_topic_0000001420053432_p10236172711455"><a name="zh-cn_topic_0000001420053432_p10236172711455"></a><a name="zh-cn_topic_0000001420053432_p10236172711455"></a>影响：该问题单中问题为偶现问题，出现失败频率最高的模块，在前28次CI日构建中失败了4次，其他模块失败了1次或0次，影响CI环境CTS通过率。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row22361727144513"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p023672734513"><a name="zh-cn_topic_0000001420053432_p023672734513"></a><a name="zh-cn_topic_0000001420053432_p023672734513"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p523672754510"><a name="zh-cn_topic_0000001420053432_p523672754510"></a><a name="zh-cn_topic_0000001420053432_p523672754510"></a>一般</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row18236132774513"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p14236132710456"><a name="zh-cn_topic_0000001420053432_p14236132710456"></a><a name="zh-cn_topic_0000001420053432_p14236132710456"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p1428148141616"><a name="zh-cn_topic_0000001420053432_p1428148141616"></a><a name="zh-cn_topic_0000001420053432_p1428148141616"></a>规避措施：增加失败用例retry次数。</p>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001420053432_table164784818466"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row1766915482465"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p1166914481464"><a name="zh-cn_topic_0000001420053432_p1166914481464"></a><a name="zh-cn_topic_0000001420053432_p1166914481464"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p136691548154615"><a name="zh-cn_topic_0000001420053432_p136691548154615"></a><a name="zh-cn_topic_0000001420053432_p136691548154615"></a>蓝区issue15</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row266924810467"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p266924854619"><a name="zh-cn_topic_0000001420053432_p266924854619"></a><a name="zh-cn_topic_0000001420053432_p266924854619"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p966904815460"><a name="zh-cn_topic_0000001420053432_p966904815460"></a><a name="zh-cn_topic_0000001420053432_p966904815460"></a>条件：视频流云手机测试cocos</p>
<p id="zh-cn_topic_0000001420053432_p126694481469"><a name="zh-cn_topic_0000001420053432_p126694481469"></a><a name="zh-cn_topic_0000001420053432_p126694481469"></a>现象：<span>横屏游戏中，按住通知栏，单击服务端</span><span>home</span><span>键会导致下拉通知栏强制拉出</span>。</p>
<p id="zh-cn_topic_0000001420053432_p142981337141712"><a name="zh-cn_topic_0000001420053432_p142981337141712"></a><a name="zh-cn_topic_0000001420053432_p142981337141712"></a><span>根因分析：</span>蓝区需求要求屏蔽掉下拉通知栏，在问题描述的复杂操作场景下没有做屏蔽，导致仍然可以通过问题单操作呼出通知栏，该场景下屏蔽实现方案还在讨论，在过点前未完成修改。</p>
<p id="zh-cn_topic_0000001420053432_p136691448134610"><a name="zh-cn_topic_0000001420053432_p136691448134610"></a><a name="zh-cn_topic_0000001420053432_p136691448134610"></a>影响：触发条件比较苛刻。一般人不会同时左手去按住通知栏右手按住home键去操作，而且必须是横竖屏切换的时候才会出现。 就算跳出了通知栏也不会影响正常功能的使用。所以，几乎无影响。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row16691448204616"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p866934894617"><a name="zh-cn_topic_0000001420053432_p866934894617"></a><a name="zh-cn_topic_0000001420053432_p866934894617"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p1266917482462"><a name="zh-cn_topic_0000001420053432_p1266917482462"></a><a name="zh-cn_topic_0000001420053432_p1266917482462"></a>蓝区</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row466974815461"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p18669048134614"><a name="zh-cn_topic_0000001420053432_p18669048134614"></a><a name="zh-cn_topic_0000001420053432_p18669048134614"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p106691048184618"><a name="zh-cn_topic_0000001420053432_p106691048184618"></a><a name="zh-cn_topic_0000001420053432_p106691048184618"></a>正常使用几乎不会触发此问题。</p>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001420053432_table85082284479"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row115371528134717"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p953792815479"><a name="zh-cn_topic_0000001420053432_p953792815479"></a><a name="zh-cn_topic_0000001420053432_p953792815479"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p553715286471"><a name="zh-cn_topic_0000001420053432_p553715286471"></a><a name="zh-cn_topic_0000001420053432_p553715286471"></a>DTS202107210KJTJ7P1400</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row205371728164714"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p19537192894712"><a name="zh-cn_topic_0000001420053432_p19537192894712"></a><a name="zh-cn_topic_0000001420053432_p19537192894712"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p353772874720"><a name="zh-cn_topic_0000001420053432_p353772874720"></a><a name="zh-cn_topic_0000001420053432_p353772874720"></a>条件：CI日构建场景视频流云手机测试cocos</p>
<p id="zh-cn_topic_0000001420053432_p1353772818475"><a name="zh-cn_topic_0000001420053432_p1353772818475"></a><a name="zh-cn_topic_0000001420053432_p1353772818475"></a>现象：<span>CI</span><span>视频流日构建运行完</span><span>cocos</span><span>用例后，进入服务端云手机主界面显示花屏</span>。</p>
<p id="zh-cn_topic_0000001420053432_p2537202817476"><a name="zh-cn_topic_0000001420053432_p2537202817476"></a><a name="zh-cn_topic_0000001420053432_p2537202817476"></a><span>根因分析：</span>通过CI日志分析，在跑cocos用例时，在mesa的gallium_dri.so内调用函数发生了内存越界访问导致mesa出现crash，调用栈定位到mesa库中的eglSwapBuffersWithDamageKHR接口，问题现象为花屏，初步定位跟第三方组件mesa驱动有关，需要进一步进行定位分析。</p>
<p id="zh-cn_topic_0000001420053432_p12538428184718"><a name="zh-cn_topic_0000001420053432_p12538428184718"></a><a name="zh-cn_topic_0000001420053432_p12538428184718"></a>影响：</p>
<a name="ol16754121113013"></a><a name="ol16754121113013"></a><ol id="ol16754121113013"><li>该问题为小概率偶现问题，视频流日构建服务器一共出现2次（7月20号和9月4号，超过一个月未发生），之后经过专项测试6000次未复现问题。</li><li>只影响当前跑用例的云手机，不影响服务器上启动的其它路云手机。</li></ol>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row75381285471"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p17538728144719"><a name="zh-cn_topic_0000001420053432_p17538728144719"></a><a name="zh-cn_topic_0000001420053432_p17538728144719"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p2538102816477"><a name="zh-cn_topic_0000001420053432_p2538102816477"></a><a name="zh-cn_topic_0000001420053432_p2538102816477"></a>一般</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row12538202816473"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p1753812824714"><a name="zh-cn_topic_0000001420053432_p1753812824714"></a><a name="zh-cn_topic_0000001420053432_p1753812824714"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p961105117193"><a name="zh-cn_topic_0000001420053432_p961105117193"></a><a name="zh-cn_topic_0000001420053432_p961105117193"></a>重启该路云手机可以恢复。</p>
</td>
</tr>
</tbody>
</table>

<a name="zh-cn_topic_0000001420053432_table919416369514"></a>
<table><tbody><tr id="zh-cn_topic_0000001420053432_row16268203685118"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.1.1"><p id="zh-cn_topic_0000001420053432_p192681636145116"><a name="zh-cn_topic_0000001420053432_p192681636145116"></a><a name="zh-cn_topic_0000001420053432_p192681636145116"></a>问题单号</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.1.1 "><p id="zh-cn_topic_0000001420053432_p10268133611512"><a name="zh-cn_topic_0000001420053432_p10268133611512"></a><a name="zh-cn_topic_0000001420053432_p10268133611512"></a>DTS2021090912581</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row172689368517"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.2.1"><p id="zh-cn_topic_0000001420053432_p926833695111"><a name="zh-cn_topic_0000001420053432_p926833695111"></a><a name="zh-cn_topic_0000001420053432_p926833695111"></a>问题描述</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.2.1 "><p id="zh-cn_topic_0000001420053432_p16268173665114"><a name="zh-cn_topic_0000001420053432_p16268173665114"></a><a name="zh-cn_topic_0000001420053432_p16268173665114"></a>条件：服务器升级177版本BIOS/5.14版本CPLD/3.01.12.23版本IBMC</p>
<p id="zh-cn_topic_0000001420053432_p1526873685116"><a name="zh-cn_topic_0000001420053432_p1526873685116"></a><a name="zh-cn_topic_0000001420053432_p1526873685116"></a>现象：<span>5220</span><span>服务器使用新的主板升级</span><span>177</span><span>版本</span><span>BIOS/5.14</span><span>版本</span><span>CPLD/3.01.12.23</span><span>版本</span><span>IBMC</span><span>，升级失败，服务器挂死。暂时无可以匹配的正式版本</span>。</p>
<p id="zh-cn_topic_0000001420053432_p148522050143713"><a name="zh-cn_topic_0000001420053432_p148522050143713"></a><a name="zh-cn_topic_0000001420053432_p148522050143713"></a><span>根因分析：5220存在新老主板两个版本，老主板配套的BIOS版本在support网站的链接失效；当前测试使用的新主板，和鲲鹏计算硬件5220主板开发工程师确认配套5220新主板的BIOS版本还未上网，使用support网站上最新的BIOS版本会出现升级失败问题，当前问题的解决依赖BIOS团队发布新主板配套的BIOS版本到support网站。</span></p>
<p id="zh-cn_topic_0000001420053432_p52681436185115"><a name="zh-cn_topic_0000001420053432_p52681436185115"></a><a name="zh-cn_topic_0000001420053432_p52681436185115"></a>影响：客户如果拿到新主板，无法通过support获取到配套的BIOS版本。</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row19268193605118"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.3.1"><p id="zh-cn_topic_0000001420053432_p826823611513"><a name="zh-cn_topic_0000001420053432_p826823611513"></a><a name="zh-cn_topic_0000001420053432_p826823611513"></a>严重级别</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.3.1 "><p id="zh-cn_topic_0000001420053432_p42684364512"><a name="zh-cn_topic_0000001420053432_p42684364512"></a><a name="zh-cn_topic_0000001420053432_p42684364512"></a>一般</p>
</td>
</tr>
<tr id="zh-cn_topic_0000001420053432_row13268163620519"><th class="firstcol" valign="top" width="23%" id="mcps1.1.3.4.1"><p id="zh-cn_topic_0000001420053432_p02681236205117"><a name="zh-cn_topic_0000001420053432_p02681236205117"></a><a name="zh-cn_topic_0000001420053432_p02681236205117"></a>规避和应急措施</p>
</th>
<td class="cellrowborder" valign="top" width="77%" headers="mcps1.1.3.4.1 "><p id="zh-cn_topic_0000001420053432_p856694613200"><a name="zh-cn_topic_0000001420053432_p856694613200"></a><a name="zh-cn_topic_0000001420053432_p856694613200"></a>无</p>
</td>
</tr>
</tbody>
</table>

## 版本配套文档<a name="ZH-CN_TOPIC_0000002549825961"></a>

### V7.3.0_11配套文档<a name="ZH-CN_TOPIC_0000002549825955"></a>

|序号|文档名称|内容简介|下载方法|
|--|--|--|--|
|1|best practices| 本文档向用户介绍Kbox云手机容器的最佳实践 |[best practices](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/best_practices.md)|
|2|compile guide| 本文档向用户介绍Kbox云手机容器的编译方法 |[compile guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/compile_guide.md)|
|3|feature guide| 本文档向用户介绍Kbox云手机容器的特性说明 |[feature guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/feature_guide.md)|
|4|install guide| 本文档向用户介绍Kbox云手机容器的安装指南 |[install guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/install_guide.md)|
|5|release notes| 本文档向用户介绍Kbox云手机容器的版本相关信息 |[release notes](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/release_notes.md)|
|6|test guide| 本文档向用户介绍Kbox云手机容器的测试方法 |[test guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/test_guide.md)|
|7|troubleshooting| 本文档向用户介绍Kbox云手机容器的故障案例 |[troubleshooting](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/troubleshooting.md)|
|8|user guide| 本文档向用户介绍Kbox云手机容器的用户指南 |[user guide](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/user_guide.md)|
|9|routine maintenance| 本文档向用户介绍Kbox云手机容器的维护方法和维护工具 |[routine maintenance](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/%E4%BE%8B%E8%A1%8C%E7%BB%B4%E6%8A%A4.md)|

### 获取文档方式<a name="ZH-CN_TOPIC_0000002549705957"></a>

您可以通过访问[menu](https://gitcode.com/boostkit/Kbox/blob/AOSP11/docs/zh/menu.md)浏览和获取相关文档。
