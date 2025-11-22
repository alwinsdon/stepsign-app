# 📁 Project Structure

Complete overview of the Flutter project structure and file organization.

## 🌳 Directory Tree

```
stepsign_mobile/
├── 📱 lib/                                    # Main application code
│   ├── main.dart                             # App entry point & theme config
│   ├── 📺 screens/                           # Screen-level widgets
│   │   └── onboarding_screen.dart           # Onboarding flow (4 pages)
│   └── 🧩 widgets/                           # Reusable UI components
│       ├── gradient_button.dart             # Gradient button with icon
│       ├── feature_card.dart                # Feature list card
│       ├── permission_card.dart             # Permission request card
│       └── heatmap_preview.dart             # Animated pressure heatmap
│
├── 🤖 android/                                # Android-specific files
│   ├── app/
│   │   ├── build.gradle                     # Android build config
│   │   └── src/main/
│   │       └── AndroidManifest.xml          # Android permissions & config
│   ├── gradle/                              # Gradle wrapper
│   └── build.gradle                         # Root build config
│
├── 🍎 ios/                                    # iOS-specific files
│   └── Runner/
│       ├── Info.plist                       # iOS permissions & config
│       └── Assets.xcassets/                 # iOS app icons
│
├── 📄 Documentation Files
│   ├── FLUTTER_README.md                    # Setup & installation guide
│   ├── QUICKSTART.md                        # 5-minute quick start
│   ├── DESIGN_COMPARISON.md                 # Design fidelity analysis
│   ├── IMPLEMENTATION_GUIDE.md              # Technical implementation
│   ├── CONVERSION_SUMMARY.md                # Project summary
│   └── PROJECT_STRUCTURE.md                 # This file
│
├── ⚙️ Configuration Files
│   ├── pubspec.yaml                         # Dependencies & assets
│   ├── analysis_options.yaml                # Linting rules
│   └── .gitignore                           # Git ignore rules
│
└── 📦 Original React Code (Reference)
    ├── src/
    │   ├── App.tsx                          # Original React app
    │   └── components/
    │       └── Onboarding.tsx               # Original onboarding
    └── package.json                         # React dependencies
```

## 📱 lib/ Directory

### main.dart (60 lines)
**Purpose**: Application entry point
- Configures Material theme
- Sets up color scheme
- Defines app-wide styling
- Initializes status bar

**Key Components**:
```dart
void main() { ... }                          // Entry point
class StepSignApp extends StatelessWidget   // Root widget
```

### screens/onboarding_screen.dart (550 lines)
**Purpose**: Main onboarding flow with 4 pages
- Page 1: Welcome & features
- Page 2: Real-time visualization
- Page 3: AI verification
- Page 4: Permissions

**Key Components**:
```dart
class OnboardingScreen extends StatefulWidget
class _OnboardingScreenState extends State<OnboardingScreen>
  - _buildWelcomePage()
  - _buildVisualizationPage()
  - _buildAIVerificationPage()
  - _buildPermissionsPage()
  - _buildBottomSection()
```

**State Management**:
- `_currentPage`: Current page index (0-3)
- `_bluetoothGranted`: Bluetooth permission state
- `_activityGranted`: Activity permission state
- `_notificationsGranted`: Notifications permission state
- `_canProceed`: Computed property for button state

### widgets/gradient_button.dart (60 lines)
**Purpose**: Reusable gradient button
- Cyan to purple gradient
- Optional icon support
- Disabled state handling
- Ripple effect on tap

**Usage**:
```dart
GradientButton(
  text: 'Continue',
  icon: Icons.arrow_forward,
  onPressed: () { ... },
  enabled: true,
)
```

### widgets/feature_card.dart (50 lines)
**Purpose**: Feature list card with colored dot
- Colored indicator dot
- Title and subtitle
- Semi-transparent background
- Subtle border

