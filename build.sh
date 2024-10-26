#!/bin/bash
set -uo pipefail
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
    dd if=/dev/zero of=linux.img bs=16M count=255 status=progress
fi

sudo losetup -P -f ./linux.img
loopDevice="` losetup | grep $PWD/linux.img | cut -d" " -f1 `"

echo "Attached future image to $loopDevice"
sed -e 's/\s*\([-\-\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo gdisk "$loopDevice"
    # Create u-boot partition
    n
    1
    2048
    16M

    # Create boot partition
    n
    2
          # default, start immediately after
    +512M  # For fernel, initrd and boot script

    # Create root partition
    n
    3
    # default, start immediately after
    # default, to the end of the disk
    
    # Set names and UUIDs
    c
    1
    uboot
    x
    c
    2
    ${BOOT_UUID}
    c
    3
    ${ROOT_UUID}
    w
    Y
EOF
echo "Formatting ext2 on boot partition (${loopDevice}p2)"
sudo mkfs.ext2 "${loopDevice}p2"
sudo tune2fs -U $BOOT_UUID "${loopDevice}p2"
echo "UUID is `sudo blkid ${loopDevice}p2` (expected $BOOT_UUID)"

echo "Formatting ext4 on root partition (${loopDevice}p3)" 
sudo mkfs.ext4 "${loopDevice}p3"
sudo tune2fs -U $ROOT_UUID "${loopDevice}p3"
echo "UUID is `sudo blkid ${loopDevice}p3` (expected $ROOT_UUID)"
echo "Writing uboot to the uboot partition ${loopDevice}p1"
sudo dd if=uboot/u-boot/u-boot.bin of="${loopDevice}p1" status=progress

echo "Copying linux files to the image"
mkdir -p root
sudo mount "${loopDevice}p3" root
sudo mkdir -p root/boot
sudo mount "${loopDevice}p2" root/boot
sudo cp -prf archlinux/root/* root/

echo "Unmounting folders and detaching $loopDevice"
sudo umount root/boot
sudo umount root
sudo losetup -d $loopDevice

