import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'now_playing_controls.dart';
import 'now_playing_progress.dart';
import 'strategies/now_playing_strategy.dart';

class NowPlayingArtwork extends StatelessWidget {
  final PlayerViewModel vm;
  final double size;
  final bool isCompact;
  final NowPlayingStrategy strategy;

  const NowPlayingArtwork({
    super.key,
    required this.vm,
    required this.size,
    required this.isCompact,
    required this.strategy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool showOverlayProgress = strategy.showProgress && size >= 160;

    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'now_playing_art',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 2,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: size,
                  height: size,
                  color: Colors.transparent,
                  child: vm.currentTrack?.coverArt != null
                      ? Image.memory(
                          vm.currentTrack!.coverArt!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 80, color: Colors.white10),
                        )
                      : vm.currentImageUrl != null
                          ? Image.network(
                              vm.currentImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 80, color: Colors.white10),
                            )
                          : const Icon(Icons.music_note, size: 80, color: Colors.white10),
                ),
              ),
            ),
          ),
        ),
        if (isCompact)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.black.withValues(alpha: 0.6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (showOverlayProgress)
                      const NowPlayingProgress(isOverlay: true),
                    NowPlayingControls(isOverlay: true),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
