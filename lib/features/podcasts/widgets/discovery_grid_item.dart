import 'package:flutter/material.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';

class DiscoveryGridItem extends StatelessWidget {
  final PodcastSearchResult result;
  final PodcastViewModel vm;

  const DiscoveryGridItem({
    super.key,
    required this.result,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imgUrl = result.imageUrl;

    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: () {
          vm.setActiveDiscoveryDetail({
            'iTunesId': result.itunesId ?? result.feedUrl,
            'title': result.title,
            'artist': result.artist,
            'imageUrl': result.imageUrl,
            'feedUrl': result.feedUrl,
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'pod_${result.itunesId ?? result.feedUrl}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imgUrl != null
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white10,
                                child: const Icon(Icons.podcasts),
                              ),
                            )
                          : Container(color: Colors.white10),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              result.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
