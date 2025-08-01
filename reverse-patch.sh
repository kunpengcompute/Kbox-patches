# To reverse all android patches from aosp code.
# ./reverse-patch.sh [aosp path] aosp15r17-patch
#!/bin/bash

TAG="$2"
TARGET_DIR="$1"
SOURCE_DIR="$(pwd)/${TAG}"

if [ ! -d "$TARGET_DIR" ];then
    echo "Error: Target directory $TARGET_DIR does not exist"
    exit 1
fi

find "$SOURCE_DIR" -type f -name "*.patch" | while read -r patch_file; do
    subdir=$(dirname "$patch_file")

    rel_path="${subdir#$SOURCE_DIR/}"

    target_subdir="$TARGET_DIR/$rel_path"

    if [ ! -d "$target_subdir" ];then
        echo "Warning: Target Subdirectory $target_subdir does not exist, skipping"
        continue
    fi

    echo "Reversing directory $target_subdir"

    (cd "$target_subdir" && git reset --hard >/dev/null 2>&1 && git clean -fdx >/dev/null 2>&1)
done
