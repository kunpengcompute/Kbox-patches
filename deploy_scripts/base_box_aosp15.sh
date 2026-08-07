#!/bin/bash
# Copyright Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
#set -x

XD_GPU_ID="1fe0:1010"
VA_SGPU100_ID=":0200"

# CPU/GPU/编码卡绑定映射表（由 bb_init_cpu_gpu_maps / bb_select_* 填充）
CPU_MAP=()
GPU_MAP=()
VPU_MAP=()
ENC_MAP=()
USERDATA_MAP=()
VSYNC_OFFSET_MAP=()
HANBO_MAP=()

#===============================================================================
# 统一日志函数（bb_ 前缀标识归属 base_box_aosp15.sh）
#===============================================================================
function bb_log_info() {
    echo -e "\033[1;36m[INFO] $@\033[0m"
}

function bb_log_warn() {
    echo -e "\033[1;32m[WARNING] $@\033[0m"
}

function bb_log_error() {
    echo -e "\033[1;31m[ERROR] $@\033[0m"
}

function bb_exit_error() {
    bb_log_error "$@" ; exit 1
}

#===============================================================================
# Functions
#===============================================================================

# 初始化运行时环境变量（THISDIR、DEFAULT_RUNTIME、RUNTIME_CMD）
# 调用方在 source base_box_aosp15.sh 后需主动调用此函数
function bb_init_runtime_env() {
    THISDIR=$(readlink -ef $(dirname ${BASH_SOURCE[0]}))
    CONTAINERD_CONFIG=$THISDIR/containerd_config
    BUILD_PROP=$THISDIR/build.prop
    LOCAL_PROP=$THISDIR/local.prop
    if [ ! -f $LOCAL_PROP ]; then
        touch $LOCAL_PROP
        chmod 600 $LOCAL_PROP
    fi

    if [ -f "$CONTAINERD_CONFIG" ]; then
        DEFAULT_RUNTIME=containerd
        RUNTIME_CMD=nerdctl
    else
        DEFAULT_RUNTIME=docker
        RUNTIME_CMD=docker
    fi
}

function bb_check_environment() {
    # root权限执行此脚本
    if [ "${UID}" -ne 0 ]; then
        echo  "请使用root权限执行"
        exit 1
    fi

    # 支持非当前目录执行
    CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    cd ${CURRENT_DIR}

    bb_check_devices

     # 如果是需要转码的机型，在使用脚本过程中检查转码
    local VENDOR_ID=$(lscpu | grep "Vendor ID:" | grep -v "BIOS" | awk '{print $3}')
    if [ x"$VENDOR_ID" == x"0x48" ] || [ x"$VENDOR_ID" == x"HiSilicon" ]; then
	    bb_check_exagear
    fi

    # 清理/dev/目录下的全部loop device节点，并在/dev/loop_device/目录下提前生成足够数量的设备节点
    if [ "$1" == "start" ] || [ "$1" == "restart" ]; then
        bb_prepare_loop_device
    fi

    # 检查必要的环境配置
    bb_check_selinux
    bb_check_max_user_instances
    bb_check_cgroup_v2
    
    # 关闭udev相关服务
    bb_stop_udev_services
}

function bb_check_devices() {
    # 确定kernel版本
    local KERNEL_VERSION=$(uname -r)

    chmod 600 /dev/dri/*
    chmod 600 /dev/input

    if bb_has_xd_gpu; then
        chmod 666 /dev/ion*
        chmod 666 /dev/pvr_sync
    fi
}

function bb_get_lxcfs_path() {
    local value
    if [ -d "/var/lib/lxc/lxcfs" ]; then
        value="/var/lib/lxc/lxcfs"
    elif [ -d "/var/lib/lxcfs" ]; then
        value="/var/lib/lxcfs"
    else
        echo "error, fail to get lxcfs path"
        exit 1
    fi

    echo ${value}
}

function bb_check_nfs_mount() {
    local nfs_dir=$1
    
    if [ ! -d "$nfs_dir" ]; then
        echo -e "\033[1;31m[ERROR] NFS目录 ${nfs_dir} 不存在！\033[0m"
        exit 1
    fi
    
    if ! mountpoint -q "$nfs_dir"; then
        echo -e "\033[1;31m[ERROR] NFS目录 ${nfs_dir} 不是挂载点！\033[0m"
        exit 1
    fi
    
    if ! mount | grep " ${nfs_dir} " | grep -qE " type nfs| type nfs4"; then
        echo -e "\033[1;31m[ERROR] NFS目录 ${nfs_dir} 不是NFS远端挂载目录！\033[0m"
        exit 1
    fi
    
    echo "NFS目录 ${nfs_dir} 检查通过"
    return 0
}

function bb_get_closest_numas() {
    local NUM_OF_NUMA=$(lscpu | grep "NUMA node(s)" | awk '{print $3}')

    local CPU_LIST_ARRAY=
    for ((NUMA=0; NUMA<${NUM_OF_NUMA}; NUMA++))
    do
        CPU_LIST_ARRAY[$NUMA]=$(cat /sys/devices/system/node/node${NUMA}/cpulist |sed "s/-/ /")
    done

    local CPU_LIST=
    for CPU in $@
    do
        for ((NUMA=0; NUMA<${NUM_OF_NUMA}; NUMA++))
        do
            # 将带空格的文本转换成array，其中第一个元素是最小值，第二个元素是最大值
            CPU_LIST=(${CPU_LIST_ARRAY[$NUMA]})
            if (( ${CPU} >= ${CPU_LIST[0]} )) && (( ${CPU} <= ${CPU_LIST[1]} ))
            then
                echo $NUMA
            fi
        done
    done
}

# 获取宿主机 CPU 核数
function bb_get_num_of_cpus() {
    lscpu | grep -w "CPU(s)" | head -n 1 | awk '{print $2}'
}

# 获取宿主机 NUMA 节点数
function bb_get_num_of_numas() {
    lscpu | grep -w "NUMA node(s)" | awk '{print $3}'
}

# 从容器 inspect 获取数据卷挂载根目录
# 优先从容器 mount source 反推，失败时 fallback 到 USERDATA 变量
# 参数：$1=容器名
# 输出：挂载根目录路径
function bb_get_mount_dir() {
    local box_name=$1
    local mount_source
    if [ "$DEFAULT_RUNTIME" == "docker" ]; then
        mount_source=$($RUNTIME_CMD inspect --format='{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}' "$box_name" 2>/dev/null)
    else
        mount_source=$($RUNTIME_CMD inspect --mode=native --format='{{range .Spec.mounts}}{{if eq .destination "/data"}}{{.source}}{{end}}{{end}}' "$box_name" 2>/dev/null)
    fi

    if [ -n "$mount_source" ]; then
        local mount_dir=$(echo "$mount_source" | sed "s|/data/${box_name}/data$||")
        if [ "$mount_dir" == "$mount_source" ]; then
            mount_dir=$(dirname "$mount_source")
        fi
        echo "$mount_dir"
    else
        echo "${USERDATA:-/home/mount}"
    fi
}


function bb_wait_async_cmd() {
    eval $1
    local pid=$(jobs -rp)
    local count_time=0
    while true; do
        local count=$(jobs -rp | wc -l)
        if [ ${count} -eq 0 ]; then
            wait ${pid}
            echo $?
            break
        fi

        if [ ${count_time} -gt 8 ]; then
            kill -9 ${pid}
            echo -1
            break
        fi

        sleep 0.5
        count_time=$((count_time + 1))
    done
}

function bb_wait_container_ready() {
    local box_name=$1
    local timeout=${2:-200}
    local enable_restart=${3:-1}
    local starttime=$(date +%s)
    local currenttime=$starttime
    local endtime=$(($starttime+$timeout))
    local has_restart=0

    local mount_dir=$(bb_get_mount_dir "${box_name}")

    while [ "$currenttime" -lt "$endtime" ] ; do
        printf "\r%03d/%03d" $(($currenttime-$starttime)) $timeout
        sleep 1
        local cmd="$RUNTIME_CMD exec -i ${box_name} getprop sys.boot_completed | grep 1 > /dev/null 2>&1 &"
        local result=$(bb_wait_async_cmd "${cmd}")
        if [ "${result}" == "0" ]; then
            bb_check_key_process ${box_name}
            if [ $? -ne 0 ] && [ "$enable_restart" = "1" ]; then
                has_restart=1
                BB_NAME="${box_name}"
                BB_USER_DATA_PATH="${mount_dir}"
                BB_RESTART_TIMES=2
                bb_restart_box
                if [ $? -eq 1 ] && [ $has_restart -eq 1 ]; then
                    bb_log_error "${box_name} started failed at $(date +'%Y-%m-%d %H:%M:%S')!"
                    printf "\r\033[1;31m%03d/%03d\033[0m\n" $(($currenttime-$starttime)) $timeout
                    return 1
                fi
            fi
            bb_log_info "${box_name} started successfully at $(date +'%Y-%m-%d %H:%M:%S')!"
            printf "\r\033[1;32m%03d/%03d\033[0m\n" $(($currenttime-$starttime)) $timeout
            return 0
        elif [ "${result}" == "-1" ]; then
            bb_log_warn "${box_name} bb_wait_async_cmd timeout, exit and continue!"
        fi
        currenttime=$(date +%s)
    done
    printf "\r\033[1;31m%03d/%03d\033[0m\n" $(($currenttime-$starttime)) $timeout
    bb_log_error "Start check timed out, ${box_name} unable to start"
    return 1
}

function bb_check_encode_card()
{
    # 检查nvme指令
    cmd="nvme --help"
    $cmd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "nvme command unavailable, cannot auto detect vpu"
        return 0
    fi
 
    cmd="nvme list"
    output=$($cmd 2>/dev/null)
}

function bb_prepare_media_codecs_for_amd() {
    local container_name=$1
    if bb_has_amd_gpu; then
        if [ ${T432_QUADRA_DECODE_ENABLE} -ne 1 ]; then
            $RUNTIME_CMD cp ${container_name}:/system/vendor/etc/media_codecs.xml .
            if ! grep -q '<!--.*<Decoders>' media_codecs.xml; then
                sed -i '/<Decoders>/,/<\/Decoders>/s/<Decoders>/<!-- &/' media_codecs.xml
                sed -i '/<Decoders>/,/<\/Decoders>/s/<\/Decoders>/& -->/' media_codecs.xml
            fi
            $RUNTIME_CMD cp ./media_codecs.xml ${container_name}:/system/vendor/etc/
        else
            $RUNTIME_CMD cp ${container_name}:/system/vendor/etc/media_codecs.xml .
            sed -i '/<!--.*<Decoders>/s/^[[:space:]]*<!--[[:space:]]*//' media_codecs.xml
            sed -i '/<Decoders>/,/<\/Decoders>/s/ -->$//' media_codecs.xml
            $RUNTIME_CMD cp ./media_codecs.xml ${container_name}:/system/vendor/etc/
        fi
    fi
}

