#!/bin/bash

# ============================================================
# Cuttlefish 环境初始化脚本（适用于 openEuler / RHEL 系）
# 用法：sudo bash setup_cuttlefish_env.sh
# ============================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGING=$BASE_DIR/cuttlefish-files

# ---------- 0. 准备cuttlefish-common权限 ----------
chmod -R +x $BASE_DIR/cuttlefish-common
cp -r $BASE_DIR/cuttlefish-common /usr/lib/ 

# ---------- 1. 创建所需系统组 ----------
echo "[Step 1/7] 创建系统组（如需）..."
for g in cuttlefish cvdnetwork kvm; do
    if getent group "$g" >/dev/null 2>&1; then
        echo "  组 $g 已存在"
    else
        groupadd -f -r "$g"
        echo "  创建组 $g"
    fi
done

# ---------- 2. 将当前用户加入组 ----------
echo "[Step 2/7] 将用户加入组..."
TARGET_USER="${SUDO_USER:-$USER}"
usermod -aG cuttlefish,cvdnetwork,kvm "$TARGET_USER"
echo "  用户 $TARGET_USER 已加入 cuttlefish, cvdnetwork, kvm"

# ---------- 3. 配置内核模块 ----------
echo "[Step 3/7] 配置内核模块（vhost_vsock）..."
STAGING="${STAGING:-/opt/cuttlefish}"   # 可根据实际情况修改 STAGING 路径
if [ -d "$STAGING/modules" ]; then
    cp "$STAGING/modules/"* /etc/modules-load.d/ 2>/dev/null || true
    echo "  已复制模块配置文件"
fi

# 确认 cuttlefish.conf 存在
if [ -f /etc/modules-load.d/cuttlefish.conf ]; then
    cat /etc/modules-load.d/cuttlefish.conf
else
    echo "  警告：/etc/modules-load.d/cuttlefish.conf 不存在，手动创建"
    echo "vhost_vsock" > /etc/modules-load.d/cuttlefish.conf
fi

# 加载模块（忽略已加载的错误）
modprobe vhost_vsock 2>/dev/null || true
if lsmod | grep -q vhost_vsock; then
    echo "  vhost_vsock 模块已加载"
else
    echo "  错误：vhost_vsock 模块加载失败，请检查内核支持"
    exit 1
fi

# ---------- 4. 配置 udev 规则 ----------
echo "[Step 4/7] 配置 udev 规则..."
if [ -d "$STAGING/udev" ]; then
    cp "$STAGING/udev/"* /etc/udev/rules.d/ 2>/dev/null || true
    echo "  已复制 udev 规则"
else
    echo "  警告：$STAGING/udev 目录不存在，跳过 udev 规则复制"
fi
udevadm control --reload 2>/dev/null || true
echo "  udev 规则已重载"

# ---------- 5. 配置 sudoers ----------
echo "[Step 5/7] 配置 sudoers 权限..."
SUDOERS_FILE="/etc/sudoers.d/cuttlefish"
if [ ! -f "$SUDOERS_FILE" ]; then
    cat > "$SUDOERS_FILE" << 'EOF'
%cuttlefish ALL=(root) NOPASSWD: /opt/cuttlefish/bin/launch_cvd, /opt/cuttlefish/bin/cvd, /usr/sbin/modprobe
EOF
    chmod 0440 "$SUDOERS_FILE"
    echo "  已创建 $SUDOERS_FILE"
else
    echo "  $SUDOERS_FILE 已存在，跳过"
fi

# 验证 sudoers 语法
if visudo -c -f "$SUDOERS_FILE" 2>/dev/null; then
    echo "  sudoers 语法正确"
else
    echo "  错误：sudoers 语法有误，请检查 $SUDOERS_FILE"
    exit 1
fi

# ---------- 6. 创建 tmpfiles 配置 ----------
echo "[Step 6/7] 创建 tmpfiles 配置..."
TMPFILES_CONF="/etc/tmpfiles.d/cuttlefish.conf"
if [ ! -f "$TMPFILES_CONF" ]; then
    echo 'd /run/cuttlefish 0755 root root -' > "$TMPFILES_CONF"
    echo "  已创建 $TMPFILES_CONF"
else
    echo "  $TMPFILES_CONF 已存在，跳过"
fi

systemd-tmpfiles --create --prefix=/run/cuttlefish 2>/dev/null || true
if [ -d /run/cuttlefish ]; then
    echo "  /run/cuttlefish 目录已创建"
else
    echo "  警告：/run/cuttlefish 创建失败"
fi

# ---------- 7. 安装所需软件包 ----------
echo "[Step 7/7] 安装软件包..."
# 注意：openEuler 使用 dnf/yum，此处用 yum（兼容）
PACKAGES="swtpm qemu-img jq elfutils-libs libcap slirp4netns"
if command -v yum &>/dev/null; then
    yum install -y $PACKAGES
elif command -v dnf &>/dev/null; then
    dnf install -y $PACKAGES
else
    echo "  错误：未找到 yum 或 dnf，请手动安装：$PACKAGES"
    exit 1
fi
echo "  软件包安装完成"

# ---------- 完成 ----------
echo ""
echo "============================================"
echo "Cuttlefish 环境初始化完成！"
echo "请重新登录或执行 'newgrp cuttlefish' 使组权限生效。"
echo "然后可使用 launch_cvd 启动实例。"
echo "============================================"
