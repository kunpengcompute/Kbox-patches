#!/bin/bash
# Copyright 2026 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ******************************************************************************** #
# File Name: kbox11_iso_build.sh
# Description: ubuntu iso镜像生成总调用脚本.
# Usage: bash kbox11_iso_build.sh
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

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${CURRENT_DIR}" || exit
package_dir=$(cd "${CURRENT_DIR}"/../../../ && pwd)
iso_file="ubuntu-20.04.1-live-server-arm64.iso"
export iso_file

main(){
    bash kbox9_kernel.sh
    if [ -f "${package_dir}/${iso_file}" ]
    then
        bash make_iso.sh
    fi
}

main "$@"
exit 0
