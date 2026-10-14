# 1. 安卓镜像编译

## 1.1 硬件环境要求

安卓镜像的编译仅支持在 x86 服务器下进行，服务器要求的操作系统为 Ubuntu 22.04 LTS，编译前请确保您的硬件环境满足要求。服务器需有访问外网权限，以方便下载 OS 镜像。

## 1.2 软件环境要求

安装编译环境所需依赖包：

```bash
sudo apt-get install libgl1-mesa-dev g++-multilib git flex bison gperf build-essential
sudo apt-get install tofrodos python3-markdown xsltproc dpkg-dev libsdl1.2-dev
sudo apt-get install git-core gnupg zip curl zlib1g-dev gcc-multilib glslang-tools
sudo apt-get install libc6-dev-i386 libx11-dev libncurses5-dev lib32ncurses5-dev x11proto-core-dev
sudo apt-get install libxml2-utils unzip m4 lib32z-dev ccache libssl-dev gettext python3-mako libncurses5
sudo apt-get install python3-chardet python3-markupsafe python3-packaging python3-pkg-resources python3-pygments
sudo apt-get install python3-pyparsing python3-six python3-yaml python2 python2.7
sudo apt-get install python3 python3-apport python3-apt python3-attr python3-automat
sudo apt-get install python3-blinker python3-certifi python3-cffi-backend
sudo apt-get install python3-click python3-colorama python3-commandnotfound
sudo apt-get install python3-configobj python3-constantly
sudo apt-get install python3-cryptography python3-dbus python3-debconf
sudo apt-get install python3-debian python3-dev python3-distro python3-distro-info
sudo apt-get install python3-distupgrade python3-distutils python3-entrypoints
sudo apt-get install python3-gdbm python3-gi python3-hamcrest python3-httplib2
sudo apt-get install python3-hyperlink python3-idna python3-importlib-metadata
sudo apt-get install python3-incremental python3-jinja2 python3-json-pointer
sudo apt-get install python3-jsonpatch python3-jsonschema python3-jwt
sudo apt-get install python3-keyring python3-launchpadlib python3-lazr.restfulclient
sudo apt-get install python3-lazr.uri python3-lib2to3
sudo apt-get install python3-more-itertools python3-nacl python3-netifaces python3-newt
sudo apt-get install python3-oauthlib python3-openssl python3-pip
sudo apt-get install python3-problem-report python3-pyasn1
sudo apt-get install python3-pyasn1-modules python3-pymacaroons python3-pyrsistent
sudo apt-get install python3-requests python3-requests-unixsocket python3-secretstorage
sudo apt-get install python3-serial python3-service-identity
sudo apt-get install python3-setuptools python3-simplejson
sudo apt-get install python3-software-properties python3-systemd python3-twisted
sudo apt-get install python3-update-manager python3-urllib3 python3-wadllib
sudo apt-get install python3-wheel python3-zipp python3-zope.interface
sudo apt-get install python-is-python3 ninja-build autoconf
```

## 1.3 源码准备

1. 从清华源下载 AOSP 源码：

   - 安卓14：`repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-14.0.0_r28 --depth=1 --no-repo-verify`
   - 安卓15：`repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-15.0.0_r17 --depth=1 --no-repo-verify`
   - 安卓16：`repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-16.0.0_r4 --depth=1 --no-repo-verify`

   初始化仓库完成后用 `repo sync -j$(nproc)` 拉取全量代码。

2. 拉取 BoostCPH 相关代码：

   ```bash
   git clone https://gitcode.com/maoyue0730/Kbox-patches.git -b br-enable-cf
   cd ./Kbox-patches/patchForCuttlefish
   ```

3. 下载二进制 envd-android-arm64，放入当前目录下。

## 1.4 编译安卓镜像

**自动编译脚本**

在当前目录下运行：

```bash
# 安卓14（默认）
./build_cf.sh $AOSP_PATH

# 安卓15
./build_cf.sh $AOSP_PATH a15

# 安卓16
./build_cf.sh $AOSP_PATH a16
```

脚本会自动应用对应版本的 patch、拷贝 envd 二进制、并执行 `make dist`。

**编译产物**

产物会生成在 `$AOSP_PATH/out/dist/` 目录下：

- `aosp_cf_arm64_only_phone-img-eng.android-build.zip`：安卓镜像包
- `cvd-host_package.tar.gz`：Host 工具包，用于启动 Cuttlefish 实例

# 2. Cuttlefish 启动命令

**安卓14（QEMU 后端）**

```bash
HOME=$PWD ./bin/launch_cvd \
  --gpu_mode=guest_swiftshader \
  --extra_kernel_cmdline="arm64.nompam androidboot.selinux=permissive" \
  --start_gnss_proxy=false \
  --enable_host_bluetooth=false \
  --report_anonymous_usage_stats=false \
  --enable_host_uwb=false \
  --netsim=false \
  --netsim_bt=false \
  --proxy_fastboot=false \
  --resume=false \
  --vm_manager=qemu_cli \
  --run_adb_connector=false
```

**安卓15（QEMU 后端）**

```bash
HOME=$PWD ./bin/launch_cvd \
  --gpu_mode=guest_swiftshader \
  --extra_kernel_cmdline="arm64.nompam androidboot.selinux=permissive" \
  --start_webrtc=false \
  --start_gnss_proxy=false \
  --enable_host_bluetooth=false \
  --enable_host_nfc=false \
  --enable_host_uwb=false \
  --enable_automotive_proxy=false \
  --netsim=false \
  --netsim_bt=false \
  --netsim_uwb=false \
  --report_anonymous_usage_stats= \
  --run_adb_connector=false \
  --proxy_fastboot=false \
  --resume=false \
  --vm_manager=qemu_cli
```

**安卓16（QEMU 后端）**

```bash
HOME=$PWD ./bin/launch_cvd \
  --gpu_mode=guest_swiftshader \
  --extra_kernel_cmdline="arm64.nompam console=ttyAMA0 androidboot.selinux=permissive" \
  --vm_manager=qemu_cli \
  --start_gnss_proxy=false \
  --enable_host_bluetooth=false \
  --report_anonymous_usage_stats=false \
  --enable_host_uwb=false \
  --proxy_fastboot=false \
  --start_webrtc=false \
  --netsim=false \
  --netsim_bt=false \
  --netsim_uwb=false \
  --enable_wifi=false \
  --enable_host_nfc=false \
  --run_adb_connector=false
```
