import 'dart:typed_data';

/// BLE UUIDs matching the ESP32 firmware
class StepSignBleUuids {
  static const String serviceUuid = '12345678-1234-5678-1234-56789abcdef0';
  static const String sensorDataUuid = '12345678-1234-5678-1234-56789abcdef1';
  static const String deviceInfoUuid = '12345678-1234-5678-1234-56789abcdef2';
  static const String hapticCmdUuid = '12345678-1234-5678-1234-56789abcdef3';
}

/// Raw sensor frame from ESP32 (20 bytes)
/// Matches the C struct:
/// ```c
/// struct SensorFrame {
///   int16_t ax, ay, az;    // Accelerometer (6 bytes)
///   int16_t gx, gy, gz;    // Gyroscope (6 bytes)
///   uint16_t fsr[4];       // FSR values (8 bytes)
/// };
/// ```
class SensorFrame {
  /// Accelerometer values in raw units (±2g = ±16384)
  final int ax, ay, az;
  
  /// Gyroscope values in raw units (±250°/s = ±131)
  final int gx, gy, gz;
  
  /// FSR values (0-4095 ADC)
  final List<int> fsr;
  
  /// Timestamp when this frame was received
  final DateTime timestamp;

  SensorFrame({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.fsr,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Parse from 20-byte BLE notification payload
  factory SensorFrame.fromBytes(List<int> bytes) {
    if (bytes.length < 20) {
      throw ArgumentError('SensorFrame requires 20 bytes, got ${bytes.length}');
    }

    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    
    // Read int16 values (little-endian)
    final ax = data.getInt16(0, Endian.little);
    final ay = data.getInt16(2, Endian.little);
    final az = data.getInt16(4, Endian.little);
    final gx = data.getInt16(6, Endian.little);
    final gy = data.getInt16(8, Endian.little);
    final gz = data.getInt16(10, Endian.little);
    
    // Read uint16 FSR values (little-endian)
    final fsr = <int>[
      data.getUint16(12, Endian.little),
      data.getUint16(14, Endian.little),
      data.getUint16(16, Endian.little),
      data.getUint16(18, Endian.little),
    ];

    return SensorFrame(
      ax: ax,
      ay: ay,
      az: az,
      gx: gx,
      gy: gy,
      gz: gz,
      fsr: fsr,
    );
  }

  /// Convert accelerometer to g (assuming ±2g range)
  double get axG => ax / 16384.0;
  double get ayG => ay / 16384.0;
  double get azG => az / 16384.0;

  /// Convert gyroscope to degrees per second (assuming ±250°/s range)
  double get gxDps => gx / 131.0;
  double get gyDps => gy / 131.0;
  double get gzDps => gz / 131.0;

  /// Get FSR values as normalized percentages (0.0 - 1.0)
  List<double> get fsrNormalized => fsr.map((v) => v / 4095.0).toList();

  /// Get FSR values mapped to pressure names
  Map<String, double> get pressureMap => {
    'heel': fsrNormalized[0] * 100,
    'arch': fsrNormalized[1] * 100,
    'ball': fsrNormalized[2] * 100,
    'toes': fsrNormalized[3] * 100,
  };

  /// Calculate pitch angle from accelerometer (degrees)
  double get pitch {
    return _atan2(-ax, _sqrt(ay * ay + az * az)) * 180.0 / 3.14159;
  }

  /// Calculate roll angle from accelerometer (degrees)
  double get roll {
    return _atan2(ay, az) * 180.0 / 3.14159;
  }

  double _atan2(num y, num x) {
    if (x == 0 && y == 0) return 0;
    return y.toDouble().atan2(x.toDouble());
  }

  double _sqrt(num x) => x.toDouble().abs().sqrt();

  @override
  String toString() {
    return 'SensorFrame(ax=$ax, ay=$ay, az=$az, gx=$gx, gy=$gy, gz=$gz, fsr=$fsr)';
  }
}

/// Device info from ESP32 (6 bytes)
class DeviceInfo {
  final int batteryPercent;
  final String firmwareVersion;
  final bool isCalibrated;
  final int sampleRateHz;

  DeviceInfo({
    required this.batteryPercent,
    required this.firmwareVersion,
    required this.isCalibrated,
    required this.sampleRateHz,
  });

  factory DeviceInfo.fromBytes(List<int> bytes) {
    if (bytes.length < 6) {
      throw ArgumentError('DeviceInfo requires 6 bytes, got ${bytes.length}');
    }

    return DeviceInfo(
      batteryPercent: bytes[0],
      firmwareVersion: 'v${bytes[1]}.${bytes[2]}.${bytes[3]}',
      isCalibrated: bytes[4] != 0,
      sampleRateHz: bytes[5],
    );
  }

  @override
  String toString() {
    return 'DeviceInfo(battery=$batteryPercent%, firmware=$firmwareVersion, calibrated=$isCalibrated, rate=${sampleRateHz}Hz)';
  }
}

/// Haptic command to send to ESP32
class HapticCommand {
  /// Intensity 0-255 (PWM value)
  final int intensity;
  
  /// Duration in milliseconds
  final int durationMs;

  HapticCommand({
    required this.intensity,
    this.durationMs = 200,
  });

  /// Convert to bytes for BLE write
  List<int> toBytes() {
    return [
      intensity & 0xFF,
      (durationMs >> 8) & 0xFF,
      durationMs & 0xFF,
    ];
  }

  /// Quick vibration (50% intensity, 100ms)
  factory HapticCommand.tap() => HapticCommand(intensity: 128, durationMs: 100);

  /// Strong vibration (100% intensity, 200ms)
  factory HapticCommand.strong() => HapticCommand(intensity: 255, durationMs: 200);

  /// Gentle vibration (25% intensity, 150ms)
  factory HapticCommand.gentle() => HapticCommand(intensity: 64, durationMs: 150);
}

/// Extension for atan2 on double
extension on double {
  double atan2(double other) {
    if (this == 0 && other == 0) return 0;
    // Using dart:math would require import, so manual calculation
    // This is a simplified version
    if (other > 0) {
      return _atan(this / other);
    } else if (other < 0) {
      if (this >= 0) {
        return _atan(this / other) + 3.14159;
      } else {
        return _atan(this / other) - 3.14159;
      }
    } else {
      return this > 0 ? 1.5708 : -1.5708;
    }
  }

  double _atan(double x) {
    // Taylor series approximation for atan
    if (x.abs() > 1) {
      return 1.5708 - _atan(1 / x);
    }
    double result = 0;
    double term = x;
    for (int i = 1; i <= 15; i += 2) {
      result += term / i;
      term *= -x * x;
    }
    return result;
  }

  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;
    double x = this;
    double y = (x + 1) / 2;
    while ((y - x / y).abs() > 0.0001) {
      y = (y + x / y) / 2;
    }
    return y;
  }
}

