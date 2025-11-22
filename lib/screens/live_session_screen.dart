import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:stepsign_mobile_app/widgets/heatmap_full.dart';
import 'package:stepsign_mobile_app/widgets/imu_orientation_mini.dart';

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
  int _sessionSeconds = 0;
  int _stepCount = 0;
  String _currentGesture = 'Walking';
  double _confidence = 0.92;
  String _cheatStatus = 'verified';
  double _hapticIntensity = 0.5;
  
  Timer? _sessionTimer;
  Timer? _dataUpdateTimer;
  final _random = math.Random();
  
  Map<String, double> _sensorData = {
    'heel': 45.0,
    'arch': 32.0,
    'ball': 68.0,
    'toes': 28.0,
  };

  Map<String, double> _imuData = {
    'pitch': 5.0,
    'roll': -2.0,
    'yaw': 0.0,
  };

  List<double> _waveformData = List.generate(50, (index) => 0.0);

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    // Session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sessionSeconds++;
        if (_random.nextDouble() > 0.7) {
          _stepCount++;
        }
      });
    });

    // Data update timer (30 FPS)
    _dataUpdateTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      setState(() {
        // Update sensor data
        _sensorData = {
          'heel': 30 + _random.nextDouble() * 40,
          'arch': 20 + _random.nextDouble() * 30,
          'ball': 50 + _random.nextDouble() * 40,
          'toes': 15 + _random.nextDouble() * 25,
        };

        // Update IMU data
        _imuData = {
          'pitch': -10 + _random.nextDouble() * 20,
          'roll': -5 + _random.nextDouble() * 10,
          'yaw': -3 + _random.nextDouble() * 6,
        };

        // Update waveform
        _waveformData.removeAt(0);
        _waveformData.add(_random.nextDouble());

        // Randomly update gesture
        if (_random.nextDouble() > 0.95) {
          final gestures = ['Walking', 'Running', 'Standing', 'Jumping'];
          _currentGesture = gestures[_random.nextInt(gestures.length)];
          _confidence = 0.85 + _random.nextDouble() * 0.14;
        }

        // Randomly update cheat status
        if (_random.nextDouble() > 0.98) {
          final statuses = ['verified', 'suspicious', 'flagged'];
          _cheatStatus = statuses[_random.nextInt(statuses.length)];
        }
      });
    });
  }

  void _endSession() {
    _sessionTimer?.cancel();
    _dataUpdateTimer?.cancel();
    widget.onBack();
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
                          'Real-time monitoring',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF22C55E),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

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
                'Live Waveform',
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

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
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

