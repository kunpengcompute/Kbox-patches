# 验收测试指南<a name="ZH-CN_TOPIC_0000002552663615"></a>

## 1 概述<a name="ZH-CN_TOPIC_0000002518186314"></a>

### 1.1 验收依据<a name="ZH-CN_TOPIC_0000002549706091"></a>

本手册是云手机产品验收的指导文档，在进行验收前请确保使用的物理环境、系统环境以及软件版本正确，本手册中的用例为云手机产品测试团队设计，覆盖Kbox云手机产品的基本功能。

### 1.2 注意事项<a name="ZH-CN_TOPIC_0000002549826087"></a>

1. 在进行验收前请确保使用的物理环境、系统环境以及软件版本正确并配套。
2. 执行验收用例前请首先完成Kbox云手机端到端环境部署，具体部署步骤请参见《[install_guide](install_guide.md)》。
3. 验收的项目应经过华为公司和用户双方相关人员的确认。
4. 在验收和初验测试过程中，双方人员应对照相关标准严格测试。由于部分指标参数出厂时已经测试，验收时限于条件可以进行抽测或免测。

>![](public_sys-resources/icon-note.gif) **说明：** 
>
>在实际验收测试过程中，以合同要求及双方约定为准进行验收，本手册仅供参考。

## 2 测试准备<a name="ZH-CN_TOPIC_0000002518186316"></a>

服务器硬件以及软件包信息、用例验收前环境部署以及密度测试方法等信息请参见《[install_guide](install_guide.md)》，BIOS/iBMC/CPLD版本请参见《[release_notes](release_notes.md)》。

## 3 测试约定<a name="ZH-CN_TOPIC_0000002549706087"></a>

**结果描述<a name="section62693428"></a>**

本文档约定使用如下的测试结果描述。

- PASS：按照用例的预置条件和测试步骤，测试结果与预期结果完全符合。
- FAIL：按照用例的预置条件和测试步骤，测试结果与预期结果不符合。
- NT：由于需求变更或测试环境原因，用例未执行测试。

## 4 测试用例及测试记录<a name="ZH-CN_TOPIC_0000002518346236"></a>

### 4.1 基本功能测试<a name="ZH-CN_TOPIC_0000002518186318"></a>

#### 4.1.1 创建Kbox云手机容器<a name="ZH-CN_TOPIC_0000002549826089"></a>

<a name="table27768935"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.1<br> |
| 测试目的<br> | 创建Kbox云手机容器。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。<br> |
| 测试步骤<br> | 执行创建Kbox云手机容器命令./android11_kbox.sh start kbox_image:tag x y。 说明： 其中x，y表示想要创建的容器编号首尾值，如创建1到9号容器则x输入1，y输入9；如果只想创建单个容器，仅输入x即可。<br><br>执行命令docker ps -a查看已创建成功的Kbox云手机容器及状态。<br> |
| 预期结果<br> | Kbox云手机容器创建结束回显成功标志。执行命令可以查询到已创建的设备及状态。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.2 重启Kbox云手机容器<a name="ZH-CN_TOPIC_0000002549706089"></a>

<a name="table26778736"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.2<br> |
| 测试目的<br> | 重启Kbox云手机容器。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。Kbox云手机容器已启动。<br> |
| 测试步骤<br> | 执行./android11_kbox.sh restart x重启已启动的Kbox云手机容器。 说明： 其中x表示容器编号数字部分。<br><br>执行docker ps -a查看已重启成功的Kbox云手机容器及状态。<br> |
| 预期结果<br> | Kbox云手机容器重启结束回显成功标志。执行命令可以查询到已重启的设备及状态。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.3 删除Kbox云手机容器<a name="ZH-CN_TOPIC_0000002518346234"></a>

<a name="table24712267"></a>

