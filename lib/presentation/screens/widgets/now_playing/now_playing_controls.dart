import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'strategies/now_playing_strategy.dart';
import 'strategies/music_strategy.dart';
import 'strategies/audiobook_strategy.dart';
import 'strategies/podcast_strategy.dart';
import 'strategies/radio_strategy.dart';
import 'strategies/noise_strategy.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';

// --- Shared Helpers for Strategies ---

Widget buildAulosPlayButton(PlayerViewModel vm, ThemeData theme, double size) {
  final primary = theme.colorScheme.primary;
  final bool isPlaying = vm.isPlaying;
  final bool isBuffering = vm.isBuffering;

  return IconButton(
    onPressed: vm.togglePlay,
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
      child: isBuffering 
        ? Center(child: SizedBox(width: size * 0.4, height: size * 0.4, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
        : Icon(
            isPlaying ? (vm.currentMediaType == MediaType.noise ? Icons.stop_rounded : Icons.pause_rounded) : Icons.play_arrow_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
    ),
  );
}

Widget buildCircularButton(IconData icon, VoidCallback onPressed, double size, ThemeData theme, {Color? color, bool isOverlay = false}) {
  return IconButton(
    onPressed: onPressed,
    padding: EdgeInsets.zero,
    icon: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOverlay ? Colors.white10 : (color?.withValues(alpha: 0.1) ?? theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        border: Border.all(color: color?.withValues(alpha: 0.3) ?? (isOverlay ? Colors.white24 : theme.colorScheme.onSurface.withValues(alpha: 0.1))),
      ),
      child: Icon(icon, color: color ?? (isOverlay ? Colors.white : theme.colorScheme.onSurface), size: size * 0.5),
    ),
  );
}

Widget buildSpeedSelector(PlayerViewModel vm, ThemeData theme, {bool isOverlay = false}) {
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

Widget buildMiniArt(BuildContext context, Uint8List? art, bool isPlaying, ThemeData theme) {
  if (isPlaying) return Icon(Icons.play_circle_filled, color: theme.colorScheme.primary, size: 24);
  final imageUrl = context.read<PlayerViewModel>().currentImageUrl;

  return Container(
    width: 24, height: 24,
    decoration: BoxDecoration(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
      image: art != null && art.isNotEmpty 
          ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
          : imageUrl != null && imageUrl.isNotEmpty
              ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
              : null,
    ),
    child: (art == null || art.isEmpty) && (imageUrl == null || imageUrl.isEmpty) 
        ? const Icon(Icons.music_note, size: 12, color: Colors.white10) 
        : null,
  );
}

void showRichBookmarkDialog(BuildContext context, PlayerViewModel vm, ThemeData theme) {
  final titleController = TextEditingController(text: 'Clip from ${vm.displayTitle}');
  final tagsController = TextEditingController();
  final notesController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) => AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('SAVE AUDIO CLIP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 16),
          TextField(controller: tagsController, decoration: const InputDecoration(labelText: 'Tags')),
          const SizedBox(height: 16),
          TextField(controller: notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
        ],
      ),
      actions: [
        TextButton(onPressed: () { vm.resetBookmarkState(); Navigator.pop(context); }, child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () {
            vm.saveBookmark(title: titleController.text, tags: tagsController.text, notes: notesController.text);
            Navigator.pop(context);
          },
          child: const Text('SAVE CLIP'),
        ),
      ],
    ),
  );
}

// --- Main Controls Component ---

class NowPlayingControls extends StatelessWidget {
  final bool isOverlay;

  const NowPlayingControls({super.key, this.isOverlay = false});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final theme = Theme.of(context);
    final strategy = _getStrategy(vm.currentMediaType);
    
    final double buttonSize = isOverlay ? 36 : 48;
    final double primaryButtonSize = isOverlay ? 72 : 96;

    return strategy.buildControls(
      context,
      vm,
      theme,
      buttonSize,
      primaryButtonSize,
      isOverlay: isOverlay,
    );
  }

  NowPlayingStrategy _getStrategy(MediaType type) {
    switch (type) {
      case MediaType.music: return MusicStrategy();
      case MediaType.audiobook: return AudiobookStrategy();
      case MediaType.podcast: return PodcastStrategy();
      case MediaType.radio: return RadioStrategy();
      case MediaType.noise: return NoiseStrategy();
    }
  }
}
