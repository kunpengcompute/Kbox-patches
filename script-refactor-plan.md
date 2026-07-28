### 1、重构总体约束

1. 保持当前脚本架构不变，仍为

```
---Kbox
   ---kbox_config.cfg # Kbox配置文件
   ---android_kbox.sh # Kbox脚本入口
---vmi
   ---cfct_config # 视频流配置文件
   ---cfct_video  # 视频流脚本入口
---base_box.sh # 提供公共能力
```

2. 保持当前配置项名称，与脚本接口面不变，避免破坏测试自动化脚本（部分命名不清晰的配置项，建议与测试对齐后统一修改，当前配置项的命名存在不清晰的问题）

### 2、重构设计原则

1. 脚本功能明确：`kbox_config.cfg`与`cfct_config`继续作为纯粹的配置文件，`android_kbox.sh`与`cfct_video`作为Kbox云手机与视频流云手机的脚本入口，仅保留最简功能（参数解析/业务路由/视频流云机差异化处理），公共能力全部在`base_box.sh`中实现，并被入口脚本以source的方式调用。
2. 消除冗余代码：当前部分逻辑在`android_kbox.sh`与`cfct_video`被重复实现，这部分代码统一移动到`base_box.sh`中。
3. 安卓11/15归一：除部分由安卓11/安卓15云机运行环境（cgroup v1 vs. cgroup v2等）差异导致的启动逻辑差异以外（在重构后以列表形式给出），其余实现归一，确保安卓11与安卓15云机使用方式一致。
4. Kbox/视频流归一：尽可能将Kbox和视频流的配置项，及相关的生效/使用方式归一，保持
5. 配置项生效方式优化：`kbox_config.cfg`与`cfct_config`中的配置项，除确实无法通过重启动态生效的配置以外（即只要容器启动，后续无法修改的，例如CPU/GPU绑定，数据卷挂载路径等），其余全部实现为可通过重启动态生效，并在配置文件中显式注明生效方式。
6. build.prop/default.prop/local.prop操作优化：对3份prop文件的使用方式，保持安卓11/15归一，并给出统一的修改生效方式。
7. CPU/GPU绑定配置优化：提供自动化生成的CPU/GPU绑定策略，并可通过手动配置覆盖。

### 3、详细设计

#### 3.1、明确脚本架构

##### 3.1.1、脚本调用关系设计

当前的实现中，base_box.sh作为公共能力底座的设计原则已被实际上破坏，例如：

* `check_environment`、NFS挂载校验等逻辑，在`android_kbox.sh`与`cfct_video`中重复实现。
* `android_kbox.sh`与`cfct_video`和`base_box.sh`中均有CLI分发器入口，这会导致`base_box.sh`使用方式的局限和不统一：只通过fork的方式调用，可能存在预期之外的副作用。且相对较重，对于一些小颗粒的功能，修改比较麻烦。
  **因此去除`base_box.sh`中的CLI入口，使其作为一个纯函数库，`android_kbox.sh`与`cfct_video`作为CLI入口和业务逻辑组织者，以source的形式调用`base_box.sh`提供的函数，`kbox_config.cfg`与`cfct_config`继续作为配置文件存在，不包含逻辑。**

![image](./03c23449-080e-4a5e-9e06-a825a96329cd.png)

| 脚本| 唯一职责 |
| --- | --- |
| base_box.sh | 提供公共函数 |
| android_kbox.sh | Kbox云手机CLI入口：解析参数 -> 调用公共函数 |
| cfct_video  | 视频流云手机CLI入口：解析参数 -> 调用公共函数 |
| kbox_config.cfg | Kbox业务配置数据 |
| cfct_config | 视频流业务配置数据 |

##### 3.1.2、重复函数消除

当前由于脚本职责的模糊，部分逻辑被重复实现，在脚本角色明确后，这些重复代码均应被抽取为公共函数，由`base_box.sh`提供。其中包括这些同名函数：

| kbox实现 | 视频流实现 | 功能 |
| --- | --- | --- |
| check_encode_card | check_encode_card | 识别编码卡硬件型号 |
| get_closest_numas | get_closest_numas | 根据CPU绑核返回最近的NUMA节点 |
| wait_container_ready | wait_container_ready | 判断安卓系统是否启动完成 |
| check_nfs_mount | check_nfs_mount | NFS相关校验 |
| check_f2fs_partition | check_f2fs_partition | F2FS相关校验 |
| 散落在main函数中 | check_paras | 参数校验 |

还有一些重复的代码片段，例如`media_codecs.xml`相关处理等，同样在本次重构中抽取为公共函数，实现在`base_box.sh`中。

#### 3.2、差异化实现归一

##### 3.2.1、安卓11/15归一（TODO）

