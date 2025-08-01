# To apply all android patches to aosp code.
# ./apply-patch.sh [aosp path] aosp15r17-patch
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
