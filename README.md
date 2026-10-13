# BGzErol OpenWrt CI

使用 GitHub Actions 构建个人定制的 OpenWrt / ImmortalWrt 固件。

保留三个独立构建入口，共用一套构建流程。仅通过 Actions 附件下载，不启用 SSH 调试、Release、网盘上传或构建缓存。

## 构建目标

| Actions 入口 | 源码仓库 | 源码分支 | 目标目录 | 主要产物 |
| --- | --- | --- | --- | --- |
| 构建 · ImmortalWrt 23.05 · x86_64 | [BGzEroll/immortalwrt](https://github.com/BGzEroll/immortalwrt) | `openwrt-23.05` | `immortalwrt-23_05-x86_64` | x86 固件镜像 |
| 构建 · ImmortalWrt 23.05 · 360 T7 | [BGzEroll/immortalwrt](https://github.com/BGzEroll/immortalwrt) | `openwrt-23.05` | `immortalwrt-23_05-360t7` | 360 T7 ubootmod 固件 |
| 构建 · ImmortalWrt 25.12 · x86_64 LXC | [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt) | `openwrt-25.12` | `immortalwrt-25_12-x86_64-lxc` | PVE LXC `rootfs.tar.gz` |

各目标每次获取对应分支的最新提交，具体提交及 feeds 版本记录在附件中。

## 手动构建与下载

1. 打开仓库的 **Actions** 页面。
2. 在左侧选择对应目标的中文构建入口。
3. 点击 **Run workflow**，选择本 CI 仓库的分支并运行。
4. 构建成功后，在运行页面底部的 **Artifacts** 下载附件，或点击构建摘要中的下载链接。

附件名称为 `<目标目录>-<运行序号>-<重跑次数>`，保留 **30 天**。下载需要登录 GitHub。LXC 附件里的 `rootfs.tar.gz` 是模板文件，外层 Actions ZIP 只是下载包装。

所有目标使用 `ubuntu-24.04`。每次浅克隆源码并重新下载、编译；没有 `actions/cache`，也禁用 OpenWrt 的 ccache。

同一目标、同一 CI 分支限制为一个运行中的构建，不自动取消正在运行的编译；不同目标可以并行。实际并发数受 GitHub 账号额度限制。

## 附件内容

普通固件附件保留目标输出目录中的文件，不包含 `packages/` 软件包目录；LXC 附件只保留 rootfs 和构建信息。

每份成功附件同时包含：

- `build.config`：`make defconfig` 展开后的完整配置。
- `feeds.conf`：本次使用的 feeds 地址与分支。
- `source-commit.txt`：固件源码提交。
- `build-info.txt`：构建目标、时间、CI 提交、源码和各 Git feed 提交。
- 源码生成的 `version.buildinfo`、`feeds.buildinfo`、`config.buildinfo`（如有）。
- `SHA256SUMS`：附件内文件的 SHA256 校验值。

解压后可以运行 `sha256sum -c SHA256SUMS` 检查完整性。编译失败时另外上传 `<目标目录>-logs-<运行序号>-<重跑次数>`，包含已有的阶段日志和构建配置。

## 目录说明

```text
.github/workflows/
  build-common.yml                       # 公共流程，不提供手动入口
  <原有目标工作流>.yml                    # 三个独立中文入口

targets/
  <目标目录>/
    target.conf                          # 源码、分支和产物路径
    config                               # 此目标的固件配置
    hooks/                               # 此目标的阶段定制（按需）

common/
  feeds/immortalwrt-23.05.conf             # x86 与 360 T7 共用的 feeds
  files/etc/netdata/netdata.conf          # 原有固件覆盖文件
  hooks/
    passwall-feeds.sh                     # 原有 PassWall feeds
    default-ip.sh                        # 默认 LAN 地址 192.168.114.1

scripts/
  load-target.sh                         # 读取目标参数
  prepare-env.sh                         # 准备 Ubuntu 构建环境
  configure-target.sh                    # 应用定制与检查配置
  collect-artifacts.sh                   # 整理产物和生成校验文件
```

## 修改目标配置

修改 `targets/<目标目录>/config` 调整软件包和镜像选项，修改 `target.conf` 调整源码地址、分支和产物路径。

`target.conf` 中的参数：

| 参数 | 用途 |
| --- | --- |
| `REPO_URL` / `REPO_BRANCH` | 固件源码仓库与分支 |
| `FEEDS_FILE` | 本 CI 仓库内的 feeds 配置路径；空字符串表示使用源码自带配置 |
| `TARGET_OUTPUT` | `openwrt/bin/targets/` 下的输出路径 |
| `OUTPUT_KIND` | 普通固件使用 `firmware`，LXC 使用 `lxc` |

所有目标直接添加 PassWall feeds、设置默认 LAN 地址 192.168.114.1 并复制 common/files，无需开关。LXC 另外添加 Nikki；实际编译哪些软件包仍由 config 决定。

三个目标明确配置以上参数，脚本直接读取，不额外校验名称或补充默认值。

### 目标定制脚本

脚本在对应目标的 `hooks/` 目录中按需创建，用 Bash 执行，工作目录始终是 OpenWrt 源码根目录：

| 脚本 | 执行时机 |
| --- | --- |
| `before-feeds.sh` | 共用 feeds 定制完成后、更新 feeds 前 |
| `config.sh` | 复制 `.config` 和定制文件后、`make defconfig` 前 |
| `verify.sh` | LXC 的 `make defconfig` 后，仅检查 Nikki 和 mihomo-meta |

LXC 专用脚本添加 Nikki、避免 mihomo-alpha/meta 循环依赖，并检查 Nikki 和 mihomo-meta。rootfs 由配置定制启用，整理产物时直接复制，缺文件则构建失败。

### UPnP feed

23.05 x86 和 360 T7 使用自维护的 [UPnP feed](https://github.com/BGzEroll/miniupnp)。仓库根目录包含 miniupnpd/ 和 luci-app-upnp/ 两个标准包目录。

common/feeds/immortalwrt-23.05.conf 的第一行是：

```text
src-git --force custom_upnp https://github.com/BGzEroll/miniupnp.git;master
```

自维护 feed 排在其他 feeds 前，优先提供同名包，--force 允许覆盖源码树中的同名核心包。现有 feeds update -a 和 feeds install -a 完成接入，CI 不调用 UPnP 仓库的安装脚本。

两个目标的 config 已选择 miniupnpd-nftables、luci-app-upnp 和 IPv6，禁用 iptables 变体及独立中文包；中文词典随自维护的 LuCI 包提供。LXC 25.12 继续使用源码自带 UPnP 包来源，不加入这个 23.05 定制 feed。

CI 脚本使用 `GITHUB_WORKSPACE` 和 `GITHUB_SHA`，按 Actions 的固定环境运行。feeds 定制每次全新构建执行一次，不提供重复追加检测。

## 外部触发

两个普通固件目标保留 `repository_dispatch`，收窄为独立事件类型，避免一次事件同时启动两套构建：

| 目标 | `event_type` |
| --- | --- |
| ImmortalWrt 23.05 x86_64 | `build-immortalwrt-23_05-x86_64` |
| 360 T7 | `build-immortalwrt-23_05-360t7` |

已有外部调用方需要改用表中的事件名；LXC 沿用手动触发。

## 验证

修改工作流后使用 `actionlint`，修改脚本后使用 `bash -n` 和 `shellcheck` 检查。脚本语法和本地配置检查不能替代 GitHub Actions 的完整固件编译，构建成功也不能替代设备刷机或 PVE LXC 启动验证。

本次整理的检查范围及结果见 [本地验证记录](docs/validation.md)。

## 致谢与许可证

本项目基于 [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)，感谢 OpenWrt、ImmortalWrt 和相关软件包维护者。

使用 [MIT 许可证](LICENSE)，保留原作者版权声明。
