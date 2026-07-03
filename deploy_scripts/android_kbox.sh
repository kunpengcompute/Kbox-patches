#!/bin/bash
# Copyright Huawei Technologies Co., Ltd. 2021-2021. All rights reserved.
#===============================================================================
# Source base_box.sh (公共函数库)
#===============================================================================
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ ! -e "${CURRENT_DIR}/base_box.sh" ]; then
    echo "Can not find file base_box.sh"
    exit 1
fi
source "${CURRENT_DIR}/base_box.sh"

#===============================================================================
# Functions
#===============================================================================
function init_kbox_env() {
    bb_init_runtime_env
    local KBOX_CFG=$CURRENT_DIR/kbox_config.cfg
    if [ ! -f "$KBOX_CFG" ]; then
        bb_exit_error "Can not find file $KBOX_CFG"
    fi
    source $KBOX_CFG
    bb_log_info "$KBOX_CFG loaded"

    DOCKER_NAME_PREFIX="kbox_"  # must end with "_"

    bb_init_hardware_config

    bb_check_environment
    bb_log_info "Default container runtime selected: ${DEFAULT_RUNTIME}"
}

function check_kbox_paras() {
    if [ $# -eq 0 ]; then
        echo "command must be \"start\", \"delete\" or \"restart\" "
        exit 1
    fi

    if [ $1 == "start" ] || [ $1 == "nstart" ]; then
        if [ $# -gt 4 ]; then
            echo "the number of parameters exceeds 4!"
            echo "Usage: "
            echo "./android_kbox.sh $1 <image_id> <start_container_id> <end_container_id>"
            echo "./android_kbox.sh $1 <image_id> <container_id>"
            exit 1;
        fi

        local IMAGE_ID=$2
        if [[ "${IMAGE_ID}" =~ ":" ]]; then
            local IMAGE_RE=$(echo ${IMAGE_ID} | cut -d ':' -f1)
            tag=$(echo ${IMAGE_ID} | cut -d ':' -f2)
            docker images | awk '{print $1" "$2}' | grep -w "${IMAGE_RE}" | grep -w "${tag}" >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "no image ${IMAGE_ID}"
                exit 1
            fi
        else
            docker images | awk '{print $3}' | grep -w "${IMAGE_ID}" >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "no image ${IMAGE_ID}"
                exit 1
            fi
        fi

        if [ -n "`echo "$3$4" | sed 's/[0-9]//g'`" ]; then
            echo "The third and fourth parameters must be numbers."
            exit 1
        fi

        local MIN=$3 MAX=$4
        if [ -z "$4" ]; then
            MAX=$3
        fi

        if [ $MIN -gt $MAX ]; then
            echo "start_num must be less than or equal to end_num"
            exit 1
        fi
    elif [ $1 == "delete" ] || [ $1 == "ndelete" ]; then
        if [ $# -gt 3 ]; then
            echo "the number of parameters exceeds 3!"
            echo "Usage: "
            echo "./android_kbox.sh $1 <start_container_id> <end_container_id>"
            echo "./android_kbox.sh $1 <container_id>"
            exit 1
        fi

        if [ -n "`echo "$2$3" | sed 's/[0-9]//g'`" ]; then
            echo "The second and third parameters must be numbers."
            exit 1
        fi

        local MIN=$2 MAX=$3
        if [ -z $3 ]; then
            MAX=$2
        fi

        if [ $MIN -gt $MAX ]; then
            echo "start_num must be less than or equal to end_num"
            exit 1
        fi
    elif [ $1 == "restart" ]; then
        if [ $# -gt 3 ]; then
            echo "the number of parameters exceeds 3!"
            echo "Usage: "
            echo "./android_kbox.sh restart <start_container_id> <end_container_id>"
            echo "./android_kbox.sh restart <container_id>"
            exit 1
        fi

        if [ -n "`echo "$2$3" | sed 's/[0-9]//g'`" ]; then
            echo "The second and third paramelters must be numbers."
            exit 1
        fi

        local MIN=$2 MAX=$3
        if [ -z $3 ]; then
            MAX=$2
        fi

        if [ $MIN -gt $MAX ]; then
            echo "start_num must be less than or equal to end_num"
            exit 1
        fi
    else
        echo "command must be \"start\", \"delete\" or \"restart\" "
    fi
}

function disable_ipv6_icmp() {
    # 更改容器内部accept_redirects参数配置，禁止ipv6的icmp重定向功能
    KBOX_NAME=$1
    temp=$(mktemp)
    echo 0 > $temp
    pid=$(docker inspect ${KBOX_NAME} | grep Pid | awk -F, '{print $1}' | sed -n '1p' | awk '{print $2}')
    nsenter -n -t ${pid} cp $temp /proc/sys/net/ipv6/conf/all/accept_redirects
    rm $temp
}

function enable_netint() {
    # 不需要使能硬解设备
    if [ $T432_QUADRA_DECODE_ENABLE -ne 1 ];then
        return
    fi

    # VA GPU 无此步骤，直接退出
    if bb_has_hantro_gpu; then
        return;
    fi

    local container_name=$1
    bb_check_encode_card
    # T432初始化执行方式不变；Quadra采用ni_rsrc_mon自启动，生命周期由编码卡厂家管理，此处仅打印返回值
    if [ "$NETINT_TYPE" == "t432" ];then
        docker exec -itd ${container_name} /system/bin/ni_rsrc_mon_logan
        sleep 3
        docker exec -itd ${container_name} chmod 666 /dev/nvm*n*
        docker exec -itd ${container_name} chmod 777 -R /dev/shm_netint
        [ ${?} != 0 ] && echo "Failed to enable netint device" && return
        echo "enable netint device success"
    elif [ "$NETINT_TYPE" == "quadra" ];then
        local container_name=$1
        local ni_init_success=$(docker exec -itd ${container_name} getprop ni_rsrc_init_completed)
        if [ "${ni_init_success}" == "yes" ]; then
            echo "Failed to enable netint device"
        else
            echo "enable netint device success"
        fi
    else
        return;
    fi
}

function netint_run_option() {
    container_id=$1
    local opt=""
    local encs_string=${ENC_MAP[$((($container_id - 1) % ${#ENC_MAP[*]}))]}
    local encs=""
    local encs_dev=()
    IFS=',' read -r -a encs_dev <<< $encs_string
    for i in ${encs_dev[*]}; do
        encs+=" --device=${i}:${i}:rwm"
    done
    opt+=$encs

    echo "$opt"
}

function start_box_by_id() {
    local enable_nfs=0
    if [ "$1" = "nstart" ];then
        bb_check_nfs_mount "$NFS_DIR"
        enable_nfs=1
    fi
    bb_check_nfs_f2fs_conflict "$enable_nfs"

    # 基本参数准备
    local IMAGE_NAME=$2
    local container_id=$3
    local CONTAINER_NAME="${DOCKER_NAME_PREFIX}${container_id}"
    local RAM_SIZE_MB=$(($RAM_SIZE_GB * 1024))
    local cpus_string=${CPU_MAP[$((($container_id - 1) % ${#CPU_MAP[*]}))]}
    local cpus=()
    IFS=',' read -r -a cpus <<< $cpus_string
    local gpu_node=()
    if [ ${ENABLE_SOFT_RENDER} -ne 1 ]; then
        gpu_node=${GPU_MAP[$((($container_id - 1) % ${#GPU_MAP[*]}))]}
    fi
    local userdata_dir=${USERDATA_MAP[$((($container_id - 1) % ${#USERDATA_MAP[*]}))]}
    local NUMAS=($(echo $(bb_get_closest_numas ${cpus[@]}) | tr ' ' '\n' | sort -u | tr '\n' ' '))
    local PORTS=("$((8500+$container_id)):5555")
    
    # 准备云机属性配置文件
    bb_create_build_prop

    # 准备额外启动参数
    local EXTRA_RUN_OPTION=""
    # 使能硬解设备，若获取到的值为空，则不使能
    if [ $ENABLE_SOFT_RENDER -eq 1 ]; then
        true
    elif bb_has_hantro_gpu; then
        EXTRA_RUN_OPTION=" ENABLE_HARD_DECODE=${ENABLE_HARD_DECODE}"
    elif bb_has_xd_gpu; then
        local idx=$((`echo ${GPUS_RENDER:16}` - 128))
        # docker额外启动参数
        EXTRA_RUN_OPTION+=" --device=/dev/pvr_sync:/dev/pvr_sync:rwm "
        EXTRA_RUN_OPTION+=" --device=/dev/ion-$idx:/dev/ion:rwm "
        EXTRA_RUN_OPTION+=" --device=${GPUS_RENDER}:/dev/renderD190:rwm"
    else
        # amdgpu 搭配编码卡使用
        EXTRA_RUN_OPTION=$(netint_run_option $container_id)
        EXTRA_RUN_OPTION+=" -e ENABLE_AMD_C2_DECODE=${ENABLE_AMD_C2_DECODE}"
    fi

    BB_NAME="$CONTAINER_NAME"
    BB_CPUS="${cpus[*]}"
    BB_NUMAS="${NUMAS[*]}"
    BB_GPUS_RENDER="${gpu_node[*]}"
    BB_STORAGE_SIZE_GB="$STORAGE_SIZE_GB"
    BB_RAM_SIZE_MB="$RAM_SIZE_MB"
    BB_PORTS="${PORTS[*]}"
    BB_EXTRA_RUN_OPTION="$EXTRA_RUN_OPTION"
    BB_IMAGE_NAME="$IMAGE_NAME"
    BB_USER_DATA_PATH="$userdata_dir"
    BB_ENABLE_RENDER_LAYER="$ENABLE_RENDER_LAYER"
    BB_ENABLE_F2FS="$ENABLE_F2FS"
    BB_SYSTEM_SIZE_MB="$SYSTEM_PARTITION_SIZE_MB"
    BB_ENABLE_NFS="$enable_nfs"
    BB_NFS_DIR="$NFS_DIR"
    BB_SKIP_DATA_COPY=0
    bb_start_box

    # 新增拦截：判断上方的 bb_start_box 是否成功执行
    if [ $? -ne 0 ]; then
        bb_log_error "${CONTAINER_NAME} 基础环境准备失败，终止后续拉起流程！"
        return 1
    fi

    bb_prepare_media_codecs_for_amd ${CONTAINER_NAME}

    if [ -n "$(docker ps -a --format {{.Names}} | grep "$CONTAINER_NAME$")" ]; then
        # 等待容器启动
        bb_wait_container_ready ${CONTAINER_NAME}
        [ ${?} -eq 1 ] && return

        set -e
        enable_netint ${CONTAINER_NAME}

        # 更改容器内部accept_redirects参数配置，禁止ipv6的icmp重定向功能
        disable_ipv6_icmp ${CONTAINER_NAME}
        echo -e "---------------------- done ----------------------\n"
    fi
    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        # 渲染中间层，放在base_box.sh会set property失败
        docker exec -it ${CONTAINER_NAME} sh -c "setprop debug.gles.layers RenderAccLayer.kbox.so"
    fi
}

#===============================================================================
# CLI 命令分发函数（每个子命令对应一个独立函数）
#===============================================================================

function cli_start() {
    local MIN=$3 MAX=$4
    if [ -z $4 ]; then
        MAX=$3
    fi

    local container_id
    for container_id in $(seq $MIN $MAX); do
        if [ -n "$(docker ps -a --format {{.Names}} | grep "${DOCKER_NAME_PREFIX}$container_id$")" ]; then
            bb_log_warn "${DOCKER_NAME_PREFIX}$container_id exist!"
        else
            start_box_by_id $1 $2 $container_id
        fi
    done
}

function cli_delete() {
    local MIN=$2 MAX=$3
    if [ -z $3 ]; then
        MAX=$2
    fi

    local container_id
    for container_id in $(seq $MIN $MAX);do
        if [ -z "$(docker ps -a --format {{.Names}} | grep "${DOCKER_NAME_PREFIX}$container_id$")" ]; then
            bb_log_warn "no container ${DOCKER_NAME_PREFIX}$container_id!"
        else
            local CONTAINER_NAME="${DOCKER_NAME_PREFIX}$container_id"
            local MOUNT_DIR=$(bb_get_mount_dir "$CONTAINER_NAME")
            if [ $1 = "ndelete" ]; then
                MOUNT_DIR=$NFS_DIR
            fi
            bb_log_info "delete using mount path: $MOUNT_DIR"
            BB_NAME="$CONTAINER_NAME"
            BB_USER_DATA_PATH="$MOUNT_DIR"
            bb_delete_box
        fi
    done
}

function cli_restart() {
    local MIN=$2 MAX=$3
    if [ -z $3 ]; then
        MAX=$2
    fi
    local container_id
    for container_id in $(seq $MIN $MAX);do
        if [ -z "$(docker ps -a --format {{.Names}} | grep "${DOCKER_NAME_PREFIX}$container_id$")" ]; then
            bb_log_warn "no container ${DOCKER_NAME_PREFIX}$container_id!"
        else
            set +e
            local CONTAINER_NAME="${DOCKER_NAME_PREFIX}${container_id}"
            local MOUNT_DIR=$(bb_get_mount_dir "$CONTAINER_NAME")
            bb_log_info "restart using mount path: $MOUNT_DIR"

            bb_prepare_media_codecs_for_amd ${CONTAINER_NAME}
            bb_create_build_prop
            BB_NAME="$CONTAINER_NAME"
            BB_USER_DATA_PATH="$MOUNT_DIR"
            BB_RESTART_TIMES=3
            BB_ENABLE_HARD_DECODE="${ENABLE_HARD_DECODE}"
            BB_ENABLE_RENDER_LAYER="${ENABLE_RENDER_LAYER}"
            BB_ENABLE_F2FS="${ENABLE_F2FS}"
            BB_SYSTEM_SIZE_MB="${SYSTEM_PARTITION_SIZE_MB}"
            bb_restart_box
            [ ${?} -eq 1 ] && continue

            enable_netint "$CONTAINER_NAME"
            set -e
        fi
    done
}

#===============================================================================
# Main
#===============================================================================
function main() {
    check_kbox_paras "$@"

    init_kbox_env
    case "$1" in
        start|nstart)
            cli_start "$@"
            ;;
        delete|ndelete)
            cli_delete "$@"
            ;;
        restart)
            cli_restart "$@"
            ;;
        *)
            bb_exit_error "Unknown command: $1"
            ;;
    esac
}

main "$@"
