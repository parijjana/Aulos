import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as engine_domain;
import 'package:provider/provider.dart';
import 'now_playing_strategy.dart';
import '../now_playing_controls.dart'; 

class MusicStrategy extends NowPlayingStrategy {
  @override
  String get sectionLabel => 'UP NEXT';

  @override
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize) {
    final queueVM = context.watch<QueueViewModel>();
    final currentTrack = vm.currentTrack;
    
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentTrack != null) ...[
            IconButton(
              icon: Icon(
                currentTrack.rating == -1 ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                color: currentTrack.rating == -1 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              onPressed: () => queueVM.updateRating(currentTrack.id, -1),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: Icon(
              vm.isShuffle ? Icons.shuffle : Icons.shuffle_rounded,
              color: vm.isShuffle ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onPressed: vm.toggleShuffle,
          ),
          const SizedBox(width: 8),
          buildCircularButton(Icons.skip_previous_rounded, vm.skipPrevious, buttonSize, theme),
          const SizedBox(width: 16),
          buildAulosPlayButton(vm, theme, primarySize),
          const SizedBox(width: 16),
          buildCircularButton(Icons.skip_next_rounded, vm.skipNext, buttonSize, theme),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              vm.repeatMode == engine_domain.RepeatMode.one ? Icons.repeat_one : Icons.repeat,
              color: vm.repeatMode != engine_domain.RepeatMode.off ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onPressed: vm.toggleRepeat,
          ),
          if (currentTrack != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                currentTrack.rating == 1 ? Icons.favorite : Icons.favorite_border,
                color: currentTrack.rating == 1 ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              onPressed: () => queueVM.updateRating(currentTrack.id, 1),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme) {
    final queueVM = context.watch<QueueViewModel>();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: queueVM.currentQueue.length,
      itemBuilder: (context, index) {
        final track = queueVM.currentQueue[index];
        final isPlaying = queueVM.currentIndex == index;
        return ListTile(
          dense: true,
          leading: buildMiniArt(context, track.coverArt, isPlaying, theme),
          title: Text(track.title, style: TextStyle(color: isPlaying ? theme.colorScheme.primary : null, fontWeight: isPlaying ? FontWeight.bold : null, fontSize: 13)),
          onTap: () => vm.playTrackAtIndex(index),
        );
      },
    );
  }
}
