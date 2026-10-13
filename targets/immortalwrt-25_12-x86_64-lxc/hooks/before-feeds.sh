#!/bin/bash
set -euo pipefail

# LXC 仅添加 Nikki，其他 feeds 使用 ImmortalWrt 源码自带配置。
if ! grep -q '^src-git nikki ' feeds.conf.default; then
    echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >> feeds.conf.default
fi