当前安卓11和15脚本实现方式不同，导致部分配置项生效方式等细节处有差异（例如，安卓11允许重启切换软硬解，而安卓15不允许），而没有明确约束。在本次重构中，应保证安卓11/15脚本在使用方式上保持完全一致，并在此基础上尽可能消除二者实现上的差异（应该挑战安卓11/15分支归一）。

kbox_config.cfg差异：

| 差异项 | 安卓11 | 安卓15 | 策略 |
| --- | --- | --- | --- |
| ENABLE_SOFT_RENDER | 有 | 无 | 安卓15未落入相关需求，暂时保留差异 |
| ENABLE_ONLY64_KBOX | 有 | 无 | 安卓15未落入相关需求，暂时保留差异 |

android_kbox.sh差异：

| 差异项 | 安卓11 | 安卓15 | 策略 |
| --- | --- | --- | --- |
| THISDIR定义 | 无 | 有 | 与安卓15拉齐 |
| ENABLE_ONLY64_KBOX相关逻辑 | 有 | 无 | 与软渲染需求相关，安卓15不涉及，保留差异 |
| prepare_loop_device  | 无 | 有 | 安卓15相关，安卓11不涉及，保留差异 |
| stop_udev_services | 无 | 有 | 安卓15相关，安卓11不涉及，保留差异 |
| check_selinux | 无 | 有 | 与安卓15拉齐 |
| kbox_enable开关 | 无 | 有 | 与安卓15拉齐 |

base_box.sh差异：

| 差异项 | 安卓11 | 安卓15 | 策略 |
| --- | --- | --- | --- |
| --cap-drop=ALL | 有 | 无 | TODO：需要分析安卓15是否必须 |
| --device=/dev/ashmem | 有 | 无 | 6.6内核ashmem退出导致，保留差异 |
| --device=/dev/loop-control & --volume=/dev/loop_device | 无 | 有 | 安卓15 loop device差异导致，保留差异 |
| -v /sys:/sys | 无 | 有 | TODO：需要分析是否必须 |
| lxcfs volume | 逐一挂载/proc/diskstats等5个 | 统一挂载/proc:/lxcfs-proc:ro | TODO：需要分析差异 |
| device-cgroup-rule | c 13: * rwm规则 | 无该规则 | cgroup v1/v2差异，应依据这个条件进行判断 |
| 容器init入口 | init | /init | 统一到/init |
| AMD C2 decode处理 | 未赋值debug.stagefright.ccodec | debug.stagefright.ccodec无论是否使能都写build.prop | TODO： |
| VAGPU | 无 | 写ro.va.video.codec=c2到build.prop | TODO： |
| local.prop | volume形式挂载 | cp进容器 | 安卓15未验证local.prop功能，与安卓11拉齐 |
| 渲染层处理 | create_app_shader_filesystem调用两次 | 仅调用一次 | 与安卓15拉齐 |

cfct_config差异：

| 差异项 | 安卓11 | 安卓15 | 策略 |
| --- | --- | --- | --- |
| ENABLE_SOFT_RENDER | 有 | 无 | 安卓15不支持，保留差异 |
| ENABLE_ONLY64_KBOX | 有 | 无 | 安卓15不支持，保留差异 |
| 112、384核相关cpu/gpu map | 有 | 无 | 与安卓11拉齐 |

cfct_video差异：

| 差异项 | 安卓11 | 安卓15 | 策略 |
| --- | --- | --- | --- |
| CPU_MAP | 支持112核和384核 | 无 | 与安卓11拉齐 |
| wait_container_ready | ready后只chk_key_process | chk_key_process后有失败restart | 与安卓15拉齐 |
| 软渲染相关处理 | 有 | 无 | 安卓15不支持软渲染，保留差异 

##### 3.2.1、Kbox/视频流归一

当前Kbox/视频流的配置项和使用方式都有较大差异，而其中Kbox实现较为粗糙：例如Kbox中写死了云机数据卷镜像路径、CPU/GPU绑定关系等，导致在使用上有较严格的约束，配置项的命名二者也多有不同。**实际上，我们应该将Kbox视为视频流云机的一个子集（即去除了编码出流的部分）**。因此在实现中，我们也应遵循这一原则，将`android_box.sh`的实现向`cfct_video`靠拢，即：

1. kbox_config.cfg的内容保持为cfct_config的子集（从使用习惯考虑，暂不考虑配置文件之间的合并），所有配置项的含义、生效方式拉齐（同样从使用习惯考虑，暂不进行配置项的改名，但确保相同含义的配置项一一对应）。
2. `android_kbox.sh`的实现方式向`cfct_video`拉齐，仅去除不必要的部分（编码、端云引擎相关）。
3. 从使用习惯考虑，仍保持Kbox云手机和视频流云手机命名上的区别。

#### 3.3、配置项优化

##### 3.3.1、生效方式优化

当前配置项（功能开关、安卓属性）有多种配置方式：

