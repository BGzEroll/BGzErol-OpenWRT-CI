# 本地验证记录

## 首轮目录整理（历史记录）

验证时间：2026-10-13 21:27:29（北京时间）。

本次只验证最终保留的三个目标。未推送、未运行 GitHub Actions 的完整固件编译或附件上传，也未进行刷机和 PVE LXC 启动测试。

### 配置迁移

三个目标的 `targets/<目标>/config` 与整理前对应的 `config/*.config` 逐字节一致。源码地址及分支保持原值。LXC 定制额外明确启用原流程已要求的 `CONFIG_TARGET_ROOTFS_TARGZ=y`；所有构建禁用 ccache。

### 真实源码检查

使用临时浅克隆，在 Debian 13 主机上执行真实的 feeds 更新、安装、目标定制、`make defconfig` 和配置检查。x86 与 360 T7 共用相同源码及 feeds；两个目标分别展开配置。日志检查未发现 Kconfig 错误或循环依赖。

| 目标 | 源码提交 | 配置检查 |
| --- | --- | --- |
| immortalwrt-23_05-x86_64 | `8193c67d6c357a682af0b772374f6c2fbcb585b8` | 通过 |
| immortalwrt-23_05-360t7 | `8193c67d6c357a682af0b772374f6c2fbcb585b8` | 通过 |
| immortalwrt-25_12-x86_64-lxc | `ce35a9e4ef1b87fbbc2146036ce6693e4242861a` | 通过 |

LXC 同时检查 rootfs.tar.gz、Nikki、LuCI 和 mihomo-meta 的必需选项，确保 mihomo-alpha 未启用。

### 静态与主机回归

- actionlint 1.7.12：全部工作流通过。
- ShellCheck 0.11.0 和 `bash -n`：全部脚本及目标参数文件通过。
- 目标目录、公共工作流引用及已移除功能检查通过。
- `git diff --check` 通过。
- Ubuntu 24.04 官方 noble main/universe 包索引中可找到全部 68 项声明依赖；未在此主机安装 Ubuntu 依赖，也未据此宣称构建环境验证通过。
- 19 项临时主机回归通过：三个目标的附件与 SHA256、缺失/重复产物拒绝、LXC 必需配置、mihomo-alpha 与 ccache 拒绝、非法目标拒绝、下载/编译重试以及 Kconfig 错误日志拦截。

产物整理及重试回归使用模拟镜像和模拟 make，验证的是 CI 脚本行为，并非完整固件构建。

原始检查日志保存在本地忽略目录 `logs/validation/`。临时源码、feeds 和工具已清理，不作为后续构建缓存。

## 本轮代码精简

验证时间：2026-10-13 21:46:06（北京时间）。

本轮移除目标名、文件存在和必填参数的额外检查，取消通用目标配置校验、feeds 重复添加检查、空的 after-feeds 步骤、目标 files 覆盖及本地环境回退。三个目标明确填写参数，直接使用 Actions 环境变量。

保留命令失败停止、最终镜像存在检查、Kconfig 错误日志检查及 LXC 的 Nikki/mihomo-meta 检查；mihomo-alpha 安装链接移除继续保留。失败日志附件、版本信息和 SHA256 不变。

| 脚本 | 精简前行数 | 精简后行数 |
| --- | --- | --- |
| load-target.sh | 27 | 9 |
| configure-target.sh | 57 | 34 |
| collect-artifacts.sh | 60 | 43 |
| LXC hooks/verify.sh | 14 | 5 |
| 合计 | 158 | 91 |

### 本轮检查

- actionlint 1.7.12、ShellCheck 0.11.0、bash -n 和 git diff --check 通过。
- 三个固件 config 文件与当前提交逐字节一致。
- 15 项临时主机回归通过：三个目标的参数加载、feeds 和定制、附件和版本信息、SHA256；缺失镜像失败；多个 LXC rootfs 直接复制；缺失 Nikki 或 mihomo-meta 失败；LuCI/翻译包不再逐项检查；下载及编译重试成功/失败；Kconfig 报错/成功处理。
- 本轮使用模拟源码目录、模拟镜像及模拟 make 检查脚本行为，没有重新执行真实源码的 feeds、make defconfig 或完整固件编译。上面的真实源码检查属于首轮历史结果。

本轮回归输出保存在本地忽略目录 logs/validation/simplify-regression-result.txt。临时测试目录和下载工具已清理。未提交或推送本轮改动。

## 共用定制直接执行

验证时间：2026-10-13 22:00:42（北京时间）。

移除三个目标的 USE 字段及对应分支。所有目标直接添加 PassWall feeds、设置默认 LAN 地址并复制共用文件，LXC 仍另外添加 Nikki。三个固件 config 文件未修改。

- 三个目标的主机定制检查通过：PassWall feeds、192.168.114.1、Netdata 配置复制及原有包选择；LXC 的 Nikki、mihomo-alpha 链接移除和 rootfs 定制仍生效。
- LXC 使用真实源码 ce35a9e4ef1b87fbbc2146036ce6693e4242861a 完成 feeds 更新、安装和 make defconfig，没有 Kconfig 错误，Nikki、mihomo-meta 和 rootfs.tar.gz 选项正常，未选中 luci-app-passwall。
- actionlint、ShellCheck、bash -n 和 git diff --check 通过。

原始日志位于本地 logs/validation/，本轮临时源码与工具已清理。未进行完整固件编译或推送。

## UPnP 标准 feed 接入

UPnP 包目录移到仓库根目录，23.05 共用 feeds 首行加入 src-git --force custom_upnp；x86 和 360 T7 配置启用自维护的 nftables 与 LuCI 包。旧替换脚本及安装器移除。

本地 src-link 验证确认安装链接指向新目录，两个目标的 make defconfig 通过。额外执行了 23.05.4 x86 SDK 包编译并通过，未进行完整固件编译或上机测试。按用户要求，本轮编译产物及临时 SDK 全部清理；后续此类整理默认只做语法和引用检查，实际编译需明确要求。
