# 编译指南<a name="ZH-CN_TOPIC_0000002552663613"></a>

## 环境准备<a name="ZH-CN_TOPIC_0000002549825291"></a>

### 硬件环境<a name="ZH-CN_TOPIC_0000002549705339"></a>

Kbox安卓镜像的编译仅支持在x86服务器下进行，服务器要求的操作系统为Ubuntu 22.04 LTS，编译前请确保您的硬件环境满足要求。

Kbox安卓镜像编译构建的硬件环境要求如[**表 1** Kbox安卓镜像编译构建硬件环境要求](#Kbox安卓镜像编译构建硬件环境要求)所示。

**表 1** Kbox安卓镜像编译构建硬件环境要求<a id="Kbox安卓镜像编译构建硬件环境要求"></a>

|设备型号|用途|服务器OS版本|
|--|--|--|
|x86_64服务器|Kbox安卓镜像编译制作|Ubuntu 22.04 LTS推荐：ubuntu-22.04-live-server-amd64.iso|

>![](public_sys-resources/icon-note.gif) **说明：** 
>
>- 本文档测试服务器型号为2288H V5。
>- 服务器需有访问外网权限，以方便下载OS镜像。

Kbox安卓镜像的编译仅支持在x86服务器下进行，服务器要求的操作系统为Ubuntu 22.04 LTS，编译前请确保您的硬件环境满足要求。

### 软件环境<a name="ZH-CN_TOPIC_0000002518345466"></a>

编译Kbox安卓镜像需要使用AOSP、Mesa、LLVM等源码包，华为提供的Kbox二进制文件包和ExaGear转码包，您需要通过本节提供的渠道获取相应的源码包并对华为提供的软件包进行完整性校验，以便进行后续的编译步骤。

**获取软件包<a name="section038565445713"></a>**

Kbox安卓镜像编译构建的软件环境要求如[**表 1** Kbox安卓镜像编译构建软件环境要求](#Kbox安卓镜像编译构建软件环境要求)所示。

**表 1** Kbox安卓镜像编译构建软件环境要求<a id="Kbox安卓镜像编译构建软件环境要求"></a>

|序号|软件|说明|获取地址|
|--|--|--|--|
|1|AOSP源码|版本：android-11.0.0_r48|获取链接|
|2|Mesa源码|Mesa参考Demo版本：22.1.7|获取链接切换到22.1.7分支，并单击“下载zip”进行下载。|
|3|LLVM源码|版本：13.0.1|获取链接|
|4|libdrm源码|版本：2.4.111|获取链接|
|5|libva源码|版本：2.14.0|获取链接|
|6|BoostKit-boostcph-kbox_*.zip|Android Kbox二进制文件包|获取链接|
|7|Kbox-AOSP11.zip|Android代码补丁Demo包、编译脚本Demo包|获取链接切换到AOSP11分支，并单击“下载zip”进行下载。|
|8|ExaGear_ARM32-ARM64_V2.5.tar.gz|ExaGear转码二进制包|获取链接|
|9|Meson|0.63.2|获取链接|
|10|vmi-CloudPhone.zip|华为VMI引擎云手机开源参考Demo分支：CloudPhone|获取链接切换到CloudPhone分支，并单击“下载zip”进行下载。|

>![](public_sys-resources/icon-note.gif) **说明：** 
>以上软件包名仅供参考，部分下载方式可能会导致软件包名与表格产生差异。请以获取的实际包名为准，参考表格适当进行更名，以方便后续步骤中的使用。

**软件包完整性校验<a name="section12800195641510"></a>**

为了防止软件包在传递过程或存储期间被恶意篡改，从鲲鹏社区获取软件包时需下载对应的数字签名文件用于完整性验证。

1. 获取软件数字证书和软件包。

    请参见[**表 1** Kbox安卓镜像编译构建软件环境要求](#Kbox安卓镜像编译构建软件环境要求)。

2. <a name="li1273482318125"></a>从[华为企业业务网站](https://support.huawei.com/enterprise/zh/tool/pgp-verify-TL1000000054)或[运营商网站](http://support.huawei.com/carrier/digitalSignatureAction)获取校验工具和校验方法。
3. 使用[2](#li1273482318125)获取到的签名验证指南文档对下载的软件包进行PGP数字签名校验。

>![](public_sys-resources/icon-note.gif) **说明：** 
>如果校验失败，请不要使用该软件包，先联系华为技术支持工程师解决。
>使用软件包安装或升级之前，也需要按上述过程先验证软件包的数字签名，确保软件包未被篡改。
>使用软件包前请先阅读《[鲲鹏应用使能套件BoostKit用户许可协议 2.0](https://www.hikunpeng.com/zh/legal/developer/boostkit/software/protocol)》，如确认继续使用，则默认同意协议的条款和条件。

编译Kbox安卓镜像需要使用AOSP、Mesa、LLVM等源码包，华为提供的Kbox二进制文件包和ExaGear转码包，您需要通过本节提供的渠道获取相应的源码包并对华为提供的软件包进行完整性校验，以便进行后续的编译步骤。

## 编译构建流程<a name="ZH-CN_TOPIC_0000002549825249"></a>

了解Kbox安卓镜像编译构建流程，可以帮助您更好地理解编译过程中的各个环节。

Kbox安卓镜像编译构建的流程如[**图 1** Kbox安卓镜像编译构建流程](#Kbox安卓镜像编译构建流程)所示。

**图 1** Kbox安卓镜像编译构建流程<a name="fig19747839194513"></a><a id="Kbox安卓镜像编译构建流程"></a>
![](figures/Kbox安卓镜像编译构建流程.png "Kbox安卓镜像编译构建流程")

了解Kbox安卓镜像编译构建流程，可以帮助您更好地理解编译过程中的各个环节。

## 镜像一键式编译脚本<a name="ZH-CN_TOPIC_0000002549825281"></a>

华为提供一键式编译Kbox安卓镜像的自动化脚本。一键式编译脚本包含了编译构建的全部流程，若参考本章节使用了一键式编译脚本进行镜像编译，则可以跳过软件编译后续章节直接进行软件部署。

自动化脚本实现了[安装编译依赖包](#安装编译依赖包)、[编译AOSP源码与镜像生成](#编译AOSP源码与镜像生成)章节的操作。使用自动化脚本需要准备AOSP源码、华为提供的Kbox二进制文件包、ExaGear转码包和Android代码补丁包、编译脚本包，请参见[**表 1** Kbox安卓镜像编译构建软件环境要求](#Kbox安卓镜像编译构建软件环境要求)获取。自动化脚本的使用步骤如下：

1. 首先在“/home“目录下手动创建“auto\_compile“目录，用于存放AOSP源码以及自动化脚本。

    >![](public_sys-resources/icon-note.gif) **说明：** 
    >请确保“/home“目录的剩余空间大于250GB，可通过**df -h**命令查看磁盘空间情况。

    ```shell
    mkdir -p /home/auto_compile
    cd /home/auto_compile
    ```

2. 在“/home/auto\_compile“目录下载AOSP源码，版本为android-11.0.0\_r48，将下载好的AOSP源码目录重命名为“aosp“。
3. 请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)下载Kbox-AOSP11.zip文件到本地，上传到服务器的“/home/auto\_compile“目录，并解压。

    ```shell
    cd /home/auto_compile
    unzip Kbox-AOSP11.zip
    ```

4. 修改容器网络配置。
    1. 编辑kbox11\_android\_build.sh脚本。

        ```shell
        cd /home/auto_compile/Kbox-AOSP11/make_img_sample/kbox11_android_build
        vim kbox11_android_build.sh
        ```

    2. 按“i”进入编辑模式，修改以下内容，用于配置容器的DNS地址。需保证配置的地址可用，且按照文件的格式进行配置，否则可能导致编译获得的镜像不可用。配置格式参考示例如下。

        ```shell
        DNS=xx.xx.xx.xx
        ```

    3. 按“Esc”键，输入**:wq!**，按“Enter”保存并退出编辑。

5. 请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)下载Android Kbox二进制文件包、ExaGear转码包、Meson、Mesa源码、LLVM源码、libdrm源码、libva源码和Cloudphone应用安装包到本地。在如下指定目录中创建“package“文件夹。

    ```shell
    cd /home/auto_compile/Kbox-AOSP11/make_img_sample/kbox11_android_build
    mkdir -p package
    ```

    将下载的文件上传至服务器的“/home/auto\_compile/Kbox-AOSP11/make\_img\_sample/kbox11\_android\_build/package“目录。

    ![](figures/zh-cn_image_0000002549705429.png)

    需保持下载的第三方库源码（Mesa、LLVM、libdrm、libva）及解压出的文件夹名与“/home/auto\_compile/Kbox-AOSP11/make\_img\_sample/00\_kbox\_prepare.sh“文件中配置的“<package\>\_version“或“<package\>\_src“变量值一致。若不一致可重命名源码文件夹再重新打包。

6. 执行kbox11\_android\_build.sh自动化脚本完成Kbox编译。

    ```shell
    cd /home/auto_compile/Kbox-AOSP11/make_img_sample/kbox11_android_build && chmod +x kbox11_android_build.sh
    ./kbox11_android_build.sh
    ```

    此脚本执行时间需要一小时以上，请耐心等待。脚本执行完成会有如下回显。如遇脚本执行报错，优先排查脚本并联系华为工程师。

    ```shell
    ---------------Success--------------
    /home/auto_compile/aosp/android.tar
    ---------------End--------------
    ```

    至此，Kbox安卓镜像制作完成，在AOSP源码目录下会生成名为“android.tar”的Kbox镜像。

**故障处理<a name="section173361345459"></a>**

**问题现象一：**

执行kbox11\_android\_build.sh自动化脚本时可能出现“'format\_info.h' file not found”类报错，原因为Mesa多线程编译概率性导致编译所依赖的头文件生成滞后，导致编译失败。

```shell
../src/mesa/main/formats.c:81:10: fatal error: 'format_info.h' file not found
#include "format_info.h"
1 error generated.
```

**解决步骤**

1. 使环境变量生效。

    ```shell
    source ~/.bashrc
    ```

2. 重新编译。

    ```shell
    cd /home/auto_compile/aosp
    source build/envsetup.sh
    lunch kbox_arm64-user
    make -j
    ```

    如果出现相同报错，请再次执行**make -j**命令编译，直到不再出现相同报错。执行成功后，会有如下回显：

    ```shell
    #### build completed successfully (xx:xx (mm:ss)) ####
    ```

3. 继续执行以下命令用于生成“android.tar“的Kbox镜像。

    ```shell
    cp -r /home/auto_compile/Kbox-AOSP11/make_img_sample/kbox11_android_build/create-package.sh /home/auto_compile/aosp
    chmod +x create-package.sh
    ./create-package.sh /home/auto_compile/aosp/out/target/product/arm64/system.img
    ```

**问题现象二：**

执行kbox11\_android\_build.sh自动化脚本时，可能出现“No such file or directory”类报错， 原因为依赖包解压所得文件夹名称发生变化比如附加后缀，一键式脚本中无法识别到解压出来的文件夹名称，导致编译失败。

![](figures/zh-cn_image_0000002518345560.png)

解决步骤：

以下步骤仅供参考，具体操作以实际为主。

1. 找到报错的软件压缩包后解压。

    ```shell
    unzip drm-libdrm-2.4.111.zip
    ```

2. 修改解压文件夹名为编译报错中提示的文件名（一键式脚本中预设的文件名）。

    ```shell
    mv libdrm-libdrm-2.4.111-f801b07a60740425604d6563e5dc399375108bc4 drm-libdrm-2.4.111
    ```

3. 压缩目录，新做一个软件包，使用新软件包进行一键式脚本编译即可。

    ```shell
    mv drm-libdrm-2.4.111.zip drm-libdrm-2.4.111.zip.bak
    zip -r drm-libdrm-2.4.111.zip  drm-libdrm-2.4.111
    ```

>![](public_sys-resources/icon-note.gif) **说明：** 
>执行kbox11\_android\_build.sh自动化脚本时也可能出现依赖缺失类报错， 这类报错同样可能由于软件包内容更新产生的新的依赖导致。遇到该类型的报错，直接在环境上安装缺失的包即可。

华为提供一键式编译Kbox安卓镜像的自动化脚本。一键式编译脚本包含了编译构建的全部流程，若参考本章节使用了一键式编译脚本进行镜像编译，则可以跳过软件编译后续章节直接进行软件部署。

## 安装编译依赖包<a name="ZH-CN_TOPIC_0000002518185544" id ="安装编译依赖包"></a>

进行编译前，需要为环境配置源，安装Python3的mako模块以及Meson等依赖包。

1. 根据实际网络环境配置源，以便安装编译源码需要的依赖包。
2. 配置完成后，更新索引。

    ```shell
    sudo apt update
    ```

3. 安装编译环境所需依赖包。

    ```shell
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

    若遇到如下图所示的提示信息，选择“Cancel”即可。

    ![](figures/zh-cn_image_0000002518345612.png)

4. 确认服务器的Python3环境是否包含mako模块。若无，请为服务器的Python3环境安装mako模块。
    1. 执行如下命令，进入Python3环境。

        ```shell
        python3
        ```

        ![](figures/zh-cn_image_0000002518185682.png)

    2. 进入Python3环境后，执行如下命令，查看包含的模块信息。

        ```shell
        help("modules")
        ```

        ![](figures/zh-cn_image_0000002518345610.png)

        如图所示，若回显中包含mako模块，则可继续后文步骤。若不包含，可通过执行“pip3 install mako”安装mako模块。请确保Python3环境中包含mako模块，再继续后文的步骤。

        ![](figures/zh-cn_image_0000002549825457.png)

    3. 退出python命令模式。

        ```shell
        exit()
        ```

5. 在用户目录下创建“buildtools“目录，并为目录拥有者添加读、写和可执行权限。

    ```shell
    mkdir ~/buildtools
    chmod -R 700 ~/buildtools
    ```

6. 安装Meson。

    请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)中的链接下载源码包后，将源码包中的“meson-0.63.2.tar.gz“文件上传至“\~/buildtools“目录并解压。

    ```shell
    cd ~/buildtools
    tar -xvpf meson-0.63.2.tar.gz
    ```

7. 设置环境变量。
    1. 在“\~/.bashrc“文件末尾添加如下内容。

        ```shell
        cat >> ~/.bashrc <<EOF
        export PATH=~/buildtools/meson-0.63.2:\$PATH
        EOF
        ```

    2. 使环境变量生效。

        ```shell
        source ~/.bashrc
        ```

进行编译前，需要为环境配置源，安装Python3的mako模块以及Meson等依赖包。

## 编译AOSP源码与镜像生成<a name="ZH-CN_TOPIC_0000002518185476" id="编译AOSP源码与镜像生成"></a>

### 下载AOSP源码<a name="ZH-CN_TOPIC_0000002549705281"></a>

Kbox安卓镜像使用AOSP 11进行编译，请参考本节操作步骤下载源码。

1. 在用户目录下创建“aosp“目录，并为目录拥有者添加读、写和可执行权限。

    ```shell
    mkdir ~/aosp
    chmod -R 700 ~/aosp
    ```

    >![](public_sys-resources/icon-note.gif) **说明：** 
    >用户目录剩余空间要求大于300GB，AOSP源码约130GB，编译后接近300GB。

2. 按照[谷歌官方指导](https://android.googlesource.com/tools/repo)，下载并安装repo工具，然后下载AOSP源码，版本为android-11.0.0\_r48，并进行编译。

    ```shell
    cd ~/aosp
    repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r48
    repo sync
    ```

3. 在“aosp“目录下，删除源码中“external/mesa3d“、“external/libdrm“、“device/generic/arm64“三个文件夹。

    ```shell
    cd ~/aosp
    rm -rf external/mesa3d external/libdrm device/generic/arm64
    ```

Kbox安卓镜像使用AOSP 11进行编译，请参考本节操作步骤下载源码。

### 下载Mesa、LLVM、libdrm、libva、Media源码<a name="ZH-CN_TOPIC_0000002518185496"></a>

Kbox安卓镜像编译过程中使用到Mesa、LLVM和libdrm等，请参考本节操作步骤下载源码。

1. 在用户目录下创建“sourcecode“目录，并为目录拥有者添加读、写和可执行权限。

    ```shell
    mkdir ~/sourcecode
    chmod -R 700 ~/sourcecode
    ```

2. 下载Mesa Demo源码，并复制到“aosp/external“目录。

    请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)中的链接下载源码包后，将源码包上传至“/root/sourcecode“目录，解压并重命名后，复制到“aosp/external“目录。

    ```shell
    cd ~/sourcecode
    unzip mesa-22.1.7.zip
    mv mesa-22.1.7 mesa
    cp -r ./mesa ~/aosp/external/
    ```

3. 下载LLVM源码，复制到“aosp/external“目录，并且将目录重命名为“llvm70“。

    请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)中的链接下载源码包后，将源码包上传至“/root/sourcecode“目录，解压并重命名后，复制到“aosp/external“目录。

    ```shell
    cd ~/sourcecode
    tar xvf llvm-13.0.1.src.tar.xz
    mv llvm-13.0.1.src llvm70
    cp -r ./llvm70 ~/aosp/external/
    ```

4. 下载libdrm源码，复制到“aosp/external“目录，并且重命名为“libdrm“。

    请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)中的链接下载源码包后，将源码包上传至“/root/sourcecode“目录，解压并重命名后，复制到“aosp/external“目录。

    ```shell
    cd ~/sourcecode
    unzip drm-libdrm-2.4.111.zip
    mv drm-libdrm-2.4.111 libdrm
    cp -r ./libdrm ~/aosp/external/
    ```

5. 下载libva源码，复制到“aosp/external“目录，并且重命名为“libva“。

    请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)中的链接下载源码包后，将源码包上传至“/root/sourcecode“目录，解压并重命名后，复制到“aosp/external“目录。

    ```shell
    cd ~/sourcecode
    tar xvf libva-2.14.0.tar.gz
    mv libva-2.14.0 libva
    cp -r ./libva ~/aosp/external/
    ```

6. 请参见[软件环境](#Kbox安卓镜像编译构建软件环境要求)下载vmi-CloudPhone.zip软件包，解压后将指定文件夹复制到“aosp/external“目录。

    请将获取到的Media的zip源码包上传至“/root/sourcecode“目录，解压并复制以下内容到“aosp/external“目录。

    ```shell
    cd ~/sourcecode
    unzip vmi-CloudPhone.zip
    cp -r ./vmi-CloudPhone/CloudPhoneService/VideoEngine/Media/video_decoder ~/aosp/external/
    cp -r ./vmi-CloudPhone/CloudPhoneService/VideoEngine/Media/vendor ~/aosp/external/
    ```

Kbox安卓镜像编译过程中使用到Mesa、LLVM和libdrm等，请参考本节操作步骤下载源码。

### 合入ExaGear转码补丁<a name="ZH-CN_TOPIC_0000002549705327"></a>

在AOSP源码包中合入ExaGear转码补丁包。

1. 在用户目录下创建“dependency“目录。解压Kbox-AOSP11.zip，将Kbox-AOSP11文件夹中的“patchForExagear“目录上传至“\~/dependency“目录。请对上传文件、目录的权限进行合理配置，其他用户属组建议不配置写权限。
2. 合入ExaGear转码补丁。拷贝ExaGear转码补丁0001-exagear-adapt-android-11.0.0\_r48.patch至AOSP源码目录，并执行合入补丁命令。

    ```shell
    cd ~/dependency/patchForExagear/guestOS/aosp11
    cp 0001-exagear-adapt-android-11.0.0_r48.patch ~/aosp
    cd ~/aosp
    patch -p1 < 0001-exagear-adapt-android-11.0.0_r48.patch
    ```

3. 将ExaGear转码包（ExaGear\_ARM32-ARM64\_V2.5.tar.gz）上传至“\~/dependency”目录。请对上传文件、目录的权限进行合理配置，其他用户属组建议不配置写权限。
4. 解压补丁包，并调整权限。

    ```shell
    cd ~/dependency/ 
    sudo tar -xzvf ExaGear_ARM32-ARM64_V2.5.tar.gz 
    ```

5. 将“\~/dependency/ExaGear\_ARM32-ARM64“目录下的preubt\_a32a64\_a64、preubt\_a32a64\_x64、ubt\_a32a64文件拷贝至“\~/dependency/patchForExagear/guestOS/aosp11/vendor/huawei/exagear/prebuilts”目录。

    ```shell
    cd ~/dependency/ExaGear_ARM32-ARM64
    cp * ~/dependency/patchForExagear/guestOS/aosp11/vendor/huawei/exagear/prebuilts
    ```

6. 拷贝“vendor“目录至“aosp“目录下。

    ```shell
    cd ~/dependency/patchForExagear/guestOS/aosp11
    cp -r ./vendor ~/aosp/
    ```

在AOSP源码包中合入ExaGear转码补丁包。

### 合入Kbox安卓补丁<a name="ZH-CN_TOPIC_0000002518345478"></a>

在AOSP源码包中合入Kbox安卓补丁包。

1. 解压Kbox-AOSP11.zip，将Kbox-AOSP11文件夹中的“patchForAndroid“目录上传至“\~/dependency“目录。请对上传文件、目录的权限进行合理配置，其他用户属组建议不配置写权限。
2. 合入Kbox安卓补丁。

    ```shell
    aosp_path=~/aosp; \
    work_path=~/dependency/patchForAndroid; \
    for patch_name in $(ls $work_path | grep .patch); do \
        cd $work_path; \
        echo $patch_name; \
        patch_path="$(echo $patch_name | sed 's|-|/|g' | awk -F"/" 'OFS="/"{$NF="";print}')"; \
        cp $patch_name $aosp_path/$patch_path; \
        cd $aosp_path/$patch_path; \
        patch -p1 < $patch_name; \
    done
    ```

>![](public_sys-resources/icon-note.gif) **说明：** 
>为了方便用户快速体验和部署Kbox云手机套件，提供了Kbox安卓补丁。该补丁仅作为功能性参考，不是商用交付范围，不提供商业承诺，建议客户或ISV在商用前进行必要的安全评估，若选择使用鲲鹏BoostKit云手机参考方案需自行承担安全风险。

在AOSP源码包中合入Kbox安卓补丁包。

### 合入二进制内容<a name="ZH-CN_TOPIC_0000002549825259"></a>

在AOSP源码包中合入Kbox二进制软件包。

1. 解压二进制文件包（BoostKit-boostcph-kbox\_\*.zip），获得Kbox-\*-aosp11.0-binary.zip压缩包，将此压缩包中的“product\_prebuilt“、“products“目录上传至“\~/dependency“目录。

    请对上传文件、目录的权限进行合理配置，其他用户属组建议不配置写权限。

2. 将二进制内容复制到AOSP源码根目录。由于product\_prebuilt的解码二进制libstagefrighthw.so会和Android的有冲突，需删除Android的目录“device/generic/goldfish-opengl/system/codecs“以及注释其相关的编译代码。

    ```shell
    cd ~/dependency
    cp -rf product_prebuilt ~/aosp/
    rm -rf ~/aosp/device/generic/goldfish-opengl/system/codecs
    sed -i 's/include $(GOLDFISH_OPENGL_PATH)\/system\/codecs\/omx/#include $(GOLDFISH_OPENGL_PATH)\/system\/codecs\/omx/g' \
    ~/aosp/device/generic/goldfish-opengl/Android.mk
    ```

3. 在AOSP源码目录创建“vendor/kbox“目录，拷贝“products“目录至该目录。

    ```shell
    mkdir -p ~/aosp/vendor/kbox
    chmod -R 700 ~/aosp/vendor/kbox
    cd ~/dependency
    cp -rf products ~/aosp/vendor/kbox
    ```

4. 在“\~/aosp/vendor/kbox/products“目录下，通过以下命令修改kbox.mk文件里的DNS地址。

    此命令中的net.dns1=xxx.xxx.xxx.xxx需要替换成配置容器的DNS地址。需保证配置的地址可用，否则可能导致编译获得的镜像不可用。

    ```shell
    sed -i "s|net.dns1=.*|net.dns1=xxx.xxx.xxx.xxx \\\\|" ~/aosp/vendor/kbox/products/kbox.mk
    ```

    >![](public_sys-resources/icon-note.gif) **说明：** 
    >- 示例仅作为格式参考，请根据实际情况自行配置可用的公共DNS地址，以保证容器连接网络正常。
    >- DNS地址也可以通过修改Kbox容器内部文件“/system/vendor/build.prop“配置，容器重启后配置生效。
    >- 如配置时有疑问，请联系华为运维人员支撑。

在AOSP源码包中合入Kbox二进制软件包。

### 编译AOSP并生成镜像<a name="ZH-CN_TOPIC_0000002518185486"></a>

编译AOSP源码生成Kbox安卓镜像。

1. 编译AOSP源码。
    1. 生成您自己的唯一发布密钥集用于对部署的Android操作系统映像进行签名。

        ```shell
        cd ~/aosp/
        rm -rf ./build/target/product/security/release*
        chmod +x ./development/tools/make_key
        ./development/tools/make_key build/target/product/security/releasekey '/C=xx/ST=xxx/L=xxx/O=xxx/OU=xx/CN=xxx/emailAddress=xxxxx@xxx.com'
        ```

        >![](public_sys-resources/icon-note.gif) **说明：** 
        >在执行**make\_key**命令时，会提示输入密码，可以直接按回车跳过。
        >**make\_key**命令参数介绍如下：
        >- “build/target/product/security/releasekey“表示要生成key的名字。
        >- 后面的参数表示公司相关信息，请根据实际情况填写，含义解释如[**表 1** **make\_key**参数说明](#make_key参数说明)所示。

        **表 1** **make\_key**参数说明<a id="make_key参数说明"></a>

        |参数名称|参数解释|
        |--|--|
        |C|Country Name (2 letter code)|
        |ST|State or Province Name (full name)|
        |L|Locality Name (eg, city)|
        |O|Organization Name (eg, company)|
        |OU|Organizational Unit Name (eg, section)|
        |CN|Common Name (eg, your name or your server’s hostname)|
        |emailAddress|Contact email address|

    2. 将envsetup.sh中所有用到的命令加载到环境变量中。

        ```shell
        source build/envsetup.sh
        ```

    3. 选择编译模式。Kbox的user模式编译镜像默认开启adb，adb有root权限。此处默认采用user模式编译镜像。

        ```shell
        lunch kbox_arm64-user
        ```

        >![](public_sys-resources/icon-note.gif) **说明：** 
        >- 若需要采用userdebug模式编译镜像，请将上述**lunch**命令后的选项后缀由“user“修改为“userdebug“。以“kbox\_arm64“为例：
        >
        >    ```shell
        >    lunch kbox_arm64-userdebug
        >    ```
        >
        >- Kbox还提供了精简版本镜像，在一般镜像的基础上去除了部分系统预装应用，以获得更好的内存占用与性能表现。
        > 使用如下编译选项以编译精简镜像：
        >
        >    ```shell
        >    lunch kbox_arm64_optimized-user
        >    ```

    4. 执行编译。

        ```shell
        make clean
        make -j
        ```

        >![](public_sys-resources/icon-note.gif) **说明：** 
        >在执行上述命令时，“-j”后的数字参数要根据服务器实际的CPU核数来定。CPU核数可通过以下命令查询。
        >
        > ```shell
        > cat /proc/cpuinfo |grep "processor" | wc -l
        >    ```
        >
        >可不指定核数，直接执行**make**命令，则默认用1个核进行编译，也可用“-j”参数指定核数进行编译，可指定的数字最大为服务器实际的CPU核数，本文以64核为例进行说明。
        >正常情况下，能够编译完成。有时可能由于并发编译顺序导致编译出现问题，可尝试重新执行**make**命令。

2. 解压Kbox-AOSP11.zip，将Kbox-AOSP11文件夹中的make\_img\_sample目录上传至“\~/dependency“目录。

    请对上传文件、目录的权限进行合理配置，其他用户属组建议不配置写权限。

3. 拷贝生成镜像脚本至“\~/aosp“目录，并赋予可执行权限。

    ```shell
    cd ~/dependency/make_img_sample/kbox11_android_build
    cp create-package.sh ~/aosp/
    cd ~/aosp
    chmod +x create-package.sh
    ```

4. 运行脚本，生成Kbox安卓镜像。

    >![](public_sys-resources/icon-note.gif) **说明：** 
    >制作镜像的时候需要root权限，请用root用户执行脚本，且执行脚本时，目录需要使用绝对路径。

    ```shell
    ./create-package.sh ~/aosp/out/target/product/arm64/system.img
    ```

    至此，Kbox安卓镜像制作完成，在当前目录下会生成名为android.tar的Kbox镜像。
