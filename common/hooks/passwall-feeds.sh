#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# 本文件基于 Actions-OpenWrt 的 diy-part1.sh，使用 MIT 许可证，详见 /LICENSE。
set -euo pipefail

# 在更新 feeds 前添加现有的 PassWall 软件包与 LuCI 源。
if ! grep -q '^src-git passwall_packages ' feeds.conf.default; then
    echo 'src-git passwall_packages https://github.com/BGzEroll/openwrt-passwall-packages.git' >> feeds.conf.default
fi
if ! grep -q '^src-git passwall_luci ' feeds.conf.default; then
    echo 'src-git passwall_luci https://github.com/BGzEroll/openwrt-passwall.git' >> feeds.conf.default
fi
