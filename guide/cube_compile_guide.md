# CubeSandbox + guest 内核 编译说明

本文档说明如何从零准备 CubeSandbox 工作区，并通过 `build-cube.sh` 一键完成 **patch 合入 → guest 内核编译 → CubeSandbox 一键发布包编译**，以及在已部署环境上重新部署新编译的包（第 4 章）。

> **目标**：在 aarch64 编译机上，从 CubeSandbox v0.7.1 源码与 OpenCloudOS 6.6 内核源码出发，产出可直接部署的发布包。
>
> **编译机要求**：aarch64 Linux（与目标机同架构），已安装并启动 Docker，≥ 16 核 CPU、≥ 32GB 内存、≥ 200GB 磁盘。
>
> **构建产物**：
>
> - `vmlinux` —— guest 内核映像（含 patch `0005` / `0006` 的配置改动）
> - `cube-sandbox-one-click-<version>.tar.gz` —— 一键发布包（组件均由本方案 patch 后的源码编译）

## 1. 环境准备

### 1.1 硬件环境

组件编译与内核编译均为 aarch64 构建，发布包最终部署在同架构宿主机上。

| 项    | 要求                                            |
| ---- | --------------------------------------------- |
| 编译机  | aarch64 Linux，≥ 16 核 / ≥ 32GB 内存 / ≥ 200GB 磁盘 |
| 操作系统 | openEuler 24.03（推荐）/ Ubuntu 22.04+            |

### 1.2 安装编译依赖包

以 openEuler 24.03 为例：

```bash
sudo dnf install -y git make tar gzip pigz python3 nodejs npm docker
sudo systemctl start docker && sudo systemctl enable docker
```

> **说明：** 组件编译所需的完整工具链（Go / Rust / LLVM / protoc / 交叉编译器）全部由 builder 镜像提供，宿主机无需自行安装，也**不要改动宿主机的 Go / Rust 版本**——版本不一致会绕过 builder 内已验证的构建环境。工具链版本见附录 A。
>
> **说明：** 宿主机需提供 `nodejs` / `npm`——发布包中的 WebUI 在宿主机（非 builder 容器）执行 `npm ci && npm run build`；缺失时报 `required command not found: npm`。

### 1.3 配置构建所需的镜像源与代理

构建机需能访问 Docker Hub（builder 基础镜像 `ubuntu:20.04` 等）、Go module 代理、crates.io 与 GitHub。受限网络下按下面的方式配置（示例使用国内公共镜像/代理）：

```bash
# 1) Docker 镜像加速：Docker Hub 直连超时时配置 registry-mirror
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": ["https://docker.m.daocloud.io"]
}
EOF
systemctl reload docker          # registry-mirrors 支持热加载；必要时 systemctl restart docker
docker info | grep -A1 'Registry Mirrors'

# 2) crates.io 源替换：builder 的 CARGO_HOME 外挂在 /root/.cache/cube-sandbox-builder/.cargo
mkdir -p /root/.cache/cube-sandbox-builder/.cargo
cat > /root/.cache/cube-sandbox-builder/.cargo/config.toml <<'EOF'
[source.crates-io]
replace-with = "rsproxy-sparse"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF

# 3) builder 镜像构建阶段：生成一份带 GOPROXY + GitHub / Go 下载加速的 Dockerfile 副本
awk '
/^ARG DEBIAN_FRONTEND/ {
  print "ARG GITHUB_MIRROR="
  print "ENV GITHUB_MIRROR=${GITHUB_MIRROR:-https://gh-proxy.com/}"
}
/^RUN go install google\.golang\.org\/protobuf/ {
  print "ARG GOPROXY=https://goproxy.cn,direct"
  print "ENV GOPROXY=${GOPROXY}"
}
/^COPY CubeS3lvol\/setup_dep\.sh/ {
  print "# 受限网络加速：SPDK 走 gitee 镜像，其余 github.com 拉取走 gh-proxy。"
  print "ARG SPDK_REPO="
  print "ENV SPDK_REPO=${SPDK_REPO:-https://gitee.com/mirrors/spdk.git}"
}
/^RUN chmod \+x \/tmp\/s3lvol-dep\/setup_dep\.sh/ {
  print "RUN git config --global url.\"${GITHUB_MIRROR}https://github.com/\".insteadOf \"https://github.com/\" \\"
  sub(/^RUN /, "    \\&\\& ")
}
$0 ~ /https:\/\/github\.com\// && $0 ~ /wget|curl/ {
  gsub(/https:\/\/github\.com\//, "${GITHUB_MIRROR}https://github.com/")
}
# Go 官方下载站 go.dev 在国内多数环境不可达（curl 报 SSL connect error，退出码 35），
# 改用阿里云镜像；路径规则与 go.dev 完全一致（/golang/go<版本>.linux-<arch>.tar.gz）。
$0 ~ /https:\/\/go\.dev\/dl\// {
  gsub(/https:\/\/go\.dev\/dl\//, "https://mirrors.aliyun.com/golang/")
}
{ print }
' <工作区>/CubeSandbox/docker/Dockerfile.builder > /tmp/Dockerfile.builder.goproxy

# 4) npm registry（WebUI 构建）
npm config set registry https://registry.npmmirror.com
```

