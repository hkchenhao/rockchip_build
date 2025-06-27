# Build Rockchip

## Clone
```shell
git clone https://github.com/rockchip-linux/rkbin loader -b master --single-branch --depth 1
git clone https://github.com/rockchip-linux/u-boot uboot -b next-dev --single-branch --depth 1
git clone https://github.com/rockchip-linux/kernel.git kernel -b develop-6.1 --single-branch --depth 1
```
## Download
```shell
# UBoot 进入 Reload/Maskrom 模式命令: download(reboot loader) / rbrom
./upgrade_tool ul ../image/loader.bin -noreset
./upgrade_tool di -p ../image/parameter.txt
./upgrade_tool di -u ../image/uboot.img && ./upgrade_tool rd
./upgrade_tool di -b ../image/kernel.img && ./upgrade_tool rd
./upgrade_tool di -rootfs ../image/ubuntu-rootfs.img && ./upgrade_tool rd
```