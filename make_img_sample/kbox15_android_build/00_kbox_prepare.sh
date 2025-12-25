#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2020-2020. All rights reserved.
# File Name: 00_kbox_prepare.sh
# Description: 源码相关准备.
# Usage: bash 00_kbox_prepare.sh
# ******************************************************************************** #

#set -x
# 脚本解释器 强制设置为 bash
if [ "$BASH" != "/bin/bash" ] && [ "$BASH" != "/usr/bin/bash" ]
then
   bash "$0" "$@"
   exit $?
fi

# 检查参数是否传递正确
if [ $# -ne 3 ]; then
    echo "Usage: $0 <CURRENT_DIR> <AOSP_PATH> <PACKAGE_PATH>"
    exit 1
fi

# 获取传递给脚本的参数
CURRENT_DIR=$1
AOSP_PATH=$2
PACKAGE_PATH=$3

function error(){
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

export GIT_SSL_NO_VERIFY=1
mkdir -p ~/bin
PATH=~/bin:$PATH
cpu_num=$(< /proc/cpuinfo grep -c "processor")

# 关闭ubuntu的Daemons using outdated libraries服务重启提示弹窗
echo "\$nrconf{kernelhints} = 0;" >> /etc/needrestart/needrestart.conf
echo "\$nrconf{restart} = 'l';" >> /etc/needrestart/needrestart.conf

################################################################################
# Function Name: clean
# Description  : 清理依赖目录
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function clean(){
    echo "----------清理当前目录下的buildtools目录----------"
    rm -rf $CURRENT_DIR/buildtools || { error "无法删除buildtools目录"; }
    echo "----------清理当前目录下的sourcecode目录----------"
    rm -rf $CURRENT_DIR/sourcecode || { error "无法删除sourcecode目录"; }
    echo "----------清理成功----------"
}

################################################################################
# Function Name: build_dependency
# Description  : 安装编译构建所需依赖
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function build_dependency(){
    echo "----------开始安装编译构建所需依赖----------"
    apt update || error "apt update 失败"
    sudo apt-get -y install libgl1-mesa-dev || error "libgl1-mesa-dev 安装失败"
    sudo apt-get -y install g++-multilib || error "g++-multilib 安装失败"
    sudo apt-get -y install wget || error "wget 安装失败"
    sudo apt-get -y install git || error "git 安装失败"
    sudo apt-get -y install flex || error "flex 安装失败"
    sudo apt-get -y install bison || error "bison 安装失败"
    sudo apt-get -y install gperf || error "gperf 安装失败"
    sudo apt-get -y install build-essential || error "build-essential 安装失败"
    sudo apt-get -y install tofrodos || error "tofrodos 安装失败"
    sudo apt-get -y install python3-markdown || error "python3-markdown 安装失败"
    sudo apt-get -y install xsltproc || error "xsltproc 安装失败"
    sudo apt-get -y install dpkg-dev || error "dpkg-dev 安装失败"
    sudo apt-get -y install libsdl1.2-dev || error "libsdl1.2-dev 安装失败"
    sudo apt-get -y install git-core || error "git-core 安装失败"
    sudo apt-get -y install gnupg || error "gnupg 安装失败"
    sudo apt-get -y install zip || error "zip 安装失败"
    sudo apt-get -y install curl || error "curl 安装失败"
    sudo apt-get -y install zlib1g-dev || error "zlib1g-dev 安装失败"
    sudo apt-get -y install gcc-multilib || error "gcc-multilib 安装失败"
    sudo apt-get -y install libc6-dev-i386 || error "libc6-dev-i386 安装失败"
    sudo apt-get -y install libx11-dev || error "libx11-dev 安装失败"
    sudo apt-get -y install libncurses5-dev || error "libncurses5-dev 安装失败"
    sudo apt-get -y install lib32ncurses5-dev || error "lib32ncurses5-dev 安装失败"
    sudo apt-get -y install x11proto-core-dev || error "x11proto-core-dev 安装失败"
    sudo apt-get -y install libxml2-utils || error "libxml2-utils 安装失败"
    sudo apt-get -y install unzip || error "unzip 安装失败"
    sudo apt-get -y install m4 || error "m4 安装失败"
    sudo apt-get -y install lib32z-dev || error "lib32z-dev 安装失败"
    sudo apt-get -y install ccache || error "ccache 安装失败"
    sudo apt-get -y install libssl-dev || error "libssl-dev 安装失败"
    sudo apt-get -y install gettext || error "gettext 安装失败"
    sudo apt-get -y install python3-mako || error "python3-mako 安装失败"
    sudo apt-get -y install libncurses5 || error "libncurses5 安装失败"
    sudo apt-get -y install python3-chardet || error "python3-chardet 安装失败"
    sudo apt-get -y install python3-markupsafe || error "python3-markupsafe 安装失败"
    sudo apt-get -y install python3-packaging || error "python3-packaging 安装失败"
    sudo apt-get -y install python3-pkg-resources || error "python3-pkg-resources 安装失败"
    sudo apt-get -y install python3-pygments || error "python3-pygments 安装失败"
    sudo apt-get -y install python3-pyparsing || error "python3-pyparsing 安装失败"
    sudo apt-get -y install python3-six || error "python3-six 安装失败"
    sudo apt-get -y install python3-yaml || error "python3-yaml 安装失败"
    sudo apt-get -y install python2 || error "python2 安装失败"
    sudo apt-get -y install python2.7 || error "python2.7 安装失败"
    sudo apt-get -y install python3 || error "python3 安装失败"
    sudo apt-get -y install python3-apport || error "python3-apport 安装失败"
    sudo apt-get -y install python3-apt || error "python3-apt 安装失败"
    sudo apt-get -y install python3-attr || error "python3-attr 安装失败"
    sudo apt-get -y install python3-automat || error "python3-automat 安装失败"
    sudo apt-get -y install python3-blinker || error "python3-blinker 安装失败"
    sudo apt-get -y install python3-certifi || error "python3-certifi 安装失败"
    sudo apt-get -y install python3-cffi-backend || error "python3-cffi-backend 安装失败"
    sudo apt-get -y install python3-click || error "python3-click 安装失败"
    sudo apt-get -y install python3-colorama || error "python3-colorama 安装失败"
    sudo apt-get -y install python3-commandnotfound || error "python3-commandnotfound 安装失败"
    sudo apt-get -y install python3-configobj || error "python3-configobj 安装失败"
    sudo apt-get -y install python3-constantly || error "python3-constantly 安装失败"
    sudo apt-get -y install python3-cryptography || error "python3-cryptography 安装失败"
    sudo apt-get -y install python3-dbus || error "python3-dbus 安装失败"
    sudo apt-get -y install python3-debconf || error "python3-debconf 安装失败"
    sudo apt-get -y install python3-debian || error "python3-debian 安装失败"
    sudo apt-get -y install python3-dev || error "python3-dev 安装失败"
    sudo apt-get -y install python3-distro || error "python3-distro 安装失败"
    sudo apt-get -y install python3-distro-info || error "python3-distro-info 安装失败"
    sudo apt-get -y install python3-distupgrade || error "python3-distupgrade 安装失败"
    sudo apt-get -y install python3-distutils || error "python3-distutils 安装失败"
    sudo apt-get -y install python3-entrypoints || error "python3-entrypoints 安装失败"
    sudo apt-get -y install python3-gdbm || error "python3-gdbm 安装失败"
    sudo apt-get -y install python3-gi || error "python3-gi 安装失败"
    sudo apt-get -y install python3-hamcrest || error "python3-hamcrest 安装失败"
    sudo apt-get -y install python3-httplib2 || error "python3-httplib2 安装失败"
    sudo apt-get -y install python3-hyperlink || error "python3-hyperlink 安装失败"
    sudo apt-get -y install python3-idna || error "python3-idna 安装失败"
    sudo apt-get -y install python3-importlib-metadata || error "python3-importlib-metadata 安装失败"
    sudo apt-get -y install python3-incremental || error "python3-incremental 安装失败"
    sudo apt-get -y install python3-jinja2 || error "python3-jinja2 安装失败"
    sudo apt-get -y install python3-json-pointer || error "python3-json-pointer 安装失败"
    sudo apt-get -y install python3-jsonpatch || error "python3-jsonpatch 安装失败"
    sudo apt-get -y install python3-jsonschema || error "python3-jsonschema 安装失败"
    sudo apt-get -y install python3-jwt || error "python3-jwt 安装失败"
    sudo apt-get -y install python3-keyring || error "python3-keyring 安装失败"
    sudo apt-get -y install python3-launchpadlib || error "python3-launchpadlib 安装失败"
    sudo apt-get -y install python3-lazr.restfulclient || error "python3-lazr.restfulclient 安装失败"
    sudo apt-get -y install python3-lazr.uri || error "python3-lazr.uri 安装失败"
    sudo apt-get -y install python3-lib2to3 || error "python3-lib2to3 安装失败"
    sudo apt-get -y install python3-more-itertools || error "python3-more-itertools 安装失败"
    sudo apt-get -y install python3-nacl || error "python3-nacl 安装失败"
    sudo apt-get -y install python3-netifaces || error "python3-netifaces 安装失败"
    sudo apt-get -y install python3-newt || error "python3-newt 安装失败"
    sudo apt-get -y install python3-oauthlib || error "python3-oauthlib 安装失败"
    sudo apt-get -y install python3-openssl || error "python3-openssl 安装失败"
    sudo apt-get -y install python3-pip || error "python3-pip 安装失败"
    sudo apt-get -y install python3-problem-report || error "python3-problem-report 安装失败"
    sudo apt-get -y install python3-pyasn1 || error "python3-pyasn1 安装失败"
    sudo apt-get -y install python3-pyasn1-modules || error "python3-pyasn1-modules 安装失败"
    sudo apt-get -y install python3-pymacaroons || error "python3-pymacaroons 安装失败"
    sudo apt-get -y install python3-pyrsistent || error "python3-pyrsistent 安装失败"
    sudo apt-get -y install python3-requests || error "python3-requests 安装失败"
    sudo apt-get -y install python3-requests-unixsocket || error "python3-requests-unixsocket 安装失败"
    sudo apt-get -y install python3-secretstorage || error "python3-secretstorage 安装失败"
    sudo apt-get -y install python3-serial || error "python3-serial 安装失败"
    sudo apt-get -y install python3-service-identity || error "python3-service-identity 安装失败"
    sudo apt-get -y install python3-setuptools || error "python3-setuptools 安装失败"
    sudo apt-get -y install python3-simplejson || error "python3-simplejson 安装失败"
    sudo apt-get -y install python3-software-properties || error "python3-software-properties 安装失败"
    sudo apt-get -y install python3-systemd || error "python3-systemd 安装失败"
    sudo apt-get -y install python3-twisted || error "python3-twisted 安装失败"
    sudo apt-get -y install python3-update-manager || error "python3-update-manager 安装失败"
    sudo apt-get -y install python3-urllib3 || error "python3-urllib3 安装失败"
    sudo apt-get -y install python3-wadllib || error "python3-wadllib 安装失败"
    sudo apt-get -y install python3-wheel || error "python3-wheel 安装失败"
    sudo apt-get -y install python3-zipp || error "python3-zipp 安装失败"
    sudo apt-get -y install python3-zope.interface || error "python3-zope.interface 安装失败"
    sudo apt-get -y install python-is-python3 || error "python-is-python3 安装失败"
    sudo apt-get -y install ninja-build || error "ninja-build 安装失败"
    sudo apt-get -y install autoconf || error "autoconf 安装失败"
    echo "----------安装编译构建所需依赖成功----------"
}

################################################################################
# Function Name: aosp_prepare
# Description  : 清理aosp源码
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function aosp_prepare(){
    echo "---------清理并准备aosp源码----------"
    cd $AOSP_PATH || { error "无法进入AOSP目录"; }
    # 删除上次编译产生的目录
    rm -rf vendor || { error "无法删除vendor目录"; }
    # 删除纯净源码中external/mesa3d
    rm -rf external/mesa3d || { error "无法删除external/mesa3d目录"; }
    # 清理AOSP源码中已打的patch
    cd $PATCH_PATH || { error "无法切换到patch目录 $PATCH_PATH"; }
    ./reverse-patch.sh $AOSP_PATH all
    echo "---------aosp源码准备完成----------"
}

################################################################################
# Function Name: make_buildtools
# Description  : 检查buildtools目录是否存在
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function make_buildtools(){
    # 检查buildtools目录是否存在，如果不存在就创建，并为目录拥有者添加读、写和可执行权限
    cd $CURRENT_DIR || error "切换到主目录失败"
    if [ ! -d $buildtools_path ]; then
        mkdir $buildtools_path || error "创建buildtools目录失败"
        chmod -R 700 $buildtools_path || error "修改buildtools目录权限失败"
    fi
}

################################################################################
# Function Name: package_prepare
# Description  : 检查所需依赖包是否齐全
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function package_prepare(){
    echo "---------开始检查所需依赖包是否齐全----------"
    cd $PACKAGE_PATH || error "切换到package目录失败"
    if [ ! -f "${meson_dir}.tar.gz" ]; then
        error "请确保meson已经上传到$PACKAGE_PATH"
    fi
    if [ ! -d "$mesa_src" ]; then
        error "请确保mesa已经上传到$PACKAGE_PATH"
    fi
    cp -r "${meson_dir}.tar.gz" "$buildtools_path" || error "从package目录拷贝meson压缩包到buildtools目录失败"

    echo "---------依赖包齐全----------"
}

################################################################################
# Function Name: install_meson
# Description  : 安装Meson
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function install_meson(){
    echo "---------开始安装meson----------"
    # 检查并解压Meson
    cd $buildtools_path || error "切换到buildtools目录失败"
    echo "---------解压meson---------"
    tar -xvpf "${meson_dir}.tar.gz" || error "Failed to extract meson"
    echo "---------解压完成----------"

    # 检查Meson路径是否已经在PATH中
    meson_path="$buildtools_path/$meson_dir"
    if [[ ":$PATH:" != *":$meson_path:"* ]]; then
        export PATH=$meson_path:$PATH
        echo "Added Meson to PATH in current session"

        # 更新~/.bashrc以确保在新的shell会话中生效
        if ! grep -qF "$meson_path" ~/.bashrc; then
            echo "export PATH=$meson_path:\$PATH" >> ~/.bashrc
            echo "Added Meson to PATH in ~/.bashrc"
        else
            echo "Meson path already exists in ~/.bashrc"
        fi
    else
        echo "Meson path already exists in PATH"
    fi

    MESON_LINK=/usr/local/bin/meson15.py
    if [ ! -f "$MESON_LINK" ]; then
        echo "创建meson.py的软链"
        ln -s $meson_path $MESON_LINK
    fi

    echo "---------安装meson完成----------"
}

################################################################################
# Function Name: merge_external
# Description  : 安装mesa源码, 并替换到aosp源码中
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
# Mesa
function install_mesa() {
    echo "---------开始安装mesa----------"
    local mesa_repo=$PACKAGE_PATH/$mesa_src

    cp -r $mesa_repo $AOSP_PATH/external/mesa3d

    echo "---------安装mesa完成----------"
}

function merge_external(){
    install_mesa
}

main(){
    clean
    build_dependency
    make_buildtools
    package_prepare
    aosp_prepare
    install_meson
    merge_external
    return 0
}

main "$@"
