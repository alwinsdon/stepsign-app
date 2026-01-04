/*
 * StepSign Smart Insole - BLE Firmware
 * 
 * Hardware: ESP32 + MPU-6050 IMU + 4x FSR Sensors + Vibration Motor
 * 
 * BLE Service: StepSign Sensor Service
 * - SENSOR_DATA characteristic (Notify): Streams sensor data at 50Hz
 * - DEVICE_INFO characteristic (Read): Device info and battery
 * - HAPTIC_CMD characteristic (Write): Control vibration motor
 */

#include <Wire.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// ============================================================================
// Configuration
// ============================================================================

// Device name for BLE advertising
#define DEVICE_NAME "StepSign-001"
#define FIRMWARE_VERSION "1.0.0"

// Sampling rate (Hz)
#define SAMPLE_RATE_HZ 50
#define SAMPLE_INTERVAL_MS (1000 / SAMPLE_RATE_HZ)

// MPU-6050 I2C
static constexpr uint8_t MPU6050_ADDR = 0x68;
static constexpr uint8_t REG_PWR_MGMT_1 = 0x6B;
static constexpr uint8_t REG_WHO_AM_I = 0x75;
static constexpr uint8_t REG_ACCEL_XOUT_H = 0x3B;
static constexpr uint8_t REG_ACCEL_CONFIG = 0x1C;
static constexpr uint8_t REG_GYRO_CONFIG = 0x1B;

// I2C Pins
static constexpr int SDA_PIN = 21;
static constexpr int SCL_PIN = 22;

// FSR sensor pins (ADC)
static constexpr int FSR_PINS[] = {34, 15, 2, 4};
static constexpr int FSR_COUNT = 4;

// Vibration motor pin
static constexpr int VIBRATION_PIN = 5;

// ============================================================================
// BLE UUIDs
// ============================================================================

// Custom Service UUID for StepSign
#define SERVICE_UUID           "12345678-1234-5678-1234-56789abcdef0"
// Sensor Data Characteristic (Notify) - streams IMU + FSR data
#define SENSOR_DATA_UUID       "12345678-1234-5678-1234-56789abcdef1"
// Device Info Characteristic (Read) - battery, firmware, etc.
#define DEVICE_INFO_UUID       "12345678-1234-5678-1234-56789abcdef2"
// Haptic Command Characteristic (Write) - control vibration
#define HAPTIC_CMD_UUID        "12345678-1234-5678-1234-56789abcdef3"

// ============================================================================
// Data Structures
// ============================================================================

// Sensor data packet (20 bytes) - sent via BLE notify
#pragma pack(push, 1)
struct SensorFrame {
  int16_t ax;      // Accelerometer X (raw)
  int16_t ay;      // Accelerometer Y (raw)
  int16_t az;      // Accelerometer Z (raw)
  int16_t gx;      // Gyroscope X (raw)
  int16_t gy;      // Gyroscope Y (raw)
  int16_t gz;      // Gyroscope Z (raw)
  uint16_t fsr[4]; // FSR values (0-4095)
};
#pragma pack(pop)

// Device info packet
#pragma pack(push, 1)
struct DeviceInfo {
  uint8_t batteryPercent;  // 0-100
  uint8_t firmwareMajor;
  uint8_t firmwareMinor;
  uint8_t firmwarePatch;
  uint8_t isCalibrated;
  uint8_t sampleRateHz;
};
#pragma pack(pop)

// ============================================================================
// Global State
// ============================================================================

BLEServer* pServer = nullptr;
BLECharacteristic* pSensorDataChar = nullptr;
BLECharacteristic* pDeviceInfoChar = nullptr;
BLECharacteristic* pHapticCmdChar = nullptr;

bool deviceConnected = false;
bool oldDeviceConnected = false;
uint32_t lastSampleTime = 0;
uint32_t frameCount = 0;

// Haptic state
uint8_t hapticIntensity = 0;  // 0-255 PWM value
uint32_t hapticEndTime = 0;   // When to stop haptic

// ============================================================================
// BLE Callbacks
// ============================================================================

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    deviceConnected = true;
    Serial.println("BLE: Client connected");
  }

  void onDisconnect(BLEServer* pServer) override {
    deviceConnected = false;
    Serial.println("BLE: Client disconnected");
  }
};

class HapticCmdCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) override {
    std::string value = pCharacteristic->getValue();
    if (value.length() >= 1) {
      // Command format: [intensity] or [intensity, duration_ms_hi, duration_ms_lo]
      hapticIntensity = (uint8_t)value[0];
      
      uint16_t durationMs = 200; // Default 200ms
      if (value.length() >= 3) {
        durationMs = ((uint8_t)value[1] << 8) | (uint8_t)value[2];
      }
      
      hapticEndTime = millis() + durationMs;
      
      Serial.printf("Haptic: intensity=%d, duration=%dms\n", hapticIntensity, durationMs);
    }
  }
};

// ============================================================================
// I2C / MPU-6050 Functions
// ============================================================================

static bool i2cWriteByte(uint8_t addr, uint8_t reg, uint8_t data) {
  Wire.beginTransmission(addr);
  Wire.write(reg);
  Wire.write(data);
  return (Wire.endTransmission(true) == 0);
}

static bool i2cReadBytes(uint8_t addr, uint8_t reg, uint8_t* buf, size_t len) {
  Wire.beginTransmission(addr);
  Wire.write(reg);
  if (Wire.endTransmission(false) != 0) {
    return false;
  }
  size_t readCount = Wire.requestFrom((int)addr, (int)len, (int)true);
  if (readCount != len) {
    return false;
  }
  for (size_t i = 0; i < len; i++) {
    buf[i] = Wire.read();
  }
  return true;
}

static int16_t be16(const uint8_t hi, const uint8_t lo) {
  return (int16_t)((hi << 8) | lo);
}

bool initMPU6050() {
  // Check WHO_AM_I
  uint8_t who = 0;
  if (!i2cReadBytes(MPU6050_ADDR, REG_WHO_AM_I, &who, 1)) {
    Serial.println("MPU-6050 not found!");
    return false;
  }
  Serial.printf("MPU-6050 WHO_AM_I: 0x%02X\n", who);

  // Wake up MPU-6050 (clear sleep bit)
  if (!i2cWriteByte(MPU6050_ADDR, REG_PWR_MGMT_1, 0x00)) {
    Serial.println("Failed to wake MPU-6050");
    return false;
  }

  // Configure accelerometer: ±2g (default, most sensitive)
  i2cWriteByte(MPU6050_ADDR, REG_ACCEL_CONFIG, 0x00);
  
  // Configure gyroscope: ±250°/s (default, most sensitive)
  i2cWriteByte(MPU6050_ADDR, REG_GYRO_CONFIG, 0x00);

  delay(50);
  return true;
}

bool readMPU6050(SensorFrame& frame) {
  uint8_t raw[14] = {0};
  if (!i2cReadBytes(MPU6050_ADDR, REG_ACCEL_XOUT_H, raw, sizeof(raw))) {
    return false;
  }

  frame.ax = be16(raw[0], raw[1]);
  frame.ay = be16(raw[2], raw[3]);
  frame.az = be16(raw[4], raw[5]);
  // raw[6], raw[7] = temperature (skip)
  frame.gx = be16(raw[8], raw[9]);
  frame.gy = be16(raw[10], raw[11]);
  frame.gz = be16(raw[12], raw[13]);

  return true;
}

// ============================================================================
// FSR Functions
// ============================================================================

void readFSRs(SensorFrame& frame) {
  for (int i = 0; i < FSR_COUNT; i++) {
    frame.fsr[i] = (uint16_t)analogRead(FSR_PINS[i]);
  }
}

// ============================================================================
// Battery Reading (simulated - replace with actual ADC reading if available)
// ============================================================================

uint8_t readBatteryPercent() {
  // TODO: If you have a battery voltage divider on an ADC pin, read it here
  // For now, return 100% (USB powered)
  return 100;
}

// ============================================================================
// Haptic Control
// ============================================================================

void updateHaptic() {
  if (millis() < hapticEndTime && hapticIntensity > 0) {
    // PWM output for vibration motor
    analogWrite(VIBRATION_PIN, hapticIntensity);
  } else {
    analogWrite(VIBRATION_PIN, 0);
    hapticIntensity = 0;
  }
}

// ============================================================================
// BLE Setup
// ============================================================================

