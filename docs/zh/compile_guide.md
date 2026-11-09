# 编译指南

## 环境准备

### 硬件环境

**表 1** redroid镜像编译构建硬件环境要求<a id="redroid镜像编译构建硬件环境要求"></a>

|设备型号|用途|服务器OS版本|
|---|---|---|
|x86_64服务器|redroid镜像编译制作|Ubuntu 22.04 LTS推荐：ubuntu-22.04-live-server-amd64.iso|

### 软件环境

**表 2** redroid镜像编译构建软件环境要求<a id="redroid镜像编译构建软件环境要求"></a>

|序号|软件|说明|获取地址|
|---|---|---|---|
|1|BoostKit-boostcph-kbox_*_sbx_14.zip|Android Kbox二进制文件包|获取链接|
|2|Kbox-patches-dev_AndroidSandbox.zip|Kbox AOSP补丁、脚本Demo包|[获取链接](https://gitcode.com/boostkit/Kbox-patches.git)<br>分支：dev_AndroidSandbox|
|3|AOSP源码|版本：android-14.0.0_r75|[获取链接](https://android.googlesource.com/platform/manifest)|
|4|envd源码|沙箱内部守护服务|[获取链接](https://github.com/e2b-dev/runtime.git)|
|5|Redroid源码|1. Redroid Modules源码<br>2. Redroid AOSP patch|1. [获取链接](https://github.com/remote-android/local_manifests.git)<br>2. [获取链接](https://github.com/remote-android/redroid-patches.git)|

### 安装编译依赖包

安装编译AOSP所需的依赖：

```bash
# 安装AOSP编译依赖 
sudo apt update && sudo apt-get install -y git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev libc6-dev-i386 libncurses-dev x11proto-core-dev \
  libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip \
  fontconfig python3 python-is-python3 openjdk-17-jdk git-lfs android-tools-adb \
  && git lfs install
# 安装Docker
sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && sudo apt update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
# 安装Go
GO_VERSION=1.26.10 && curl -fsSL -o /tmp/go$GO_VERSION.linux-amd64.tar.gz https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz \
  && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go$GO_VERSION.linux-amd64.tar.gz \
  && echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc && . ~/.bashrc && go version
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 依赖包清单以AOSP官方文档为准，如遇缺失可参考 [AOSP官方构建要求](https://source.android.com/docs/setup/start/initializing) 补充。

## 拉取AOSP 14.0.0\_r75源码

### 拉取AOSP 14.0.0\_r75源码

```bash
mkdir -p ~/redroid-workspace && cd ~/redroid-workspace
mkdir aosp-14 && cd aosp-14

# repo 工具与 AOSP manifest 使用官方地址
export REPO_URL='https://gerrit.googlesource.com/git-repo'
repo init -u https://android.googlesource.com/platform/manifest \
  -b android-14.0.0_r75
repo sync -c  --no-tags -j"$(nproc)"

### 拉取runtime（envd）源码

```bash
cd ~/redroid-workspace
git clone https://github.com/e2b-dev/runtime.git
cd runtime
git checkout 1b46ac89015b27f866515150385e6b938c861b7a
```

## 合入Redroid源码

### 获取Redroid modules源码

#### 同步redroid仓库

```bash
cd aosp-14

git clone https://github.com/remote-android/local_manifests.git \
  .repo/local_manifests -b 14.0.0
git -C .repo/local_manifests checkout d801ec2ab62b45b920bada57260701d2b1c60321

repo sync -c -j"$(nproc)" \
  device/redroid \
  device/redroid-prebuilts \
  hardware/redroid/c2 \
  hardware/redroid/omx \
  vendor/redroid
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 先同步专属仓库、再合入增量patch，可避免后续`repo sync`覆盖`device/redroid`、`vendor/redroid`的本地修改。

#### 同步WebView（git-lfs）

```bash
cd aosp-14
repo sync --force-sync -c external/chromium-webview
repo sync -c -j"$(nproc)" \
  external/chromium-webview/prebuilt/arm \
  external/chromium-webview/prebuilt/arm64 \
  external/chromium-webview/prebuilt/x86 \
  external/chromium-webview/prebuilt/x86_64

  
for d in external/chromium-webview/prebuilt/{arm,arm64,x86,x86_64}; do
    git -C "$d" lfs pull LineageOS
done
```

### 合入Redroid AOSP patch

#### 获取Redroid AOSP patch

```bash
cd ~/redroid-workspace
git clone https://github.com/remote-android/redroid-patches.git
cd redroid-patches
git checkout a5c70c0dd89c12b5027c902ab4182f31d38f3bb7
```

#### 合入Redroid AOSP patch

```bash
./redroid-patches/apply-patch.sh aosp-14 android-14.0.0_r75
```

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 该脚本遍历`redroid-patches/android-14.0.0_r75/`下各子目录，脚本第一个参数aosp-14为源码目录，需写入绝对路径，否则脚本执行会出错，对每个git仓执行`git am`，输出不应出现`[ERROR]`。
> redroid官方patch仅作用于AOSP核心仓（frameworks/av、system/core等），不涉及redroid专属仓。

完成本步骤后，`aosp-14`达到**redroid默认基线**（不含Kbox-patches增量修改），可直接编译出官方redroid镜像。

#### 验证Redroid默认基线（可选）

完成以上步骤后，源码已形成Redroid默认基线，可通过以下编译步骤验证基线正确性。

```bash
cd aosp-14
source build/envsetup.sh
lunch redroid_arm64_only-trunk_staging-userdebug
make -j"$(nproc)"
```

产物：`out/target/product/redroid_arm64_only/{system.img,vendor.img}`

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> 若基线编译失败，应先排查AOSP/Redroid/编译环境，再进入增量修改，避免把AOSP/Redroid/编译环境问题混入后续环节。

## 获取Kbox软件包

请参见[软件环境](#redroid镜像编译构建软件环境要求)下载`BoostKit-boostcph-kbox_*_sbx_14.zip`并上传至服务器`~/redroid-workspace/kbox-bin/`目录。

获取Kbox AOSP patch和参考脚本

```bash
cd ~/redroid-workspace
git clone https://gitcode.com/boostkit/Kbox-patches.git -b dev_AndroidSandbox
```

## 合入Kbox并编译Redroid镜像

### 合入Kbox二进制库

```bash
cd ~/redroid-workspace/kbox-bin
unzip BoostKit-boostcph-kbox_*_sbx_14.zip && unzip Kbox-BoostKit-boostcph-kbox_*-sbx-aosp14.0-binary.zip
cp -r product_prebuilt ~/redroid-workspace/aosp-14/
```

### 合入Kbox AOSP patch并编译Redroid镜像

#### 注入GMS（可选）

GMS即Google Mobile Services，默认编译流程中构建的AOSP镜像不会包含GMS组件。可自选是否注入GMS，文档总共提供2种GMS注入方式，如需注入则根据需要**任选其一**即可：

- 方法1：在编译环境，编译镜像时设置ENABLE_GMS=1，打包镜像包`./build_redroid.sh pack`时注入GMS到镜像。
- 方法2：在部署环境，部署Kbox沙箱方案挂载镜像时通过`./inject_gms.sh`注入GMS到沙箱。

本章节主要介绍“方法1”的使能步骤；“方法2”可参考用户指南（`user_guide.md`）文档。

1. 配置参数：

   ```bash
   cd redroid-workspace/Kbox-patches/build
   vim build_redroid.conf
   ```

   | 环境变量 | 作用 |
   | --- | --- |
   | ENABLE_GMS=0 | 默认设置为0，不注入GMS，设置1时产生注入GMS的镜像 |

   ```bash
   vim pack_gms.conf
   ```

   | 环境变量 | 作用 |
   | --- | --- |
   | GMS_LOCAL=0| 默认设置0时通过链接下载GMS，设置1时使用本地GMS目录，GMS_LOCAL_DIR与GMS_ZIP_FILE二选一（都填时优先GMS_LOCAL_DIR） |
   | GMS_LOCAL_DIR | GMS_LOCAL=0设置1时使用的本地已还原的GMS目录 |
   | GMS_ZIP_FILE | GMS_LOCAL=0设置1时使用的本地已下载好的GMS zip文件路径 |

2. 执行[一键构建](#一键构建Redroid镜像)或[分布构建](#分布构建)，构建出包含GMS的Redroid镜像。

#### 一键构建Redroid镜像<a id="一键构建Redroid镜像"></a>

构建脚本 `build/build_redroid.sh` 的配置文件为`build/build_redroid.conf`，可根据需要依照实际情况进行配置和修改。

| 配置名 | 默认值 | 功能作用 |
|---|---|---|
| SCRIPT_DIR | \$(cd "\$(dirname "${BASH_SOURCE[0]}")" && pwd)（脚本所在目录，即build/） | 动态计算脚本自身所在目录，作为其余相对路径的基准 |
| WORKSPACE | \$(cd "\$SCRIPT_DIR/../.." && pwd)（build/的上上级目录，即工作区根） | 动态计算工作区根目录，其余路径均基于此展开 |
| AOSP | \$WORKSPACE/aosp-14 | AOSP Android 14源码目录，编译与patch的目标工作区 |
| RUNTIME | \$WORKSPACE/runtime | runtime目录，存放运行时组件源码（如envd） |
| PATCH_DIR | \$SCRIPT_DIR/../patchForRedroid | redroid补丁包所在目录，打包前应用补丁时引用 |
| ENVD_SRC | \$RUNTIME/packages/envd | envd组件源码路径（注入前拷贝的源） |
| ENVD_DST | \$AOSP/vendor/redroid/envd/envd | envd拷贝注入到AOSP的目标路径 |
| PRODUCT | redroid_arm64_only | 编译产品名，对应AOSP的product配置 |
| LUNCH_TARGET | redroid_arm64_only-trunk_staging-user | lunch target，指定编译目标组合（产品-分支-类型）。如需编译userdebug镜像则修改为redroid_arm64_only-trunk_staging-userdebug |
| TAG | redroid:14.0.0_r75_arm64_only | 打包产出的Docker镜像标签 |
| OUT_TAR | \$AOSP/redroid-14.0.0_r75_arm64_only-cubesandbox.tar | 镜像打包输出的tar包路径（供docker load / 导入使用） |
| PROD_DIR | \$AOSP/out/target/product/\$PRODUCT | AOSP编译产物目录，打包时从中取rootfs/system等 |
| GMS_SCRIPT | \$SCRIPT_DIR/pack_gms.sh | GMS统一维护脚本（下载源清单 / 载荷下载校验 / 注入参数均由其管理） |
| ENABLE_GMS | 0 | 是否打包包含GMS载荷的镜像：1 = 打包时注入GMS；0 = 不含GMS（默认） |

由root权限执行脚本一键构建时，所有编译过程中文件所有者建议均设置为root。

```bash
cd ~/redroid-workspace/Kbox-patches/build
sudo ./build_redroid.sh all
```

#### 分步构建（可选）<a id="分布构建"></a>

本脚本提供分布构建能力，若已执行[一键构建](#一键构建Redroid镜像)则可跳过本章节。

```bash
cd ~/redroid-workspace/Kbox-patches/build
./build_redroid.sh envd            # 1) 编译 envd 二进制
./build_redroid.sh patch           # 2) 合入 Kbox-patches 增量 patch
./build_redroid.sh gms             # 3) 【可选】注入 GMS
./build_redroid.sh redroid         # 4) 编译 AOSP 镜像
sudo ./build_redroid.sh pack       # 5) 打包 Docker 镜像
```

### 产物与注意事项

最终产物：`aosp-14/redroid-14.0.0_r75_arm64_only-cubesandbox.tar`

>![](./public_sys-resources/icon-note.gif) **说明：**
>
> - **编译时长**：`make`全量编译约2~3小时（取决于核数）
> - **磁盘占用**：编译产物占用100GB+磁盘，请确保足够的磁盘空间。
