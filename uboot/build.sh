#!/bin/bash
set -euo pipefail

export PLAT=3568
export CROSS_COMPILE="aarch64-linux-gnu-"
export ARCH="arm64"

# Fetching
if [ ! -d u-boot ]
then
    git clone https://github.com/u-boot/u-boot.git
fi

if [ ! -d rkbin ]
then
    git clone https://github.com/rockchip-linux/rkbin.git
fi

if [ ! -d arm-trusted-firmware ]
then
  git clone https://github.com/ARM-software/arm-trusted-firmware.git
fi

# Building
echo "Building ATF (ARM trusted firmware)"
cd arm-trusted-firmware && cd ..

echo "Building uboot"
cd u-boot
make \
  BL31=`pwd`/arm-trusted-firmware/build/rk3568/release/bl31/bl31.elf \
  ROCKCHIP_TPL=`pwd`/rkbin/bin/rk35/rk3568_ddr_1560MHz_v1.21.bin \
  odroid-m1-rk3568_defconfig all
