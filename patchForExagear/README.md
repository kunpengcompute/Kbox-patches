# ExaGear 适配 Android11 Patch说明

## Table of Contents

├── guestOS
│   └── aosp11
│       ├── 0001-exagear-adapt-android-11.0.0_r48.patch
│       └── vendor
│           └── huawei
│               └── exagear
│                   ├── exagear.mk
│                   ├── init
│                   │   ├── exagear-binfmt.rc
│                   │   └── exagear-debug.rc
│                   └── prebuilts
│                       └── Android.mk
├── hostOS
│   └── ubuntu_20.04
│       └── 0001-exagear-adapt-kernel-5.10.27.patch
└── README.md


##  Linux Kernel Patch

将0001-exagear-adapt-kernel-5.10.27.patch拷贝到linux kernel源码下打上patch即可

```shell
kernel_workspace=/home/fanglinglong/linux_5.10.27
cp 0001-exagear-adapt-kernel-5.10.27.patch $kernel_workspace/
cd $kernel_workspace
patch -p1 <  0001-exagear-adapt-kernel-5.10.27.patch
make menuconfig # 生成.config目录即可
make -j64
make INSTALL_MOD_STRIP=1 modules_install -j64
make install
reboot # 切换内核
```



## Android Patch

拷贝0001-exagear-adapt-android-11.0.0_r48.patch到android11源码目录，打上patch后，讲vendor目录拷贝到android源码目录下。

```shell
aosp11_workspace=/home/fanglinglong/aosp11
cp 0001-exagear-adapt-android-11.0.0_r48.patch $aosp11_workspace
patch -p1 <  0001-exagear-adapt-android-11.0.0_r48.patch 
mkdir -p $aosp11_workspace/vendor
cp -r vendor/* $aosp11_workspace/vendor
# 编译android11
```



## Developing The Host Exagear

将ubt_a32a64拷贝到/opt/exagear目录下，将其注册到binfmt_misc中。使得32位的程序能自动调用ubt_a32a64

``` shell
mkdir -p /opt/exagear
mv ubt_a32a64 /opt/exagear
chmod +x /opt/exagear/ubt_a32a64
# 注册Exagear到binfmt_misc
translator_name=ubt_a32a64
translator_path=/proc/sys/fs/binfmt_misc/$translator_name

echo ":${translator_name}:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/opt/exagear/ubt_a32a64:POCF" > /proc/sys/fs/binfmt_misc/register
```

