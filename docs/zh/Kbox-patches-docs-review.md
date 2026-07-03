# Kbox-patches AOSP15 中文文档编写问题审查报告

审查范围：`Kbox-patches/docs/zh/` 下所有 `.md` 文件，对照《文档编写规范.md》 及常见编写规范进行检查。

---

## 一、 版本配套问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | menu.md | 1 | 标题为 `# kbox-pathes-AOSP15`，应为 `# kbox-patches-AOSP15`（"pathes"拼写错误） | 高 |
| 2 | feature_guide.md | 11 | 链接指向 `https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/zh/compile_guide.md`，应为 AOSP15 分支 | 高 |
| 3 | feature_guide.md | 11 | 链接指向 `https://gitcode.com/boostkit/Kbox-patches/blob/AOSP11/docs/zh/install_guide.md`，应为 AOSP15 分支 | 高 |
| 4 | release_notes.md | 141 | 链接指向 `https://gitcode.com/boostkit/Kbox/blob/AOSP15/docs/zh/menu.md`，该链接指向的是 Kbox 仓库而非 Kbox-patches 仓库 | 高 |
| 5 | routine_maintenance.md | 206 | 链接中引用软件环境章节的 URL 为 `https://gitcode.com/boostkit/Kbox/blob/AOSP15/docs/zh/install_guide.md#22-软件环境`，指向 Kbox 仓库而非 Kbox-patches 仓库 | 高 |
| 6 | routine_maintenance.md | 330 | 链接中引用软件环境的 URL 为 `https://gitcode.com/boostkit/Kbox-patches/blob/AOSP15/docs/zh/install_guide.md#22-软件环境`，正确但锚点ID使用了 URL 编码的中文字符，可能导致跳转失败 | 中 |
| 7 | user_guide.md | 260 | NFS 挂载章节使用 `./android_kbox.sh` 启动脚本，应为 `./android_kbox_aosp15.sh` | 高 |
| 8 | user_guide.md | 266 | NFS 刌载章节使用 `./android_kbox.sh` 删除脚本，应为 `./android_kbox_aosp15.sh` | 高 |
| 9 | feature_guide.md | 514 | NFS 挂载章节使用 `./android_kbox.sh` 启动脚本，应为 `./android_kbox_aosp15.sh` | 高 |
| 10 | routine_maintenance.md | 77 | 运维章节重启容器使用 `./android_kbox.sh restart ${index}`，应为 `./android_kbox_aosp15.sh` | 高 |
| 11 | feature_guide.md | 221 | "7.3持线程级 Shader Cache"章节，链接提到 `Kbox-patches-AOSP11.zip`，应为 `Kbox-patches-AOSP15.zip` | 高 |

