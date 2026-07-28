#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2020-2020. All rights reserved.
# File Name: 02_compile_aosp.sh
# Description: android镜像编译及打包.
# Usage: bash 02_compile_aosp.sh
# ******************************************************************************** #

#set -x
# 脚本解释器 强制设置为 bash
if [ "$BASH" != "/bin/bash" ] && [ "$BASH" != "/usr/bin/bash" ]; then
   bash "$0" "$@"
   exit $?
fi

# 检查必需的环境变量
if ! command -v validate_config >/dev/null 2>&1; then
    echo "Error: validate_config 函数未定义，请确保已加载配置文件"
    exit 1
fi

validate_config || {
    echo "Error: 配置项验证失败"
    exit 1
}

function error(){
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

cpu_num=$(< /proc/cpuinfo grep -c "processor")
hostmemory=$(< /proc/meminfo head -n1|awk '{print $2}')
hostmemory=$((hostmemory/1024/1024/4))
if [ "${cpu_num}" -gt "${hostmemory}" ]
then
    cpu_num=${hostmemory}
    echo "java limit j${hostmemory}"
fi

################################################################################
# Function Name: aosp_compile
# Description  : aosp编译
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function aosp_compile(){
    echo "-----------aosp源码编译-----------"
    cd $AOSP_PATH || error "无法切换到AOSP目录"
    [ -e ~ ] && rm -rf $AOSP_PATH/out
    [ -e ~ ] && rm -rf $AOSP_PATH/create-package.sh
    # 修改kbox.mk文件中的网络配置
    sed -i 's|^[[:space:]]*net\.dns1=.*|    net.dns1='"$DNS"' \\|' "${AOSP_PATH}/vendor/kbox/products/kbox.mk"
    # 生成release key
    rm -rf ./build/target/product/security/release*
    chmod +x ./development/tools/make_key || error "无法设置make_key为可执行"
    echo -e "\n" | ./development/tools/make_key build/target/product/security/releasekey '/C=CN/O=Huawei/CN=kunpeng' ||
        true
    source build/envsetup.sh || error "无法加载build环境"
    lunch kbox_arm64-user || error "lunch命令执行失败"
    export LC_ALL=C
    echo "2" > /proc/sys/kernel/randomize_va_space  #可信需求
    make clean && make -j${cpu_num}
    if [ $? -ne 0 ]; then
        error "aosp编译失败"
        make clean
    fi
    echo "---------Success----------"
}

################################################################################
# Function Name: create_package
# Description  : 镜像打tar包
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function create_package(){
    echo "-----------生成Android镜像包-----------"
    cp -r "$CURRENT_DIR/create-package.sh" "$AOSP_PATH/" || error "无法复制create-package.sh到AOSP目录"
    cd $AOSP_PATH || error "无法切换到AOSP目录"
    chmod +x create-package.sh || error "无法设置create-package.sh为可执行"
    ./create-package.sh $AOSP_PATH/out/target/product/arm64/system.img
    [ $? -ne 0 ] && error "生成Android镜像失败"
    echo "---------Success----------"
}

################################################################################
# Function Name: pack_binary
# Description  : 打包Kbox二进制
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function pack_binary(){
    echo "-----------生成Kbox二进制包-----------"
    KBOX_BUILD_PATH=$KBOX_SRC_PATH/build
    cd $KBOX_BUILD_PATH || error "无法切换到KBOX Build目录"
    ./jenkins_conf.sh package $AOSP_PATH
    echo "---------Success----------"
}

################################################################################
# Function Name: end_of_build
# Description  : 生成MD5文件及清理
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function end_of_build(){
    cd $AOSP_PATH || error "无法切换到AOSP目录"
    md5sum android.tar > android.tar.md5
    echo $AOSP_PATH/android.tar
    echo "---------End----------"
}

main(){
    aosp_compile
    create_package
    if [ $PACK_BINARY -eq 1 ]; then
        pack_binary
    fi
    end_of_build
    return 0
}

main "$@"