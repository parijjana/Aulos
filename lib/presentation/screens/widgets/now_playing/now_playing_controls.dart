import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as domain;
import 'package:provider/provider.dart';

class NowPlayingControls extends StatelessWidget {
  final bool isOverlay;

  const NowPlayingControls({
    super.key,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final queueVM = context.watch<QueueViewModel>();
    final theme = Theme.of(context);
    final mediaType = vm.currentMediaType;
    final double buttonSize = isOverlay ? 36 : 48;
    final double primaryButtonSize = isOverlay ? 72 : 96;

    if (mediaType == MediaType.radio) {
      return _buildRadioControls(theme, vm, primaryButtonSize);
    }

    if (mediaType == MediaType.podcast || mediaType == MediaType.audiobook) {
      return _buildPodcastControls(theme, vm, buttonSize, primaryButtonSize, mediaType);
    }

    return _buildMusicControls(theme, vm, queueVM, buttonSize, primaryButtonSize);
  }

  Widget _buildRadioControls(ThemeData theme, PlayerViewModel vm, double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: vm.isPlaying ? vm.stop : vm.play,
          padding: EdgeInsets.zero,
          icon: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
              ),
            ),
            child: Icon(
              vm.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodcastControls(ThemeData theme, PlayerViewModel vm, double buttonSize, double primarySize, MediaType type) {
    final bool isAudiobook = type == MediaType.audiobook;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSpeedSelector(vm, theme),
          const SizedBox(width: 16),
          if (isAudiobook) ...[
            _buildCircularButton(Icons.skip_previous_rounded, vm.skipPrevious, buttonSize * 0.9, theme),
            const SizedBox(width: 12),
          ],
          _buildCircularButton(Icons.replay_10_rounded, vm.skipBackward, buttonSize, theme),
          const SizedBox(width: 16),
          _buildAulosPlayButton(vm, theme, primarySize),
          const SizedBox(width: 16),
          _buildCircularButton(Icons.forward_10_rounded, vm.skipForward, buttonSize, theme),
          if (isAudiobook) ...[
            const SizedBox(width: 12),
            _buildCircularButton(Icons.skip_next_rounded, vm.skipNext, buttonSize * 0.9, theme),
          ],
          const SizedBox(width: 16),
          _buildCircularButton(Icons.bookmark_add_outlined, vm.bookmark, buttonSize, theme),
        ],
      ),
    );
  }

  Widget _buildMusicControls(ThemeData theme, PlayerViewModel vm, QueueViewModel queueVM, double buttonSize, double primarySize) {
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
          _buildCircularButton(Icons.skip_previous_rounded, vm.skipPrevious, buttonSize, theme),
          const SizedBox(width: 16),
          _buildAulosPlayButton(vm, theme, primarySize),
          const SizedBox(width: 16),
          _buildCircularButton(Icons.skip_next_rounded, vm.skipNext, buttonSize, theme),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              vm.repeatMode == domain.RepeatMode.one ? Icons.repeat_one : Icons.repeat,
              color: vm.repeatMode != domain.RepeatMode.off ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
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

  Widget _buildAulosPlayButton(PlayerViewModel vm, ThemeData theme, double size) {
    final primary = theme.colorScheme.primary;
    return IconButton(
      onPressed: vm.isPlaying ? vm.pause : vm.play,
      padding: EdgeInsets.zero,
      icon: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, primary.withValues(alpha: 0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          vm.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed, double size, ThemeData theme) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOverlay ? Colors.white10 : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(color: isOverlay ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: isOverlay ? Colors.white : theme.colorScheme.onSurface, size: size * 0.5),
      ),
    );
  }

  Widget _buildSpeedSelector(PlayerViewModel vm, ThemeData theme) {
    return PopupMenuButton<double>(
      initialValue: vm.playbackSpeed,
      onSelected: vm.setSpeed,
      itemBuilder: (context) => [0.5, 0.8, 1.0, 1.2, 1.5, 2.0].map((s) => PopupMenuItem(
        value: s,
        child: Text('${s}x', style: TextStyle(fontWeight: vm.playbackSpeed == s ? FontWeight.bold : FontWeight.normal)),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isOverlay ? Colors.black45 : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isOverlay ? Colors.white24 : theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${vm.playbackSpeed}x', style: TextStyle(color: isOverlay ? Colors.white : theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 10)),
            Icon(Icons.arrow_drop_down, color: isOverlay ? Colors.white : theme.colorScheme.primary, size: 14),
          ],
        ),
      ),
    );
  }
}
