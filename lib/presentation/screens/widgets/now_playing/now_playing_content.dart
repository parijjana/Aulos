import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/screens/widgets/html_text.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
      // Parse homepage from description (Format: UUID|HOMEPAGE)
      final metadata = playerVM.currentShowNotes?.split('|');
      final homepage = (metadata != null && metadata.length > 1) ? metadata[1] : null;

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.radio, size: 64, color: Colors.white10),
                const SizedBox(height: 32),
                if (playerVM.currentStreamMetadata != null)
                  Text(
                    playerVM.currentStreamMetadata!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900, 
                      fontSize: 20, 
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                  )
                else
                  Text(
                    'Live Stream: ${playerVM.displayTitle}', 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'INTERNET RADIO',
                    style: TextStyle(
                      color: theme.colorScheme.primary, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                if (homepage != null && homepage.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(homepage)),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('VISIT STATION HOMEPAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
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
