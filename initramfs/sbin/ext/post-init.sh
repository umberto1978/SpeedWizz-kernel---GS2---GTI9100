#!/sbin/busybox sh
# Logging
#/sbin/busybox cp /data/user.log /data/user.log.bak
#/sbin/busybox rm /data/user.log
#exec >>/data/user.log
#exec 2>&1

#if [ "$logger" == "on" ];then
#insmod /lib/modules/logger.ko
#fi

# disable debugging on some modules
#if [ "$logger" == "off" ];then
  rm -rf /dev/log
  echo 0 > /sys/module/ump/parameters/ump_debug_level
  echo 0 > /sys/module/mali/parameters/mali_debug_level
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys//module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
  echo 0 > /sys/module/alarm/parameters/debug_mask
  echo 0 > /sys/module/alarm_dev/parameters/debug_mask
  echo 0 > /sys/module/binder/parameters/debug_mask
  echo 0 > /sys/module/xt_qtaguid/parameters/debug_mask
#fi

# for init.d support
if [ -d /system/etc/init.d ]; then
        echo "init.d already exists";
else
	mount -o remount,rw /system;	
        mkdir /system/etc/init.d;
	chmod -R 755 /system/etc/init.d;
	mount -o remount,ro /system;
fi;

# for ntfs automounting
insmod /lib/modules/fuse.ko
mount -o remount,rw /
mkdir -p /mnt/ntfs
mount -t tmpfs tmpfs /mnt/ntfs
chmod 777 /mnt/ntfs
mount -o remount,ro /

/sbin/busybox sh /sbin/ext/properties.sh

/sbin/busybox sh /sbin/ext/install.sh

# run this because user may have chosen not to install root at boot but he may need it later and install it using ExTweaks
#/sbin/busybox sh /sbin/ext/su-helper.sh

##### Early-init phase tweaks #####
/sbin/busybox sh /sbin/ext/tweaks.sh

/sbin/busybox mount -t rootfs -o remount,ro rootfs

##### EFS Backup #####
(
# make sure that sdcard is mounted
sleep 30
/sbin/busybox sh /sbin/ext/efs-backup.sh
) &

sleep 12
#apply last soundgasm level on boot
#/res/uci.sh soundgasm_hp $soundgasm_hp

# apply ExTweaks defaults
#/res/uci.sh apply

#usb mode
#/res/customconfig/actions/usb-mode ${usb_mode}

##### init scripts #####
/sbin/busybox sh /sbin/ext/run-init-scripts.sh
