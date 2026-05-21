import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/screens/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/podcast_discovery_service.dart';

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Podcast? _selectedPodcast;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final podcastVM = context.watch<PodcastViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedPodcast == null) ...[
              _buildHeaderSection(podcastVM, theme),
              const SizedBox(height: 16),
              Expanded(
                child: _isSearching
                    ? _buildSearchResults(podcastVM, theme)
                    : _buildDiscoveryView(podcastVM, theme),
              ),
            ] else ...[
              _buildPodcastDetailHeader(_selectedPodcast!, theme),
              const SizedBox(height: 16),
              Expanded(
                child: _buildEpisodesList(podcastVM, playerVM, theme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(PodcastViewModel vm, ThemeData theme) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _isSearching = false);
                  _searchController.clear();
                },
              ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _isSearching ? 'Search iTunes...' : 'Subscribed Podcasts',
                  border: InputBorder.none,
                  prefixIcon: _isSearching ? null : const Icon(Icons.search, size: 20),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                onChanged: (val) {
                  if (!_isSearching && val.isNotEmpty) {
                    setState(() => _isSearching = true);
                  }
                },
                onSubmitted: (val) => vm.search(val),
              ),
            ),
            if (!_isSearching)
              IconButton(
                icon: Icon(Icons.rss_feed, color: theme.colorScheme.primary),
                onPressed: () => _showManualRssDialog(vm, theme),
                tooltip: 'Add RSS Manually',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryView(PodcastViewModel vm, ThemeData theme) {
    if (vm.error != null && vm.trendingResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(vm.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: vm.loadPodcasts, child: const Text('RETRY')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vm.podcasts.isNotEmpty) ...[
          _buildSectionHeader(theme, 'YOUR SUBSCRIPTIONS'),
          SizedBox(
            height: 140,
            child: _buildPodcastsHorizontalList(vm, theme),
          ),
          const SizedBox(height: 24),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(theme, 'TRENDING ON ITUNES'),
            IconButton(
              icon: Icon(Icons.refresh, size: 16, color: theme.colorScheme.primary),
              onPressed: vm.refreshDiscovery,
              tooltip: 'Refresh Trending',
            ),
          ],
        ),
        Expanded(
          child: _buildTrendingGrid(vm, theme),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPodcastsHorizontalList(PodcastViewModel vm, ThemeData theme) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: vm.podcasts.length,
      itemBuilder: (context, index) {
        final podcast = vm.podcasts[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: () {
              setState(() => _selectedPodcast = podcast);
              vm.loadEpisodes(podcast.id);
            },
            child: Column(
              children: [
                _buildArt(podcast.imageUrl, theme, size: 100),
                const SizedBox(height: 8),
                SizedBox(
                  width: 100,
                  child: Text(
                    podcast.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingGrid(PodcastViewModel vm, ThemeData theme) {
    if (vm.isLoading && vm.trendingResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final results = vm.trendingResults;
    if (results.isEmpty) {
      return const Center(child: Text('No trending podcasts found.'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return InkWell(
          onTap: () => vm.subscribeFromDiscovery(result),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildArt(result.imageUrl, theme),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                result.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(PodcastViewModel vm, ThemeData theme) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.searchResults.isEmpty) {
      return Center(
        child: Text(
          'Search for podcasts above.',
          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
        ),
      );
    }

    return ListView.builder(
      itemCount: vm.searchResults.length,
      itemBuilder: (context, index) {
        final result = vm.searchResults[index];
        return ListTile(
          leading: _buildArt(result.imageUrl, theme, size: 50),
          title: Text(result.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(result.artist, style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              vm.subscribeFromDiscovery(result);
              setState(() => _isSearching = false);
              _searchController.clear();
            },
          ),
        );
      },
    );
  }

  Widget _buildArt(String? url, ThemeData theme, {double? size}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => _buildPlaceholder(size),
            )
          : _buildPlaceholder(size),
    );
  }

  Widget _buildPlaceholder(double? size) {
    return Container(
      width: size,
      height: size,
      color: Colors.white.withValues(alpha: 0.05),
      child: const Icon(Icons.podcasts, size: 32),
    );
  }

  Widget _buildPodcastDetailHeader(Podcast podcast, ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedPodcast = null),
        ),
        const SizedBox(width: 8),
        _buildArt(podcast.imageUrl, theme, size: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                podcast.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                podcast.author ?? 'Unknown Author',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            context.read<PodcastViewModel>().unsubscribe(podcast.id);
            setState(() => _selectedPodcast = null);
          },
        ),
      ],
    );
  }

  Widget _buildEpisodesList(
    PodcastViewModel vm,
    PlayerViewModel playerVM,
    ThemeData theme,
  ) {
    if (vm.isLoading && vm.episodes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: vm.episodes.length,
      itemBuilder: (context, index) {
        final ep = vm.episodes[index];
        final progress = vm.downloadProgress[ep.id];
        final isDownloaded = ep.downloadState == 2;
        final isDownloading = ep.downloadState == 1;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            ep.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Text(
                ep.pubDate?.toString().split(' ')[0] ?? 'Unknown Date',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
              if (isDownloaded) ...[
                const SizedBox(width: 8),
                const Icon(Icons.offline_pin, size: 12, color: Colors.greenAccent),
              ],
            ],
          ),
          leading: IconButton(
            icon: Icon(
              ep.isPlayed ? Icons.play_circle_outline : Icons.play_circle_fill,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              final track = Track(
                id: -ep.id,
                path: ep.localFilePath ?? ep.audioUrl,
                title: ep.title,
                artistId: 0,
                folderId: 0,
                rating: 0,
                isFavorite: false,
                playCount: 0,
              );
              playerVM.loadTrack(track);
            },
          ),
          trailing: isDownloading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    isDownloaded ? Icons.delete_forever : Icons.download_for_offline_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                  ),
                  onPressed: isDownloaded ? null : () => vm.downloadEpisode(ep),
                ),
        );
      },
    );
  }

  void _showManualRssDialog(PodcastViewModel vm, ThemeData theme) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Add RSS Feed'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'https://example.com/rss'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.subscribe(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}