## 二、 标题规范问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | user_guide.md | 3 | 二级标题 `## 1 启动和卸载云手机实例`，标题不应携带序号 | 中 |
| 2 | user_guide.md | 62 | 二级标题 `## 1.2 启动与卸载云手机实例`，标题不应携带序号 | 中 |
| 3 | user_guide.md | 165 | 二级标题 `## 1.3 查询版本号信息`，标题不应携带序号 | 中 |
| 4 | user_guide.md | 195 | 二级标题 `## 1.4 （可选） 使能容器以F2FS文件系统启动`，标题不应携带序号 | 中 |
| 5 | user_guide.md | 222 | 二级标题 `## 1.5 （可选） 实现容器内/system分区大小可调节`，标题不应携带序号 | 中 |
| 6 | user_guide.md | 247 | 二级标题 `## 1.6 （可选） 使能容器支持NFS挂载启动`，标题不应携带序号 | 中 |
| 7 | user_guide.md | 277 | 二级标题 `## 1.7 （可选） 实现云机cpu频率动态调整`，标题不应携带序号 | 中 |
| 8 | user_guide.md | 325 | 二级标题 `## 2 SCRCPY测试`，标题不应携带序号 | 中 |
| 9 | user_guide.md | 371 | 二级标题 `## 3 （可选）Docker环境配置`，标题不应携带序号 | 中 |
| 10 | user_guide.md | 444 | 二级标题 `## 4 仿真设备参数配置`，标题不应携带序号 | 中 |
| 11 | user_guide.md | 490 | 二级标题 `## 4.2 配置系统属性`，标题不应携带序号 | 中 |
| 12 | user_guide.md | 492 | 三级标题 `### 4.2.1 配置GPS系统属性`，标题不应携带序号 | 中 |
| 13 | user_guide.md | 494 | 四级标题 `#### 4.2.1.1 GPS属性说明`，标题不应携带序号 | 中 |
| 14 | user_guide.md | 514 | 四级标题 `#### 4.2.1.2 配置属性示例`，标题不应携带序号 | 中 |
| 15 | user_guide.md | 568 | 三级标题 `### 4.2.2 配置Telephony系统属性`，标题不应携带序号 | 中 |
| 16 | user_guide.md | 570 | 四级标题 `#### 4.2.2.1 Telephony属性说明`，标题不应携带序号 | 中 |
| 17 | user_guide.md | 589 | 四级标题 `#### 4.2.2.2 配置属性示例`，标题不应携带序号 | 中 |
| 18 | user_guide.md | 678 | 三级标题 `### 4.2.3 配置加速度陀螺仪系统属性`，标题不应携带序号 | 中 |
| 19 | user_guide.md | 680 | 四级标题 `#### 4.2.3.1 加速度陀螺仪属性说明`，标题不应携带序号 | 中 |
| 20 | user_guide.md | 698 | 四级标题 `#### 4.2.3.2 配置属性示例`，标题不应携带序号 | 中 |
| 21 | user_guide.md | 730 | 三级标题 `### 4.2.4 配置多VInput设备系统属性`，标题不应携带序号 | 中 |
| 22 | user_guide.md | 732 | 四级标题 `#### 4.2.4.1 VInput属性说明`，标题不应携带序号 | 中 |
| 23 | user_guide.md | 744 | 四级标题 `#### 4.2.4.2 配置属性示例`，标题不应携带序号 | 中 |
| 24 | user_guide.md | 808 | 二级标题 `## 5 故障处理`，标题不应携带序号 | 中 |
| 25 | user_guide.md | 810 | 三级标题 `### 5.1 概述`，标题不应携带序号 | 中 |
| 26 | user_guide.md | 812 | 四级标题 `#### 5.1.1 故障处理原则`，标题不应携带序号 | 中 |
| 27 | user_guide.md | 840 | 四级标题 `#### 5.1.2 故障处理流程`，标题不应携带序号 | 中 |
| 28 | user_guide.md | 878 | 三级标题 `### 5.2 信息收集`，标题不应携带序号 | 中 |
| 29 | user_guide.md | 880 | 四级标题 `#### 5.2.1 声明`，标题不应携带序号 | 中 |
| 30 | user_guide.md | 888 | 四级标题 `#### 5.2.2 基本信息收集`，标题不应携带序号 | 中 |
| 31 | feature_guide.md | 3 | 二级标题 `## 1 特性描述`，标题不应携带序号 | 中 |
| 32 | feature_guide.md | 37 | 二级标题 `## 2 支持纹理自适应压缩`，标题不应携带序号 | 中 |
| 33 | feature_guide.md | 66 | 二级标题 `## 3 自适应帧同步`，标题不应携带序号 | 中 |
| 34 | feature_guide.md | 100 | 二级标题 `## 4 Kbox动态帧率调整`，标题不应携带序号 | 中 |
| 35 | feature_guide.md | 132 | 二级标题 `## 5 Android轻量化裁剪`，标题不应携带序号 | 中 |
| 36 | feature_guide.md | 163 | 二级标题 `## 6 Android composer优化`，标题不应携带序号 | 中 |
| 37 | feature_guide.md | 194 | 二级标题 `## 7 支持线程级Shader Cache`，标题不应携带序号 | 中 |
| 38 | feature_guide.md | 228 | 二级标题 `## 8 以f2fs文件格式启动`，标题不应携带序号 | 中 |
| 39 | feature_guide.md | 329 | 二级标题 `## 9 容器内/system分区大小可调节`，标题不应携带序号 | 中 |
| 40 | feature_guide.md | 422 | 二级标题 `## 10 支持NFS挂载`，标题不应携带序号 | 中 |
| 41 | feature_guide.md | 523 | 二级标题 `## 11 CPU频率动态模拟与调节`，标题不应携带序号 | 中 |
| 42 | feature_guide.md | 39 | 三级标题 `### 2.1 特性介绍`，标题不应携带序号 | 中 |
| 43 | feature_guide.md | 41 | 四级标题 `#### 2.1.1 简介`，标题不应携带序号 | 中 |
| 44 | feature_guide.md | 45 | 四级标题 `#### 2.1.2 约束与限制`，标题不应携带序号 | 中 |
| 45 | feature_guide.md | 51 | 四级标题 `#### 2.1.3 应用场景`，标题不应携带序号 | 中 |
| 46 | feature_guide.md | 55 | 三级标题 `### 2.2 安装特性`，标题不应携带序号 | 中 |
| 47 | feature_guide.md | 59 | 三级标题 `### 2.3 使用特性`，标题不应携带序号 | 中 |
| 48 | feature_guide.md | 68 | 三级标题 `### 3.1 特性介绍`，标题不应携带序号 | 中 |
| 49 | feature_guide.md | 70 | 四级标题 `#### 3.1.1 简介`，标题不应携带序号 | 中 |
| 50 | feature_guide.md | 76 | 四级标题 `#### 3.1.2 约束与限制`，标题不应携带序号 | 中 |
| 51 | feature_guide.md | 80 | 四级标题 `#### 3.1.3 应用场景`，标题不应携带序号 | 中 |
| 52 | feature_guide.md | 84 | 三级标题 `### 3.2 安装特性`，标题不应携带序号 | 中 |
| 53 | feature_guide.md | 90 | 三级标题 `### 3.3 使用特性`，标题不应携带序号 | 中 |
| 54 | feature_guide.md | 96 | 三级标题 `### 3.4 特性收益`，标题不应携带序号 | 中 |
| 55 | feature_guide.md | 102 | 三级标题 `### 4.1 特性介绍`，标题不应携带序号 | 中 |
| 56 | feature_guide.md | 104 | 四级标题 `#### 4.1.1 简介`，标题不应携带序号 | 中 |
| 57 | feature_guide.md | 108 | 四级标题 `#### 4.1.2 约束与限制`，标题不应携带序号 | 中 |
| 58 | feature_guide.md | 112 | 四级标题 `#### 4.1.3 应用场景`，标题不应携带序号 | 中 |
| 59 | feature_guide.md | 116 | 三级标题 `### 4.2 安装特性`，标题不应携带序号 | 中 |
| 60 | feature_guide.md | 126 | 三级标题 `### 4.3 使用特性`，标题不应携带序号 | 中 |
| 61 | feature_guide.md | 132 | 三级标题 `### 5.1 特性介绍`，标题不应携带序号 | 中 |
| 62 | feature_guide.md | 134 | 四级标题 `#### 5.1.1 简介`，标题不应携带序号 | 中 |
| 63 | feature_guide.md | 140 | 四级标题 `#### 5.1.2 约束与限制`，标题不应携带序号 | 中 |
| 64 | feature_guide.md | 146 | 四级标题 `#### 5.1.3 应用场景`，标题不应携带序号 | 中 |
| 65 | feature_guide.md | 148 | 三级标题 `### 5.2 安装特性`，标题不应携带序号 | 中 |
| 66 | feature_guide.md | 156 | 三级标题 `### 5.3 使用特性`，标题不应携带序号 | 中 |
| 67 | feature_guide.md | 159 | 三级标题 `### 5.4 特性收益`，标题不应携带序号 | 中 |
| 68 | feature_guide.md | 163 | 三级标题 `### 6.1 特性介绍`，标题不应携带序号 | 中 |
| 69 | feature_guide.md | 165 | 四级标题 `#### 6.1.1 简介`，标题不应携带序号 | 中 |
| 70 | feature_guide.md | 171 | 四级标题 `#### 6.1.2 约束与限制`，标题不应携带序号 | 中 |
| 71 | feature_guide.md | 175 | 四级标题 `#### 6.1.3 应用场景`，标题不应携带序号 | 中 |
| 72 | feature_guide.md | 180 | 三级标题 `### 6.2 安装特性`，标题不应携带序号 | 中 |
| 73 | feature_guide.md | 184 | 三级标题 `### 6.3 使用特性`，标题不应携带序号 | 中 |
| 74 | feature_guide.md | 190 | 三级标题 `### 6.4 特性收益`，标题不应携带序号 | 中 |
| 75 | feature_guide.md | 194 | 三级标题 `### 7.1 特性介绍`，标题不应携带序号 | 中 |
| 76 | feature_guide.md | 196 | 四级标题 `#### 7.1.1 简介`，标题不应携带序号 | 中 |
| 77 | feature_guide.md | 200 | 四级标题 `#### 7.1.2 约束与限制`，标题不应携带序号 | 中 |
| 78 | feature_guide.md | 208 | 四级标题 `#### 7.1.3 应用场景`，标题不应携带序号 | 中 |
| 79 | feature_guide.md | 212 | 三级标题 `### 7.2 安装特性`，标题不应携带序号 | 中 |
| 80 | feature_guide.md | 216 | 三级标题 `### 7.3 使用特性`，标题不应携带序号 | 中 |
| 81 | feature_guide.md | 228 | 三级标题 `### 8.1 特性介绍`，标题不应携带序号 | 中 |
| 82 | feature_guide.md | 230 | 四级标题 `#### 8.1.1 简介`，标题不应携带序号 | 中 |
| 83 | feature_guide.md | 235 | 四级标题 `#### 8.1.2 约束与限制`，标题不应携带序号 | 中 |
| 84 | feature_guide.md | 240 | 四级标题 `#### 8.1.3 应用场景`，标题不应携带序号 | 中 |
| 85 | feature_guide.md | 244 | 三级标题 `### 8.2 使用介绍`，标题不应携带序号 | 中 |
| 86 | feature_guide.md | 248 | 四级标题 `#### 8.2.1.1 环境准备`，标题不应携带序号 | 中 |
| 87 | feature_guide.md | 266 | 四级标题 `#### 8.2.1.2 新建f2fs磁盘并挂载指定目录`，标题不应携带序号 | 中 |
| 88 | feature_guide.md | 317 | 三级标题 `### 8.2.2 使用特性`，标题不应携带序号 | 中 |
| 89 | feature_guide.md | 329 | 三级标题 `### 9.1 特性介绍`，标题不应携带序号 | 中 |
| 90 | feature_guide.md | 331 | 四级标题 `#### 9.1.1 简介`，标题不应携带序号 | 中 |
| 91 | feature_guide.md | 337 | 四级标题 `#### 9.1.2 约束与限制`，标题不应携带序号 | 中 |
| 92 | feature_guide.md | 343 | 四级标题 `#### 9.1.3 应用场景`，标题不应携带序号 | 中 |
| 93 | feature_guide.md | 347 | 三级标题 `### 9.2 使用介绍`，标题不应携带序号 | 中 |
| 94 | feature_guide.md | 349 | 四级标题 `#### 9.2.1 安装特性`，标题不应携带序号 | 中 |
| 95 | feature_guide.md | 351 | 五级标题 `##### 9.2.1.1 新建xfs盘并挂载`，标题不应携带序号 | 中 |
| 96 | feature_guide.md | 409 | 四级标题 `#### 9.2.1.2 触发分区扩容逻辑`，标题不应携带序号 | 中 |
| 97 | feature_guide.md | 417 | 三级标题 `### 9.2.2 使用特性`，标题不应携带序号 | 中 |
| 98 | feature_guide.md | 422 | 二级标题 `## 10 支持NFS挂载`，标题不应携带序号 | 中 |
| 99 | feature_guide.md | 424 | 三级标题 `### 10.1 特性介绍`，标题不应携带序号 | 中 |
| 100 | feature_guide.md | 426 | 四级标题 `#### 10.1.1 简介`，标题不应携带序号 | 中 |
| 101 | feature_guide.md | 430 | 四级标题 `#### 10.1.2 约束与限制`，标题不应携带序号 | 中 |
| 102 | feature_guide.md | 434 | 四级标题 `#### 10.1.3 应用场景`，标题不应携带序号 | 中 |
| 103 | feature_guide.md | 438 | 三级标题 `### 10.2 安装特性`，标题不应携带序号 | 中 |
| 104 | feature_guide.md | 441 | 四级标题 `#### 10.2.1 客户端/服务器公共操作`，标题不应携带序号 | 中 |
| 105 | feature_guide.md | 462 | 四级标题 `#### 10.2.2 服务器配置`，标题不应携带序号 | 中 |
| 106 | feature_guide.md | 492 | 四级标题 `#### 10.2.3 客户端配置`，标题不应携带序号 | 中 |
| 107 | feature_guide.md | 509 | 三级标题 `### 10.3 使用特性`，标题不应携带序号 | 中 |
| 108 | feature_guide.md | 523 | 二级标题 `## 11 CPU频率动态模拟与调节`，标题不应携带序号 | 中 |
| 109 | feature_guide.md | 525 | 三级标题 `### 11.1 特性介绍`，标题不应携带序号 | 中 |
| 110 | feature_guide.md | 527 | 四级标题 `#### 11.1.1 简介`，标题不应携带序号 | 中 |
| 111 | feature_guide.md | 531 | 四级标题 `#### 11.1.2 约束与限制`，标题不应携带序号 | 中 |
| 112 | feature_guide.md | 535 | 四级标题 `#### 11.1.3 应用场景`，标题不应携带序号 | 中 |
| 113 | feature_guide.md | 539 | 三级标题 `### 11.2 使用介绍`，标题不应携带序号 | 中 |
| 114 | feature_guide.md | 541 | 四级标题 `#### 11.2.1 安装特性`，标题不应携带序号 | 中 |
| 115 | feature_guide.md | 543 | 五级标题 `##### 11.2.1.1 权限检测`，标题不应携带序号 | 中 |
| 116 | feature_guide.md | 559 | 五级标题 `##### 11.2.1.2 新增权限`，标题不应携带序号 | 中 |
| 117 | feature_guide.md | 573 | 五级标题 `##### 11.2.1.3 文件说明`，标题不应携带序号 | 中 |
| 118 | feature_guide.md | 594 | 四级标题 `#### 11.2.2 实施修改`，标题不应携带序号 | 中 |
| 119 | install_guide.md | 3 | 二级标题 `## 1 部署说明`，标题不应携带序号 | 中 |
| 120 | install_guide.md | 7 | 二级标题 `## 2 环境准备`，标题不应携带序号 | 中 |
| 121 | install_guide.md | 9 | 三级标题 `### 2.1 硬件环境`，标题不应携带序号 | 中 |
| 122 | install_guide.md | 35 | 三级标题 `### 2.2 软件环境`，标题不应携带序号 | 中 |
| 123 | install_guide.md | 76 | 二级标题 `## 3 部署流程简述`，标题不应携带序号 | 中 |
| 124 | install_guide.md | 86 | 二级标题 `## 4 配置BIOS`，标题不应携带序号 | 中 |
| 125 | install_guide.md | 88 | 三级标题 `### 4.1 内存插入顺序说明`，标题不应携带序号 | 中 |
| 126 | install_guide.md | 97 | 三级标题 `### 4.2 （硬件配置方案一、二）配置BIOS`，标题不应携带序号 | 中 |
| 127 | install_guide.md | 186 | 三级标题 `### 4.3 （硬件配置方案三、四）配置BIOS`，标题不应携带序号 | 中 |
| 128 | install_guide.md | 234 | 二级标题 `## 5 网卡绑定CPU`，标题不应携带序号 | 中 |
| 129 | install_guide.md | 344 | 二级标题 `## 6 （硬件配置方案一）配置GPU工作模式`，标题不应携带序号 | 中 |
| 130 | install_guide.md | 354 | 二级标题 `## 7 编译内核`，标题不应携带序号 | 中 |
| 131 | install_guide.md | 356 | 三级标题 `### 7.1 编译准备`，标题不应携带序号 | 中 |
| 132 | install_guide.md | 523 | 三级标题 `### 7.2 编译及安装内核`，标题不应携带序号 | 中 |
| 133 | install_guide.md | 525 | 四级标题 `#### 7.2.1 下载Kernel源码`，标题不应携带序号 | 中 |
| 134 | install_guide.md | 543 | 四级标题 `#### 7.2.2 合入内核补丁`，标题不应携带序号 | 中 |
| 135 | install_guide.md | 574 | 四级标题 `#### 7.2.3 编译及安装内核`，标题不应携带序号 | 中 |
| 136 | install_guide.md | 797 | 二级标题 `## 8 部署Kbox`，标题不应携带序号 | 中 |
| 137 | install_guide.md | 799 | 三级标题 `### 8.1 确定GPU拓扑结构`，标题不应携带序号 | 中 |
| 138 | install_guide.md | 871 | 三级标题 `### 8.2 （硬件配置方案一，可选）升级NVMe固件版本`，标题不应携带序号 | 中 |
| 139 | install_guide.md | 917 | 三级标题 `### 8.3 （硬件配置方案二、三、四）安装显卡驱动`，标题不应携带序号 | 中 |
| 140 | install_guide.md | 992 | 三级标题 `### 8.4 上传ExaGear转码包`，标题不应携带序号 | 中 |
| 141 | compile_guide.md | 3 | 二级标题 `## 1 环境准备`，标题不应携带序号 | 中 |
| 142 | compile_guide.md | 5 | 三级标题 `### 1.1 硬件环境`，标题不应携带序号 | 中 |
| 143 | compile_guide.md | 22 | 三级标题 `### 1.2 软件环境`，标题不应携带序号 | 中 |
| 144 | compile_guide.md | 62 | 二级标题 `## 2 编译构建流程`，标题不应携带序号 | 中 |
| 145 | compile_guide.md | 71 | 二级标题 `## 3 安装编译依赖包`，标题不应携带序号 | 中 |
| 146 | compile_guide.md | 182 | 二级标题 `## 4 编译AOSP源码与镜像生成`，标题不应携带序号 | 中 |
| 147 | compile_guide.md | 184 | 三级标题 `### 4.1 下载AOSP源码`，标题不应携带序号 | 中 |
| 148 | compile_guide.md | 207 | 三级标题 `### 4.2 下载Mesa Demo源码`，标题不应携带序号 | 中 |
| 149 | compile_guide.md | 228 | 三级标题 `### 4.3 合入Kbox安卓补丁`，标题不应携带序号 | 中 |
| 150 | compile_guide.md | 252 | 三级标题 `### 4.4 合入二进制内容`，标题不应携带序号 | 中 |
| 151 | compile_guide.md | 290 | 三级标题 `### 4.5 编译AOSP并生成镜像`，标题不应携带序号 | 中 |
| 152 | test_guide.md | 3 | 二级标题 `## 1 概述`，标题不应携带序号 | 中 |
| 153 | test_guide.md | 5 | 三级标题 `### 1.1 验收依据`，标题不应携带序号 | 中 |
| 154 | test_guide.md | 9 | 三级标题 `### 1.2 注意事项`，标题不应携带序号 | 中 |
| 155 | test_guide.md | 20 | 二级标题 `## 2 测试准备`，标题不应携带序号 | 中 |
| 156 | test_guide.md | 24 | 二级标题 `## 3 测试约定`，标题不应携带序号 | 中 |
| 157 | test_guide.md | 34 | 二级标题 `## 4 测试用例及测试记录`，标题不应携带序号 | 中 |
| 158 | test_guide.md | 36 | 三级标题 `### 4.1 基本功能测试`，标题不应携带序号 | 中 |
| 159 | test_guide.md | 38 | 四级标题 `#### 4.1.1 创建Kbox云手机容器`，标题不应携带序号 | 中 |
| 160 | test_guide.md | 51 | 四级标题 `#### 4.1.2 重启Kbox云手机容器`，标题不应携带序号 | 中 |
| 161 | test_guide.md | 64 | 四级标题 `#### 4.1.3 删除Kbox云手机容器`，标题不应携带序号 | 中 |
| 162 | test_guide.md | 77 | 四级标题 `#### 4.1.4 Kbox云手机容器状态查询`，标题不应携带序号 | 中 |
| 163 | test_guide.md | 90 | 四级标题 `#### 4.1.5 Kbox云手机容器adb测试`，标题不应携带序号 | 中 |
| 164 | test_guide.md | 103 | 四级标题 `#### 4.1.6 资源隔离测试`，标题不应携带序号 | 中 |
| 165 | test_guide.md | 116 | 四级标题 `#### 4.1.7 GPS Mock测试`，标题不应携带序号 | 中 |
| 166 | test_guide.md | 129 | 四级标题 `#### 4.1.8 IMEI Mock测试`，标题不应携带序号 | 中 |
| 167 | test_guide.md | 142 | 四级标题 `#### 4.1.9 Wi-Fi Mock测试`，标题不应携带序号 | 中 |
| 168 | test_guide.md | 155 | 四级标题 `#### 4.1.10 传感器Mock测试`，标题不应携带序号 | 中 |
| 169 | test_guide.md | 168 | 四级标题 `#### 4.1.11 vinput设备创建`，标题不应携带序号 | 中 |
| 170 | test_guide.md | 181 | 四级标题 `#### 4.1.12 vinput设备事件发送与接收`，标题不应携带序号 | 中 |
| 171 | test_guide.md | 194 | 四级标题 `#### 4.1.13 GPS Mock属性值修改`，标题不应携带序号 | 中 |
| 172 | test_guide.md | 207 | 四级标题 `#### 4.1.14 传感器属性值设置`，标题不应携带序号 | 中 |
| 173 | test_guide.md | 220 | 四级标题 `#### 4.1.15 Kbox组件版本号查询测试`，标题不应携带序号 | 中 |
| 174 | test_guide.md | 233 | 四级标题 `#### 4.1.16 Kbox云手机硬解视频播放能力测试`，标题不应携带序号 | 中 |
| 175 | test_guide.md | 246 | 四级标题 `#### 4.1.17 IMSI Mock测试`，标题不应携带序号 | 中 |
| 176 | test_guide.md | 259 | 四级标题 `#### 4.1.18 网络运营商信息、SIM卡信息查询测试`，标题不应携带序号 | 中 |
| 177 | test_guide.md | 272 | 二级标题 `## 5 测试结果分析`，标题不应携带序号 | 中 |
| 178 | test_guide.md | 274 | 三级标题 `### 5.1 测试基本信息`，标题不应携带序号 | 中 |
| 179 | test_guide.md | 285 | 三级标题 `### 5.2 测试结果列表`，标题不应携带序号 | 中 |
| 180 | test_guide.md | 310 | 二级标题 `## 6 客户建议及结果确认`，标题不应携带序号 | 中 |
| 181 | test_guide.md | 312 | 三级标题 `### 6.1 客户建议`，标题不应携带序号 | 中 |
| 182 | test_guide.md | 314 | 三级标题 `### 6.2 结果确认`，标题不应携带序号 | 中 |
| 183 | routine_maintenance.md | 3 | 二级标题 `## 1 运维概述`，标题不应携带序号 | 中 |
| 184 | routine_maintenance.md | 22 | 二级标题 `## 2 巡检`，标题不应携带序号 | 中 |
| 185 | routine_maintenance.md | 24 | 三级标题 `### 2.1 简介`，标题不应携带序号 | 中 |
| 186 | routine_maintenance.md | 28 | 三级标题 `### 2.2 巡检项目和周期`，标题不应携带序号 | 中 |
| 187 | routine_maintenance.md | 39 | 三级标题 `### 2.3 检查容器状态`，标题不应携带序号 | 中 |
| 188 | routine_maintenance.md | 41 | 四级标题 `#### 2.3.1 启动时容器状态`，标题不应携带序号 | 中 |
| 189 | routine_maintenance.md | 61 | 四级标题 `#### 2.3.2 运行时容器状态`，标题不应携带序号 | 中 |
| 190 | routine_maintenance.md | 80 | 三级标题 `### 2.4 检查容器资源消耗`，标题不应携带序号 | 中 |
| 191 | routine_maintenance.md | 96 | 二级标题 `## 3 监控`，标题不应携带序号 | 中 |
| 192 | routine_maintenance.md | 98 | 三级标题 `### 3.1 简介`，标题不应携带序号 | 中 |
| 193 | routine_maintenance.md | 102 | 三级标题 `### 3.2 CPU使用详情`，标题不应携带序号 | 中 |
| 194 | routine_maintenance.md | 132 | 三级标题 `### 3.3 系统内存`，标题不应携带序号 | 中 |
| 195 | routine_maintenance.md | 148 | 三级标题 `### 3.4 系统存储`，标题不应携带序号 | 中 |
| 196 | routine_maintenance.md | 160 | 三级标题 `### 3.5 GPU使用详情`，标题不应携带序号 | 中 |
| 197 | routine_maintenance.md | 162 | 四级标题 `#### 3.5.1 AMD GPU状态查询`，标题不应携带序号 | 中 |
| 198 | routine_maintenance.md | 202 | 四级标题 `#### 3.5.2 道客DC 1000状态查询`，标题不应携带序号 | 中 |
| 199 | routine_maintenance.md | 209 | 二级标题 `## 4 日志管理`，标题不应携带序号 | 中 |
| 200 | routine_maintenance.md | 211 | 三级标题 `### 4.1 简介`，标题不应携带序号 | 中 |
| 201 | routine_maintenance.md | 215 | 三级标题 `### 4.2 Kbox云手机容器日志`，标题不应携带序号 | 中 |
| 202 | routine_maintenance.md | 217 | 四级标题 `#### 4.2.1 容器元数据`，标题不应携带序号 | 中 |
| 203 | routine_maintenance.md | 240 | 四级标题 `#### 4.2.2 容器内logcat日志`，标题不应携带序号 | 中 |
| 204 | routine_maintenance.md | 254 | 四级标题 `#### 4.2.3 容器内进程信息`，标题不应携带序号 | 中 |
| 205 | routine_maintenance.md | 262 | 四级标题 `#### 4.2.4 容器内top信息`，标题不应携带序号 | 中 |
| 206 | routine_maintenance.md | 270 | 四级标题 `#### 4.2.5 ANR时应用堆栈信息`，标题不应携带序号 | 中 |
| 207 | routine_maintenance.md | 274 | 四级标题 `#### 4.2.6 dumpsys信息`，标题不应携带序号 | 中 |
| 208 | routine_maintenance.md | 300 | 四级标题 `#### 4.2.7 容器属性信息`，标题不应携带序号 | 中 |
| 209 | routine_maintenance.md | 308 | 三级标题 `### 4.3 运行环境日志`，标题不应携带序号 | 中 |
| 210 | routine_maintenance.md | 310 | 四级标题 `#### 4.3.1 dmesg日志`，标题不应携带序号 | 中 |
| 211 | routine_maintenance.md | 322 | 三级标题 `### 4.4 维护工具`，标题不应携带序号 | 中 |
| 212 | routine_maintenance.md | 324 | 四级标题 `#### 4.4.1 工具简介`，标题不应携带序号 | 中 |
| 213 | routine_maintenance.md | 332 | 四级标题 `#### 4.4.2 日志收集`，标题不应携带序号 | 中 |
| 214 | routine_maintenance.md | 360 | 四级标题 `#### 4.4.3 赎源检查`，标题不应携带序号 | 中 |
| 215 | routine_maintenance.md | 382 | 四级标题 `#### 4.4.4 故障检查及恢复`，标题不应携带序号 | 中 |
| 216 | routine_maintenance.md | 406 | 二级标题 `## 5 高危操作`，标题不应携带序号 | 中 |
| 217 | routine_maintenance.md | 408 | 三级标题 `### 5.1 禁用操作一览表`，标题不应携带序号 | 中 |
| 218 | routine_maintenance.md | 412 | 三级标题 `### 5.2 高危操作一览表`，标题不应携带序号 | 中 |
| 219 | routine_maintenance.md | 444 | 二级标题 `## 6 日常运维`，标题不应携带序号 | 中 |
| 220 | routine_maintenance.md | 446 | 三级标题 `### 6.1 Docker信息查询`，标题不应携带序号 | 中 |
| 221 | routine_maintenance.md | 455 | 三级标题 `### 6.2 Android信息查询`，标题不应携带序号 | 中 |
| 222 | routine_maintenance.md | 469 | 三级标题 `### 6.3 服务器信息查询`，标题不应携带序号 | 中 |
| 223 | routine_maintenance.md | 507 | 二级标题 `## 7 参考信息`，标题不应携带序号 | 中 |
| 224 | routine_maintenance.md | 509 | 三级标题 `### 7.1 性能指标参考`，标题不应携带序号 | 中 |