function bb_prepare_media_codecs_c2() {
    local container_name=$1
    local enable_hard_decode=$2
    bb_log_info "bb_prepare_media_codecs_c2: ENABLE_HARD_DECODE=${enable_hard_decode}"
    if [ "${enable_hard_decode}" == "0" ]; then
        $RUNTIME_CMD exec ${container_name} sh -c "[ -f /vendor/etc/media_codecs_c2.xml ]" 2>/dev/null
        if [ $? -eq 0 ]; then
            bb_log_info "Rename vendor/etc/media_codecs_c2.xml to media_codecs_c2.bak"
            $RUNTIME_CMD exec ${container_name} mv /vendor/etc/media_codecs_c2.xml /vendor/etc/media_codecs_c2.bak
        fi
    elif [ "${enable_hard_decode}" == "1" ]; then
        $RUNTIME_CMD exec ${container_name} sh -c "[ ! -f /vendor/etc/media_codecs_c2.xml ]" 2>/dev/null
        if [ $? -eq 0 ]; then
            $RUNTIME_CMD exec ${container_name} sh -c "[ -f /vendor/etc/media_codecs_c2.bak ]" 2>/dev/null
            if [ $? -eq 0 ]; then
                bb_log_info "Rename vendor/etc/media_codecs_c2.bak back to media_codecs_c2.xml"
                $RUNTIME_CMD exec ${container_name} mv /vendor/etc/media_codecs_c2.bak /vendor/etc/media_codecs_c2.xml
            fi
        fi
    fi
}

# 检查F2FS和NFS冲突，参数：enable_nfs (0/1)
function bb_check_nfs_f2fs_conflict() {
    local enable_nfs=$1
    if [ "$ENABLE_F2FS" == "1" ] && [ "$enable_nfs" == "1" ]; then
        bb_log_error "不可以同时使能F2FS和NFS！"
        bb_log_error "当前配置：ENABLE_F2FS=1，使用nstart命令（NFS挂载）"
        bb_log_error "请将ENABLE_F2FS设置为0，或使用start命令（本地挂载）"
        exit 1
    fi
}

#===============================================================================
# base_box_aosp15.sh 容器管理：启动、重启
# BB_* 全局配置变量（调用方在调用 bb_start_box / bb_restart_box / bb_delete_box 前设置）
# 所有变量以 BB_ 前缀标识归属 base_box_aosp15.sh，避免与调用方变量冲突。
#-------------------------------------------------------------------------------
# BB_NAME               容器名称（如 kbox_1、android_1）
# BB_CPUS               CPU 列表（空格分隔，如 "0 1 2 3"）
# BB_NUMAS              NUMA 节点列表（空格分隔，如 "0 0"）
# BB_GPUS_RENDER        GPU render 设备路径列表（空格分隔，如 "/dev/dri/renderD128"）
# BB_STORAGE_SIZE_GB    存储镜像大小（GB）
# BB_RAM_SIZE_MB        内存限制（MB）
# BB_PORTS              端口映射列表（空格分隔，格式 "host:container"）
# BB_EXTRA_RUN_OPTION   额外的运行时选项字符串
# BB_IMAGE_NAME         容器镜像名称（如 kbox:test）
# BB_USER_DATA_PATH     用户数据根目录（如 /root/mount）
# BB_CONTAINER_DATA_PATH 容器运行时数据目录（留空则自动推断）
# BB_ENABLE_RENDER_LAYER 是否启用渲染中间层（"1"=启用）
# BB_ENABLE_F2FS        是否启用 F2FS 文件系统（"1"=启用）
# BB_SYSTEM_SIZE_MB     /system 分区大小（MB，0=不修改）
# BB_ENABLE_NFS         是否启用 NFS 存储（"1"=启用）
# BB_NFS_DIR            NFS 目录路径
# BB_RESTART_TIMES      重启最大次数（默认 3，仅 bb_restart_box 使用）
# BB_ENABLE_HARD_DECODE 是否启用硬解码（"1"=启用，仅 bb_restart_box 使用）
# BB_KEEP_DATA          删除时是否保留数据（0=删除, 1=保留, 2=保留且使用NFS路径，仅 bb_delete_box 使用）
#===============================================================================