> **说明：**
>
> - 第 3 步产出的 `/tmp/Dockerfile.builder.goproxy` 需要在第 3 章构建时通过 `BUILDER_DOCKERFILE` 指定（见 §3.1）；若构建机可直连 `proxy.golang.org`，第 3 步可跳过。
> - 第 3 步同时解决 GitHub 拉取问题（builder 镜像内 github.com 全部不可直连）：`GITHUB_MIRROR` 默认 `https://gh-proxy.com/`，副本对两类场景生效——**wget/curl 下载 release 压缩包**（protoc、libseccomp 等，URL 自动加 `${GITHUB_MIRROR}` 前缀）、**git 克隆**（S3lvol 的 SPDK/aws 系，通过 `git config url.<mirror>.insteadOf` 重定向）；SPDK 单独走 `SPDK_REPO` 默认 `https://gitee.com/mirrors/spdk.git`。如需换源可在构建 shell 里 `export SPDK_REPO=...` / `export GITHUB_MIRROR=...` 覆盖（副本已做 ARG/ENV 透传）。

## 2. 拉取源码

### 2.1 准备工作区

```bash
mkdir -p cube-workspace && cd cube-workspace
```

下文以 `cube-workspace/` 为工作区根目录。

### 2.2 拉取 CubeSandbox v0.7.1 源码

```bash
cd cube-workspace
git clone https://gitcode.com/boostkit/CubeSandbox.git
cd CubeSandbox
git checkout v0.7.1

# 校验
git log -1 --format='%H'
# 期望: 2babb6f7405677c04b7fed1563c6a5d53a8e771b
```

> **说明：** CubeSandbox 是**单一 git 仓库**（`CubeMaster` / `Cubelet` / `CubeShim` / `hypervisor` 等均为其子目录），与 AOSP 那种多仓结构不同，因此本方案所有 patch 都在同一个仓库内应用，无需按相对路径分仓管理。

### 2.3 拉取 guest 内核源码

```bash
cd cube-workspace
git clone https://gitee.com/OpenCloudOS/OpenCloudOS-Kernel.git opencloudos-kernel
cd opencloudos-kernel
git checkout 6.6.119-49.6

# 校验
git log -1 --format='%H'
# 期望: a75d76aa7675ef86b782d19716916d9789c6f450
```

### 2.4 放置脚本与 patch

把本方案配套的 `Kbox-patches/` 目录整体放到工作区根目录下。工作区最终结构：

