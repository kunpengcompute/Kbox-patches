# Cuttlefish Host 基础环境部署指南

本文从 Cuttlefish 官方镜像中抽取 host 运行组件，打包为 `cuttlefish-base.zip`，并通过随附的 `setup_cuttlefish_env.sh` 完成目标主机的环境部署。

> 交付物：`cuttlefish-base.zip`、`setup_cuttlefish_env.sh`

---

## 1. 前置条件

- 目标主机为 aarch64 架构，KVM 已启用，具备 root 权限
- 抽取环境可运行 `docker`，且能访问 `us-docker.pkg.dev`
- 已获得随附的 `setup_cuttlefish_env.sh`

---

## 2. 抽取 host 组件

### 2.1 拉取官方镜像

```bash
IMG=us-docker.pkg.dev/android-cuttlefish-artifacts/cuttlefish-orchestration/cuttlefish-orchestration:1.55.0-arm64
docker pull "$IMG"
```

**预期结果**：镜像拉取完成，`docker images` 中可见该镜像。

### 2.2 取出 host 组件目录

```bash
docker create --name cf-extract "$IMG"
rm -rf ~/cf-work && mkdir -p ~/cf-work
docker cp cf-extract:/usr/lib/cuttlefish-common ~/cf-work/cuttlefish-common
```

**预期结果**：`~/cf-work/cuttlefish-common` 生成，包含 `bin/` 与 `etc/` 两个目录。

### 2.3 取出配置文件

```bash
# 整取 /etc，并补取可能位于 /usr/lib 下的 systemd/udev 文件
docker cp cf-extract:/etc ~/cf-work/img-etc
docker cp cf-extract:/usr/lib/systemd/system/cuttlefish-host-resources.service ~/cf-work/img-etc/ 2>/dev/null || true
docker cp cf-extract:/usr/lib/udev/rules.d/60-cuttlefish-base.rules            ~/cf-work/img-etc/ 2>/dev/null || true
docker rm cf-extract

# 按类别归置
F=~/cf-work/cuttlefish-files
mkdir -p "$F"/{default,limits,modules,networkmanager,systemd,udev}
cp ~/cf-work/img-etc/default/cuttlefish-host-resources            "$F/default/"
cp ~/cf-work/img-etc/security/limits.d/1_cuttlefish.conf          "$F/limits/"
cp ~/cf-work/img-etc/modules-load.d/cuttlefish-common.conf        "$F/modules/"
cp ~/cf-work/img-etc/NetworkManager/conf.d/99-cuttlefish.conf     "$F/networkmanager/"
{ cp ~/cf-work/img-etc/systemd/system/cuttlefish-host-resources.service "$F/systemd/" \
    || cp ~/cf-work/img-etc/cuttlefish-host-resources.service           "$F/systemd/"; }
{ cp ~/cf-work/img-etc/udev/rules.d/60-cuttlefish-base.rules           "$F/udev/" \
    || cp ~/cf-work/img-etc/60-cuttlefish-base.rules                    "$F/udev/"; }
```

**预期结果**：`cuttlefish-files` 下共 6 个文件：

```
cuttlefish-files/default/cuttlefish-host-resources
cuttlefish-files/limits/1_cuttlefish.conf
cuttlefish-files/modules/cuttlefish-common.conf
cuttlefish-files/networkmanager/99-cuttlefish.conf
cuttlefish-files/systemd/cuttlefish-host-resources.service
cuttlefish-files/udev/60-cuttlefish-base.rules
```

### 2.4 规范化目录

```bash
cd ~/cf-work
# 跟随符号链接，转为普通文件
cp -rL cuttlefish-common cuttlefish-common.real
rm -rf cuttlefish-common && mv cuttlefish-common.real cuttlefish-common
# 只保留 bin 与 etc
rm -rf cuttlefish-common/lib64 cuttlefish-common/usr
```

**预期结果**：

```bash
find cuttlefish-common -type l | wc -l     # 输出 0
find cuttlefish-common -type f | wc -l     # 输出 112
```

### 2.5 组装并打包

```bash
cd ~/cf-work
mkdir -p cuttlefish-base
mv cuttlefish-common cuttlefish-files cuttlefish-base/
cp /path/to/setup_cuttlefish_env.sh cuttlefish-base/
chmod +x cuttlefish-base/setup_cuttlefish_env.sh
zip -r cuttlefish-base.zip cuttlefish-base
```

**预期结果**：`cuttlefish-base.zip` 生成，大小约 190 MB；解压后顶层目录为 `cuttlefish-base/`，其下为：

```
cuttlefish-base/
├── cuttlefish-common/{bin,etc}
├── cuttlefish-files/{default,limits,modules,networkmanager,systemd,udev}
└── setup_cuttlefish_env.sh
```

---

## 3. 部署

### 3.1 上传并解压

```bash
unzip cuttlefish-base.zip
cd cuttlefish-base
```

**预期结果**：当前目录下存在 `setup_cuttlefish_env.sh`、`cuttlefish-common`、`cuttlefish-files`。

### 3.2 执行部署脚本（最后一步）

```bash
sudo bash setup_cuttlefish_env.sh
```

**预期结果**：

- 输出依次包含 `[Step 1/7]` 至 `[Step 7/7]` 的步骤信息
- 输出 `vhost_vsock 模块已加载`
- 输出 `sudoers 语法正确`
- 输出 `/run/cuttlefish 目录已创建`
- 最后输出：

```
============================================
Cuttlefish 环境初始化完成！
请重新登录或执行 'newgrp cuttlefish' 使组权限生效。
然后可使用 launch_cvd 启动实例。
============================================
```

- 部署后的文件位置：

```
/usr/lib/cuttlefish-common/{bin,etc}
/etc/modules-load.d/cuttlefish-common.conf
/etc/udev/rules.d/60-cuttlefish-base.rules
/etc/tmpfiles.d/cuttlefish.conf
/etc/sudoers.d/cuttlefish
```
