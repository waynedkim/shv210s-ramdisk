#!/bin/sh

###
# Boot image automation tool
#
# author: Wayne (Dojung) Kim (dojung.kim@live.com)
# last edited by: wdk, 24/JUL/2014
###

PWD=$(pwd)
KERNEL_PATH="${PWD}/../shv210s-kernel"
ZIMAGE="${KERNEL_PATH}/arch/arm/boot/zImage"
MKBOOTIMG="${PWD}/mkbootimg/mkbootimg"
RAMDISK="${PWD}/ramdisk.img"
BOOTIMAGE="${PWD}/boot.img"
NO_RAMDISK_COMPRESS=0

for ARG in $@
do
	if [ "x${ARG}" = "x-kernel" ]; then
		NO_RAMDISK_COMPRESS=1
	fi
done


if [ ${NO_RAMDISK_COMPRESS} -eq 0 ]; then

	echo "Copying kernel modules ..."
	find ${KERNEL_PATH}/drivers/ -name "*.ko" -exec cp -v {} ./ramfs_factory/lib/modules/ \;

	echo "Compressing ramdisk image ..."
	./touch_ramfs.sh pack ${RAMDISK}
fi

${MKBOOTIMG}	--kernel ${ZIMAGE} \
		--ramdisk ${RAMDISK} \
		--cmdline "" \
		--board smdk4x12 \
		--base 0x10000000 \
		--ramdiskaddr 0x11000000 \
		--pagesize 2048 \
		--output ${BOOTIMAGE}
