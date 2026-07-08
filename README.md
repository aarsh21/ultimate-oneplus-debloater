# Ultimate OnePlus / OxygenOS Debloater

A cautious-but-powerful ADB debloat script for OnePlus/Oppo/OxygenOS devices.

It removes regular bloat automatically, then asks before touching critical apps like Phone/SMS, Health/Fitbit, Android Setup, SIM Toolkit/Airtel Services, accessibility apps, and dark/blur tweaks.

> Tested workflow target: OxygenOS 16 / Android 16 OnePlus device. Use at your own risk on other builds.

## What this does

The script uses standard non-root ADB commands:

```bash
pm uninstall -k --user 0 <package>
```

That means apps are removed only for the current Android user, not deleted from the system partition. A restore script is generated every run.

If a package is protected and refuses uninstall, the script tries:

```bash
pm disable-user --user 0 <package>
pm suspend --user 0 <package>
```

## What is kept by default

The Google apps below are intentionally protected:

- Chrome
- Google app / Search / Discover news
- Gmail
- YouTube
- Maps
- Play Store
- Play Services
- Google Services Framework
- Gboard
- Android System WebView

## Regular bloat removed

The regular pass targets common OnePlus/Oppo/HeyTap/ColorOS/Google bloat such as:

- OnePlus/Oppo AI features: AI Writer, Mind Space, AI Service/AI Unit, prediction services
- Global Search / Quick Search
- Theme Store / App Market / Instant Apps framework
- HeyTap Cloud / Browser / Pictorial
- Weather, Compass, Smart Sidebar, Omoji, Games, Children Space
- Android Auto, Wallet, Google Photos, Google Files, Lens, Safety Hub, Digital Wellbeing
- Facebook/Meta preload
- Netflix and LinkedIn preload if present

## Critical prompts

Unless you use `--yolo`, the script asks before:

- Removing OnePlus stock apps like Clock, Gallery, File Manager, Recorder, Clone Phone, Zen Space
- Removing optional Google apps/services like Gemini, Google Home, Docs, Meet, YouTube Music, ARCore, telemetry/ad services
- Removing default Phone and Messages UIs
- Removing Fitbit while keeping Health Connect
- Disabling Android Setup / Setup Wizard
- Hiding Airtel Services / SIM Toolkit
- Removing accessibility extras like TalkBack
- Applying AMOLED-ish dark mode and OxygenOS blur-disable tweaks

## YOLO mode

`--yolo` does all aggressive actions from the reference debloat session without prompts:

```bash
./debloat.sh --yolo
```

This includes:

- aggressive OnePlus/Oppo bloat removal
- all OnePlus AI/prediction services
- optional Google apps/services while keeping Chrome/Google/Gmail/YouTube/Maps
- default Phone and Messages removal
- Fitbit removal
- Android Setup disabled after marking setup complete
- Airtel/SIM Toolkit hidden
- Live Caption icon hidden from the volume panel
- AMOLED-ish dark mode + blur-disable flags

**Warning:** YOLO can leave you without a Phone/SMS UI if you did not install replacements.

## Install / run

1. Enable Developer Options on the phone.
2. Enable USB debugging.
3. Install Android platform-tools (`adb`).
4. Connect the phone and accept the RSA prompt.
5. Run:

```bash
git clone https://github.com/aarsh21/ultimate-oneplus-debloater.git
cd ultimate-oneplus-debloater
chmod +x debloat.sh
./debloat.sh
```

Dry run first:

```bash
./debloat.sh --dry-run
```

Skip only the first regular confirmation, but still ask critical questions:

```bash
./debloat.sh --yes
```

Full aggressive run:

```bash
./debloat.sh --yolo
```

## Restore

Every run creates a restore script in `./logs`, for example:

```bash
./logs/restore_20260709_021500.sh
```

Run it with the phone connected:

```bash
bash ./logs/restore_YYYYMMDD_HHMMSS.sh
```

You can also restore a single package manually:

```bash
adb shell cmd package install-existing --user 0 com.package.name
adb shell pm enable --user 0 com.package.name
adb shell pm unsuspend --user 0 com.package.name
```

## Notes and caveats

- Some OxygenOS packages cannot be uninstalled without root. The script will disable/suspend them when possible.
- True pitch-black Quick Settings is usually hardcoded in OxygenOS SystemUI. The script can disable known blur/material flags, but it may not make QS fully AMOLED black without root or a custom overlay.
- Disabling SIM Toolkit hides Airtel Services; it should not break calls, SMS, or mobile data.
- Disabling Android Setup is done only after setting `user_setup_complete=1` and `device_provisioned=1`.
- Do not remove accessibility packages if you rely on TalkBack, Switch Access, or similar services.

## License

MIT
