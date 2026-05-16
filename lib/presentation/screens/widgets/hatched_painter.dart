import 'package:flutter/material.dart';

class HatchedPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;

  HatchedPainter({
    required this.color,
    this.spacing = 8.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HatchedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}