function bb_create_data_img() {
    local data_dir_path=${USER_DATA_PATH}/data/$BOX_NAME # 云机数据分区路径
    local data_img_path=${USER_DATA_PATH}/img/$BOX_NAME.img # 云机数据卷镜像路径
    local volume_data_path=${data_dir_path}/data

    local base_dir_path=${USER_DATA_PATH}/data/android_base # android_base路径
    local base_data_path=${base_dir_path}/data
    
    # 若无android_base的卷，先创建
    if [ ! "$($RUNTIME_CMD volume ls -q 2>/dev/null|grep -w android_base)" ]; then
        bb_log_info "create android_base"
        $RUNTIME_CMD volume create android_base
    fi

    # 若数据卷镜像不存在，创建
    if [ ! -e $data_img_path ]; then
        fallocate -l ${STORAGE_SIZE_GB}G $data_img_path
        if [ "$ENABLE_F2FS" == "1" ]; then
            yes | mkfs.f2fs $data_img_path
        else
            yes | mkfs -t ext4 $data_img_path
        fi
    fi

    # 若数据目录不存在，创建
    if [ ! -d "${data_dir_path}" ]; then
        mkdir -p $data_dir_path
    fi

    # 挂载数据卷镜像到数据目录
    if [ "$ENABLE_F2FS" == "1" ]; then
        mount -t f2fs -o loop $data_img_path $data_dir_path
    else
        mount $data_img_path $data_dir_path
    fi
    mkdir -p $data_dir_path/data

    # 若android_base存在数据，且未跳过复制，基于android_base启动
    if [ "$(ls $base_data_path 2>/dev/null)" != "" ] && [ "$SKIP_DATA_COPY" != "1" ]; then
        bb_log_info "copy ${BOX_NAME} from android_base"
        cp -r -p ${base_data_path}/* ${volume_data_path}/ 2>/dev/null
    fi

    # 每次容器启动后重新创建containerid文件，在启动前要清理
    if [ -e $volume_data_path/containerid ]; then
        rm -rf $volume_data_path/containerid
    fi

    echo $(($STORAGE_SIZE_GB * 2 * 1024 * 1024)) >$data_dir_path/storage_size
}

function bb_start_box() {
    ########################## 1. 读取 BB_* 全局配置 ##########################
    echo "------------------ Kbox Startup ------------------"
    local BOX_NAME="${BB_NAME}"
    local CPUS=(${BB_CPUS})
    local NUMAS=(${BB_NUMAS})
    local GPUS_RENDER=(${BB_GPUS_RENDER})
    local STORAGE_SIZE_GB="${BB_STORAGE_SIZE_GB}"
    local RAM_SIZE_MB="${BB_RAM_SIZE_MB}"
    local PORTS=(${BB_PORTS})
    local EXTRA_RUN_OPTION="${BB_EXTRA_RUN_OPTION}"
    local IMAGE_NAME="${BB_IMAGE_NAME}"
    local USER_DATA_PATH="${BB_USER_DATA_PATH}"
    local CONTAINER_DATA_PATH="${BB_CONTAINER_DATA_PATH}"
    local ENABLE_RENDER_LAYER="${BB_ENABLE_RENDER_LAYER:-0}"
    local ENABLE_F2FS="${BB_ENABLE_F2FS:-0}"
    local SYSTEM_SIZE_MB="${BB_SYSTEM_SIZE_MB:-0}"
    local ENABLE_NFS="${BB_ENABLE_NFS:-0}"
    local NFS_DIR="${BB_NFS_DIR}"
    local SKIP_DATA_COPY="${BB_SKIP_DATA_COPY:-0}"

    echo "--name)               BOX_NAME           : $BOX_NAME"
    echo "--cpus)               CPUS               : ${CPUS[*]}"
    echo "--numas)              NUMAS              : ${NUMAS[*]}"
    echo "--gpus)               GPUS_RENDER        : ${GPUS_RENDER[*]}"
    echo "--storage_size_gb)    STORAGE_SIZE_GB    : $STORAGE_SIZE_GB"
    echo "--ram_size_mb)        RAM_SIZE_MB        : $RAM_SIZE_MB"
    echo "--ports)              PORTS              : ${PORTS[*]}"
    echo "--extra_run_option)   EXTRA_RUN_OPTION   : $EXTRA_RUN_OPTION"
    echo "--image)              IMAGE_NAME         : $IMAGE_NAME"
    echo "--user_data_path)     USER_DATA_PATH     : $USER_DATA_PATH"
    echo "--enable_render_layer) ENABLE_RENDER_LAYER : $ENABLE_RENDER_LAYER"
    echo "--enable_f2fs)        ENABLE_F2FS        : $ENABLE_F2FS"
    echo "--system_size_mb)     SYSTEM_SIZE_MB     : $SYSTEM_SIZE_MB"
    echo "--enable_nfs)         ENABLE_NFS         : $ENABLE_NFS"
    echo "--nfs_dir)            NFS_DIR            : $NFS_DIR"
    echo "--skip_data_copy)     SKIP_DATA_COPY     : $SKIP_DATA_COPY"

    ########################## 2. 参数校验 ##########################
    local PARA_ERROR=""
    if [ -z "$BOX_NAME" ]; then
        echo "\"BB_NAME\" error, fail: need a kbox name!"
        PARA_ERROR="true"
    fi
    if [ ${#CPUS[@]} -eq 0 ]; then
        echo "\"BB_CPUS\" error, fail: para empty!"
        PARA_ERROR="true"
    fi
    local bb_cpu
    for bb_cpu in "${CPUS[@]}"; do
        if [ -n "$(echo "$bb_cpu" | sed 's/[0-9]//g')" ]; then
            echo "\"BB_CPUS\" error, fail: cpu parameter must be number!"
            PARA_ERROR="true"
        fi
        if [ "$bb_cpu" -ge "$(lscpu | grep -w "CPU(s)" | head -n 1 | awk '{print $2}')" ] || \
           [ "$bb_cpu" -lt 0 ]; then
            echo "\"BB_CPUS\" error, fail: cpu$bb_cpu not exist!"
        fi
    done
    if [ ${#NUMAS[@]} -eq 0 ]; then
        echo "\"BB_NUMAS\" error, fail: para empty!"
        PARA_ERROR="true"
    fi
    local bb_numa
    for bb_numa in "${NUMAS[@]}"; do
        if [ -n "$(echo "$bb_numa" | sed 's/[0-9]//g')" ]; then
            echo "\"BB_NUMAS\" error, fail: numa parameter must be number!"
            PARA_ERROR="true"
        fi
        if [ "$bb_numa" -ge "$(lscpu | grep "NUMA node(s)" | awk '{print $3}')" ] || \
           [ "$bb_numa" -lt 0 ]; then
            echo "\"BB_NUMAS\" fail: numa$bb_numa not exist!"
            PARA_ERROR="true"
        fi
    done
    local bb_gpu
    for bb_gpu in "${GPUS_RENDER[@]}"; do
        if [ ! -e "$bb_gpu" ]; then
            echo "\"BB_GPUS_RENDER\" error, fail: GPU device $bb_gpu not exist!"
            PARA_ERROR="true"
        fi
    done
    if [ -z "$(echo "$STORAGE_SIZE_GB" | sed 's/[0-9]//g')" ]; then
        if [ -z "$STORAGE_SIZE_GB" ]; then
            echo "\"BB_STORAGE_SIZE_GB\" error, fail: para empty!"
            PARA_ERROR="true"
        elif [ "$STORAGE_SIZE_GB" -le 0 ]; then
            echo "\"BB_STORAGE_SIZE_GB\" error, fail: storage size must greater than 0 GB!"
            PARA_ERROR="true"
        fi
    else
        echo "\"BB_STORAGE_SIZE_GB\" error, fail: storage size must be number!"
        PARA_ERROR="true"
    fi
    if [ -z "$(echo "$RAM_SIZE_MB" | sed 's/[0-9]//g')" ]; then
        if [ -z "$RAM_SIZE_MB" ]; then
            echo "\"BB_RAM_SIZE_MB\" error, fail: para empty!"
            PARA_ERROR="true"
        elif [ "$RAM_SIZE_MB" -le 0 ]; then
            echo "\"BB_RAM_SIZE_MB\" error, fail: ram size must greater than 0 MB!"
            PARA_ERROR="true"
        fi
    else
        echo "\"BB_RAM_SIZE_MB\" error, fail: ram size must be number!"
        PARA_ERROR="true"
    fi
    if [ -n "$SYSTEM_SIZE_MB" ]; then
        if [ -n "$(echo "$SYSTEM_SIZE_MB" | sed 's/[0-9]//g')" ]; then
            echo "\"BB_SYSTEM_SIZE_MB\" error, fail: system partition size must be number!"
            PARA_ERROR="true"
        elif [ "$SYSTEM_SIZE_MB" -lt 0 ]; then
            echo "\"BB_SYSTEM_SIZE_MB\" error, fail: system partition size must >= 0 MB!"
            PARA_ERROR="true"
        fi
    fi
    if [ ${#PORTS[@]} -eq 0 ]; then
        echo "\"BB_PORTS\" error, fail: para empty!"
        PARA_ERROR="true"
    fi
    local bb_port
    for bb_port in "${PORTS[@]}"; do
        if [[ "${bb_port}" =~ ":" ]]; then
            local bb_agent_port bb_host_port
            bb_agent_port=$(echo "${bb_port}" | cut -d ':' -f1)
            bb_host_port=$(echo "${bb_port}" | cut -d ':' -f2)
            if [ -n "$(echo "$bb_agent_port" | sed 's/[0-9]//g')" ]; then
                echo "\"BB_PORTS\" error, fail: agent port must be number!"
                PARA_ERROR="true"
            fi
            if [ -n "$(echo "$bb_host_port" | sed 's/[0-9]//g')" ]; then
                echo "\"BB_PORTS\" error, fail: host port must be number!"
                PARA_ERROR="true"
            fi
        else
            echo "\"BB_PORTS\" error, fail: error port format!"
            PARA_ERROR="true"
        fi
    done
    if [[ "${IMAGE_NAME}" =~ ":" ]]; then
        local bb_image_re bb_tag
        bb_image_re=$(echo "${IMAGE_NAME}" | cut -d ':' -f1)
        bb_tag=$(echo "${IMAGE_NAME}" | cut -d ':' -f2)
        $RUNTIME_CMD images | awk '{print $1" "$2}' | grep -w "${bb_image_re}" | grep -w "${bb_tag}" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "\"BB_IMAGE_NAME\" error, no image ${IMAGE_NAME}!"
            PARA_ERROR="true"
        fi
    else
        $RUNTIME_CMD images | awk '{print $3}' | grep -w "${IMAGE_NAME}" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "\"BB_IMAGE_NAME\" error, fail: no image ${IMAGE_NAME}!"
            PARA_ERROR="true"
        fi
    fi
    echo "---------------------------------------------------"
    if [ "$PARA_ERROR" = "true" ]; then
        echo "error: Kbox Start Fail!"
        return 1
    fi

    ########################## 3.环境初始化 ##########################
    local KBOX_SWITCH="/sys/kernel/kbox/kbox_enable"
    if [ -f "$KBOX_SWITCH" ] && [ "$(cat "$KBOX_SWITCH")" = "0" ]; then
	    echo "1" > "$KBOX_SWITCH"
    fi

    if [ "$DEFAULT_RUNTIME" == "docker" ]; then
        # 如果未通过参数指定，则动态获取 Docker 根目录，失败时降级到默认路径
        CONTAINER_DATA_PATH=$($RUNTIME_CMD info --format '{{.DockerRootDir}}' 2>/dev/null || echo "/var/lib/docker")
    else
        CONTAINER_DATA_PATH="/var/lib/containerd"
        SYSTEM_SIZE_MB=0
    fi

    # HOOK_PATH
    local HOOK_PATH=$CONTAINER_DATA_PATH/hooks
    rm -rf ${HOOK_PATH}/${BOX_NAME}
    mkdir -p ${HOOK_PATH}/${BOX_NAME}

    # EVENT PATH
    local INPUT_EVENT_PATH="/var/run/${BOX_NAME}/input"
    mkdir -p $INPUT_EVENT_PATH"/event0"
    mkdir -p $INPUT_EVENT_PATH"/event1"

    # 存储隔离
    if [ -z ${USER_DATA_PATH} ]; then
        USER_DATA_PATH="/root/mount"
    fi
        
    if [[ $ENABLE_NFS == "1" ]]; then
        USER_DATA_PATH="${NFS_DIR}"
    fi

    if [ ! -d "${USER_DATA_PATH}/img" ]; then
        mkdir -p ${USER_DATA_PATH}/img
    fi
    # f2fs 宿主机物理分区格式校验
    if [ "$ENABLE_F2FS" == "1" ]; then  
        bb_check_f2fs_partition "${USER_DATA_PATH}/data"
        if [ $? -ne 0 ]; then
            return 1 # 校验失败，直接退出拉起流程
        fi
    fi

    bb_create_data_img

    ########################## 4.容器启动 ##########################
    local RUN_OPTION=""
    if [ $DEFAULT_RUNTIME == "docker" ]; then
        RUN_OPTION+=" -i "
    fi
    RUN_OPTION+=" -td "
    RUN_OPTION+=" --hostname=${BOX_NAME} "
    RUN_OPTION+=" --cap-add=SETPCAP "
    RUN_OPTION+=" --cap-add=AUDIT_WRITE "
    RUN_OPTION+=" --cap-add=SYS_CHROOT "
    RUN_OPTION+=" --cap-add=CHOWN "
    RUN_OPTION+=" --cap-add=DAC_OVERRIDE "
    RUN_OPTION+=" --cap-add=FOWNER "
    RUN_OPTION+=" --cap-add=SETGID "
    RUN_OPTION+=" --cap-add=SETUID "
    RUN_OPTION+=" --cap-add=SYSLOG "
    RUN_OPTION+=" --cap-add=SYS_ADMIN "
    RUN_OPTION+=" --cap-add=WAKE_ALARM "
    RUN_OPTION+=" --cap-add=SYS_PTRACE "
    RUN_OPTION+=" --cap-add=BLOCK_SUSPEND "
    RUN_OPTION+=" --cap-add=MKNOD "
    RUN_OPTION+=" --cap-add=KILL "
    RUN_OPTION+=" --cap-add=SYS_RESOURCE "
    RUN_OPTION+=" --cap-add=NET_RAW "
    RUN_OPTION+=" --cap-add=NET_ADMIN "
    RUN_OPTION+=" --cap-add=NET_BIND_SERVICE "
    RUN_OPTION+=" --cap-add=SYS_NICE "
    RUN_OPTION+=" --cap-add=AUDIT_CONTROL "
    RUN_OPTION+=" --cap-add=DAC_READ_SEARCH "
    RUN_OPTION+=" --cap-add=IPC_LOCK "
    RUN_OPTION+=" --cap-add=SYS_MODULE "
    RUN_OPTION+=" --security-opt="apparmor:unconfined" "
    RUN_OPTION+=" --security-opt="seccomp:unconfined" "
    RUN_OPTION+=" --device=/dev/loop-control:/dev/loop-control "
    RUN_OPTION+=" --volume=/dev/loop_device:/dev/loop_device:rw "
    RUN_OPTION+=" --name ${BOX_NAME} "
    RUN_OPTION+=" -v /sys:/sys "
    RUN_OPTION+=" -e CONTAINER_NAME=${BOX_NAME} "
    RUN_OPTION+=" -e PATH=/system/bin:/system/xbin "
    RUN_OPTION+=" --cidfile ${HOOK_PATH}/${BOX_NAME}/container_id.cid "
    RUN_OPTION+=" --cpu-shares=$(lscpu | grep -w "CPU(s)" | head -n 1 | awk '{print $2}') "

    local CPU NUMA TEMP
    for CPU in ${CPUS[@]}; do
        TEMP+=$CPU","
    done
    TEMP=${TEMP: 0: $((${#TEMP} - 1))}
    RUN_OPTION+=" --cpuset-cpus=$TEMP "

    TEMP=""
    for NUMA in ${NUMAS[@]}; do
       TEMP+=$NUMA","
    done
    TEMP=${TEMP: 0: $((${#TEMP} - 1))}
    RUN_OPTION+=" --cpuset-mems=$TEMP"

    # 内存 +1M,规避依赖UE引擎的游戏在内存设置为4的倍数时会崩溃的问题
    RAM_SIZE_MB=$(($RAM_SIZE_MB + 1))
    RUN_OPTION+=" --memory=${RAM_SIZE_MB}M "
    if [ $DEFAULT_RUNTIME == "docker" ]; then
        RUN_OPTION+=" --device=/dev/net/tun:/dev/tun:rwm "
    else
        RUN_OPTION+=" --device=/dev/net/tun:/dev/net/tun:rwm "
    fi
    RUN_OPTION+=" --device=/dev/fuse:/dev/fuse:rwm "
    RUN_OPTION+=" --device=/dev/uinput:/dev/uinput:rwm "
    if [ -c "/dev/ion" ]; then
        RUN_OPTION+=" --device=/dev/ion:/dev/ion:rwm "
    fi
    if [ -c "/dev/i2c-1" ]; then
        RUN_OPTION+=" --device=/dev/i2c-1:/dev/i2c-1:rwm "
    fi
    local i
    local VA_SGPU100_ID=":0200"

    if bb_has_hantro_gpu; then
        RUN_OPTION+=" --device=/dev/vatools:/dev/vatools:rwm "
        RUN_OPTION+=" --device=/dev/va_sync:/dev/va_sync:rwm "
        local RENDER_IDX
        for (( i=0; i<${#GPUS_RENDER[@]};i++ )); do
            RUN_OPTION+=" --device=${GPUS_RENDER[$i]}:${GPUS_RENDER[$i]}:rwm "
            RENDER_IDX=$(($(echo "${GPUS_RENDER[$i]}" | tr -cd "[0-9]")-128))
            RUN_OPTION+=" --device=/dev/va${RENDER_IDX}_ctl:/dev/va${RENDER_IDX}_ctl:rwm "
            RUN_OPTION+=" --device=/dev/va_video${RENDER_IDX}:/dev/va_video${RENDER_IDX}:rwm "
            RUN_OPTION+=" --device=/dev/vacc${RENDER_IDX}:/dev/vacc${RENDER_IDX}:rwm "
        done
        echo "ro.va.video.codec=c2" >> $THISDIR/build.prop
    else
        for (( i=0; i<${#GPUS_RENDER[@]};i++ )); do
            RUN_OPTION+=" --device=${GPUS_RENDER[$i]}:/dev/dri/renderD$((128 + $i)):rwm "
        done
    fi

    if bb_has_amd_w6800_gpu; then
        ENABLE_AMD_C2_DECODE=$(echo "${EXTRA_RUN_OPTION}" | grep -oP '(?<=ENABLE_AMD_C2_DECODE=)[01]')
        if [ "$ENABLE_AMD_C2_DECODE" -eq 1 ]; then
            sudo chmod 666 /dev/dma_heap/system
            RUN_OPTION+=" --device=/dev/dma_heap/system:/dev/dma_heap/system:rwm "
            echo "debug.stagefright.ccodec=4" >> $THISDIR/build.prop
            echo "sys.cpu.limited=1" >> $THISDIR/build.prop
        else
            echo "debug.stagefright.ccodec=0" >> $THISDIR/build.prop
            echo "sys.cpu.limited=0" >> $THISDIR/build.prop
        fi
    fi

    if [ -e "/dev/tango32" ]; then
        RUN_OPTION+=" --device=/dev/tango32:/dev/tango32:rwm "
    fi

    local data_path="${USER_DATA_PATH}/data/$BOX_NAME"
    RUN_OPTION+=" --volume=$data_path/cache:/cache:rw "
    if [ "$START_SHARE_DATA" == "0" ]; then
        RUN_OPTION+=" --volume=$data_path/data:/data:rw "
    fi
    RUN_OPTION+=" --volume=$INPUT_EVENT_PATH/event0:/dev/input/event0:rw "
    RUN_OPTION+=" --volume=$INPUT_EVENT_PATH/event1:/dev/input/event1:rw "
    RUN_OPTION+=" --volume=$(bb_get_lxcfs_path)/proc:/lxcfs-proc:ro "
    RUN_OPTION+=" --volume=$data_path/storage_size:/storage_size:rw "
    # --- 新增的 /system 分区大小配置及 xfs 校验逻辑 开始 ---
    # 如果参数为空，赋予默认值 0
    if [ -z "$SYSTEM_SIZE_MB" ]; then
        SYSTEM_SIZE_MB=0
    fi

    # 只有当配置值不为 0 时，才去校验 xfs 格式
    if [ "$SYSTEM_SIZE_MB" -ne 0 ]; then
        bb_check_system_size_modify "$CONTAINER_DATA_PATH"
    fi
    # 如果 SYSTEM_SIZE_MB 为 0，则上面整个 if 都不进，直接跳过，什么参数都不加
    # --- 新增的 /system 分区大小配置及 xfs 校验逻辑 结束 ---
    
    if [ -f $THISDIR/default.prop_$BOX_NAME ]; then
        RUN_OPTION+=" --volume=$THISDIR/default.prop_$BOX_NAME:/kbox_prop/default.prop:rw "
    fi
    if [ -f $THISDIR/build.prop ]; then
        RUN_OPTION+=" --volume=$THISDIR/build.prop:/kbox_prop/build.prop:rw "
    fi
    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        bb_create_app_shader_filesystem ${BOX_NAME} RUN_OPTION
    fi
    bb_mock_cpu
    bb_mock_power_supply
    local PORT
    for PORT in ${PORTS[@]}; do
        RUN_OPTION+=" -p $PORT "
    done
    RUN_OPTION+=" --sysctl net.ipv6.conf.all.accept_redirects=0"
    # 额外的选项
    if [ -n "$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')" ]; then
        # VA GPU 使用该参数传递是否使能硬解，其余情况下传递硬解设备信息。
        ENABLE_HARD_DECODE=$(echo "${EXTRA_RUN_OPTION}" | grep -oP '(?<=ENABLE_HARD_DECODE=)[01]')
        EXTRA_RUN_OPTION=${EXTRA_RUN_OPTION% *}
    fi
    RUN_OPTION+=" $EXTRA_RUN_OPTION "
    $RUNTIME_CMD run $RUN_OPTION --device-cgroup-rule "c *:* rwm" --device-cgroup-rule "b 7:* rwm" $IMAGE_NAME /init 

    if [ $DEFAULT_RUNTIME == "containerd" ]; then
        $RUNTIME_CMD exec -i ${BOX_NAME} ln -s /dev/net/tun /dev/tun
    fi
    # 支持Android系统属性可定制
    # local.prop用于修改定制属性，但该文件不是一定存在，需要用户手动生成。
    if [ -e "$CURRENT_DIR/local.prop" ]; then
        $RUNTIME_CMD cp $CURRENT_DIR/local.prop ${BOX_NAME}:/data
        sleep 0.5
        $RUNTIME_CMD exec ${BOX_NAME} chmod 400 /data/local.prop
    fi

    local cid=$($RUNTIME_CMD ps --filter "name=$BOX_NAME" --format "{{.ID}}" | head -n 1)
    echo $cid > $THISDIR/containerid_${BOX_NAME}
    $RUNTIME_CMD cp $THISDIR/containerid_${BOX_NAME} ${BOX_NAME}:/data/containerid
    rm -f $THISDIR/containerid_${BOX_NAME}
}

function bb_check_exagear() {
    # 未注册
    if [ ! -e "/proc/sys/fs/binfmt_misc/ubt_a32a64" ]; then
        if [ ! -d "/proc/sys/fs/binfmt_misc/" ]; then
            mount -t binfmt_misc none /proc/sys/fs/binfmt_misc
        fi

        # 在归档路径下模糊查找
        local UBT_PATHS=($(ls /root/dependency/*/ubt_a32a64))
        if [ ${#UBT_PATHS[@]} -lt 1 ]; then
            echo "No ubt_a32a64 file!"
            exit 1
        elif [ ${#UBT_PATHS[@]} -gt 1 ]; then
            echo "Many ubt_a32a64 files exist! Please check:"
            for PA in ${UBT_PATHS[@]}; do
                echo "${PA}"
            done
            exit 1
        fi

        # 恢复exgear文件
        mkdir -p /opt/exagear
        chmod -R 700 /opt/exagear
        cp -rf ${UBT_PATHS[0]} /opt/exagear/
        cd /opt/exagear
        chmod +x ubt_a32a64

        # 注册转码 续行符后字符串顶格
        echo ":ubt_a32a64:M::\x7fELF\x01\x01\x01\x00\x00\x00\x0"\
"0\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xf"\
"f\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00"\
"\x00\xfe\xff\xff\xff:/opt/exagear/ubt_a32a64:POCF" > /proc/sys/fs/binfmt_misc/register
        cd - >/dev/null 2>&1
    fi

    # 检查ubt_a32a64版本
    local UBT_VER=($(/opt/exagear/ubt_a32a64 -V |grep -w binary | sed 's/^ExaGear binary translator version: \([^\s]*\)/\1/g'  | sed 's/^v//g'))
    if [ $UBT_VER \> "2.4.1" ]; then
        if [ ! -e "/dev/tango32" ]; then
            echo "No tango32!"
            exit 1
        fi
    fi
}

function bb_prepare_loop_device() {
    # 清空/dev/目录下现有的loop device
    for dev in /dev/loop[0-9]*; do
        # 不删除loop device软链接
        if [ -L "$dev" ]; then
            continue
        fi

        if [ -b "$dev" ]; then
            echo "Removing $dev"
            rm -f "$dev"
        fi
    done

    local TARGET_DIR="/dev/loop_device"
    local LOOP_NUM=20000

    mkdir -p "$TARGET_DIR"

    # 统计已有loop device节点数量
    count=$(ls -1 "$TARGET_DIR"/loop* 2>/dev/null | wc -l)
    # 如果少于预期节点个数LOOP_NUM，则补齐
    if [ "$count" -lt $LOOP_NUM ]; then
        echo "Creating loop device... This process will take about 1 min."

        for i in $(seq 0 $((LOOP_NUM - 1))); do
            local guest_node="$TARGET_DIR/loop$i"
            local host_node="/dev/loop$i"

            if [ ! -e "$guest_node" ]; then
                mknod -m 0666 "$guest_node" b 7 $i
            fi

            if [ ! -e "$host_node" ]; then
                ln -s "$guest_node" "$host_node"
            fi
        done

        echo "Loop device created successfully."
    else
        echo "Skip creating loop device."
    fi
}

function bb_check_selinux() {
    local SELINUX_STATUS=$(getenforce)
    if [ "$SELINUX_STATUS" != "Disabled" ]; then
        echo "SELinux is not disabled! Please check! Current status: $SELINUX_STATUS"
        exit 1
    fi
}

function bb_check_max_user_instances() {
    local TARGET_VALUE=8192
    local CURRENT_VALUE=$(cat /proc/sys/fs/inotify/max_user_instances)
    if [ "$CURRENT_VALUE" -ne "$TARGET_VALUE" ]; then
        echo "Set fs.inotify.max_user_instances to $TARGET_VALUE"
        sysctl -w fs.inotify.max_user_instances=$TARGET_VALUE > /dev/null 2>&1
    fi
}

function bb_check_cgroup_v2() {
    if ! mount | grep -q "cgroup2 on /sys/fs/cgroup"; then
        echo "WARNING: cgroup v2 is disabled, which may lead to functional issues."
    fi
}

function bb_stop_udev_services() {
    stop_service 'systemd-udevd-control.socket'
    stop_service 'systemd-udevd-kernel.socket'
    stop_service 'systemd-udevd.service'
}

stop_service() {
    local service_name="$1"

    if systemctl is-active --quiet "$service_name"; then
        systemctl stop "$service_name"
    fi

    local is_stopped
    is_stopped=$(systemctl is-active "$service_name")

    if [[ "$is_stopped" != "inactive" ]]; then
        echo -e "\033[1;31m[ERROR] 服务 $service_name 停止失败\033[0m"
        return 1
    fi
}

#CPU文件模拟
function bb_mock_cpu() {
    local CPU_PATH="/var/lib/kbox/cpus/${BOX_NAME}/cpu"
    local CPU_NUM=8
    if [ -d "${CPU_PATH}" ];then
        umount /var/lib/kbox/cpus/$BOX_NAME/cpu/cpu*/* > /dev/null 2>&1
        rm -rf /var/lib/kbox/cpus/$BOX_NAME
        [ $? -ne 0 ] && echo "fail to remove data files /var/lib/kbox/cpus/$BOX_NAME !" && RET="fail"
    fi

    mkdir -p ${CPU_PATH}
    chmod 755 ${CPU_PATH}

    echo "7" >${CPU_PATH}"/kernel_max"
    echo "0-7" >${CPU_PATH}"/possible"
    echo "0-7" >${CPU_PATH}"/present"
    echo "0-7" >${CPU_PATH}"/online"

    chmod 444 ${CPU_PATH}/kernel_max ${CPU_PATH}/possible ${CPU_PATH}/present ${CPU_PATH}/online

    # mock_cpufreq
    mkdir -p ${CPU_PATH}/cpufreq/policy0 ${CPU_PATH}/cpufreq/cpuidle
    chmod 755 ${CPU_PATH}/cpufreq ${CPU_PATH}/cpufreq/policy0 ${CPU_PATH}/cpufreq/cpuidle

    echo "$(seq 0 $(($CPU_NUM - 1))|tr 'n' ' ')" >${CPU_PATH}"/cpufreq/policy0/affected_cpus"
    echo "1954000" >${CPU_PATH}"/cpufreq/policy0/cpuinfo_max_freq"
    echo "1954000" >${CPU_PATH}"/cpufreq/policy0/cpuinfo_cur_freq"
    echo "554000" >${CPU_PATH}"/cpufreq/policy0/cpuinfo_min_freq"
    echo "0" >${CPU_PATH}"/cpufreq/policy0/cpuinfo_transition_latency"
    cat ${CPU_PATH}"/cpufreq/policy0/affected_cpus" >${CPU_PATH}"/cpufreq/policy0/related_cpus"
    echo "554000 860000 956000 1042000 1128000 1224000 1320000 1397000 1512000 1628000 1748000 1858000 1954000" >${CPU_PATH}"/cpufreq/policy0/scaling_available_frequencies"
    echo "interacitve userspace powersave performance schedutil" >${CPU_PATH}"/cpufreq/policy0/scaling_available_governors"
    cat ${CPU_PATH}"/cpufreq/policy0/cpuinfo_cur_freq" >${CPU_PATH}"/cpufreq/policy0/scaling_cur_freq"
    echo "cpufreq-dt" >${CPU_PATH}"/cpufreq/policy0/scaling_driver"
    echo "performance" >${CPU_PATH}"/cpufreq/policy0/scaling_governor"
    cat ${CPU_PATH}"/cpufreq/policy0/cpuinfo_max_freq" >${CPU_PATH}"/cpufreq/policy0/scaling_max_freq"
    cat ${CPU_PATH}"/cpufreq/policy0/cpuinfo_min_freq" >${CPU_PATH}"/cpufreq/policy0/scaling_min_freq"
    echo "<unsupported>" >${CPU_PATH}"/cpufreq/policy0/scaling_setspeed"

    chmod 444 ${CPU_PATH}/cpufreq/policy0/*
    chmod 400 ${CPU_PATH}/cpufreq/policy0/cpuinfo_cur_freq
    chmod 644 ${CPU_PATH}/cpufreq/policy0/scaling_governor ${CPU_PATH}/cpufreq/policy0/scaling_setspeed
    chmod 660 ${CPU_PATH}/cpufreq/policy0/scaling_max_freq ${CPU_PATH}/cpufreq/policy0/scaling_min_freq

    # mock_cpuidle
    mkdir -p ${CPU_PATH}/cpufreq/cpuidle/driver ${CPU_PATH}/cpufreq/cpuidle/state0 ${CPU_PATH}/cpufreq/cpuidle/state1
    chmod 755 ${CPU_PATH}/cpufreq/cpuidle/*

    echo "hisi_cluster0_idle_driver" >${CPU_PATH}"/cpufreq/cpuidle/driver/name"
    chmod 444 ${CPU_PATH}"/cpufreq/cpuidle/driver/name" 

    echo "ARM64 WFI" >${CPU_PATH}"/cpufreq/cpuidle/state0/desc"
    echo "0" >${CPU_PATH}"/cpufreq/cpuidle/state0/disable"
    echo "1" >${CPU_PATH}"/cpufreq/cpuidle/state0/latency"
    echo "WFI" >${CPU_PATH}"/cpufreq/cpuidle/state0/name"
    echo "0" >${CPU_PATH}"/cpufreq/cpuidle/state0/power"
    echo "1" >${CPU_PATH}"/cpufreq/cpuidle/state0/residency"
    echo "$((RANDOM*4+11111))" >${CPU_PATH}"/cpufreq/cpuidle/state0/usage"
    echo "$(($(cat ${CPU_PATH}/cpufreq/cpuidle/state0/usage)*666))" >${CPU_PATH}"/cpufreq/cpuidle/state0/time"

    chmod 444 ${CPU_PATH}/cpufreq/cpuidle/state0/*
    chmod 644 ${CPU_PATH}/cpufreq/cpuidle/state0/disable

    echo "cpu-sleep-0" >${CPU_PATH}"/cpufreq/cpuidle/state1/desc"
    echo "0" >${CPU_PATH}"/cpufreq/cpuidle/state1/disable"
    echo "110" >${CPU_PATH}"/cpufreq/cpuidle/state1/latency"
    echo "cpu-sleep-0" >${CPU_PATH}"/cpufreq/cpuidle/state1/name"
    echo "0" >${CPU_PATH}"/cpufreq/cpuidle/state1/power"
    echo "3000" >${CPU_PATH}"/cpufreq/cpuidle/state1/residency"
    echo "$((RANDOM*+11111))" >${CPU_PATH}"/cpufreq/cpuidle/state1/usage"
    echo "$(($(cat ${CPU_PATH}/cpufreq/cpuidle/state1/usage)*22222))" >${CPU_PATH}"/cpufreq/cpuidle/state0/time"


    chmod 444 ${CPU_PATH}/cpufreq/cpuidle/state1/*
    chmod 644 ${CPU_PATH}/cpufreq/cpuidle/state1/disable

    # mock_cpu*
    for ((i=0; i<8; i++));
    do
        mkdir -p ${CPU_PATH}/cpu$i
        chmod 755 ${CPU_PATH}/cpu$i
        #其他文件的挂载
        mkdir -p ${CPU_PATH}/cpu$i/hotplug ${CPU_PATH}/cpu$i/power ${CPU_PATH}/cpu$i/regs ${CPU_PATH}/cpu$i/topology
        cp /sys/devices/system/cpu/cpu$i/cpu_capacity ${CPU_PATH}/cpu$i/cpu_capacity
        mount --bind /sys/devices/system/cpu/cpu$i/hotplug ${CPU_PATH}/cpu$i/hotplug
        echo "1" >${CPU_PATH}/cpu$i/online
        mount --bind /sys/devices/system/cpu/cpu$i/power ${CPU_PATH}/cpu$i/power
        mount --bind /sys/devices/system/cpu/cpu$i/regs ${CPU_PATH}/cpu$i/regs
        mount --bind /sys/devices/system/cpu/cpu$i/topology ${CPU_PATH}/cpu$i/topology
        mkdir -p ${CPU_PATH}/cpu$i/cpufreq ${CPU_PATH}/cpu$i/cpuidle
        mount --bind ${CPU_PATH}/cpufreq/policy0 ${CPU_PATH}/cpu$i/cpufreq
        mount --bind ${CPU_PATH}/cpufreq/cpuidle ${CPU_PATH}/cpu$i/cpuidle
    done

    RUN_OPTION+="--volume=/var/lib/kbox/cpus/${BOX_NAME}/cpu:/data/local/cpu:ro"
}

# 供电模拟：USB供电，未充电状态
function bb_mock_power_supply() {
    local POWER_SUPPLY_PATH="/var/lib/kbox/powers/${BOX_NAME}/power_supply"

    mkdir -p $POWER_SUPPLY_PATH"/Battery"
    mkdir -p $POWER_SUPPLY_PATH"/Mains"
    mkdir -p $POWER_SUPPLY_PATH"/USB"
    mkdir -p $POWER_SUPPLY_PATH"/Wireless"

    echo "100" >$POWER_SUPPLY_PATH"/Battery/capacity"
    echo "3945000" >$POWER_SUPPLY_PATH"/Battery/charge_counter"
    echo "0" >$POWER_SUPPLY_PATH"/Battery/current_now"

    echo "Good" >$POWER_SUPPLY_PATH"/Battery/health"
    echo "1" >$POWER_SUPPLY_PATH"/Battery/online"

    echo "1" >$POWER_SUPPLY_PATH"/Battery/present"
    echo "Not charging" >$POWER_SUPPLY_PATH"/Battery/status"
    echo "Li-poly" >$POWER_SUPPLY_PATH"/Battery/technology"
    echo "260" >$POWER_SUPPLY_PATH"/Battery/temp"
    echo "Battery" >$POWER_SUPPLY_PATH"/Battery/type"
    echo "4400" > $POWER_SUPPLY_PATH"/Battery/voltage_max"
    echo "4356000" >$POWER_SUPPLY_PATH"/Battery/voltage_now"

    echo "500000" >$POWER_SUPPLY_PATH"/USB/current_max"
    echo "Good" >$POWER_SUPPLY_PATH"/USB/health"
    echo "1" >$POWER_SUPPLY_PATH"/USB/online"
    echo "USB" >$POWER_SUPPLY_PATH"/USB/type"
    echo "4950000" > $POWER_SUPPLY_PATH"/USB/voltage_max"

    echo "Good" >$POWER_SUPPLY_PATH"/Mains/health"
    echo "0" >$POWER_SUPPLY_PATH"/Mains/online"
    echo "Mains" >$POWER_SUPPLY_PATH"/Mains/type"

    echo "Good" >$POWER_SUPPLY_PATH"/Wireless/health"
    echo "0" >$POWER_SUPPLY_PATH"/Wireless/online"
    echo "Wireless" >$POWER_SUPPLY_PATH"/Wireless/type"

    RUN_OPTION+=" --volume=$POWER_SUPPLY_PATH:/sys/class/power_supply:rw "
}

function bb_check_key_process() {
    # 检查关键进程是否存在
    local process_name=(system_server zygote zygote64 surfaceflinger)
    local cmd="$RUNTIME_CMD exec -i $1 ps -A | grep -Ew 'system_server|zygote|zygote64|surfaceflinger' &"
    local result=$(bb_wait_cmd "${cmd}")
    bb_check_wait_cmd_result "${cmd}" "${result}"
    local val
    for process in ${process_name[@]}; do
        val=$(echo $result |grep -w ${process}'\>')
        [ ! -n "$val" ] && echo "$process is null" && return 1
    done

    # 检查关键进程是否重启
    local check_list=(sys.surfaceflinger.has_reboot sys.zygote.has_reboot sys.zygote64.has_reboot)
    cmd="$RUNTIME_CMD exec -i $1 getprop |grep '.has_reboot' &"
    result=$(bb_wait_cmd "${cmd}" 2>/dev/null )
    bb_check_wait_cmd_result "${cmd}" "${result}"
    for property in ${check_list[@]}; do
        val=$(echo $result |grep -w ${property}'\>')
        [[ "$val" =~ "[1]" ]] && echo "$property has restarted" && return 1
    done

    # 检查服务列表
    cmd="$RUNTIME_CMD exec -i $1 service list |grep -w SurfaceFlinger &"
    result=$(bb_wait_cmd "${cmd}")
    bb_check_wait_cmd_result "${cmd}" "${result}"
    if [[ "$result" =~ "[android.ui.ISurfaceComposer]" ]]; then
        return 0
    else
        echo "service SurfaceFlinger is not normal"
        return 1
    fi
}

function bb_create_app_shader_filesystem()
{
    local box_name=$1
    local -n RUN_OPTION_REF=$2
    local render_config="${THISDIR}/kbox_render_accelerating_configuration.xml"
    if [ ! -e "${render_config}" ]; then
        echo -e "\033[31mThe RenderAccLayer cannot be enabled. kbox_render_accelerating_configuration.xml not exist.\033[0m"
        return
    fi
    result=$(python3 << EOF
# -*- coding: utf-8 -*-
import xml.etree.ElementTree as ET

app_config = {}

def read_xml(xml_file):
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        dir_size_list = [-1, 64, 128, 256, 512, 1024]  # 单位 MB

        for app in root.findall("Application"):
            if app.get('isEnable') != 'true' and app.get('isEnable') != '1':
                continue
            app_name = app.get('name')
            if app_name == "system":
                continue
            shader_cache_config = {}
            # 提取shadercache配置
            for feature in app.findall('feature'):
                if feature.get('name') != 'kbox.render.accelerating.shaderCache':
                    continue
                if feature.get('isEnable') != 'true' and feature.get('isEnable') != '1':
                    continue
                cache_mode = feature.find('.//param[@name="SHADER_CACHE_MODE"]')
                cache_size = feature.find('.//param[@name="SHADER_CACHE_DIR_SIZE"]')
                if cache_mode is not None:
                    mode = int(cache_mode.get('value'))
                    if mode < 0 or mode >= 3:
                        mode = 0
                    shader_cache_config["mode"] = mode
                else:
                    shader_cache_config["mode"] = 0  # 默认关闭

                if cache_size is not None:
                    size = int(cache_size.get('value'))
                    for item in dir_size_list[::-1]:
                        if size >= item:
                            size = item
                            break
                    if size <= 0:
                        size = 256
                    shader_cache_config["size"] = size
                else:
                    shader_cache_config["size"] = 256  # 默认256 MB

                app_config[app_name] = shader_cache_config
        return 0

    except ET.ParseError as e:
        raise ValueError("XML解析失败") 
    except FileNotFoundError as e:
        raise FileNotFoundError("XML文件不存在")
    except Exception as e:
        raise Exception("未知错误")


if __name__ == "__main__":
    input_file = "${render_config}"
    result = read_xml(input_file)

    for item in app_config:
        print("%s"%item, "%d"%app_config[item]["mode"], "%d"%app_config[item]["size"])
EOF
)
    if [ $? -ne 0 ]; then
        echo -e "\033[31mFailed to enabled render layer! Failed to read kbox_render_accelerating_configuration.xml \033[0m"
        return
    fi

    apps=($(printf "%s" "$result" | awk '{print $1}'))
    modes=($(printf "%s" "$result" | awk '{print $2}'))
    sizes=($(printf "%s" "$result" | awk '{print $3}'))
    app_num=${#apps[@]}
    mode_config=("CLOSED" "READONLY" "READWRITE" "DEFAULT")
    mkdir -p $USER_DATA_PATH/shader_cache
    cd $USER_DATA_PATH/shader_cache
    echo "------------------ SHADERCACHE CONFIG ------------------"
    for i in $(seq 0 $(($app_num - 1))); do
        app=${apps[i]}
        mode=${modes[i]}
        size=${sizes[i]}
        printf "App: %-40s  Mode: %s  Size: %1d MB\n " "${app}" "${mode_config[mode]}" "${size}"
        if [ ${mode} -ne 2 ] && [ ${mode} -ne 1 ]; then
            # 不是读写或者只读模式
            continue
        fi
        if [ ${mode} -eq 1 ] && [ ! -e ${app}.img ]; then
            echo -e "\033[33m WARN:Failed to bind shader cache path! mode is READONLY but ${app}.img not exist. \033[0m"
            continue
        fi
        if [ ${mode} -eq 2 ] && [ ! -e ${app}.img ]; then
            fallocate -l ${size}M ${app}.img
            yes | mkfs -t ext4 ${app}.img
        fi
        mkdir -p $app
        mount ${app}.img $app
        RUN_OPTION_REF+=" --volume=${USER_DATA_PATH}/shader_cache/$app/:/vendor/shader_cache/$app:rw "
    done
    echo "---------------------------------------------------"
    cd - >/dev/null 2>&1
    return 0
}

function bb_deploy_render_layer() {
    local BOX_NAME=$1
    local render_config="${THISDIR}/kbox_render_accelerating_configuration.xml"
    if [ ! -e "${render_config}" ]; then
        return
    fi
    local cmds=(
        "$RUNTIME_CMD exec -it ${BOX_NAME} mkdir -p /data/local/debug/gles"
        "$RUNTIME_CMD exec -it ${BOX_NAME} chmod 755 -R /data/local/debug/"
        "$RUNTIME_CMD exec -it ${BOX_NAME} mkdir -p /data/local/tmp"
        "$RUNTIME_CMD cp ${render_config} ${BOX_NAME}:/data/local/tmp"
        "$RUNTIME_CMD exec -it ${BOX_NAME} cp /system/vendor/lib64/hw/RenderAccLayer.kbox.so /data/local/debug/gles"
        "$RUNTIME_CMD exec -it ${BOX_NAME} setprop debug.gles.layers RenderAccLayer.kbox.so"
    )
    local failed=0
    for cmd in "${cmds[@]}"
    do
        $cmd || { echo -e "\033[31m Failed to Run command \"$cmd\" \033[0m"; failed=1; }
    done
    if [ $failed -eq 1 ]; then
        echo -e "\033[31mFailed to enabled render layer!\033[0m"
    else
        echo -e "\033[36mSuccessful to enabled render layer!\033[0m"
    fi
    $RUNTIME_CMD exec -it ${BOX_NAME} sh -c "if [ -d /vendor/shader_cache/ ]; then chmod 757 -R /vendor/shader_cache/; fi"
}

function bb_delete_box() {
    # 从 BB_* 全局配置变量读取参数
    local BOX_NAME="${BB_NAME}"
    local USER_DATA_PATH="${BB_USER_DATA_PATH}"
    local keep_data="${BB_KEEP_DATA:-0}"
    local enable_nfs=0
    if [ "$keep_data" -eq 2 ] 2>/dev/null; then
        enable_nfs=1
        keep_data=1
    fi
    local RET="true"
    local umount_try=30
    local rm_try=30
    set +e
    # 删除容器
    if [ -n "$("$RUNTIME_CMD" ps -a --format {{.Names}} | grep "$BOX_NAME$")" ]; then
        while [ $rm_try -gt 1 ]
        do
            $RUNTIME_CMD kill $BOX_NAME > /dev/null 2>&1
            $RUNTIME_CMD rm $BOX_NAME > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                rm_try=$((rm_try - 1))
                RET="fail"
                sleep 1
            else
                echo "remove container $BOX_NAME OK"
                RET="true"
                break
            fi
        done
    fi

    # 删除cpu/文件
    umount /var/lib/kbox/cpus/$BOX_NAME/cpu/cpu*/* > /dev/null 2>&1
    rm -rf /var/lib/kbox/cpus/$BOX_NAME
    [ $? -ne 0 ] && echo "fail to remove data files /var/lib/kbox/cpus/$BOX_NAME !" && RET="fail"

    # 删除power_supply文件
    rm -rf /var/lib/kbox/powers/${BOX_NAME}

    # 删除数据文件
    if [ -z "${USER_DATA_PATH}" ]; then
        USER_DATA_PATH="/root/mount"
    fi

    if [ -d "$USER_DATA_PATH/data/$BOX_NAME" ]; then
        while [ $umount_try -gt 1 ]
        do
            umount $USER_DATA_PATH/data/$BOX_NAME > /dev/null 2>&1
            [ $? -ne 0 ] && echo "$BOX_NAME is already umounted!"
            mount | grep -w "$USER_DATA_PATH/data/$BOX_NAME"
            if [ $? -eq 0 ]; then
                umount_try=$((umount_try - 1))
                sleep 1
            else
                echo "umounted $BOX_NAME OK"
                break
            fi
        done
        rm -rf $USER_DATA_PATH/data/$BOX_NAME > /dev/null 2>&1
        [ $? -ne 0 ] && echo "fail to remove data files $USER_DATA_PATH/data/$BOX_NAME !" && RET="fail"
    fi

    # 删除数据img文件
    if [ -e "$USER_DATA_PATH/img/$BOX_NAME.img" ] && [ $keep_data -ne 1 ]; then
        rm -rf $USER_DATA_PATH/img/$BOX_NAME.img > /dev/null 2>&1
        [ $? -ne 0 ] && echo "fail to remove image file $USER_DATA_PATH/img/$BOX_NAME.img !" && RET="fail"
    fi

    # 删除input event path
    if [ -d /var/run/$BOX_NAME ]; then
        rm -rf /var/run/${BOX_NAME} > /dev/null 2>&1
        [ $? -ne 0 ] && echo "fail to remove event path /var/run/${BOX_NAME} !" && RET="fail"
    fi

    if [ $RET == "true" ];then
        echo "container ${BOX_NAME} is deleted successfully."
    fi
}

function bb_check_f2fs_partition() {
    local target_path=$1
    local has_error=0
    
    # 1. 校验当前内核是否支持 f2fs
    # 使用 grep -q 静默匹配，如果找到了会返回 0 (true)
    if ! grep -q "f2fs" /proc/filesystems; then
        echo -e "\033[1;31m[ERROR] 校验失败: 当前系统内核不支持 f2fs 文件系统。\033[0m"
        echo -e "\033[1;31m[ERROR] 执行 'cat /proc/filesystems | grep f2fs' 未检测到回显。\033[0m"
        echo -e "\033[1;31m[ERROR] 请检查内核是否编译了 f2fs 支持，或尝试手动加载模块 (modprobe f2fs)。\033[0m"
        has_error=1
    fi

    # 2. 校验目标目录所在的分区是否为 f2fs 格式
    mkdir -p "${target_path}"
    local host_fs_type=$(df -T "${target_path}" | tail -1 | awk '{print $2}')
    if [ "$host_fs_type" != "f2fs" ]; then
        echo  "当前容器配置为使能 f2fs (ENABLE_F2FS=1)"
        echo  "但目标挂载目录 ${target_path} 所在的分区格式为 ${host_fs_type}，并非 f2fs。"
        echo  "这可能会导致性能受到影响，请注意！"
    fi

    # 3. 最终判断逻辑：只要有一个校验未通过，就中止并返回 1
    if [ "$has_error" -ne 0 ]; then
        echo -e "\033[1;31m[ERROR] f2fs 运行环境检查未通过，操作已中止。\033[0m"
        return 1
    fi

    return 0
}

function bb_create_build_prop() {
    if [ -f $BUILD_PROP ]; then
        rm -rf $BUILD_PROP
    fi

    echo "ro.hardware.width=${BUILD_WIDTH}" >> $BUILD_PROP
    bb_log_info "ro.hardware.width=${BUILD_WIDTH}"
    echo "ro.hardware.height=${BUILD_HEIGHT}" >> $BUILD_PROP
    bb_log_info "ro.hardware.height=${BUILD_HEIGHT}"
    echo "qemu.sf.lcd_density=${BUILD_DENSITY}" >> $BUILD_PROP
    bb_log_info "qemu.sf.lcd_density=${BUILD_DENSITY}"
    echo "ro.hardware.fps=${BUILD_FPS}" >> $BUILD_PROP
    bb_log_info "ro.hardware.fps=${BUILD_FPS}"
    echo "ro.hardware.enableC2decode=0" >> $BUILD_PROP
    echo "ro.hardware.omxsoftdecode=0" >> $BUILD_PROP
    echo "sys.cpu.limited=0" >> $BUILD_PROP
    # 配置是否使能C2解码器（仅 AMD W6800 GPU）
    if bb_has_amd_w6800_gpu; then
        if [ ${ENABLE_AMD_C2_DECODE} -eq 1 ];then
            sed -i "s/ro.hardware.enableC2decode=0/ro.hardware.enableC2decode=1/g" $BUILD_PROP
            sed -i "s/sys.cpu.limited=0/sys.cpu.limited=1/g" $BUILD_PROP
            sudo chmod 666 /dev/dma_heap/system
        else
            sed -i "s/ro.hardware.enableC2decode=1/ro.hardware.enableC2decode=0/g" $BUILD_PROP
            sed -i "s/sys.cpu.limited=1/sys.cpu.limited=0/g" $BUILD_PROP
        fi
    fi
    # VA GPU(Hantro/SGPU100)需要配置相关属性、修改设备的权限
    if bb_has_hantro_gpu; then
        if [ $ENABLE_HARD_DECODE -eq 1 ];then
            sed -i "s/ro.hardware.omxsoftdecode=1/ro.hardware.omxsoftdecode=0/g" $BUILD_PROP
        else
            sed -i "s/ro.hardware.omxsoftdecode=0/ro.hardware.omxsoftdecode=1/g" $BUILD_PROP
        fi
    fi

}

bb_check_system_size_modify() {
    local target_path="$1"
    
    # 路径为空检查保护
    if [ -z "$target_path" ]; then
        echo -e "\033[33m WARN: Target path is empty. Cannot check fs type. Ignoring custom system size ${SYSTEM_SIZE_MB}M. \033[0m"
        return 1
    fi

    # 获取 target_path 所在磁盘的文件系统类型
    # 屏蔽 df 可能产生的标准错误输出（例如路径不存在时），避免脏日志
    local fs_type=$(df -T "$target_path" 2>/dev/null | tail -n 1 | awk '{print $2}')
    
    if [ "$fs_type" == "xfs" ]; then
        # 条件满足：格式为 xfs，添加存储限制参数
        RUN_OPTION+=" --storage-opt size=${SYSTEM_SIZE_MB}M "
    else
        # 格式不是 xfs：打印警告提示，且不生效该配置 (已将写死的路径替换为变量)
        echo -e "\033[33m WARN: ${target_path} is not xfs format (current: ${fs_type}). Ignoring custom system size ${SYSTEM_SIZE_MB}M. \033[0m"
    fi
}

#===============================================================================
# 硬件检测与配置读取
# 统一检测 GPU 类型/型号、编码卡型号，结果存入全局变量
# 所有消费方使用 BB_HW_* 全局变量判断，禁止散落 lspci 调用
#===============================================================================
# 全局硬件状态变量（由 bb_detect_hardware 一次性设置）
BB_HW_AMD_GPUS=()          # AMD GPU PCI 地址数组
BB_HW_XD_GPUS=()           # XD GPU PCI 地址数组
BB_HW_HANTRO_GPUS=()       # Hantro GPU PCI 地址数组
BB_HW_GPU_TYPE=""          # 主 GPU 类型: "amd"|"xd"|"hantro"|""
BB_HW_AMD_IS_W6800=0       # 1 表示 AMD GPU 型号为 Radeon PRO W6800
BB_HW_ENCODE_CARD=""       # 编码卡型号: "QuadraT2A"|"T432"|""


function bb_detect_hardware() {
    BB_HW_XD_GPUS=($(lspci -D | grep "1fe0:1010" | awk '{print $1}'))
    BB_HW_AMD_GPUS=($(lspci -D | grep "AMD" | grep -E "VGA|73a3|73a1|73e3" | awk '{print $1}'))
    BB_HW_HANTRO_GPUS=($(lspci -D | grep ":0200" | awk '{print $1}'))

    # AMD GPU 型号检测
    if [ ${#BB_HW_AMD_GPUS[@]} -ne 0 ] && lspci | grep -q "Radeon PRO W6800"; then
        BB_HW_AMD_IS_W6800=1
    fi

    # 主 GPU 类型判定（优先级: AMD > XD > Hantro）
    if [ ${#BB_HW_AMD_GPUS[@]} -ne 0 ]; then
        BB_HW_GPU_TYPE="amd"
    elif [ ${#BB_HW_XD_GPUS[@]} -ne 0 ]; then
        BB_HW_GPU_TYPE="xd"
    elif [ ${#BB_HW_HANTRO_GPUS[@]} -ne 0 ]; then
        BB_HW_GPU_TYPE="hantro"
    else
        BB_HW_GPU_TYPE=""
    fi

    # 编码卡型号检测（需要 nvme 命令）
    if command -v nvme &>/dev/null; then
        local nvme_output=$(nvme list 2>/dev/null)
        if echo "$nvme_output" | grep -q "QuadraT2A"; then
            BB_HW_ENCODE_CARD="QuadraT2A"
        elif echo "$nvme_output" | grep -q "T432"; then
            BB_HW_ENCODE_CARD="T432"
        fi
    fi
}

# 软渲染判断（无GPU时自动使能，或手动使能时清空GPU数组）
# 依赖 bb_detect_hardware 已设置 BB_HW_* 全局变量
function bb_check_soft_render() {
    if [ ${#BB_HW_XD_GPUS[@]} -eq 0 ] && [ ${#BB_HW_AMD_GPUS[@]} -eq 0 ] && [ ${#BB_HW_HANTRO_GPUS[@]} -eq 0 ]; then
        ENABLE_SOFT_RENDER=1
    fi
    if [ "${ENABLE_SOFT_RENDER:-0}" -eq 1 ]; then
        BB_HW_XD_GPUS=()
        BB_HW_AMD_GPUS=()
        BB_HW_HANTRO_GPUS=()
        BB_HW_GPU_TYPE=""
        # DEFAULT_PROP 检查仅在变量已设置时执行（视频流需要，Kbox 可选）
        if [ -n "${DEFAULT_PROP:-}" ] && [ ! -f "$DEFAULT_PROP" ]; then
            bb_exit_error "Enable soft render but ${DEFAULT_PROP} not exist!"
        fi
    fi
}

# 初始化 CPU/GPU 绑定映射（统一 Kbox 与视频流）
# 自动绑定优先（ENABLE_AUTO_BINDING=1），否则按 CPU_BIND_MODE 手动查表
# 设置全局变量 CPU_MAP, GPU_MAP
# 视频流专用变量（VSYNC_OFFSET_MAP）在相关配置存在时一并填充
function bb_init_cpu_gpu_maps() {
    local num_of_cpus=$(bb_get_num_of_cpus)

    if [ "${ENABLE_AUTO_BINDING}" == "1" ]; then
        bb_auto_detect_cpu_gpu_binding "${AUTO_CPU_PER_CONTAINER}" "${AUTO_RESERVED_CORES_PER_NUMA}"
        CPU_MAP=("${AUTO_CPUSET_MAP[@]}")
        GPU_MAP=("${AUTO_GPU_MAP[@]}")
        # 自动绑定模式下 AMD GPU 仍需 VSYNC_OFFSET
        if bb_has_amd_gpu && [ -n "${VIDEO_VSYNC_OFFSET_MAP_AMD1+x}" ]; then
            bb_select_amd_gpu_map ${#BB_HW_AMD_GPUS[@]}
        fi
        return
    fi

    # 手动绑定：CPU_MAP 查表
    local has_xd=0
    bb_has_xd_gpu && has_xd=1
    bb_select_cpu_map "$num_of_cpus" "${CPU_BIND_MODE}" "$has_xd"
    bb_select_gpu_map_by_type "$num_of_cpus" BB_HW_XD_GPUS BB_HW_AMD_GPUS BB_HW_HANTRO_GPUS
}

function bb_init_hardware_config() {
    bb_detect_hardware
    bb_check_soft_render

    # CPU/GPU 绑定映射初始化（与视频流统一，由 base_box.sh 提供）
    # 自动绑定优先（ENABLE_AUTO_BINDING=1），否则按 CPU_BIND_MODE 手动查表
    bb_init_cpu_gpu_maps
    ENC_MAP=(${VIDEO_ENC_MAP_CORE[*]})
    USERDATA_MAP=(${USERDATA_MAP[*]})
}


# 便捷判断函数：是否有 AMD GPU
function bb_has_amd_gpu() { [ ${#BB_HW_AMD_GPUS[@]} -ne 0 ]; }

# 便捷判断函数：是否有 AMD W6800 GPU
function bb_has_amd_w6800_gpu() { [ ${#BB_HW_AMD_GPUS[@]} -ne 0 ] && [ "$BB_HW_AMD_IS_W6800" -eq 1 ]; }

# 便捷判断函数：是否有 XD GPU
function bb_has_xd_gpu() { [ ${#BB_HW_XD_GPUS[@]} -ne 0 ]; }

# 便捷判断函数：是否有 Hantro GPU
function bb_has_hantro_gpu() { [ ${#BB_HW_HANTRO_GPUS[@]} -ne 0 ]; }

# 便捷判断函数：是否有任意 GPU
function bb_has_gpu() { [ -n "$BB_HW_GPU_TYPE" ]; }


# 按核数和绑定模式查表选择 CPU_MAP
# 参数：$1=num_of_cpus $2=cpu_bind_mode $3=has_xd_gpu(0/1)
# 设置全局变量 CPU_MAP
function bb_select_cpu_map() {
    local num_of_cpus=$1
    local cpu_bind_mode=$2
    local has_xd_gpu=${3:-0}

    local var_name
    # 特例：128核 MODE1 + XD GPU 需要负载均衡专用表
    if [ "$num_of_cpus" -eq 128 ] && [ "$cpu_bind_mode" -eq 1 ] && [ "$has_xd_gpu" = "1" ]; then
        var_name="VIDEO_XD_CPU_MAP_128CORE_MODE1"
    else
        var_name="VIDEO_CPU_MAP_${num_of_cpus}CORE_MODE${cpu_bind_mode}"
    fi

    local -n _src="${var_name}"
    if [ -z "${_src[*]}" ]; then
        bb_exit_error "CPU_BIND_MODE error: ${cpu_bind_mode} for ${num_of_cpus} cores"
    fi
    CPU_MAP=("${_src[@]}")
}

# 选择 AMD GPU MAP（不依赖核数）
# 参数：$1=amd_gpu_count
# 设置全局变量 GPU_MAP, VSYNC_OFFSET_MAP
function bb_select_amd_gpu_map() {
    local amd_count=$1
    local idx=1
    [ "$amd_count" -eq 2 ] && idx=2
    local -n _gpu="VIDEO_GPU_MAP_AMD${idx}"
    local -n _vsync="VIDEO_VSYNC_OFFSET_MAP_AMD${idx}"
    GPU_MAP=("${_gpu[@]}")
    VSYNC_OFFSET_MAP=("${_vsync[@]}")
}

# 选择 XD GPU MAP（仅128核支持）
# 参数：$1=xd_gpu_count $2=num_of_cpus
# 设置全局变量 GPU_MAP, VPU_MAP
function bb_select_xd_gpu_map() {
    local xd_count=$1
    local num_of_cpus=$2
    local -n _gpu="VIDEO_GPU_MAP_XD${xd_count}_${num_of_cpus}CORE"
    local -n _vpu="VIDEO_VPU_MAP_XD${xd_count}_${num_of_cpus}CORE"
    if [ -z "${_gpu[*]}" ]; then
        bb_log_info "No XD GPU map for count=${xd_count}, core=${num_of_cpus}"
        return 1
    fi
    GPU_MAP=("${_gpu[@]}")
    VPU_MAP=("${_vpu[@]}")
}

# 选择 Hantro/Hanbo GPU MAP（精确匹配 count，回退到 HB4）
# 参数：$1=hb_gpu_count
# 设置全局变量 GPU_MAP
function bb_select_hb_gpu_map() {
    local hb_count=$1
    local num_of_cpus=$2
    local var_name="VIDEO_GPU_MAP_HB${hb_count}"
    local -n _gpu="${var_name}"
    # 精确匹配为空时回退到 HB4
    if [ -z "${_gpu[*]}" ]; then
        var_name="VIDEO_GPU_MAP_HB4"
        local -n _fallback="${var_name}"
        if [ -z "${_fallback[*]}" ]; then
            bb_log_info "No GPU exists on the host. Enable soft render..."
            return 1
        fi
        GPU_MAP=("${_fallback[@]}")
        return
    fi
    GPU_MAP=("${_gpu[@]}")
}

# 按 GPU 类型优先级（AMD > XD > Hantro）选择 GPU_MAP
# 参数：$1=num_of_cpus $2=xd_gpus $3=amd_gpus $4=hantro_gpus
function bb_select_gpu_map_by_type() {
    local num_of_cpus=$1
    local -n _xd=$2
    local -n _amd=$3
    local -n _hantro=$4

    if [ ${#_amd[@]} -ne 0 ]; then
        bb_select_amd_gpu_map ${#_amd[@]}
    elif [ ${#_xd[@]} -ne 0 ]; then
        bb_select_xd_gpu_map ${#_xd[@]} "$num_of_cpus"
    elif [ ${#_hantro[@]} -ne 0 ]; then
        bb_select_hb_gpu_map ${#_hantro[@]} "$num_of_cpus"
    else
        bb_log_info "No GPU exists on the host. Enable soft render..."
    fi
}

#===============================================================================
# CPU/GPU 绑定关系自动推断（路标3：CPU/GPU绑定自动化）
# 根据硬件环境自动推断CPU/GPU绑定关系，可通过手动配置覆盖
# 算法参考 script-refactor-plan.md 3.3.3 节
#===============================================================================

# 自动推断CPU/GPU绑定关系
# 参数：
#   $1: 每组CPU核数（默认2）
#   $2: 每NUMA预留核数（默认0）
# 输出：设置全局数组 AUTO_CPUSET_MAP 和 AUTO_GPU_MAP
function bb_auto_detect_cpu_gpu_binding() {
    local CPU_PER_CONTAINER=${1:-2}
    local RESERVED_CORES_PER_NUMA=${2:-0}

    # 获取NUMA数量
    local NUM_OF_NUMA=$(lscpu 2>/dev/null | grep "NUMA node(s)" | awk '{print $3}')
    [ -z "$NUM_OF_NUMA" ] && NUM_OF_NUMA=1

    # 获取每个NUMA的CPU起止范围
    local -a NUMA_CPU_START NUMA_CPU_END
    local n
    for ((n=0; n<NUM_OF_NUMA; n++)); do
        local cpulist=$(cat /sys/devices/system/node/node${n}/cpulist 2>/dev/null)
        if echo "$cpulist" | grep -q -- '-'; then
            NUMA_CPU_START[$n]=$(echo "$cpulist" | sed 's/-.*//')
            NUMA_CPU_END[$n]=$(echo "$cpulist" | sed 's/.*-//')
        else
            NUMA_CPU_START[$n]=$cpulist
            NUMA_CPU_END[$n]=$cpulist
        fi
    done

    # 获取GPU render节点及其NUMA亲和性，按NUMA分组
    local -a NUMA_GPUS
    local r
    for r in /dev/dri/renderD*; do
        [ -e "$r" ] || continue
        local rname=$(basename "$r")
        local numa=$(cat /sys/class/drm/$rname/device/numa_node 2>/dev/null)
        [ -z "$numa" ] && numa=0
        [ "$numa" -lt 0 ] && numa=0
        if [ -z "${NUMA_GPUS[$numa]}" ]; then
            NUMA_GPUS[$numa]="$r"
        else
            NUMA_GPUS[$numa]="${NUMA_GPUS[$numa]} $r"
        fi
    done

    # 构建每个NUMA的CPU组列表（从预留核之后开始，从前往后划分）
    # 格式: NUMA_CPU_GROUPS[numa]="cpu1 cpu2|cpu3 cpu4|..."
    local -a NUMA_CPU_GROUPS
    local numa
    for ((numa=0; numa<NUM_OF_NUMA; numa++)); do
        local start=$((NUMA_CPU_START[$numa] + RESERVED_CORES_PER_NUMA))
        local end=${NUMA_CPU_END[$numa]}
        local groups=""
        local c
        for ((c=start; c+CPU_PER_CONTAINER-1<=end; c+=CPU_PER_CONTAINER)); do
            local group=""
            local i
            for ((i=0; i<CPU_PER_CONTAINER; i++)); do
                group="$group $((c+i))"
            done
            group=$(echo "$group" | sed 's/^ //')
            if [ -z "$groups" ]; then
                groups="$group"
            else
                groups="$groups|$group"
            fi
        done
        NUMA_CPU_GROUPS[$numa]="$groups"
    done

    # 桶分配顺序：4 NUMA时使用 0-2-1-3 确保跨numa和跨socket均衡
    local -a BUCKET_ORDER
    if [ "$NUM_OF_NUMA" -eq 4 ]; then
        BUCKET_ORDER=(0 2 1 3)
    else
        local idx
        for ((idx=0; idx<NUM_OF_NUMA; idx++)); do
            BUCKET_ORDER[$idx]=$idx
        done
    fi

    # 生成绑定映射
    local MAX_CONTAINERS=64
    local -a bucket_cpu_cursor bucket_gpu_cursor
    local i
    for ((i=0; i<NUM_OF_NUMA; i++)); do
        bucket_cpu_cursor[$i]=0
        bucket_gpu_cursor[$i]=0
    done

    AUTO_CPUSET_MAP=()
    AUTO_GPU_MAP=()

    local container_idx
    for ((container_idx=0; container_idx<MAX_CONTAINERS; container_idx++)); do
        local bucket=${BUCKET_ORDER[$((container_idx % NUM_OF_NUMA))]}

        # 分配CPU组
        local all_groups=${NUMA_CPU_GROUPS[$bucket]}
        local group_count=$(echo "$all_groups" | tr '|' '\n' | wc -l)
        local cursor=${bucket_cpu_cursor[$bucket]}

        if [ "$cursor" -ge "$group_count" ]; then
            AUTO_CPUSET_MAP[$container_idx]=""
            AUTO_GPU_MAP[$container_idx]=""
            continue
        fi

        local cpu_group=$(echo "$all_groups" | cut -d'|' -f$((cursor + 1)))
        AUTO_CPUSET_MAP[$container_idx]="$cpu_group"
        bucket_cpu_cursor[$bucket]=$((cursor + 1))

        # 分配GPU节点（按桶内轮询）
        local gpus=${NUMA_GPUS[$bucket]}
        if [ -n "$gpus" ]; then
            local gpu_count=$(echo "$gpus" | wc -w)
            local gpu_cursor=${bucket_gpu_cursor[$bucket]}
            local gpu_idx=$((gpu_cursor % gpu_count))
            local gpu=$(echo "$gpus" | tr ' ' '\n' | sed -n "$((gpu_idx + 1))p")
            AUTO_GPU_MAP[$container_idx]="$gpu"
            bucket_gpu_cursor[$bucket]=$((gpu_cursor + 1))
        else
            AUTO_GPU_MAP[$container_idx]=""
        fi
    done

    echo "Auto CPU/GPU binding generated: ${MAX_CONTAINERS} slots, CPU_PER_CONTAINER=${CPU_PER_CONTAINER}, NUMA=${NUM_OF_NUMA}"
}

function bb_wait_cmd() {
    local count_time=0
    while true; do
        local result=$(bb_wait_async_cmd "$1")
        if [ "$result" != "-1" ]; then
            echo ${result}
            break
        fi

        if [ ${count_time} -gt 3 ]; then
            echo -1
            break
        fi
        count_time=$((count_time + 1))
    done
}

function bb_check_wait_cmd_result() {
    local cmd=$1
    local result=$2
    if [ "$result" == "-1" ]; then
        echo "cmd \"${cmd}\" wait_cmd timeout"
    fi
}

function bb_restart_box() {
    # 从 BB_* 全局配置变量读取参数
    local BOX_NAME="${BB_NAME}"
    local USER_DATA_PATH="${BB_USER_DATA_PATH}"
    local restart_times="${BB_RESTART_TIMES:-3}"
    local ENABLE_HARD_DECODE="${BB_ENABLE_HARD_DECODE:-0}"
    local ENABLE_RENDER_LAYER="${BB_ENABLE_RENDER_LAYER:-0}"
    local ENABLE_F2FS="${BB_ENABLE_F2FS:-0}"
    local SYSTEM_SIZE_MB="${BB_SYSTEM_SIZE_MB:-0}"
    local KBOX_SWITCH="/sys/kernel/kbox/kbox_enable"
    if [ -f "$KBOX_SWITCH" ] && [ "$(cat "$KBOX_SWITCH")" = "0" ]; then
        echo "1" > "$KBOX_SWITCH"
    fi

    # --- 新增获取 CONTAINER_DATA_PATH 的逻辑 ---
    local CONTAINER_DATA_PATH=""
    if [ "$DEFAULT_RUNTIME" == "docker" ]; then
        CONTAINER_DATA_PATH=$($RUNTIME_CMD info --format '{{.DockerRootDir}}' 2>/dev/null || echo "/var/lib/docker")
    else
        CONTAINER_DATA_PATH="/var/lib/containerd"
        SYSTEM_SIZE_MB=0
    fi
    # --------------------------------------------

    set +e
    if [ -z ${USER_DATA_PATH} ]; then
        USER_DATA_PATH="/root/mount"
    fi

    echo "mount ${BOX_NAME}.img"
    if [ "$ENABLE_F2FS" == "1" ]; then
        bb_check_f2fs_partition "${USER_DATA_PATH}/data"
        if [ $? -ne 0 ]; then
            return 1 # 校验失败，直接退出拉起流程
        fi
        mount -t f2fs -o loop ${USER_DATA_PATH}/img/${BOX_NAME}.img ${USER_DATA_PATH}/data/${BOX_NAME} >/dev/null
    else
        mount ${USER_DATA_PATH}/img/${BOX_NAME}.img ${USER_DATA_PATH}/data/${BOX_NAME} >/dev/null
    fi

    if [ "$SYSTEM_SIZE_MB" -ne 0 ]; then
        bb_check_system_size_modify "$CONTAINER_DATA_PATH"
    fi

    bb_mock_cpu

    $RUNTIME_CMD inspect ${BOX_NAME} >/dev/null
    if [ $? -ne 0 ]; then
        # 无容器判断
        return 1
    fi

    local VA_SGPU100_ID=":0200"
    if [ -n "$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')" ]; then
        grep -q "ro\.va\.video\.codec=c2" $THISDIR/build.prop || echo "ro.va.video.codec=c2" >> $THISDIR/build.prop
    fi

    for i in $(seq 1 $restart_times)
    do
        local should_restart=0 # 0为不应该再重启，1为需要再次重启
        $RUNTIME_CMD stop -t 0 ${BOX_NAME}
        echo "${BOX_NAME} begins restarting the $i times!"
        $RUNTIME_CMD start ${BOX_NAME}

        if [ $DEFAULT_RUNTIME == "containerd" ]; then
            $RUNTIME_CMD exec -i ${BOX_NAME} ln -s /dev/net/tun /dev/tun
        fi
        for j in $(seq 1 3)
        do {
            $RUNTIME_CMD inspect ${BOX_NAME} --format {{.State.Status}} |grep running
            if [ $? -eq 0 ]; then
                # 等待容器状态为 running
                break
            fi
            sleep 1
        } done

        local cid=$($RUNTIME_CMD ps | grep -w " ${BOX_NAME}" | awk '{print $1}')
        local BINDER_MAJOR_ID=$(cat /proc/devices | grep binder | awk '{print $1}')

        # 支持Android系统属性可定制
        # local.prop用于修改定制属性，但该文件不是一定存在，需要用户手动生成。
        if [ -e "$CURRENT_DIR/local.prop" ]; then
            $RUNTIME_CMD cp $CURRENT_DIR/local.prop ${BOX_NAME}:/data
            sleep 0.5
            $RUNTIME_CMD exec ${BOX_NAME} chmod 400 /data/local.prop
        fi

        local count_time=0
        while true; do
            local cmd="$RUNTIME_CMD exec -i ${BOX_NAME} getprop sys.boot_completed | grep 1 > /dev/null 2>&1 &"
            local result=$(bb_wait_cmd "${cmd}")
            bb_check_wait_cmd_result "${cmd}" "${result}"
            if [ "${result}" == "0" ]; then
                # 等待容器启动完成
                bb_check_key_process ${BOX_NAME}
                [ ${?} -ne 0 ] && echo "${BOX_NAME} check key process fail" && should_restart=1
                break
            fi
            if [ ${count_time} -gt 50 ]; then
                echo -e "\033[1;31m reStart check timed out,${BOX_NAME} unable to restart\033[0m"
                should_restart=1
                break
            fi
            sleep 1
            count_time=$((count_time + 1))
        done

        if [ $i -eq $restart_times ] && [ $should_restart -eq 1 ];then
            echo "${BOX_NAME} start failed!"
            return 1
        fi
        local cmd="$RUNTIME_CMD exec -i ${BOX_NAME} logcat -d |grep \"addInterfaceToNetwork() failed\" &"
        local result=$(bb_wait_async_cmd "${cmd}")
        if [ "${result}" == "-1" ];then
            echo "${BOX_NAME} wait_async_cmd logcat timeout"
        elif [ "${result}" != "0" ];then
            # 无异常日志, 且检查关键进程均无异常，退出重启流程
            if [ $should_restart -eq 0 ]; then
                break
            fi
        fi
    done

    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        docker exec -it "${BOX_NAME}" sh -c "setprop debug.gles.layers RenderAccLayer.kbox.so"
    fi
}
