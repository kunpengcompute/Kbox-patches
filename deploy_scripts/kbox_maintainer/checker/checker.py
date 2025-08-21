#!/usr/bin/env python3
# -*- encoding:utf-8 -*-
# Copyright Huawei Technologies Co., Ltd. 2021-2021. All rights reserved.

import logging
import subprocess
import stat
from pathlib import Path
import docker
from os import uname
import re
from cpuinfo import get_cpu_info

class Checker(object):

    def __init__(self):
        self.__client = docker.from_env()

    @staticmethod
    def _check_one_container(container):
        container.reload()
        if container.status != 'running':
            print("container[short_id:{}, name:{}] is {}".format(
                container.short_id, container.name, container.status))
            return False

        exit_code, output = container.exec_run("getprop sys.boot_completed")
        if exit_code != 0:
            print("container[name:{}] getprop failed, exit_code={}".format(
                container.name, exit_code))
            return False

        if output != b'1\n':
            print("container[name:{}] system boot is incomplete!!!".format(
                container.name))
            return False

        process_name=["zygote", "zygote64", "surfaceflinger", "system_server"]
        exit_code, output = container.exec_run("ps -a")
        if exit_code != 0:
            print("container[name:{}] get process failed, exit_code={}".format(
                container.name, exit_code))
            return False

        for process in process_name:
            patt = ' ' + process + '\n'
            matchobj = re.search(patt, output.decode())
            if not matchobj:
                print("container[name:{}] process[{}] is null!!!".format(container.name, process))
                return False

        check_list=["sys.surfaceflinger.has_reboot", "sys.zygote.has_reboot", "sys.zygote64.has_reboot"]
        for proper in check_list:
            exit_code, output = container.exec_run("getprop " + proper)
            if exit_code != 0:
                print("container[name:{}] get sys.prop[{}] failed, exit_code={}".format(
                    container.name, proper, exit_code))
                return False
            if output == b'1\n':
                print("container[name:{}] {}!!!".format(container.name, proper))
                return False

        exit_code, output = container.exec_run("service list |grep -w SurfaceFlinger")
        if exit_code != 0:
            print("container[name:{}] get service SurfaceFlinger failed, exit_code={}".format(
                container.name, exit_code))
            return False
        if str(output).find("[android.ui.ISurfaceComposer]") == -1:
            print("container[name:{}] check service SurfaceFlinger failed!!!".format(
                container.name))
            return False

        return True

    def check_containers(self, containers):
        if containers:
            containers_list = [self.__client.containers.get(
                container) for container in containers]
        else:
            containers_list = self.__client.containers.list(all=True)

        unhealthy_containers = []
        for container in containers_list:
            healthy = Checker._check_one_container(container)
            if not healthy:
                unhealthy_containers.append(container)

        print("===container check report===\n")
        print("Total checked containers: {}\n".format(len(containers_list)))
        if unhealthy_containers:
            print("unhealth containers name:")
            print([container.name for container in unhealthy_containers])
        else:
            print("All the checked containers are healthy!")

        return unhealthy_containers

    @staticmethod
    def _recover_one_container(container):
        # exec android_kbox.sh scripts
        container_no = container.name.split('_')[1]
        cmd = Path.cwd() / "android_kbox.sh"
        base_cmd = Path.cwd() / "base_box.sh"
        if not cmd.is_file() or not base_cmd.is_file():
            logging.fatal("{} is not found".format(str(cmd)))
            return

        cmd.chmod(mode=cmd.stat().st_mode | stat.S_IXUSR)
        base_cmd.chmod(mode=base_cmd.stat().st_mode | stat.S_IXUSR)

        subprocess.run([str(cmd), "restart", container_no])

    def recover_containers(self, containers):
        unhealthy_containers = self.check_containers(containers)
        if not unhealthy_containers:
            return []

        for container in unhealthy_containers:
            Checker._recover_one_container(container)

        unrecover_containers = []
        for container in unhealthy_containers:
            if not Checker._check_one_container(container):
                unrecover_containers.append(container)

        print("===container recover report===\n")
        if unrecover_containers:
            print("unrecover containers name:")
            print([container.name for container in unrecover_containers])
        else:
            print("All the containers are recovered!")

        return unrecover_containers

    @staticmethod
    def check_exagear():
        exagear = Path("/proc/sys/fs/binfmt_misc/ubt_a32a64")
        return exagear.is_file() and exagear.read_text().startswith("enabled")

    @staticmethod
    def recover_exagear():
        # exec android_kbox.sh scripts
        cmd = Path.cwd() / "android_kbox.sh"
        base_cmd = Path.cwd() / "base_box.sh"
        if not cmd.is_file() or not base_cmd.is_file():
            logging.fatal("{} is not found".format(str(cmd)))
            return

        cmd.chmod(mode=cmd.stat().st_mode | stat.S_IXUSR)
        base_cmd.chmod(mode=base_cmd.stat().st_mode | stat.S_IXUSR)

        subprocess.run([str(cmd), "restart"])
        return Checker.check_exagear()