```
cube-workspace/
├── CubeSandbox/                  # 2.2 拉取
├── opencloudos-kernel/           # 2.3 拉取
└── Kbox-patches/
    ├── build/
    │   ├── build-cube.sh         # 第 3 章执行的构建脚本（CubeSandbox + guest 内核）
    │   ├── build_redroid.sh      # redroid 镜像构建脚本，见 redroid_compile_guide.md
    │   └── pack_gms.sh           # GMS 下载/注入脚本，由 build_redroid.sh 调用
    ├── deploy/
    │   └── cube_client.py        # 部署后的操作客户端，见 user_guide.md 第 6 章
    ├── guide/                    # 说明文档
    ├── patchForCube/             # 6 个 patch，由 build-cube.sh 自动应用
    └── patchForRedroid/          # redroid 侧 patch，由 build_redroid.sh 自动应用
```

> **说明：** `build-cube.sh` 按「脚本所在目录的上上级」定位工作区，因此 `CubeSandbox/`、`opencloudos-kernel/`、`Kbox-patches/` 三者必须同级。

<br />

## 3. 执行 build-cube.sh

### 3.1 脚本用法

```bash
cd cube-workspace/Kbox-patches/build

bash build-cube.sh all       # 一键全量（patch → 内核 → 发布包）
bash build-cube.sh patch     # 仅合入 patchForCube/ 下的 6 个 patch
bash build-cube.sh kernel    # 仅编译 guest 内核
bash build-cube.sh bundle    # 仅编译 CubeSandbox 一键发布包
```

可覆盖的环境变量：

| 变量                          | 默认值                             | 说明                                            |
| --------------------------- | ------------------------------- | --------------------------------------------- |
| `CUBE_SRC`                  | `<工作区>/CubeSandbox`             | CubeSandbox 源码目录                              |
| `KERNEL_SRC`                | `<工作区>/opencloudos-kernel`      | guest 内核源码目录                                  |
| `KERNEL_TARGET_ARCH`        | `aarch64`                       | 目标架构                                          |
| `KERNEL_BUILD_JOBS`         | `nproc`                         | 内核编译并发数                                       |
| `GOPROXY`                   | 空                               | 受限网络下指定 Go module 代理（作用于 builder 镜像与 `bundle` 步骤） |
| `BUILDER_IMAGE`             | `cube-sandbox-builder:ubuntu2004` | builder 镜像名                                    |
| `BUILDER_DOCKERFILE`        | `docker/Dockerfile.builder`     | builder 镜像使用的 Dockerfile（受限网络下指向 §1.3 生成的副本）   |
| `MIRROR`                    | 空                               | 设为 `cn` 时 builder 镜像的 apt/LLVM 源走国内镜像（腾讯 ubuntu + 浙大 llvm），避免上游源下载过慢 |
| `LLVM_MIRROR_BASE`          | `https://mirrors.zju.edu.cn/llvm-apt` | LLVM apt 镜像源；默认浙大镜像较慢，受限网络可覆盖为清华 `https://mirrors.tuna.tsinghua.edu.cn/llvm-apt` |
| `ONE_CLICK_GUEST_IMAGE_TAR` | 空                               | 指定时用该 guest image 归档（含 `cube-guest-image-cpu.img` 与 `version`）替代本地构建 |
| `ENVD_LOCAL_PATH`           | 空                               | 指定时把该 envd 二进制内嵌进发布包的 `cubemastercli`          |

构建前先导出受限网络所需的变量（与第 3 章命令在同一 shell 中执行）：

```bash
cd cube-workspace/Kbox-patches/build

export GOPROXY=https://goproxy.cn,direct                  # 受限网络下指定 Go module 代理
export BUILDER_DOCKERFILE=/tmp/Dockerfile.builder.goproxy  # §1.3 生成
export MIRROR=cn                                          # builder 镜像的 apt/LLVM 源走国内镜像，避免上游源下载过慢
export LLVM_MIRROR_BASE=https://mirrors.tuna.tsinghua.edu.cn/llvm-apt  # 覆盖默认浙大 LLVM 镜像（浙大下载慢），改用清华镜像加速
```

