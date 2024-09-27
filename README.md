# odroid-m1-archlinux
I had problems with running modern linux on my Odroid M1 device. Builds from Hardkernel were old and didn't work with my
bluetooth dongle, while others were showing only black screen and empty UART output. So, if you want something done, do it
yourself.

# Used sources
* u-boot
  * arm-trusted-firmware
  * rkbin
* ArchLinuxARM-aarch64
  
# Creating an image

### Ubuntu
```bash
apt install git sudo curl build-essential bison flex gcc-aarch64-linux-gnu gdisk uboot-tools
git clone https://github.com/lanseg/odroid-m1-archlinux.git
cd odroid-m1-archlinux
./build.sh
```

### ArchLinux
```bash
pacman -Sy python3 python-setuptools swig python-pyelftools curl git sudo gcc make aarch64-linux-gnu-gcc bison flex gdisk uboot-tools
git clone https://github.com/lanseg/odroid-m1-archlinux.git
cd odroid-m1-archlinux
./build.sh
```

