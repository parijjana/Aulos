import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
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
    final bool isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
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
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      borderRadius: BorderRadius.circular(32),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          GestureDetector(
                            onTap: () => tabController.animateTo(0),
                            child: _buildMiniArt(track?.coverArt, theme),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
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
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous_rounded, color: onSurface.withValues(alpha: 0.7), size: isDesktop ? 22 : 24),
                        onPressed: playerVM.skipPrevious,
                      ),
                      const SizedBox(width: 12),
                      _buildProminentPlayButton(playerVM, theme, isDesktop),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(Icons.skip_next_rounded, color: onSurface.withValues(alpha: 0.7), size: isDesktop ? 22 : 24),
                        onPressed: playerVM.skipNext,
                      ),
                    ],
                  ),
                ),
                if (isDesktop)
                   Align(
                    alignment: Alignment.centerRight,
                    child: _buildSpeedButton(playerVM, theme),
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

  Widget _buildProminentPlayButton(PlayerViewModel vm, ThemeData theme, bool isDesktop) {
    return GestureDetector(
      onTap: vm.isPlaying ? vm.pause : vm.play,
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 10 : 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withValues(alpha: 0.1),
          border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Icon(
          vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: theme.colorScheme.onSurface,
          size: isDesktop ? 28 : 32,
        ),
      ),
    );
  }

  Widget _buildMiniArt(Uint8List? art, ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : null,
      ),
      child: art == null || art.isEmpty
          ? Icon(Icons.music_note, color: theme.colorScheme.onSurface.withValues(alpha: 0.24), size: 22)
          : null,
    );
  }

  Widget _buildSpeedButton(PlayerViewModel vm, ThemeData theme) {
    return InkWell(
      onTap: () {
        final speeds = [0.5, 0.8, 1.0, 1.2, 1.5, 2.0];
        final currentIndex = speeds.indexOf(vm.playbackSpeed);
        final nextIndex = (currentIndex + 1) % speeds.length;
        vm.setSpeed(speeds[nextIndex]);
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${vm.playbackSpeed}x',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