**受限网络：离线复用旧发布包中的 guest image（替代 Docker Hub 拉取）**

`bundle` 步骤默认在宿主机构建 guest image，基础镜像来自 Docker Hub 的 `tencentos/tencentos4-minimal:latest`。网络无法访问 Docker Hub 时，构建会在 `FROM` 处超时失败。若已有任一版本的发布包（如旧的 `cube-sandbox-one-click-<version>.tar.gz`），可从中提取 guest image 离线复用：

**第 1 步：解出外层包里的内层 `sandbox-package.tar.gz`**

```bash
mkdir -p /tmp/guestimg
tar -xzf deploy/one-click/dist/cube-sandbox-one-click-<version>.tar.gz \
    -C /tmp/guestimg \
    cube-sandbox-one-click-<version>/assets/package/sandbox-package.tar.gz
```

**第 2 步：解出内层包里的 guest image 两个文件**

```bash
tar -xzf /tmp/guestimg/cube-sandbox-one-click-<version>/assets/package/sandbox-package.tar.gz \
    -C /tmp/guestimg \
    sandbox-package/cube-image/cube-guest-image-cpu.img \
    sandbox-package/cube-image/version
```

**第 3 步：重新打包（两个文件必须位于归档根，无目录前缀）**

```bash
tar -czf <工作路径>/guest-image.tar.gz \
    -C /tmp/guestimg/sandbox-package/cube-image \
    cube-guest-image-cpu.img version
```

> 校验（可选）：打包后确认归档结构正确——
>
> ```bash
> tar -tzf <工作路径>/guest-image.tar.gz
> # 期望输出（根下直接两个文件）：
> # cube-guest-image-cpu.img
> # version
> ```

**第 4 步：指定归档**

```bash
export ONE_CLICK_GUEST_IMAGE_TAR=<工作路径>/guest-image.tar.gz
```

> **说明：** `ONE_CLICK_GUEST_IMAGE_TAR` 指向的归档必须为 gzip 格式（`.tar.gz`），脚本以 `tar -xzf` 解压并校验解压后 `cube-guest-image-cpu.img` 与 `version` 位于归档根（即 `build-guest-image.sh` 的 `ensure_file` 检查）；第 3 步的 `-C` 切换目录就是为此。跑完后 `dist/` 下会生成新的 `cube-sandbox-one-click-<version>.tar.gz`。

> **说明：**
>
> - **patch 不幂等**：脚本用 `git apply` 在「干净」源码树上应用 patch，重复执行 `build-cube.sh patch` 会因已应用而失败。还原方式：`git -C CubeSandbox checkout .`。
> - **源码树需干净**：若 `opencloudos-kernel` 中存在 in-tree 编译残留，`kernel` 步骤会报 `The source tree is not clean, please run 'make mrproper'`，执行 `make -C opencloudos-kernel ARCH=arm64 mrproper` 后重试。
> - **`vmlinux`** **是** **`Image`** **的副本**：aarch64 下最终的 `vmlinux` 文件实际是内核 `Image`（原始镜像），并非 ELF 格式——这是部署脚本的约定，属正常现象。
> - **构建缓存**：`CUBE_BUILD_TIME` 默认取 HEAD 提交时间而非当前时间，同一提交重复构建可复用 Go / Rust 增量缓存，第二次构建显著加快。
> - **压缩工具回退**：`pigz` 缺失时脚本自动回退单线程 gzip，产物内容一致，仅打包耗时增加。
> - **guest image 复用**：guest image 默认在宿主机构建，基础镜像为 Docker Hub 的 `tencentos/tencentos4-minimal:latest`。网络无法拉取该基础镜像时，可离线复用旧发布包中的 guest image（提取 → 重新打包 → `ONE_CLICK_GUEST_IMAGE_TAR` 指定），完整命令见上文「受限网络：离线复用旧发布包中的 guest image（替代 Docker Hub 拉取）」；`ONE_CLICK_GUEST_IMAGE_TAR` 的环境变量说明见本节的表格。

