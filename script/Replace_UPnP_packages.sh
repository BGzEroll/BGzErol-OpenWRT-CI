#!/bin/bash
set -eu

# 修改为你的 UPnP 仓库地址和分支
UPNP_REPO='https://github.com/BGzEroll/miniupnp.git'
UPNP_BRANCH='master'

cd "$GITHUB_WORKSPACE/openwrt"

mkdir -p tmp
git clone --depth 1 --branch "$UPNP_BRANCH" \
    "$UPNP_REPO" tmp/custom-upnp-source

bash tmp/custom-upnp-source/scripts/install-to-openwrt.sh \
    --packages-only "$PWD"
