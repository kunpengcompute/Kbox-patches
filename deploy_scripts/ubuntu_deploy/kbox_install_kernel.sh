#!/bin/bash

# ******************************************************************************** #
# Copyright Kbox Technologies Co., Ltd. 2023-2023. All rights reserved.
# File Name: kbox_install_kernel.sh
# Description: ubuntu kbox内核编译安装及环境部署。
# Usage: 
# 1.请确认脚本位于：Kbox-AOSP*/deploy_scripts/ubuntu_deploy/
# 2.需使用root用户或sudo命令执行此脚本
# 3.脚本运行格式：
#   [1] 联网模式：该模式下脚本会联网下载所需源码包
#   ./kbox_install_kernel.sh
#   [2] 本地模式：该模式下脚本会会从本地获取源码包，${packages_dir}即本地包所在目录的绝对路径，详见步骤4
#   ./kbox_install_kernel.sh ${packages_dir} 
#   示例： ./kbox_install_kernel.sh /home/kbox_packages/
# 4.若使用"本地模式"运行脚本，需提前上传以下文件到${packages_dir}目录下：("联网模式"无需上传)
#   [1] linux-firmware-20210919.tar.gz (仅amdgpu需要)
#   [2] linux-5.15.98.tar.gz
#   [3] docker-19.03.15.tgz
#   [4] ExaGear_ARM32-ARM64_V2.5.tar.gz
# ******************************************************************************** #

# 脚本解释器 强制设置为 bash
if [ "$BASH" != "/bin/bash" ] && [ "$BASH" != "/usr/bin/bash" ]
then
   bash "$0" "$@"
   exit $?
fi

function error(){
    echo -e "\033[1;31m$1\033[0m"
    exit 1
}

# 操作系统版本
OS_VERSION="ubuntu_20.04"
# linux kernel版本
KERNEL_VERSION="5.15.98"

docker_src="https://download.docker.com/linux/static/stable/aarch64/docker-19.03.15.tgz"
exagear_bin_src="https://kunpeng-repo.obs.cn-north-4.myhuaweicloud.com/Exagear ARM32-ARM64/Exagear ARM32-ARM64 202.0.0/ExaGear_ARM32-ARM64_V2.5.tar.gz"
linux_firmware_src="https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20210919.tar.gz"
linux_firmware_verify_src="https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/sha256sums.asc"
kernel_src="https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.gz"
kernel_verify_src="https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/sha256sums.asc"

# 内核源码存放目录
kernel_dir="/usr/src/"
# 当前目录
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${CURRENT_DIR}" || exit
# 依赖目录
mkdir -p /root/dependency/
work_dir=/root/dependency/
# Kbox_AOSP根目录
kbox_dir=$(cd "${CURRENT_DIR}"/../../ && pwd)
# 本地依赖包目录
packages_dir=$1

cpu_num=$(< /proc/cpuinfo grep -c "processor")

################################################################################
# Function Name: check_local_package
# Description  : 检查本地依赖包
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function check_local_package(){
    [ -e "${packages_dir}/${1}" ] || error "指定路径下无法找到${packages_dir}/${1}"
}