### 3.2 一键构建

```bash
cd cube-workspace/Kbox-patches/build
bash build-cube.sh all
```

<br />

### 3.3 分步构建

```bash
cd cube-workspace/Kbox-patches/build
bash build-cube.sh patch     # 1) 合入 patchForCube/ 下的 6 个 patch
bash build-cube.sh kernel    # 2) 编译 guest 内核
bash build-cube.sh bundle    # 3) 编译 CubeSandbox 一键发布包
```

> **说明：** `bundle` 步骤依赖 `kernel` 步骤的产物（会自动复制到 `deploy/one-click/assets/kernel-artifacts/vmlinux`）；若内核产物不存在，脚本直接报错终止。

### 3.4 产物与注意事项

| 产物       | 路径                                                                          |
| -------- | --------------------------------------------------------------------------- |
| guest 内核 | `CubeSandbox/_output/kernel/aarch64/vmlinux`                                |
| 发布包      | `CubeSandbox/deploy/one-click/dist/cube-sandbox-one-click-<version>.tar.gz` |

校验发布包中已打入内核与 guest image：

```bash
cd cube-workspace/CubeSandbox

# 外层：内核制品 + 嵌套的 sandbox-package（guest image 位于内层）
tar -tzf deploy/one-click/dist/cube-sandbox-one-click-<version>.tar.gz \
  | grep -E 'cube-kernel-scf\.zip|sandbox-package\.tar\.gz'

# 内层：guest image
tar -xzf deploy/one-click/dist/cube-sandbox-one-click-<version>.tar.gz -O \
    cube-sandbox-one-click-<version>/assets/package/sandbox-package.tar.gz \
  | tar -tzf - | grep cube-guest-image
```

## 4. 重新部署到已部署环境

本方案的 patch 同时改动 Cube 组件与 guest 内核，因此「改代码 → 重新编译 → 重新部署 → 重建模板」是一个闭环。本节说明在**已经部署过 CubeSandbox 的目标机**上用新编译的发布包覆盖安装，并保证所有组件（含 guest 内核）与本次编译产物一致。

> **说明：** 组件任一处变化都必须**重建模板**——模板是「redroid 镜像 + guest 内核 + cube-shim + cube-agent」的状态快照。

### 4.1 覆盖安装的难点

| 组件                                        | 版本化目录归档方式                              | 覆盖安装时的行为                                |
| ----------------------------------------- | -------------------------------------- | --------------------------------------- |
| `cube-shim` / `cube-image` / `cube-agent` | 按**版本号字符串**（如 `v0.7.1`、`guest-image-260820-1`） | 同名目录已存在即**跳过**，保留旧内容 → 与 `/usr/local` 下的新组件**不同源** |
| `cube-kernel-scf`                         | 按**内容哈希**（`sha256-<12位>`）              | 新内核必然生成新目录，天然一致                         |

模板构建读取 `/usr/local/services/cubetoolbox` 下的组件，而沙箱恢复读取 `/data/cubelet/root/component_versions/<版本>/` 下的副本；两者不同源时表现为「模板能建、沙箱起不来」。所以重新部署的关键是让版本化目录**全量刷新**。

### 4.2 重新部署步骤

以下命令在**目标机**上执行。

**步骤 1：记录现状**

```bash
TC=/usr/local/services/cubetoolbox
CV=/data/cubelet/root/component_versions

cat "$TC/VERSION.txt"
ls -l "$CV"/*
cubemastercli template list
cubemastercli ls
```

记下 `VERSION.txt`、各版本化目录名，以及待清理的模板 / 沙箱 ID。

**步骤 2：停控制面、清理沙箱**

```bash
cubemastercli cubebox destroy <sandbox-id> [...]      # 无沙箱则跳过
systemctl stop cube-sandbox-control.target
```

**步骤 3：移走版本化组件目录**

```bash
sudo mv "$CV" "/data/cubelet/root/component_versions.bak.$(date +%F-%H%M%S)"
```

