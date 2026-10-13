# 本地整理验证记录

验证时间：2026-10-13 21:27:29（北京时间）。

本次只验证最终保留的三个目标。未推送、未运行 GitHub Actions 的完整固件编译或附件上传，也未进行刷机和 PVE LXC 启动测试。

## 配置迁移

三个目标的 `targets/<目标>/config` 与整理前对应的 `config/*.config` 逐字节一致。源码地址及分支保持原值。LXC 定制额外明确启用原流程已要求的 `CONFIG_TARGET_ROOTFS_TARGZ=y`；所有构建禁用 ccache。

## 真实源码检查

使用临时浅克隆，在 Debian 13 主机上执行真实的 feeds 更新、安装、目标定制、`make defconfig` 和配置检查。x86 与 360 T7 共用相同源码及 feeds；两个目标分别展开配置。日志检查未发现 Kconfig 错误或循环依赖。

| 目标 | 源码提交 | 配置检查 |
| --- | --- | --- |
| immortalwrt-23_05-x86_64 | `8193c67d6c357a682af0b772374f6c2fbcb585b8` | 通过 |
| immortalwrt-23_05-360t7 | `8193c67d6c357a682af0b772374f6c2fbcb585b8` | 通过 |
| immortalwrt-25_12-x86_64-lxc | `ce35a9e4ef1b87fbbc2146036ce6693e4242861a` | 通过 |

LXC 同时检查 rootfs.tar.gz、Nikki、LuCI 和 mihomo-meta 的必需选项，确保 mihomo-alpha 未启用。

## 静态与主机回归

- actionlint 1.7.12：全部工作流通过。
- ShellCheck 0.11.0 和 `bash -n`：全部脚本及目标参数文件通过。
- 目标目录、公共工作流引用及已移除功能检查通过。
- `git diff --check` 通过。
- Ubuntu 24.04 官方 noble main/universe 包索引中可找到全部 68 项声明依赖；未在此主机安装 Ubuntu 依赖，也未据此宣称构建环境验证通过。
- 19 项临时主机回归通过：三个目标的附件与 SHA256、缺失/重复产物拒绝、LXC 必需配置、mihomo-alpha 与 ccache 拒绝、非法目标拒绝、下载/编译重试以及 Kconfig 错误日志拦截。

产物整理及重试回归使用模拟镜像和模拟 make，验证的是 CI 脚本行为，并非完整固件构建。

原始检查日志保存在本地忽略目录 `logs/validation/`。临时源码、feeds 和工具已清理，不作为后续构建缓存。