* 通过配置文件修改，云机启动生效：修改`kbox_config.cfg`与`cfct_config`中配置项，启动云机生效，重启不生效
* 通过配置文件修改，重启生效：修改`kbox_config.cfg`与`cfct_config`中配置项，重启云机生效
* 修改default.prop文件，重启云机生效
* 修改local.prop文件，重启云机生效（仅安卓11）
* 修改build.prop文件，重启云机生效

但这些方式混杂，且对于某一配置项而言，没有明确声明其应有的配置方式。因此本次做如下优化：

1. 所有的云机属性/功能开关，均应作为配置文件中的一个配置项存在，并应尽可能地实现为支持通过重启云机方式进行修改（除了无法更改的容器配置以外，例如：绑核、挂载路径等）
2. 所有配置项，均应标注`[RESTART]`/`[RECREATE]`，区分通过重启生效，还是必须重新拉起容器生效
3. 对于build.prop，通过在`kbox_config.cfg`与`cfct_config`中提供配置项，允许用户自行配置需要的属性
4. 安卓15与安卓11拉齐，支持local.prop

kbox配置项：

| 当前类别 | 配置项 |
| --- | --- |
| 重启生效 | ENABLE_HARD_DECODE/ENABLE_RENDER_LAYER/HARD_DECODE_TYPE/ENABLE_F2FS/SYSTEM_PARTITION_SIZE_MB |
| 重建生效 | ENABLE_AMD_C2_DECODE/ENABLE_SOFT_RENDER/ENABLE_ONLY64_KBOX/NFS_DIR |

视频流配置项：

| 当前类别 | 配置项 |
| --- | --- |
| 重启生效 | BUILD_WIDTH/HEIGHT/DENSITY/FPS、ENABLE_AMD_C2_DECODE、ENABLE_HARD_DECODE、ENABLE_WEBRTC_CONNECTION、ENABLE_RENDER_LAYER、ENABLE_F2FS、SYSTEM_PARTITION_SIZE_MB、ENABLE_ONLY64_KBOX、ENCODECARD、T432_QUADRA_DECODE_ENABLE |
| 重建生效 | DOCKER_IMAGE、ENABLE_SOFT_RENDER、NFS_DIR、USERDATA、CPU/GPU相关绑定关系 |

待修改的：

| 配置项 | 问题 |
| --- | --- |
| ENABLE_AMD_C2_DECODE | Kbox与视频流实现不一致，Kbox无法重启生效 |

##### 3.3.3、CPU/GPU绑定配置优化

当前云机与CPU/GPU资源之间的绑定关系实现，Kbox与视频流实现均存在较大问题：

* Kbox：CPU、GPU绑定关系直接以数组方式写死，CPU固定为2C，GPU瀚博固定为4卡，灵活度很低，而且容易因硬件配置不同导致容器启动失败。
* 视频流：CPU分组、GPU绑定关系同样写死，对不同硬件配置需要重新适配，且存在较多冗余代码。

本次重构中，在base_box.sh中新增自动推断CPU/GPU节点绑定关系的功能，并保留通过配置文件手动指定绑定关系的能力（配置文件优先级高于自动推断），以适应各种测试场景下调试的灵活性。具体算法如下：

```bash
# 算法约束：
# 1. 云机cpu绑核不允许跨numa，cpu绑核与gpu节点之间保持亲和关系
# 2. 整体上保持socket间、numa间均衡（容器数量均匀分布）
# 3. 每个numa前x个核预留，配置每组cpu核数

# 算法实现：
# step1：获取当前硬件环境信息
	# 所有硬件资源按socket-numa二级索引划分为硬件资源桶
	# 1.1 获取cpu分组
	lscpu # 获取socket数s、numa数n、每numa核数c
	c = c - x # 每numa去除预留的核
	# 按配置的每组cpu核数，将c从后向前划分为组（尽可能保证分组不跨cluster），以数组形式管理（若无法均分，最后余数为一组，以WARNING形式提醒当前分布不均匀）

	# 1.2 获取gpu分组
	ll /sys/class/drm # 获取所有render节点
	lspci -vvv -d :0200 | grep -ai numa # 获取瀚博卡与NUMA之间的亲和关系
	# 按获取的亲和关系，划分render节点到对应的桶

	# 1.3 获取编码卡分组
	nvme list # 获取编码卡型号
	# 划分编码卡节点到对应的桶

# step2：分配cpu组到云机
# 与当前逻辑拉齐，按容器序号为索引，分配到硬件资源桶（按0-2-1-3顺序，确保跨numa和跨socket均衡），再按容器序号为索引，分配到对应的cpu组

# step3：分配gpu节点到云机
# 与分配cpu逻辑拉齐，先按容器序号对应到桶，再按序号分配到桶中的render节点。

# step4：分配编码卡节点到云机（仅NETINT）
# 与分配cpu逻辑拉齐，先按容器序号对应到桶，再按序号分配到桶中的render节点。虽然当前不区分亲和关系，但是保持前后逻辑一致
```