移走后安装器找不到同名目录，会把新包中的 `cube-shim` / `cube-image` / `cube-agent` / `cube-kernel-scf` **全量写入**版本化目录，与 `/usr/local` 下同源；旧目录作为备份保留，可回滚。

> **说明：** 必须在停掉控制面之后执行——运行中的 shim 会按绝对路径读取该目录下的 `cube-runtime`。

**步骤 4：解压新包并覆盖安装**

```bash
tar -xzf cube-sandbox-one-click-<version>.tar.gz
cd cube-sandbox-one-click-<version>
cp -a <旧包目录>/.env .env          # 可选；不复制也会与既有配置做三方合并
sudo ./install.sh                   # 检测到既有安装 → 自动走「保留配置的升级」
```

> **说明：** 已部署环境**不要**加 `--mode=install`——该模式按语义会重置既有配置（自动生成的密钥、网络 CIDR 等），而 MySQL / Redis / MinIO 的数据卷仍保留旧内容，容易出现组件连不上库。`--mode=install` 只用于全新机器。

安装结束应看到 `[quickcheck] OK` 与 `install complete (role=...)`。

**步骤 5：校验组件一致性**

```bash
bash <工作区>/Kbox-patches/deploy/cube_healthcheck.sh
```

第 6 组「组件版本化目录一致性」必须全部通过（`cube-shim` 的 shim + runtime、`cube-agent`、`cube-image`、`cube-kernel-scf` 的 live 与版本化副本逐一比对），其余各组按输出处理。

**步骤 6：重建模板**

```bash
# 删除旧模板（会一并清理其在 cubebox_os_image/ 下的 rfs 制品）
cubemastercli template delete --template-id <旧 template-id>

# 用同一个 redroid 镜像重建（命令见 user_guide.md §5.1）
cubemastercli template create-from-image --image 127.0.0.1:5000/redroid:14.0.0_r75_arm64_only \
  --alias android14-4c8g ...        # 其余参数与首次部署一致
```

重建后确认打入的内核就是本次编译产物：

```bash
D=$(ls -d /usr/local/services/cubetoolbox/cubebox_os_image/rfs-*/ | tail -1)
sha256sum "$D"/*.vm
sha256sum /usr/local/services/cubetoolbox/cube-kernel-scf/vmlinux-bm
# 期望：两行哈希一致
```

**步骤 7：回归验证**

```bash
cubemastercli multirun --norm --runcnt 1 --runcc 1 redroid14_req.json                 # 期望 code:200
bash <工作区>/Kbox-patches/deploy/cube_healthcheck.sh --sandbox <沙箱IP>                # 期望 49983 / 5555 均 OPEN
adb connect <沙箱IP>:5555 && adb -s <沙箱IP>:5555 shell getprop sys.boot_completed      # 期望 1
```

### 4.3 注意事项

> **说明：** **guest 内核随模板生效**：内核是模板的组成部分（`<rfs>.vm`）。只更换部署包而不重建模板，起箱仍使用旧内核，因此「重编内核 → 重新部署 → 重建模板」必须成组执行。

> **说明：** **redroid 镜像不在部署包内**：镜像只与模板绑定。部署包更新而镜像不变时，重建模板即可；镜像本身重新构建时，需先推送到本地 registry，再重建模板。

> **说明：** **回滚**：把步骤 3 移走的目录移回原位，用旧包重新安装一次，再重建模板即可。

<br />

## 附录 A：builder 镜像工具链版本

| 组件                                      | 版本                                             |
| --------------------------------------- | ---------------------------------------------- |
| 基础镜像                                    | Ubuntu 20.04                                   |
| Go                                      | 1.25.7                                         |
| Rust（默认 / hypervisor / E2B API / agent） | 1.89 / 1.77.2 / 1.85 / 1.89                    |
| LLVM（clang / llvm-strip）                | 14                                             |
| protoc                                  | 28.3                                           |
| libseccomp                              | 2.5.5                                          |
| 交叉编译器                                   | `gcc-aarch64-linux-gnu`、`gcc-x86-64-linux-gnu` |