**Usage**:
```dart
FeatureCard(
  title: '4 FSR Pressure Sensors',
  subtitle: 'Heel • Arch • Ball • Toes',
  dotColor: Color(0xFF06B6D4),
)
```

### widgets/permission_card.dart (70 lines)
**Purpose**: Interactive permission request card
- Icon with color
- Title and subtitle
- Checkbox indicator
- Tap to toggle state

**Usage**:
```dart
PermissionCard(
  icon: Icons.bluetooth,
  title: 'Bluetooth',
  subtitle: 'Connect to insoles',
  iconColor: Color(0xFF3B82F6),
  isGranted: _bluetoothGranted,
  onTap: () { ... },
)
```

### widgets/heatmap_preview.dart (120 lines)
**Purpose**: Animated pressure visualization
- Custom painter for insole shape
- 4 animated pressure points
- Radial gradient effects
- 3-second animation loop

**Key Components**:
```dart
class HeatmapPreview extends StatefulWidget
class _HeatmapPreviewState with SingleTickerProviderStateMixin
class HeatmapPainter extends CustomPainter
```

## 🤖 android/ Directory

### app/build.gradle
**Purpose**: Android build configuration
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Compile SDK: 34
- Package name: com.stepsign.mobile

### app/src/main/AndroidManifest.xml
**Purpose**: Android app manifest
- App name: StepSign
- Permissions: Bluetooth, Activity, Location, Notifications
- Main activity configuration
- Launch mode: singleTop

**Permissions Declared**:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## 🍎 ios/ Directory

### Runner/Info.plist
**Purpose**: iOS app configuration
- App name: StepSign
- Bundle ID: com.stepsign.mobile
- Permissions descriptions
- Supported orientations

**Permissions Declared**:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<key>NSMotionUsageDescription</key>
<key>NSUserNotificationsUsageDescription</key>
<key>NSLocationWhenInUseUsageDescription</key>
```

## ⚙️ Configuration Files

### pubspec.yaml
**Purpose**: Package management and assets
- App name: stepsign_mobile
- Version: 1.0.0+1
- Flutter SDK: >=3.0.0
- Dependencies: 7 packages

**Dependencies**:
```yaml
flutter_svg: ^2.0.9                          # SVG support
smooth_page_indicator: ^1.1.0                # Page dots
provider: ^6.1.1                             # State management
permission_handler: ^11.0.1                  # Permissions
flutter_blue_plus: ^1.31.0                   # Bluetooth
fl_chart: ^0.65.0                            # Charts
lucide_icons: ^0.263.0                       # Icons
```

### analysis_options.yaml
**Purpose**: Linting and code quality rules
- Includes: flutter_lints
- Custom rules: prefer_const_constructors, avoid_print, etc.

### .gitignore
**Purpose**: Git version control exclusions
- Build artifacts
- IDE files
- Generated files
- Platform-specific builds

## 📄 Documentation Files

### FLUTTER_README.md (200 lines)
**Audience**: Developers
**Content**:
- Setup instructions
- Dependencies explanation
- Project structure
- Platform-specific setup
- Customization guide

### QUICKSTART.md (150 lines)
**Audience**: Quick start users
**Content**:
- 3-step installation
- Troubleshooting
- Platform commands
- Basic customization

### DESIGN_COMPARISON.md (300 lines)
**Audience**: Designers & QA
**Content**:
- Fidelity score (95%)
- Screen-by-screen comparison
- Color palette verification
- Typography matching
- Animation enhancements

### IMPLEMENTATION_GUIDE.md (400 lines)
**Audience**: Developers
**Content**:
- Architecture explanation
- Widget breakdown
- Animation implementation
- State management
- Testing strategies

### CONVERSION_SUMMARY.md (350 lines)
**Audience**: Project managers
**Content**:
- Project overview
- Conversion statistics
- Success metrics
- Future roadmap
- Support resources

### PROJECT_STRUCTURE.md (This file)
**Audience**: All team members
**Content**:
- Directory tree
- File purposes
- Component overview
- Quick reference

## 📊 File Statistics

| Category | Files | Lines of Code |
|----------|-------|---------------|
| Dart Code | 6 | ~800 |
| Android Config | 2 | ~100 |
| iOS Config | 1 | ~80 |
| Documentation | 6 | ~1500 |
| Configuration | 3 | ~100 |
| **Total** | **18** | **~2580** |

## 🎯 File Relationships

```
main.dart
  └── OnboardingScreen
      ├── GradientButton (used 1x per page)
      ├── FeatureCard (used 4x on page 1)
      ├── PermissionCard (used 3x on page 4)
      └── HeatmapPreview (used 1x on page 2)
