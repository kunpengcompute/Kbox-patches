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

mapfile -t vm_name < <(cat numa_resource_dispatch.json | grep "vm name" | awk '{print $3}' | sed 's/,$//' | sed 's/"//g')


for i in "${!vm_name[@]}";do
	echo "virsh start ${vm_name[i]}"
	virsh start ${vm_name[i]}
done
