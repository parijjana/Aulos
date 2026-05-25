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

    // 1. Hide for Radio (Live streams don't have progress)
    if (mediaType == MediaType.radio) {
      return const SizedBox(
        height: 24, // Reduced height
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

    // 2. Dual-Slider for Bookmark Mode
    if (vm.isBookmarkMode) {
      final total = vm.duration.inMilliseconds.toDouble();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            RangeSlider(
              values: RangeValues(vm.bookmarkStartMs, vm.bookmarkEndMsVal),
              min: 0,
              max: total > 0 ? total : vm.bookmarkEndMsVal + 1000,
              onChanged: (val) => vm.setBookmarkRange(val.start, val.end),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final startX = (vm.bookmarkStartMs / (total > 0 ? total : 1)) * width;
                final endX = (vm.bookmarkEndMsVal / (total > 0 ? total : 1)) * width;
                
                return Stack(
                  children: [
                    const SizedBox(height: 20, width: double.infinity),
                    Positioned(
                      left: (startX - 20).clamp(0, width - 40),
                      child: Text(
                        _formatDuration(Duration(milliseconds: vm.bookmarkStartMs.toInt())),
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      left: (endX - 20).clamp(0, width - 40),
                      child: Text(
                        _formatDuration(Duration(milliseconds: vm.bookmarkEndMsVal.toInt())),
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'ADJUST CLIP RANGE', 
                        style: TextStyle(fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w900, color: Colors.white12),
                      ),
                    ),
                  ],
                );
              },
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
        total: vm.duration,
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
