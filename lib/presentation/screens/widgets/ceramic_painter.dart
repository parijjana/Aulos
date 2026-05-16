import 'package:flutter/material.dart';
import 'dart:math' as math;

class CeramicPainter extends CustomPainter {
  final Color color;

  CeramicPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final goldPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Greek Meander / Fret Border logic
    _drawFretBorder(canvas, size, goldPaint);

    // Elaborate vine patterns in corners
    _drawOrnateVine(
      canvas,
      paint,
      Offset(size.width * 0.12, size.height * 0.12),
      0,
    );
    _drawOrnateVine(
      canvas,
      paint,
      Offset(size.width * 0.88, size.height * 0.12),
      math.pi / 2,
    );
    _drawOrnateVine(
      canvas,
      paint,
      Offset(size.width * 0.12, size.height * 0.88),
      -math.pi / 2,
    );
    _drawOrnateVine(
      canvas,
      paint,
      Offset(size.width * 0.88, size.height * 0.88),
      math.pi,
    );

    // Side motifs
    _drawOrnateVine(
      canvas,
      paint,
      Offset(size.width * 0.5, size.height * 0.05),
      math.pi / 2,
      small: true,
    );
    _drawOrnateVine(
      canvas,
      paint,
      Offset(size.width * 0.5, size.height * 0.95),
      -math.pi / 2,
      small: true,
    );
  }

  void _drawFretBorder(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    const double inset = 4.0;
    const double step = 10.0;

    // Simple dashed fret line
    for (double x = inset; x < size.width - inset; x += step * 2) {
      path.moveTo(x, inset);
      path.lineTo(x + step, inset);
      path.moveTo(x, size.height - inset);
      path.lineTo(x + step, size.height - inset);
    }
    for (double y = inset; y < size.height - inset; y += step * 2) {
      path.moveTo(inset, y);
      path.lineTo(inset, y + step);
      path.moveTo(size.width - inset, y);
      path.lineTo(size.width - inset, y + step);
    }
    canvas.drawPath(path, paint);
  }

  void _drawOrnateVine(
    Canvas canvas,
    Paint paint,
    Offset origin,
    double rotation, {
    bool small = false,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rotation);

    final double s = small ? 0.6 : 1.0;
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(15 * s, -15 * s, 30 * s, 0);
    path.quadraticBezierTo(45 * s, 15 * s, 60 * s, 0);

    // Multiple leaf shapes
    path.addOval(Rect.fromLTWH(20 * s, -8 * s, 10 * s, 5 * s));
    path.addOval(Rect.fromLTWH(40 * s, 3 * s, 10 * s, 5 * s));
    path.addOval(Rect.fromLTWH(10 * s, 5 * s, 6 * s, 3 * s));

    // Swirl
    path.moveTo(60 * s, 0);
    path.arcToPoint(Offset(70 * s, -10 * s), radius: Radius.circular(10 * s));

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CeramicPainter oldDelegate) => oldDelegate.color != color;
}
