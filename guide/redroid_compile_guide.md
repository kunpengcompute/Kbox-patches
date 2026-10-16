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

编译 AOSP 前需安装官方依赖。以 Ubuntu 22.04 为例：

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

> **说明：** 先同步专属仓库、再合入增量 patch（第 3 步），可避免后续 `repo sync` 覆盖 `device/redroid`、`vendor/redroid` 的本地修改。

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

> **说明：** 该脚本遍历 `redroid-patches/android-14.0.0_r75/` 下各子目录，对每个 git 仓执行 `git am`，输出出现 `[ERROR]` 需排查。redroid 官方 patch 仅作用于 AOSP 核心仓（frameworks/av、system/core 等），不涉及 redroid 专属仓。

完成本步骤后，`aosp-14` 达到 **redroid 默认基线**（不含 Kbox-patches 增量修改），可直接编译出官方 redroid 镜像。

### 3.3 验证默认基线（可选）

```bash
cd aosp-14
source build/envsetup.sh
lunch redroid_arm64_only-trunk_staging-userdebug
make -j"$(nproc)"
```

产物：`out/target/product/redroid_arm64_only/{system.img,vendor.img}`

> **说明：** 若基线编译失败，应先排查 AOSP / redroid 官方环节，再进入增量修改，避免把官方问题混入自定义 patch 排查。

## 4. 执行 build.sh

### 4.1 脚本用法

```bash
cd redroid-workspace/Kbox-patches/build

sudo bash build.sh all        # 一键全量（envd → patch → 编译 → 打包，pack 前自动下载 GMS 载荷）
bash build.sh envd            # 仅编译 envd 二进制
bash build.sh patch           # 仅合入 Kbox-patches 增量 patch
bash build.sh gms             # 仅下载/还原 GMS 载荷 APK（pack 时也会自动执行）
bash build.sh redroid         # 仅编译 AOSP 镜像
sudo bash build.sh pack       # 仅打包 Docker 镜像
```

### 4.2 一键构建

```bash
cd redroid-workspace/Kbox-patches/build
sudo bash build.sh all
```

> **说明：** `all` 依次执行：编译 envd 二进制 → 合入 Kbox-patches 增量 patch → lunch/make → 打包 Docker 镜像（打包前自动下载/还原 GMS 载荷）。打包步骤需 root，故整体用 `sudo`。

### 4.3 分步构建

```bash
cd redroid-workspace/Kbox-patches/build
bash build.sh envd            # 1) 编译 envd 二进制
bash build.sh patch           # 2) 合入 Kbox-patches 增量 patch
bash build.sh gms             # 3) 下载/还原 GMS 载荷（pack 前会自动执行，可省略）
bash build.sh redroid         # 4) 编译 AOSP 镜像
sudo bash build.sh pack       # 5) 打包 Docker 镜像
```

### 4.4 产物与注意事项

最终产物：`aosp-14/redroid-14.0.0_r75_arm64_only-docker.tar`（约 1.6GB）

> **说明：**
>
> - **patch 幂等性**：脚本假设在“干净”源码树上应用 patch。若 `aosp-14` 已应用过这些 patch，重复执行 `build.sh patch` 会因 `git apply` 失败而中止，需先还原源码树或跳过 patch 步骤。
> - **Go 版本**：`runtime` 的 envd `go.mod` 要求 go 1.26.x，脚本用 `GOTOOLCHAIN=auto` 自动下载，但要求基础 go ≥ 1.21。
> - **网络代理**：envd 编译会 `go mod download`，需可用 `GOPROXY`（脚本默认 `goproxy.cn`）。
> - **编译时长**：`make` 全量编译约 2~3 小时（取决于核数），产物占用 100GB+ 磁盘。
> - **打包验证**：`vendor/bin/envd` 缺失时打包失败——确认已执行 envd 编译且 `vendor-redroid-0002` patch 已应用。
> - **构建变体与 adb**：`userdebug` 变体默认启动 adbd，`adb connect <沙箱IP>:5555` 开箱可用；`user` 变体不会启动 adbd（缺少 `persist.sys.usb.config=adb` 且 `ro.adb.secure=1`）。如需在 `user` 变体上使用 adb，见 [redroid_user_build_adb_fix.md](redroid_user_build_adb_fix.md)。
> - **FLAG_SECURE 全局禁用（Zoom 登录黑屏修复）**：`frameworks/base/frameworks-base-0002-wm-secure-flag.patch` 将 `WindowState.setSecureLocked()` 改为空实现（SECURE 标志不再写入 SurfaceControl 事务）、`isSecureLocked()` 恒返回 `false`。修复容器内 SECURE surface 合成输出黑屏（Zoom 登录页现象），随 `build.sh patch` 自动合入，无需镜像后处理。注意这是全局开关：所有 App 的 FLAG_SECURE 防截屏保护均失效。
> - **内置 GMS（YouTube 等 Google 应用闪退修复）**：`pack` 阶段自动按 `patchForRedroid/prebuilts/gms/` 下的 `.apk.url` 描述下载 GMS 载荷并叠加进镜像，产物镜像自带 GMS 三件套，见第 5 节。