| 项目<br> | 内容<br>   |
|---|---|
| 用例编号<br> | 4.1.3<br> |
| 测试目的<br> | 删除Kbox云手机容器。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。Kbox云手机容器已启动。<br> |
| 测试步骤<br> | 执行./android11_kbox.sh delete x删除Kbox云手机容器。 说明： 其中x表示容器编号数字部分。<br><br>执行docker ps -a查看当前环境上的Kbox云手机容器。<br> |
| 预期结果<br> | Kbox云手机容器删除结束显示成功标志。执行命令查看到的Kbox云手机容器列表中没有已被删除的Kbox云手机容器。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.4 Kbox云手机容器状态查询<a name="ZH-CN_TOPIC_0000002549826077"></a>

<a name="table35101782"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.4<br> |
| 测试目的<br> | 查询Kbox云手机容器状态。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。Kbox云手机容器已启动。<br> |
| 测试步骤<br> | 执行docker ps -a查看当前环境上的Kbox云手机容器。执行docker exec -it kbox_x sh进入Kbox云手机容器后执行getprop | grep sys.boot_completed查询容器运行状态。 说明： 其中x表示容器编号数字部分。<br><br><br> |
| 预期结果<br> | 显示的Kbox云手机列表中有待查询设备。待查Kbox云手机的[sys.boot_completed]参数的值为[1]，表示该Kbox云手机启动成功。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.5 Kbox云手机容器adb测试<a name="ZH-CN_TOPIC_0000002549706085"></a>

<a name="table21405834"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.5<br> |
| 测试目的<br> | 验证Kbox云手机容器adb连接和断连。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。Kbox云手机容器已启动。<br> |
| 测试步骤<br> | 执行adb connect [ip:port]连接单个容器。 说明： 其中ip:port（需替换为实际IP地址和端口号）为Kbox云手机的部署IP地址以及启动的容器对应的端口。<br><br>执行adb disconnect [ip:port]断连单个容器。<br> |
| 预期结果<br> | 回显“connected to ip:port”，adb连接Kbox云手机容器成功。回显“disconnected ip:port”，adb断连Kbox云手机容器成功。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.6 资源隔离测试<a name="ZH-CN_TOPIC_0000002518346226"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.6<br> |
| 测试目的<br> | 验证Kbox云手机资源隔离功能是否正常。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并连接。<br> |
| 测试步骤<br> | CPU资源隔离验证：执行命令docker exec -it kbox_x cat /proc/cpuinfo | grep processor。内存资源隔离验证：执行命令docker exec -it kbox_x cat /proc/meminfo | grep MemTotal。存储资源隔离验证：执行命令df -h | grep -w kbox_x。 说明： 其中x表示容器编号数字部分。<br><br><br> |
| 预期结果<br> | 查询到的单个容器CPU核数与特性指南中的规格相符。查询到的单个容器内存大小与特性指南中的规格相符。查询到的单个容器存储空间大小与特性指南中的规格相符。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.7 GPS Mock测试<a name="ZH-CN_TOPIC_0000002549706077"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.7<br> |
| 测试目的<br> | 验证GPS Mock功能。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并连接。容器内已安装百度地图或高德地图。<br> |
| 测试步骤<br> | 使用ARDC连接Kbox云手机容器显示图形界面。打开百度地图或高德地图，查看当前位置。<br> |
| 预期结果<br> | 显示当前位置为Mock预置位置（华为杭研所）。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.8 IMEI Mock测试<a name="ZH-CN_TOPIC_0000002518186306"></a>

<a name="table9347770"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.8<br> |
| 测试目的<br> | 验证IMEI Mock功能。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用ARDC连接显示云手机界面。<br> |
| 测试步骤<br> | 在云手机拨号界面输入“*#06#”，或在服务器端使用命令docker exec -it kbox_x getprop persist.sys.prop.writeimei，查询IMEI的值。服务器端使用命令docker exec -it kbox_x sh setprop persist.sys.prop.writeimei imei_num修改IMEI的值。 说明： 其中x表示容器编号的数值部分。<br><br><br> |
| 预期结果<br> | 显示当前Kbox云手机容器预置的IMEI码。服务端修改IMEI值后，再次查询显示为修改之后的IMEI值。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.9 Wi-Fi Mock测试<a name="ZH-CN_TOPIC_0000002549826083"></a>

