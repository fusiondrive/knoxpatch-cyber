#!/system/bin/sh
# KnoxPatch S20U - Manual bind mount for KernelSU Next Meta mount
MODDIR=${0%/*}

# Bind mount patched services.jar
mount --bind "$MODDIR/system/framework/services.jar" /system/framework/services.jar

# Bind mount patched samsungkeystoreutils.jar
mount --bind "$MODDIR/system/framework/samsungkeystoreutils.jar" /system/framework/samsungkeystoreutils.jar

# Nullify WSM HAL shared libraries
[ -f /system/lib/libhal.wsm.samsung.so ] && mount --bind "$MODDIR/system/lib/libhal.wsm.samsung.so" /system/lib/libhal.wsm.samsung.so
[ -f /system/lib64/libhal.wsm.samsung.so ] && mount --bind "$MODDIR/system/lib64/libhal.wsm.samsung.so" /system/lib64/libhal.wsm.samsung.so
[ -f /system/lib/vendor.samsung.hardware.security.wsm.service-V1-ndk.so ] && mount --bind "$MODDIR/system/lib/vendor.samsung.hardware.security.wsm.service-V1-ndk.so" /system/lib/vendor.samsung.hardware.security.wsm.service-V1-ndk.so
[ -f /system/lib64/vendor.samsung.hardware.security.wsm.service-V1-ndk.so ] && mount --bind "$MODDIR/system/lib64/vendor.samsung.hardware.security.wsm.service-V1-ndk.so" /system/lib64/vendor.samsung.hardware.security.wsm.service-V1-ndk.so
