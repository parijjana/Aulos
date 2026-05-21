import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/html_text.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';

class NowPlayingContent extends StatelessWidget {
  const NowPlayingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final playerVM = context.watch<PlayerViewModel>();
    final queueVM = context.watch<QueueViewModel>();
    final theme = Theme.of(context);
    final mediaType = playerVM.currentMediaType;

    if (mediaType == MediaType.podcast) {
      return SliverToBoxAdapter(
        child: HtmlText(
          playerVM.currentShowNotes ?? 'No notes available.',
          onTimestampTap: (d) => playerVM.seek(d),
        ),
      );
    }

    if (mediaType == MediaType.radio) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.radio, size: 48, color: Colors.white10),
              const SizedBox(height: 16),
              Text(
                playerVM.currentStreamMetadata ?? 'Live Stream: ${playerVM.displayTitle}', 
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Internet Radio',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final track = queueVM.currentQueue[index];
          final isPlaying = queueVM.currentIndex == index;
          return ListTile(
            dense: true,
            leading: _buildMiniArt(context, track.coverArt, isPlaying, theme),
            title: Text(track.title, style: TextStyle(color: isPlaying ? theme.colorScheme.primary : null, fontWeight: isPlaying ? FontWeight.bold : null)),
            subtitle: Text(track.path, style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => playerVM.playTrackAtIndex(index),
          );
        },
        childCount: queueVM.currentQueue.length,
      ),
    );
  }

  Widget _buildMiniArt(BuildContext context, Uint8List? art, bool isPlaying, ThemeData theme) {
    if (isPlaying) return Icon(Icons.play_circle_filled, color: theme.colorScheme.primary, size: 32);
    final imageUrl = context.read<PlayerViewModel>().currentImageUrl;

    return Container(
      width: 32, height: 32,
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
          ? const Icon(Icons.music_note, size: 16, color: Colors.white10) 
          : null,
    );
  }
}
