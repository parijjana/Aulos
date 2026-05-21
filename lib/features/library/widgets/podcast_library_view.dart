import 'package:flutter/material.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:provider/provider.dart';
import 'package:localaudioplayer/presentation/screens/widgets/html_text.dart';
import 'package:file_picker/file_picker.dart';

class PodcastLibraryView extends StatefulWidget {
  const PodcastLibraryView({super.key});

  @override
  State<PodcastLibraryView> createState() => _PodcastLibraryViewState();
}

class _PodcastLibraryViewState extends State<PodcastLibraryView> with AutomaticKeepAliveClientMixin {
  Podcast? _selectedPodcast;
  Episode? _selectedEpisode;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final podcastVM = context.watch<PodcastViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    if (podcastVM.isLoading && podcastVM.podcasts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (podcastVM.podcasts.isEmpty) {
      return _buildEmptyState(context, onSurface);
    }

    return Column(
      children: [
        if (_selectedPodcast != null)
           _buildBreadcrumb(theme, onSurface),
        Expanded(
          child: _selectedPodcast == null 
            ? _buildPodcastsGrid(podcastVM, theme)
            : _buildThreePaneView(podcastVM, playerVM, theme),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb(ThemeData theme, Color onSurface) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 18),
            onPressed: () => setState(() {
              _selectedPodcast = null;
              _selectedEpisode = null;
            }),
          ),
          const SizedBox(width: 8),
          Text(
            'PODCASTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: onSurface.withValues(alpha: 0.38),
            ),
          ),
          const Icon(Icons.chevron_right, size: 14, color: Colors.white24),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _selectedPodcast!.title.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<DisplayViewModel>().setTabIndex(2),
            icon: const Icon(Icons.search),
            label: const Text('DISCOVER PODCASTS'),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastsGrid(PodcastViewModel vm, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.8,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: vm.podcasts.length,
      itemBuilder: (context, index) {
        final podcast = vm.podcasts[index];
        return InkWell(
          onTap: () {
            setState(() => _selectedPodcast = podcast);
            vm.loadEpisodes(podcast.id);
          },
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

  Widget _buildThreePaneView(PodcastViewModel vm, PlayerViewModel playerVM, ThemeData theme) {
    return Row(
      children: [
        // Left Pane: Info
        _buildInfoPane(_selectedPodcast!, theme),
        
        // Middle Pane: Episode List
        VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        Expanded(
          flex: 4,
          child: _buildEpisodeList(vm, theme),
        ),
        
        // Right Pane: Show Notes
        VerticalDivider(width: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        Expanded(
          flex: 5,
          child: _buildNotesPane(playerVM, theme),
        ),
      ],
    );
  }

  Widget _buildInfoPane(Podcast podcast, ThemeData theme) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: podcast.imageUrl != null
                  ? Image.network(podcast.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.white10, height: 250),
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
              onPressed: () {
                context.read<PodcastViewModel>().unsubscribe(podcast.id);
                setState(() {
                  _selectedPodcast = null;
                  _selectedEpisode = null;
                });
              },
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('UNSUBSCRIBE', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeList(PodcastViewModel vm, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('EPISODES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Spacer(),
              Text('${vm.episodes.length} Items', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.episodes.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final ep = vm.episodes[index];
              final isSelected = _selectedEpisode?.id == ep.id;
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
                onTap: () => setState(() => _selectedEpisode = ep),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesPane(PlayerViewModel playerVM, ThemeData theme) {
    if (_selectedEpisode == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            const SizedBox(height: 16),
            Text('Select an episode to view notes', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24))),
          ],
        ),
      );
    }

    final ep = _selectedEpisode!;
    return Column(
      children: [
        _buildNotesHeader(ep, playerVM, theme),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ep.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 8),
                Text(
                  ep.pubDate?.toString().split(' ')[0] ?? 'Unknown Date',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 32),
                HtmlText(
                  ep.description ?? 'No notes available.',
                  onTimestampTap: (duration) {
                    context.read<PlayerViewModel>().seek(duration);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesHeader(Episode ep, PlayerViewModel playerVM, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(ep.isPinned ? Icons.push_pin : Icons.push_pin_outlined, color: ep.isPinned ? theme.colorScheme.primary : null),
            onPressed: () {
              context.read<PodcastViewModel>().togglePin(ep);
              setState(() {
                 _selectedEpisode = ep.copyWith(isPinned: !ep.isPinned);
              });
            },
            tooltip: ep.isPinned ? 'Unpin' : 'Pin',
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _handlePlayEpisode(context, ep, playerVM, theme),
            icon: const Icon(Icons.play_arrow),
            label: const Text('PLAY EPISODE'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlayEpisode(BuildContext context, Episode ep, PlayerViewModel playerVM, ThemeData theme) async {
    final settingsVM = context.read<settings.SettingsViewModel>();
    if (settingsVM.podcastStorageLocation == null) {
      final proceed = await _showStoragePrompt(context, theme);
      if (!proceed) return;
    }
    
    if (mounted) {
      await context.read<PodcastViewModel>().playEpisode(ep, playerVM);
    }
  }

  Future<bool> _showStoragePrompt(BuildContext context, ThemeData theme) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Podcast Storage Required'),
        content: const Text('Aulos needs a dedicated folder to save your podcasts for offline playback and better performance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('STREAM ONLY')),
          ElevatedButton(
            onPressed: () async {
              final String? path = await FilePicker.getDirectoryPath();
              if (path != null) {
                if (context.mounted) {
                  await context.read<settings.SettingsViewModel>().setPodcastStorageLocation(path);
                  if (context.mounted) Navigator.pop(context, true);
                }
              }
            },
            child: const Text('SELECT FOLDER'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildDownloadIcon(Episode ep, ThemeData theme) {
    if (ep.downloadState == 1) return const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2));
    if (ep.downloadState == 2) return Icon(Icons.offline_pin, size: 16, color: Colors.greenAccent.withValues(alpha: 0.5));
    return Icon(Icons.download_for_offline_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.2));
  }
}
