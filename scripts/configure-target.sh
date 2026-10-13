#!/bin/bash
set -euo pipefail
# shellcheck source=scripts/load-target.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/load-target.sh"
cd "$CI_ROOT/openwrt"

case "${1:-}" in
    before-feeds)
        if [[ -n "$FEEDS_FILE" ]]; then
            cp "$CI_ROOT/$FEEDS_FILE" feeds.conf.default
        fi
        if [[ "$USE_PASSWALL" == true ]]; then
            bash "$CI_ROOT/common/hooks/passwall-feeds.sh"
        fi
        ;;
    after-feeds)
        # 可选 after-feeds.sh 在 feeds 更新后、安装前运行。
        ;;
    config)
        if [[ "$USE_COMMON_FILES" == true ]]; then
            mkdir -p files
            cp -a "$CI_ROOT/common/files/." files/
        fi
        if [[ -d "$TARGET_DIR/files" ]]; then
            mkdir -p files
            cp -a "$TARGET_DIR/files/." files/
        fi
        cp "$TARGET_DIR/config" .config
        # 每次从头构建，不启用 OpenWrt 编译缓存。
        sed -i '/^CONFIG_CCACHE=/d; /^# CONFIG_CCACHE is not set$/d' .config
        echo '# CONFIG_CCACHE is not set' >> .config
        if [[ "$USE_DEFAULT_IP" == true ]]; then
            bash "$CI_ROOT/common/hooks/default-ip.sh"
        fi
        ;;
    verify)
        while IFS= read -r symbol; do
            if ! grep -qxF "$symbol" .config; then
                echo "错误：展开后的配置缺少目标选项：$symbol" >&2
                exit 1
            fi
        done < <(sed -n '/^CONFIG_TARGET_.*=y$/p' "$TARGET_DIR/config")
        if grep -qx 'CONFIG_CCACHE=y' .config; then
            echo '错误：构建配置启用了 ccache' >&2
            exit 1
        fi
        ;;
    *)
        echo '用法：configure-target.sh {before-feeds|after-feeds|config|verify}' >&2
        exit 1
        ;;
esac

# 目标专用定制只在对应阶段运行，工作目录始终是固件源码根目录。
if [[ -f "$TARGET_DIR/hooks/$1.sh" ]]; then
    bash "$TARGET_DIR/hooks/$1.sh"
fi
