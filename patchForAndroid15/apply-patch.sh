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

# To apply all android patches to aosp code.
# ./apply-patch.sh [aosp path]
#!/bin/bash

AOSP_DIR="$1"
SOURCE_DIR="$(pwd)"

if [ ! -d "$AOSP_DIR" ];then
    echo "Error: Target directory $AOSP_DIR does not exist"
    exit 1
fi

find "$SOURCE_DIR" -type f -name "*.patch" | sort | while read -r patch_file; do
    subdir=$(dirname "$patch_file")

    rel_path="${subdir#$SOURCE_DIR/}"

    target_subdir="$AOSP_DIR/$rel_path"

    patch_name=$(basename "$patch_file")

    if [ ! -d "$target_subdir" ];then
        echo "Warning: Target Subdirectory $target_subdir does not exist, skipping"
        continue
    fi

    (cd "$target_subdir" && git apply --check "$patch_file" >/dev/null 2>&1)

    if [ $? -eq 0 ]; then
        (cd "$target_subdir" && git apply "$patch_file" >/dev/null 2>&1)

        if [ $? -eq 0 ]; then
            echo "Successfully applied $patch_name"
        else
            echo "Error applying $patch_name"
        fi
    else
        echo "Error $patch_name cannot be applied"
    fi
done