## 三、 使用HTML表格问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | release_notes.md | 8-29 | 产品版本信息使用 `<table>` HTML 标签而非 Markdown 表格语法 | 高 |
| 2 | release_notes.md | 84-121 | 遗留问题使用 `<table>` HTML 标签而非 Markdown 表格语法 | 高 |

## 四、 图片路径问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | install_guide.md | 95 | 图片 `![](figures/内存插入格式.png)` 缺少 `./` 前缀，应为 `![](./figures/内存插入格式.png)` | 高 |
| 2 | install_guide.md | 105 | 图片 `![](figures/zh-cn_image_0000002518385460.png)` 缺少 `./` 前缀 | 高 |
| 3 | install_guide.md | 109 | 图片 `![](figures/BIOS-2-0.png)` 缺少 `./` 前缀 | 高 |
| 4 | install_guide.md | 117 | 图片 `![](figures/BIOS4.png)` 缺少 `./` 前缀 | 高 |
| 5 | install_guide.md | 121 | 图片 `![](figures/zh-cn_image_0000002518385458.png)` 缺少 `./` 前缀 | 高 |
| 6 | install_guide.md | 123 | 图片 `![](figures/zh-cn_image_0000002518225530.png)` 缺少 `./` 前缀 | 高 |
| 7 | install_guide.md | 133 | 图片 `![](figures/BIOS6.png)` 缺少 `./` 前缀 | 高 |
| 8 | install_guide.md | 135 | 图片 `![](figures/BIOS7.png)` 缺少 `./` 前缀 | 高 |
| 9 | install_guide.md | 147 | 图片 `![](figures/zh-cn_image_0000002549745299.png)` 缺少 `./` 前缀 | 高 |
| 10 | install_guide.md | 157 | 图片 `![](figures/zh-cn_image_0000002549745303.png)` 缺少 `./` 前缀 | 高 |
| 11 | install_guide.md | 194 | 图片 `![](figures/BIOS设置界面.png)` 缺少 `./` 前缀 | 高 |
| 12 | install_guide.md | 198 | 图片 `![](figures/BIOS-2-0-0.png)` 缺少 `./` 前缀 | 高 |
| 13 | install_guide.md | 206 | 图片 `![](figures/zh-cn_image_0000002549865321.png)` 缺少 `./` 前缀 | 高 |
| 14 | install_guide.md | 208 | 图片 `![](figures/zh-cn_image_0000002518225546.png)` 缺少 `./` 前缀 | 高 |
| 15 | install_guide.md | 210 | 图片 `![](figures/zh-cn_image_0000002549745317.png)` 缺少 `./` 前缀 | 高 |
| 16 | install_guide.md | 216 | 图片 `![](figures/zh-cn_image_0000002518225548.png)` 缺少 `./` 前缀 | 高 |
| 17 | install_guide.md | 228 | 图片 `![](figures/zh-cn_image_0000002549865323.png)` 缺少 `./` 前缀 | 高 |
| 18 | install_guide.md | 230 | 图片 `![](figures/zh-cn_image_0000002549745319.png)` 缺少 `./` 前缀 | 高 |
| 19 | install_guide.md | 599 | 图片 `![](figures/内核configure_load.png)` 缺少 `./` 前缀 | 高 |
| 20 | install_guide.md | 604 | 图片 `![](figures/zh-cn_image_0000002549865311.png)` 缺少 `./` 前缀 | 高 |
| 21 | install_guide.md | 657 | 图片 `![](figures/Snipaste_2023-08-14_15-01-18.jpg)` 缺少 `./` 前缀 | 高 |
| 22 | install_guide.md | 661 | 图片 `![](figures/Snipaste_2023-08-14_15-01-52.jpg)` 缺少 `./` 前缀 | 高 |
| 23 | install_guide.md | 665 | 图片 `![](figures/Snipaste_2023-08-14_15-02-39.jpg)` 缺少 `./` 前缀 | 高 |
| 24 | install_guide.md | 670 | 图片 `![](figures/内核configure_save.png)` 缺少 `./` 前缀 | 高 |
| 25 | install_guide.md | 673 | 图片 `![](figures/zh-cn_image_0000002549865307.png)` 缺少 `./` 前缀 | 高 |
| 26 | install_guide.md | 678 | 图片 `![](figures/zh-cn_image_0000002518225536.png)` 缺少 `./` 前缀 | 高 |
| 27 | install_guide.md | 681 | 图片 `![](figures/内核configure_exit.png)` 缺少 `./` 前缀 | 高 |
| 28 | install_guide.md | 810 | 图片 `![](figures/环境部署流程.png)` 缺少 `./` 前缀（该图片有 title 但缺少 `./`） | 高 |
| 29 | compile_guide.md | 121 | 图片 `![](figures/zh-cn_image_0000002518186270.png)` 缺少 `./` 前缀 | 高 |
| 30 | compile_guide.md | 130 | 图片 `![](figures/zh-cn_image_0000002518346190.png)` 缺少 `./` 前缀 | 高 |
| 31 | compile_guide.md | 138 | 图片 `![](figures/zh-cn_image_0000002549826041.png)` 缺少 `./` 前缀 | 高 |
| 32 | compile_guide.md | 140 | 图片 `![](figures/zh-cn_image_0000002518186272.png)` 缺少 `./` 前缀 | 高 |
| 33 | compile_guide.md | 142 | 图片 `![](figures/zh-cn_image_0000002518186272.png)` 缺少 `./` 前缀 | 高 |
| 34 | routine_maintenance.md | 72 | 图片 `![](figures/zh-cn_image_0000002549825431.png)` 缺少 `./` 前缀 | 高 |
| 35 | routine_maintenance.md | 90 | 图片 `![](figures/zh-cn_image_0000002549705419.png)` 缺少 `./` 前缀 | 高 |
| 36 | routine_maintenance.md | 110 | 图片 `![](figures/zh-cn_image_0000002518185658.png)` 缺少 `./` 前缀 | 高 |
| 37 | routine_maintenance.md | 120 | 图片 `![](figures/zh-cn_image_0000002518345562.png)` 缺少 `./` 前缀 | 高 |
| 38 | routine_maintenance.md | 158 | 图片 `![](figures/zh-cn_image_0000002518185698.png)` 缺少 `./` 前缀 | 高 |
| 39 | routine_maintenance.md | 186 | 图片 `![](figures/unnaming.png)` 缺少 `./` 前缀 | 高 |
| 40 | routine_maintenance.md | 200 | 图片 `![](figures/zh-cn_image_0000002549825411.png)` 缺少 `./` 前缀 | 高 |
| 41 | routine_maintenance.md | 298 | 图片 `![](figures/zh-cn_image_0000002549705371.png)` 缺少 `./` 前缀 | 高 |
| 42 | user_guide.md | 105 | 图片 `![](figures/zh-cn_image_0000002518385460.png)` 缺少 `./` 前缀 | 高 |

