# Complete StepSign Flutter Implementation Plan

## ✅ What's Already Done (4 screens)
1. ✅ Onboarding Screen 1 - Welcome
2. ✅ Onboarding Screen 2 - Visualization  
3. ✅ Onboarding Screen 3 - AI Verification
4. ✅ Onboarding Screen 4 - Permissions

## 🚧 What Needs to Be Implemented (5 screens + 3 widgets)

### Screens (5)
5. ❌ **Dashboard** - Navigation hub, stats, live preview
6. ❌ **Pairing** - BLE scanning, calibration
7. ❌ **LiveSession** - Real-time monitoring
8. ❌ **Analytics** - Historical charts
9. ❌ **3D Viewer** - IMU orientation
10. ❌ **Goals** - Progress tracking
11. ❌ **Wallet** - Token management
12. ❌ **Settings** - Preferences, developer mode

### Critical Widgets (3)
- ❌ **HeatmapFull** - Full insole with exact CAD path + pressure rendering
- ❌ **HeatmapMini** - Mini version for dashboard
- ❌ **IMUOrientationMini** - 3D orientation widget

## 📊 Complexity Estimate

| Component | Lines of Code | Priority | Complexity |
|-----------|---------------|----------|------------|
| Dashboard | ~300 lines | HIGH | Medium |
| Pairing | ~350 lines | HIGH | Medium |
| LiveSession | ~400 lines | HIGH | High |
| Analytics | ~300 lines | MEDIUM | Medium |
| 3D Viewer | ~400 lines | MEDIUM | Very High |
| Goals | ~250 lines | MEDIUM | Low |
| Wallet | ~300 lines | LOW | Medium |
| Settings | ~400 lines | LOW | Medium |
| HeatmapFull | ~200 lines | HIGH | Very High |
| HeatmapMini | ~150 lines | HIGH | High |
| IMUOrientationMini | ~150 lines | MEDIUM | High |
| **TOTAL** | **~3200 lines** | | |

## 🎯 Implementation Strategy

### Phase 1: Core Navigation & Widgets (CRITICAL)
1. Update main.dart with all screen routes
2. Create HeatmapFull widget (exact CAD path)
3. Create HeatmapMini widget
4. Create IMUOrientationMini widget

### Phase 2: Primary Screens (HIGH PRIORITY)
5. Dashboard screen (navigation hub)
6. Pairing screen (BLE)
7. LiveSession screen (real-time data)

### Phase 3: Secondary Screens (MEDIUM PRIORITY)
8. Analytics screen
9. 3D Viewer screen
10. Goals screen

### Phase 4: Tertiary Screens (LOW PRIORITY)
11. Wallet screen
12. Settings screen

## 🎨 Design Consistency Checklist

### Colors (from React code)
- ✅ Primary Gradient: #06B6D4 (Cyan) → #A855F7 (Purple)
- ✅ Accent Gradient: #F59E0B (Amber) → #F97316 (Orange)
- ✅ Success: #22C55E (Green)
- ✅ Warning: #EAB308 (Yellow)
- ✅ Danger: #EF4444 (Red)
- ✅ Background: #0F172A (Slate 950), #1E293B (Slate 900)

### Typography
- ✅ Font: Roboto (system default)
- ✅ Headings: FontWeight.w600 (SemiBold)
- ✅ Body: FontWeight.w500 (Medium) - BOLDER per user request
- ✅ Base size: 16sp

### Components
- ✅ Glassmorphism cards with blur
- ✅ Gradient buttons
- ✅ Animated progress bars
- ✅ Smooth page transitions

## 📐 Exact CAD Insole Path (CRITICAL)

```dart
// This EXACT path must be used in all heatmap visualizations
const String INSOLE_CAD_PATH = "M386.18 42.56L386.77 42.53L387.35 42.51...";
// ViewBox: "280 20 240 580"
// Rotation: 180° (heel at bottom, toes at top)

// Sensor positions (on rotated insole):
// - Toes: cx="400" cy="65"
// - Ball: cx="400" cy="150"  
// - Arch: cx="360" cy="330"
// - Heel: cx="388" cy="520"
```