<a name="table11771810"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.9<br> |
| 测试目的<br> | 验证Wi-Fi Mock功能。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器。Kbox云手机内已安装安兔兔（安兔兔的作用是激活Wi-Fi Mock功能）。<br> |
| 测试步骤<br> | 打开安兔兔，并授予相关权限。进入“首页 > 我的手机 > 硬件配置界面”查看相关配置。<br> |
| 预期结果<br> | 硬件配置界面显示Wi-Fi相关信息。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.10 传感器Mock测试<a name="ZH-CN_TOPIC_0000002518186312"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.10<br> |
| 测试目的<br> | 验证传感器Mock功能，测试的传感器包括加速度和陀螺仪。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并连接。Kbox云手机内已安装安兔兔软件。<br> |
| 测试步骤<br> | 在安兔兔软件中查看“我的手机 > 硬件配置 > 传感器”。<br> |
| 预期结果<br> | 传感器选项中有加速度/陀螺仪显示。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.11 vinput设备创建<a name="vinput设备创建"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.11<br> |
| 测试目的<br> | 验证能够成功创建vinput设备-鼠标/手柄。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用adb连接。<br> |
| 测试步骤<br> | 打开一个服务器远程连接窗口A，输入命令docker exec -it kbox_x setprop persist.sys.input.[mouse/gamepad1/gamepad2].name xxx分别设置鼠标/手柄1/手柄2名称。 说明： 其中x表示容器编号的数值部分，xxx为长度不超过64个字符的字母/数字/下划线组合。<br><br>设置完成后，输入docker exec -it kbox_x getevent可以查询设置的设备名称。<br> |
| 预期结果<br> | 设备名称设置成功，无报错提示。能够查询到所创建的设备并且名称正确。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.12 vinput设备事件发送与接收<a name="ZH-CN_TOPIC_0000002518186304"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.12<br> |
| 测试目的<br> | 验证vinput设备能够正常发送与接收事件。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用adb连接。<br> |
| 测试步骤<br> | 完成4.1.11-vinput设备创建相关设置后，打开另一个服务器端远程连接窗口B输入命令getevent侦听事件。在服务器远程连接窗口A使用命令docker exec -it kbox_x sh进入容器。输入命令getevent -p获取相应事件的“device”、“type”、“code”、“value”参数。在容器中使用命令sendevent [device] [type] [code] [value]发送事件。 说明： 其中x表示容器编号数字部分。<br><br><br> |
| 预期结果<br> | 窗口A发送事件无报错，窗口B可以成功侦听到事件。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.13 GPS Mock属性值修改<a name="ZH-CN_TOPIC_0000002518346228"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.13<br> |
| 测试目的<br> | 验证GPS Mock各属性的数值能够修改并查询。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建1路Kbox云手机容器，并连接。<br> |
| 测试步骤<br> | 在PC端CMD窗口连接容器后输入命令adb -s [ip:port] shell setprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed] xx分别修改GPS各属性的数值。 说明： 其中xx为各属性的合法值。ip:port（需替换为实际IP地址和端口号）为Kbox云手机的部署IP地址以及启动的容器对应的端口。<br><br>在PC端CMD窗口输入命令adb -s [ip:port] shell getprop persist.gps.mock.[accuracy/altitude/longitude/latitude/bearing/speed]查询GPS各属性的数值。<br> |
| 预期结果<br> | 无设置失败报错提示。能够查询到测试步骤1中设置的GPS各属性数值，且数值正确。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.14 传感器属性值设置<a name="ZH-CN_TOPIC_0000002549706079"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.14<br> |
| 测试目的<br> | 验证传感器Mock的x/y/z三轴属性值以及数据采集频率属性值能够修改。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用adb连接。<br> |
| 测试步骤<br> | 在PC端CMD窗口或服务器端输入命令adb -s [ip:port] shell setprop persist.sensors.mock.[acce/gyro].data.[x/y/z] xx（xx为±3.402823466e+38内任意值）修改传感器（acce表示加速度传感器，gyro表示陀螺仪传感器）的x/y/z三轴参数。打开sensors_test.apk查询传感器各属性的数值。在PC端CMD窗口或服务器端输入命令adb -s [ip:port] shell setprop persist.sensors.mock.delaytime xx（xx为[20000,1000000]任意值）设置传感器Mock中的数据采集频率属性值。再次执行步骤1与步骤2。观察修改数据采集频率之后所修改的传感器的属性值的变化时长。<br> |
| 预期结果<br> | 设置过程无报错。能够成功设置各参数。能够成功查询各参数。修改数据采集频率为不同的数值之后传感器的属性值变化的时长不同。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.15 Kbox组件版本号查询测试<a name="ZH-CN_TOPIC_0000002518346230"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.15<br> |
| 测试目的<br> | Kbox组件版本号查询测试。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用adb连接。<br> |
| 测试步骤<br> | 执行sudo docker exec -it kbox_x sh进入Kbox云手机容器，出现结果1。执行cat /vendor/etc/kbox_version.txt查询版本号内容，出现结果2。<br> |
| 预期结果<br> | 容器可以正常进入。文件内容包含Kbox组件版本信息如下，且版本信息准确。（具体版本号以当前版本为准。）Product Name: Kunpeng BoostKit<br>Product Version: xxx<br>Component Name: BoostKit-boostcph-kbox<br>Component Version: xxx<br>Component AppendInfo: 11.0.0_r48<br><br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.16 Kbox云手机硬解视频播放能力测试<a name="ZH-CN_TOPIC_0000002518346232"></a>

