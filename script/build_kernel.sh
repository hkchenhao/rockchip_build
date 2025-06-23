#!/bin/bash -e

# Ref: https://www.cnblogs.com/solo666/p/15953768.html https://blog.csdn.net/fhy00229390/article/details/112980643)
cd ../../kernel
# make distclean
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- rockchip_linux_defconfig
# make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- menuconfig
# make ARCH=arm64 savedefconfig && mv defconfig arch/arm64/configs/rk3399_linux_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- rk3399-eaidk-610.img -j32
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=../build/image
mv boot.img ../build/image/kernel.img
cd -