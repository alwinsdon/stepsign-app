# StepSign - Quick Testing Guide

## Prerequisites Checklist

Before running the app, make sure you have:

### ✅ Phone Setup
- [ ] Developer Options enabled (Settings → About phone → Tap "Build number" 7 times)
- [ ] USB Debugging turned ON (Settings → Developer options → USB debugging)
- [ ] Phone connected via USB cable to laptop
- [ ] "Allow USB debugging" popup accepted on phone (check "Always allow")

### ✅ Laptop Setup
- [x] Flutter installed (already done! ✓)
- [ ] ADB installed (run setup script below)
- [ ] Project dependencies installed

---

## Step 1: Install ADB and Check Phone Connection

Open a terminal and run:

```bash
cd /home/alwins_don/Desktop/stepsign-app
./setup-phone.sh
```

This will:
1. Install ADB (Android Debug Bridge)
2. Check if your phone is connected
3. Show you next steps

**Expected output:**
```
Connected devices:
XXXXXXXXXX    device
```

If you see "unauthorized", check your phone for the USB debugging popup!

---

## Step 2: Install Project Dependencies

```bash
cd /home/alwins_don/Desktop/stepsign-app
flutter pub get
```

This downloads all required packages (flutter_blue_plus, etc.)

---

## Step 3: Run the App!

```bash
flutter run
```

**What happens:**
1. Flutter builds the app (~30 seconds first time)
2. APK automatically installs on your phone
3. App launches automatically
4. You see logs in terminal

**Expected output:**
```
Launching lib/main.dart on SM G973F in debug mode...
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing...
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

Running with sound null safety

💙 An Observatory debugger and profiler is available at: ...
```

---

## Step 4: Test BLE with ESP32

Once the app is running on your phone:

1. **Flash ESP32 firmware:**
   - Open `firmware/stepsign_ble/stepsign_ble.ino` in Arduino IDE
   - Select "ESP32 Dev Module" board
   - Upload to your ESP32

2. **Power on ESP32:**
   - Connect to USB or battery
   - Check Serial Monitor (115200 baud) - should see "BLE: Advertising started"

3. **In the app on your phone:**
   - Complete onboarding
   - Go to "Device Pairing"
   - Tap "Start Scanning"
   - You should see "StepSign-001"
   - Tap to connect
   - Go to "Live Session"
   - See real sensor data! 🎉

---

## Hot Reload (The Magic!)

While the app is running, you can make changes to the code and see them instantly:

1. Edit a file (e.g., change a color in `lib/screens/live_session_screen.dart`)
2. Save the file
3. Press `r` in the terminal
4. Changes appear on your phone in ~1 second! ⚡

---

## Troubleshooting

### Phone not detected

```bash
# Restart ADB
adb kill-server
adb start-server
adb devices
```

### Build fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Permission errors on phone

Settings → Apps → StepSign → Permissions → Enable:
- Location (required for BLE scanning on Android)
- Nearby devices (Android 12+)

### ESP32 not appearing in scan

- Check ESP32 Serial Monitor shows "BLE: Advertising started"
- Make sure Bluetooth is ON on your phone
- Try getting physically closer to ESP32
- Restart the app

---

## Commands Reference

```bash
# Check Flutter setup
flutter doctor

# List connected devices
flutter devices

# Install dependencies
flutter pub get

# Run app
flutter run

# Build release APK (for sharing)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Check phone connection
adb devices

# View phone logs
adb logcat | grep flutter
```

---

## What You'll See

### Terminal Output (Laptop)
```
I/flutter: BLE: Scanning for devices...
I/flutter: BLE: Found device: StepSign-001
I/flutter: BLE: Connecting...
I/flutter: BLE: Connected and streaming!
I/flutter: SensorFrame(ax=234, ay=-156, az=16234, fsr=[1234, 2345, 3456, 4567])
```

### ESP32 Serial Monitor
```
=== StepSign Smart Insole ===
Firmware: 1.0.0
MPU-6050: OK
FSR sensors: OK
Vibration motor: OK
BLE: Advertising started
BLE: Device name: StepSign-001

BLE: Client connected
Sent 50 frames | ax=234 ay=-156 az=16234 | fsr=[1234,2345,3456,4567]
```

---

## Ready to Start?

1. Make sure your phone has USB debugging enabled
2. Connect phone via USB
3. Run: `./setup-phone.sh`
4. Run: `flutter pub get`
5. Run: `flutter run`

**That's it!** The app will appear on your phone and you can start testing! 🚀

