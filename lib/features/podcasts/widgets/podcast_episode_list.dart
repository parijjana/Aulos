import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:provider/provider.dart';

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
    final podcastVM = context.read<PodcastViewModel>();

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
          child: RefreshIndicator(
            onRefresh: () => podcastVM.loadEpisodes(episodes.isNotEmpty ? episodes.first.podcastId : 0),
            child: episodes.isEmpty
                ? _buildEmptyState(theme, podcastVM.isLoading)
                : ListView.separated(
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDownloadIcon(ep, theme),
                            if (ep.downloadState == 2)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 16),
                                onSelected: (val) {
                                  if (val == 'delete') {
                                    context.read<PodcastViewModel>().deleteEpisode(ep, context);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                        SizedBox(width: 12),
                                        Text('Delete Download', style: TextStyle(color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        onTap: () => onEpisodeSelected(ep),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isLoading) {
    return ListView( // Needs to be scrollable for RefreshIndicator
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLoading ? Icons.sync : Icons.error_outline,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 16),
              Text(
                isLoading ? 'FETCHING EPISODES...' : 'NO EPISODES FOUND',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.5),
              ),
            ],
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
