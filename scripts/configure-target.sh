#!/bin/bash
set -euo pipefail
# shellcheck source=scripts/load-target.sh
source "$GITHUB_WORKSPACE/scripts/load-target.sh"
cd "$CI_ROOT/openwrt"

case "$1" in
    before-feeds)
        if [[ -n "$FEEDS_FILE" ]]; then
            cp "$CI_ROOT/$FEEDS_FILE" feeds.conf.default
        fi
        bash "$CI_ROOT/common/hooks/passwall-feeds.sh"
        ;;
    config)
        mkdir -p files
        cp -a "$CI_ROOT/common/files/." files/
        cp "$TARGET_DIR/config" .config
        # 每次从头构建，不启用 OpenWrt 编译缓存。
        sed -i '/^CONFIG_CCACHE=/d; /^# CONFIG_CCACHE is not set$/d' .config
        echo '# CONFIG_CCACHE is not set' >> .config
        bash "$CI_ROOT/common/hooks/default-ip.sh"
        ;;
esac

# 目标专用定制只在对应阶段运行，工作目录始终是固件源码根目录。
if [[ -f "$TARGET_DIR/hooks/$1.sh" ]]; then
    bash "$TARGET_DIR/hooks/$1.sh"
fi
