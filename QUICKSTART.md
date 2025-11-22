# 🚀 Quick Start Guide

Get the StepSign Flutter app running in 5 minutes!

## ⚡ Prerequisites

Before you begin, ensure you have:
- ✅ Flutter SDK installed ([Install Flutter](https://flutter.dev/docs/get-started/install))
- ✅ Android Studio or VS Code with Flutter extension
- ✅ Android emulator or iOS simulator running

## 📦 Installation (3 Steps)

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Verify Setup
```bash
flutter doctor
```
Make sure all checkmarks are green (✓)

### Step 3: Run the App
```bash
flutter run
```

That's it! 🎉

## 🎯 What You'll See

The app will launch with the **onboarding flow**:

1. **Screen 1**: Welcome with smart insole features
2. **Screen 2**: Animated pressure heatmap visualization
3. **Screen 3**: AI gesture classification badges
4. **Screen 4**: Permission requests (tap to grant)

## 🎮 How to Use

### Navigation
- **Swipe left/right**: Navigate between screens
- **Tap "Continue"**: Go to next screen
- **Tap "Back"**: Return to previous screen (screens 1-2)

### Permissions Screen
- **Tap each permission card** to grant access
- **"Get Started" button** enables when all 3 permissions granted

## 🔧 Troubleshooting

### Issue: "flutter: command not found"
**Solution**: Install Flutter SDK and add to PATH
```bash
# Check Flutter installation
which flutter

# If not found, install from https://flutter.dev
```

### Issue: "No devices found"
**Solution**: Start an emulator or connect a physical device
```bash
# List available devices
flutter devices

# Start Android emulator
flutter emulators --launch <emulator_id>
```

### Issue: "Gradle build failed"
**Solution**: Accept Android licenses
```bash
flutter doctor --android-licenses
```

### Issue: "CocoaPods not installed" (iOS)
**Solution**: Install CocoaPods
```bash
sudo gem install cocoapods
cd ios && pod install
```

## 📱 Platform-Specific Commands

### Android
```bash
# Run on Android
flutter run -d android

# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle
```

### iOS
```bash
# Run on iOS
flutter run -d ios

# Build for iOS
flutter build ios
```

### Web (Preview Only)
```bash
# Run on web
flutter run -d chrome
```
⚠️ Note: Bluetooth features won't work on web

## 🎨 Customization

### Change Colors
Edit `lib/main.dart`:
```dart
colorScheme: ColorScheme.dark(
  primary: const Color(0xFF06B6D4), // Change this
  secondary: const Color(0xFFA855F7), // And this
),
```

### Modify Onboarding Content
Edit `lib/screens/onboarding_screen.dart`:
- `_buildWelcomePage()` - Screen 1
- `_buildVisualizationPage()` - Screen 2
- `_buildAIVerificationPage()` - Screen 3
- `_buildPermissionsPage()` - Screen 4

### Add Your Next Screen
After onboarding, navigate to your screen:
```dart
// In onboarding_screen.dart, _nextPage() method
if (_currentPage == 3 && _canProceed) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => YourScreen()),
  );
}
```

## 📚 Next Steps

1. ✅ **You are here**: Onboarding flow complete
2. 📱 **Add Pairing Screen**: BLE device discovery
3. 📊 **Add Dashboard**: Daily stats and live preview
4. 🎯 **Add Live Session**: Real-time sensor monitoring

## 🆘 Need Help?

### Documentation
- 📖 [FLUTTER_README.md](FLUTTER_README.md) - Full setup guide
- 🎨 [DESIGN_COMPARISON.md](DESIGN_COMPARISON.md) - Design details
- 💻 [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) - Technical guide

### Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

### Community
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev)

## ✅ Checklist

Before moving to production:
- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Add app icons
- [ ] Add splash screen
- [ ] Configure app signing
- [ ] Test permissions on real devices
- [ ] Optimize performance
- [ ] Add error handling
- [ ] Add analytics
- [ ] Write tests

## 🎉 Success!

If you see the onboarding screens with smooth animations and can navigate through all 4 pages, you're all set! 

**Happy coding!** 🚀

---

**Questions?** Open an issue or check the documentation files.

