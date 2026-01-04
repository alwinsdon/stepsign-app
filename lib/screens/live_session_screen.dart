import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../widgets/heatmap_full.dart';
import '../widgets/imu_orientation_mini.dart';
import '../services/ble_service.dart';
import '../models/sensor_data.dart';

class LiveSessionScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LiveSessionScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  final BleService _bleService = BleService();
  
  int _sessionSeconds = 0;
  int _stepCount = 0;
  String _currentGesture = 'Idle';
  double _confidence = 0.0;
  String _cheatStatus = 'verified';
  double _hapticIntensity = 0.5;
  
  Timer? _sessionTimer;
  StreamSubscription? _sensorSubscription;
  
  // Sensor data from BLE
  Map<String, double> _sensorData = {
    'heel': 0.0,
    'arch': 0.0,
    'ball': 0.0,
    'toes': 0.0,
  };

  Map<String, double> _imuData = {
    'pitch': 0.0,
    'roll': 0.0,
    'yaw': 0.0,
  };

  // Waveform data (last 50 samples of vertical acceleration)
  final List<double> _waveformData = List.generate(50, (index) => 0.5);
  
  // Step detection
  double _lastAz = 0;
  bool _stepPhase = false;
  int _stepCooldown = 0;
  static const double _stepThreshold = 0.3; // g threshold for step detection

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _startSession() {
    // Session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sessionSeconds++;
      });
    });

    // Subscribe to real sensor data
    _sensorSubscription = _bleService.sensorDataStream.listen(_onSensorData);
    
    // Haptic feedback to indicate session started
    _bleService.tapHaptic();
  }

  void _onSensorData(SensorFrame frame) {
    setState(() {
      // Update pressure data from FSR sensors
      _sensorData = frame.pressureMap;

      // Update IMU orientation
      _imuData = {
        'pitch': frame.pitch,
        'roll': frame.roll,
        'yaw': 0.0, // Yaw requires magnetometer or gyro integration
      };

      // Update waveform with vertical acceleration (normalized to 0-1 range)
      final normalizedAz = (frame.azG + 2) / 4; // Map -2g to +2g → 0 to 1
      _waveformData.removeAt(0);
      _waveformData.add(normalizedAz.clamp(0.0, 1.0));

      // Simple step detection based on vertical acceleration
      _detectStep(frame.azG);

      // Simple gesture classification based on sensor data
      _classifyGesture(frame);

      // Update cheat detection status based on sensor patterns
      _updateCheatStatus(frame);
    });
  }

  void _detectStep(double az) {
    // Simple step detection: look for significant vertical acceleration changes
    if (_stepCooldown > 0) {
      _stepCooldown--;
      return;
    }

    final deltaAz = (az - _lastAz).abs();
    _lastAz = az;

    if (deltaAz > _stepThreshold) {
      if (!_stepPhase) {
        _stepPhase = true;
      }
    } else if (_stepPhase) {
      _stepPhase = false;
      _stepCount++;
      _stepCooldown = 10; // ~200ms cooldown at 50Hz
      
      // Trigger subtle haptic on step (optional, can be disabled for battery)
      // _bleService.sendHaptic(HapticCommand(intensity: 32, durationMs: 20));
    }
  }

  void _classifyGesture(SensorFrame frame) {
    // Simple rule-based gesture classification
    final totalPressure = frame.fsrNormalized.reduce((a, b) => a + b);
    final accelMagnitude = math.sqrt(
      frame.axG * frame.axG + frame.ayG * frame.ayG + frame.azG * frame.azG
    );

    if (totalPressure < 0.1) {
      _currentGesture = 'Idle';
      _confidence = 0.95;
    } else if (accelMagnitude > 1.5) {
      _currentGesture = 'Running';
      _confidence = 0.75 + (accelMagnitude - 1.5) * 0.1;
    } else if (accelMagnitude > 1.1) {
      _currentGesture = 'Walking';
      _confidence = 0.85 + (accelMagnitude - 1.1) * 0.2;
    } else {
      _currentGesture = 'Standing';
      _confidence = 0.90;
    }
    _confidence = _confidence.clamp(0.0, 0.99);
  }

  void _updateCheatStatus(SensorFrame frame) {
    // Simple cheat detection heuristics
    // In production, this would be done by ML model on backend
    
    final fsrValues = frame.fsr;
    final hasZeroVariance = fsrValues.every((v) => v == fsrValues[0]);
    final allMaxed = fsrValues.every((v) => v > 4000);
    final allZero = fsrValues.every((v) => v < 50);

    if (hasZeroVariance && !allZero) {
      // Suspicious: all sensors reading exact same non-zero value
      _cheatStatus = 'suspicious';
    } else if (allMaxed) {
      // Flagged: all sensors maxed out (possible tampering)
      _cheatStatus = 'flagged';
    } else {
      _cheatStatus = 'verified';
    }
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _sensorSubscription?.cancel();
    
    // Strong haptic to indicate session ended
    _bleService.strongHaptic();
    
    widget.onBack();
  }

  void _testHaptic() {
    final intensity = (_hapticIntensity * 255).toInt();
    _bleService.sendHaptic(HapticCommand(intensity: intensity, durationMs: 300));
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getCheatStatusColor() {
    switch (_cheatStatus) {
      case 'verified':
        return const Color(0xFF22C55E);
      case 'suspicious':
        return const Color(0xFFF59E0B);
      case 'flagged':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  bool get _isConnected => _bleService.connectionState == BleConnectionState.connected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: _endSession,
                    icon: const Icon(Icons.close),
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Session',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          _isConnected ? 'Real-time monitoring' : 'Device disconnected',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _isConnected 
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFFEF4444),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnected ? 'LIVE' : 'OFFLINE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _isConnected ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Connection warning if disconnected
              if (!_isConnected) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth_disabled, color: Color(0xFFEF4444)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Device disconnected. Go back to pairing screen to reconnect.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFEF4444),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Session Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      label: 'Time',
                      value: _formatTime(_sessionSeconds),
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.directions_walk,
                      label: 'Steps',
                      value: _stepCount.toString(),
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Current Gesture
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF06B6D4).withOpacity(0.1),
                      const Color(0xFFA855F7).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Gesture',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentGesture,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Confidence',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_confidence * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF06B6D4),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _confidence,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF06B6D4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cheat Detection Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getCheatStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getCheatStatusColor().withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _cheatStatus == 'verified'
                          ? Icons.verified_outlined
                          : _cheatStatus == 'suspicious'
                              ? Icons.warning_outlined
                              : Icons.error_outline,
                      color: _getCheatStatusColor(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cheat Detection',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                          Text(
                            _cheatStatus.toUpperCase(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _getCheatStatusColor(),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Live Waveform
              Text(
                'Vertical Acceleration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                  ),
                ),
                child: CustomPaint(
                  painter: _WaveformPainter(data: _waveformData),
                  size: const Size(double.infinity, 68),
                ),
              ),
              const SizedBox(height: 32),

              // Pressure Heatmap
              Text(
                'Pressure Heatmap',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Center(
                child: HeatmapFull(sensorData: _sensorData),
              ),
              const SizedBox(height: 32),

              // IMU Orientation
              Text(
                'IMU Orientation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              IMUOrientationMini(imuData: _imuData),
              const SizedBox(height: 32),

              // Haptic Controls
              Text(
                'Haptic Feedback',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Intensity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${(_hapticIntensity * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: const Color(0xFFA855F7),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _hapticIntensity,
                      onChanged: (value) {
                        setState(() {
                          _hapticIntensity = value;
                        });
                      },
                      activeColor: const Color(0xFFA855F7),
                      inactiveColor: const Color(0xFF334155),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isConnected ? _testHaptic : null,
                        icon: const Icon(Icons.vibration),
                        label: const Text('Test Vibration'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFA855F7),
                          side: const BorderSide(color: Color(0xFFA855F7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Raw Sensor Values (Debug)
              if (_bleService.latestFrame != null) ...[
                Text(
                  'Raw Sensor Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF334155).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RawDataRow(
                        label: 'Accel (g)',
                        values: [
                          'X: ${_bleService.latestFrame!.axG.toStringAsFixed(2)}',
                          'Y: ${_bleService.latestFrame!.ayG.toStringAsFixed(2)}',
                          'Z: ${_bleService.latestFrame!.azG.toStringAsFixed(2)}',
                        ],
                      ),
                      const SizedBox(height: 8),
                      _RawDataRow(
                        label: 'Gyro (°/s)',
                        values: [
                          'X: ${_bleService.latestFrame!.gxDps.toStringAsFixed(1)}',
                          'Y: ${_bleService.latestFrame!.gyDps.toStringAsFixed(1)}',
                          'Z: ${_bleService.latestFrame!.gzDps.toStringAsFixed(1)}',
                        ],
                      ),
                      const SizedBox(height: 8),
                      _RawDataRow(
                        label: 'FSR (raw)',
                        values: _bleService.latestFrame!.fsr
                            .map((v) => v.toString())
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // End Session Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _endSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stop, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'End Session',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _RawDataRow extends StatelessWidget {
  final String label;
  final List<String> values;

  const _RawDataRow({
    required this.label,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: values
                .map((v) => Text(
                      v,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: const Color(0xFF06B6D4),
                          ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;

  _WaveformPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepWidth = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepWidth;
      final y = size.height - (data[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Fill under the line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF06B6D4).withOpacity(0.3),
          const Color(0xFF06B6D4).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw center line (1g reference)
    final centerPaint = Paint()
      ..color = const Color(0xFF475569).withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return true; // Always repaint for real-time updates
  }
}
