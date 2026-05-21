import 'package:flutter/material.dart';
import 'package:localaudioplayer/data/database/discovery_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PodcastDetailScreen extends StatelessWidget {
  const PodcastDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PodcastViewModel>();
    final detail = vm.activeDiscoveryDetail;
    final theme = Theme.of(context);
    
    if (detail == null) return const SizedBox.shrink();

    final iTunesId = detail['iTunesId'] as String;
    final title = detail['title'] as String;
    final artist = detail['artist'] as String;
    final imageUrl = detail['imageUrl'] as String?;
    final feedUrl = detail['feedUrl'] as String?;

    // Trigger detail sync
    vm.loadPodcastDetails(iTunesId, feedUrl);

    return Stack(
      children: [
        _buildThemeBackground(theme),
        SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, theme, vm),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _buildHeader(theme, iTunesId, title, artist, imageUrl, feedUrl, vm),
                        const SizedBox(height: 24),
                        _buildAboutSection(vm, theme, iTunesId),
                        const SizedBox(height: 32),
                        _buildEpisodeList(context, vm, theme, iTunesId, title),
                      ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, PodcastViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => vm.setActiveDiscoveryDetail(null),
          ),
          const SizedBox(width: 8),
          Text(
            'PODCAST DETAIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String iTunesId, String title, String artist, String? imageUrl, String? feedUrl, PodcastViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'pod_$iTunesId',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: imageUrl == null
                ? const Icon(Icons.podcasts, size: 48)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                artist,
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (feedUrl != null && feedUrl.isNotEmpty)
                Consumer<PodcastViewModel>(
                  builder: (context, vm, _) {
                    final isSubscribed = vm.podcasts.any((p) => p.feedUrl == feedUrl);
                    return ElevatedButton.icon(
                      onPressed: isSubscribed ? null : () => vm.subscribe(feedUrl),
                      icon: Icon(isSubscribed ? Icons.check : Icons.add),
                      label: Text(isSubscribed ? 'SUBSCRIBED' : 'SUBSCRIBE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubscribed ? Colors.transparent : theme.colorScheme.primary,
                        foregroundColor: isSubscribed ? theme.colorScheme.onSurface : Colors.white,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(PodcastViewModel vm, ThemeData theme, String iTunesId) {
    return StreamBuilder<DiscoveredPodcast?>(
      stream: vm.watchPodcast(iTunesId),
      builder: (context, snapshot) {
        final description = snapshot.data?.description ?? 'Loading description...';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ABOUT',
              style: TextStyle(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Text(
                description,
                style: TextStyle(height: 1.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEpisodeList(BuildContext context, PodcastViewModel vm, ThemeData theme, String iTunesId, String podcastTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LATEST EPISODES',
          style: TextStyle(
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<DiscoveredEpisode>>(
          stream: vm.watchEpisodes(iTunesId),
          builder: (context, snapshot) {
            final episodes = snapshot.data ?? [];
            if (episodes.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ));
            }
            return Column(
              children: episodes.map((ep) => _buildEpisodeTile(context, ep, theme, vm, podcastTitle)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEpisodeTile(BuildContext context, DiscoveredEpisode ep, ThemeData theme, PodcastViewModel vm, String podcastTitle) {
    final dateStr = ep.pubDate != null ? DateFormat.yMMMd().format(ep.pubDate!) : 'Unknown Date';
    final playerVM = context.read<PlayerViewModel>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(ep.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(dateStr, style: const TextStyle(fontSize: 10)),
        trailing: Icon(Icons.play_circle_outline, color: theme.colorScheme.primary),
        onTap: () => vm.playDiscoveredEpisode(ep, podcastTitle, playerVM),
      ),
    );
  }
}
