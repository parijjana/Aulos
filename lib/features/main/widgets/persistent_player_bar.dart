import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/screens/widgets/glass_card.dart';
import 'package:provider/provider.dart';

class PersistentPlayerBar extends StatelessWidget {
  final TabController tabController;
  final Color primaryColor;

  const PersistentPlayerBar({
    super.key,
    required this.tabController,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final track = playerVM.currentTrack;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniProgressBar(playerVM, theme),
          const SizedBox(height: 4),
          SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: BorderRadius.circular(32),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => tabController.animateTo(0),
                          child: _buildMiniArt(track?.coverArt, playerVM, theme),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => tabController.animateTo(0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playerVM.displayTitle,
                                  style: TextStyle(color: onSurface, fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${playerVM.currentArtistName} • ${playerVM.currentAlbumName}',
                                  style: TextStyle(color: onSurface.withValues(alpha: 0.38), fontSize: 9),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildMiniPlayButton(playerVM, theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProgressBar(PlayerViewModel vm, ThemeData theme) {
    final pos = vm.position;
    final dur = vm.duration;
    final progress = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        color: primaryColor,
        minHeight: 2,
      ),
    );
  }

  Widget _buildMiniPlayButton(PlayerViewModel vm, ThemeData theme) {
    return IconButton(
      onPressed: vm.isPlaying ? vm.pause : vm.play,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withValues(alpha: 0.1),
        ),
        child: Icon(
          vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMiniArt(Uint8List? art, PlayerViewModel vm, ThemeData theme) {
    final imageUrl = vm.currentImageUrl;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20), // Circular mini art
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : imageUrl != null && imageUrl.isNotEmpty
                ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                : null,
      ),
      child: (art == null || art.isEmpty) && (imageUrl == null || imageUrl.isEmpty)
          ? Icon(Icons.music_note, color: theme.colorScheme.onSurface.withValues(alpha: 0.24), size: 22)
          : null,
    );
  }
}
