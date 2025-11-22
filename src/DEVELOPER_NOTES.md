# StepSign Developer Notes

## BLE Integration Guide

### GATT Service Structure

#### InsoleService
**UUID:** `0000180F-0000-1000-8000-00805f9b34fb`

This is the main service for the StepSign smart insole system.

### Characteristics

#### 1. PressureData (Read/Notify)
**UUID:** `00002A19-0000-1000-8000-00805f9b34fb`
- **Format:** 4 × uint16 (8 bytes total)
- **Byte Order:** Little Endian
- **Range:** 0-1023 (10-bit ADC values)
- **Mapping:**
  - Bytes 0-1: Heel sensor
  - Bytes 2-3: Arch sensor
  - Bytes 4-5: Ball sensor
  - Bytes 6-7: Toes sensor

**Example Payload:**
```
0x4A 0x3F 0x52 0x41 0x3E 0x2D 0x1C 0x0B
```

**Conversion to Newtons:**
```javascript
const rawValue = (byte1 << 8) | byte0;
const newtons = (rawValue / 1023) * 150; // Assuming 150N max pressure
```

#### 2. IMUData (Read/Notify)
**UUID:** `00002A1C-0000-1000-8000-00805f9b34fb`
- **Format:** 6 × int16 or 4 × float (quaternions)
- **Options:**
  - **Euler Angles Mode:** 6 bytes (3 × int16)
    - Pitch: -180° to +180°
    - Roll: -180° to +180°
    - Yaw: -180° to +180°
  - **Quaternion Mode:** 16 bytes (4 × float32)
    - w, x, y, z components

**Example Euler Payload:**
```
0x12 0x34 0x56 0x78 0x9A 0xBC
```

**Conversion:**
```javascript
const pitch = ((byte1 << 8) | byte0) / 100; // in degrees
const roll = ((byte3 << 8) | byte2) / 100;
const yaw = ((byte5 << 8) | byte4) / 100;
```

#### 3. Battery (Read/Notify)
**UUID:** `00002A19-0000-1000-8000-00805f9b34fb`
- **Format:** uint8 (1 byte)
- **Range:** 0-100 (percentage)

**Example Payload:**
```
0x57  // 87%
```

#### 4. Command (Write)
**UUID:** `00002A1D-0000-1000-8000-00805f9b34fb`
- **Format:** Variable length

**Commands:**
- **Calibrate Sensors:** `0x01 0x00`
- **Set Haptic Intensity:** `0x02 [0x00-0xFF]`
  - Example: `0x02 0x64` = 100% intensity
- **Trigger Haptic Pulse:** `0x03 [duration_ms]`
  - Example: `0x03 0xC8` = 200ms pulse
- **Set Sampling Rate:** `0x04 [rate_hz]`
  - Example: `0x04 0x32` = 50Hz

### Streaming Modes

#### Low-Power Mode (20 Hz)
- Battery Life: ~48 hours
- Packet interval: 50ms
- Recommended for: Daily tracking, casual use

#### Balanced Mode (50 Hz)
- Battery Life: ~24 hours
- Packet interval: 20ms
- Recommended for: Walking, light exercise

#### High-Fidelity Mode (100 Hz)
- Battery Life: ~12 hours
- Packet interval: 10ms
- Recommended for: Running, sports analysis, AI training

### Connection State Machine

```
IDLE → SCANNING → CONNECTING → CONNECTED → CALIBRATING → SYNCED
  ↓        ↓           ↓            ↓            ↓           ↓
  └────────┴───────────┴────────────┴────────────┴───────────┘
                  ← DISCONNECTED (any time)
```

### Sample Packet Rates

| Mode | Pressure Data | IMU Data | Battery | Total Throughput |
|------|--------------|----------|---------|------------------|
| 20Hz | 160 B/s | 120 B/s | 0.1 B/s | ~280 B/s |
| 50Hz | 400 B/s | 300 B/s | 0.1 B/s | ~700 B/s |
| 100Hz | 800 B/s | 600 B/s | 0.1 B/s | ~1400 B/s |

### Error Handling

