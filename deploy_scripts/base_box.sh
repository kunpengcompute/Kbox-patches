#!/bin/bash
# Copyright Huawei Technologies Co., Ltd. 2021-2021. All rights reserved.

THISDIR=$(readlink -ef $(dirname $0))
CONTAINERD_CONFIG=$THISDIR/containerd_config
if [ -f "$CONTAINERD_CONFIG" ]; then
    DEFAULT_RUNTIME=containerd
    RUNTIME_CMD=nerdctl
else
    DEFAULT_RUNTIME=docker
    RUNTIME_CMD=docker
fi
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
    cd ${CURRENT_DIR}

    # 如果使能纯64位，不需要转码
    if [ "$ENABLE_ONLY64_KBOX" == "1" ]; then
        return
    fi

    # 如果是需要转码的机型，在使用脚本过程中检查转码
    local VENDOR_ID=$(lscpu | grep "Vendor ID:" | grep -v "BIOS" | awk '{print $3}')
    if [ x"$VENDOR_ID" == x"0x48" ] || [ x"$VENDOR_ID" == x"HiSilicon" ]; then
	    check_exagear
    fi
}

function check_exagear() {
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

function get_lxcfs_path() {
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

#CPU文件模拟
function mock_cpu() {
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

    RUN_OPTION+="--volume=/var/lib/kbox/cpus/${BOX_NAME}/cpu:/sys/devices/system/cpu:ro"
}

# 供电模拟：USB供电，未充电状态
function mock_power_supply() {
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

function check_paras() {
    echo "------------------ Kbox Startup ------------------"

    local BOX_NAME CPUS NUMAS GPUS_RENDER STORAGE_SIZE_GB RAM_SIZE_MB PORTS
    local EXTRA_RUN_OPTION IMAGE_NAME USER_DATA_PATH CONTAINER_DATA_PATH
    local ENABLE_RENDER_LAYER ENABLE_F2FS
    local ENABLE_RENDER_LAYER SYSTEM_SIZE_MB
    local PARA_ERROR=""
    while :; do
        case $1 in
            start)              shift;;
            --name)             BOX_NAME=$2;         echo "--name)               BOX_NAME           : $2 "; shift;;
            --cpus)             CPUS=($2);           echo "--cpus)               CPUS               : $2 "; shift;;
            --numas)            NUMAS=($2);          echo "--numas)              NUMAS              : $2 "; shift;;
            --gpus)             GPUS_RENDER=($2);    echo "--gpus)               GPUS_RENDER        : $2 "; shift;;
            --storage_size_gb)  STORAGE_SIZE_GB=$2;  echo "--storage_size_gb)    STORAGE_SIZE_GB    : $2 "; shift;;
            --ram_size_mb)      RAM_SIZE_MB=$2;      echo "--ram_size_mb)        RAM_SIZE_MB        : $2 "; shift;;
            --ports)            PORTS=($2);          echo "--ports)              PORTS              : $2 "; shift;;
            --extra_run_option) EXTRA_RUN_OPTION=$2; echo "--extra_run_option)   EXTRA_RUN_OPTION   : $2 "; shift;;
            --image)            IMAGE_NAME=$2;       echo "--image)              IMAGE_NAME         : $2 "; shift;;
            --user_data_path)   USER_DATA_PATH=$2;   echo "--user_data_path)     USER_DATA_PATH     : $2 "; shift;;
            --container_data_path) CONTAINER_DATA_PATH=$2; echo "--container_data_path)   CONTAINER_DATA_PATH   : $2 "; shift;;
            --enable_render_layer) ENABLE_RENDER_LAYER=$2; echo "--enable_render_layer)   ENABLE_RENDER_LAYER   : $2 "; shift;;
            --enable_f2fs)         ENABLE_F2FS=$2;         echo "--enable_f2fs)           ENABLE_F2FS           : $2 "; shift;;
            --system_size_mb)   SYSTEM_SIZE_MB=$2;       echo "--system_size_mb)      SYSTEM_SIZE_MB     : $2 "; shift;;
            --)                 shift;               break;;
            -?*)                printf 'WARN: Unknown option: %s\n' "$1" >&2; exit 1;;
            *)   break
        esac

        shift
    done

    if [ -z $BOX_NAME ]; then
        echo "\"--name\" option error, fail: need a kbox name!"
        PARA_ERROR="true"
    fi

    if [ ${#CPUS[@]} -eq 0 ]; then
        echo "\"--cpus\" option error, fail: para empty!"
        PARA_ERROR="true"
    fi
    local CPU
    for CPU in ${CPUS[@]}; do
        if [ -n "`echo "$CPU" | sed 's/[0-9]//g'`" ]; then
            echo "\"--cpus\" option error,  fail: cpu parameter must be number!"
            PARA_ERROR="true"
        fi
        if [ $CPU -ge  $(lscpu | grep -w "CPU(s)" | head -n 1 | awk '{print $2}') ] || \
           [ $CPU -lt 0 ]; then
            echo "\"--cpus\" option error, fail: cpu$CPUS not exist!"
        fi
    done

    if [ ${#NUMAS[@]} -eq 0 ]; then
        echo "\"--numas\" option error, fail: para empty!"
        PARA_ERROR="true"
    fi
    local NUMA
    for NUMA in ${NUMAS[@]}; do
        if [ -n "`echo "$NUMA" | sed 's/[0-9]//g'`" ]; then
            echo "\"--numas\" option error, fail: numa parameter must be number!"
            PARA_ERROR="true"
        fi

        if [ $NUMA -ge  $(lscpu | grep "NUMA node(s)" | awk '{print $3}') ] || \
           [ $NUMA -lt 0 ]; then
            echo " \"--numas\" fail: numa$NUMA not exist!"
            PARA_ERROR="true"
        fi
    done

    local GPU
    for GPU in ${GPUS_RENDER[@]}; do
        if [ ! -e $GPU ]; then
            echo "\"--gpus\"  error, fail: GPU device $GPU not exist!"
            PARA_ERROR="true"
        fi
    done

    if [ -z "`echo "$STORAGE_SIZE_GB" | sed 's/[0-9]//g'`" ]; then
        if [ -z $STORAGE_SIZE_GB ]; then
            echo "\"--storage_size_gb\" option error, fail: para empty!"
            PARA_ERROR="true"
        elif [ $STORAGE_SIZE_GB -le 0 ]; then
            echo "\"--storage_size_gb\" option error, fail: storage size must greater than 0 GB!"
            PARA_ERROR="true"
        fi
    else
        echo "\"--storage_size_gb\" option error, fail: storage size must be number!"
        PARA_ERROR="true"
    fi

    if [ -z "`echo "$RAM_SIZE_MB" | sed 's/[0-9]//g'`" ]; then
        if [ -z $RAM_SIZE_MB ]; then
            echo "\"--ram_size_mb\" option error, fail: para empty!"
            PARA_ERROR="true"
        elif [ $RAM_SIZE_MB -le 0 ];then
            echo "\"--ram_size_mb\" option error, fail: ram size must greater than 0 MB!"
            PARA_ERROR="true"
        fi
    else
        echo "\"--ram_size_mb\" option error, fail: ram size must be number!"
        PARA_ERROR="true"
    fi

    # 校验系统分区大小参数 (新增逻辑)
    if [ -n "$SYSTEM_SIZE_MB" ]; then
        # 校验是否为纯数字
        if [ -n "`echo "$SYSTEM_SIZE_MB" | sed 's/[0-9]//g'`" ]; then
            echo "\"--system_size_mb\" option error, fail: system partition size must be number!"
            PARA_ERROR="true"
        # 允许传入 0
        elif [ "$SYSTEM_SIZE_MB" -lt 0 ];then
            echo "\"--system_size_mb\" option error, fail: system partition size must greater than or equal to 0 MB!"
            PARA_ERROR="true"
        fi
    fi

    if [ ${#PORTS[@]} -eq 0 ]; then
        echo "\"--ports\" option error, fail: para empty!"
        PARA_ERROR="true"
    fi
    local PORT
    for PORT in ${PORTS[@]}; do
        if [[ "${PORT}" =~ ":" ]]; then
            local AGENT_PORT=$(echo ${PORT} | cut -d ':' -f1)
            local HOST_PORT=$(echo ${PORT} | cut -d ':' -f2)
            if [ -n "`echo "$AGENT_PORT" | sed 's/[0-9]//g'`" ]; then
                echo "\"--ports\" option error, fail: agent port must be number!"
                PARA_ERROR="true"
            fi

            if [ -n "`echo "$HOST_PORT" | sed 's/[0-9]//g'`" ]; then
                echo "\"--ports\" option error, fail: host port must be number!"
                PARA_ERROR="true"
            fi
        else
            echo "\"--ports\" option error, fail: error port format!"
            PARA_ERROR="true"
        fi
    done

    if [[ "${IMAGE_NAME}" =~ ":" ]]; then
        local IMAGE_RE=$(echo ${IMAGE_NAME} | cut -d ':' -f1)
        tag=$(echo ${IMAGE_NAME} | cut -d ':' -f2)
        $RUNTIME_CMD images | awk '{print $1" "$2}' | grep -w "${IMAGE_RE}" | grep -w "${tag}" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "\"--image\" option error, no image ${IMAGE_NAME}!"
            PARA_ERROR="true"
        fi
    else
        $RUNTIME_CMD images | awk '{print $3}' | grep -w "${IMAGE_NAME}" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "\"--image\" option error, fail: no image ${IMAGE_NAME}!"
            PARA_ERROR="true"
        fi
    fi

    echo "---------------------------------------------------"
    if [ "$PARA_ERROR" = "true" ]; then
        echo "error: Kbox Start Fail!"
        exit 1
    fi
}

function check_key_process() {
    # 检查关键进程是否存在
    local process_name=(system_server zygote zygote64 surfaceflinger)
    if [ "$ENABLE_ONLY64_KBOX" == "1" ]; then
        # 软渲染为纯64位，不用检查zygote
        unset process_name[1]
    fi
    local cmd="$RUNTIME_CMD exec -i $1 ps -A | egrep -w 'system_server|zygote|zygote64|surfaceflinger' &"
    local result=$(wait_cmd "${cmd}")
    check_wait_cmd_result "${cmd}" "${result}"
    local val
    for process in ${process_name[@]}; do
        val=$(echo $result |grep -w ${process}'\>')
        [ ! -n "$val" ] && echo "$process is null" && return 1
    done

    # 检查关键进程是否重启
    local check_list=(sys.surfaceflinger.has_reboot sys.zygote.has_reboot sys.zygote64.has_reboot)
    cmd="$RUNTIME_CMD exec -i $1 getprop |grep '.has_reboot' &"
    result=$(wait_cmd "${cmd}")
    check_wait_cmd_result "${cmd}" "${result}"
    for property in ${check_list[@]}; do
        val=$(echo $result |grep -w ${property}'\>')
        [[ "$val" =~ "[1]" ]] && echo "$property has restarted" && return 1
    done

    # 检查服务列表
    cmd="$RUNTIME_CMD exec -i $1 service list |grep -w SurfaceFlinger &"
    result=$(wait_cmd "${cmd}")
    check_wait_cmd_result "${cmd}" "${result}"
    if [[ "$result" =~ "[android.ui.ISurfaceComposer]" ]]; then
        return 0
    else
        echo "service SurfaceFlinger is not normal"
        return 1
    fi
}

function create_app_shader_filesystem()
{
    local box_name=$1
    local -n RUN_OPTION_REF=$2
    if [ ! -e "kbox_render_accelerating_configuration.xml" ]; then
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
    input_file = "kbox_render_accelerating_configuration.xml" 
    result = read_xml(input_file)

    for item in app_config:
        print("%s"%item, "%d"%app_config[item]["mode"], "%d"%app_config[item]["size"])
EOF
)
    if [ $? -ne 0 ]; then
        echo -e "\033[31mFailed to enabled render layer! Failed to read kbox_render_accelerating_configuration.xml \033[0m"
        return -1
    fi

    apps=($(printf "%s" "$result" | awk '{print $1}'))
    modes=($(printf "%s" "$result" | awk '{print $2}'))
    sizes=($(printf "%s" "$result" | awk '{print $3}'))
    app_num=${#apps[@]}
    mode_config=("CLOSED", "READONLY", "READWRITE", "DEFAULT")
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

function start_box() {
    ########################## 1. 参数检查 ##########################
    check_paras "$@"
    ########################## 2. 参数解析 ##########################
    while :; do
        case $1 in
            start)                      shift;;
            --name)                     local BOX_NAME=$2;          shift;;
            --cpus)                     local CPUS=($2);            shift;;
            --numas)                    local NUMAS=($2);           shift;;
            --gpus)                     local GPUS_RENDER=($2);     shift;;
            --storage_size_gb)          local STORAGE_SIZE_GB=$2;   shift;;
            --ram_size_mb)              local RAM_SIZE_MB=$2;       shift;;
            --ports)                    local PORTS=($2);           shift;;
            --extra_run_option)         local EXTRA_RUN_OPTION=$2;  shift;;
            --image)                    local IMAGE_NAME=$2;        shift;;
            --user_data_path)           local USER_DATA_PATH=$2;    shift;;
            --container_data_path)      local CONTAINER_DATA_PATH=$2;  shift;;
            --enable_render_layer)      local ENABLE_RENDER_LAYER=$2;  shift;;
            --enable_f2fs)              local ENABLE_F2FS=$2;          shift;;
            --system_size_mb)           local SYSTEM_SIZE_MB=$2;    shift;;
            --)                     shift;                      break;;
            -?*) printf 'WARN: Unknown option: %s\n' "$1" >&2;;
            *)   break
        esac
        shift
    done

    ########################## 3.环境初始化 ##########################
    if [ $DEFAULT_RUNTIME == "docker" ]; then
        CONTAINER_DATA_PATH="/var/lib/docker"
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

    if [ ! -d "${USER_DATA_PATH}/img" ]; then
        mkdir -p ${USER_DATA_PATH}/img
    fi
    # f2fs 宿主机物理分区格式校验
    if [ "$ENABLE_F2FS" == "1" ]; then  
        check_f2fs_partition "${USER_DATA_PATH}/data"
        if [ $? -ne 0 ]; then
            return 1 # 校验失败，直接退出拉起流程
        fi
    fi
    local KBOX_IMG=${USER_DATA_PATH}/img/$BOX_NAME.img
    if [ ! -e $KBOX_IMG ]; then
        fallocate -l ${STORAGE_SIZE_GB}G $KBOX_IMG
        if [ "$ENABLE_F2FS" == "1" ]; then
            yes | mkfs.f2fs $KBOX_IMG
        else
            yes | mkfs -t ext4 $KBOX_IMG
        fi
    fi
    KBOX_DATA_PATH="${USER_DATA_PATH}/data/$BOX_NAME"
    mkdir -p $KBOX_DATA_PATH
    if [ "$ENABLE_F2FS" == "1" ]; then
        mount -t f2fs -o loop $KBOX_IMG $KBOX_DATA_PATH
    else
        mount $KBOX_IMG $KBOX_DATA_PATH
    fi
    echo $(($STORAGE_SIZE_GB * 2 * 1024 * 1024)) >$KBOX_DATA_PATH/storage_size

    ########################## 4.容器启动 ##########################
    local RUN_OPTION=""
    if [ $DEFAULT_RUNTIME == "docker" ]; then
        RUN_OPTION+=" -i "
    fi
    RUN_OPTION+=" -td "
    RUN_OPTION+=" --hostname=${BOX_NAME} "
    RUN_OPTION+=" --cap-drop=ALL "
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
    RUN_OPTION+=" --security-opt="apparmor=unconfined" "
    RUN_OPTION+=" --security-opt="seccomp=unconfined" "
    RUN_OPTION+="--name ${BOX_NAME}"
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
    RUN_OPTION+=" --device=/dev/ashmem:/dev/ashmem:rwm "
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
    if [ ${#GPUS_RENDER[@]} -eq 0 ]; then
        true
    elif [ -n "$(lspci -n | grep ${VA_SGPU100_ID} | awk '{print $3}')" ]; then
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
    else
        for (( i=0; i<${#GPUS_RENDER[@]};i++ )); do
            RUN_OPTION+=" --device=${GPUS_RENDER[$i]}:/dev/dri/renderD$((128 + $i)):rwm "
        done
    fi
    if [ -e "/dev/tango32" ]; then
        RUN_OPTION+=" --device=/dev/tango32:/dev/tango32:rwm "
    fi
     
    RUN_OPTION+=" --volume=$KBOX_DATA_PATH/cache:/cache:rw "
    RUN_OPTION+=" --volume=$KBOX_DATA_PATH/data:/data:rw "
    RUN_OPTION+=" --volume=$INPUT_EVENT_PATH/event0:/dev/input/event0:rw "
    RUN_OPTION+=" --volume=$INPUT_EVENT_PATH/event1:/dev/input/event1:rw "
    RUN_OPTION+=" --volume=$(get_lxcfs_path)/proc/diskstats:/proc/diskstats:ro "
    RUN_OPTION+=" --volume=$(get_lxcfs_path)/proc/meminfo:/proc/meminfo:ro "
    RUN_OPTION+=" --volume=$(get_lxcfs_path)/proc/stat:/proc/stat:ro "
    RUN_OPTION+=" --volume=$(get_lxcfs_path)/proc/swaps:/proc/swaps:ro "
    RUN_OPTION+=" --volume=$(get_lxcfs_path)/proc/uptime:/proc/uptime:ro "
    RUN_OPTION+=" --volume=$KBOX_DATA_PATH/storage_size:/storage_size:rw "
    if [ -f $THISDIR/default.prop_$BOX_NAME ]; then
        RUN_OPTION+=" --volume=$THISDIR/default.prop_$BOX_NAME:/kbox_prop/default.prop:rw "
    fi
    if [ -f $THISDIR/build.prop ]; then
        RUN_OPTION+=" --volume=$THISDIR/build.prop:/kbox_prop/build.prop:rw "
    fi
    if [ -e "$CURRENT_DIR/local.prop" ]; then
        chmod 400 $CURRENT_DIR/local.prop
        RUN_OPTION+=" --volume=$CURRENT_DIR/local.prop:/data/local.prop:rw "
    fi
    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        create_app_shader_filesystem ${BOX_NAME} RUN_OPTION
    fi

    # --- 新增的 /system 分区大小配置及 xfs 校验逻辑 开始 ---
    # 如果参数为空，赋予默认值 0
    if [ -z "$SYSTEM_SIZE_MB" ]; then
        SYSTEM_SIZE_MB=0
    fi

    # 只有当配置值不为 0 时，才去校验 xfs 格式
    if [ "$SYSTEM_SIZE_MB" -ne 0 ]; then
       check_system_size_modify "$CONTAINER_DATA_PATH"
    fi
    # 如果 SYSTEM_SIZE_MB 为 0，则上面整个 if 都不进，直接跳过，什么参数都不加
    # --- 新增的 /system 分区大小配置及 xfs 校验逻辑 结束 ---

    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        create_app_shader_filesystem ${BOX_NAME} RUN_OPTION
    fi
    mock_cpu
    mock_power_supply
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

    # 安卓11里面使能c2解码器需要把/dev/dma_heap/system设备节点映射到容器中
    if lspci | grep -q "Radeon PRO W6800"; then
        ENABLE_AMD_C2_DECODE=$(echo "${EXTRA_RUN_OPTION}" | grep -oP '(?<=ENABLE_AMD_C2_DECODE=)[01]')
        if [ $ENABLE_AMD_C2_DECODE -eq 1 ];then
            RUN_OPTION+=" --device=/dev/dma_heap/system:/dev/dma_heap/system:rwm"
        fi
    fi
    $RUNTIME_CMD run $RUN_OPTION $IMAGE_NAME init
    local cid=$($RUNTIME_CMD ps | grep -w " ${BOX_NAME}" | awk '{print $1}')

    local BINDER_MAJOR_ID=$(cat /proc/devices | grep binder | awk '{print $1}')
    if [ $DEFAULT_RUNTIME == "docker" ]; then
        # 赋予容器binder设备节点cgroup devices权限
        echo "c $BINDER_MAJOR_ID:* rwm" >$(ls -d /sys/fs/cgroup/devices/docker/$cid*/devices.allow)
        echo 1 > /sys/fs/cgroup/cpuset/docker/$cid*/cgroup.clone_children
    else
        # 赋予容器binder设备节点cgroup devices权限
        echo "c $BINDER_MAJOR_ID:* rwm" >$(ls -d /sys/fs/cgroup/devices/default/$cid*/devices.allow)
        echo 1 > /sys/fs/cgroup/cpuset/default/$cid*/cgroup.clone_children
    fi

    if [ $DEFAULT_RUNTIME == "containerd" ]; then
        $RUNTIME_CMD exec -i ${BOX_NAME} ln -s /dev/net/tun /dev/tun
    fi

    container_id=$($RUNTIME_CMD ps --filter "name=$BOX_NAME" --format "{{.ID}}")
    echo $container_id > $THISDIR/containerid_${BOX_NAME}
    $RUNTIME_CMD cp $THISDIR/containerid_${BOX_NAME} ${BOX_NAME}:/data/containerid
    rm -f $THISDIR/containerid_${BOX_NAME}

    if [[ $ENABLE_RENDER_LAYER == "1" ]]; then
        # 渲染中间层
        $RUNTIME_CMD exec -it ${BOX_NAME} sh -c "if [ -d /vendor/shader_cache/ ]; then chmod 777 -R /vendor/shader_cache/; fi"
        $RUNTIME_CMD exec -it ${BOX_NAME} sh -c "mkdir -p /data/local/debug/gles"
        $RUNTIME_CMD exec -it ${BOX_NAME} sh -c "chmod 755 -R /data/local/debug/"
        $RUNTIME_CMD exec -it ${BOX_NAME} sh -c "mkdir -p /data/local/tmp"
        if [ -e "kbox_render_accelerating_configuration.xml" ]; then
            $RUNTIME_CMD cp kbox_render_accelerating_configuration.xml ${BOX_NAME}:/data/local/tmp
        fi
        $RUNTIME_CMD exec -it ${BOX_NAME} sh -c "cp /system/vendor/lib64/hw/RenderAccLayer.kbox.so /data/local/debug/gles"
        if [ $? -ne 0 ]; then
            echo -e "\033[31mFailed to enabled render layer! RenderAccLayer.kbox.so may not exist\033[0m"
        fi
    fi
}

function delete_box() {
    local BOX_NAME=$1
    local USER_DATA_PATH=$2
    local keep_data=0
    if [ $3 ] && [ $3 -eq 1 ]; then
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
    if [ -z ${USER_DATA_PATH} ]; then
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

function wait_async_cmd() {
    eval $1
    local pid=$(jobs -rp)
    local count_time=0
    while true; do
        local count=$(jobs -rp | wc -l)
        if [ ${count} -eq 0 ]; then
            wait ${pid}
            # $?表示wait的返回状态，用于获取eval $1执行的命令是否执行成功，执行成功返回0
            if [ $? -ne 0 ]; then
                echo -2 # 命令执行失败
            fi
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

function wait_cmd() {
    local count_time=0
    while true; do
        local result=$(wait_async_cmd "$1")
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

check_wait_cmd_result() {
    local cmd=$1
    local result=$2
    if [ "$result" == "-1" ]; then
        echo "cmd \"${cmd}\" wait_cmd timeout"
    fi
}

function check_f2fs_partition() {
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
        echo -e "\033[1;31m[ERROR] 校验失败: 容器配置为使能 f2fs (ENABLE_F2FS=1)\033[0m"
        echo -e "\033[1;31m[ERROR] 但目标挂载目录 ${target_path} 所在的分区格式为 ${host_fs_type}，并非 f2fs。\033[0m"
        echo -e "\033[1;31m[ERROR] 请检查底层硬盘分区格式是否已正确格式化并挂载！\033[0m"
        has_error=1
    fi

    # 3. 最终判断逻辑：只要有一个校验未通过，就中止并返回 1
    if [ "$has_error" -ne 0 ]; then
        echo -e "\033[1;31m[ERROR] f2fs 运行环境检查未通过，操作已中止。\033[0m"
        return 1
    fi

    return 0
}

# 校验指定路径所在磁盘是否为 xfs 格式，并根据结果设置 RUN_OPTION
check_system_size_modify() {
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



function restart_box() {
    local BOX_NAME=$1
    local USER_DATA_PATH=$2

    local restart_times=3 # 默认最大重启次数为三次
    if [ $# -ge 3 ]; then
        restart_times=$3
    fi

    local ENABLE_HARD_DECODE=0
    if [ $# -ge 4 ]; then
        ENABLE_HARD_DECODE=$4
    fi

    local ENABLE_RENDER_LAYER=0
    if [ $# -ge 5 ]; then
        ENABLE_RENDER_LAYER=$5
    fi

    local ENABLE_F2FS=0
    if [ $# -ge 6 ]; then
        ENABLE_F2FS=$6
    fi

    local SYSTEM_SIZE_MB=0
    if [ $# -ge 7 ]; then
        SYSTEM_SIZE_MB=$7
    fi

    set +e
    if [ -z ${USER_DATA_PATH} ]; then
        USER_DATA_PATH="/root/mount"
    fi

    echo "mount ${BOX_NAME}.img"
    if [ "$ENABLE_F2FS" == "1" ]; then
        check_f2fs_partition "${USER_DATA_PATH}/data"
        if [ $? -ne 0 ]; then
            return 1 # 校验失败，中止重启流程
        fi
        mount -t f2fs -o loop ${USER_DATA_PATH}/img/${BOX_NAME}.img ${USER_DATA_PATH}/data/${BOX_NAME} >/dev/null
    else
        mount ${USER_DATA_PATH}/img/${BOX_NAME}.img ${USER_DATA_PATH}/data/${BOX_NAME} >/dev/null
    fi

    if [ "$SYSTEM_SIZE_MB" -ne 0 ]; then
        check_system_size_modify "/var/lib/docker"
    fi

    mock_cpu

    $RUNTIME_CMD inspect ${BOX_NAME} >/dev/null
    if [ $? -ne 0 ]; then
        # 无容器判断
        break
    fi

    for i in $(seq 1 $restart_times)
    do
        local should_restart=0 # 0为不应该再重启，1为需要再次重启
        $RUNTIME_CMD stop -t 0 ${BOX_NAME}
        echo "${BOX_NAME} begins restarting the $i times!"
        $RUNTIME_CMD start ${BOX_NAME}
        local cid=$($RUNTIME_CMD ps | grep -w " ${BOX_NAME}" | awk '{print $1}')
        local BINDER_MAJOR_ID=$(cat /proc/devices | grep binder | awk '{print $1}')
        if [ $DEFAULT_RUNTIME == "docker" ]; then
            # 赋予容器binder设备节点cgroup devices权限
            echo "c $BINDER_MAJOR_ID:* rwm" >$(ls -d /sys/fs/cgroup/devices/docker/$cid*/devices.allow)
            echo "c 13:* rwm" >$(ls -d /sys/fs/cgroup/devices/docker/$cid*/devices.allow)
            echo 1 > /sys/fs/cgroup/cpuset/docker/$cid*/cgroup.clone_children
        else
            # 赋予容器binder设备节点cgroup devices权限
            echo "c $BINDER_MAJOR_ID:* rwm" >$(ls -d /sys/fs/cgroup/devices/default/$cid*/devices.allow)
            echo "c 13:* rwm" >$(ls -d /sys/fs/cgroup/devices/default/$cid*/devices.allow)
            echo 1 > /sys/fs/cgroup/cpuset/default/$cid*/cgroup.clone_children
        fi

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

        local execOneTime=true
        local VA_SGPU100_ID=":0200"
          
        local count_time=0
        while true; do
            local cmd="$RUNTIME_CMD exec -i ${BOX_NAME} getprop sys.boot_completed | grep 1 &"
            local result=$(wait_cmd "${cmd}")
            check_wait_cmd_result "${cmd}" "${result}"
            if [ "${result}" == "1" ]; then
                # 等待容器启动完成
                check_key_process ${BOX_NAME}
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
        local result=$(wait_async_cmd "${cmd}")
        if [ "${result}" == "-1" ];then
            echo "${BOX_NAME} wait_async_cmd logcat timeout"
        elif [ "${result}" == "-2" ];then
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

check_environment
CMD=$1; shift
case $CMD in
    start)       start_box   "$@";;
    delete)      delete_box  "$@";;
    restart)     restart_box "$@";;
    wait_async_cmd) wait_async_cmd "$@";;
    chk_key_process) check_key_process "$@";;
    *)          echo "command must be \"start\", \"delete\", \"restart\", \"wait_async_cmd\" or \"chk_key_process\"";;
esac
