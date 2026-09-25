#!/bin/bash
set -euo pipefail

# PVE/LXC 专用构建只额外加入 Nikki。
# 不复用现有的 PassWall feed 配置。
if ! grep -q '^src-git nikki ' feeds.conf.default; then
    echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >> feeds.conf.default
fi
