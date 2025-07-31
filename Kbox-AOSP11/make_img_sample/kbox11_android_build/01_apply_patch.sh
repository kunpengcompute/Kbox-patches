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

# 检查补丁是否已应用的函数
function is_patch_applied(){
    local patch_name=$1
    patch -p1 --dry-run < "$patch_name" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 1 # 补丁未应用
    else
        return 0 # 补丁已应用
    fi
}

################################################################################
# Function Name: check_package
# Description  : ExaGear转码补丁包、Kbox二进制软件包是否存在
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function check_package(){
    echo "---------检查patchForExagear目录---------"
    if [ ! -d "$CURRENT_DIR/../../patchForExagear" ]
    then
        error "检查patchForExagear失败, 目录不存在"
    fi

    echo "---------检查ExaGear转码补丁包---------"
    if [ ! -f "$PACKAGE_PATH/ExaGear_ARM32-ARM64_V2.5.tar.gz" ]
    then
        error "检查ExaGear_ARM32-ARM64_V2.5.tar.gz转码补丁包失败, 文件不存在"
    fi
    echo "---------检查ExaGear转码补丁包通过---------"

    echo "---------检查Kbox二进制软件包---------"
    if ! find "$PACKAGE_PATH" -maxdepth 1 -type f -name "BoostKit-kbox_*.zip" | grep -q .
    then
        error "检查BoostKit-kbox二进制软件包检查失败, 文件不存在"
    fi
    echo "---------检查Kbox二进制软件包通过----------"
}

################################################################################
# Function Name: apply_exagear
# Description  : 合入转码补丁及文件
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function apply_exagear(){
    # 检查~/dependency目录是否存在, 如果目录不存在就创建,并为目录拥有者添加读、写和可执行权限
    cd "$CURRENT_DIR" || error "无法切换到 $CURRENT_DIR 目录"
    if [ ! -d "dependency" ]; then
        mkdir "$CURRENT_DIR/dependency" || error "无法创建目录 $CURRENT_DIR/dependency"
        chmod -R 700 "$CURRENT_DIR/dependency" || error "无法修改目录权限 $CURRENT_DIR/dependency"
    fi
    cp -r "../../patchForExagear" "$CURRENT_DIR/dependency" ||
        error "无法复制文件 patchForExagear 到 $CURRENT_DIR/dependency目录"
    cd "$CURRENT_DIR/dependency/patchForExagear/guestOS/aosp11" ||
        error "无法切换到 $CURRENT_DIR/dependency/patchForExagear/guestOS/aosp11 目录"
    cp 0001-exagear-adapt-android-11.0.0_r48.patch "$AOSP_PATH" ||
        error "无法复制文件 0001-exagear-adapt-android-11.0.0_r48.patch 到 $AOSP_PATH"
    cd "$AOSP_PATH" || error "无法切换到 $AOSP_PATH 目录"

    # 检查0001-exagear-adapt-android-11.0.0_r48.patch补丁是否已应用
    if is_patch_applied "0001-exagear-adapt-android-11.0.0_r48.patch"; then
        echo "0001-exagear-adapt-android-11.0.0_r48.patch 补丁已应用, 跳过"
    else
        echo "正在合入补丁 0001-exagear-adapt-android-11.0.0_r48.patch ..."
        if patch -p1 < "0001-exagear-adapt-android-11.0.0_r48.patch"; then
            echo "补丁 0001-exagear-adapt-android-11.0.0_r48.patch 合入成功"
        else
            error "补丁 0001-exagear-adapt-android-11.0.0_r48.patch 合入失败"
        fi
    fi

    cp "$PACKAGE_PATH/ExaGear_ARM32-ARM64_V2.5.tar.gz" "$CURRENT_DIR/dependency" ||
        error "无法复制文件 $PACKAGE_PATH/ExaGear_ARM32-ARM64_V2.5.tar.gz 到 $CURRENT_DIR/dependency"
    # 将ExaGear转码包（ExaGear_ARM32-ARM64_V2.5.tar.gz）上传至“~/dependency”目录请对上传文件、目录的权限进行合理配置, 其他用户属组建议不配置写权限
    cd "$CURRENT_DIR/dependency/" || error "无法切换到 $CURRENT_DIR/dependency/ 目录"
    sudo tar -xzvf ExaGear_ARM32-ARM64_V2.5.tar.gz || error "无法解压文件 ExaGear_ARM32-ARM64_V2.5.tar.gz"
    sudo chown -R root:root ExaGear_ARM32-ARM64 || error "无法修改目录权限 ExaGear_ARM32-ARM64"
    sudo chmod -R 700 ExaGear_ARM32-ARM64 || error "无法修改目录权限 ExaGear_ARM32-ARM64"
    # 将“~/dependency/ExaGear_ARM32-ARM64”目录下的preubt_a32a64_a64、preubt_a32a64_x64、ubt_a32a64文件
    # 拷贝至“~/dependency/patchForExagear/guestOS/aosp11/vendor/huawei/exagear/prebuilts”目录
    cd "$CURRENT_DIR/dependency/ExaGear_ARM32-ARM64" || error "无法切换到 $CURRENT_DIR/dependency/ExaGear_ARM32-ARM64 目录"
    cp * "$CURRENT_DIR/dependency/patchForExagear/guestOS/aosp11/vendor/huawei/exagear/prebuilts" ||
        error "无法复制文件到$CURRENT_DIR/dependency/patchForExagear/guestOS/aosp11/vendor/huawei/exagear/prebuilts目录"
    # 拷贝“vendor”目录至“aosp”目录下
    cd "$CURRENT_DIR/dependency/patchForExagear/guestOS/aosp11" ||
        error "无法切换到 $CURRENT_DIR/dependency/patchForExagear/guestOS/aosp11 目录"
    cp -r ./vendor "$AOSP_PATH/" || error "无法复制目录 vendor 到 $AOSP_PATH 目录"
}

