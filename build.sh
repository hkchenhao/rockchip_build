#!/bin/bash -e

# Git 克隆单个分支
# git clone -b branch_name --single-branch repo_url

# Build boot loader
cd ../loader
./tools/boot_merger ./RKBOOT/RK3399MINIALL.ini
./tools/trust_merger ./RKTRUST/RK3399TRUST.ini
mv rk3399_loader_*.bin trust.img ../build/image
cd -

# Build uboot
cd ../uboot
make distclean
make CROSS_COMPILE=aarch64-none-linux-gnu- rk3399_defconfig
# make CROSS_COMPILE=aarch64-none-linux-gnu- menuconfig && make savedefconfig && mv defconfig ./configs/rk3399_defconfig
make CROSS_COMPILE=aarch64-none-linux-gnu- -j32
./../loader/tools/loaderimage --pack --uboot u-boot.bin uboot.img 0x200000 --size 2048 2
mv uboot.img ../build/image
cd -

# Build kernel(Ref: https://www.cnblogs.com/solo666/p/15953768.html https://blog.csdn.net/fhy00229390/article/details/112980643)
cd ../kernel
make distclean
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- rockchip_linux_defconfig
# make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- menuconfig && make ARCH=arm64 savedefconfig && mv defconfig arch/arm64/configs/rk3399_linux_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- rk3399-sapphire-excavator-linux.img -j32
cp boot.img ../build/image
cd -

# Download(UBoot 进入 Reload/Maskrom 模式命令: download(reboot loader) / rbrom)
./upgrade_tool ul ../image/rk3399_loader_v1.30.130.bin -noreset
./upgrade_tool di -p ../image/parameter.txt
./upgrade_tool di -u ../image/uboot.img && ./upgrade_tool rd
./upgrade_tool di -b ../image/boot.img && ./upgrade_tool rd
./upgrade_tool di -rootfs ../image/ubuntu-rootfs.img && ./upgrade_tool rd
