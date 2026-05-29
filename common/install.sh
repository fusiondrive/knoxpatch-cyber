VARIANTS="CyberK_S24X CyberK_S23X CyberK_S22X CyberK_S21X CyberK_S20X"

TARGET_SYSTEM=""
STATUS=""

for module in $VARIANTS; do
    if [ -d "/data/adb/modules_update/$module" ]; then
        TARGET_SYSTEM="/data/adb/modules_update/$module/system"
        STATUS="update"
        break
    fi
done

if [ -z "$TARGET_SYSTEM" ]; then
    for module in $VARIANTS; do
        if [ -d "/data/adb/modules/$module" ]; then
            TARGET_SYSTEM="/data/adb/modules/$module/system"
            STATUS="normal"
            break
        fi
    done
fi

if [ "$STATUS" = "update" ]; then
    ui_print "Updated Ultimate module detected"
elif [ "$STATUS" = "normal" ]; then
    ui_print "Ultimate module detected"
else
    ui_print "Ultimate module not found, using default installation..."
fi

if [ -n "$TARGET_SYSTEM" ] && [ -d "$MODPATH/system" ]; then
    mkdir -p "$TARGET_SYSTEM"
    cp -af "$MODPATH/system/." "$TARGET_SYSTEM/"
    rm -rf "$MODPATH/system"
fi
