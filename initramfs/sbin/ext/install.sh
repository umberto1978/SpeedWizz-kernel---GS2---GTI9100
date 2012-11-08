#!/sbin/busybox sh

BB="/sbin/busybox";

extract_payload()
{
	payload_extracted=1;
  	$BB chmod 755 /sbin/read_boot_headers;
  	eval $(/sbin/read_boot_headers /dev/block/mmcblk0p5);
  	load_offset=$boot_offset;
  	load_len=$boot_len;
  	cd /;
  	dd bs=512 if=/dev/block/mmcblk0p5 skip=$load_offset count=$load_len | tar x;
}

. /res/customconfig/customconfig-helper;
read_defaults;
read_config;

$BB mount -o remount,rw /system;
$BB mount -t rootfs -o remount,rw rootfs;
payload_extracted=0;

cd /;

# if [ "$install_root" == "on" ]; then
	if [ -s /system/xbin/su ]; then
		echo "Superuser already exists";
	else
		if [ "$payload_extracted" == "0" ]; then
			extract_payload;
		fi;

		# clean su traces
		$BB rm -f /system/bin/su > /dev/null 2>&1;
		$BB rm -f /system/xbin/su > /dev/null 2>&1;
		$BB mkdir /system/xbin > /dev/null 2>&1;
		$BB chmod 755 /system/xbin;

		# extract SU binary
		$BB xzcat /res/misc/payload/su.xz > /system/xbin/su;
		$BB chown 0.0 /system/xbin/su;
		$BB chmod 6755 /system/xbin/su;

		# clean super user old apps
		$BB rm -f /system/app/*uper?ser.apk > /dev/null 2>&1;
		$BB rm -f /system/app/?uper?u.apk > /dev/null 2>&1;
		$BB rm -f /system/app/*chainfire?supersu*.apk > /dev/null 2>&1;
		$BB rm -f /data/app/*uper?ser.apk > /dev/null 2>&1;
		$BB rm -f /data/app/?uper?u.apk > /dev/null 2>&1;
		$BB rm -f /data/app/*chainfire?supersu*.apk > /dev/null 2>&1;
		$BB rm -rf /data/dalvik-cache/*uper?ser.apk* > /dev/null 2>&1;
		$BB rm -rf /data/dalvik-cache/*chainfire?supersu*.apk* > /dev/null 2>&1;

		# extract super user app
		$BB xzcat /res/misc/payload/Superuser.apk.xz > /system/app/Superuser.apk;
		$BB chown 0.0 /system/app/Superuser.apk;
		$BB chmod 644 /system/app/Superuser.apk;

		# restore witch if exist
		if [ -e /system/xbin/waswhich-bkp ]; then
			$BB rm -f /system/xbin/which > /dev/null 2>&1;
			$BB cp /system/xbin/waswhich-bkp /system/xbin/which > /dev/null 2>&1;
			$BB chmod 755 /system/xbin/which > /dev/null 2>&1;
		fi;

		if [ -e /system/xbin/boxman ]; then
			$BB rm -f /system/xbin/busybox > /dev/null 2>&1;
			$BB mv /system/xbin/boxman /system/xbin/busybox > /dev/null 2>&1;
			$BB chmod 755 /system/xbin/busybox > /dev/null 2>&1;
			$BB mv /system/bin/boxman /system/bin/busybox > /dev/null 2>&1;
			$BB chmod 755 /system/bin/busybox > /dev/null 2>&1;
		fi;

		# delete payload and kill superuser pid
		$BB rm -rf /res/misc/payload;
		pkill -f "com.noshufou.android.su" > /dev/null 2>&1;
	fi;
#fi;


# liblights install by force to allow BLN
if [ ! -e /system/lib/hw/lights.exynos4.so.BAK ]; then
	$BB mv /system/lib/hw/lights.exynos4.so /system/lib/hw/lights.exynos4.so.BAK;
fi;
echo "Copying liblights";
$BB cp -a /res/misc/lights.exynos4.so /system/lib/hw/lights.exynos4.so;
$BB chown root:root /system/lib/hw/lights.exynos4.so;
$BB chmod 644 /system/lib/hw/lights.exynos4.so;

if [ ! -s /system/xbin/ntfs-3g ]; then
	if [ "$payload_extracted" == "0" ]; then
		extract_payload;
  	fi;
		$BB xzcat /res/misc/payload/ntfs-3g.xz > /system/xbin/ntfs-3g;
		$BB chown 0.0 /system/xbin/ntfs-3g;
		$BB chmod 755 /system/xbin/ntfs-3g;
fi;

echo "Checking if cwmanager is installed"
if [ ! -f /system/.speedwizz/cwmmanager3-installed ];
then
  if [ "$payload_extracted" == "0" ]; then
    extract_payload;
  fi;
  $BB rm /system/app/CWMManager.apk;
  $BB rm /data/dalvik-cache/*CWMManager.apk*;
  $BB rm /data/app/eu.chainfire.cfroot.cwmmanager*.apk;

  $BB xzcat /res/misc/payload/CWMManager.apk.xz > /system/app/CWMManager.apk;
  $BB chown 0.0 /system/app/CWMManager.apk;
  $BB chmod 644 /system/app/CWMManager.apk;
  $BB mkdir /system/.speedwizz;
  $BB chmod 755 /system/.speedwizz;
  echo 1 > /system/.speedwizz/cwmmanager3-installed
fi;

echo "Checking if NSTools is installed"
if [ ! -f /system/.speedwizzapp/NSTools-installed ];
then
  if [ "$payload_extracted" == "0" ]; then
    extract_payload;
  fi;
  $BB rm /system/app/*nstools*.apk;
  $BB rm /data/dalvik-cache/*mobi.cyann.nstools-1.apk*;
  $BB rm /data/app/mobi.cyann.nstools*.apk;

  $BB xzcat /res/misc/payload/mobi.cyann.nstools-1.apk.xz > /system/app/mobi.cyann.nstools-1.apk;
  $BB chown 0.0 /system/app/mobi.cyann.nstools-1.apk;
  $BB chmod 644 /system/app/mobi.cyann.nstools-1.apk;
  $BB mkdir /system/.speedwizzapp;
  $BB chmod 755 /system/.speedwizzapp;
  echo 1 > /system/.speedwizzapp/NSTools-installed
fi;

$BB rm -rf /res/misc/payload;


$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
