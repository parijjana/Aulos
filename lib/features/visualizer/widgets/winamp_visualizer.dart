import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import '../visualizer_plugin.dart';
import '../plugins/bar_spectrum_plugin.dart';
import '../plugins/oscilloscope_plugin.dart';

class WinampVisualizer extends StatefulWidget {
  final double height;
  final String pluginId;

  const WinampVisualizer({
    super.key,
    this.height = 80,
    required this.pluginId,
  });

  @override
  State<WinampVisualizer> createState() => _WinampVisualizerState();
}

class _WinampVisualizerState extends State<WinampVisualizer> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<VisualizerPlugin> _registry = [
    BarSpectrumPlugin(),
    OscilloscopePlugin(),
  ];

  static const int computePoints = 16;
  final List<double> _frequencies = List.filled(computePoints, 0.0);
  final List<double> _targets = List.filled(computePoints, 0.0);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      _updateFrequencies();
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateFrequencies() {
    final playerVM = context.read<PlayerViewModel>();
    final bool isPlaying = playerVM.isPlaying && playerVM.currentMediaType == MediaType.music;

    setState(() {
      for (int i = 0; i < computePoints; i++) {
        if (isPlaying) {
          // Generate realistic audio peak targets using a random wave walk
          if (_random.nextDouble() < 0.15 || _targets[i] == 0.0) {
            _targets[i] = 0.05 + _random.nextDouble() * 0.95;
          }
          // Interpolate current frequency point toward target
          _frequencies[i] = _frequencies[i] + (_targets[i] - _frequencies[i]) * 0.25;
        } else {
          // Decay values smoothly back to rest (0) when paused
          _frequencies[i] = (_frequencies[i] - 0.1).clamp(0.0, 1.0);
          _targets[i] = 0.0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    final plugin = _registry.firstWhere(
      (p) => p.id == widget.pluginId,
      orElse: () => _registry.first,
    );

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeColor.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomPaint(
        painter: _VisualizerPainter(
          frequencies: _frequencies,
          plugin: plugin,
          primaryColor: activeColor,
        ),
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  final List<double> frequencies;
  final VisualizerPlugin plugin;
  final Color primaryColor;

  _VisualizerPainter({
    required this.frequencies,
    required this.plugin,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    plugin.paint(canvas, size, frequencies, primaryColor);
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) {
    return oldDelegate.frequencies != frequencies ||
        oldDelegate.plugin != plugin ||
        oldDelegate.primaryColor != primaryColor;
  }
}
