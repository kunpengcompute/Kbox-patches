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

sudo bash build.sh all        # 一键全量（envd → patch → 编译 → 打包）
bash build.sh envd            # 仅编译 envd 二进制
bash build.sh patch           # 仅合入 Kbox-patches 增量 patch
bash build.sh redroid         # 仅编译 AOSP 镜像
sudo bash build.sh pack       # 仅打包 Docker 镜像
```

### 4.2 一键构建

```bash
cd redroid-workspace/Kbox-patches/build
sudo bash build.sh all
```

> **说明：** `all` 依次执行：编译 envd 二进制 → 合入 Kbox-patches 增量 patch → lunch/make → 打包 Docker 镜像。打包步骤需 root，故整体用 `sudo`。

### 4.3 分步构建

```bash
cd redroid-workspace/Kbox-patches/build
bash build.sh envd            # 1) 编译 envd 二进制
bash build.sh patch           # 2) 合入 Kbox-patches 增量 patch
bash build.sh redroid         # 3) 编译 AOSP 镜像
sudo bash build.sh pack       # 4) 打包 Docker 镜像
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