#### Connection Lost
```javascript
if (lastPacketTimestamp > 5000) { // 5 seconds
  // Show "Connection Lost" UI
  // Attempt reconnection
  reconnect();
}
```

#### Low Battery Warning
```javascript
if (batteryLevel < 20) {
  showNotification("Low battery on insole — please charge");
}
```

#### Packet Loss Detection
```javascript
const packetRate = packetsReceived / timeElapsed;
if (packetRate < expectedRate * 0.8) {
  // Packet loss detected, may need to adjust MTU or sampling rate
}
```

## AI Model Integration

### On-Device Model
- **Framework:** TensorFlow Lite / ONNX Runtime
- **Input:** 200-sample window (4 pressure sensors + 3 IMU axes = 7 channels)
- **Output:** 6 classes (Walking, Running, Standing, Jumping, Stairs, Cheating)
- **Inference Time:** <50ms on mobile CPU

### Model Architecture
```
Input: [batch, 200, 7]
  ↓
Conv1D(32 filters, kernel=5)
  ↓
MaxPool1D(pool=2)
  ↓
Conv1D(64 filters, kernel=3)
  ↓
MaxPool1D(pool=2)
  ↓
LSTM(128 units)
  ↓
Dense(64, ReLU)
  ↓
Dense(6, Softmax)
  ↓
Output: [batch, 6]
```

### Cheat Detection Logic

```javascript
function detectCheating(pressureData, imuData, gestureLabel, confidence) {
  // Rule 1: High vibration with low forward movement
  const vibrationIntensity = calculateVariance(imuData);
  const forwardProgression = calculateNetDisplacement(imuData);
  
  if (vibrationIntensity > THRESHOLD_HIGH && forwardProgression < THRESHOLD_LOW) {
    return {
      status: 'flagged',
      reason: 'Possible tampering: high vibration, low forward progression'
    };
  }
  
  // Rule 2: Pressure pattern doesn't match gesture
  if (gestureLabel === 'Walking' && confidence > 0.8) {
    const pressurePattern = analyzePressurePattern(pressureData);
    if (!pressurePattern.matchesWalking) {
      return {
        status: 'suspicious',
        reason: 'Pattern matches shake — low confidence'
      };
    }
  }
  
  // Rule 3: Gait inconsistency
  const gaitConsistency = compareToBaseline(pressureData, userGaitBaseline);
  if (gaitConsistency < 0.7) {
    return {
      status: 'suspicious',
      reason: 'Irregular gait pattern detected'
    };
  }
  
  return {
    status: 'verified',
    reason: ''
  };
}
```

## UI/UX Design System

### Color Palette

#### Gradients
- **Primary:** Cyan → Purple (`from-cyan-500 to-purple-600`)
- **Warning:** Amber → Orange (`from-amber-500 to-orange-500`)
- **Danger:** Red → Orange (`from-red-500 to-orange-500`)

#### Pressure Heatmap
- **Low (0-30%):** Blue `#3b82f6`
- **Medium (30-60%):** Yellow `#eab308`
- **Medium-High (60-80%):** Orange `#f97316`
- **High (80-100%):** Red `#ef4444`

#### Sensor Indicators
- **Heel:** Red/Orange
- **Arch:** Yellow
- **Ball:** Orange
- **Toes:** Blue

### Accessibility

#### Color-Blind Mode
When enabled, use patterns + numeric values instead of color-only indicators:
```javascript
if (colorBlindMode) {
  return (
    <div>
      <Pattern type={pressureLevel} />
      <span>{pressureValue}N</span>
    </div>
  );
}
```

## Blockchain Integration

### Smart Contract (Simplified)

