import 'package:flutter/material.dart';
import 'dart:math' as math;

class IMUOrientationMini extends StatelessWidget {
  final Map<String, double> imuData;

  const IMUOrientationMini({
    super.key,
    required this.imuData,
  });

  @override
  Widget build(BuildContext context) {
    final pitch = imuData['pitch'] ?? 0.0;
    final roll = imuData['roll'] ?? 0.0;
    final yaw = imuData['yaw'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              children: [
                // Grid background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(),
                  ),
                ),
                // 3D insole representation
                Center(
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateX(pitch * math.pi / 180)
                      ..rotateY(yaw * math.pi / 180)
                      ..rotateZ(roll * math.pi / 180),
                    alignment: Alignment.center,
                    child: Container(
                      width: 80,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF06B6D4).withOpacity(0.3),
                            const Color(0xFFA855F7).withOpacity(0.3),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFF06B6D4).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Sensor dots
                          Positioned(
                            top: 16,
                            left: 40 - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF06B6D4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 56,
                            left: 40 - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF06B6D4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 96,
                            left: 40 - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF06B6D4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 136,
                            left: 40 - 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF06B6D4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Axis indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AxisIndicator(
                color: const Color(0xFF06B6D4),
                label: 'X',
              ),
              const SizedBox(width: 16),
              _AxisIndicator(
                color: const Color(0xFFA855F7),
                label: 'Y',
              ),
              const SizedBox(width: 16),
              _AxisIndicator(
                color: const Color(0xFFEC4899),
                label: 'Z',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _AxisIndicator({
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
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF475569).withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const gridSize = 10.0;
    final rows = (size.height / gridSize).ceil();
    final cols = (size.width / gridSize).ceil();

    // Draw vertical lines
    for (int i = 0; i <= cols; i++) {
      final x = i * gridSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      final y = i * gridSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

