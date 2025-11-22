# StepSign — Smart Insole Mobile App

A comprehensive mobile UI/UX for the StepSign smart insole system, featuring real-time sensor visualization, AI-powered gesture classification, cheat detection, and blockchain rewards integration.

## Features

### 🎯 Core Functionality

- **Real-time Sensor Visualization**
  - Live pressure heatmaps with smooth gradient interpolation
  - 4 FSR sensors: Heel, Arch, Ball, Toes
  - Color-coded pressure mapping (Blue → Yellow → Orange → Red)

- **3D IMU Orientation Viewer**
  - Real-time pitch, roll, yaw tracking
  - Interactive 3D insole model
  - Session replay with scrubbing controls

- **AI Gesture Classification**
  - On-device AI model for instant recognition
  - Detects: Walking, Running, Jumping, Standing, Stairs
  - Confidence scoring with live waveform visualization

- **Anti-Cheat Detection**
  - Real-time pattern analysis
  - Flags: Shaking, tampering, irregular gait
  - Explainable detection reasons

- **Blockchain Rewards System**
  - Stake STEP tokens
  - Earn rewards for verified sessions
  - Penalties for flagged activity
  - Secure withdrawal with 2FA

### 📱 Screens

1. **Onboarding** — Hardware explanation, permissions, demo
2. **Pairing** — BLE device discovery, connection, calibration
3. **Dashboard** — Daily stats, live preview, quick actions
4. **Live Session** — Real-time monitoring with all sensors
5. **Analytics** — Historical heatmaps, pressure graphs, injury alerts
6. **3D Viewer** — IMU playback and orientation visualization
7. **Goals** — Progress tracking, AI verification insights
8. **Wallet** — Token management, transaction history
9. **Settings** — Profile, app preferences, developer mode

### 🛠 Developer Mode

- Live BLE packet inspector
- GATT characteristic viewer
- Sampling rate control (20-100 Hz)
- Battery & connection stats
- Firmware update interface
- IMU calibration tools

## Hardware Specifications

- **Sensors:** 4× FSR (Force Sensitive Resistor)
- **IMU:** 6-axis accelerometer + gyroscope + magnetometer
- **Haptic:** 1× vibration motor with intensity control
- **Connectivity:** ESP32 BLE Low Energy
- **Battery Life:** 12-48 hours (depends on sampling rate)
- **Sampling Rates:** 20 Hz, 50 Hz, 100 Hz

## Design System

### Color Palette
- **Primary Gradient:** Cyan (#06b6d4) → Purple (#a855f7)
- **Accent:** Amber (#f59e0b) → Orange (#f97316)
- **Success:** Green (#22c55e)
- **Warning:** Yellow (#eab308)
- **Danger:** Red (#ef4444)
- **Background:** Dark slate (#0f172a, #1e293b)

### Typography
- **Headings:** Medium weight (500)
- **Body:** Normal weight (400)
- **Font Size:** Responsive (16px base)

### Accessibility
- Color-blind friendly palette option
- Numeric pressure readouts
- Pattern-based indicators
- High contrast mode

## Technology Stack

- **React** — UI framework
- **TypeScript** — Type safety
- **Tailwind CSS** — Styling
- **Motion/React** — Animations
- **Recharts** — Data visualization
- **shadcn/ui** — Component library
- **Lucide React** — Icons

## BLE Communication

### GATT Service
**UUID:** `0000180F-0000-1000-8000-00805f9b34fb`

### Characteristics
- **PressureData** — 4× uint16 (8 bytes)
- **IMUData** — 6× int16 or 4× float32
- **Battery** — uint8 (0-100%)
- **Command** — Variable (calibrate, haptic, sampling rate)

See [DEVELOPER_NOTES.md](./DEVELOPER_NOTES.md) for detailed BLE protocol documentation.

## Mock Data

The app includes realistic mock data for:
- Sensor streams (sine waves + step spikes)
- Gesture patterns (walking, running, standing, etc.)
- Cheat detection scenarios
- Blockchain transactions
- AI confidence scores

## User Flows

### First-Time Setup
1. Onboarding screens with hardware explanation
2. Grant Bluetooth, Activity, Notification permissions
3. Scan and pair left/right insoles
4. Calibrate sensors (4-step wizard)
5. Choose streaming mode (low-power vs high-fidelity)
6. View dashboard

### Daily Usage
1. Open app → See dashboard
2. Start session → Live monitoring
3. AI classifies gestures in real-time
4. Cheat detection runs continuously
5. End session → Data saved
6. Earn STEP tokens for verified sessions

### Developer Workflow
1. Enable developer mode in Settings
2. View live BLE packets
3. Adjust sampling rate
4. Monitor battery consumption
5. Test firmware updates
6. Export logs for analysis

## Notifications

- **Goal Achievements:** "🎉 Goal verified — 12 STEP tokens added to your wallet"
- **Cheat Detection:** "⚠️ Unverified steps detected — pattern suggests non-walking motion"
- **Low Battery:** "Low battery on right insole — please charge"
- **Connection Lost:** "Connection lost — attempting to reconnect..."
- **Pressure Alerts:** "Peak pressure alert — consider adding cushioning"

## Future Enhancements

- Multi-insole support (>2 pairs)
- Social leaderboards & challenges
- Injury risk prediction with ML
- Real-time gait coaching
- Integration with Apple Health / Google Fit
- Firmware OTA updates
- Advanced analytics dashboard

## Performance

- **Heatmap Updates:** 30 FPS (throttled)
- **3D Viewer:** 60 FPS
- **Packet Processing:** <10ms latency
- **AI Inference:** <50ms on mobile CPU
- **Battery Impact:** ~2-5% per hour of active use

## Security & Privacy

- **On-Device AI:** No sensor data sent to cloud
- **Blockchain:** Decentralized rewards system
- **2FA:** Optional for wallet withdrawals
- **Data Retention:** 30 days, user-controlled deletion
- **No PII Collection:** Designed for fitness tracking only

## License

MIT License — See LICENSE file for details

## Support

- **Documentation:** [docs.stepsign.io](https://docs.stepsign.io)
- **Issues:** [github.com/stepsign/mobile/issues](https://github.com/stepsign/mobile/issues)
- **Discord:** [discord.gg/stepsign](https://discord.gg/stepsign)

---

**Built with Figma Make** — AI-powered web application builder