```

## 🔍 Quick Reference

### Need to change colors?
→ `lib/main.dart` (theme configuration)

### Need to modify onboarding content?
→ `lib/screens/onboarding_screen.dart` (page builders)

### Need to customize buttons?
→ `lib/widgets/gradient_button.dart`

### Need to add Android permissions?
→ `android/app/src/main/AndroidManifest.xml`

### Need to add iOS permissions?
→ `ios/Runner/Info.plist`

### Need to add dependencies?
→ `pubspec.yaml`

### Need setup instructions?
→ `FLUTTER_README.md` or `QUICKSTART.md`

### Need design details?
→ `DESIGN_COMPARISON.md`

### Need technical details?
→ `IMPLEMENTATION_GUIDE.md`

## 🚀 Adding New Screens

1. Create new file in `lib/screens/`
2. Import in `main.dart` or parent screen
3. Navigate using `Navigator.push()`

Example:
```dart
// lib/screens/dashboard_screen.dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(child: Text('Dashboard')),
    );
  }
}

// In onboarding_screen.dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => DashboardScreen()),
);
```

## 🧩 Adding New Widgets

1. Create new file in `lib/widgets/`
2. Import where needed
3. Use like any other widget

Example:
```dart
// lib/widgets/custom_card.dart
class CustomCard extends StatelessWidget {
  final String title;
  
  const CustomCard({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(title),
    );
  }
}
```

## 📦 Build Outputs

### Android
```
build/app/outputs/
├── apk/
│   └── release/
│       └── app-release.apk           # APK for distribution
└── bundle/
    └── release/
        └── app-release.aab           # App Bundle for Play Store
```

### iOS
```
build/ios/
└── iphoneos/
    └── Runner.app                    # iOS app bundle
```

## 🔐 Sensitive Files (Not in Repo)

These files should be in `.gitignore`:
- `android/app/google-services.json` (Firebase)
- `ios/Runner/GoogleService-Info.plist` (Firebase)
- `android/key.properties` (Signing keys)
- `.env` (Environment variables)

## 📚 Learning Path

1. **Start here**: `QUICKSTART.md`
2. **Understand design**: `DESIGN_COMPARISON.md`
3. **Learn implementation**: `IMPLEMENTATION_GUIDE.md`
4. **Read code**: `lib/main.dart` → `lib/screens/` → `lib/widgets/`
5. **Customize**: Modify colors, content, add screens

## 🎓 Code Organization Principles

### ✅ Good Practices Used
- Separation of concerns (screens vs widgets)
- Reusable components
- Single responsibility principle
- Meaningful names
- Proper documentation

### 📏 Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables: `camelCase`
- Private: `_leadingUnderscore`
- Constants: `SCREAMING_SNAKE_CASE`

### 🗂️ File Organization
```
lib/
├── main.dart                         # Entry point
├── screens/                          # Full-screen pages
├── widgets/                          # Reusable components
├── models/                           # Data models (future)
├── services/                         # Business logic (future)
└── utils/                            # Helper functions (future)
```

---

**Need help navigating the project?** Start with `QUICKSTART.md` for a quick overview!

