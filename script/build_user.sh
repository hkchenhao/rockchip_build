#!/bin/bash -e

# Clone
git clone -b master --single-branch https://github.com/rockchip-linux/rkbin loader
git clone -b next-dev --single-branch https://github.com/rockchip-linux/u-boot uboot
git clone -b develop-5.10 --single-branch https://github.com/rockchip-linux/kernel kernel

# Download
# UBoot 进入 Reload/Maskrom 模式命令: download(reboot loader) / rbrom
./upgrade_tool ul ../image/loader.bin -noreset
./upgrade_tool di -p ../image/parameter.txt
./upgrade_tool di -u ../image/uboot.img && ./upgrade_tool rd
./upgrade_tool di -b ../image/kernel.img && ./upgrade_tool rd
./upgrade_tool di -rootfs ../image/ubuntu-rootfs.img && ./upgrade_tool rd