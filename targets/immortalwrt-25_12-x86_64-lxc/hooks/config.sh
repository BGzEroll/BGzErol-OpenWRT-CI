#!/bin/bash
set -euo pipefail

# 固定使用稳定版 mihomo-meta，避免与 mihomo-alpha 的 Kconfig 循环依赖。
rm -f package/feeds/nikki/mihomo-alpha
rm -rf tmp

# 明确要求生成 PVE LXC 使用的 rootfs.tar.gz。
echo 'CONFIG_TARGET_ROOTFS_TARGZ=y' >> .config
