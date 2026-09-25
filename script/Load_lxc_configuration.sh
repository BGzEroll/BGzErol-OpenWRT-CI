#!/bin/bash
set -euo pipefail

# Nikki 同时提供 mihomo-meta 和 mihomo-alpha。
#
# 在 ImmortalWrt 25.12 下，两者的 PROVIDES/CONFLICTS 会导致：
#
#   PACKAGE_mihomo-alpha depends on PACKAGE_mihomo-meta
#   PACKAGE_mihomo-meta depends on PACKAGE_mihomo-alpha
#
# 本镜像固定使用稳定版 mihomo-meta，因此从 package feed 中
# 移除 mihomo-alpha 的 symlink。
rm -f package/feeds/nikki/mihomo-alpha

# 删除已经生成的 Kconfig/package metadata，
# 让后面的 make defconfig 重新生成。
rm -rf tmp
