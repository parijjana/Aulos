import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:provider/provider.dart';

class PodcastInfoPane extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback onUnsubscribe;

  const PodcastInfoPane({
    super.key,
    required this.podcast,
    required this.onUnsubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        key: const PageStorageKey('podcast_info_scroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: podcast.imageUrl != null
                  ? Image.network(podcast.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.white10, height: 250, child: const Icon(Icons.podcasts, size: 64)),
            ),
            const SizedBox(height: 24),
            Text(podcast.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.1)),
            const SizedBox(height: 8),
            Text(podcast.author ?? 'Unknown Author', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('ABOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(
              podcast.description ?? 'No description available.',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onUnsubscribe,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('UNSUBSCRIBE', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
