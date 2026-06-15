import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aulos/domain/library/jamendo_track.dart';
import 'package:aulos/presentation/viewmodels/jamendo_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

class JamendoDiscoverView extends StatefulWidget {
  const JamendoDiscoverView({super.key});

  @override
  State<JamendoDiscoverView> createState() => _JamendoDiscoverViewState();
}

class _JamendoDiscoverViewState extends State<JamendoDiscoverView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<JamendoViewModel>();
      if (vm.searchResults.isEmpty && !vm.isLoading) {
        // Pre-populate with empty search (shows trending/popular tracks)
        vm.search('');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    context.read<JamendoViewModel>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<JamendoViewModel>();
    final libraryVM = context.watch<LibraryViewModel>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0.8),
            const Color(0xFF0F1E19), // Subtle deep forest green/charcoal undertone for music
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _buildSearchBox(theme, vm),
          ),

          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Error: ${vm.error}',
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ),

          Expanded(
            child: vm.isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
                : RefreshIndicator(
                    onRefresh: () async {
                      await vm.search(_searchController.text);
                    },
                    child: _buildTrackList(theme, vm, libraryVM),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(ThemeData theme, JamendoViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmit,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search Jamendo CC-licensed music tracks...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmit('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _onSearchSubmit(_searchController.text),
          tooltip: 'Refresh Discovery',
        ),
      ],
    );
  }

  Widget _buildTrackList(ThemeData theme, JamendoViewModel vm, LibraryViewModel libraryVM) {
    final results = vm.searchResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note_rounded, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              'No tracks found.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
            ),
          ],
        ),
      );
    }

    final bool isSearch = vm.lastSearchQuery.isNotEmpty;
    final title = isSearch ? 'Search Results' : 'Trending Music';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: results.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final track = results[index];
              return _JamendoTrackItem(
                track: track,
                vm: vm,
                libraryVM: libraryVM,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JamendoTrackItem extends StatelessWidget {
  final JamendoTrack track;
  final JamendoViewModel vm;
  final LibraryViewModel libraryVM;

  const _JamendoTrackItem({
    required this.track,
    required this.vm,
    required this.libraryVM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDownloaded = libraryVM.tracks.any((t) => t.path.contains(track.title) && t.isStream == false);
    final bool isStreaming = libraryVM.tracks.any((t) => t.path == track.audioUrl && t.isStream == true);
    final double? progress = vm.downloadProgress[track.id];

    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _JamendoTrackDetailSheet(
            track: track,
            isDownloaded: isDownloaded,
            isStreaming: isStreaming,
            vm: vm,
            libraryVM: libraryVM,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 48,
                height: 48,
                child: track.imageUrl.isNotEmpty
                    ? Image.network(
                        track.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _buildFallbackCover(theme),
                      )
                    : _buildFallbackCover(theme),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${track.artistName} • ${track.albumName}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Duration & status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.durationString,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                if (progress != null)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else if (isDownloaded)
                  const Icon(Icons.download_done_rounded, color: Colors.teal, size: 14)
                else if (isStreaming)
                  const Icon(Icons.sensors_rounded, color: Colors.orange, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCover(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary, size: 24),
    );
  }
}

class _JamendoTrackDetailSheet extends StatelessWidget {
  final JamendoTrack track;
  final bool isDownloaded;
  final bool isStreaming;
  final JamendoViewModel vm;
  final LibraryViewModel libraryVM;

  const _JamendoTrackDetailSheet({
    required this.track,
    required this.isDownloaded,
    required this.isStreaming,
    required this.vm,
    required this.libraryVM,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerVM = context.read<PlayerViewModel>();
    final double? progress = vm.downloadProgress[track.id];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Cover, Title, details row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: track.imageUrl.isNotEmpty
                      ? Image.network(
                          track.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackCover(theme),
                        )
                      : _buildFallbackCover(theme),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Artist: ${track.artistName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Album: ${track.albumName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          track.durationString,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isDownloaded)
                      _buildStatusChip(Colors.teal, Icons.download_done_rounded, 'Downloaded (Offline)')
                    else if (isStreaming)
                      _buildStatusChip(Colors.orange, Icons.sensors_rounded, 'Available Streaming')
                    else
                      _buildStatusChip(theme.colorScheme.primary, Icons.lock_open_rounded, 'Creative Commons'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Actions
          if (progress != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading track...',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  color: theme.colorScheme.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                // Stream / Play button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isStreaming ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.primaryContainer,
                      foregroundColor: isStreaming ? theme.colorScheme.primary : theme.colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(isStreaming ? 'Play Stream' : 'Stream Track'),
                    onPressed: () async {
                      Navigator.pop(context); // Close detail sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Streaming "${track.title}"...')),
                      );
                      // Start streaming and setup
                      final dbTrack = await vm.streamTrack(track);
                      // Refresh local library view to show the new track
                      await libraryVM.reloadLibrary();
                      // Play the track immediately!
                      await playerVM.setQueueAndPlay([dbTrack], 0);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Download button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDownloaded ? Colors.teal : theme.colorScheme.outline),
                      foregroundColor: isDownloaded ? Colors.teal : theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(isDownloaded ? Icons.download_done_rounded : Icons.download_rounded),
                    label: Text(isDownloaded ? 'Downloaded' : 'Download MP3'),
                    onPressed: isDownloaded
                        ? null
                        : () async {
                            Navigator.pop(context); // Close detail sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Starting download for "${track.title}"...')),
                            );
                            await vm.downloadTrack(track);
                            // Refresh local library view
                            await libraryVM.reloadLibrary();
                          },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackCover(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary, size: 48),
    );
  }

  Widget _buildStatusChip(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
