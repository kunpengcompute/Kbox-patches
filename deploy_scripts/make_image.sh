#!/bin/bash
# 本脚本将基于kbox基础云手机镜像、商用二进制包和目标GPU的二进制驱动合并制作云手机镜像，方便用户使用
# 操作命令
# ./make_images.sh [kbox基础云手机镜像名称] [目标GPU Kbox云手机镜像名称] [gpu驱动包名称]
# 脚本至少提供两个参数
#第一个参数：kbox基础云手机镜像名称：kbox:latest
#第二个参数：目标GPU Kbox云手机镜像名称：kbox:latest_{GPU_NAME}
#第三个参数：[gpu驱动包名称] 为可选参数，无该参数时默认制作基于amd GPU 的kbox镜像。soft表示使能软渲染，soft64表示使能纯64位软渲染。
# 例：
# ./make_image.sh kbox:latest kbox:latest_
# ./make_image.sh kbox:latest kbox:latest_ xxxx.tar.gz
# ./make_image.sh kbox:latest kbox:latest_ soft
# ./make_image.sh kbox:latest kbox:latest_ soft64

set -e

CUR_PATH=$(cd $(dirname "${0}");pwd)

GPUTYPE=""
GPU_DRIVER_PACKAGE=
TMP_PACKAGE_DIR=${CUR_PATH}/imageFile
DOCKER_FILE_DIR=${CUR_PATH}/Dockerfiles
DOCKER_FILE_BAK=${CUR_PATH}/Dockerfile.bak
DOCKER_FILE=${CUR_PATH}/Dockerfile
ENABLE_ONLY64_KBOX=0

function gen_docker_file()
{
    local target_docker_file="${DOCKER_FILE_DIR}/Dockerfile_"
    if [ ${GPUTYPE} = "amd" ]; then
        target_docker_file="${target_docker_file}amd"
    elif [ ${GPUTYPE} = "awm" ]; then
        target_docker_file="${target_docker_file}awm"
    elif [ ${GPUTYPE} = "va" ]; then
        target_docker_file="${target_docker_file}va"
    else
        target_docker_file="${target_docker_file}cpu"
    fi

    # 判断Dockerfile是否存在
    if [ ! -f "${target_docker_file}" ]; then
        echo -e "\033[1;31m[ERROR] ${target_docker_file} is not exist. \033[0m" && return -1
    fi

    if [ -f "${DOCKER_FILE}" ]; then
        mv ${DOCKER_FILE} ${DOCKER_FILE_BAK}
    fi

    cp ${target_docker_file} ${DOCKER_FILE}
}

