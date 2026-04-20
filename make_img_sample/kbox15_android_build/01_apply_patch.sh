#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2020-2020. All rights reserved.
# File Name: 01_apply_patch.sh
# Description: 合入相关修改补丁及源码.
# Usage: bash 01_apply_patch.sh
# ******************************************************************************** #

#set -x
# 脚本解释器 强制设置为 bash
if [ "$BASH" != "/bin/bash" ] && [ "$BASH" != "/usr/bin/bash" ]
then
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

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function error(){
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

################################################################################
# Function Name: clean
# Description  : 清理依赖目录
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function clean(){
    echo "---------清理dependency目录---------"
    rm -rf $CURRENT_DIR/dependency
    echo "---------清理dependency目录完成---------"
}

################################################################################
# Function Name: check_package
# Description  : ExaGear转码补丁包、Kbox二进制软件包是否存在
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function check_package(){
    if [ $USE_PREBUILT -eq 1 ]; then
    	echo "---------检查Kbox二进制软件包---------"
    	if ! find "$PACKAGE_PATH" -maxdepth 1 -type f -name "BoostKit-boostcph-kbox_*.zip" | grep -q .
    	then
        	error "检查BoostKit-boostcph-kbox二进制软件包检查失败, 文件不存在"
    	fi
    	echo "---------检查Kbox二进制软件包通过----------"
    fi
}

function apply_patchs(){
    cd $PATCH_PATH || error "无法切换到patch目录 $PATCH_PATH"

    source ./apply-patch.sh $AOSP_PATH

    echo "所有补丁尝试合入完成"
}

################################################################################
# Function Name: kbox_src
# Description  : 合入kbox源码
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function kbox_src(){
    echo "---------合入Kbox src----------"
    cd "$PACKAGE_PATH" || error "无法切换到 $PACKAGE_PATH 目录"

    # 在AOSP源码目录创建vendor/kbox目录, 拷贝Kbox/src/vendor目录至该目录
    mkdir -p "$AOSP_PATH/vendor/kbox" || error "无法创建目录 $AOSP_PATH/vendor/kbox"
    chmod -R 700 "$AOSP_PATH/vendor/kbox" || error "无法修改权限为 700 $AOSP_PATH/vendor/kbox"
    cp -r "$KBOX_SRC_PATH"/src/vendor/kbox/* "$AOSP_PATH"/vendor/kbox/ || error "无法复制文件到 $AOSP_PATH/vendor/kbox"

    echo "---------Success----------"
}

################################################################################
# Function Name: product_prebuilt
# Description  : 合入kbox自研二进制相关源码及补丁
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
# 注意：这里必须保证用户把Android Kbox二进制文件包下载到用户目录下, 不然这里会直接退出
function product_prebuilt(){
    # 检查~/dependency目录是否存在, 如果目录不存在就创建,并为目录拥有者添加读、写和可执行权限
    cd "$CURRENT_DIR" || error "无法切换到 $CURRENT_DIR 目录"
    if [ ! -d "dependency" ]; then
        mkdir "$CURRENT_DIR/dependency" || error "无法创建目录 $CURRENT_DIR/dependency"
        chmod -R 700 "$CURRENT_DIR/dependency" || error "无法修改目录权限 $CURRENT_DIR/dependency"
    fi

    echo "---------合入二进制内容补丁----------"
    cd "$PACKAGE_PATH" || error "无法切换到 $PACKAGE_PATH 目录"

    # 查找匹配的ZIP文件并确认其存在
    zip_files=($(ls BoostKit-boostcph-kbox_*.zip))
    if [ ${#zip_files[@]} -eq 0 ]; then
        error "BoostKit-boostcph-kbox_*.zip不存在"
    fi

    # 复制文件到 $CURRENT_DIR/dependency 目录
    cp "${zip_files[0]}" "$CURRENT_DIR/dependency" ||
        error "无法复制文件 ${zip_files[0]} 到 $CURRENT_DIR/dependency 目录"

    cd "$CURRENT_DIR/dependency" || error "无法切换到 $CURRENT_DIR/dependency 目录"

    # 解压最新下载的zip文件, 并自动覆盖任何现有文件
    unzip -o "${zip_files[0]}" || error "无法解压 ${zip_files[0]}"

    # 继续解压Kbox-BoostKit-boostcph-kbox_*-binary.zip
    binary_packages=$(ls Kbox-BoostKit-boostcph-kbox_*-binary.zip)
    unzip -o  "${binary_packages}" || error "无法解压 $binary_packages"

    # 将二进制内容复制到AOSP源码根目录并处理冲突文件
    cp -rf "$CURRENT_DIR/dependency/product_prebuilt" "$AOSP_PATH/" || error "无法复制文件到 $AOSP_PATH"

    # 在AOSP源码目录创建“vendor/kbox”目录, 拷贝“products”目录至该目录
    mkdir -p "$AOSP_PATH/vendor/kbox" || error "无法创建目录 $AOSP_PATH/vendor/kbox"
    chmod -R 700 "$AOSP_PATH/vendor/kbox" || error "无法修改权限为 700 $AOSP_PATH/vendor/kbox"
    cp -r "$CURRENT_DIR/dependency/products" "$AOSP_PATH/vendor/kbox" || error "无法复制文件到 $AOSP_PATH/vendor/kbox"

    echo "---------Success----------"
}

main(){
    clean
    check_package
    apply_patchs
    if [ $USE_PREBUILT -eq "1" ]; then
        product_prebuilt
    else
        kbox_src
    fi
    return 0
}

main "$@"