> **说明：** WebUI 由**宿主机**的 `nodejs` / `npm` 构建（见 §1.2），不在 builder 镜像内。

## 附录 B：patch 清单

`patch` 步骤由脚本自动按编号升序应用以下 6 个 patch，此处仅作说明。

| 序号   | patch 文件                                               | 修改目标                                                        | 作用                                                                                                                                                                                            |
| ---- | ------------------------------------------------------ | ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0001 | `0001-template-probe-timeout-flag.patch`               | `CubeMaster/cmd/cubemastercli/commands/cubebox/template.go` | 为 `template create-from-image` 新增 `--probe-timeout-ms`（默认 30000），使 Android 冷启动的探活超时可配置                                                                                                        |
| 0002 | `0002-template-annotation-flag.patch`                  | `CubeMaster/`、`CubeShim/`、`Cubelet/`（共 6 文件）                | 新增注解 `cube.vm.cgroup.unified_hierarchy`：置 `false` 时不再向 guest 注入 `agent.unified_cgroup_hierarchy=true`，避免 Android `init` 挂载 cgroup v2 冲突而重启；并为 `create-from-image` 新增 `--annotation KEY=VALUE` |
| 0003 | `0003-numa-aware-cgroup-pool.patch`                    | `Cubelet/plugins/cube/internals/cgroup/`（2 文件）              | 启用 NUMA 感知的 poolV2 cgroup 池，沙箱 cgroup 落到 `/cube_sandbox_v2/sandbox/numa<N>`                                                                                                                   |
| 0004 | `0004-gic-register-read-ub-fix.patch`                  | `hypervisor/hypervisor/src/kvm/aarch64/gic/`（4 文件）          | 修复 GIC 寄存器读取的 Rust UB（出参写成不可变局部变量，被 LLVM 常量折叠为 0），使快照恢复可用，即「模板能建、沙箱能起」                                                                                                                        |
| 0005 | `0005-guest-kernel-enable-psi-ipv6-dmabuf-heaps.patch` | `configs/kernel-oc9.aarch64.config`                         | 开启 `CONFIG_PSI`（lmkd 内存压力）、内建 `CONFIG_IPV6=y`（dual-stack socket）、`CONFIG_DMABUF_HEAPS`（Codec2 buffer 分配）                                                                                      |
| 0006 | `0006-guest-kernel-enable-fib-rules.patch`             | `configs/kernel-oc9.aarch64.config`                         | 开启 IPv4 / IPv6 策略路由（`CONFIG_IP_ADVANCED_ROUTER` + `CONFIG_IPV6_MULTIPLE_TABLES`），使 Android `netd` 能下发 per-network 默认路由，应用得以出网                                                                 |

> **说明：** patch 必须按序号顺序应用。`0002` 与 `0001` 修改同一文件（`template.go`），`0006` 与 `0005` 修改同一文件（`kernel-oc9.aarch64.config`），均存在上下文依赖。全部应用后去重共 **13 个文件**被修改。
>
> **说明：** `CONFIG_FIB_RULES` 是 `net/Kconfig` 中的隐藏符号（无 prompt），**不能直接书写**——手工写入会被 `olddefconfig` 覆盖，只能通过 `CONFIG_IP_ADVANCED_ROUTER=y` 与 `CONFIG_IPV6_MULTIPLE_TABLES=y` 的 `select` 连带打开。patch `0006` 已按此处理。

## 附录 C：版本基线

| 项           | 值                                                                                                                           |
| ----------- | --------------------------------------------------------------------------------------------------------------------------- |
| CubeSandbox | `https://gitcode.com/boostkit/CubeSandbox.git`，tag `v0.7.1`，commit `2babb6f7405677c04b7fed1563c6a5d53a8e771b`               |
| guest 内核源码  | `https://gitee.com/OpenCloudOS/OpenCloudOS-Kernel.git`，tag `6.6.119-49.6`，commit `a75d76aa7675ef86b782d19716916d9789c6f450` |
| guest 内核配置  | `configs/kernel-oc9.aarch64.config`（位于 **CubeSandbox** 仓库，不在内核仓库）                                                  |

