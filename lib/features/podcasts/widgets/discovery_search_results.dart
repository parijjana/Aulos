import 'package:flutter/material.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';

class DiscoverySearchResults extends StatelessWidget {
  final PodcastViewModel vm;
  final ScrollController scrollController;

  const DiscoverySearchResults({
    super.key,
    required this.vm,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    if (vm.isLoading && vm.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!vm.isLoading && vm.searchResults.isEmpty) {
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                '${vm.searchResults.length} RESULTS FOUND',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Colors.white24,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              if (vm.isLoading)
                const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => vm.search(vm.lastSearchQuery),
            child: ListView.builder(
              controller: scrollController,
              itemCount: vm.searchResults.length + (vm.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.searchResults.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final result = vm.searchResults[index];
                return ListTile(
                  leading: Hero(
                    tag: 'pod_${result.itunesId ?? result.feedUrl}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: result.imageUrl != null
                          ? Image.network(
                              result.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.white10,
                                child: const Icon(Icons.podcasts),
                              ),
                            )
                          : Container(width: 50, height: 50, color: Colors.white10),
                    ),
                  ),
                  title: Text(
                    result.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    result.artist,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.add_circle_outline, size: 20),
                  onTap: () {
                    vm.setActiveDiscoveryDetail({
                      'iTunesId': result.itunesId ?? result.feedUrl,
                      'title': result.title,
                      'artist': result.artist,
                      'imageUrl': result.imageUrl,
                      'feedUrl': result.feedUrl,
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
