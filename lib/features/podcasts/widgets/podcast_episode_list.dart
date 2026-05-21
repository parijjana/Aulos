import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';

class PodcastEpisodeList extends StatelessWidget {
  final List<Episode> episodes;
  final Episode? selectedEpisode;
  final Function(Episode) onEpisodeSelected;

  const PodcastEpisodeList({
    super.key,
    required this.episodes,
    this.selectedEpisode,
    required this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('EPISODES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Spacer(),
              Text('${episodes.length} Items', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            key: const PageStorageKey('podcast_episode_list'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: episodes.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final ep = episodes[index];
              final isSelected = selectedEpisode?.id == ep.id;
              return ListTile(
                selected: isSelected,
                selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                title: Text(
                  ep.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(ep.pubDate?.toString().split(' ')[0] ?? '', style: const TextStyle(fontSize: 10)),
                trailing: _buildDownloadIcon(ep, theme),
                onTap: () => onEpisodeSelected(ep),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadIcon(Episode ep, ThemeData theme) {
    if (ep.downloadState == 1) return const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2));
    if (ep.downloadState == 2) return Icon(Icons.offline_pin, size: 16, color: Colors.greenAccent.withValues(alpha: 0.5));
    return Icon(Icons.download_for_offline_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.2));
  }
}
