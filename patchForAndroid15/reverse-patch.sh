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

# To reverse all modifications from aosp code.
# ./reverse-patch.sh [aosp path] patch: remove modification of repositories in AOSP based on existed patches
# ./reverse-patch.sh [aosp path] all: remove all modification of repositories in AOSP

#!/bin/bash

reverse_by_patch() {
    SOURCE_DIR="$(pwd)"
    find "$SOURCE_DIR" -type f -name "*.patch" | while read -r patch_file; do
        subdir=$(dirname "$patch_file")

        rel_path="${subdir#$SOURCE_DIR/}"

        target_subdir="$AOSP_DIR/$rel_path"

        if [ ! -d "$target_subdir" ];then
            echo "Warning: Target Subdirectory $target_subdir does not exist, skipping"
            continue
        fi

        echo "Reversing directory $target_subdir"

        (cd "$target_subdir" && git reset --hard >/dev/null 2>&1 && git clean -fdx >/dev/null 2>&1)
    done
}

reverse_all_repository() {
    REPO_DIR="$AOSP_DIR/.repo/projects"
    find "$REPO_DIR" -maxdepth 10 -type d -name "*.git" | while read -r repo; do
        if [[ "$repo" == *.git ]]; then
            repo="${repo%.git}"

            relative_path=$(realpath --relative-to="$REPO_DIR" "$repo")

            target_subdir="$AOSP_DIR/$relative_path"

            echo "Reversing directory $target_subdir"

            (cd "$target_subdir" && git reset --hard >/dev/null 2>&1 && git clean -fdx >/dev/null 2>&1)
        fi
    done 
}

main() {
    AOSP_DIR="$1"

    if [ ! -d "$AOSP_DIR" ]; then
        echo "Error: Target directory $AOSP_DIR does not exist"
        exit 1
    fi

    if [ $2 = "patch" ]; then
        reverse_by_patch
    elif [ $2 = "all" ]; then
        reverse_all_repository
    fi
}

main $1 $2
