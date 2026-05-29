# KnoxPatch Cyber — SM-X910 (Tab S9 Ultra) OneUI 8.5 Port

Ported from [KnoxPatch-S23U-UI_8.5 by @CyberK1](https://t.me/cyberkuploads/2/1894).  
Original patches by [UN1CA ROM](https://github.com/salvogiangri/KnoxPatch).

## Device
- **Model**: SM-X910 (Galaxy Tab S9 Ultra Wi-Fi)
- **OneUI**: 8.5 (Android 16, SDK 36)
- **Build**: X910XXU6EZE3
- **Root**: KernelSU Next 3.2.0

## What's patched

| File | Change |
|---|---|
| `system/framework/framework.jar` | Added `KnoxPatchHooks` class (`io.mesalabs.unica`); patched `Instrumentation.newApplication()` to call `init()`; patched `SystemProperties.get()` to intercept property reads |
| `system/framework/knoxsdk.jar` | `EnterpriseDeviceManager.getAPILevel()` replaced with `KnoxPatchHooks.onEDMGetAPILevel()` — returns -1 for non-system apps |
| `system/framework/samsungkeystoreutils.jar` | `AttestParameterSpec.isVerifiableIntegrity()` always returns `true` |
| `system/framework/services.jar` | X910 stock (no Knox-specific changes needed) |
| `system/lib*/libhal.wsm.samsung.so` | Empty stub — disables hardware warranty bit reads |
| `system/lib*/vendor.samsung.hardware.security.wsm.service-V1-ndk.so` | Empty stub — disables WSM HAL service |

## KnoxPatchHooks logic
- `init(Context)`: Detects calling package, sets spoof flags
- `onEDMGetAPILevel()`: Returns -1 for non-system apps (hides Knox availability)
- `onSystemPropertiesGet(String)`:
  - `com.samsung.android.scpm` → `ro.build.type = "eng"`
  - FMM / Samsung Health / TV Plus → `ro.security.keystore.keytype = ""`

## Installation (KernelSU Next)
The `META-INF/update-binary` was updated to support both Magisk and KernelSU Next environments.

Flash via KSU Manager or:
```
ksud module install KnoxPatch-X910-UI_8.5.zip
```

## Porting notes
The S23U and X910 both run OneUI 8.5 (Android 16, SDK 36) so class counts are nearly identical (9224 classes in framework.jar). The smali patches are applied at the DEX level using apktool 3.0.1 baksmali/smali.

Patch locations:
- `Instrumentation.smali` (smali/android/app/) — lines after `attach()` calls
- `SystemProperties.smali` (smali_classes3/android/os/) — `get(String)` and `get(String,String)` methods
- `EnterpriseDeviceManager.smali` (smali/com/samsung/android/knox/) — `getAPILevel()` method
- `AttestParameterSpec.smali` (smali/com/samsung/android/security/keystore/) — `isVerifiableIntegrity()` method
- `KnoxPatchHooks.smali` added to `smali_classes6/io/mesalabs/unica/`