## 五、 内容问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | user_guide.md | 72 | `KBOX_GPU_MAP` 的说明文字"根据，renderD128节点属于NUMA0"中出现不完整语句，"根据"后面缺少内容 | 中 |
| 2 | user_guide.md | 73 | `KBOX_CPUSET_MAP` 的说明文字中出现同样的不完整语句"根据，renderD128~135属于NUMA0" | 中 |
| 3 | user_guide.md | 83 | 步骤2中 "必须再容器第一次启动时配置开/关C2解码器" 语句不通顺，"再"应为"在" | 中 |
| 4 | feature_guide.md | 243 | "本特性没有特别的应用场景限制" 缺少句号，与规范中"短语不加标点"的要求矛盾 | 低 |
| 5 | feature_guide.md | 436 | NFS应用场景描述"存算分离，存储复用等场景" 缺少句号 | 低 |
| 6 | user_guide.md | 742 | 4.2.4.1 VInput属性说明的表格后，重复出现了"本章节介绍VInput属性配置项说明内容。" 这句话 | 中 |
| 7 | release_notes.md | 52 | 病毒扫描结果表格的"扫描时间"列中"2025-12-12 08:00:00.0" 格式不规范，不应包含".0" | 低 |
| 8 | routine_maintenance.md | 492 | 说明内容中"当Host OS为openEuler 22.03时"，版本号为 22.03，但当前配套版本为 openEuler 24.03 LTS SP1 | 中 |
| 9 | best_practices.md | 整篇 | 最佳实践文档内容使用视频流云手机而非当前仓库的 Kbox 容器云手机方案 | 高 |
| 10 | user_guide.md | 321 | 1.7.3 校验是否生效标题后多了一个 "." | 低 |