void setupBLE() {
  Serial.println("Initializing BLE...");

  // Initialize BLE
  BLEDevice::init(DEVICE_NAME);
  
  // Create BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  // Create BLE Service
  BLEService* pService = pServer->createService(SERVICE_UUID);

  // Create Sensor Data Characteristic (Notify)
  pSensorDataChar = pService->createCharacteristic(
    SENSOR_DATA_UUID,
    BLECharacteristic::PROPERTY_NOTIFY
  );
  pSensorDataChar->addDescriptor(new BLE2902());

  // Create Device Info Characteristic (Read)
  pDeviceInfoChar = pService->createCharacteristic(
    DEVICE_INFO_UUID,
    BLECharacteristic::PROPERTY_READ
  );
  
  // Set initial device info
  DeviceInfo info;
  info.batteryPercent = readBatteryPercent();
  info.firmwareMajor = 1;
  info.firmwareMinor = 0;
  info.firmwarePatch = 0;
  info.isCalibrated = 1;
  info.sampleRateHz = SAMPLE_RATE_HZ;
  pDeviceInfoChar->setValue((uint8_t*)&info, sizeof(info));

  // Create Haptic Command Characteristic (Write)
  pHapticCmdChar = pService->createCharacteristic(
    HAPTIC_CMD_UUID,
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
  );
  pHapticCmdChar->setCallbacks(new HapticCmdCallbacks());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // For iPhone compatibility
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("BLE: Advertising started");
  Serial.printf("BLE: Device name: %s\n", DEVICE_NAME);
}

// ============================================================================
// Setup
// ============================================================================

void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("\n=== StepSign Smart Insole ===");
  Serial.printf("Firmware: %s\n", FIRMWARE_VERSION);

  // Initialize I2C
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(400000);

  // Initialize MPU-6050
  if (!initMPU6050()) {
    Serial.println("FATAL: MPU-6050 initialization failed!");
    while (true) {
      delay(1000);
    }
  }
  Serial.println("MPU-6050: OK");

  // Initialize FSR pins
  for (int i = 0; i < FSR_COUNT; i++) {
    pinMode(FSR_PINS[i], INPUT);
  }
  Serial.println("FSR sensors: OK");

  // Initialize vibration motor pin
  pinMode(VIBRATION_PIN, OUTPUT);
  digitalWrite(VIBRATION_PIN, LOW);
  Serial.println("Vibration motor: OK");

  // Quick haptic test
  analogWrite(VIBRATION_PIN, 128);
  delay(100);
  analogWrite(VIBRATION_PIN, 0);

  // Setup BLE
  setupBLE();

  Serial.println("=== Ready ===\n");
}

// ============================================================================
// Main Loop
// ============================================================================

void loop() {
  uint32_t now = millis();

  // Handle connection state changes
  if (!deviceConnected && oldDeviceConnected) {
    // Disconnected - restart advertising
    delay(500);
    pServer->startAdvertising();
    Serial.println("BLE: Restarted advertising");
    oldDeviceConnected = deviceConnected;
  }
  if (deviceConnected && !oldDeviceConnected) {
    // Just connected
    oldDeviceConnected = deviceConnected;
  }

  // Sample and send sensor data at configured rate
  if (now - lastSampleTime >= SAMPLE_INTERVAL_MS) {
    lastSampleTime = now;

    SensorFrame frame;
    
    // Read IMU
    if (!readMPU6050(frame)) {
      Serial.println("Warning: Failed to read MPU-6050");
      frame.ax = frame.ay = frame.az = 0;
      frame.gx = frame.gy = frame.gz = 0;
    }

    // Read FSRs
    readFSRs(frame);

    // Send via BLE if connected
    if (deviceConnected) {
      pSensorDataChar->setValue((uint8_t*)&frame, sizeof(frame));
      pSensorDataChar->notify();
      
      frameCount++;
      if (frameCount % 50 == 0) {  // Log every second
        Serial.printf("Sent %lu frames | ax=%d ay=%d az=%d | fsr=[%d,%d,%d,%d]\n",
          frameCount, frame.ax, frame.ay, frame.az,
          frame.fsr[0], frame.fsr[1], frame.fsr[2], frame.fsr[3]);
      }
    }

    // Update device info periodically
    if (frameCount % 500 == 0) {  // Every 10 seconds
      DeviceInfo info;
      info.batteryPercent = readBatteryPercent();
      info.firmwareMajor = 1;
      info.firmwareMinor = 0;
      info.firmwarePatch = 0;
      info.isCalibrated = 1;
      info.sampleRateHz = SAMPLE_RATE_HZ;
      pDeviceInfoChar->setValue((uint8_t*)&info, sizeof(info));
    }
  }

  // Update haptic feedback
  updateHaptic();
}