## 🔧 Technical Requirements

### Dependencies to Add
```yaml
# Already in pubspec.yaml:
- smooth_page_indicator: ^1.1.0
- provider: ^6.1.1
- permission_handler: ^11.0.1
- flutter_blue_plus: ^1.31.0
- fl_chart: ^0.65.0

# Need to add:
- intl: ^0.18.0  # For date formatting
- shared_preferences: ^2.2.0  # For settings persistence
```

### State Management
- Use Provider for app-wide state
- Local StatefulWidget state for screen-specific data
- Mock data generators for sensors

## 🎬 Animation Specifications

### From React Code
- Page transitions: 300ms ease-in-out
- Heatmap updates: 30 FPS (throttled)
- 3D viewer: 60 FPS
- Button press: Scale to 0.95, 150ms
- Progress rings: Smooth circular progress

### Flutter Implementation
- Use AnimationController for continuous animations
- PageView for screen transitions
- CustomPainter for heatmaps
- Transform widgets for 3D effects

## 📱 Screen-Specific Notes

### Dashboard
- Grid of stats cards (steps, active minutes, calories)
- Daily goal progress bar
- Live sensor preview (HeatmapMini)
- Wallet summary card
- Quick action buttons (Start Session, Calibrate)
- Bottom navigation bar

### Pairing
- BLE scanning animation
- Device list with RSSI, battery, firmware
- 4-step calibration wizard:
  1. Stand normally
  2. Shift to toes
  3. Shift to heels
  4. Walk in place
- Streaming mode selection (20Hz/50Hz/100Hz)
- Real-time sensor readings during calibration

### LiveSession
- Session timer (MM:SS)
- Step counter
- Current gesture with confidence bar
- Live waveform visualization
- Cheat detection status (verified/suspicious/flagged)
- Full pressure heatmap (HeatmapFull)
- IMU orientation display
- Haptic controls with intensity slider
- End session button

### Analytics
- Time range selector (Day/Week/Month)
- Multi-line chart (4 sensors)
- Peak pressure alerts
- Tabs for individual sensors
- Export data button

### 3D Viewer
- Interactive 3D insole model (exact CAD shape)
- IMU data display (pitch, roll, yaw)
- Playback controls (play/pause, scrubber, speed)
- View options (wireframe, show sensors, auto-rotate)
- Manual rotation sliders
- Grid background with axis labels

### Goals
- Current streak display
- Weight goal progress
- Daily steps goal
- AI verification insights
- Flagged sessions list
- Achievement badges

### Wallet
- Wallet address with copy button
- Staked amount (locked 30 days)
- Available balance
- Stake/Withdraw buttons
- Transaction history with tabs
- Smart contract info

### Settings
- 3 tabs: Profile, App, Developer
- Profile: weight, height, shoe size, gait baseline
- App: notifications, haptic, AI mode, accessibility
- Developer: BLE packet inspector, GATT viewer, sampling rate

## ⚠️ Known Challenges

1. **3D Rendering**: Flutter doesn't have native 3D, need creative 2.5D solution
2. **Exact CAD Path**: Must preserve exact coordinates and rotation
3. **Real-time Performance**: Heatmap updates at 30 FPS
4. **BLE Integration**: Mock for now, real implementation later
5. **Charts**: fl_chart may need customization

## 🎯 Success Criteria

- ✅ All 9 screens implemented
- ✅ Exact color matching
- ✅ Smooth 60 FPS animations
- ✅ Exact CAD insole shape in all heatmaps
- ✅ Consistent typography (bolder weights)
- ✅ Working navigation between all screens
- ✅ Mock data generators for sensors
- ✅ Production-ready code quality

## 📝 Next Steps

1. Start with Phase 1 (navigation + widgets)
2. Implement Phase 2 (primary screens)
3. Continue with Phase 3 & 4
4. Test complete flow
5. Document any deviations from React code

---

**Estimated Total Time**: 6-8 hours of focused implementation
**Current Progress**: 30% (onboarding complete)
**Remaining Work**: 70% (5 screens + 3 widgets)

