#!/bin/bash
set -euo pipefail

# LXC 在共用 feeds 之外添加 Nikki。
echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >> feeds.conf.default
