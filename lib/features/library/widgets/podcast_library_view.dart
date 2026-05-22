import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:provider/provider.dart';
import '../../podcasts/widgets/podcast_grid.dart';
import '../../podcasts/widgets/podcast_detail_view.dart';

class PodcastLibraryView extends StatefulWidget {
  const PodcastLibraryView({super.key});

  @override
  State<PodcastLibraryView> createState() => _PodcastLibraryViewState();
}

class _PodcastLibraryViewState extends State<PodcastLibraryView> with AutomaticKeepAliveClientMixin {
  Podcast? _selectedPodcast;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final podcastVM = context.watch<PodcastViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    if (podcastVM.isLoading && podcastVM.podcasts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (podcastVM.podcasts.isEmpty) {
      return _buildEmptyState(context, onSurface);
    }

    return _selectedPodcast == null 
      ? PodcastGrid(
          podcasts: podcastVM.podcasts,
          onPodcastSelected: (podcast) {
            setState(() => _selectedPodcast = podcast);
            podcastVM.loadEpisodes(podcast.id);
          },
        )
      : PodcastDetailView(
          podcast: _selectedPodcast!,
          onBack: () => setState(() => _selectedPodcast = null),
        );
  }

  Widget _buildEmptyState(BuildContext context, Color onSurface) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.podcasts, size: 64, color: onSurface.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            'No podcasts subscribed yet.',
            style: TextStyle(color: onSurface.withValues(alpha: 0.38)),
          ),
        ],
      ),
    );
  }
}
