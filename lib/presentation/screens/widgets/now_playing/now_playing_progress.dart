import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class NowPlayingProgress extends StatelessWidget {
  const NowPlayingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final mediaType = vm.currentMediaType;

    if (mediaType == MediaType.radio) {
      return const SizedBox(
        height: 24, 
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors, size: 12, color: Colors.redAccent),
              SizedBox(width: 6),
              Text(
                'LIVE STREAM', 
                style: TextStyle(
                  fontSize: 9, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 2.0,
                  color: Colors.redAccent,
                )
              ),
            ],
          ),
        ),
      );
    }

    if (mediaType == MediaType.noise) {
      return const SizedBox.shrink();
    }

    final double total = vm.duration.inMilliseconds.toDouble();

    // 2. Custom Arrow Sliders for Bookmark Mode
    if (vm.isBookmarkMode) {
      final effectiveMax = total > 0 ? total : 1000.0;
      final double start = vm.bookmarkStartMs.toDouble().clamp(0.0, effectiveMax);
      final double end = vm.bookmarkEndMsVal.toDouble().clamp(start + 1.0, effectiveMax);

      return Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final startX = (start / effectiveMax) * width;
                  final endX = (end / effectiveMax) * width;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // The Timeline Base
                      Center(
                        child: Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // The Active Range
                      Positioned(
                        left: startX,
                        right: width - endX,
                        top: 58,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      // Start Arrow (From Above) - WIDER HIT AREA
                      Positioned(
                        left: startX - 25,
                        top: 10,
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final newStart = ((startX + details.delta.dx) / width) * effectiveMax;
                            vm.setBookmarkRange(newStart.clamp(0.0, end - 100).toDouble(), end);
                          },
                          child: Container(
                            width: 50, // Wider touch area
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Icon(Icons.arrow_downward_rounded, size: 28, color: theme.colorScheme.primary),
                                Container(width: 4, height: 25, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // End Arrow (From Below) - WIDER HIT AREA
                      Positioned(
                        left: endX - 25,
                        bottom: 10,
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final newEnd = ((endX + details.delta.dx) / width) * effectiveMax;
                            vm.setBookmarkRange(start, newEnd.clamp(start + 100, effectiveMax).toDouble());
                          },
                          child: Container(
                            width: 50, // Wider touch area
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                Container(width: 4, height: 25, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
                                Icon(Icons.arrow_upward_rounded, size: 28, color: theme.colorScheme.primary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(Duration(milliseconds: start.toInt())),
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'DRAG ARROWS TO TRIM', 
                  style: TextStyle(fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: Colors.white24),
                ),
                Text(
                  _formatDuration(Duration(milliseconds: end.toInt())),
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 3. Standard Progress Bar
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ProgressBar(
        progress: vm.position,
        total: total > 0 ? vm.duration : const Duration(milliseconds: 1),
        onSeek: vm.seek,
        baseBarColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        progressBarColor: theme.colorScheme.primary,
        bufferedBarColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        thumbColor: theme.colorScheme.primary,
        barHeight: 4,
        thumbRadius: 6,
        timeLabelLocation: TimeLabelLocation.below,
        timeLabelType: TimeLabelType.remainingTime,
        timeLabelTextStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.38), 
          fontSize: 10, 
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
