# StepSign ESP32 BLE Firmware

This firmware runs on an ESP32-WROOM-32 and streams sensor data to the StepSign mobile app via Bluetooth Low Energy (BLE).

## Hardware Requirements

- **ESP32-WROOM-32 Dev Board** (or compatible)
- **MPU-6050 IMU** (I2C)
- **4x FSR Sensors** (Force Sensitive Resistors)
- **Vibration Motor** (for haptic feedback)

## Wiring

| Component | ESP32 Pin | Notes |
|-----------|-----------|-------|
| MPU-6050 SDA | GPIO 21 | I2C Data |
| MPU-6050 SCL | GPIO 22 | I2C Clock |
| MPU-6050 VCC | 3.3V | |
| MPU-6050 GND | GND | |
| FSR 1 (Heel) | GPIO 34 | ADC input |
| FSR 2 (Arch) | GPIO 15 | ADC input |
| FSR 3 (Ball) | GPIO 2 | ADC input (also onboard LED) |
| FSR 4 (Toes) | GPIO 4 | ADC input |
| Vibration Motor + | GPIO 5 | Via transistor/MOSFET |
| Vibration Motor - | GND | |

> **Note:** GPIO 2 and GPIO 15 have boot-mode implications. If you experience boot issues, you can remap these to other ADC-capable pins (32, 33, 35, 36, 39).

## FSR Wiring

Each FSR should be wired as a voltage divider:

```
3.3V ──┬── FSR ──┬── 10kΩ ──┬── GND
       │         │          │
       └─────────┴── ADC Pin
```

## Vibration Motor Wiring

Use a transistor or MOSFET to drive the motor:

```
GPIO 5 ── 1kΩ ──┬── Base (NPN transistor)
                │
                └── Collector ── Motor - ── GND
                    │
                    Emitter ── GND
                    
Motor + ── 5V (or 3.3V depending on motor)
```

Add a flyback diode across the motor terminals.

## Flashing the Firmware

### Using Arduino IDE

1. Install [Arduino IDE](https://www.arduino.cc/en/software)
2. Add ESP32 board support:
   - Go to **File → Preferences**
   - Add to "Additional Boards Manager URLs":
     ```
     https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
     ```
   - Go to **Tools → Board → Boards Manager**
   - Search for "ESP32" and install "esp32 by Espressif Systems"
3. Select board: **Tools → Board → ESP32 Dev Module**
4. Select port: **Tools → Port → (your ESP32 COM port)**
5. Open `firmware/stepsign_ble/stepsign_ble.ino`
6. Click **Upload**

### Using PlatformIO

1. Install [VS Code](https://code.visualstudio.com/) and the PlatformIO extension
2. Create a new project or use this `platformio.ini`:

```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200
```

3. Copy `stepsign_ble.ino` to `src/main.cpp`
4. Build and upload

## BLE Service Details

| UUID | Name | Properties | Description |
|------|------|------------|-------------|
| `12345678-1234-5678-1234-56789abcdef0` | StepSign Service | - | Main service |
| `12345678-1234-5678-1234-56789abcdef1` | Sensor Data | Notify | 20-byte sensor frames at 50Hz |
| `12345678-1234-5678-1234-56789abcdef2` | Device Info | Read | Battery, firmware version |
| `12345678-1234-5678-1234-56789abcdef3` | Haptic Command | Write | Control vibration motor |

### Sensor Data Format (20 bytes)

```c
struct SensorFrame {
    int16_t ax;      // Accelerometer X (raw, ±2g = ±16384)
    int16_t ay;      // Accelerometer Y
    int16_t az;      // Accelerometer Z
    int16_t gx;      // Gyroscope X (raw, ±250°/s = ±131)
    int16_t gy;      // Gyroscope Y
    int16_t gz;      // Gyroscope Z
    uint16_t fsr[4]; // FSR values (0-4095 ADC)
};
```

### Haptic Command Format

| Byte | Description |
|------|-------------|
| 0 | Intensity (0-255, PWM value) |
| 1 | Duration high byte (optional) |
| 2 | Duration low byte (optional) |

Default duration is 200ms if not specified.

## Serial Monitor

Connect at 115200 baud to see debug output:

```
=== StepSign Smart Insole ===
Firmware: 1.0.0
MPU-6050 WHO_AM_I: 0x68
MPU-6050: OK
FSR sensors: OK
Vibration motor: OK
Initializing BLE...
BLE: Advertising started
BLE: Device name: StepSign-001
=== Ready ===
```

## Customization

### Change Device Name

Edit `DEVICE_NAME` in the firmware:

```cpp
#define DEVICE_NAME "StepSign-001"
```

### Change Sample Rate

Edit `SAMPLE_RATE_HZ` (supported: 20, 50, 100):

```cpp
#define SAMPLE_RATE_HZ 50
```

### Remap FSR Pins

Edit the `FSR_PINS` array:

```cpp
static constexpr int FSR_PINS[] = {34, 35, 32, 33}; // Alternative pins
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| MPU-6050 not found | Check I2C wiring, ensure AD0 pin is grounded |
| Boot loops | GPIO 2/15 may be conflicting; remap FSR pins |
| No BLE advertising | Ensure ESP32 has BLE support (not ESP32-S2) |
| FSR readings stuck at 0 or 4095 | Check voltage divider wiring |
| Vibration motor not working | Check transistor wiring and GPIO 5 connection |

