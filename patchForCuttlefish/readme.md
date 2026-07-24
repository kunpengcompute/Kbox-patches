# 下载安卓源码
从清华源下载AOSP源码：
* 安卓14：repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-14.0.0_r28 --depth=1 --no-repo-verify
* 安卓15：repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-15.0.0_r17 --depth=1 --no-repo-verify
* 安卓16：repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-16.0.0_r4 --depth=1 --no-repo-verify

初始化仓库完成后用：`repo sync -j$(nproc)`拉取全量代码。

# 编译安卓源码
当前安卓14已完成自动化编译，在当前目录下运行：`./build_cf.sh $AOSP_PATH`即可完成patch合入，编译的流程。
编译产物：
* aosp_cf_arm64_only_phone-img-eng.android-build.zip：安卓镜像包
* cvd-host_package.tar.gz：Host工具包，用于启动Cuttlefish实例

# 启动命令：
HOME=$PWD ./bin/launch_cvd \
--gpu_mode=guest_swiftshader \
--extra_kernel_cmdline="arm64.nompam androidboot.selinux=permissive" \
--start_webrtc=true \
--start_gnss_proxy=false \
--enable_host_bluetooth=false \
--report_anonymous_usage_stats=false \
--enable_host_uwb=false \
--netsim=false \
--netsim_bt=false \
--proxy_fastboot=false \
--resume=false \
--vm_manager=qemu_cli