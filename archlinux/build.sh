#!/bin/bash
set -euo pipefail
source ../settings

distArchive="ArchLinuxARM-aarch64-latest.tar.gz"

mkdir -p downloads
if [ ! -f "downloads/$distArchive" ]
then
    curl -L "http://os.archlinuxarm.org/os/$distArchive" -o "downloads/$distArchive"
fi

if [ ! -d "root" ]
then
  mkdir -p root
  echo "Extracting 'downloads/$distArchive' to root/"
  sudo bsdtar -xpf "downloads/$distArchive" -C root/
fi

echo "Updating fstab"
cat fstab | \
    sed "s/###ROOT_UUID###/$ROOT_UUID/g" | \
    sed "s/###BOOT_UUID###/$BOOT_UUID/g" | \
    sudo bash -c "cat > root/etc/fstab"

echo "Updating boot.txt"
cat boot.txt | \
    sed "s/###ROOT_UUID###/$ROOT_UUID/g" | \
    sed "s/###BOOT_UUID###/$BOOT_UUID/g" | \
    sudo bash -c "cat > root/boot/boot.txt"

sudo mkimage -A arm -O linux -T script -C none -n "U-Boot boot script" -d root/boot/boot.txt root/boot/boot.scr



