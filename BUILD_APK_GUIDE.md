# 🚀 How to Build Flutter APK

## ✅ Option 1: Download from GitHub Actions (EASIEST - Already Running!)

Your APK is **building automatically** right now on GitHub!

### Steps:
1. **Go to**: https://github.com/alwinsdon/stepsign-app/actions
2. **Click** on the latest workflow run (should be running now)
3. **Wait** ~5-10 minutes for build to complete
4. **Scroll down** to "Artifacts" section
5. **Download**: `android-apk` (will be a .zip file)
6. **Extract** the .zip file
7. **Install** the APK on your Android device

**That's it! No Flutter installation needed!** ✅

---

## Option 2: Build Locally (Requires Flutter SDK)

### Prerequisites:
- Flutter SDK installed
- Android Studio or Android SDK
- Java JDK

### Quick Build:

```bash
# Navigate to project
cd "C:\Users\alwin\Downloads\StepSign Mobile App Design (1)"

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Detailed Steps:

#### 1. Install Flutter SDK (if not installed)
```bash
# Download from: https://flutter.dev/docs/get-started/install/windows
# Or use winget:
winget install --id=Google.Flutter -e
```

#### 2. Install Android Studio
- Download: https://developer.android.com/studio
- Install Android SDK
- Accept licenses:
```bash
flutter doctor --android-licenses
```

#### 3. Verify Setup
```bash
flutter doctor
```
Should show:
- ✅ Flutter
- ✅ Android toolchain
- ✅ Android Studio

#### 4. Get Dependencies
```bash
cd "C:\Users\alwin\Downloads\StepSign Mobile App Design (1)"
flutter pub get
```

#### 5. Build APK
```bash
# Release APK (smaller, optimized)
flutter build apk --release

# Debug APK (larger, with debugging)
flutter build apk --debug

# Split APKs by architecture (smaller per device)
flutter build apk --split-per-abi
```

#### 6. Find Your APK
```
📁 build/app/outputs/flutter-apk/
   ├── app-release.apk          (Universal - works on all devices)
   ├── app-armeabi-v7a-release.apk  (32-bit ARM)
   ├── app-arm64-v8a-release.apk    (64-bit ARM - most modern phones)
   └── app-x86_64-release.apk       (64-bit Intel - emulators)
```

---

## 📱 Install APK on Android Device

### Method 1: USB Cable
1. Enable **Developer Options** on your phone:
   - Settings → About Phone → Tap "Build Number" 7 times
2. Enable **USB Debugging**:
   - Settings → Developer Options → USB Debugging
3. Connect phone to computer
4. Run:
```bash
flutter install
# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Method 2: Direct Install
1. Copy APK to your phone (via USB, email, cloud, etc.)
2. On phone, open the APK file
3. Allow "Install from Unknown Sources" if prompted
4. Click "Install"

---

## 🔧 Build Options

### Release APK (Recommended for distribution)
```bash
flutter build apk --release
```
- ✅ Optimized and minified
- ✅ Smaller size (~20-40 MB)
- ✅ Better performance
- ❌ No debugging

### Debug APK (For testing)
```bash
flutter build apk --debug
```
- ✅ Includes debugging symbols
- ✅ Hot reload support
- ❌ Larger size (~50-80 MB)
- ❌ Slower performance

### Profile APK (For performance testing)
```bash
flutter build apk --profile
```
- ✅ Performance profiling enabled
- ✅ Some optimizations
- ✅ DevTools support

### Split APKs (Smallest size per device)
```bash
flutter build apk --split-per-abi
```
Creates separate APKs for each CPU architecture:
- `app-armeabi-v7a-release.apk` (~15 MB) - Older phones
- `app-arm64-v8a-release.apk` (~18 MB) - Modern phones
- `app-x86_64-release.apk` (~20 MB) - Emulators

---

## 📊 APK Size Optimization

### Reduce APK Size:
```bash
# Enable code shrinking
flutter build apk --release --shrink

# Split by ABI
flutter build apk --split-per-abi

# Obfuscate code
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

### Expected Sizes:
- **Universal APK**: ~25-35 MB
- **Split APK (arm64)**: ~18-22 MB
- **With obfuscation**: ~15-20 MB

---

## 🐛 Troubleshooting

### Error: "Flutter SDK not found"
```bash
# Add Flutter to PATH
$env:Path += ";C:\path\to\flutter\bin"
```

### Error: "Android SDK not found"
```bash
# Install Android Studio
# Then run:
flutter doctor --android-licenses
```

### Error: "Gradle build failed"
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### Error: "Execution failed for task ':app:lintVitalRelease'"
```bash
# Disable lint checks (add to android/app/build.gradle)
android {
    lintOptions {
        checkReleaseBuilds false
    }
}
```

### Error: "Out of memory"
```bash
# Increase Gradle memory (android/gradle.properties)
org.gradle.jvmargs=-Xmx4096m
```

---

## 🚀 Quick Commands Summary

```bash
# Install dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Build and install on connected device
flutter install

# Build split APKs (smaller)
flutter build apk --split-per-abi

# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Check what's installed
flutter devices

# Clean build
flutter clean && flutter pub get && flutter build apk --release
```

---

## 📦 Build Output Locations

```
Project Root
└── build/
    └── app/
        └── outputs/
            └── flutter-apk/
                ├── app-release.apk              ← Universal APK
                ├── app-armeabi-v7a-release.apk  ← 32-bit ARM
                ├── app-arm64-v8a-release.apk    ← 64-bit ARM (most phones)
                └── app-x86_64-release.apk       ← Intel (emulators)
```

---

## 🎯 Recommended Build Command

For distribution:
```bash
flutter build apk --release --split-per-abi
```

This creates the smallest APKs for each device type!

---

## ✅ Next Steps After Building

1. **Test APK** on real device
2. **Sign APK** for Play Store (if publishing)
3. **Upload to GitHub Releases** (optional)
4. **Share with users**

---

## 🔗 Useful Links

- **Flutter Build Docs**: https://docs.flutter.dev/deployment/android
- **Android Studio**: https://developer.android.com/studio
- **Flutter SDK**: https://flutter.dev/docs/get-started/install

---

**Easiest Way**: Just download from GitHub Actions! ✅
**No Flutter installation needed!** 🎉

