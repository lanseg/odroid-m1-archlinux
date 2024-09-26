#!/bin/bash
set -euo pipefail
source ./settings

imageName="linux.img"

cd uboot 
./build.sh 
cd ..

cd archlinux
./build.sh
cd ..

if [ ! -f "$imageName" ]
then
    echo "Creating an empty image file: $imageName"
    dd if=/dev/zero of=linux.img bs=16M count=512 status=progress
fi

sudo losetup -P -f ./linux.img
loopDevice="` losetup | grep $PWD/linux.img | cut -d" " -f1 `"

echo $loopDevice
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo gdisk "$loopDevice"
    # Create u-boot partition
    n
    1
    2048
    16M

    # Create boot partition
    n
    2
          # default, start immediately after
    +128M  # For fernel, initrd and boot script

    # Create root partition
    n
    3
    # default, start immediately after
    # default, to the end of the disk
    
    # Set UUIDs
    x
    c
    2
    $BOOT_UUID
    c
    2
    $ROOT_UUID
    w
    Y
EOF
sudo mkfs.ext2 "${loopDevice}p2"
sudo mkfs.ext4 "${loopDevice}p3"
sudo dd if=uboot/u-boot/u-boot.bin of="${loopDevice}p1" status=progress

mkdir -p root
sudo mount "${loopDevice}p3" root
sudo mkdir -p root/boot
sudo mount "${loopDevice}p2" root/boot
sudo cp -prfv archlinux/root/* root/

sudo umount root/boot
sudo umount root
sudo losetup -d $loopDevice