## 5. 内置 GMS 载荷（解决 YouTube 等 Google 应用闪退）

沙箱镜像默认不含 GMS（Google Mobile Services），YouTube 等 Google 应用启动即闪退（缺少 `com.google.android.gms` 依赖）。为让 `build.sh` 产物开箱带 GMS，采用 **prebuilt 载荷** 方案而非源码 patch。**APK 二进制不入库**（gitcode 仓库不允许托管 APK），仅入库下载源描述文件，构建时自动下载还原。

### 5.1 载荷位置与内容

```text
Kbox-patches/patchForRedroid/prebuilts/gms/system/
├── product/
│   ├── priv-app/
│   │   ├── GmsCore/GmsCore.apk.url                              # Google Play services（142MB）下载源描述
│   │   └── Phonesky/Phonesky.apk.url                            # Google Play Store（71MB）下载源描述
│   └── etc/permissions/
│       └── privapp-permissions-google-product.xml               # product 分区 priv-app 权限白名单
└── system_ext/
    ├── priv-app/
    │   └── GoogleServicesFramework/GoogleServicesFramework.apk.url # GSF（5.7MB）下载源描述
    └── etc/permissions/
        └── privapp-permissions-google-system-ext.xml            # system_ext 分区权限白名单
```

来源：MindTheGapps 14.0.0 arm64 官方 GitHub Release（`MindTheGapps-14.0.0-arm64-20250203_200051.zip`，主页 https://mindthegapps.com/ ，仓库 https://github.com/MindTheGapps/14.0.0-arm64 ），裁剪只取核心三件套（共约 210MB）。**不要**把完整 GApps 拷入——多余组件（SetupWizard、CarrierConfig 等）会触发 APEX 元数据冲突，导致容器无法 boot。

每个 `.apk.url` 描述文件包含四项校验信息：`zip_url`（官方下载地址）、`zip_sha256`（整包校验）、`zip_path`（zip 内路径，与载荷目录相对路径一致）、`apk_sha256`（单个 APK 校验）。构建时 `build.sh gms` 步骤按描述下载 zip（缓存于工作区 `downloads/`，断点续传，自动尝试 GitHub 直连与 gh-proxy.com 等公共镜像，亦可用 `GMS_ZIP_URL` 环境变量覆盖），解出三个 APK 还原到原位置并逐个 sha256 校验。

> **为何不是 `.patch` 文件、APK 也不入库**：GMS 是 Google 签名的二进制 APK（单文件最大 142MB），`git apply` 文本 patch 无法承载；且 gitcode 仓库规范不允许托管 APK 二进制。故仅入库轻量 `.apk.url` 下载源描述，由构建脚本在 `gms`/`pack` 阶段下载还原并叠加进镜像，效果等价于"构建期就完成了 docker cp 注入"。

### 5.2 工作机制

`build.sh pack` 在 tar 打包镜像时，把载荷目录作为附加 `-C` 根拼接成员（详见 build.sh `pack_image()`）：

- 载荷成员路径带 `system/` 前缀，与镜像内 `/product -> /system/product`、`/system_ext -> /system/system_ext` 符号链接布局一致，文件落在对应分区的真实路径上；
- 只显式列举**新增目录与新增文件**的叶子成员，避免与 system.img 已有目录条目重复（`docker import` 拒绝重复路径）；
- tar 加 `--owner=0 --group=0` 把载荷 owner 固化为 root:root，与 system 分区标准布局一致，不依赖构建机 checkout 用户。

之所以必须镜像层预置而不能运行时安装：PMS 只在 boot 阶段扫描 `/product/priv-app`、`/system_ext/priv-app`，并依据 `privapp-permissions-google-*.xml` 授予 signature|privileged 权限——运行时 `pm install` 无法装进 priv-app 分区，`pm grant` 无法授予 privapp 权限。

### 5.3 下载与降级行为

`pack` 打包前自动执行 GMS 下载步骤（也可单独运行 `bash build.sh gms` 提前下载，无需 sudo）：

- 三个 APK 已就位且 sha256 校验通过 → 跳过下载；
- 有缺失 → 按 `.apk.url` 描述下载 zip 到工作区 `downloads/` 缓存（下次复用），依次尝试 `GMS_ZIP_URL` 环境变量覆盖 → GitHub 直连 → gh-proxy.com / hub.gitmirror.com / ghfast.top 公共镜像，全部内容以 sha256 校验兜底；
- 下载失败 → 构建终止并提示（可 `export GMS_ZIP_URL=<可用地址>` 重试，或手动下载 zip 放到 `downloads/`）；
- 极端情况下 `.url` 描述文件也缺失时，`pack` 自动跳过叠加，产出**无 GMS 基础镜像**，构建不失败。判据为 `system/product/priv-app/GmsCore/GmsCore.apk` 是否存在。

### 5.4 更新 GMS 版本

更新三个 `.apk.url` 描述文件中的 `zip_url`/`zip_sha256`/`zip_path`/`apk_sha256`（或临时 `export GMS_ZIP_URL=<新包地址>` 覆盖）后，**只需重跑打包**，无需重新编译 AOSP（可省 2~3 小时的 make）：

