#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# 本文件基于 Actions-OpenWrt 的 diy-part2.sh，使用 MIT 许可证，详见 /LICENSE。
set -euo pipefail

# 保留现有的默认 LAN 地址。
sed -i 's/192.168.1.1/192.168.114.1/g' package/base-files/files/bin/config_generate
