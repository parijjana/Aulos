import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/app_database.dart';

class PodcastGrid extends StatelessWidget {
  final List<Podcast> podcasts;
  final Function(Podcast) onPodcastSelected;

  const PodcastGrid({
    super.key,
    required this.podcasts,
    required this.onPodcastSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const PageStorageKey('podcast_library_grid'),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: podcasts.length,
      itemBuilder: (context, index) {
        final podcast = podcasts[index];
        return InkWell(
          onTap: () => onPodcastSelected(podcast),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: podcast.imageUrl != null
                      ? Image.network(podcast.imageUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.white10, child: const Icon(Icons.podcasts)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                podcast.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
