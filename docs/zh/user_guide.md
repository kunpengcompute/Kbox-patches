# 用户指南

## 环境准备

### 硬件环境

| 配置项 | 硬件配置方案一 | 硬件配置方案二 |
| ---- | ---- | ---- |
| CPU  | 2*鲲鹏920 7280Z处理器，80核，2.9Ghz | 2*鲲鹏950 7592C处理器，96核，2.3Ghz |
| 内存 | 16*DDR5 DIMM内存-64GB-4800MT/s | 24*DDR5 DIMM内存-64GB-6400MT/s |
| 操作系统 | openEuler 24.03 LTS SP3 | openEuler 24.03 LTS SP3 |

### 软件环境

|序号|软件|说明|获取地址|
| ---- | ---- | ---- | ---- |
|1| redroid-14.0.0_r75_arm64_only-cubesandbox.tar | Redroid镜像 | 自行编译，编译指南(compile_guide.md)构建产物 |
|2| Kbox-patches-dev_AndroidSandbox.zip | Android代码补丁Demo包、编译脚本Demo包 | [获取链接](https://gitcode.com/boostkit/Kbox-patches.git)<br>分支：dev_AndroidSandbox|

## 获取Kbox软件包

获取Kbox CubeSandbox部署参考脚本

```bash
mkdir -p ~/dependency
cd ~/dependency
git clone https://gitcode.com/boostkit/Kbox-patches.git -b dev_AndroidSandbox
```

## 加载redroid镜像

### 加载镜像

```bash
docker load -i /path/to/redroid-14.0.0_r75_arm64_only-cubesandbox.tar

# 校验并记录镜像名（供后续步骤使用）
docker images | grep redroid
```

示例回显，记录镜像名称<a id="查询Redroid镜像名"></a>：

```bash
redroid  14.0.0_r75_arm64_only  c04246f72191  2 hours ago  1.63GB
```

### 注入GMS（可选）

加载镜像后，如果需要镜像包含GMS框架
可通过执行脚本`./inject_gms.sh`注入GMS。

修改脚本`inject_gms.sh`，配置`BASE_IMAGE`，`NEW_IMAGE`镜像名称。

```bash
cd ~/dependency/Kbox-patches/deploy/
vim inject_gms.sh
```

| 环境变量 | 作用 | 默认值 |
| --- | --- | --- |
| BASE_IMAGE | 输入镜像（不含GMS的镜像）名称。 | redroid:14.0.0_r75_arm64_only |
| NEW_IMAGE| 输出镜像（已注入GMS的镜像）名称。 | redroid:14.0.0_r75_arm64_only_gms |

执行脚本注入GMS。

```bash
./inject_gms.sh
```

完成章节沙箱启动，可通过以下命令判断GMS是否成功注入。

```bash
adb connect <sandbox_ip>:5555
adb -s <sandbox_ip:5555>  shell pm list packages | grep -E 'gms|vending|gsf'
# 期望输出：com.google.android.gms / com.android.vending / com.google.android.gsf
adb -s <sandbox_ip:5555> shell dumpsys package com.google.android.gsf | grep -i READ_DEVICE_CONFIG
# 期望 granted=true（由 privapp-permissions XML 在 boot 期授予）
```

### 启动本地Registry并推送

根据[查询的Redroid镜像名](#查询Redroid镜像名)，赋值环境变量：

```bash
REDROID_IMAGE=redroid:14.0.0_r75_arm64_only
```

创建模板时按 `--image` 全名拉取镜像，裸镜像名会解析到docker.io导致超时，因此需要本地registry：

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> `registry:2` 是Docker Hub上的镜像。若本机无法直连Docker Hub，需先配置镜像加速（在 `/etc/docker/daemon.json` 中追加 `"registry-mirrors": ["https://<mirror>"]` 后重启Docker）。校验连通性：`curl -sI https://<mirror>/v2/ | head -1`。

```bash
docker start cube-registry 2>/dev/null || docker run -d --name cube-registry --restart=always \
  -p 127.0.0.1:5000:5000 registry:2

REGISTRY_IMAGE=127.0.0.1:5000/${REDROID_IMAGE}
docker tag "${REDROID_IMAGE}" "${REGISTRY_IMAGE}"
docker push "${REGISTRY_IMAGE}"

# 校验
curl -s "http://127.0.0.1:5000/v2/$(echo "${REDROID_IMAGE}" | cut -d: -f1)/tags/list"
```

## 安卓沙箱基本操作

### 脚本简介：`redroid_operation.sh`

`redroid_operation.sh` 把模板、沙箱、快照的日常管理封装成一条命令，无需手工拼JSON请求文件或记忆 `cubemastercli` 的长参数：

```bash
cd ~/dependency/Kbox-patches/deploy
./redroid_operation.sh <命令> [参数]
```

模板与沙箱的创建参数**不在命令行传入**，统一放在配置文件 `redroid_config.conf`（随脚本同目录）中，详见[创建沙箱实例](#创建沙箱实例)章节。

### 创建沙箱实例<a id="创建沙箱实例"></a>

#### 从镜像创建模板

加载镜像后，把镜像全名如（`127.0.0.1:5000/redroid:14.0.0_r75_arm64_only`）填进配置文件`redroid_config.conf` 的 `TPL_IMAGE`。脚本默认使用配置文件的参数，执行创建模板命令，用`--alias`参数给模板命名：

```bash
./redroid_operation.sh template-create --alias <android-1> 
```

`--alias`为必填项，若该别名已存在会直接报错「模板已存在」，不会重复创建；成功后前台等待构建完成并打印 `TEMPLATE_ID`信息。通过`template-info`查询创建的模板信息：

```bash
./redroid_operation.sh template-info  <android-1>
```

#### 从模板创建沙箱实例

用`sandbox-create`命令创建沙箱，`--alias`为必填项，填入需要派生沙箱的模板，别名不存在会报错；`--count`填入要创建的沙箱个数，缺省默认创建一个沙箱；创建成功后输出沙箱ID等信息。

```bash
./redroid_operation.sh sandbox-create --alias <android-1> --count <沙箱数>  
```

也可以通过`sandbox-info`命令查询沙箱状态、IP、所属模板等信息。

```bash
./redroid_operation.sh sandbox-info <sandbox-id>     
```

可通过`sandbox-pause`对沙箱进行暂停操作，暂停后沙箱无CPU/内存占用，但状态完整保留。命令完成后回显沙箱详情，`state=paused` 即暂停完成，若为 `pausing` 稍候用 `sandbox-info` 复查。可通过`sandbox-connect`唤醒沙箱，此命令对`paused` 沙箱调用会自动唤醒，对 `running` 沙箱等同查询连接信息。

```bash
./redroid_operation.sh sandbox-pause <sandbox-id>
./redroid_operation.sh sandbox-connect <sandbox-id>
```

如需销毁沙箱，通过`sandbox-destroy`执行销毁操作，可填入多个沙箱ID实现批量删除。

```bash
./redroid_operation.sh sandbox-destroy <sandbox-id> [sandbox-id ...]   # 可一次多个
```

### 操作总览（速查表）

统一前缀：`./redroid_operation.sh <命令> [参数]`。方括号 `[ ]` 内为可选项；`...` 表示可重复。各命令的详细说明见4.3–4.5。

**模板操作**

| 脚本命令 | 用途 | 完整用法 | 实际调用路径 |
| ---- | ---- | -------- | ------------ |
| template-create | 从镜像创建模板（--alias必填，--image缺省用配置） | template-create --alias \<别名\> [--image \<镜像名\>] [--config \<文件\>] | cubemastercli template create-from-image |
| template-list | 列举模板 | template-list [--wide] | cubemastercli template list |
| template-info | 查询模板详情 | template-info \<tpl-id\> | cubemastercli template info |
| template-delete | 删除模板 | template-delete \<tpl-id\> | cubemastercli template delete |
| template-commit | 把运行中沙箱提交为新模板 | template-commit \<sandbox-id\> | cubemastercli template commit |

**沙箱操作**

| 脚本命令 | 用途 | 完整用法 | 实际调用路径 |
| ---- | ---- | -------- | ------------ |
| sandbox-create | 按模板别名创建沙箱（--alias与--snapshot二选一、必填） | sandbox-create --alias \<模板别名\> [--count \<沙箱数\>] [--runcc \<并行启动数\>] | cubemastercli multirun |
| sandbox-create | 从快照派生新沙箱 | sandbox-create --snapshot \<snap-id\> [--config \<文件\>] | cubemastercli multirun（同创建） |
| sandbox-list | 列举沙箱 | sandbox-list [--all] [--wide] [--with-ip] | cubemastercli ls |
| sandbox-info | 查询沙箱详情 | sandbox-info \<sandbox-id\> | cubemastercli info -s |
| sandbox-pause | 暂停沙箱（内存快照落盘，零占用） | sandbox-pause \<sandbox-id\> | POST /sandboxes/{id}/pause |
| sandbox-connect | 连接 / 唤醒已暂停沙箱，可设空闲超时 | sandbox-connect \<sandbox-id\> [--timeout \<秒\>\|-1] | POST /sandboxes/{id}/connect |
| sandbox-destroy | 销毁沙箱（可一次多个） | sandbox-destroy [sandbox-id ...] | cubemastercli cubebox destroy |

**快照操作**

| 脚本命令 | 用途 | 完整用法 | 实际调用路径 |
| ---- | ---- | -------- | ------------ |
| snapshot-create | 对运行中沙箱打快照（内存 + 文件系统） | snapshot-create \<sandbox-id\> [--name \<显示名\>] | POST /sandboxes/{id}/snapshots |
| snapshot-list | 列举快照 | snapshot-list [--sandbox \<sandbox-id\>] [--limit \<N\>] | GET /snapshots |
| snapshot-delete | 删除快照（需先解除沙箱运行时引用） | snapshot-delete \<snap-id\> | DELETE /templates/{snap-id} |
| sandbox-clone | 克隆：打快照 + 从快照派生N个沙箱 | sandbox-clone \<sandbox-id\> [--count \<N\>] [--runcc \<并行启动数\>] | 快照（CubeAPI）+ multirun派生N个 |
| sandbox-rollback | 把沙箱原地回滚到指定快照（ID不变） | sandbox-rollback \<sandbox-id\> \<snapshot-id\> | POST /sandboxes/{id}/rollback |

**其他**

| 脚本命令 | 用途 | 完整用法 |
| ---- | ---- | -------- |
| health | 检查CubeAPI健康状态 | health |
| --help / help | 显示完整帮助（含全部用法与示例） | --help |

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 所有命令都支持 `--config <文件>` 或环境变量 `REDROID_CONFIG` 指定配置文件（`health` 除外，仅当命令依赖配置文件时生效，如 `template-create` / `sandbox-create` / `sandbox-clone`）。

## 安卓沙箱投屏（Scrcpy）

沙箱IP（`10.100.x.x`）属部署机Cube内部网络，Windows本机无法直连。通过在Windows上建一条SSH本地端口转发隧道，把本机某端口映射到沙箱的adb端口5555，之后 `adb connect` 与 `scrcpy` 都走 `127.0.0.1` 即可。

前置条件：

- 部署机已运行sshd：`sudo systemctl enable --now sshd`
- Windows 10/11自带OpenSSH客户端（`ssh` 命令），无需额外安装

操作步骤：

1. **获取沙箱IP**（部署机上执行）：

   ```bash
   ./redroid_operation.sh sandbox-info <sandbox-id> 
   ```
   
   示例回显：
   
   ```bash
   ...
   SANDBOX_IP        10.100.0.195
   ...
   ```

2. **Windows端创建隧道**（PowerShell / CMD均可，该窗口需保持不关闭）：<a id="Windows建隧道"></a>

   ```bash
   ssh -p 3389 -L 5555:10.100.x.x:5555 <部署机用户>@<部署机IP>
   ```

   `-L 本机端口:沙箱IP:沙箱端口` 把本机5555端口转发到沙箱的5555；端口号可自选，避开本机已占用端口。按提示输入登录账号密码，创建成功后保持该窗口在后台运行。

3. **adb连接**（另开一个Windows窗口）：

   ```bash
   adb connect 127.0.0.1:5555
   ```

4. **scrcpy投屏**：

   用cmd窗口打开scrcpy文件路径，执行以下命令投屏

   ```bash
   scrcpy.exe -s 127.0.0.1:5555
   ```

   常用参数：

   - `--max-fps 30`：限制帧率，投屏更流畅
   - `--turn-screen-off`：投屏时关闭沙箱屏幕（不影响操作）
   - `--window-title "redroid-<别名>"`：同时投多台沙箱时区分窗口

## 硬件仿真设备参数配置

### 配置属性操作方式

在进行配置属性前，需要先连接容器、进入容器，然后进行相应的属性操作。

1. 正常启动沙箱，并确认沙箱的IP信息。
2. 在服务器侧，通过**adb**命令行连接沙箱实例。

    ```bash
    adb connect 10.100.x.x:5555
    ```

3. 通过**adb**命令行进入沙箱。

    ```bash
    adb -s 10.100.x.x:5555 shell
    ```

    进入容器后即可执行相应的云手机参数配置命令。

    >![](./public_sys-resources/icon-note.gif) **说明：**
    >
    >在本文档使用的**adb**命令中，10.100.x.x代指沙箱IP地址，请根据实际IP替换。

### 配置系统属性

#### 配置GPS系统属性

##### GPS属性说明

>![](./public_sys-resources/icon-note.gif) **说明：**
>
>对下表中的参数数据类型说明如下：
>
>- double类型参数有效值为15\~16位，若设置的数据有效值超过15\~16位，请采用科学计数法表示。由于double类型有效值位数限制，超出范围的数据会乱码。部分上层应用由于双精度浮点数类型转换，即使在有效数字范围内也存在精度浮动问题。
>- float类型参数有效值为6\~7位，若设置的数据有效值超过6\~7位，请采用科学计数法表示。由于float类型有效值位数限制，超出范围的数据会乱码。部分上层应用由于浮点数类型转换，在有效数字范围内也存在精度浮动问题。

|配置项名称|含义|类型|取值范围|默认值|说明|
|---|---|---|---|---|---|
|persist.gps.mock.latitude| 纬度 |double|纬度范围是[-90,90]度|30.188433度| 默认值为杭州的纬度。Android 11因为代码限制，经纬度不能同时设置为零 |
|persist.gps.mock.longitude| 经度 |double|经度范围是[-180,180]度|120.199818度| 初始值为杭州的经度。Android 11因为代码限制，经纬度不能同时设置为零 |
|persist.gps.mock.altitude| 海拔高度，单位：米 |double|无限制，正负皆可|0米| 初始值表示当前海拔高度为0米 |
|persist.gps.mock.speed| 表示当前的移动速度，单位：米每秒 |float|[0,400]米每秒|0米每秒| 初始值表示当前处于静止状态，超过400米每秒Android系统会停止上报GPS数据 |
|persist.gps.mock.bearing| 当前的移动导向角，单位：度 |float|范围[0,360)度|0度| 初始值表示正北方 |
|persist.gps.mock.accuracy| 表示当前的定位精度，单位：米 |float|大于等于0米|20米| 初始值表示定位误差为正负20米 |

##### 配置属性示例

1. 调用**setprop**方法设置当前属性的值，以gps.mock.latitude和gps.mock.longitude系统属性为例，其他属性设置方式相同。

    ```bash
    setprop persist.gps.mock.latitude 30.188433
    setprop persist.gps.mock.longitude 120.193818
    ```

2. 检查当前的GPS系统属性值。

    ```bash
    getprop | grep "persist.gps.mock."
    ```

    回显示例如下。

    ```bash
    [persist.gps.mock.latitude]: [30.188433]
    [persist.gps.mock.longitude]: [120.193818]
    ```

3. 重启AOSP系统gnss服务进程。

   ```bash
   setprop ctl.restart vendor.gnss_service
   ```

4. 查询Location Service的GPS数据，进入容器后使用如下命令查询最近更新的GPS数据。

    ```bash
    dumpsys location | grep "last location"
    ```

    根据返回值判断GPS属性是否生效。示例回显如下。

    ```bash
    last location=Location[gps 30.188433,120.199818 hAcc=20.0 et=+1d1h8m55s372ms alt=0.0 mslAlt=8.729687156853496 vel=0.0 bear=0.0 {Bundle[{satellites=6, maxCn0=33, meanCn0=23}]}]
    ```

    |返回帧参数项|含义|
    |--|--|
    |gps|位置信息，格式为：[纬度],[经度]|
    |hAcc|表示当前的定位误差，单位：米|
    |alt|海拔高度，单位：米|
    |bear|当前的移动导向角，单位：度|
    |vel|表示当前的移动速度，单位：米每秒|

5. 检查Location Service的GPS数据值与设定值是否一致。

#### 配置Telephony系统属性

##### Telephony属性说明

|配置项名称|含义|类型|取值范围|默认值|说明|
|---|---|---|---|---|---|
|persist.sys.prop.writeimei| 国际移动设备识别码（IMEI） |int|15~17位数字|86+15位随机值|86表示中国|
|persist.gsm.operator.alphacph| 网络运营商名字 |string|1~20位字母或数字|CMCC|-|
|persist.gsm.operator.numericcph| 网络运营商代码 |int|5~6位数字|46000| 由3位网络运营商国家代码+2~3位移动网络代码组成，比如460表示中国（cn），00表示中国移动 |
|persist.sys.prop.writeimsi| 国际移动用户识别码（IMSI） |int|15位数字|46011+随机值| 前5~6位表示SIM卡运营商代码，组成和网络运营商代码相同，460表示中国（cn），11表示中国移动 |
|persist.gsm.sim.operator.alphacph| SIM卡运营商名字 |string|1~20位字母或数字|CMCC|-|
|persist.sys.prop.writesimserial| SIM卡序列号 |int|20位数字|898600+随机值| 89为国际代码，86表示中国，00表示中国移动 |
|persist.sys.prop.writephonenum| 手机号码 |int|0~20位数字|空|-|

>![](./public_sys-resources/icon-note.gif) **说明：**
>
>- 所有属性设置后，需重启对应系统服务进程`zygote`或`modem_simulator-daemon`以生效，具体见下文详细步骤。
>- 设置参数时，会判断字符和长度是否合法，判断非法则采用默认值。

##### 配置属性示例

1. 调用**setprop**方法设置“IMEI”值。

    ```bash
    setprop persist.sys.prop.writeimei 861456987456321
    ```

    重启AOSP系统zygote服务进程
    
    ```bash
    setprop ctl.restart zygote
    ```
    
    拨号界面输入`*#06#`，显示IMEI值。

2. 调用**setprop**方法设置“网络运营商名字”和“网络运营商代码”。

    ```bash
    setprop persist.gsm.operator.alphacph CMCC
    setprop persist.gsm.operator.numericcph 46000
    ```

    重启AOSP系统modem_simulator服务进程
    
    ```bash
    setprop ctl.restart modem_simulator-daemon
    ```

    通过应用查询相关系统值，示例如下：
    
    ```bash
    Network operator name:      CMCC
    Network country:              cn
    Network operator:          46000
    ```

    >![](./public_sys-resources/icon-note.gif) **说明：**
    >
    >用户可自行查找相关应用进行验证。

3. 调用**setprop**方法设置“IMSI”和“SIM卡运营商名字”。

    ```bash
    setprop persist.sys.prop.writeimsi 460110123456789
    setprop persist.gsm.sim.operator.alphacph CMCC
    ```

    重启AOSP系统zygote服务进程
    
    ```bash
    setprop ctl.restart zygote
    ```
    
    拨号界面输入`*#*#4636#*#*`，打开手机信息，可以查询到“IMSI”，示例如下：

    ```bash
    IMSI: 460110123456789
    ```
    
    在应用中查询到“SIM卡运营商代码”，示例如下：

    ```bash
    SIM operator name:          CMCC
    SIM country:                  cn
    SIM operator:              46011
    ```
    
    >![](./public_sys-resources/icon-note.gif) **说明：**
    >
    >用户可自行查找相关应用进行验证。

4. 调用**setprop**方法设置“SIM卡序列号”。

    ```bash
    setprop persist.sys.prop.writesimserial 01234567890123456789
    ```

    重启AOSP系统zygote服务进程
    
    ```bash
    setprop ctl.restart zygote
    ```
    
    通过命令查询设置结果。

    ```bash
    dumpsys isub | grep iccid
    ```

    SIM卡序列号查询结果示例：
    
    ```bash
     [SubscriptionInfoInternal: id=x iccId=012345678[****] ...
    ```

    >![](./public_sys-resources/icon-note.gif) **说明：**
    >
    >1. 通过命令查询“SIM卡序列号”，部分位置会出现星号遮挡，为正常现象不影响实际功能。
    >2. 用户可自行查找相关应用进行验证。

5. 调用**setprop**方法设置“手机号码”。

    ```bash
    setprop persist.sys.prop.writephonenum 12345678901
    ```

    重启AOSP系统modem_simulator服务进程
    
    ```bash
    setprop ctl.restart modem_simulator-daemon
    ```
    
    在应用中查询设置结果，示例如下：

    ```bash
    Line one number:    +12345678901
    ```
    
    >![](./public_sys-resources/icon-note.gif) **说明：**
    >
    >用户可自行查找相关应用进行验证。

## Android World测试框架

### 部署测试框架

#### 安装依赖

安装系统依赖

```bash
dnf install -y python3 git curl unzip gcc gcc-c++ make ffmpeg
```

安装adb

#### 拉取android_world和android_env代码

拉取android_world源码。

```bash
cd ~/dependency
mkdir -p aw_workspace && cd aw_workspace

# 拉取android_world官方仓库
git clone https://github.com/google-research/android_world.git android_world
cd android_world
git checkout 55ddaf5edc6f6c25673aed343907d5b9dca66f84
```

拉取android_env源码。

```bash
cd ~/dependency/aw_workspace

# 拉取android_env官方PyPI包
pip download android_env==1.2.3 --no-deps -d /tmp/aedl

python3.11 - <<'PY'
import zipfile
zipfile.ZipFile('/tmp/aedl/android_env-1.2.3-py3-none-any.whl').extractall(
    '/tmp/android_env')
PY

rm -rf /tmp/android_env/android_env-1.2.3.dist-info
mv /tmp/android_env ~/dependency/aw_workspace

# 原 wheel 不含 pyproject.toml，补一个最小的，使其可被 pip install -e 安装：
cat > ~/dependency/aw_workspace/android_env/pyproject.toml <<'TOML'
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[project]
name = "android-env"
version = "1.2.3"
dependencies = ["absl-py", "dm-env", "numpy", "Pillow"]
TOML

cd ~/dependency/aw_workspace/android_env && git init -q && git add -A \
  && git commit -qm 'baseline: android_env 1.2.3 (PyPI wheel)'
```

#### 合入Kbox补丁

合入android_world Kbox补丁。

```bash
cd ~/dependency/aw_workspace/android_world
KBOX_AW_PATCHES_PATH="$HOME/dependency/Kbox-patches/patchForAW/android_world/"
for p in $(ls -1 $KBOX_AW_PATCHES_PATH/*.patch | sort); do
  git apply --check "$p" && git apply "$p" && echo "ok $f"
done
```

合入android_env Kbox补丁。

```bash
cd ~/dependency/aw_workspace/android_env
KBOX_AE_PATCHES_PATH="$HOME/dependency/Kbox-patches/patchForAW/android_env/"
for p in $(ls -1 $KBOX_AE_PATCHES_PATH/*.patch | sort); do
  git apply --check "$p" && git apply "$p" && echo "ok $f"
done
```

#### 创建并配置venv虚拟环境

创建venv虚拟环境，用于后续运行Android World。

```bash
cd ~/dependency/aw_workspace/android_world
/usr/bin/python3.11 -m venv .venv 
M="-i https://pypi.tuna.tsinghua.edu.cn/simple"

# 1) 安装依赖（此步会先拉一份 PyPI 的干净 android_env，下一步覆盖掉）
.venv/bin/pip install -r requirements.txt $M

# 2) 用合入过patches的源码树覆盖 android_env（关键一步）
.venv/bin/pip install -e ~/dependency/aw_workspace/android_env --no-deps $M

# 3) 链接android_world 本体
.venv/bin/pip install -e . --no-deps $M

# 4) 官方 opencv-python 依赖系统图形库（libGL），宿主机没有，换 headless；
#    headless 新版会把 numpy 升到 2.x，与官方锁定的 1.26 冲突，将版本一并固定住。
.venv/bin/pip uninstall -y opencv-python
.venv/bin/pip install "opencv-python-headless==4.10.0.84" "numpy==1.26.3" $M

# 5) 生成 protobuf 代码
.venv/bin/python setup.py generate_protos
```

自检：

```bash
# 必须指向补丁树，而不是 PyPI 的干净版本
.venv/bin/python -c "import android_env; print(android_env.__file__)"
# 期望：~/dependency/aw_workspace/android_env/android_env/__init__.py

.venv/bin/python -c "import android_world, cv2, numpy; print('OK', cv2.__version__, numpy.__version__)"
# 期望：OK 4.10.0 1.26.3

ls android_world/task_evals/information_retrieval/proto/*_pb2.py
# 期望：state_pb2.py  task_pb2.py

.venv/bin/python -c "import redroid.env_factory, redroid.run_task; print('env stack ok')"
```

### 执行测试

#### 安装测试APP

支持以下多种指令：

```bash
export AW_ADB_SERIAL=10.100.x.x:5555
adb connect $AW_ADB_SERIAL

.venv/bin/python -m redroid.setup_apps --list                    # 查看可装 App
.venv/bin/python -m redroid.setup_apps --apps markor vlc         # 按需安装
.venv/bin/python -m redroid.setup_apps                           # 安装全量 24个App（下载量大，时间较长）
```

执行指令时需指定沙箱IP，可以使用以下任一方式指定：

```bash
export AW_ADB_SERIAL=10.100.x.x:5555
.venv/bin/python -m redroid.setup_apps
```

或

```bash
.venv/bin/python -m redroid.setup_apps --serial 10.100.x.x:5555
```

其中10.100.x.x代指沙箱的IP，请根据实际值替换。

指令执行完成后，会打印执行结果，正确回显示例如下：<a id="Andoird_World_APP安装结果"></a>

```bash
[汇总] App 安装状态:
  android world            OK
  audio recorder           OK
  camera                   系统预装
  chrome                   系统预装
...
  tasks                    OK
  vlc                      OK

[完成] 全部成功.
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
>- 使用`userdebug`镜像：APP快照功能依赖root权限，因此需使用`userdebug`镜像；`user`镜像由于缺少root权限，则不支持该功能
>- APP安装过程中可能打印报错日志，其会自动运行备选方案，因此不一定影响最终安装效果。安装结果请参考[最终结果汇总回显](#Andoird_World_APP安装结果)。

#### 运行测试用例

执行用例测试前，先设置测试运行的沙箱IP

```bash
export AW_ADB_SERIAL=<SANDBOX_IP>:5555
```

支持以下指令，使用`--task`选项指定执行的测试用例：

- **查看全部用例名（90+）：**

  使用`--list`选项

  ```bash
  .venv/bin/python -m redroid.run_task --list
  ```

- **人工操作执行用例：**

  使用`--agent=human`选项指定。打印用例目标后，用户自行投屏操作沙箱，回车后调用Android World官方判定

  ```bash
  .venv/bin/python -m redroid.run_task --task=CameraTakePhoto --agent=human
  ```

- **random冒烟测试：**

  验证"截图→随机动作→判定"全链路，用例极大概率会FAIL，属正常现象

  ```bash
  .venv/bin/python -m redroid.run_task --task=SystemWifiTurnOnVerify --agent=random --max_steps=1
  ```

- **大模型（OpenAI兼容LLM）agent执行用例：**

  `--agent`选项可指定`t3a`或`m3a`，分别对应纯文本agent和多模态agent。

  以下3个变量`AW_LLM_API_KEY`、`AW_LLM_BASE_URL`、`AW_LLM_MODEL`必须配置。

  ```bash
  export AW_LLM_API_KEY=sk-xxxxxxxx
  export AW_LLM_BASE_URL=https://api.example.com/v1
  export AW_LLM_MODEL=example-model
  .venv/bin/python -m redroid.run_task --task=SystemWifiTurnOn --agent=t3a
  ```
  
  | 变量名 | 含义 | 是否必填 | 示例值 |
  | -- | -- | -- | -- |
  | AW_LLM_API_KEY | LLM服务的鉴权密钥 | **必填** | sk-xxxxxxxx |
  | AW_LLM_BASE_URL | OpenAI兼容端点的根地址，不含/chat/completions | **必填** | httpx://api.example.com/v1 |
  | AW_LLM_MODEL | 指定调用的模型名，以LLM服务实际支持的模型为准 | **必填** | example-model |
  | AW_LLM_EFFORT | 推理档位，用来控制推理深度/成本/时延<br>可选值包括：low / high / max，具体以端点支持为准。 | 可选 | high |