```solidity
contract StepSignRewards {
  mapping(address => uint256) public stakedAmount;
  mapping(address => uint256) public pendingRewards;
  mapping(address => uint256) public lockEndTime;
  
  uint256 public constant LOCK_PERIOD = 30 days;
  uint256 public constant EARLY_WITHDRAWAL_PENALTY = 10; // 10%
  
  function stake(uint256 amount) external {
    // Transfer STEP tokens from user
    token.transferFrom(msg.sender, address(this), amount);
    
    stakedAmount[msg.sender] += amount;
    lockEndTime[msg.sender] = block.timestamp + LOCK_PERIOD;
  }
  
  function addReward(address user, uint256 amount) external onlyOracle {
    pendingRewards[user] += amount;
  }
  
  function applyPenalty(address user, uint256 amount) external onlyOracle {
    pendingRewards[user] -= amount;
  }
  
  function withdraw() external {
    require(pendingRewards[msg.sender] > 0, "No rewards");
    
    uint256 amount = pendingRewards[msg.sender];
    pendingRewards[msg.sender] = 0;
    
    token.transfer(msg.sender, amount);
  }
}
```

### Oracle Integration
The app should send verified session data to an oracle service that interacts with the smart contract:

```javascript
async function submitVerifiedSession(sessionData) {
  const signature = await signSessionData(sessionData, privateKey);
  
  const response = await fetch('https://api.stepsign.io/oracle/submit', {
    method: 'POST',
    body: JSON.stringify({
      user: walletAddress,
      sessionId: sessionData.id,
      steps: sessionData.verifiedSteps,
      confidence: sessionData.averageConfidence,
      signature: signature
    })
  });
  
  if (response.ok) {
    const tx = await response.json();
    // Show transaction confirmation in UI
    showNotification(`🎉 Goal verified — ${reward} STEP tokens added to your wallet`);
  }
}
```

## Performance Optimization

### Rendering Optimization
- Heatmap updates: throttle to 30 FPS max
- IMU 3D viewer: throttle to 60 FPS
- Packet inspector: virtual scrolling for >100 packets

### Memory Management
```javascript
// Limit stored sensor data
const MAX_DATA_POINTS = 1000;
if (sensorDataBuffer.length > MAX_DATA_POINTS) {
  sensorDataBuffer = sensorDataBuffer.slice(-MAX_DATA_POINTS);
}
```

### Battery Optimization
- Use BLE notifications instead of polling
- Batch packet writes when possible
- Implement connection interval negotiation

## Testing Recommendations

### Mock Data Generation
```javascript
function generateMockPressureData(gesture, timestamp) {
  const baseValues = {
    Walking: { heel: 60, arch: 30, ball: 50, toes: 25 },
    Running: { heel: 90, arch: 40, ball: 80, toes: 35 },
    Standing: { heel: 40, arch: 20, ball: 30, toes: 15 },
  };
  
  const base = baseValues[gesture];
  const noise = () => (Math.random() - 0.5) * 10;
  
  return {
    heel: base.heel + noise(),
    arch: base.arch + noise(),
    ball: base.ball + noise(),
    toes: base.toes + noise(),
    timestamp: timestamp
  };
}
```

### Test Scenarios
1. **Normal Walking:** Consistent pressure patterns, forward IMU movement
2. **Shoe Shaking:** High vibration, low forward movement, irregular pressure
3. **Connection Loss:** Packet gaps >3 seconds
4. **Low Battery:** Gradual decline, warnings at 20%, 10%, 5%
5. **Gait Change:** User switches from walking to running mid-session

## Future Enhancements

### Planned Features
- [ ] Multi-insole support (>2 pairs)
- [ ] Social leaderboards
- [ ] Injury risk prediction
- [ ] Gait coaching with real-time feedback
- [ ] Integration with health apps (Apple Health, Google Fit)
- [ ] Firmware OTA updates via BLE
- [ ] ML model versioning and A/B testing

### API Endpoints (Future)
```
POST /api/v1/sessions/submit
GET  /api/v1/leaderboard
GET  /api/v1/user/stats
POST /api/v1/dispute/create
GET  /api/v1/wallet/balance
POST /api/v1/wallet/stake
POST /api/v1/wallet/withdraw
```

## Support & Resources

- **Firmware Repository:** https://github.com/stepsign/firmware
- **AI Model Repository:** https://github.com/stepsign/ai-models
- **Smart Contract:** https://etherscan.io/address/0x...
- **Developer Discord:** https://discord.gg/stepsign
- **Documentation:** https://docs.stepsign.io

---

**Last Updated:** November 14, 2025
**Version:** 1.0.0
