import 'package:flutter/material.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/features/podcasts/widgets/discovery_grid_item.dart';

class DiscoveryResultList extends StatelessWidget {
  final List<PodcastSearchResult> results;
  final PodcastViewModel vm;
  final settings.SettingsViewModel settingsVM;
  final ScrollController scrollController;

  const DiscoveryResultList({
    super.key,
    required this.results,
    required this.vm,
    required this.settingsVM,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    if (results.isEmpty && !vm.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 64, color: onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text('No results found.', style: TextStyle(color: onSurface.withValues(alpha: 0.38))),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();

        if (settingsVM.libraryViewType == settings.LibraryViewType.list) {
          return ListView.separated(
            controller: scrollController,
            itemCount: results.length + (vm.isLoading ? 1 : 0),
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) {
              if (index == results.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = results[index];
              return ListTile(
                leading: _buildMiniArt(item.imageUrl),
                title: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  item.artist,
                  style: const TextStyle(fontSize: 10),
                ),
                trailing: const Icon(Icons.add_circle_outline, size: 18),
                onTap: () => vm.setActiveDiscoveryDetail({
                  'iTunesId': item.itunesId ?? item.feedUrl,
                  'title': item.title,
                  'artist': item.artist,
                  'imageUrl': item.imageUrl,
                  'feedUrl': item.feedUrl,
                }),
              );
            },
          );
        }

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            childAspectRatio: 0.85,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: results.length + (vm.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == results.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final item = results[index];
            return DiscoveryGridItem(result: item, vm: vm);
          },
        );
      },
    );
  }

  Widget _buildMiniArt(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.podcasts, size: 20, color: Colors.white24),
              )
            : const Icon(Icons.podcasts, size: 20, color: Colors.white24),
      ),
    );
  }
}
