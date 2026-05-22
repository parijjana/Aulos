import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:provider/provider.dart';

class RemoteControlGlow extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final bool isHost;

  const RemoteControlGlow({
    super.key,
    required this.child,
    required this.enabled,
    this.isHost = false,
  });

  @override
  State<RemoteControlGlow> createState() => _RemoteControlGlowState();
}

class _RemoteControlGlowState extends State<RemoteControlGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.isHost ? 8 : 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final settingsVM = context.watch<SettingsViewModel>();
    final bool showAnim = widget.isHost
        ? settingsVM.showHostAnimation
        : settingsVM.showRemoteAnimation;

    if (!showAnim) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _AulosGlowPainter(
            progress: _controller.value,
            isHost: widget.isHost,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AulosGlowPainter extends CustomPainter {
  final double progress;
  final bool isHost;

  _AulosGlowPainter({required this.progress, required this.isHost});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (isHost) {
      _paintHost(canvas, size);
    } else {
      _paintRemote(canvas, size);
    }
  }

  void _paintRemote(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0);

    final totalLength = (size.width + size.height) * 2;
    final riverLength = totalLength * 0.4;
    final startPos = progress * totalLength;

    _drawSegment(canvas, size, startPos, riverLength, paint);

    final sparkPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    _drawSegment(
      canvas,
      size,
      (progress * 2.5 % 1.0) * totalLength,
      totalLength * 0.05,
      sparkPaint,
    );
  }

  void _paintHost(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purpleAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0);

    final totalLength = (size.width + size.height) * 2;
    final riverLength = totalLength * 0.3;
    // Host river flows in opposite direction and at slightly different speed
    final startPos = (1.0 - progress) * totalLength;

    _drawSegment(canvas, size, startPos, riverLength, paint);

    final flarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    _drawSegment(
      canvas,
      size,
      ((1.0 - progress) * 1.8 % 1.0) * totalLength,
      totalLength * 0.08,
      flarePaint,
    );

    // Subtle background frame for host
    final framePaint = Paint()
      ..color = Colors.purpleAccent.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), framePaint);
  }

  void _drawSegment(
    Canvas canvas,
    Size size,
    double start,
    double length,
    Paint paint,
  ) {
    final int density = 40;
    final totalLength = (size.width + size.height) * 2;
    for (int i = 0; i < density; i++) {
      final p = (start + (i * length / density)) % totalLength;
      final offset = _getPositionAtLength(p, size);
      canvas.drawCircle(offset, paint.strokeWidth / 2, paint);
    }
  }

  Offset _getPositionAtLength(double length, Size size) {
    final w = size.width;
    final h = size.height;
    if (length < w) return Offset(length, 0);
    if (length < w + h) return Offset(w, length - w);
    if (length < w * 2 + h) return Offset(w - (length - (w + h)), h);
    return Offset(0, h - (length - (w * 2 + h)));
  }

  @override
  bool shouldRepaint(_AulosGlowPainter oldDelegate) => true;
}
