import 'package:flutter/material.dart';

/// The contract defining a pluggable Winamp-style audio visualizer.
abstract class VisualizerPlugin {
  /// Unique identifier of the visualizer plugin.
  String get id;

  /// Human-readable name of the visualizer.
  String get name;

  /// Custom paint method executed on every tick.
  /// [values] is a list of normalized amplitude/frequency points (0.0 to 1.0).
  /// [primaryColor] is the active theme/vibrant color to use for drawing.
  void paint(Canvas canvas, Size size, List<double> values, Color primaryColor);
}