## 附录 D：常见问题

**Q:** **`patch`** **步骤报** **`应用失败: .../0001-template-probe-timeout-flag.patch`？**

A: 源码树不干净（多为已应用过 patch）。执行 `git -C CubeSandbox checkout .` 还原后重跑。

**Q:** **`bundle`** **步骤报** **`缺少 guest 内核产物`？**

A: 未执行 `kernel` 步骤，或内核编译未产出 `vmlinux`。按 `patch` → `kernel` → `bundle` 顺序执行。

**Q: guest image 生成失败并提示** **`mkfs.ext4`** **不支持** **`-d`？**

A: 编译机 `e2fsprogs` 版本过低，升级后重试。

**Q:** **`go mod download`** **超时？**

A: 导出 `GOPROXY` 指向可用代理后重新执行 `bash build-cube.sh bundle`（见 §1.3、§3.1）。

**Q:** **builder 镜像构建报** **`FROM ubuntu:20.04`** **拉取超时 / connection refused？**

A: Docker Hub 不可达。按 §1.3 第 1 步配置 `registry-mirrors` 后重跑（`systemctl reload docker` 可热加载）。

**Q:** **builder 镜像构建报** **`Get "https://proxy.golang.org/...": i/o timeout`？**

A: 该层 `go install` 使用的 Go module 代理不可达。按 §1.3 第 3 步生成带 `GOPROXY` 的 Dockerfile 副本，`export BUILDER_DOCKERFILE=/tmp/Dockerfile.builder.goproxy` 后重跑（已完成的层会命中缓存，从失败处继续）。

**Q:** **builder 镜像构建报** **`curl: (35) ... SSL connect error`** **，失败层是** **`curl -fsSL "https://go.dev/dl/go${GO_VERSION}..."`？**

A: `go.dev` 不可达（国内多数环境如此，curl 退出码 35）。按 §1.3 第 3 步生成的 Dockerfile 副本已把该地址替换为 `https://mirrors.aliyun.com/golang/`（路径规则一致，实测可用），`export BUILDER_DOCKERFILE=/tmp/Dockerfile.builder.goproxy` 后重跑即可，已完成层会命中缓存。

> **说明：** 该层本应命中已有镜像的缓存，之所以被重新执行，是因为 `make guest-kernel` 前置的 `builder-image` 目标发现 s3lvol 依赖 stamp 与镜像标签不一致——**切换 CubeSandbox 版本后 `CubeS3lvol/setup_dep.sh` 的内容变化会改变 stamp，从而触发镜像重建**。可用下面两条命令确认：
>
> ```bash
> docker image inspect -f 'spdk={{index .Config.Labels "org.cubesandbox.s3lvol.spdk-stamp"}}' cube-sandbox-builder:ubuntu2004
> bash CubeSandbox/CubeS3lvol/setup_dep.sh --print-stamp spdk
> ```
>
> 两者不一致即会重建。若非必要，不要用改标签的方式绕过重建，否则 s3lvol 组件可能与源码要求的 spdk 版本不符。

**Q:** **`bundle`** **步骤报** **`failed to get` ... `as a dependency`（crates.io 超时）？**

A: 按 §1.3 第 2 步配置 crates.io 源替换后重跑。

**Q:** **`bundle`** **步骤报** **`required command not found: npm`？**

A: 宿主机缺少 `nodejs` / `npm`，按 §1.2 安装后重跑。

**Q: guest image 构建报** **`tencentos/tencentos4-minimal`** **拉取失败？**

A: 按 §3.4 的 guest image 复用说明，从官方发布包取出归档并以 `ONE_CLICK_GUEST_IMAGE_TAR` 指定后重跑。
