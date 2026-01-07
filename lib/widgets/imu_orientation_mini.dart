import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'insole_cad_path.dart';

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
                    child: SizedBox(
                      width: 80,
                      height: 160,
                      child: CustomPaint(
                        painter: _Insole3DPainter(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Angle displays
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAngleDisplay('Pitch', pitch, const Color(0xFF06B6D4)),
              _buildAngleDisplay('Roll', roll, const Color(0xFFA855F7)),
              _buildAngleDisplay('Yaw', yaw, const Color(0xFFEC4899)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAngleDisplay(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Insole3DPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Use exact CAD path from the shared insole path
    final scaleX = size.width / InsoleCadPath.viewBoxWidth;
    final scaleY = size.height / InsoleCadPath.viewBoxHeight;

    // Save canvas state for rotation
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi); // 180° rotation to match the orientation
    canvas.translate(-size.width / 2, -size.height / 2);

    // Translate for viewBox offset
    canvas.translate(-InsoleCadPath.viewBoxX * scaleX, -InsoleCadPath.viewBoxY * scaleY);

    // Parse and draw the exact CAD path
    final path = InsoleCadPath.parsePath(scaleX, scaleY);

    // Draw insole fill with gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF06B6D4).withOpacity(0.3),
          const Color(0xFFA855F7).withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw insole outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);

    // Draw sensor indicators using the same CAD coordinates
    final sensorPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;

    for (final zoneName in InsoleCadPath.sensorZones.keys) {
      final zone = InsoleCadPath.sensorZones[zoneName]!;
      canvas.drawCircle(
        Offset(zone['cx']! * scaleX, zone['cy']! * scaleY),
        4,
        sensorPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += size.width / 8) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += size.height / 8) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw center crosshair
    final centerPaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.3)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

