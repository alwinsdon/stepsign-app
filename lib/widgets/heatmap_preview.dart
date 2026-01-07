import 'package:flutter/material.dart';
import 'dart:math' as math;

class HeatmapPreview extends StatefulWidget {
  const HeatmapPreview({super.key});

  @override
  State<HeatmapPreview> createState() => _HeatmapPreviewState();
}

class _HeatmapPreviewState extends State<HeatmapPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 400),
          painter: HeatmapPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final double animationValue;

  HeatmapPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw insole outline
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.05);
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.1,
      size.width * 0.75, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.5,
      size.width * 0.65, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.6, size.height * 0.85,
      size.width * 0.5, size.height * 0.95,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.85,
      size.width * 0.35, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.5,
      size.width * 0.25, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.5, size.height * 0.05,
    );
    path.close();

    // Draw outline
    paint.color = const Color(0xFF475569);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawPath(path, paint);

    // Draw pressure points with animation
    paint.style = PaintingStyle.fill;

    // Heel (orange)
    final heelIntensity = 0.5 + 0.3 * math.sin(animationValue * 2 * math.pi);
    _drawPressurePoint(
      canvas,
      Offset(size.width * 0.5, size.height * 0.85),
      30 * heelIntensity,
      Color.lerp(const Color(0xFF3B82F6), const Color(0xFFF97316), heelIntensity)!,
    );

    // Arch (cyan)
    final archIntensity = 0.3 + 0.2 * math.sin(animationValue * 2 * math.pi + 1);
    _drawPressurePoint(
      canvas,
      Offset(size.width * 0.5, size.height * 0.55),
      25 * archIntensity,
      Color.lerp(const Color(0xFF3B82F6), const Color(0xFF06B6D4), archIntensity)!,
    );

    // Ball (orange)
    final ballIntensity = 0.4 + 0.3 * math.sin(animationValue * 2 * math.pi + 2);
    _drawPressurePoint(
      canvas,
      Offset(size.width * 0.5, size.height * 0.35),
      28 * ballIntensity,
      Color.lerp(const Color(0xFF3B82F6), const Color(0xFFF97316), ballIntensity)!,
    );

    // Toes (cyan)
    final toeIntensity = 0.3 + 0.2 * math.sin(animationValue * 2 * math.pi + 3);
    _drawPressurePoint(
      canvas,
      Offset(size.width * 0.5, size.height * 0.15),
      22 * toeIntensity,
      Color.lerp(const Color(0xFF3B82F6), const Color(0xFF06B6D4), toeIntensity)!,
    );
  }

  void _drawPressurePoint(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.4),
          color.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(HeatmapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

