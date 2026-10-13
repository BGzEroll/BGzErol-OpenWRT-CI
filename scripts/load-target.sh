#!/bin/bash
# 此脚本供工作流和其他 CI 脚本 source。
# shellcheck disable=SC2034
set -euo pipefail

CI_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
: "${TARGET_ID:?请指定构建目标 TARGET_ID}"
if [[ ! "$TARGET_ID" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "错误：构建目标名称无效：$TARGET_ID" >&2
    exit 1
fi
TARGET_DIR="$CI_ROOT/targets/$TARGET_ID"
if [[ ! -f "$TARGET_DIR/target.conf" || ! -f "$TARGET_DIR/config" ]]; then
    echo "错误：构建目标缺少 target.conf 或 config：$TARGET_ID" >&2
    exit 1
fi

FEEDS_FILE=''
USE_PASSWALL=false
USE_DEFAULT_IP=false
USE_COMMON_FILES=false
# shellcheck source=/dev/null
source "$TARGET_DIR/target.conf"
: "${REPO_URL:?目标未配置源码地址}"
: "${REPO_BRANCH:?目标未配置源码分支}"
: "${TARGET_OUTPUT:?目标未配置产物目录}"
: "${OUTPUT_KIND:?目标未配置产物类型}"