<a name="table60533823"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.16<br> |
| 测试目的<br> | Kbox云手机硬解视频播放能力测试。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用adb连接。Kbox云手机容器已安装Xplayer。<br> |
| 测试步骤<br> | 已按照特性指南的指导将Kbox云手机设置为使用NETINT T432/NETINT QUADRA T2A编解码卡的硬件解码器。容器导入264_1280x720_30fps/265_1280x720_30fps格式视频。使用Xplayer对导入视频进行完整播放，出现结果预期结果1。<br> |
| 预期结果<br> | 视频播放过程画面正常，不出现卡顿，未出现异常帧（如花屏、黑屏、绿屏等）画面现象，且日志能够查询到硬件解码器名称OMX.media.video.decoder。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.17 IMSI Mock测试<a name="ZH-CN_TOPIC_0000002549706081"></a>

<a name="table9347770"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.17<br> |
| 测试目的<br> | 验证IMSI Mock功能。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用ARDC连接显示云手机界面。<br> |
| 测试步骤<br> | 在云手机拨号界面输入“*#*#4636#*#*”，查询IMSI的值。PC终端窗口执行命令adb connect [ip:port]连接指定容器PC终端窗口执行命令adb -s [ip:port] shell setprop persist.sys.prop.writeimsi xx，重启kbox云手机，重新查询IMSI的值。 说明： 其中xx表示IMSI参数的合法数值。<br><br><br> |
| 预期结果<br> | 显示当前Kbox云手机容器预置的IMSI码默认初始值：46011+随机数字。服务端修改IMSI值后，再次查询显示为修改之后的IMSI值。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

#### 4.1.18 网络运营商信息、SIM卡信息查询测试<a name="ZH-CN_TOPIC_0000002518186308"></a>

<a name="table9347770"></a>