################################################################################
# Function Name: apply_patch
# Description  : 合入kbox aosp补丁
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################

PATCH_DIR=$CURRENT_DIR/dependency/patchForAndroid

# 合入补丁的函数
function apply_patch(){
    local patch_name=$1
    local patch_path="${patch_name%-*}"  # 从补丁名称中解析出路径
    patch_path="${patch_path//-/\/}"     # 将路径中的-替换成/

    # 完整的目标路径
    local full_path="$AOSP_PATH/$patch_path"

    # 检查目标路径是否存在
    if [ ! -d "$full_path" ]; then
        error "目标路径 $full_path 不存在, 跳过补丁 $patch_name"
    fi

    # 拷贝补丁到目标目录并应用
    cp "$PATCH_DIR/$patch_name" "$full_path" || error "无法复制补丁文件 $PATCH_DIR/$patch_name 到目标目录 $full_path"
    cd "$full_path" || error "无法切换到目标目录 $full_path"
    if is_patch_applied "$patch_name"; then
        echo "补丁 $patch_name 已经应用, 跳过"
    else
        if patch -p1 -N < "$patch_name"; then
            echo "补丁 $patch_name 合入成功"
        else
            error "补丁 $patch_name 合入失败"
        fi
    fi
    cd - > /dev/null || error "无法返回上级目录"
}

function apply_patchs(){
    # 从patch_config.sh文件中读取补丁列表
    if [ ! -f "$CURRENT_DIR/patch_config.sh" ]; then
        error "patch_config.sh不存在"
    fi
    source $CURRENT_DIR/patch_config.sh
    # 解压Kbox-AOSP11.zip, 将Kbox-AOSP11文件夹中的“patchForAndroid”目录上传至“~/dependency”目录
    # 请对上传文件、目录的权限进行合理配置, 其他用户属组建议不配置写权限
    cd "$CURRENT_DIR" || error "无法切换到 $CURRENT_DIR 目录"
    cp -r "../../patchForAndroid" "$CURRENT_DIR/dependency" ||
        error "无法复制文件 patchForAndroid 到 $CURRENT_DIR/dependency目录"
    cd "$CURRENT_DIR/dependency/patchForAndroid" || error "无法切换到 $CURRENT_DIR/dependency/patchForAndroid 目录"
    # 遍历补丁列表并应用每一个补丁
    for patch_name in "${android_patch_wl[@]}"; do
        echo "正在合入补丁 $patch_name ..."
        if ! apply_patch "$patch_name"; then
            error "错误：无法合入补丁 $patch_name."
        fi
    done

    echo "所有补丁尝试合入完成"
}

################################################################################
# Function Name: product_prebuilt
# Description  : 合入kbox自研二进制相关源码及补丁
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
# 注意：这里必须保证用户把Android Kbox二进制文件包下载到用户目录下, 不然这里会直接退出
function product_prebuilt(){
    echo "---------合入二进制内容补丁----------"
    cd "$PACKAGE_PATH" || error "无法切换到 $PACKAGE_PATH 目录"

    # 查找匹配的ZIP文件并确认其存在
    zip_files=($(ls BoostKit-kbox_*.zip))
    if [ ${#zip_files[@]} -eq 0 ]; then
        error "BoostKit-kbox_*.zip不存在"
    fi

    # 复制文件到 $CURRENT_DIR/dependency 目录
    cp "${zip_files[0]}" "$CURRENT_DIR/dependency" ||
        error "无法复制文件 ${zip_files[0]} 到 $CURRENT_DIR/dependency 目录"

    cd "$CURRENT_DIR/dependency" || error "无法切换到 $CURRENT_DIR/dependency 目录"

    # 解压最新下载的zip文件, 并自动覆盖任何现有文件
    unzip -o "${zip_files[0]}" || error "无法解压 ${zip_files[0]}"

    # 继续解压Kbox-BoostKit-kbox_*-binary.zip
    binary_packages=$(ls Kbox-BoostKit-kbox_*-binary.zip)
    unzip -o  "${binary_packages}" || error "无法解压 $binary_packages"

    # 将二进制内容复制到AOSP源码根目录并处理冲突文件
    cp -rf "$CURRENT_DIR/dependency/product_prebuilt" "$AOSP_PATH/" || error "无法复制文件到 $AOSP_PATH"
    rm -rf "$AOSP_PATH/device/generic/goldfish-opengl/system/codecs"
    sed -i 's/include $(GOLDFISH_OPENGL_PATH)\/system\/codecs\/omx/#include $(GOLDFISH_OPENGL_PATH)\/system\/codecs\/omx/g' \
    "$AOSP_PATH/device/generic/goldfish-opengl/Android.mk"

    # 在AOSP源码目录创建“vendor/kbox”目录, 拷贝“products”目录至该目录
    mkdir -p "$AOSP_PATH/vendor/kbox" || error "无法创建目录 $AOSP_PATH/vendor/kbox"
    chmod -R 700 "$AOSP_PATH/vendor/kbox" || error "无法修改权限为 700 $AOSP_PATH/vendor/kbox"
    cp -r "$CURRENT_DIR/dependency/products" "$AOSP_PATH/vendor/kbox" || error "无法复制文件到 $AOSP_PATH/vendor/kbox"

    echo "---------Success----------"
}

main(){
    clean
    check_package
    apply_exagear
    apply_patchs
    product_prebuilt
    return 0
}

main "$@"
