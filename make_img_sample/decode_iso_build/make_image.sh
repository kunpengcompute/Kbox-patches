#!/bin/bash
# 本文件将基于kbox基础云手机镜像和NEIINT编解码相关的二进制制作解码镜像
# 操作命令
# ./make_images.sh [kbox基础云手机镜像名称] [解码镜像名称]
# 参数可选，默认为kbox基础云手机镜像名称：kbox:origin，编解码镜像名称：kbox:latest
# 例：
# ./make_image.sh
# ./make_image.sh kbox:origin
# ./make_image.sh kbox:origin kbox:latest

set -e

CUR_PATH=$(cd $(dirname "${0}");pwd)

# kbox原始基础云手机和编解码默认镜像名称，可根据需要自行修改
DOCKER_IMAGE_KBOX=kbox:origin
DOCKER_IMAGE_KBOX_LATEST=kbox:latest

DOCKER_FILE=${CUR_PATH}/Dockerfile
DOCKER_FILE_CANDIDATE=${CUR_PATH}/Dockerfile

DEMO_NETINT_PACKAGE=${CUR_PATH}/NETINT.tar.gz

TMP_DEMO_DIR=${CUR_PATH}/NETINT

# 检查nvme指令
function check_nvme_command()
{
    cmd="nvme --help"
    $cmd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31m[ERROR] nvme command unavailable, please install nvme-cli. \033[0m"
        exit -1
    fi
}

function check_vpu()
{
    check_nvme_command
    cmd="nvme list"
    output=$($cmd)

    if echo "$output" | grep -q "QuadraT2A"; then
        echo -e "\033[1;36m[INFO] make image for QuadraT2A \033[0m"
        DOCKER_FILE_CANDIDATE=${CUR_PATH}/Dockerfile_QuadraT2A
    else
        echo -e "\033[1;36m[INFO] make image without vpu \033[0m"
    fi

    # 判断Dockerfile是否存在
    if [ ! -f "${DOCKER_FILE}" ]; then
        echo -e "\033[1;31m[ERROR] ${DOCKER_FILE} is not exist. \033[0m" && return -1
    fi

    cp ${DOCKER_FILE_CANDIDATE} ${DOCKER_FILE}
}
# 前置条件验证
function check_env()
{
    check_vpu

    # 判断DECODE原型包是否存在
    if [ ! -f "${DEMO_NETINT_PACKAGE}" ]; then
        echo -e "\033[1;31m[ERROR] ${DEMO_NETINT_PACKAGE} is not exist. \033[0m" && return -1
    fi

    # 判断DECODE原型包目录是否存在，若存在则删除重建
    if [ -d "${TMP_DEMO_DIR}" ]; then
        rm -rf ${TMP_DEMO_DIR}
    fi
    mkdir -p ${TMP_DEMO_DIR}

    # 解压DECODE原型包（注意：通过--no-same-owner保证解压后的文件属组为当前操作用户（root）文件属组）
    cmd="tar --no-same-owner -zxvf ${DEMO_NETINT_PACKAGE} -C ${TMP_DEMO_DIR}"
    echo -e "\033[1;36m[INFO] "$cmd" \033[0m"
    $cmd > /dev/null
}

# 制作镜像
function make_image()
{
    if [ -n "$1" ]; then
        DOCKER_IMAGE_KBOX="$1"
    fi
    if [ -n "$2" ]; then
        DOCKER_IMAGE_KBOX_LATEST="$2"
    fi
    cmd="docker build --build-arg KBOX_IMAGE=${DOCKER_IMAGE_KBOX} -t ${DOCKER_IMAGE_KBOX_LATEST} ."
    echo -e "\033[1;36m[INFO] "$cmd" \033[0m"
    $cmd
    wait
}

function main()
{
    echo -e "\033[1;36m[INFO] Begin to make image \033[0m"
    # 构建镜像
    local start_time=$(date +%s)
    local end_time=0

    check_env
    [ ${?} != 0 ] && echo -e "\033[1;31m[ERROR] Failed to check environment. \033[0m" && exit -1

    make_image "$@"
    [ ${?} != 0 ] && echo -e "\033[1;31m[ERROR] Failed to make image. \033[0m" && exit -1

    # 制作镜像时间统计
    end_time=$(date +%s)
    time_interval=$((${end_time}-${start_time}))
    echo -e "\033[1;36m[INFO] End to make image from ${DOCKER_IMAGE_KBOX} to ${DOCKER_IMAGE_KBOX_LATEST} \033[0m"
    echo -e "\033[1;36m[INFO] Make image takes ${time_interval} seconds. \033[0m"
}

main "$@"
