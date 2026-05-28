# Android Physical Device Setup (Team)

Use this checklist before running the Flutter app on a real Android device.

## 1) Pull Latest Repo Changes

```powershell
git pull
```

## 2) Verify Required Flutter Version

Project baseline is Flutter `3.41.9`.

```powershell
flutter --version
```

## 3) Verify Android Toolchain

```powershell
flutter doctor -v
```

Confirm Android toolchain is healthy and licenses are accepted.

## 4) Check Disk Space (Important)

Keep at least `5-10 GB` free on `C:` to avoid Gradle/Kotlin download failures.

## 5) Clean + Install Dependencies

From project root:

```powershell
flutter clean
flutter pub get
flutter devices
```

## 6) Connect Physical Device

- Enable **Developer Options**
- Enable **USB Debugging**
- Connect by USB
- Accept the RSA authorization prompt on the phone

## 7) Run on Device

```powershell
flutter run -d <your_device_id>
```

Find `<your_device_id>` from `flutter devices`.

## If Build Fails

Share these outputs in team chat:

```powershell
flutter run -d <your_device_id> --verbose
flutter doctor -v
```

Also include:
- free disk space on `C:`
- exact Flutter version
- Android SDK path from `flutter doctor -v`
