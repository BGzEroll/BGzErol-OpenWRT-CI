#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# 本文件基于 Actions-OpenWrt 的 diy-part1.sh，使用 MIT 许可证，详见 /LICENSE。
set -euo pipefail

# 在更新 feeds 前添加软件包与源。
cat >> feeds.conf.default <<'EOF'
src-git passwall_packages https://github.com/BGzEroll/openwrt-passwall-packages.git
src-git passwall_luci https://github.com/BGzEroll/openwrt-passwall.git
EOF