function gen_vagpu_package()
{
    cp -rp ${TMP_PACKAGE_DIR}/va_driver/system/* ${TMP_PACKAGE_DIR}/system/
    rm -rf ${TMP_PACKAGE_DIR}/system/vendor/bin/displayServer
}

function gen_awmgpu_package()
{
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/codec_api/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/codec_api/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/codec_api/firmware/release/* ${TMP_PACKAGE_DIR}/system/etc/firmware/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/egl/arm/libEGL_powervr.so ${TMP_PACKAGE_DIR}/system/vendor/lib/egl/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/egl/arm64/libEGL_powervr.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/egl/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/egl/arm/libIMGegl.so ${TMP_PACKAGE_DIR}/system/vendor/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/egl/arm64/libIMGegl.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/egl/arm/libpvrANDROID_WSEGL.so ${TMP_PACKAGE_DIR}/system/vendor/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/egl/arm64/libpvrANDROID_WSEGL.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm/libGLESv1_CM_powervr.so ${TMP_PACKAGE_DIR}/system/vendor/lib/egl/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm64/libGLESv1_CM_powervr.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/egl/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm/libGLESv2_powervr.so ${TMP_PACKAGE_DIR}/system/vendor/lib/egl/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm64/libGLESv2_powervr.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/egl/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm/libsrv_um.so ${TMP_PACKAGE_DIR}/system/vendor/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm64/libsrv_um.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm/libufwriter.so ${TMP_PACKAGE_DIR}/system/vendor/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm64/libufwriter.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm/libusc.so ${TMP_PACKAGE_DIR}/system/vendor/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/arm64/libusc.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/opengles/firmware/* ${TMP_PACKAGE_DIR}/system/etc/firmware/awmgpu/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/gralloc/arm/* ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/gralloc/arm64/* ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/ifbc/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/ifbc/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/isr/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/isr/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/isr/wbc/ ${TMP_PACKAGE_DIR}/system/etc/firmware/awmgpu/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/libva/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/libva/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/va-api/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/va-api/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/openmax/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/openmax/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/vulkan/arm/* ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/vulkan/arm64/* ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/

    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/c-utils/arm/* ${TMP_PACKAGE_DIR}/system/lib/
    cp -pr ${TMP_PACKAGE_DIR}/awmgpu/c-utils/arm64/* ${TMP_PACKAGE_DIR}/system/lib64/
}

function prepare_gpu_driver()
{
    # 判断Dockerfile是否存在
    if [ ! -d "${DOCKER_FILE_DIR}" ]; then
        echo -e "\033[1;31m[ERROR] ${DOCKER_FILE_DIR} is not exist. \033[0m" && return -1
    fi

    if [ ${GPUTYPE} != "amd" ] && [ ${GPUTYPE} != "cpu" ]; then
        # 解压GPU驱动包（注意：通过--no-same-owner保证解压后的文件属组为当前操作用户（root）文件属组）
        cmd="tar --no-same-owner -zxvf ${GPU_DRIVER_PACKAGE} -C ${TMP_PACKAGE_DIR}"
        echo -e "\033[1;36m[INFO] "$cmd" \033[0m"
        $cmd > /dev/null
    fi

    if [ $GPUTYPE == "awm" ]; then
        gen_awmgpu_package
    elif [ $GPUTYPE == "va" ]; then
        gen_vagpu_package
    fi

    gen_docker_file
}

# 当前目录下有商用二进制压缩包时，使用该压缩包；如不存在该压缩包，跳过该步骤。避免覆盖用户自己编译镜像中的二进制。
function prepare_kbox_binary()
{
    if [ -z $(ls | grep BoostKit-kbox_*.zip) ];then
        echo -e -n "\033[1;31m[INFO] kbox binary package is not exist, "
        echo -e "make sure ${DOCKER_IMAGE_IN} contain kbox binary. \033[0m" && return 0
    fi
    BoostKit_package=$(ls BoostKit-kbox_*.zip)
    unzip -o "${BoostKit_package}" -d ${TMP_PACKAGE_DIR} > /dev/null
    binary_packages=$(ls ${TMP_PACKAGE_DIR}/Kbox-*-*-binary.zip)
    unzip -o "${binary_packages}" -d ${TMP_PACKAGE_DIR} > /dev/null
    BinaryPath=${TMP_PACKAGE_DIR}/product_prebuilt

    cp ${BinaryPath}/gbm_gralloc/lib64/hw/gralloc.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
    [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/gbm_gralloc/lib/hw/gralloc.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/audio/lib/hw/audio.primary.kbox.so ${TMP_PACKAGE_DIR}/system/lib/hw/
    cp ${BinaryPath}/audio/lib64/hw/audio.primary.kbox.so ${TMP_PACKAGE_DIR}/system/lib64/hw/
    [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/gps/lib/hw/gps.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    cp ${BinaryPath}/gps/lib64/hw/gps.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/

    [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/omx/lib/* ${TMP_PACKAGE_DIR}/system/vendor/lib/
    cp ${BinaryPath}/omx/lib64/* ${TMP_PACKAGE_DIR}/system/vendor/lib64/

    if [ $GPUTYPE = "awm" ]; then
        [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/product_hwcomposer/lib/hw/hwcomposer.awmgpu.so ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
        cp ${BinaryPath}/product_hwcomposer/lib64/hw/hwcomposer.awmgpu.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
    elif [ $GPUTYPE = "amd" ] || [ $GPUTYPE = "cpu" ]; then
        [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/product_hwcomposer/lib/hw/hwcomposer.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
        cp ${BinaryPath}/product_hwcomposer/lib64/hw/hwcomposer.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
    fi

    [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/sensors/lib/hw/sensors.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    cp ${BinaryPath}/sensors/lib64/hw/sensors.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
    cp ${BinaryPath}/vinput/bin/vinput ${TMP_PACKAGE_DIR}/system/vendor/bin/
    cp ${BinaryPath}/vinput/vinput.rc ${TMP_PACKAGE_DIR}/system/vendor/etc/init/vinput.rc

    if [ $GPUTYPE != "cpu" ]; then
        cp ${BinaryPath}/RenderAccLayer/lib64/hw/AdaptiveVsync.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
    fi
    [ $ENABLE_ONLY64_KBOX -eq 1 ] || cp ${BinaryPath}/RenderAccLayer/lib/hw/RenderAccLayer.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    cp ${BinaryPath}/RenderAccLayer/lib64/hw/RenderAccLayer.kbox.so ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
}

function prepare_file_system()
{
    # 判断目录是否存在，若存在则删除重建
    if [ -d "${TMP_PACKAGE_DIR}" ]; then
        rm -rf ${TMP_PACKAGE_DIR}
    fi
    mkdir -p ${TMP_PACKAGE_DIR}/system/lib/hw
    mkdir -p ${TMP_PACKAGE_DIR}/system/lib64/hw
    mkdir -p ${TMP_PACKAGE_DIR}/system/vendor/lib/hw/
    mkdir -p ${TMP_PACKAGE_DIR}/system/vendor/lib64/hw/
    mkdir -p ${TMP_PACKAGE_DIR}/system/vendor/bin/
    mkdir -p ${TMP_PACKAGE_DIR}/system/vendor/etc/init/
    if [ $GPUTYPE = "awm" ]; then
        mkdir -p ${TMP_PACKAGE_DIR}/system/etc/firmware/awmgpu/
        mkdir -p ${TMP_PACKAGE_DIR}/system/vendor/lib/egl/
        mkdir -p ${TMP_PACKAGE_DIR}/system/vendor/lib64/egl/
    fi
}

function detect_gpu_type()
{
    XD_GPU_ID="1fe0:1010"
    VA_GPU_ID=":0200"
    local xd_gpus=($(lspci -D | grep ${XD_GPU_ID} | awk '{print $1}'))
    local va_gpus=($(lspci -D | grep ${VA_GPU_ID} | awk '{print $1}'))
    local amd_gpus=($(lspci -D | grep "AMD" | grep -E "VGA|73a3|73a1|73e3" | awk '{print $1}'))

    if [ "${GPU_DRIVER_PACKAGE}" == "soft" ]; then
        GPUTYPE="cpu"
        echo -e "\033[1;36m[INFO] Enable soft render... \033[0m"
        return 0
    fi

    if [ "${GPU_DRIVER_PACKAGE}" == "soft64" ]; then
        GPUTYPE="cpu"
        ENABLE_ONLY64_KBOX=1
        echo -e "\033[1;36m[INFO] Enable only64 soft render... \033[0m"
        return 0
    fi

    if [ 0 -ne ${#amd_gpus[@]} ]; then
        GPUTYPE="amd"
        if [ "${GPU_DRIVER_PACKAGE}" != "" ]; then
            echo -e "\033[1;31m[INFO] amd gpu doesn't need driver package, ignore: ${GPU_DRIVER_PACKAGE}. \033[0m"
            return 0
        fi
    elif [ 0 -ne ${#va_gpus[@]} ]; then
        GPUTYPE="va"
        if [ "${GPU_DRIVER_PACKAGE}" != "va"* ] || [ -z $(ls | grep "${GPU_DRIVER_PACKAGE}") ]; then
            echo -e -n "\033[1;31m[ERROR] please check gpu driver package "
            echo -e "and make sure it match the gpu type. \033[0m" && exit -1
        fi
    elif [ 0 -ne ${#xd_gpus[@]} ]; then
        GPUTYPE="awm"
        if [ "${GPU_DRIVER_PACKAGE}" != "awmgpu"* ] || [ -z $(ls | grep "${GPU_DRIVER_PACKAGE}") ]; then
            echo -e -n "\033[1;31m[ERROR] please check gpu driver package "
            echo -e "and make sure it match the gpu type. \033[0m" && exit -1
        fi
    else
        echo -e "\033[1;31m[ERROR] unsupport gpu type." && exit -1
    fi
}

# 制作镜像
function make_image()
{
    cmd="docker build --build-arg KBOX_IMAGE=${DOCKER_IMAGE_IN} -t ${DOCKER_IMAGE_OUT} ."
    echo -e "\033[1;36m[INFO] "$cmd" \033[0m"
    $cmd
    wait
}

function main()
{
    echo -e "\033[1;36m[INFO] Begin to make image \033[0m"
    local start_time=$(date +%s)
    local end_time=0

    if [ $# -ne 2 ] && [ $# -ne 3 ]; then
        echo -e "\033[1;31m[ERROR] input args should include base image, image to be made and gpu driver package\033[0m"
        exit -1;
    fi

    DOCKER_IMAGE_IN="$1"
    DOCKER_IMAGE_OUT="$2"

    if [ -n "$3" ]; then
        GPU_DRIVER_PACKAGE=$3
    fi

    detect_gpu_type
    prepare_file_system
    prepare_kbox_binary
    prepare_gpu_driver

    make_image
    [ ${?} != 0 ] && echo -e "\033[1;31m[ERROR] Failed to make image. \033[0m" && exit -1

    # 制作镜像时间统计
    end_time=$(date +%s)
    time_interval=$((${end_time}-${start_time}))
    echo -e "\033[1;36m[INFO] End to make image from ${DOCKER_IMAGE_IN} to ${DOCKER_IMAGE_OUT} \033[0m"
    echo -e "\033[1;36m[INFO] Make image takes ${time_interval} seconds. \033[0m"
}

main "$@"
