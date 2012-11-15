#!/bin/sh

if [ -e zImage ]; then
rm zImage
fi

rm compile.log

# Set Default Path
TOP_DIR=$PWD
KERNEL_PATH="/home/umberto/Scrivania/speedwizzkernel_2.0_update7/kernel"

# Set toolchain and root filesystem path
#TOOLCHAIN="/home/simone/arm-2009q3/bin/arm-none-linux-gnueabi-"
TOOLCHAIN="/home/umberto/Scrivania/speedwizzkernel_2.0_update7/android-toolchain-eabi/bin/arm-eabi-"
#TOOLCHAIN="/home/simone/android/system/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin/arm-eabi-"
INITRAMFS_SOURCE="/home/umberto/Scrivania/speedwizzkernel_2.0_update7/kernel/initramfs"

export KERNELDIR=$KERNEL_PATH
export INITRAMFS_SOURCE=$INITRAMFS_SOURCE
export PARENT_DIR=`readlink -f ..`
export USE_SEC_FIPS_MODE=true

make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` mrproper

if [ "${1}" != "" ];then
  export KERNELDIR=`readlink -f ${1}`
fi

INITRAMFS_TMP="/tmp/initramfs-source"

if [ ! -f $KERNELDIR/.config ];
then
  make speedwizz_defconfig
fi

. $KERNELDIR/.config

export ARCH=arm
export CROSS_COMPILE=$TOOLCHAIN

cd $KERNELDIR/
nice -n 10 make -j2 >> compile.log 2>&1 || exit 1

#remove previous initramfs files
rm -rf $INITRAMFS_TMP
rm -rf $INITRAMFS_TMP.cpio
#copy initramfs files to tmp directory
cp -ax $INITRAMFS_SOURCE $INITRAMFS_TMP
#clear git repositories in initramfs
find $INITRAMFS_TMP -name ".git*" -exec rm -rf {} \;
#remove empty directory placeholders
find $INITRAMFS_TMP -name EMPTY_DIRECTORY -exec rm -rf {} \;
rm -rf $INITRAMFS_TMP/tmp/*
#remove mercurial repository
rm -rf $INITRAMFS_TMP/.hg
#copy modules into initramfs
mkdir -p $INITRAMFS/lib/modules
find -name '*.ko' -exec cp -av {} $INITRAMFS_TMP/lib/modules/ \;
chmod 644 $INITRAMFS_TMP/lib/modules/*
${CROSS_COMPILE}strip --strip-unneeded $INITRAMFS_TMP/lib/modules/*

nice -n 10 make -j2 zImage CONFIG_INITRAMFS_SOURCE="$INITRAMFS_TMP" || exit 1

#cp $KERNELDIR/arch/arm/boot/zImage zImage
$KERNELDIR/mkshbootimg.py $KERNELDIR/zImage $KERNELDIR/arch/arm/boot/zImage $KERNELDIR/payload.tar $KERNELDIR/recovery.tar.xz