| 项目<br> | 内容<br> |
|---|---|
| 用例编号<br> | 4.1.18<br> |
| 测试目的<br> | 验证网络运营商信息、SIM卡信息查询功能。<br> |
| 测试组网<br> | 无<br> |
| 预置条件<br> | Kbox云手机基本环境已部署完成。已创建Kbox云手机容器，并使用ARDC连接显示云手机界面。Kbox云手机容器已安装zausan.zdevicetest.apk。<br> |
| 测试步骤<br> | 在服务端执行sudo docker exec -it kbox_x sh进入Kbox云手机容器。输入dumpsys isub | grep iccid查询SIM卡序列号，出现预期结果1。在客户端打开zausan.zdevicetest.apk中的SSM/UMTS。查看SIM operator/SIM operator name/SIM country/Network operator/Network operator name/Network country/Line one number，得到SIM卡运营商代码、SIM卡运营商名字、SIM卡运营商国家码、网络运营商代码、网络运营商名字、网络运营商国家码、手机号码，出现结果2。在PC端CMD窗口连接容器后输入命令adb -s [ip:port] shell setprop persist.[sys.prop.writesimserial/gsm.sim.operator.alphacph/sys.prop.writeimsi/gsm.operator.numericcph/gsm.operator.alphacph/gsm.operator.numericcph/sys.prop.writephonenum] xx分别修改各属性。 说明： 其中xx为各属性的合法值。ip:port（需替换为实际IP地址和端口号）为Kbox云手机的部署IP地址以及启动的容器对应的端口。<br><br>重启Kbox云手机，重新查询各数值，出现结果3。<br> |
| 预期结果<br> | 显示当前Kbox云手机容器预置的SIM卡序列号默认初始值：898600+随机数字。显示当前Kbox云手机容器预置的SIM卡运营商代码、SIM卡运营商名字、SIM卡运营商国家码、网络运营商代码、网络运营商名字和网络运营商国家码默认初始值分别为：46011/CMCC/cn/46000/CMCC/cn，手机号码默认初始值为空值。显示当前Kbox云手机容器修改后的值。<br> |
| 测试结果<br> |    |
| 备注<br> |    |

## 5 测试结果分析<a name="ZH-CN_TOPIC_0000002549826081"></a>

### 5.1 测试基本信息<a name="ZH-CN_TOPIC_0000002518346222"></a>

<a name="table56604068"></a>

| 设备制造商<br> | &nbsp;&nbsp; |
|---|---|
| 设备型号<br> | &nbsp;&nbsp; |
| 测试地点<br> | &nbsp;&nbsp; |
| 测试人员<br> | &nbsp;&nbsp; |
| 测试时间<br> | &nbsp;&nbsp; |
| 其余信息<br> | &nbsp;&nbsp; |

### 5.2 测试结果列表<a name="ZH-CN_TOPIC_0000002549826079"></a>

|测试类别|用例编号|用例名称|测试结果（PASS/FAIL/NT）|
|--|--|--|--|
|基本功能测试|4.1.1|创建Kbox云手机容器||
||4.1.2|重启Kbox云手机容器||
||4.1.3|删除Kbox云手机容器||
||4.1.4|Kbox云手机容器状态查询||
||4.1.5|Kbox云手机容器adb测试||
||4.1.6|资源隔离测试||
||4.1.7|GPS Mock测试||
||4.1.8|IMEI Mock测试||
||4.1.9|Wi-Fi Mock测试||
||4.1.10|传感器Mock测试||
||4.1.11|vinput设备创建||
||4.1.12|vinput设备事件发送与接收||
||4.1.13|GPS Mock属性值修改||
||4.1.14|传感器属性值设置||
||4.1.15|Kbox组件版本号查询测试||
||4.1.16|Kbox云手机硬解视频播放能力测试||
||4.1.17|IMSI Mock测试||
||4.1.18|网络运营商信息、SIM卡信息查询测试||

## 6 客户建议及结果确认<a name="ZH-CN_TOPIC_0000002549826075"></a>

### 6.1 客户建议<a name="ZH-CN_TOPIC_0000002549706083"></a>

### 6.2 结果确认<a name="ZH-CN_TOPIC_0000002549826073"></a>

|被测试方：华为技术有限公司|测试方：|
|--|--|
|测试人员签名：|测试人员签名：|
|时间：|时间：|
