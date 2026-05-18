#!/bin/bash
# Copyright Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.

#===============================================================================
# Global Variable
#===============================================================================
XD_GPU_ID="1fe0:1010"
VA_SGPU100_ID=":0200"
THISDIR=$(readlink -ef $(dirname $0))
#===============================================================================
# Functions
#===============================================================================
function check_environment() {
    # root权限执行此脚本
    if [ "${UID}" -ne 0 ]; then
        echo  "请使用root权限执行"
        exit 1
    fi

    # 支持非当前目录执行
    CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    echo "Current Path:$CURRENT_DIR"
    cd ${CURRENT_DIR}

    # 检查是否存在配置文件，不存在配置文件，直接退出
    local KBOX_CFG=$CURRENT_DIR/kbox_config.cfg
    if [ -f $KBOX_CFG ]
    then
        source $KBOX_CFG
        echo "kbox_config.cfg exists, loaded"
    else
        echo "kbox_config.cfg not found"
        exit 1
    fi

    check_devices
}

function check_devices() {
    # 确定kernel版本
    local KERNEL_VERSION=$(uname -r)

    chmod 600 /dev/dri/*
    chmod 600 /dev/input

    if [ -n "$(lspci -n | grep ${XD_GPU_ID})" ]; then
        chmod 666 /dev/ion*
        chmod 666 /dev/pvr_sync
    fi
}

function check_nfs_mount() {
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

function check_paras() {
    set +e

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

function get_closest_numas() {
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

function wait_async_cmd() {
    eval $1
    local pid=$(jobs -rp)
    local count_time=0
    while true; do
        local count=$(jobs -rp | wc -l)
        if [ ${count} -eq 0 ]; then
            wait ${pid}
            return "$?"
        fi

        if [ ${count_time} -gt 8 ]; then
            kill -9 ${pid}
            return 255
        fi

        sleep 0.5
        count_time=$((count_time + 1))
    done
}

function wait_cmd() {
    local count_time=0
    while true; do
        wait_async_cmd "$1"
        local result=$?
        if [ "${result}" != "255" ]; then
            return ${result}
        fi

        if [ ${count_time} -gt 3 ]; then
            return 255
        fi
        count_time=$((count_time + 1))
    done
}

function wait_container_ready() {
    local KBOX_NAME=$1
    local starttime=$(date +'%Y-%m-%d %H:%M:%S')
    local start_seconds=$(date --date="${starttime}" +%s)
    local res=0
    local has_restart=0
    local MOUNT_SOURCE=$(docker inspect --format='{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}' ${KBOX_NAME})
    local MOUNT_DIR
    if [ -n "$MOUNT_SOURCE" ]; then
        MOUNT_DIR=$(echo "$MOUNT_SOURCE" | sed "s|/data/${KBOX_NAME}/data$||")
        if [ "$MOUNT_DIR" == "$MOUNT_SOURCE" ]; then
            MOUNT_DIR=$(dirname "$MOUNT_SOURCE")
        fi
    fi
    if [ $? -eq 0 ]; then
        count_time=0
        set +e
        while true; do
            local cmd="docker exec -i $1 getprop sys.boot_completed | grep 1 &"
            wait_cmd "${cmd}" >/dev/null 2>&1
            local result=$?
            if [ "${result}" == "0" ]; then
                bash $CURRENT_DIR/base_box_aosp15.sh chk_key_process ${CONTAINER_NAME}
                [ ${?} -ne 0 ] && has_restart=1 && bash $CURRENT_DIR/base_box_aosp15.sh restart "${CONTAINER_NAME}" "$MOUNT_DIR" 2
                [ ${?} -eq 1 ] && [ $has_restart -eq 1 ] && echo "${KBOX_NAME} started failed at $(date +'%Y-%m-%d %H:%M:%S')!" && res=1 && break

                echo "${KBOX_NAME} started successfully at $(date +'%Y-%m-%d %H:%M:%S')!"
                break
            elif [ "${result}" == "255" ]; then
                echo "${KBOX_NAME} wait_async_cmd timeout, exit and continue!"
            fi
            # 200秒未成功启动超时跳过
            if [ ${count_time} -gt 200 ]; then
                echo -e "\033[1;31mStart check timed out,${KBOX_NAME} unable to start\033[0m"
                echo -e "\033[1;31m${KBOX_NAME} started failed\033[0m"
                break
            fi
            sleep 1
            count_time=$((count_time + 1))
        done
    else
        echo "${KBOX_NAME} started failed"
    fi
    local endtime=$(date +'%Y-%m-%d %H:%M:%S')
    local end_seconds=$(date --date="${endtime}" +%s)
    echo "time: "$((end_seconds - start_seconds))"s"
    return $res
}

function mount_lxcfs(){
    docker exec -it $1 mount --bind /lxcfs-proc/meminfo /proc/meminfo
    docker exec -it $1 mount --bind /lxcfs-proc/diskstats /proc/diskstats
    docker exec -it $1 mount --bind /lxcfs-proc/stat /proc/stat
    docker exec -it $1 mount --bind /lxcfs-proc/swaps /proc/swaps
    docker exec -it $1 mount --bind /lxcfs-proc/uptime /proc/uptime
}

function disable_ipv6_icmp() {
    # 更改容器内部accept_redirects参数配置，禁止ipv6的icmp重定向功能
    KBOX_NAME=$1
    trap 'rm -f "$temp"' EXIT
    temp=$(mktemp)
    echo 0 > $temp
    pid=$(docker inspect ${KBOX_NAME} | grep Pid | awk -F, '{print $1}' | sed -n '1p' | awk '{print $2}')
    nsenter -n -t ${pid} cp $temp /proc/sys/net/ipv6/conf/all/accept_redirects
}

function check_encode_card()
{
    # 检查nvme指令
    cmd="nvme --help"
    $cmd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "nvme command unavailable, cannot auto detect vpu"
        return 0
    fi
 
    cmd="nvme list"
    output=$($cmd)
}

function enable_hard_decoder() {
    local TAG_NUMBER=$1
    local container_name=kbox_$TAG_NUMBER
    # Exited转态时需先重启容器才能拷贝文件
    local MOUNT_DIR=${KBOX_MOUNT_MAP[$TAG_NUMBER - 1]}
    local status=$(docker ps -a| grep -w $container_name)
    if [[ "$status" =~ "Exited" ]]; then
        echo "kbox_$TAG_NUMBER is exited!"
        if [ -z ${MOUNT_DIR} ]; then
            MOUNT_DIR="/root/mount"
        fi
        mount ${MOUNT_DIR}/img/${container_name}.img ${MOUNT_DIR}/data/${container_name} >/dev/null
        docker start ${container_name}
        sleep 2
    fi
    if [ -n "$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')" ]; then
        # VA GPU 硬解逻辑到base_box中处理，兼容视频流
        return;
    fi
    # 不使用硬解
    if [ $ENABLE_HARD_DECODE -ne 1 ];then
        docker cp ${container_name}:/system/vendor/etc/media_codecs.xml .
        sed -i '81,100d' media_codecs.xml    #删除当前xml文件中关于解码器相关配置
        chmod 644 media_codecs.xml
        docker cp ./media_codecs.xml ${container_name}:/system/vendor/etc/
        return
    fi
    echo "enable hard decoder done"
}

function enable_netint() {
    # 不需要使能硬解设备
    if [ $ENABLE_HARD_DECODE -ne 1 ];then
        return
    fi

    # VA GPU 无此步骤，直接退出
    if [ -n "$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')" ]; then
        return;
    fi

    container_name=$1
    check_encode_card
    local container_name=$1
    local ni_init_success=$(docker exec -itd ${container_name} getprop ni_rsrc_init_completed)
    if [ "${ni_init_success}" == "yes" ]; then
        echo "Failed to enable netint device"
    else
        echo "enable netint device success"
    fi
}

function netint_run_option() {
    container_id=$1
    local opt=""
    local encs_string=${KBOX_DEC_MAP[$container_id - 1]}
    local encs=""
    local encs_dev=()
    IFS=',' read -r -a encs_dev <<< $encs_string
    for i in ${encs_dev[*]}; do
        encs+=" --device=${i}:${i}:rwm"
    done
    opt+=$encs

    echo "$opt"
}

function create_build_prop() {
    echo "debug.stagefright.ccodec=0" >> $THISDIR/build.prop
}

function start_box_by_id() {
    local enable_nfs=0
    if [ "$1" = "nstart" ];then
        check_nfs_mount "$NFS_DIR"
        enable_nfs=1
    fi
    # 镜像名
    local IMAGE_NAME=$2

    # 容器编号
    local TAG_NUMBER=$3

    # 没有GPU不启动容器
    local GPUS_INFO=($(lspci -D | grep "VGA compatible controller: Advanced Micro Devices" | awk '{print $1}'))
    # 芯动/VA GPU卡无法通过以上方式识别
    GPUS_INFO+=$(lspci -n | grep ${XD_GPU_ID} | awk '{print $3}')
    GPUS_INFO+=$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')
    if [ ${#GPUS_INFO[@]} -eq 0 ]; then
        echo "No GPU exists on the host"
        exit 1
    fi

    # 容器名
    local CONTAINER_NAME="kbox_$TAG_NUMBER"

    # 存储大小
    local STORAGE_SIZE_GB=16

    # 运行内存
    local RAM_SIZE_MB
    if [ -n "$(lspci -D | grep "VGA compatible controller: Advanced Micro Devices" | grep "73a3")" ] || \
       [ -n "$(lspci -D | grep "VGA compatible controller: Advanced Micro Devices" | grep "Radeon PRO W6800")" ] || \
       [ -n "$(lspci -n | grep ${XD_GPU_ID})" ] || \
       [ -n "$(lspci -n | grep ${VA_SGPU100_ID})" ]; then
        RAM_SIZE_MB=6144
    else
        RAM_SIZE_MB=4096
    fi

    # CPUS
    local CPUS
    local CPUS_STRING=${KBOX_CPUSET_MAP[TAG_NUMBER - 1]}
    IFS=' ' read -r -a CPUS <<< $CPUS_STRING

    # GPU
    local GPUS_RENDER
    if [ -n "$(lspci -n | grep ${XD_GPU_ID})" ]; then
        # GPU, XD一个GPU对应四个render
        local xd_gpus=($(lspci -D | grep "3D controller" | awk '{print $1}'))
        if [ ${#xd_gpus[@]} -eq 2 ]; then
            GPUS_RENDER=${KBOX_XD_GPU_MAP_8RENDERS[TAG_NUMBER - 1]}
        elif [ ${#xd_gpus[@]} -eq 4 ]; then
            GPUS_RENDER=${KBOX_XD_GPU_MAP_16RENDERS[TAG_NUMBER - 1]}
        elif [ ${#xd_gpus[@]} -eq 6 ]; then
            GPUS_RENDER=${KBOX_XD_GPU_MAP_24RENDERS[TAG_NUMBER - 1]}
        else
            GPUS_RENDER=${KBOX_XD_GPU_MAP_4RENDERS[TAG_NUMBER - 1]}
        fi
    elif [ -n "$(lspci -n | grep ${VA_SGPU100_ID})" ]; then
        GPUS_RENDER=${KBOX_VA_GPU_MAP[TAG_NUMBER - 1]}
    else
        GPUS_RENDER=${KBOX_GPU_MAP[TAG_NUMBER - 1]}
    fi

    # Data mount dir
    local MOUNT_DIR=${KBOX_MOUNT_MAP[TAG_NUMBER - 1]}

    # NUMA
    local NUMAS=($(echo $(get_closest_numas ${CPUS[@]}) | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # 调试端口
    local PORTS=("$((8500+$TAG_NUMBER)):5555")

    if [ -f $THISDIR/build.prop ]; then
	    rm -rf $THISDIR/build.prop
    fi

    create_build_prop

    # docker额外启动参数
    local EXTRA_RUN_OPTION=""
    # 使能硬解设备，若获取到的值为空，则不使能
    if [ -n "$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')" ]; then
        EXTRA_RUN_OPTION=" ENABLE_HARD_DECODE=${ENABLE_HARD_DECODE}"
    elif [ -n "$(lspci -n | grep ${XD_GPU_ID})" ]; then
        local idx=$((`echo ${GPUS_RENDER:16}` - 128))
        # docker额外启动参数
        EXTRA_RUN_OPTION+=" --device=/dev/pvr_sync:/dev/pvr_sync:rwm "
        EXTRA_RUN_OPTION+=" --device=/dev/ion-$idx:/dev/ion:rwm "
        EXTRA_RUN_OPTION+=" --device=${GPUS_RENDER}:/dev/renderD190:rwm"
    else
        # amdgpu 搭配编码卡使用
        EXTRA_RUN_OPTION=$(netint_run_option $TAG_NUMBER)
        EXTRA_RUN_OPTION+=" -e ENABLE_AMD_C2_DECODE=${ENABLE_AMD_C2_DECODE}"
    fi

    bash $CURRENT_DIR/base_box_aosp15.sh start \
    --name "$CONTAINER_NAME" \
    --cpus "${CPUS[*]}" \
    --numas "${NUMAS[*]}" \
    --gpus  "${GPUS_RENDER[*]}" \
    --storage_size_gb "$STORAGE_SIZE_GB" \
    --ram_size_mb "$RAM_SIZE_MB" \
    --ports "${PORTS[*]}" \
    --extra_run_option "$EXTRA_RUN_OPTION" \
    --image "$IMAGE_NAME" \
    --user_data_path "$MOUNT_DIR" \
    --container_data_path "/var/lib/docker" \
    --enable_render_layer "$ENABLE_RENDER_LAYER"\
    --enable_f2fs "$ENABLE_F2FS"\
    --system_size_mb "$SYSTEM_PARTITION_SIZE_MB" \
    --enable_nfs "$enable_nfs" \
    --nfs_dir "$NFS_DIR"

    enable_hard_decoder $TAG_NUMBER

    if [ -n "$(docker ps -a --format {{.Names}} | grep "$CONTAINER_NAME$")" ]; then
        # 等待容器启动
        wait_container_ready ${CONTAINER_NAME}
        [ ${?} -eq 1 ] && return

        set -e
        enable_netint ${CONTAINER_NAME}

        # 更改容器内部accept_redirects参数配置，禁止ipv6的icmp重定向功能
        disable_ipv6_icmp ${CONTAINER_NAME}
        echo -e "---------------------- done ----------------------\n"
    fi
    mount_lxcfs ${CONTAINER_NAME}
    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        bash $CURRENT_DIR/base_box_aosp15.sh deploy_render_layer ${CONTAINER_NAME}
    fi
}

function main() {
    if [ ! -e "$CURRENT_DIR/base_box_aosp15.sh" ]; then
        echo "Can not find file base_box_aosp15.sh"
        exit 1
    fi

    if [ $1 = "start" ] || [ $1 = "nstart" ];then
        local MIN=$3 MAX=$4
        if [ -z $4 ]; then
            MAX=$3
        fi

        local TAG_NUMBER
        for TAG_NUMBER in $(seq $MIN $MAX); do
            if [ -n "$(docker ps -a --format {{.Names}} | grep "kbox_$TAG_NUMBER$")" ]; then
                echo "kbox_$TAG_NUMBER exist!"
            else
                start_box_by_id $1 $2 $TAG_NUMBER
            fi
        done
    elif [ $1 = "delete" ] || [ "$1" = "ndelete" ]; then
        local MIN=$2 MAX=$3
        if [ -z $3 ]; then
            MAX=$2
        fi

        local TAG_NUMBER
        for TAG_NUMBER in $(seq $MIN $MAX);do
            if [ -z "$(docker ps -a --format {{.Names}} | grep "kbox_$TAG_NUMBER$")" ]; then
                echo "no container kbox_$TAG_NUMBER!"
            else
                local CONTAINER_NAME="kbox_$TAG_NUMBER"
                local MOUNT_SOURCE=$(docker inspect --format='{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}' "$CONTAINER_NAME")
                local MOUNT_DIR
                if [ -n "$MOUNT_SOURCE" ]; then
                    MOUNT_DIR=$(echo "$MOUNT_SOURCE" | sed "s|/data/${CONTAINER_NAME}/data$||")
                    if [ "$MOUNT_DIR" == "$MOUNT_SOURCE" ]; then
                        MOUNT_DIR=$(dirname "$MOUNT_SOURCE")
                    fi
                else
                    MOUNT_DIR=${KBOX_MOUNT_MAP[TAG_NUMBER - 1]}
                fi
                if [ $1 = "ndelete" ]; then
                    MOUNT_DIR=$NFS_DIR
                fi
                echo "delete using mount path: $MOUNT_DIR"
                bash $CURRENT_DIR/base_box_aosp15.sh delete "$CONTAINER_NAME" "$MOUNT_DIR"
            fi
        done
    elif [ $1 = "restart" ]; then
        local MIN=$2 MAX=$3
        if [ -z $3 ]; then
            MAX=$2
        fi
        local TAG_NUMBER
        for TAG_NUMBER in $(seq $MIN $MAX);do
            if [ -z "$(docker ps -a --format {{.Names}} | grep "kbox_$TAG_NUMBER$")" ]; then
                echo "no container kbox_$TAG_NUMBER!"
            else
                set +e
                local CONTAINER_NAME="kbox_$TAG_NUMBER"
                local MOUNT_SOURCE=$(docker inspect --format='{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}' "$CONTAINER_NAME")
                local MOUNT_DIR
                if [ -n "$MOUNT_SOURCE" ]; then
                    MOUNT_DIR=$(echo "$MOUNT_SOURCE" | sed "s|/data/${CONTAINER_NAME}/data$||")
                    if [ "$MOUNT_DIR" == "$MOUNT_SOURCE" ]; then
                        MOUNT_DIR=$(dirname "$MOUNT_SOURCE")
                    fi
                else
                    MOUNT_DIR=${KBOX_MOUNT_MAP[TAG_NUMBER - 1]}
                fi
                echo "restart using mount path: $MOUNT_DIR"
                bash $CURRENT_DIR/base_box_aosp15.sh restart "$CONTAINER_NAME" "$MOUNT_DIR" 3 ${ENABLE_HARD_DECODE} $ENABLE_RENDER_LAYER $ENABLE_F2FS $SYSTEM_PARTITION_SIZE_MB
                [ ${?} -eq 1 ] && continue
                mount_lxcfs "$CONTAINER_NAME"
                enable_netint "$CONTAINER_NAME"
                set -e
            fi
        done
    fi
}

check_environment
check_paras $@
main "$@"
