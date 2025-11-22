import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class Viewer3DScreen extends StatefulWidget {
  final VoidCallback onBack;

  const Viewer3DScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<Viewer3DScreen> createState() => _Viewer3DScreenState();
}

class _Viewer3DScreenState extends State<Viewer3DScreen> with SingleTickerProviderStateMixin {
  double _pitch = 5.0;
  double _roll = -2.0;
  double _yaw = 0.0;
  bool _isPlaying = false;
  double _playbackPosition = 0.0;
  double _playbackSpeed = 1.0;
  bool _showWireframe = false;
  bool _showSensors = true;
  bool _autoRotate = false;

  late AnimationController _rotationController;
  Timer? _dataTimer;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        if (_autoRotate) {
          setState(() {
            _yaw = _rotationController.value * 360;
          });
        }
      });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _dataTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _dataTimer = Timer.periodic(Duration(milliseconds: (100 / _playbackSpeed).round()), (timer) {
        setState(() {
          _playbackPosition = (_playbackPosition + 0.01).clamp(0.0, 1.0);
          if (_playbackPosition >= 1.0) {
            _isPlaying = false;
            timer.cancel();
          }

          // Simulate IMU data changes
          _pitch = -15 + _random.nextDouble() * 30;
          _roll = -10 + _random.nextDouble() * 20;
          if (!_autoRotate) {
            _yaw = -5 + _random.nextDouble() * 10;
          }
        });
      });
    } else {
      _dataTimer?.cancel();
    }
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
    });

    if (_autoRotate) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
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
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3D Orientation Viewer',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'IMU data visualization',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3D Viewer
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155).withOpacity(0.5),
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridBackgroundPainter(),
                      ),
                    ),
                    // 3D Insole
                    Center(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_pitch * math.pi / 180)
                          ..rotateY(_yaw * math.pi / 180)
                          ..rotateZ(_roll * math.pi / 180),
                        alignment: Alignment.center,
                        child: Container(
                          width: 120,
                          height: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF06B6D4).withOpacity(_showWireframe ? 0.1 : 0.3),
                                const Color(0xFFA855F7).withOpacity(_showWireframe ? 0.1 : 0.3),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFF06B6D4),
                              width: _showWireframe ? 2 : 1,
                            ),
                          ),
                          child: _showSensors
                              ? Stack(
                                  children: [
                                    // Sensor dots
                                    Positioned(
                                      top: 24,
                                      left: 60 - 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF06B6D4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 84,
                                      left: 60 - 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF06B6D4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 144,
                                      left: 60 - 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF06B6D4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 204,
                                      left: 60 - 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF06B6D4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    // Axis labels
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _AxisLabel(color: const Color(0xFF06B6D4), label: 'X'),
                          const SizedBox(height: 4),
                          _AxisLabel(color: const Color(0xFFA855F7), label: 'Y'),
                          const SizedBox(height: 4),
                          _AxisLabel(color: const Color(0xFFEC4899), label: 'Z'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // IMU Data Display
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
                    _IMUDataRow(
                      label: 'Pitch',
                      value: _pitch.toStringAsFixed(1),
                      color: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 12),
                    _IMUDataRow(
                      label: 'Roll',
                      value: _roll.toStringAsFixed(1),
                      color: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 12),
                    _IMUDataRow(
                      label: 'Yaw',
                      value: _yaw.toStringAsFixed(1),
                      color: const Color(0xFFEC4899),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Playback Controls
              Text(
                'Playback Controls',
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _togglePlayback,
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          color: const Color(0xFF06B6D4),
                          iconSize: 32,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _playbackPosition = 0.0;
                              _isPlaying = false;
                              _dataTimer?.cancel();
                            });
                          },
                          icon: const Icon(Icons.stop),
                          color: const Color(0xFF94A3B8),
                          iconSize: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _playbackPosition,
                      onChanged: (value) {
                        setState(() {
                          _playbackPosition = value;
                        });
                      },
                      activeColor: const Color(0xFF06B6D4),
                      inactiveColor: const Color(0xFF334155),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(_playbackPosition * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                        Text(
                          'Speed: ${_playbackSpeed}x',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SpeedButton(
                            label: '0.5x',
                            isSelected: _playbackSpeed == 0.5,
                            onTap: () => setState(() => _playbackSpeed = 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SpeedButton(
                            label: '1x',
                            isSelected: _playbackSpeed == 1.0,
                            onTap: () => setState(() => _playbackSpeed = 1.0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SpeedButton(
                            label: '2x',
                            isSelected: _playbackSpeed == 2.0,
                            onTap: () => setState(() => _playbackSpeed = 2.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // View Options
              Text(
                'View Options',
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
                  children: [
                    _OptionRow(
                      label: 'Wireframe Mode',
                      value: _showWireframe,
                      onChanged: (value) => setState(() => _showWireframe = value),
                    ),
                    const Divider(color: Color(0xFF334155), height: 24),
                    _OptionRow(
                      label: 'Show Sensors',
                      value: _showSensors,
                      onChanged: (value) => setState(() => _showSensors = value),
                    ),
                    const Divider(color: Color(0xFF334155), height: 24),
                    _OptionRow(
                      label: 'Auto-Rotate',
                      value: _autoRotate,
                      onChanged: (value) => _toggleAutoRotate(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Manual Rotation Sliders
              Text(
                'Manual Rotation',
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
                    _RotationSlider(
                      label: 'Pitch',
                      value: _pitch,
                      onChanged: (value) => setState(() => _pitch = value),
                      color: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 16),
                    _RotationSlider(
                      label: 'Roll',
                      value: _roll,
                      onChanged: (value) => setState(() => _roll = value),
                      color: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 16),
                    _RotationSlider(
                      label: 'Yaw',
                      value: _yaw,
                      onChanged: _autoRotate
                          ? null
                          : (value) => setState(() => _yaw = value),
                      color: const Color(0xFFEC4899),
                    ),
                  ],
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

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.2)
      ..strokeWidth = 1;

    const gridSize = 40.0;
    final rows = (size.height / gridSize).ceil();
    final cols = (size.width / gridSize).ceil();

    for (int i = 0; i <= cols; i++) {
      final x = i * gridSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 0; i <= rows; i++) {
      final y = i * gridSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AxisLabel extends StatelessWidget {
  final Color color;
  final String label;

  const _AxisLabel({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ],
    );
  }
}

class _IMUDataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _IMUDataRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '$value°',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}

class _SpeedButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeedButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06B6D4).withOpacity(0.2)
              : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06B6D4)
                : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? const Color(0xFF06B6D4) : Colors.white,
              ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF06B6D4),
        ),
      ],
    );
  }
}

class _RotationSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final Color color;

  const _RotationSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${value.toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          onChanged: onChanged,
          min: -180,
          max: 180,
          activeColor: color,
          inactiveColor: const Color(0xFF334155),
        ),
      ],
    );
  }
}

