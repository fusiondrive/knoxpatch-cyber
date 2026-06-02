# KnoxPatch Cyber — SM-G988N (S20 Ultra) OneUI 8.0 Port

Ported from [KnoxPatch-S23U-UI_8.5 by @CyberK1](https://t.me/cyberkuploads/2/1894).
Original patches by [UN1CA ROM](https://github.com/salvogiangri/KnoxPatch).

## Device

- **Model**: SM-G988N (Galaxy S20 Ultra Korean)
- **ROM**: [Astro-OS](https://t.me/astro_os) 3.0.7-Diamond (z3q codename, based on S918BXXS9EZCI Exynos firmware ported to kona/SM8250)
- **OneUI**: 8.0 (80000) / Android 16 / SDK 36
- **Root**: KernelSU Next v3.1.0

## What's patched

| File | Change |
|---|---|
| `system/framework/services.jar` | `com.android.server.knox.dar.IntegrityStatus` constructor made no-op — always returns warranty=0 (Normal), trustBoot=0, icd=0, kernelStatus=0, systemStatus=0 |
| `system/framework/samsungkeystoreutils.jar` | From original S23U module — `AttestParameterSpec.isVerifiableIntegrity()` always returns `true`, exposes public attestKey/attestDevice APIs |
| `system/lib*/libhal.wsm.samsung.so` | Empty stub — disables hardware warranty bit reads from WSM HAL |
| `system/lib*/vendor.samsung.hardware.security.wsm.service-V1-ndk.so` | Empty stub — disables WSM HAL service |
| `system/priv-app/KmxService/KmxService.apk` | Knox Matrix Extended Service (not present on device by default) |

## What's NOT replaced (Astro-OS already handles it)

| File | Reason |
|---|---|
| `framework.jar` | Astro-OS already contains `io.mesalabs.unica.SamsungPropsHooks` which hooks `onEDMGetAPILevelHook()` → returns 38, spoofs `ro.boot.verifiedbootstate`, `ro.build.type`, `ro.boot.warranty_bit` |
| `knoxsdk.jar` | Device's knoxsdk.jar already calls `SamsungPropsHooks.onEDMGetAPILevelHook()` — no replacement needed |

## KernelSU Next compatibility note

KernelSU Next v3.1.0 uses a **"Meta" mount system** that does **not** automatically overlay individual files from modules (unlike Magisk's magic mount / overlayfs). This module includes a `post-fs-data.sh` that manually bind-mounts each patched file over its `/system` counterpart before system_server starts.

```sh
# Uses toybox mount --bind syntax (not -o bind)
mount --bind "$MODDIR/system/framework/services.jar" /system/framework/services.jar
```

## Installation

Flash via KernelSU Next module manager or:
```
ksud module install KnoxPatch-S20U-UI_8.0.zip
```

## Verified working

After reboot:
- `ro.boot.warranty_bit = 0` (Normal)
- `ro.boot.verifiedbootstate = green` (spoofed by Astro-OS)
- `ro.build.type = user` (spoofed by Astro-OS)
- `/system/framework/services.jar` bind-mounted from patched version

## Porting notes

Astro-OS is a custom ROM based on S23U Exynos firmware ported to the S20U (z3q/kona) hardware. It already ships Knox hooks in its `framework.jar` via `io.mesalabs.unica.SamsungPropsHooks`, so the S23U module's `framework.jar` and `knoxsdk.jar` replacements are unnecessary and would break the ROM.

The key difference from stock S23U Knox bypass:
- Stock Knox bypass: inject `KnoxPatchHooks` into `framework.jar` to add Knox spoofing
- Astro-OS: `SamsungPropsHooks` already present in ROM's `framework.jar`; only `services.jar`'s `IntegrityStatus` needs patching

Patch method: `apktool 3.0.1` baksmali → edit `IntegrityStatus.smali` → `apktool` smali → `d8` from Android SDK 36 build-tools to convert class files back to DEX.
