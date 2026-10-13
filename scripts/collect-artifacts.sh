#!/bin/bash
set -euo pipefail
# shellcheck source=scripts/load-target.sh
source "$GITHUB_WORKSPACE/scripts/load-target.sh"

SOURCE_DIR="$CI_ROOT/openwrt"
TARGET_BIN="$SOURCE_DIR/bin/targets/$TARGET_OUTPUT"
OUTPUT_DIR="$CI_ROOT/output"
mkdir -p "$OUTPUT_DIR"

case "$OUTPUT_KIND" in
    firmware)
        # 只上传目标目录中的文件，不包含 packages 子目录。
        find "$TARGET_BIN" -maxdepth 1 -type f \
            \( -name '*.bin' -o -name '*.img' -o -name '*.img.gz' -o -name '*.itb' \) \
            -print -quit | grep -q .
        find "$TARGET_BIN" -maxdepth 1 -type f -exec cp -t "$OUTPUT_DIR" -- {} +
        ;;
    lxc)
        cp "$TARGET_BIN/"*rootfs.tar.gz "$OUTPUT_DIR/"
        find "$TARGET_BIN" -maxdepth 1 -type f -name '*.buildinfo' -exec cp -t "$OUTPUT_DIR" -- {} +
        ;;
esac

cp "$SOURCE_DIR/.config" "$OUTPUT_DIR/build.config"
cp "$SOURCE_DIR/feeds.conf.default" "$OUTPUT_DIR/feeds.conf"
git -C "$SOURCE_DIR" rev-parse HEAD > "$OUTPUT_DIR/source-commit.txt"
{
    printf '构建目标：%s\n源码地址：%s\n源码分支：%s\n' "$TARGET_ID" "$REPO_URL" "$REPO_BRANCH"
    printf '源码提交：%s\n' "$(git -C "$SOURCE_DIR" rev-parse HEAD)"
    printf 'CI 提交：%s\n' "$GITHUB_SHA"
    printf '构建时间：%s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    for feed in "$SOURCE_DIR"/feeds/*; do
        if [[ -d "$feed/.git" || -f "$feed/.git" ]]; then
            printf 'feed %s：%s\n' "$(basename "$feed")" "$(git -C "$feed" rev-parse HEAD)"
        fi
    done
} > "$OUTPUT_DIR/build-info.txt"

cd "$OUTPUT_DIR"
find . -maxdepth 1 -type f ! -name 'SHA256SUMS' -printf '%P\0' \
    | sort -z | xargs -0 -r sha256sum > SHA256SUMS
ls -lh
