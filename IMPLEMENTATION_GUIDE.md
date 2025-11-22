# Flutter Implementation Guide

## 🎯 Overview

This guide explains how the Figma design was converted to Flutter code, including design decisions, widget choices, and implementation patterns.

## 🏗️ Architecture

### Project Structure
```
stepsign_mobile/
├── lib/
│   ├── main.dart                    # App entry point & theme
│   ├── screens/
│   │   └── onboarding_screen.dart  # Main onboarding flow
│   └── widgets/
│       ├── gradient_button.dart     # Reusable gradient button
│       ├── feature_card.dart        # Feature list card
│       ├── permission_card.dart     # Permission request card
│       └── heatmap_preview.dart     # Animated heatmap
├── pubspec.yaml                     # Dependencies
├── analysis_options.yaml            # Linting rules
└── FLUTTER_README.md               # Setup instructions
```

## 🎨 Design to Code Mapping

### 1. Color System

#### Figma Colors → Flutter Constants
```dart
// Figma: Cyan #06B6D4
const Color(0xFF06B6D4)

// Figma: Purple #A855F7
const Color(0xFFA855F7)

// Figma: Slate 950 #0F172A
const Color(0xFF0F172A)

// Figma: Slate 900 #1E293B
const Color(0xFF1E293B)
```

#### Gradient Implementation
```dart
// Figma: linear-gradient(to right, #06B6D4, #A855F7)
LinearGradient(
  colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
)
```

### 2. Typography

#### Figma Text Styles → Flutter TextStyle
```dart
// Heading 1 (28px, Bold)
TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
)

// Body (16px, Regular)
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: Color(0xFF94A3B8),
)

// Subtitle (14px, Regular)
TextStyle(
  fontSize: 14,
  color: Color(0xFF94A3B8),
)
```

### 3. Spacing System

#### Figma Spacing → Flutter EdgeInsets
```dart
// Figma: padding: 24px
EdgeInsets.all(24)

// Figma: gap: 16px
SizedBox(height: 16)

// Figma: padding: 12px 16px
EdgeInsets.symmetric(horizontal: 16, vertical: 12)
```

### 4. Border Radius

#### Figma Border Radius → Flutter BorderRadius
```dart
// Figma: border-radius: 12px
BorderRadius.circular(12)

// Figma: border-radius: 50% (circle)
BoxDecoration(shape: BoxShape.circle)
```

## 🧩 Widget Breakdown

### GradientButton Widget

**Purpose**: Reusable button with gradient background

**Figma Element**: 
```css
.button {
  background: linear-gradient(to right, #06B6D4, #A855F7);
  border-radius: 12px;
  padding: 16px;
}
```

**Flutter Implementation**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF06B6D4), Color(0xFFA855F7)],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onPressed,
      child: Text(text),
    ),
  ),
)
```

**Key Features**:
- Gradient background
- Ripple effect on tap
- Disabled state handling
- Optional icon support

### FeatureCard Widget

**Purpose**: Display feature information with colored dot

**Figma Element**:
```css
.feature-card {
  background: rgba(30, 41, 59, 0.4);
  border: 1px solid rgba(51, 65, 85, 0.5);
  border-radius: 12px;
  padding: 12px;
}
```

**Flutter Implementation**:
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Color(0xFF1E293B).withOpacity(0.4),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Color(0xFF334155).withOpacity(0.5),
    ),
  ),
  child: Row(
    children: [
      // Colored dot
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
      // Text content
      Column(
        children: [
          Text(title),
          Text(subtitle),
        ],
      ),
    ],
  ),
)
```

### PermissionCard Widget

**Purpose**: Interactive permission request card

**Figma Element**:
```css
.permission-card {
  background: rgba(30, 41, 59, 0.4);
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
}
```

**Flutter Implementation**:
```dart
InkWell(
  onTap: onTap,
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFF1E293B).withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon),
        Expanded(child: Text(title)),
        // Checkbox indicator
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isGranted ? Color(0xFF06B6D4) : Color(0xFF475569),
            ),
          ),
        ),
      ],
    ),
  ),
)
```

### HeatmapPreview Widget

**Purpose**: Animated pressure visualization

**Figma Element**: Static SVG image

**Flutter Implementation**: Custom painter with animation
```dart
class HeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw insole outline
    Path path = Path();
    // ... insole shape ...
    
    // Draw animated pressure points
    for (var point in pressurePoints) {
      Paint paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.8), Colors.transparent],
        ).createShader(rect);
      canvas.drawCircle(point, radius, paint);
    }
  }
}
```

**Enhancement**: Added animation controller for pulsing effect

## 🎬 Animations

### Page Transitions

**Figma**: Implied slide animation

**Flutter Implementation**:
```dart
PageView(
  controller: _pageController,
  onPageChanged: (index) {
    setState(() => _currentPage = index);
  },
  children: [...],
)

// Navigate with animation
_pageController.nextPage(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)
```

### Heatmap Animation

**Figma**: Static image

**Flutter Implementation**:
```dart
AnimationController _controller = AnimationController(
  vsync: this,
  duration: Duration(seconds: 3),
)..repeat();

AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return CustomPaint(
      painter: HeatmapPainter(
        animationValue: _controller.value,
      ),
    );
  },
)
```

### Page Indicator

**Figma**: Static dots

**Flutter Implementation**:
```dart
SmoothPageIndicator(
  controller: _pageController,
  count: 4,
  effect: ExpandingDotsEffect(
    activeDotColor: Color(0xFF06B6D4),
    dotColor: Color(0xFF334155),
    expansionFactor: 4,
  ),
)
```

