#!/bin/bash -e

cd ../../rootfs

# Var and func define
TARGET_ROOTFS_DIR="ubuntu-rootfs"

function Mount() {
    echo -e "\033[47;36m Monuting.................... \033[0m"
    sudo mount -t proc /proc ${TARGET_ROOTFS_DIR}/proc
    sudo mount -t sysfs /sys ${TARGET_ROOTFS_DIR}/sys
    sudo mount -o bind /dev ${TARGET_ROOTFS_DIR}/dev
    sudo mount -o bind /dev/pts ${TARGET_ROOTFS_DIR}/dev/pts
}

function UnMount() {
    echo -e "\033[47;36m UnMonuting.................... \033[0m"
    sudo umount ${TARGET_ROOTFS_DIR}/proc
    sudo umount ${TARGET_ROOTFS_DIR}/sys
    sudo umount ${TARGET_ROOTFS_DIR}/dev/pts
    sudo umount ${TARGET_ROOTFS_DIR}/dev
}

function UnMountWithExit() {
    UnMount
    echo -e "\033[47;36m Exit after unmonuting.................... \033[0m"
    exit -1
}

# Install necessary software
echo -e "\033[47;36m Install necessary software on host.................... \033[0m"
sudo apt install -y qemu-user-static binfmt-support
sudo update-binfmts --enable qemu-aarch64

# Init ubuntu rootfs
echo -e "\033[47;36m Init ubuntu rootfs.................... \033[0m"
if [ ! -d ${TARGET_ROOTFS_DIR} ] ; then
    sudo mkdir -p ${TARGET_ROOTFS_DIR}
    if [ ! -e /tmp/ubuntu-base-22.04.3-base-arm64.tar.gz ]; then
        echo -e "\033[47;36m Get ubuntu-base-22.04-base-x.tar.gz.................... \033[0m"
        wget -P /tmp -c http://cdimage.ubuntu.com/ubuntu-base/releases/22.04/release/ubuntu-base-22.04.3-base-arm64.tar.gz
    fi
    sudo tar -xzf /tmp/ubuntu-base-22.04.3-base-arm64.tar.gz -C ${TARGET_ROOTFS_DIR}
    sudo cp -b /etc/resolv.conf ${TARGET_ROOTFS_DIR}/etc/resolv.conf
		sudo cp -b /usr/bin/qemu-aarch64-static ${TARGET_ROOTFS_DIR}/usr/bin/
    sudo sed -i "s/ports.ubuntu.com/mirrors.ustc.edu.cn/g" ${TARGET_ROOTFS_DIR}/etc/apt/sources.list
fi

# Copy kernel modules
# find ./ -name "*.ko"
# sudo cp ../kernel/ /lib/modules/<kernel_version>/kernel/directory

# Copy overlay folder and set some software
# sudo cp -rpf overlay/* ${TARGET_ROOTFS_DIR}
# sudo cp -rf overlay-debug/* ${TARGET_ROOTFS_DIR}
# sudo cp -rpf overlay-firmware/* ${TARGET_ROOTFS_DIR}

# sudo mkdir -p ${TARGET_ROOTFS_DIR}/packages
# sudo cp -rpf overlay-packages/arm64/* ${TARGET_ROOTFS_DIR}/packages
# sudo mkdir -p ${TARGET_ROOTFS_DIR}/packages/install_packages
# sudo cp -rpf overlay-packages/arm64/libmali/libmali-midgard-t86x-r18p0-x11*.deb ${TARGET_ROOTFS_DIR}/packages/install_packages
# sudo cp -rpf overlay-packages/arm64/camera_engine/camera_engine_rkisp*.deb ${TARGET_ROOTFS_DIR}/packages/install_packages
# sudo cp -rpf overlay-packages/arm64/rga/*.deb ${TARGET_ROOTFS_DIR}/packages/install_packages

# sudo cp -f overlay-debug/usr/local/share/adb/adbd-64 ${TARGET_ROOTFS_DIR}/usr/bin/adbd
# sudo cp -f overlay/usr/lib/systemd/system/serial-getty@.service ${TARGET_ROOTFS_DIR}/lib/systemd/system/serial-getty@.service

# Mount
trap UnMountWithExit ERR
Mount

# Chroot
echo -e "\033[47;36m Change root.................... \033[0m"
cat <<EOF | sudo chroot $TARGET_ROOTFS_DIR/ /bin/bash

