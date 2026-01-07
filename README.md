# StepSign 🦶⛓️

**AI-Powered Smart Insole with Blockchain Rewards**

StepSign is a comprehensive fitness ecosystem that combines smart insole hardware, a Flutter mobile app, and Sui blockchain integration to reward users for physical activity.

![StepSign Logo](StepSignLogo.png)

## 🌟 Features

### Mobile App (Flutter)
- **Real-time Sensor Visualization**: Live pressure heatmaps and 3D IMU orientation display
- **Step Tracking**: Integrated pedometer with daily/weekly/monthly analytics
- **BLE Connectivity**: Seamless pairing with StepSign smart insoles
- **Wallet Integration**: Sui blockchain wallet for STEP token rewards
- **Token Claiming**: Earn STEP tokens for walking (10+ steps per claim)
- **Goals & Analytics**: Set step goals and track progress over time

### Backend (Node.js/TypeScript)
- **RESTful API**: Session management and reward claims
- **Sui Integration**: Automated STEP token minting and transfers
- **SQLite Database**: Persistent storage for sessions and claims
- **Auto-approval**: Claims automatically processed and tokens sent

### Smart Contract (Move/Sui)
- **STEP Token**: Custom fungible token on Sui testnet
- **Reward Distribution**: Treasury-controlled minting for verified activity

### Firmware (ESP32)
- **BLE Communication**: Real-time sensor data streaming
- **Pressure Sensors**: 16 FSR zones per insole
- **IMU Integration**: 9-axis motion sensing (accelerometer, gyroscope, magnetometer)

## 📁 Project Structure

```
stepsign-app/
├── lib/                      # Flutter app source
│   ├── main.dart             # App entry point
│   ├── models/               # Data models
│   │   └── sensor_data.dart
│   ├── screens/              # UI screens
│   │   ├── dashboard_screen.dart
│   │   ├── live_session_screen.dart
│   │   ├── wallet_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── goals_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── pairing_screen.dart
│   │   ├── onboarding_screen.dart
│   │   └── viewer_3d_screen.dart
│   ├── services/             # Business logic
│   │   ├── api_service.dart
│   │   ├── ble_service.dart
│   │   ├── storage_service.dart
│   │   └── wallet_service.dart
│   └── widgets/              # Reusable UI components
│       ├── heatmap_full.dart
│       ├── heatmap_mini.dart
│       ├── imu_orientation_mini.dart
│       ├── insole_cad_path.dart
│       └── ...
├── backend/                  # Node.js backend
│   ├── src/
│   │   ├── server.ts         # Express API server
│   │   ├── database.ts       # SQLite operations
│   │   └── sui-client.ts     # Sui blockchain client
│   ├── package.json
│   └── .env.example
├── firmware/                 # ESP32 firmware
│   └── stepsign_ble/
│       ├── stepsign_ble.ino
│       └── README.md
├── step-token/               # Sui Move smart contract
│   ├── sources/
│   ├── Move.toml
│   └── README.md
├── android/                  # Android platform files
├── ios/                      # iOS platform files
├── assets/                   # App assets
│   └── images/
├── .github/
│   └── workflows/
│       └── flutter-build.yml # CI/CD pipeline
└── docs/                     # Documentation archive
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.24+
- Node.js 18+
- Android Studio / Xcode
- Sui CLI (for smart contract)

### 1. Clone & Setup

```bash
git clone https://github.com/YOUR_USERNAME/stepsign-app.git
cd stepsign-app

# Install Flutter dependencies
flutter pub get

# Install backend dependencies
cd backend && npm install && cd ..
```

### 2. Configure Backend

```bash
cd backend
cp .env.example .env
# Edit .env with your Sui wallet keys
npm run dev
```

### 3. Run the App

```bash
# Connect your Android device
flutter run -d <device_id>

# Or build APK
flutter build apk --release
```

## 🔧 Backend API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/sessions` | POST | Create walking session |
| `/api/sessions/:id` | GET | Get session details |
| `/api/claims` | POST | Submit token claim |
| `/api/claims/pending` | GET | List pending claims |
| `/api/claims/wallet/:address` | GET | Get claims by wallet |
| `/api/claims/:id/approve` | POST | Approve claim |
| `/api/wallet/:address` | GET | Get wallet info |
| `/health` | GET | Health check |

## ⚙️ Configuration

### Environment Variables (backend/.env)

```env
PORT=3000
SUI_NETWORK=testnet
SUI_RPC_URL=https://fullnode.testnet.sui.io:443
SUI_PACKAGE_ID=0x01067c18...
SUI_TREASURY_CAP_ID=0x036525...
REWARD_PER_STEP=1000000
MIN_STEPS_FOR_CLAIM=10
MAX_CLAIMS_PER_DAY=3
```

### App Configuration

- Backend URL: `http://YOUR_IP:3000` (set in `lib/services/api_service.dart`)
- BLE Service UUID: `12345678-1234-5678-1234-56789abcdef0`

## 📱 App Screens

| Screen | Description |
|--------|-------------|
| **Onboarding** | First-time setup, profile info, BLE pairing |
| **Dashboard** | Step count, token balance, mini heatmap |
| **Live Session** | Real-time pressure visualization |
| **Wallet** | STEP token balance and claim history |
| **Analytics** | Charts for daily/weekly/monthly activity |
| **Goals** | Set and track step targets |
| **Settings** | App configuration and account |

## 🔗 Blockchain

### STEP Token (Sui Testnet)
- **Package ID**: `0x01067c18c1f73d0b7a37950899a36676144c9af18fd0c3a327db6d46fe950ea5`
- **Treasury Cap**: `0x036525457738ff9aa62daf35819f7a255ed4fd86e2b0f058348b4f038b4f332f`
- **Decimals**: 9
- **Symbol**: STEP

### Viewing Tokens
1. Install [Sui Wallet](https://suiwallet.com/) browser extension
2. Switch to Testnet
3. Import your wallet or create new
4. Tokens appear after claiming in the app

## 🛠️ Development

### Build Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build Debug APK
```bash
flutter build apk --debug
```

### Run Tests
```bash
flutter test
cd backend && npm test
```

### GitHub Actions
The project includes CI/CD workflow that:
- Builds Android APK on push to main/master/develop
- Uploads artifacts for download
- Creates releases on version tags

## 🔌 Hardware Setup

### ESP32 Firmware
1. Open `firmware/stepsign_ble/stepsign_ble.ino` in Arduino IDE
2. Install ESP32 board support
3. Select your ESP32 board
4. Upload firmware

### BLE Protocol
- **Service UUID**: `12345678-1234-5678-1234-56789abcdef0`
- **Pressure Characteristic**: `12345678-1234-5678-1234-56789abcdef1`
- **IMU Characteristic**: `12345678-1234-5678-1234-56789abcdef2`

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📞 Support

For issues and questions, please open a GitHub issue.

---

**Built with ❤️ using Flutter, Node.js, and Sui Blockchain**
