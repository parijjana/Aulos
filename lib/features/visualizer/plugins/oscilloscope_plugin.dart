import 'package:flutter/material.dart';
import '../visualizer_plugin.dart';

/// Retro Oscilloscope visualizer that draws a continuous wave line.
class OscilloscopePlugin implements VisualizerPlugin {
  @override
  String get id => 'oscilloscope';

  @override
  String get name => 'Retro Oscilloscope';

  @override
  void paint(Canvas canvas, Size size, List<double> values, Color primaryColor) {
    final int count = values.length;
    if (count == 0) return;

    final double width = size.width;
    final double height = size.height;
    final double centerY = height / 2;
    final double spacing = width / (count - 1);

    final path = Path();
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < count; i++) {
      final double x = i * spacing;
      // Convert normalized value (0.0 to 1.0) into centered amplitude waves
      final double amplitude = (values[i] - 0.5) * height * 0.8;
      final double y = centerY + amplitude;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }
}
