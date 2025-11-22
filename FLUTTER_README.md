# StepSign Mobile App - Flutter Implementation

This is a Flutter conversion of the StepSign Mobile App Design from the Figma prototype at https://evil-liquid-61259634.figma.site

## 🎯 Features Implemented

### Onboarding Flow (4 Screens)
1. **Welcome Screen** - Introduction to smart insole features
   - 4 FSR Pressure Sensors
   - 6-Axis IMU + Magnetometer
   - Haptic Feedback Motor
   - ESP32 BLE Low Energy

2. **Real-time Visualization** - Live pressure heatmap preview
   - Animated insole heatmap with gradient pressure points
   - Color-coded legend (Low/Medium/High)

3. **AI-Powered Verification** - Gesture classification badges
   - Walking, Running, Jumping, Standing, Stairs detection
   - Anti-cheat detection warning

4. **Permissions Screen** - Interactive permission requests
   - Bluetooth permission
   - Physical Activity permission
   - Notifications permission

## 🎨 Design System

### Colors
- **Primary Gradient**: Cyan (#06B6D4) → Purple (#A855F7)
- **Background**: Dark slate (#0F172A, #1E293B)
- **Accent Colors**:
  - Cyan: #06B6D4
  - Purple: #A855F7
  - Pink: #EC4899
  - Blue: #3B82F6
  - Orange: #F97316
  - Yellow: #EAB308

### Typography
- Font: Roboto (system default)
- Headings: Bold (28px)
- Body: Regular (16px)
- Subtitles: 14px

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   └── onboarding_screen.dart        # Main onboarding flow with 4 pages
└── widgets/
    ├── gradient_button.dart          # Reusable gradient button
    ├── feature_card.dart             # Feature list card
    ├── permission_card.dart          # Permission request card
    └── heatmap_preview.dart          # Animated pressure heatmap
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS: Xcode (for iOS development)
- Android: Android SDK

### Installation

1. **Install Flutter dependencies**:
```bash
flutter pub get
```

2. **Run the app**:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

3. **Build for production**:
```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios
```

## 📦 Dependencies

- **flutter**: SDK
- **smooth_page_indicator**: ^1.1.0 - Page indicator dots
- **provider**: ^6.1.1 - State management
- **permission_handler**: ^11.0.1 - Permission requests
- **flutter_blue_plus**: ^1.31.0 - Bluetooth connectivity
- **fl_chart**: ^0.65.0 - Charts and data visualization
- **lucide_icons**: ^0.263.0 - Icon library

## 🎯 Key Features

### 1. Gradient Backgrounds
All screens feature a beautiful dark gradient background matching the Figma design:
- Top: #0F172A (Slate 950)
- Middle: #1E293B (Slate 900)
- Bottom: #0F172A (Slate 950)

### 2. Animated Heatmap
The pressure heatmap on screen 2 features:
- Real-time animated pressure points
- Smooth gradient interpolation
- Insole-shaped outline
- 4 sensor locations (Heel, Arch, Ball, Toes)

### 3. Interactive Permissions
Screen 4 allows users to grant permissions with:
- Visual feedback on tap
- Checkmark indicators
- Disabled "Get Started" button until all permissions granted

### 4. Smooth Page Transitions
- Swipe gestures to navigate between pages
- Animated page indicator
- Forward/Back navigation buttons

## 🔧 Customization

### Changing Colors
Edit the color constants in `lib/main.dart`:
```dart
colorScheme: ColorScheme.dark(
  primary: const Color(0xFF06B6D4), // Cyan
  secondary: const Color(0xFFA855F7), // Purple
  // ...
),
```

### Modifying Onboarding Content
Edit the page builders in `lib/screens/onboarding_screen.dart`:
- `_buildWelcomePage()` - Screen 1
- `_buildVisualizationPage()` - Screen 2
- `_buildAIVerificationPage()` - Screen 3
- `_buildPermissionsPage()` - Screen 4

### Adding More Screens
After onboarding completion, navigate to your next screen:
```dart
if (_currentPage == 3 && _canProceed) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => YourNextScreen()),
  );
}
```

## 📱 Platform-Specific Setup

### Android
Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

### iOS
Add permissions to `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>We need Bluetooth to connect to your smart insoles</string>
<key>NSMotionUsageDescription</key>
<string>We need activity tracking to monitor your steps</string>
<key>NSUserNotificationsUsageDescription</key>
<string>We need notifications to send you goal alerts</string>
```

## 🎨 Design Fidelity

This Flutter implementation closely matches the Figma design:
- ✅ Exact color palette (cyan-purple gradient theme)
- ✅ Matching typography and spacing
- ✅ Animated heatmap visualization
- ✅ Interactive permission cards
- ✅ Smooth page transitions
- ✅ Gradient buttons with icons
- ✅ Feature cards with colored dots
- ✅ Page indicator dots

## 🚧 Future Enhancements

To complete the full app, you'll need to add:
1. **Pairing Screen** - BLE device discovery and connection
2. **Dashboard** - Daily stats and live preview
3. **Live Session** - Real-time sensor monitoring
4. **Analytics** - Historical data and graphs
5. **3D Viewer** - IMU orientation visualization
6. **Goals** - Progress tracking
7. **Wallet** - Token management
8. **Settings** - User preferences

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Credits

- Original Design: StepSign Mobile App Design (Figma)
- Converted to Flutter by: AI Assistant
- Built with: Flutter & Dart

---

**Note**: This is the onboarding flow only. Additional screens need to be implemented for a complete app.