# [ubuntu-rootfs] Install software
echo -e "\033[47;36m [ubuntu-rootfs] Install software.................... \033[0m"
export APT_INSTALL="apt-get install -fy --allow-downgrades"
export LC_ALL=C.UTF-8

apt -y update && apt -f -y upgrade && apt autoremove
DEBIAN_FRONTEND=noninteractive apt install -y acpid apt-utils dialog evtest ntp rsyslog sudo
\${APT_INSTALL} bc cmake curl ethtool gdisk gpiod htop i2c-tools ifupdown inetutils-ping iperf3 \
                lrzsz net-tools netplan.io network-manager g++ gcc gdb openssh-server \
                parted python3-pip strace tcpdump u-boot-tools usbutils vim vsftpd wget xinput \
                libdrm-dev libdrm-tests libgpiod-dev libssl-dev

# echo -e "\033[47;36m apt install_packages.................... \033[0m"
# \${APT_INSTALL} /packages/install_packages/*.deb
# echo -e "\033[47;36m apt libdrm.................... \033[0m"
# \${APT_INSTALL} /packages/libdrm/*.deb
# echo -e "\033[47;36m apt rktoolkit.................... \033[0m"
# \${APT_INSTALL} /packages/rktoolkit/*.deb
# echo -e "\033[47;36m done.................... \033[0m"

# [ubuntu-rootfs] Create user
echo -e "\033[47;36m [ubuntu-rootfs] Create user.................... \033[0m"
useradd -G sudo -m -s /bin/bash cat
passwd cat <<IEOF
temppwd
temppwd
IEOF
gpasswd -a cat video
gpasswd -a cat audio
passwd root <<IEOF
root
root
IEOF

# [ubuntu-rootfs] Allow root login and Set hostname/localtime
echo -e "\033[47;36m [ubuntu-rootfs] Allow root login and Set hostname/localtime.................... \033[0m"
sed -i '/pam_securetty.so/s/^/# /g' /etc/pam.d/login
echo lubancat > /etc/hostname
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# [ubuntu-rootfs] Workaround 90s delay
services=(NetworkManager systemd-networkd)
for service in ${services[@]}; do
  systemctl mask ${service}-wait-online.service
done

# [ubuntu-rootfs] Set custom scripts
echo -e "\033[47;36m [ubuntu-rootfs] Set custom scripts.................... \033[0m"
# chmod +x /etc/rc.local
# chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper
systemctl mask wpa_supplicant-wired@
systemctl mask wpa_supplicant-nl80211@
systemctl mask wpa_supplicant@
# systemctl mask systemd-networkd-wait-online.service
# systemctl mask NetworkManager-wait-online.service
# rm /lib/systemd/system/wpa_supplicant@.service

# [ubuntu-rootfs] Clean and exit chroot
echo -e "\033[47;36m [ubuntu-rootfs] Clean and exit chroot.................... \033[0m"
if [ -e "/usr/lib/arm-linux-gnueabihf/dri" ] ; then
    cd /usr/lib/arm-linux-gnueabihf/dri/
    cp kms_swrast_dri.so swrast_dri.so /
    rm /usr/lib/arm-linux-gnueabihf/dri/*.so
    mv /*.so /usr/lib/arm-linux-gnueabihf/dri/
elif [ -e "/usr/lib/aarch64-linux-gnu/dri" ]; then
    cd /usr/lib/aarch64-linux-gnu/dri/
    cp kms_swrast_dri.so swrast_dri.so /
    rm /usr/lib/aarch64-linux-gnu/dri/*.so
    mv /*.so /usr/lib/aarch64-linux-gnu/dri/
    rm /etc/profile.d/qt.sh
fi
apt-get clean && rm -rf /var/lib/apt/lists/*
rm -rf /home/$(whoami) && rm -rf /var/cache/ && rm -rf /packages/
sync

EOF

# UnMount
UnMount

# Make image
echo -e "\033[47;36m Make image.................... \033[0m"
dd if=/dev/zero of=ubuntu-rootfs.img bs=1M count=4096
mkfs.ext4 ubuntu-rootfs.img

mkdir temp-rootfs
sudo mount ubuntu-rootfs.img temp-rootfs
sudo cp -rfp ubuntu-rootfs/* temp-rootfs
sudo umount temp-rootfs
sudo rm -fr temp-rootfs

e2fsck -p -f ubuntu-rootfs.img && resize2fs -M ubuntu-rootfs.img
mv ubuntu-rootfs.img ../build/image


cd -