import 'package:flutter/material.dart';

class HeatmapFull extends StatelessWidget {
  final Map<String, double> sensorData;

  const HeatmapFull({
    super.key,
    required this.sensorData,
  });

  Color _getColor(double intensity) {
    if (intensity > 0.7) return const Color(0xFFEF4444); // Red
    if (intensity > 0.5) return const Color(0xFFF97316); // Orange
    if (intensity > 0.3) return const Color(0xFFEAB308); // Yellow
    return const Color(0xFF3B82F6); // Blue
  }

  double _getIntensity(double value) {
    return (value / 100).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final heelIntensity = _getIntensity(sensorData['heel'] ?? 0);
    final archIntensity = _getIntensity(sensorData['arch'] ?? 0);
    final ballIntensity = _getIntensity(sensorData['ball'] ?? 0);
    final toesIntensity = _getIntensity(sensorData['toes'] ?? 0);

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: AspectRatio(
        aspectRatio: 1 / 2,
        child: CustomPaint(
          painter: _HeatmapPainter(
            heelIntensity: heelIntensity,
            archIntensity: archIntensity,
            ballIntensity: ballIntensity,
            toesIntensity: toesIntensity,
            getColor: _getColor,
          ),
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final double heelIntensity;
  final double archIntensity;
  final double ballIntensity;
  final double toesIntensity;
  final Color Function(double) getColor;

  _HeatmapPainter({
    required this.heelIntensity,
    required this.archIntensity,
    required this.ballIntensity,
    required this.toesIntensity,
    required this.getColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 240;

    // Draw insole outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(30 * scaleX, 10 * scaleY);
    path.quadraticBezierTo(20 * scaleX, 40 * scaleY, 25 * scaleX, 100 * scaleY);
    path.quadraticBezierTo(30 * scaleX, 140 * scaleY, 35 * scaleX, 180 * scaleY);
    path.quadraticBezierTo(40 * scaleX, 220 * scaleY, 50 * scaleX, 235 * scaleY);
    path.quadraticBezierTo(60 * scaleX, 220 * scaleY, 65 * scaleX, 180 * scaleY);
    path.quadraticBezierTo(70 * scaleX, 140 * scaleY, 75 * scaleX, 100 * scaleY);
    path.quadraticBezierTo(80 * scaleX, 40 * scaleY, 70 * scaleX, 10 * scaleY);
    path.quadraticBezierTo(50 * scaleX, 5 * scaleY, 30 * scaleX, 10 * scaleY);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    // Draw pressure regions with radial gradients
    _drawPressureZone(
      canvas,
      Offset(50 * scaleX, 30 * scaleY),
      25 * scaleX + toesIntensity * 5 * scaleX,
      32 * scaleY + toesIntensity * 8 * scaleY,
      getColor(toesIntensity),
      toesIntensity,
    );

    _drawPressureZone(
      canvas,
      Offset(50 * scaleX, 80 * scaleY),
      28 * scaleX + ballIntensity * 5 * scaleX,
      38 * scaleY + ballIntensity * 8 * scaleY,
      getColor(ballIntensity),
      ballIntensity,
    );

    _drawPressureZone(
      canvas,
      Offset(45 * scaleX, 140 * scaleY),
      22 * scaleX + archIntensity * 4 * scaleX,
      32 * scaleY + archIntensity * 6 * scaleY,
      getColor(archIntensity),
      archIntensity,
    );

    _drawPressureZone(
      canvas,
      Offset(50 * scaleX, 200 * scaleY),
      30 * scaleX + heelIntensity * 6 * scaleX,
      38 * scaleY + heelIntensity * 10 * scaleY,
      getColor(heelIntensity),
      heelIntensity,
    );

    // Draw sensor markers
    final markerPaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final sensors = [
      {'x': 50.0, 'y': 30.0, 'label': 'Toes', 'labelX': 60.0},
      {'x': 50.0, 'y': 80.0, 'label': 'Ball', 'labelX': 60.0},
      {'x': 45.0, 'y': 140.0, 'label': 'Arch', 'labelX': 15.0},
      {'x': 50.0, 'y': 200.0, 'label': 'Heel', 'labelX': 60.0},
    ];

    for (final sensor in sensors) {
      canvas.drawCircle(
        Offset(sensor['x']! * scaleX, sensor['y']! * scaleY),
        4,
        markerPaint,
      );

      textPainter.text = TextSpan(
        text: sensor['label'] as String,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(sensor['labelX']! * scaleX, (sensor['y']! - 3) * scaleY),
      );
    }
  }

  void _drawPressureZone(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
    Color color,
    double intensity,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(intensity * 0.8),
          color.withOpacity(intensity * 0.4),
          const Color(0xFF3B82F6).withOpacity(0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.heelIntensity != heelIntensity ||
        oldDelegate.archIntensity != archIntensity ||
        oldDelegate.ballIntensity != ballIntensity ||
        oldDelegate.toesIntensity != toesIntensity;
  }
}

