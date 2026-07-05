import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';

class MusicWaveformProgressBar extends StatefulWidget {
  final bool isOverlay;

  const MusicWaveformProgressBar({super.key, this.isOverlay = false});

  @override
  State<MusicWaveformProgressBar> createState() => _MusicWaveformProgressBarState();
}

class _MusicWaveformProgressBarState extends State<MusicWaveformProgressBar> {
  List<double> _waveform = [];
  String? _lastTrackId;

  // Generate a deterministic but unique waveform for each track ID
  void _updateWaveform(String trackId) {
    if (_lastTrackId == trackId && _waveform.isNotEmpty) return;
    _lastTrackId = trackId;

    const int barCount = 70;
    final random = Random(trackId.hashCode);
    final List<double> raw = List.generate(barCount, (_) => 0.15 + random.nextDouble() * 0.85);

    // Apply moving average smoothing to make it look like a cohesive audio wave
    final List<double> smoothed = List.filled(barCount, 0.0);
    for (int i = 0; i < barCount; i++) {
      double sum = 0;
      int divisor = 0;
      for (int g = -2; g <= 2; g++) {
        final idx = i + g;
        if (idx >= 0 && idx < barCount) {
          sum += raw[idx];
          divisor++;
        }
      }
      smoothed[i] = (sum / divisor).clamp(0.15, 1.0);
    }

    setState(() {
      _waveform = smoothed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final track = vm.currentTrack;

    if (track == null) return const SizedBox.shrink();
    _updateWaveform(track.id);

    final position = vm.position;
    final duration = vm.duration;
    final totalMs = duration.inMilliseconds;
    final progress = totalMs > 0 ? (position.inMilliseconds / totalMs).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Waveform Visualizer & Seek Area
        SizedBox(
          height: 60,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _handleSeek(details.localPosition.dx, constraints.maxWidth, vm),
                onHorizontalDragUpdate: (details) => _handleSeek(details.localPosition.dx, constraints.maxWidth, vm),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 60),
                  painter: _WaveformPainter(
                    waveform: _waveform,
                    progress: progress,
                    primaryColor: theme.colorScheme.primary,
                    unplayedColor: widget.isOverlay ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
              );
            },
          ),
        ),
        if (!widget.isOverlay) ...[
          const SizedBox(height: 10),
          // Monospaced Time Counter Labels to prevent text jitter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '-${_formatDuration(duration - position)}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _handleSeek(double localX, double width, PlayerViewModel vm) {
    if (width <= 0) return;
    final percent = (localX / width).clamp(0.0, 1.0);
    final targetMs = (percent * vm.duration.inMilliseconds).toInt();
    vm.seek(Duration(milliseconds: targetMs));
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double progress;
  final Color primaryColor;
  final Color unplayedColor;

  _WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.primaryColor,
    required this.unplayedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveform.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double width = size.width;
    final double height = size.height;
    final int count = waveform.length;
    final double spacing = width / count;

    for (int i = 0; i < count; i++) {
      final double barX = i * spacing + (spacing / 2);
      final double barProgress = i / count;
      final double barHeight = waveform[i] * height * 0.85;

      // Color based on playhead position
      paint.color = barProgress <= progress ? primaryColor : unplayedColor;

      // Draw symmetrical bars centered vertically
      canvas.drawLine(
        Offset(barX, (height - barHeight) / 2),
        Offset(barX, (height + barHeight) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveform != waveform ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.unplayedColor != unplayedColor;
  }
}
