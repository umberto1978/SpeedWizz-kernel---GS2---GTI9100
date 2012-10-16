#!/system/xbin/busybox sh
if [ -f /data/local/bootanimation.zip ] || [ -f /system/media/bootanimation.zip ]; then
  /vendor/bootanimation
else
  /system/bin/samsungani
fi;