## 🔧 State Management

### Onboarding State

```dart
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Permission states
  bool _bluetoothGranted = false;
  bool _activityGranted = false;
  bool _notificationsGranted = false;
  
  // Computed property
  bool get _canProceed {
    if (_currentPage < 3) return true;
    return _bluetoothGranted && 
           _activityGranted && 
           _notificationsGranted;
  }
}
```

### State Updates

```dart
// Update permission state
setState(() {
  _bluetoothGranted = !_bluetoothGranted;
});

// Update page
_pageController.nextPage(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
);
```

## 📱 Responsive Design

### Safe Area Handling

```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [...],
    ),
  ),
)
```

### Scrollable Content

```dart
SingleChildScrollView(
  padding: EdgeInsets.all(24),
  child: Column(
    children: [...],
  ),
)
```

### Flexible Layouts

```dart
Row(
  children: [
    Icon(icon),
    Expanded(  // Takes remaining space
      child: Text(text),
    ),
    Container(width: 24, height: 24),
  ],
)
```

## 🎨 Theme Configuration

### Material Theme

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF0F172A),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF06B6D4),
      secondary: Color(0xFFA855F7),
    ),
  ),
)
```

### Status Bar

```dart
SystemChrome.setSystemUIOverlayStyle(
  SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ),
)
```

## 🧪 Testing Considerations

### Widget Tests

```dart
testWidgets('Onboarding shows 4 pages', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: OnboardingScreen(),
  ));
  
  expect(find.text('Welcome to StepSign'), findsOneWidget);
  
  // Swipe to next page
  await tester.drag(
    find.byType(PageView),
    Offset(-400, 0),
  );
  await tester.pumpAndSettle();
  
  expect(find.text('Real-time Visualization'), findsOneWidget);
});
```

### Unit Tests

```dart
test('canProceed returns false when permissions not granted', () {
  final state = _OnboardingScreenState();
  expect(state._canProceed, isFalse);
});
```

## 🚀 Performance Optimization

### 1. Const Constructors
```dart
const Text('Welcome to StepSign')  // Reuses widget instance
```

### 2. Animation Disposal
```dart
@override
void dispose() {
  _controller.dispose();
  _pageController.dispose();
  super.dispose();
}
```

### 3. Efficient Rebuilds
```dart
AnimatedBuilder(  // Only rebuilds painter
  animation: _controller,
  builder: (context, child) {
    return CustomPaint(
      painter: HeatmapPainter(
        animationValue: _controller.value,
      ),
    );
  },
)
```

## 📦 Dependencies Explained

### smooth_page_indicator
- **Purpose**: Animated page indicator dots
- **Alternative**: Custom implementation with AnimatedContainer

### permission_handler
- **Purpose**: Request native permissions
- **Usage**: Bluetooth, Activity, Notifications

### flutter_blue_plus
- **Purpose**: Bluetooth Low Energy connectivity
- **Usage**: Connect to smart insoles (future implementation)

### fl_chart
- **Purpose**: Data visualization
- **Usage**: Analytics charts (future implementation)

## 🔄 Migration Path

### From React to Flutter

| React | Flutter |
|-------|---------|
| `useState` | `setState` |
| `useEffect` | `initState` / `didChangeDependencies` |
| `motion` animations | `AnimationController` |
| CSS classes | `TextStyle` / `BoxDecoration` |
| `onClick` | `onTap` / `onPressed` |
| `className` | `style` parameter |

### Component Mapping

| React Component | Flutter Widget |
|----------------|----------------|
| `<div>` | `Container` |
| `<button>` | `ElevatedButton` / `TextButton` |
| `<p>` | `Text` |
| `<img>` | `Image` |
| `<input>` | `TextField` |
| Flexbox | `Row` / `Column` |

## 🎓 Learning Resources

### Flutter Basics
- [Flutter Documentation](https://flutter.dev/docs)
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Cookbook](https://flutter.dev/docs/cookbook)

### Design Implementation
- [Material Design](https://material.io/design)
- [Flutter Layout Cheat Sheet](https://medium.com/flutter-community/flutter-layout-cheat-sheet-5363348d037e)
- [Animation Tutorial](https://flutter.dev/docs/development/ui/animations/tutorial)

## 🐛 Common Issues & Solutions

### Issue: Colors don't match exactly
**Solution**: Use Color(0xFFHEXCODE) format, ensure alpha channel (FF)

### Issue: Layout overflow
**Solution**: Wrap in SingleChildScrollView or use Flexible/Expanded

### Issue: Animation stuttering
**Solution**: Use const constructors, dispose controllers properly

### Issue: State not updating
**Solution**: Ensure setState() is called, check widget tree

## 🔮 Next Steps

1. **Implement remaining screens**:
   - Pairing screen
   - Dashboard
   - Live session
   - Analytics
   - Settings

2. **Add real Bluetooth connectivity**:
   - Scan for devices
   - Connect to insoles
   - Stream sensor data

3. **Implement data persistence**:
   - SharedPreferences for settings
   - SQLite for session history
   - Secure storage for tokens

4. **Add testing**:
   - Unit tests for business logic
   - Widget tests for UI
   - Integration tests for flows

5. **Polish & optimize**:
   - Add haptic feedback
   - Optimize animations
   - Reduce memory usage
   - Add error handling

---

**Questions?** Check the FLUTTER_README.md for setup instructions or DESIGN_COMPARISON.md for design fidelity details.

