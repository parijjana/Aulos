import 'package:flutter/material.dart';
import '../visualizer_plugin.dart';

/// Winamp-style bar spectrum visualizer with slowly decaying peak indicators.
class BarSpectrumPlugin implements VisualizerPlugin {
  @override
  String get id => 'bar_spectrum';

  @override
  String get name => 'Winamp Bar Spectrum';

  List<double> _peaks = [];
  List<int> _peakHoldFrames = [];

  @override
  void paint(Canvas canvas, Size size, List<double> values, Color primaryColor) {
    final int count = values.length;
    if (count == 0) return;

    if (_peaks.length != count) {
      _peaks = List.filled(count, 0.0);
      _peakHoldFrames = List.filled(count, 0);
    }

    final double width = size.width;
    final double height = size.height;
    final double spacing = width / count;
    final double barWidth = spacing * 0.75;
    final double gap = spacing * 0.25;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double targetHeight = val * height;

      // Update falling peaks
      if (targetHeight >= _peaks[i]) {
        _peaks[i] = targetHeight;
        _peakHoldFrames[i] = 12; // Hold at peak for 12 frames
      } else {
        if (_peakHoldFrames[i] > 0) {
          _peakHoldFrames[i]--;
        } else {
          _peaks[i] = (_peaks[i] - 1.5).clamp(0.0, height);
        }
      }

      final double x = i * spacing + gap / 2;

      // Draw frequency bar
      paint.color = primaryColor.withValues(alpha: 0.85);
      canvas.drawRect(
        Rect.fromLTWH(x, height - targetHeight, barWidth, targetHeight),
        paint,
      );

      // Draw falling peak dot (Winamp style)
      paint.color = Colors.white.withValues(alpha: 0.9);
      final double peakHeight = _peaks[i];
      if (peakHeight > 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, height - peakHeight - 2, barWidth, 2),
          paint,
        );
      }
    }
  }
}