```bash
sudo bash build.sh pack
```

### 5.5 仓库体积与规范

APK 二进制（约 210MB）不入库，仓库中仅保存轻量 `.apk.url` 下载源描述文件。构建期下载还原到载荷目录的 APK 为本地构建产物，已由 `.gitignore`（`patchForRedroid/prebuilts/gms/**/*.apk`）忽略，不会误提交。

### 5.6 验证

镜像 `docker load` 后按 user_guide.md §5 制作模板并起沙箱，然后：

```bash
adb connect <sandbox_ip>:5555
adb shell pm list packages | grep -E 'gms|vending|gsf'
# 期望输出：com.google.android.gms / com.android.vending / com.google.android.gsf
adb shell dumpsys package com.google.android.gsf | grep -i READ_DEVICE_CONFIG
# 期望 granted=true（由 privapp-permissions XML 在 boot 期授予）
```

打开 YouTube 应正常驻留前台、不闪退。
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

编译 AOSP 前需安装官方依赖。以 Ubuntu 22.04 为例：

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

> **说明：** 先同步专属仓库、再合入增量 patch（第 3 步），可避免后续 `repo sync` 覆盖 `device/redroid`、`vendor/redroid` 的本地修改。

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

> **说明：** 该脚本遍历 `redroid-patches/android-14.0.0_r75/` 下各子目录，对每个 git 仓执行 `git am`，输出出现 `[ERROR]` 需排查。redroid 官方 patch 仅作用于 AOSP 核心仓（frameworks/av、system/core 等），不涉及 redroid 专属仓。

完成本步骤后，`aosp-14` 达到 **redroid 默认基线**（不含 Kbox-patches 增量修改），可直接编译出官方 redroid 镜像。

### 3.3 验证默认基线（可选）

```bash
cd aosp-14
source build/envsetup.sh
lunch redroid_arm64_only-trunk_staging-userdebug
make -j"$(nproc)"
```

产物：`out/target/product/redroid_arm64_only/{system.img,vendor.img}`

> **说明：** 若基线编译失败，应先排查 AOSP / redroid 官方环节，再进入增量修改，避免把官方问题混入自定义 patch 排查。

## 4. 执行 build.sh

### 4.1 脚本用法

```bash
cd redroid-workspace/Kbox-patches/build

sudo bash build.sh all        # 一键全量（envd → patch → 编译 → 打包，pack 前自动下载 GMS 载荷）
bash build.sh envd            # 仅编译 envd 二进制
bash build.sh patch           # 仅合入 Kbox-patches 增量 patch
bash build.sh gms             # 仅下载/还原 GMS 载荷 APK（pack 时也会自动执行）
bash build.sh redroid         # 仅编译 AOSP 镜像
sudo bash build.sh pack       # 仅打包 Docker 镜像
```

### 4.2 一键构建

```bash
cd redroid-workspace/Kbox-patches/build
sudo bash build.sh all
```

> **说明：** `all` 依次执行：编译 envd 二进制 → 合入 Kbox-patches 增量 patch → lunch/make → 打包 Docker 镜像（打包前自动下载/还原 GMS 载荷）。打包步骤需 root，故整体用 `sudo`。

### 4.3 分步构建

```bash
cd redroid-workspace/Kbox-patches/build
bash build.sh envd            # 1) 编译 envd 二进制
bash build.sh patch           # 2) 合入 Kbox-patches 增量 patch
bash build.sh gms             # 3) 下载/还原 GMS 载荷（pack 前会自动执行，可省略）
bash build.sh redroid         # 4) 编译 AOSP 镜像
sudo bash build.sh pack       # 5) 打包 Docker 镜像
```

### 4.4 产物与注意事项

最终产物：`aosp-14/redroid-14.0.0_r75_arm64_only-docker.tar`（约 1.6GB）

> **说明：**
>
> - **patch 幂等性**：脚本假设在“干净”源码树上应用 patch。若 `aosp-14` 已应用过这些 patch，重复执行 `build.sh patch` 会因 `git apply` 失败而中止，需先还原源码树或跳过 patch 步骤。
> - **Go 版本**：`runtime` 的 envd `go.mod` 要求 go 1.26.x，脚本用 `GOTOOLCHAIN=auto` 自动下载，但要求基础 go ≥ 1.21。
> - **网络代理**：envd 编译会 `go mod download`，需可用 `GOPROXY`（脚本默认 `goproxy.cn`）。
> - **编译时长**：`make` 全量编译约 2~3 小时（取决于核数），产物占用 100GB+ 磁盘。
> - **打包验证**：`vendor/bin/envd` 缺失时打包失败——确认已执行 envd 编译且 `vendor-redroid-0002` patch 已应用。
> - **构建变体与 adb**：`userdebug` 变体默认启动 adbd，`adb connect <沙箱IP>:5555` 开箱可用；`user` 变体不会启动 adbd（缺少 `persist.sys.usb.config=adb` 且 `ro.adb.secure=1`）。如需在 `user` 变体上使用 adb，见 [redroid_user_build_adb_fix.md](redroid_user_build_adb_fix.md)。
