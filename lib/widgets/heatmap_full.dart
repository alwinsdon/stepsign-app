import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'insole_cad_path.dart';

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
    // Use exact CAD path from the shared insole path
    final scaleX = size.width / InsoleCadPath.viewBoxWidth;
    final scaleY = size.height / InsoleCadPath.viewBoxHeight;

    // Save canvas state for rotation
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi); // 180° rotation
    canvas.translate(-size.width / 2, -size.height / 2);

    // Translate for viewBox offset
    canvas.translate(-InsoleCadPath.viewBoxX * scaleX, -InsoleCadPath.viewBoxY * scaleY);

    // Parse and draw the exact CAD path
    final path = InsoleCadPath.parsePath(scaleX, scaleY);

    // Draw insole fill
    final fillPaint = Paint()
      ..color = const Color(0xFF0A0E1A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw insole outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, outlinePaint);

    // Draw pressure zones using the same CAD coordinates
    final zones = [
      {'zone': 'heel', 'intensity': heelIntensity},
      {'zone': 'arch', 'intensity': archIntensity},
      {'zone': 'ball', 'intensity': ballIntensity},
      {'zone': 'toes', 'intensity': toesIntensity},
    ];

    for (final zoneData in zones) {
      final zoneName = zoneData['zone'] as String;
      final intensity = zoneData['intensity'] as double;
      final zone = InsoleCadPath.sensorZones[zoneName]!;
      
      final cx = zone['cx']! * scaleX;
      final cy = zone['cy']! * scaleY;
      final rx = (zone['rx']! + intensity * 5) * scaleX;
      final ry = (zone['ry']! + intensity * 5) * scaleY;

      final paint = Paint()
        ..color = getColor(intensity).withOpacity(intensity * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: rx * 2,
          height: ry * 2,
        ),
        paint,
      );
    }

    // Draw sensor indicators
    final sensorPaint = Paint()
      ..color = const Color(0xFF06B6D4).withOpacity(0.8)
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
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.heelIntensity != heelIntensity ||
        oldDelegate.archIntensity != archIntensity ||
        oldDelegate.ballIntensity != ballIntensity ||
        oldDelegate.toesIntensity != toesIntensity;
  }
}

