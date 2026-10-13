#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo '释放构建磁盘空间'
sudo rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc /opt/hostedtoolcache/CodeQL
sudo docker image prune --all --force || true

echo '安装 Ubuntu 24.04 构建依赖'
sudo -E apt-get update
sudo -E apt-get install -y --no-install-recommends \
    antlr3 asciidoc autoconf automake autopoint \
    binutils bison build-essential bzip2 clang cmake cpio curl \
    device-tree-compiler ecj fastjar flex gawk gettext \
    gcc-multilib g++-multilib genisoimage git gperf help2man intltool \
    libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp-dev \
    libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libnsl-dev \
    libpython3-dev libreadline-dev libssl-dev libtool libyaml-dev \
    lld llvm ninja-build p7zip-full patch pkgconf \
    python3 python3-docutils python3-ply python3-pyelftools python3-setuptools \
    qemu-utils re2c rsync scons squashfs-tools subversion swig \
    texinfo uglifyjs unzip wget xmlto xxd xz-utils zlib1g-dev zstd
sudo apt-get clean
sudo mkdir -p /workdir
sudo chown "$USER":"$(id -gn)" /workdir
df -hT
