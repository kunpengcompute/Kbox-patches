# 版本说明书<a name="ZH-CN_TOPIC_0000002521895828"></a>

## 版本配套说明<a name="ZH-CN_TOPIC_0000002518186090"></a>

### 产品版本信息<a name="ZH-CN_TOPIC_0000002549825865"></a>

|项目|内容|
|--|--|
|产品名称|Kunpeng BoostKit|
|产品版本|26.2.RC1|
|软件名称|Kbox云手机容器|
|软件包版本|8.2.0_15|

### 软件版本配套说明<a name="ZH-CN_TOPIC_0000002549705863"></a>

|软件类型|版本|备注|
|--|--|--|
|Kunpeng BoostKit|Kunpeng BoostKit 26.2.RC1|-|
|OS|openEuler-24.03-LTS-SP1-aarch64 （内核6.6.0-72.0.0）|-|
|ExaGear|ExaGear_ARM32-ARM64|转码软件|

### 硬件版本配套说明<a name="ZH-CN_TOPIC_0000002549705865"></a>

|服务器类型|处理器型号|BIOS版本|CPLD版本|BMC版本|
|--|--|--|--|--|
|鲲鹏服务器|鲲鹏920 7260处理器|6.57|5.09|6.49|
|鲲鹏服务器|鲲鹏920 7280Z处理器|33.70|5.10|26.01.62.25|

## 版本使用注意事项<a name="ZH-CN_TOPIC_0000002549825861"></a>

请参考相应版本的特性指南，例如《[特性指南](./feature_guide.md)》。

## V8.2.RC1_11<a id="ZH-CN_TOPIC_0000002549825973"></a>
 
### 更新说明<a id="ZH-CN_TOPIC_0000002518186202"></a>
 
#### 新增特性<a id="section78241436103817"></a>
 
|编号|描述|目的|
|---|---|---|
|1|支持共享数据卷| Kbox支持支持共享数据卷 |
 
#### 修改特性<a id="section540mcpsimp"></a>
 
无
 
#### 删除特性<a id="section543mcpsimp"></a>
 
无
 
### 已解决的问题<a id="ZH-CN_TOPIC_0000002549705975"></a>
 
无
 
### 遗留问题<a id="ZH-CN_TOPIC_0000002549825953"></a>
 
无
 
## V8.1.RC1_11<a id="ZH-CN_TOPIC_0000002549825973"></a>
 
### 更新说明<a id="ZH-CN_TOPIC_0000002518186202"></a>
 
#### 新增特性<a id="section78241436103817"></a>
 
|编号|描述|目的|
|---|---|---|
|1|支持NFS挂载| Kbox支持NFS挂载 |
|2|CPU/F2FS文件系统/System分区/init进程仿真增强| 系统仿真增强 |
 
#### 修改特性<a id="section540mcpsimp"></a>
 
无
 
#### 删除特性<a id="section543mcpsimp"></a>
 
无
 
### 已解决的问题<a id="ZH-CN_TOPIC_0000002549705975"></a>
 
无
 
### 遗留问题<a id="ZH-CN_TOPIC_0000002549825953"></a>
 
无
 
## V8.0.RC1_11<a id="ZH-CN_TOPIC_0000002549825973"></a>
 
### 更新说明<a id="ZH-CN_TOPIC_0000002518186202"></a>
 
#### 新增特性<a id="section78241436103817"></a>
 
|编号|描述|目的|
|---|---|---|
|1|支持Codec 2.0编解码| Kbox支持Codec 2.0编解码框架 |
 
#### 修改特性<a id="section540mcpsimp"></a>
 
无
 
#### 删除特性<a id="section543mcpsimp"></a>
 
无
 
### 已解决的问题<a id="ZH-CN_TOPIC_0000002549705975"></a>
 
无
 
### 遗留问题<a id="ZH-CN_TOPIC_0000002549825953"></a>
 
无

## V7.3.0_15<a name="ZH-CN_TOPIC_0000002549705869"></a>

### 更新说明<a name="ZH-CN_TOPIC_0000002518186094"></a>

**新增特性<a name="section78241436103817"></a>**

|编号|描述|目的|
|--|--|--|
| 1 | 新增支持Android 15云手机特性 | Kbox云手机容器适配Android 15系统基础功能，完成系统启动、出图、scrcpy出流；实现了GPS、Sensor、Telephony等硬件仿真接入Android 15 |

**修改特性<a name="section540mcpsimp"></a>**

无

**删除特性<a name="section543mcpsimp"></a>**

无

### 已解决的问题<a name="ZH-CN_TOPIC_0000002518346010"></a>

无

### 遗留问题<a name="ZH-CN_TOPIC_0000002518186096"></a>

<a name="table1427894420453"></a>

|严重级别|问题描述|根因分析|影响评估|规避和应急措施|解决计划|
|--|--|--|--|--|--|
|一般|在道客DC 1000/1000C环境上运行安卓15云机，使用RC13-A15版本驱动，打开自适应Vsync功能，收益不稳定。|该特性打开时，瀚博驱动抓图部分未配合适配，导致抓图时小概率使用上一帧的数据，导致最终观察时，本该在t帧显示的图像在t+1帧显示，时延增大。|打开该功能时，正常使用应用时均无用户可感知的画面异常。|暂无规避措施|瀚博厂商更新驱动修复|

## 版本配套文档<a name="ZH-CN_TOPIC_0000002549825863"></a>

### V7.3.0_15配套文档<a name="ZH-CN_TOPIC_0000002518186092"></a>

|序号|文档名称|内容简介|下载方法|
|--|--|--|--|
| 1 | best practices | 本文档向用户介绍Kbox云手机容器的最佳实践 | [最佳实践](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/best_practices.md) |
| 2 | compile guide | 本文档向用户介绍Kbox云手机容器的编译方法 | [编译指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/compile_guide.md) |
| 3 | feature guide | 本文档向用户介绍Kbox云手机容器的特性说明 | [特性指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/feature_guide.md) |
| 4 | install guide | 本文档向用户介绍Kbox云手机容器的安装指南 | [安装指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/install_guide.md) |
| 5 | release notes | 本文档向用户介绍Kbox云手机容器的版本相关信息 | [版本说明书](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/release_notes.md) |
| 6 | test guide | 本文档向用户介绍Kbox云手机容器的测试方法 | [验收测试指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/test_guide.md) |
| 7 | troubleshooting | 本文档向用户介绍Kbox云手机容器的故障案例 | [故障案例](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/troubleshooting.md) |
| 8 | user guide | 本文档向用户介绍Kbox云手机容器的用户指南 | [用户指南](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/user_guide.md) |
| 9 | routine maintenance | 本文档向用户介绍Kbox云手机容器的维护方法和维护工具 | [例行维护](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/routine_maintenance.md) |

### 获取文档方式<a name="ZH-CN_TOPIC_0000002549825867"></a>

您可以通过访问[menu](https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/menu.md)浏览和获取相关文档。
