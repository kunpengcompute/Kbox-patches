# CubeSandbox + Redroid 14 自动化构建说明

本文档说明如何从零准备 redroid 工作区，并一键编译 **envd 二进制** 与 **redroid 14 arm64-only Docker 镜像**。

## 1. 环境准备

### 1.1 硬件环境

redroid 镜像编译仅支持在 x86\_64 服务器下进行（交叉编译 arm64 目标）。

| 项    | 要求                                            |
| ---- | --------------------------------------------- |
| 编译机  | x86\_64 Linux，≥ 16 核 / ≥ 64GB 内存 / ≥ 200GB 磁盘 |
| 操作系统 | Ubuntu 22.04 LTS（推荐）                          |

### 1.2 软件环境

| 项          | 要求                                                 |
| ---------- | -------------------------------------------------- |
| Go         | ≥ 1.21（脚本用 `GOTOOLCHAIN=auto` 自动下载 envd 所需 1.26.x） |
| Docker     | 已安装，打包步骤需 root（loop 挂载镜像）                          |
| repo / git | 已安装，用于拉取 AOSP 源码                                   |
| git-lfs    | 已安装，用于同步 WebView 预编译包                              |

### 1.3 安装编译依赖包

编译AOSP前需安装官方依赖。以 Ubuntu 22.04 为例：

```bash
sudo apt update
sudo apt-get install -y git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev \
  libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip \
  fontconfig python3 python-is-python3
sudo apt-get install -y git-lfs && git lfs install
```

