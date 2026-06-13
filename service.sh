#!/system/bin/sh

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

sleep 5

fix_qq_media_perms() {
    cmd appops set com.tencent.mobileqq WRITE_MEDIA_IMAGES allow 2>/dev/null
    cmd appops set com.tencent.mobileqq WRITE_MEDIA_VIDEO allow 2>/dev/null
    cmd appops set com.tencent.mobileqq WRITE_MEDIA_AUDIO allow 2>/dev/null

    # MANAGE_EXTERNAL_STORAGE cannot be set via appops command on this device,
    # so patch access.abx directly if the entry is missing
    local ABX="/data/misc_de/0/apexdata/com.android.permission/access.abx"
    local TMP="/data/local/tmp/qq_access_fix.xml"
    abx2xml "$ABX" "$TMP" 2>/dev/null || return
    if ! grep -q 'android:manage_external_storage' "$TMP"; then
        sed -i 's|name="android:request_install_packages"|name="android:manage_external_storage" mode="0" /><app-op name="android:request_install_packages"|' "$TMP"
        xml2abx "$TMP" "$ABX" 2>/dev/null
        cp "$ABX" "${ABX}.reservecopy" 2>/dev/null
    fi
    rm -f "$TMP"
}

fix_qq_media_perms

# Re-fix immediately when Knox resets permissions after a QQ update
logcat -s PermissionService | while read line; do
    case "$line" in
        *setAllowlistedRestrictedPermissionsUnchecked*mobileqq*)
            sleep 2
            fix_qq_media_perms
            ;;
    esac
done &