## 六、 错误链接问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | release_notes.md | 141 | 链接指向 `https://gitcode.com/boostkit/Kbox/blob/AOSP15/docs/zh/menu.md`，指向 Kbox 仓库而非 Kbox-patches 仓库 | 高 |
| 2 | feature_guide.md | 222 | "支持线程级Shader Cache"章节链接指向 vmi 仓库 `https://gitcode.com/boostkit/vmi/blob/CloudPhone15/docs/zh/user_guide.md#312-图形加速层配置项`，该链接使用了 URL 编码的中文字符，可能导致跳转失败 | 中 |
| 3 | routine_maintenance.md | 206 | 链接 `https://gitcode.com/boostkit/Kbox/blob/AOSP15/docs/zh/install_guide.md#22-软件环境` 指向 Kbox 仓库而非 Kbox-patches 仓库，且锚点中使用了 URL 编码的中文字符 | 高 |
| 4 | best_practices.md | 17 | "根据《部署安装指南》文档"引用缺少明确链接，用户无法找到对应文档 | 中 |

## 七、 标点符号问题

| 序号 | 文件 | 行号 | 问题描述 | 严重程度 |
|------|------|------|----------|----------|
| 1 | feature_guide.md | 78 | 约束与限制内容"1、自适应帧同步功能打开时"使用了全角逗号"1、"，中文文档有序列表应使用"1." | 低 |
| 2 | feature_guide.md | 441-457 | NFS 安装特性多个步骤使用"1、""2、"格式，中文文档有序列表应使用"1." "2." | 低 |
| 3 | feature_guide.md | 492 | 客户端配置步骤使用"1、""2、"格式 | 低 |
| 4 | user_guide.md | 83 | "必须再容器第一次启动时" 中"再"应为"在" | 低 |
| 5 | routine_maintenance.md | 492 | 引用 openEuler 版本号 "22.03" 与当前配套版本 "24.03 LTS SP1" 不一致 | 中 |
