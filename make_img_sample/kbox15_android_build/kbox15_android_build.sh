#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2020-2020. All rights reserved.
# File Name: kbox15_android_build.sh
# Description: android镜像编译总调用脚本.
# Usage: bash kbox15_android_build.sh
# ******************************************************************************** #

# 脚本解释器 强制设置为 bash
if [ "$BASH" != "/bin/bash" ] && [ "$BASH" != "/usr/bin/bash" ]; then
   bash "$0" "$@"
   exit $?
fi

function error(){
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

# root权限执行此脚本
[ "${UID}" -ne 0 ] && error "请使用root权限执行"

# 默认工作目录
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ -z "$CURRENT_DIR" ] && error "获取当前脚本路径失败"
echo "当前脚本的全路径为: $CURRENT_DIR"

# 准备所有编译相关的配置
source ./build.conf

# 检查网络配置参数是否为空
if [ -z "${DNS}" ]; then
    error "请确保DNS已设置"
fi

# 切换到当前目录
cd "${CURRENT_DIR}" || error "切换到当前脚本所在目录失败"

# 获取当前系统的硬件架构
arch=$(uname -m)

# 检查是否为 x86 架构
if [[ "$arch" != "x86_64" ]] && [[ "$arch" != "i686" ]]; then
    error "当前环境不是 x86 架构"
fi

main(){
    source "${CURRENT_DIR}/00_kbox_prepare.sh" "${CURRENT_DIR}" "${AOSP_PATH}" "${PACKAGE_PATH}"
    [ $? -ne 0 ] && error "00_kbox_prepare.sh执行失败"
    echo "00_kbox_prepare OK!!!"
    source "${CURRENT_DIR}/01_apply_patch.sh" "${CURRENT_DIR}" "${AOSP_PATH}" "${PACKAGE_PATH}"
    [ $? -ne 0 ] && error "01_apply_patch.sh执行失败"
    echo "01_apply_patch OK!!!"
    source "${CURRENT_DIR}/02_compile_aosp.sh" "${CURRENT_DIR}" "${AOSP_PATH}" "${PACKAGE_PATH}" "${DNS}"
    [ $? -ne 0 ] && error "02_compile_aosp.sh执行失败"
}

main "$@"|tee kbox_image_build.txt
exit 0
