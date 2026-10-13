#!/bin/bash
set -euo pipefail

for symbol in TARGET_ROOTFS_TARGZ PACKAGE_nikki PACKAGE_luci-app-nikki \
    PACKAGE_luci-i18n-nikki-zh-cn PACKAGE_mihomo-meta; do
    if ! grep -qxF "CONFIG_$symbol=y" .config; then
        echo "错误：LXC 配置缺少 CONFIG_$symbol=y" >&2
        exit 1
    fi
done
if grep -qx 'CONFIG_PACKAGE_mihomo-alpha=y' .config; then
    echo '错误：LXC 镜像不得选择 mihomo-alpha' >&2
    exit 1
fi
