#!/bin/bash
# 工作流设置 TARGET_ID，此脚本供工作流和其他 CI 脚本 source。
# shellcheck disable=SC2034,SC2153
set -euo pipefail

CI_ROOT="$GITHUB_WORKSPACE"
TARGET_DIR="$CI_ROOT/targets/$TARGET_ID"
# shellcheck source=/dev/null
source "$TARGET_DIR/target.conf"