################################################################################
# Function Name: check_local_packages
# Description  : 检查本地依赖包
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function check_local_packages(){
    # 仅amdgpu需准备固件包
    local amd_gpus=($(lspci -D | grep "AMD" | grep -E "VGA|73a3|73a1|73e3" | awk '{print $1}'))
    if [ 0 -ne ${#amd_gpus[@]} ]; then
        check_local_package "linux-firmware-20210919.tar.gz"
    fi
    check_local_package "linux-${KERNEL_VERSION}.tar.gz"
    check_local_package "docker-19.03.15.tgz"
    check_local_package "ExaGear_ARM32-ARM64_V2.5.tar.gz"
}

################################################################################
# Function Name: set_run_mode
# Description  : 选择源码包获取方式
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function set_run_mode(){
    if [ $# -eq 0 ]
    then
        run_mode="Download"
    elif [ $# -eq 1 ]
    then
        run_mode="Local"
    else
        error "The number of input parameters is incorrect."
    fi
}

################################################################################
# Function Name: modify_config
# Description  : config文件修改。
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function modify_config(){
    < ${3} grep -v "#"|grep -w "${1}"
    if [ $? -eq 0 ]
    then
        if [ "${2}" = "n" ]
        then
            sed -i "s|${1}=.*|\# ${1} is not set|g" ${3}
        else
            sed -i "s|${1}=.*|${1}=${2}|g" ${3}
        fi
    else
        if [ "${2}" != "n" ]
        then
            echo "${1}=${2}" >> ${3}
        fi
    fi
    echo "${3} >> $(< ${3} grep -w "${1}")"
}

################################################################################
# Function Name: download_copy_packages
# Description  : 下载/拷贝源码包
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function download_copy_packages(){
    local verify_sha256sums
    local file_sha256sums
    local amd_gpus=($(lspci -D | grep "AMD" | grep -E "VGA|73a3|73a1|73e3" | awk '{print $1}'))
    cd "${work_dir}" || exit
    if [ ${run_mode} = "Download" ]
    then
        echo "[[[[[[[[[[[[[[[[[[[[ STEP 1 源码包下载 ]]]]]]]]]]]]]]]]]]]]"

        # 仅amdgpu需下载固件包
        if [ 0 -ne ${#amd_gpus[@]} ]; then
            local verify_sha256sums=""
            local file_sha256sums=""
            [ -e "sha256sums.asc" ] && rm -rf sha256sums.asc
            echo "---------校验linux固件---------"
            wget -q --show-progress ${linux_firmware_verify_src} --no-check-certificate || error "固件校验文件下载失败"
            verify_sha256sums=$(grep linux-firmware-20210919.tar.gz sha256sums.asc)
            [ -e "linux-firmware-20210919.tar.gz" ] && file_sha256sums=$(sha256sum linux-firmware-20210919.tar.gz)
            if [ "${verify_sha256sums}" != "${file_sha256sums}" ]
            then
                [ -e "linux-firmware-20210919.tar.gz" ] && rm -rf linux-firmware-20210919.tar.gz
                echo "---------下载linux固件---------"
                wget -q --show-progress "${linux_firmware_src}" --no-check-certificate || error "固件下载失败"
            fi
        fi

        verify_sha256sums=""
        file_sha256sums=""
        [ -e "sha256sums.asc" ] && rm -rf sha256sums.asc
        echo "---------校验kernel源码---------"
        wget -q --show-progress ${kernel_verify_src} --no-check-certificate || error "kernel校验文件下载失败"
        verify_sha256sums=$(grep linux-${KERNEL_VERSION}.tar.gz sha256sums.asc)
        [ -e "linux-${KERNEL_VERSION}.tar.gz" ] && file_sha256sums=$(sha256sum linux-${KERNEL_VERSION}.tar.gz)
        if [ "${verify_sha256sums}" != "${file_sha256sums}" ]
        then
            [ -e "linux-${KERNEL_VERSION}.tar.gz" ] && rm -rf linux-${KERNEL_VERSION}.tar.gz
            echo "---------下载kernel源码---------"
            wget -q --show-progress "${kernel_src}" --no-check-certificate || error "kernel源码下载失败"
        fi
        
        echo "---------下载docker---------"
        [ -e "docker-19.03.15.tgz" ] && rm -rf docker-19.03.15.tgz
        wget -q --show-progress "${docker_src}" --no-check-certificate || error "docker下载失败"

        echo "---------下载Exagear二进制---------"
        [ -e "ExaGear_ARM32-ARM64_V2.5.tar.gz" ] && rm -rf ExaGear_ARM32-ARM64_V2.5.tar.gz
        wget -q --show-progress "${exagear_bin_src}" --no-check-certificate || error "Exagear二进制下载失败"
    else
        echo "[[[[[[[[[[[[[[[[[[[[ STEP 1 源码包准备 ]]]]]]]]]]]]]]]]]]]]"
        check_local_packages
        cp "${packages_dir}/docker-19.03.15.tgz" . || exit
        cp "${packages_dir}/ExaGear_ARM32-ARM64_V2.5.tar.gz" . || exit

        if [ 0 -ne ${#amd_gpus[@]} ]; then
            cp "${packages_dir}/linux-firmware-20210919.tar.gz" . || exit
        fi
        cp "${packages_dir}/linux-${KERNEL_VERSION}.tar.gz" . || exit
    fi
}

################################################################################
# Function Name: install_dependency
# Description  : 安装编译构建所需依赖。
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function install_dependency(){
    echo "[[[[[[[[[[[[[[[[[[[[ STEP 2 安装依赖 ]]]]]]]]]]]]]]]]]]]]"
    apt update || exit
    apt install -y dpkg dpkg-dev libncurses5-dev libssl-dev libpciaccess0 \
                   libdrm-amdgpu1 xserver-xorg-video-amdgpu lxc build-essential \
                   libncurses5-dev openssl libssl-dev pkg-config bison flex libelf-dev
}

################################################################################
# Function Name: install_docker
# Description  : 安装预置的docker-*.tgz包。
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function install_docker(){
    local docker_version=$(docker -v | grep "Docker version")
    if [[ -n ${docker_version} ]]
    then
        echo "docker已安装"
        return 0
    fi

    cd ${work_dir} || exit
    [ -e "docker" ] && rm -rf docker
    tar xvpf docker-19.03.15.tgz > /dev/null 2>&1 || error "docker-19.03.15.tgz解压失败"
    cp -p docker/* /usr/bin || exit
    cat >/usr/lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker.socket
[Service]
Type=notify
EnvironmentFile=-/run/flannel/docker
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock --selinux-enabled=false --log-opt max-size=1g
ExecReload=/bin/kill -s HUP $MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl restart docker
    systemctl enable docker
}

################################################################################
# Function Name: enable_exagear
# Description  : 转码使能。
# Parameter    : 
# Returns      : 0 on success, otherwise on fail
################################################################################
function enable_exagear(){
    cd ${work_dir} || exit

    local UBT_PATHS=($(ls ${work_dir}/*/ubt_a32a64 | sed 's/ubt_a32a64//'))
    for PA in ${UBT_PATHS[@]}; do
        rm -rf "${PA}"
    done

    tar -xzvf ExaGear_ARM32-ARM64_V2.5.tar.gz > /dev/null 2>&1 || error "ExaGear_ARM32-ARM64_V2.5.tar.gz解压失败"
    local NEW_UBT_PATHS=$(ls ${work_dir}/*/ubt_a32a64  | sed 's/ubt_a32a64//')
    chown -R root:root "${NEW_UBT_PATHS}"
    chmod -R 700 "${NEW_UBT_PATHS}"
    mkdir -p /opt/exagear
    chmod -R 700 /opt/exagear
    cp -f ${NEW_UBT_PATHS}/ubt_a32a64 /opt/exagear/ || exit
    chmod +x /opt/exagear/ubt_a32a64
}

################################################################################
# Function Name: prepare_environment
# Description  : 环境准备。
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function prepare_environment(){
    echo "[[[[[[[[[[[[[[[[[[[[ STEP 3 环境准备 ]]]]]]]]]]]]]]]]]]]]"
    echo "---------安装docker---------"
    install_docker

    echo "---------使能Exagear---------"
    enable_exagear

    # 仅amdgpu需更新固件
    local amd_gpus=($(lspci -D | grep "AMD" | grep -E "VGA|73a3|73a1|73e3" | awk '{print $1}'))
    if [ 0 -ne ${#amd_gpus[@]} ]; then
        echo "---------更新gpu固件---------"
        cd "${work_dir}" || exit
        [ -e "linux-firmware-20210919" ] && rm -rf linux-firmware-20210919
        tar -xvpf linux-firmware-20210919.tar.gz > /dev/null 2>&1 || error "linux-firmware-20210919.tar.gz解压失败"
        cp -ar linux-firmware-20210919/*gpu /usr/lib/firmware/ || exit
        echo "---------gpu固件更新完毕"
    fi

    echo "---------文件配置---------"
    modify_config "fs.inotify.max_user_instances" "8192" /etc/sysctl.conf
    if [ ! -e "/etc/selinux/config" ]
    then
        touch /etc/selinux/config
        echo "SELINUX=disabled" >> /etc/selinux/config
    else
        modify_config "SELINUX" "disabled" /etc/selinux/config
    fi
    echo "---------以上配置在重启后生效---------"
}

################################################################################
# Function Name: apply_patch
# Description  : 转码及内核补丁合入。
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function apply_patch(){
    echo "[[[[[[[[[[[[[[[[[[[[ STEP 4 合入kernel补丁 ]]]]]]]]]]]]]]]]]]]]"

    cd "${work_dir}" || exit
    [ -e "linux-${KERNEL_VERSION}" ] && rm -rf linux-${KERNEL_VERSION}
    [ -e "linux-kernel-${KERNEL_VERSION}" ] && rm -rf linux-kernel-${KERNEL_VERSION}
    echo "---------解压kernel源码---------"
    tar -zxvf "linux-${KERNEL_VERSION}.tar.gz" > /dev/null 2>&1 || error "linux-${KERNEL_VERSION}.tar.gz解压失败"
    mv linux-${KERNEL_VERSION} linux-kernel-${KERNEL_VERSION}
    [ -e "${kernel_dir}/linux-kernel-${KERNEL_VERSION}" ] && rm -rf ${kernel_dir}/linux-kernel-${KERNEL_VERSION}
    cp -r linux-kernel-${KERNEL_VERSION} ${kernel_dir} || exit
    touch ${kernel_dir}/linux-kernel-${KERNEL_VERSION}/.scmversion

    cd "${kbox_dir}"/patchForExagear/hostOS/ || exit
    cp 0001-exagear-kernel-module.patch "${kernel_dir}"/linux-kernel-"${KERNEL_VERSION}" || exit

    cd "${kbox_dir}"/patchForKernel/"${OS_VERSION}"/kernel_"${KERNEL_VERSION}"/ || exit
    cp *.patch "${kernel_dir}"/linux-kernel-"${KERNEL_VERSION}" || exit

    cd "${kernel_dir}"/linux-kernel-"${KERNEL_VERSION}"/ || exit
    exagear_patch_name=$(ls | grep .patch | grep -m 1 module)
    echo "-- patching ${exagear_patch_name}"
    patch -p1 < ${exagear_patch_name} || exit
    patches_list=$(ls | grep -v module | grep .patch)
    for patch_name in ${patches_list[@]}
    do
        echo "-- patching ${patch_name}"
        patch -p1 < ${patch_name} || exit
    done
}

################################################################################
# Function Name: build_install_kernel
# Description  : 内核及内核模块编译。
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function build_install_kernel(){
    echo "[[[[[[[[[[[[[[[[[[[[ STEP 5 编译&安装kernel ]]]]]]]]]]]]]]]]]]]]"
    echo "---------内核编译---------"
    cd "${kernel_dir}"/linux-kernel-"${KERNEL_VERSION}"/ || exit
    cp /boot/config-$(uname -r) .config || exit
    
    (echo -e \'\\0x65\'; echo -e \'\\0x79\') | make menuconfig > /dev/null 2>&1
    sleep 1

    [ ! -e ".config" ] && error "config file not found"
    modify_config "CONFIG_STAGING" "y" .config
    modify_config "CONFIG_ANDROID" "y" .config
    modify_config "CONFIG_ASHMEM" "y" .config
    modify_config "CONFIG_ANDROID_BINDER_IPC" "y" .config
    modify_config "CONFIG_ANDROID_BINDERFS" "y" .config
    modify_config "CONFIG_ANDROID_ALARM" "y" .config
    modify_config "CONFIG_ANON_VMA_NAME" "y" .config
    modify_config "CONFIG_TANGO32" "y" .config
    modify_config "CONFIG_VFAT_FS" "y" .config
    modify_config "CONFIG_INPUT_UINPUT" "y" .config
    modify_config "CONFIG_HISI_PMU" "y" .config
    modify_config "CONFIG_SYSTEM_TRUSTED_KEYS" "\"\"" .config
    modify_config "CONFIG_DEBUG_INFO" "n" .config
    modify_config "CONFIG_LOCALVERSION" "\"\"" .config
    modify_config "CONFIG_SYSTEM_REVOCATION_KEYS" "\"\"" .config

    (echo -e \'\\0x65\'; echo -e \'\\0x79\') | make menuconfig > /dev/null 2>&1
    sleep 1

    echo "---------内核编译---------"
    make clean && make -j"${cpu_num}"
    [ $? -ne 0 ] && error "内核编译失败"
    echo "---------安装模块---------"
    make modules_install
    [ $? -ne 0 ] && error "模块安装失败"
    echo "---------安装内核---------"
    make install
    [ $? -ne 0 ] && error "内核安装失败"
    echo "---------更新启动项---------"
    grub_default=$(< /boot/grub/grub.cfg grep "Ubuntu, with Linux"|awk -F \' '{print i++ ":"$2}'|grep -v "recovery mode"|grep -w ""${KERNEL_VERSION}"$"|awk -F ':' '{print $1}')
    sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=\"1\> ${grub_default}\"/g" /etc/default/grub
    sed -i "s/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"cgroup_enable=memory swapaccount=1\"/g" /etc/default/grub
    update-grub2
    [ $? -ne 0 ] && error "启动项更新失败"
}

################################################################################
# Function Name: system_reboot
# Description  : 系统重启。
# Parameter    :
# Returns      : 0 on success, otherwise on fail
################################################################################
function system_reboot(){
    echo "[[[[[[[[[[[[[[[[[[[[ STEP 6 重启系统 ]]]]]]]]]]]]]]]]]]]]"
    local reboot_val
    read -p "内核安装与参数配置已完成, 是否重启以生效 [Y/y]" reboot_val

    if [ ${reboot_val} = "Y" ] || [ ${reboot_val} = "y" ]
    then
        echo "---------系统即将重启---------"
        reboot
    else
        echo "---------请稍后手动重启系统---------"
    fi
}

main(){
    set_run_mode $@
    download_copy_packages
    install_dependency
    prepare_environment
    apply_patch
    build_install_kernel
    system_reboot
}

main "$@"
exit 0
