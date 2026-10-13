#!/bin/bash
set -euo pipefail

# 可选定制：在 feeds 更新后、安装前，从 OpenWrt 源码根目录调用。
# 默认目标不启用此脚本，也不改变现有 UPnP 包选择。
UPNP_REPO='https://github.com/BGzEroll/miniupnp.git'
UPNP_BRANCH='master'
UPNP_SOURCE="$(mktemp -d)"
trap 'rm -rf "$UPNP_SOURCE"' EXIT

git clone --depth 1 --single-branch --branch "$UPNP_BRANCH" "$UPNP_REPO" "$UPNP_SOURCE"
bash "$UPNP_SOURCE/scripts/install-to-openwrt.sh" --packages-only "$PWD"