> **说明：** 依赖包清单以 AOSP 官方文档为准，如遇缺失可参考 [AOSP 官方构建要求](https://source.android.com/docs/setup/start/initializing) 补充。

## 2. 拉取源码

### 2.1 拉取 AOSP 14.0.0\_r75 源码

```bash
mkdir -p redroid-workspace && cd redroid-workspace
mkdir aosp-14 && cd aosp-14

# repo 工具与 AOSP manifest 均指向清华镜像
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'
repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest \
  -b android-14.0.0_r75
repo sync -c -j"$(nproc)"
```

### 2.2 同步 redroid 专属仓库

```bash
cd aosp-14

git clone https://github.com/remote-android/local_manifests.git \
  .repo/local_manifests -b 14.0.0
# 国内中转备选：
# git clone https://gh-proxy.org/https://github.com/remote-android/local_manifests.git \
#   .repo/local_manifests -b 14.0.0

repo sync -c -j"$(nproc)" \
  device/redroid \
  device/redroid-prebuilts \
  hardware/redroid/c2 \
  hardware/redroid/omx \
  vendor/redroid
```

> **说明：** 先同步专属仓库、再合入增量patch（第3步），可避免后续`repo sync`覆盖`device/redroid`、`vendor/redroid`的本地修改。

### 2.3 同步 WebView（git-lfs）

```bash
cd aosp-14
repo sync --force-sync -c external/chromium-webview
repo sync -c -j"$(nproc)" \
  external/chromium-webview/prebuilt/arm \
  external/chromium-webview/prebuilt/arm64 \
  external/chromium-webview/prebuilt/x86 \
  external/chromium-webview/prebuilt/x86_64
```

### 2.4 拉取 runtime（envd 源码）

```bash
cd redroid-workspace
git clone --depth=1 https://github.com/e2b-dev/runtime.git
# 国内中转备选：
# git clone --depth=1 https://gh-proxy.org/https://github.com/e2b-dev/runtime.git
```

<br />

## 3. 合入 patch

### 3.1 获取 redroid 官方 patch

```bash
cd redroid-workspace
git clone https://github.com/remote-android/redroid-patches.git
# 国内中转备选：
# git clone https://gh-proxy.org/https://github.com/remote-android/redroid-patches.git
```

### 3.2 合入 redroid 官方 patch（形成默认基线）

```bash
./redroid-patches/apply-patch.sh aosp-14 android-14.0.0_r75
```

> **说明：** 该脚本遍历`redroid-patches/android-14.0.0_r75/`下各子目录，对每个git仓执行`git am`，输出出现`[ERROR]`需排查。redroid官方patch仅作用于AOSP核心仓（frameworks/av、system/core等），不涉及redroid专属仓。

完成本步骤后，`aosp-14`达到**redroid默认基线**（不含Kbox-patches增量修改），可直接编译出官方redroid镜像。

### 3.3 验证默认基线（可选）

```bash
cd aosp-14
source build/envsetup.sh
lunch redroid_arm64_only-trunk_staging-userdebug
make -j"$(nproc)"
```

产物：`out/target/product/redroid_arm64_only/{system.img,vendor.img}`

> **说明：** 若基线编译失败，应先排查AOSP/redroid官方环节，再进入增量修改，避免把官方问题混入自定义patch排查。

## 4. 注入GMS

GMS(Google Mobile Services)为闭源组件，AOSP(Android Open Source Project)镜像不含它，Google应用启动即闪退。`build/pack_gms.sh` 统一维护 GMS 的下载源。

### 4.1 脚本用法

```bash
cd redroid-workspace/Kbox-patches/build

bash pack_gms.sh fetch     # 下载/校验/还原GMS包（幂等，无需 sudo，可提前单独执行）
bash pack_gms.sh tar-args  # 输出镜像注入参数（供 build_redroid.sh 拼入 rootfs tar 流）
```

- `fetch`：从GitHub下载官方zip（约430MB，sha256校验，缓存于`<工作区>/downloads/`，直连失败自动切换gh-proxy.com等公共镜像），解出5个GMS成员还原到仓库外`<工作区>/gms-payload/`（fetch时自动创建目录）；
- `tar-args`：向stdout输出`-GMS包根路径`+5个成员路径，由`build_redroid.sh pack`在tar拼接时读入。

日常构建**无需手动运行**：`sudo bash build_redroid.sh pack`会在打包前自动`fetch`补齐、打包时自动`tar-args`注入镜像，产出自带GMS的Docker镜像。

### 4.2 可选配置

| 环境变量 | 作用 |
| --- | --- |
| `GMS_SKIP=1` | 跳过 GMS 下载与注入，产出无 GMS 基础镜像 |
| `GMS_ZIP_URL=<地址>` | 覆盖 zip 下载地址（自建代理/镜像），内容仍以 sha256 校验兜底 |
| `GMS_ZIP_CACHE=<目录>` | 覆盖 zip 缓存目录（默认 `<工作区>/downloads`） |

更新GMS版本：修改`pack_gms.sh`内`ZIP_URL`/`ZIP_SHA256`/`MANIFEST`清单后重跑`sudo bash build_redroid.sh pack`即可，无需重新编译。

> **注意：** 目录中的白名单XML必须与对应APK同分区，缺失则user版开机权限校验失败、容器无法boot；**不要**替换为完整GApps——多余组件（SetupWizard等）会触发APEX冲突导致无法boot。

镜像`docker load`并起沙箱后验证：

```bash
adb connect <sandbox_ip>:5555
adb shell pm list packages | grep -E 'gms|vending|gsf'
# 期望输出：com.google.android.gms / com.android.vending / com.google.android.gsf
adb shell dumpsys package com.google.android.gsf | grep -i READ_DEVICE_CONFIG
# 期望 granted=true（由 privapp-permissions XML 在 boot 期授予）
```

## 5. 执行 build_redroid.sh

### 5.1 脚本用法

```bash
cd redroid-workspace/Kbox-patches/build

sudo bash build_redroid.sh all        # 一键全量（envd → patch → 编译 → 打包，pack 前自动下载 GMS）
bash build_redroid.sh envd            # 仅编译 envd 二进制
bash build_redroid.sh patch           # 仅合入 Kbox-patches 增量 patch
bash build_redroid.sh gms             # 仅下载/还原GMS的APK（pack 时也会自动执行）
bash build_redroid.sh redroid         # 仅编译 AOSP 镜像
sudo bash build_redroid.sh pack       # 仅打包 Docker 镜像
```

### 5.2 一键构建

```bash
cd redroid-workspace/Kbox-patches/build
sudo bash build_redroid.sh all
```

> **说明：** `all` 依次执行：编译envd二进制→合入Kbox-patches增量patch → lunch/make → 打包Docker镜像（打包前自动下载/还原GMS）。打包步骤需 root，故整体用 `sudo`。

### 5.3 分步构建

```bash
cd redroid-workspace/Kbox-patches/build
bash build_redroid.sh envd            # 1) 编译 envd 二进制
bash build_redroid.sh patch           # 2) 合入 Kbox-patches 增量 patch
bash build_redroid.sh gms             # 3) 下载/还原 GMS（转发 pack_gms.sh fetch，pack 时自动执行，可省略）
bash build_redroid.sh redroid         # 4) 编译 AOSP 镜像
sudo bash build_redroid.sh pack       # 5) 打包 Docker 镜像
```

### 5.4 产物与注意事项

最终产物：`aosp-14/redroid-14.0.0_r75_arm64_only-docker.tar`（约 1.6GB）

> **说明：**
>
> - **patch幂等性**：脚本假设在“干净”源码树上应用patch。若`aosp-14`已应用过这些patch，重复执行`build_redroid.sh patch`会因`git apply` 失败而中止，需先还原源码树或跳过 patch 步骤。
> - **Go 版本**：`runtime`的envd `go.mod`要求go 1.26.x，脚本用`GOTOOLCHAIN=auto`自动下载，但要求基础go ≥ 1.21。
> - **网络代理**：envd编译会`go mod download`，需可用`GOPROXY`（脚本默认`goproxy.cn`）。
> - **编译时长**：`make`全量编译约2~3小时（取决于核数），产物占用100GB+磁盘。
> - **打包验证**：`vendor/bin/envd`缺失时打包失败——确认已执行envd编译且 `vendor-redroid-0002` patch 已应用。
