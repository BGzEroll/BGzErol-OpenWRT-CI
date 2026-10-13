#!/bin/bash
set -euo pipefail

grep -qx 'CONFIG_PACKAGE_nikki=y' .config
grep -qx 'CONFIG_PACKAGE_mihomo-meta=y' .config
