import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:provider/provider.dart';
import 'library_art_widget.dart';
import 'library_utils_mixin.dart';

class LibrarySubList extends StatelessWidget with LibraryUtilsMixin {
  final LibraryViewModel viewModel;
  final ScrollController scrollController;

  const LibrarySubList({
    super.key,
    required this.viewModel,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final playerVM = context.read<PlayerViewModel>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final item = viewModel.selectedItem;
    final bool isArtist = item is Artist;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 900;

        final Widget mainContent;
        if (isArtist && isNarrow) {
          mainContent = DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  tabs: const [
                    Tab(text: 'ALBUMS'),
                    Tab(text: 'ALL TRACKS'),
                  ],
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAlbumList(viewModel.subAlbums, theme),
                      _buildTrackList(viewModel.tracks, playerVM, onSurface),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          final combined = getCombinedItems(viewModel);
          mainContent = _buildTrackList(combined, playerVM, onSurface);
        }

        if (isArtist) {
          return Column(
            children: [
              _ArtistHeader(artist: item),
              Expanded(child: mainContent),
            ],
          );
        }

        return mainContent;
      },
    );
  }

  Widget _buildAlbumList(List<Album> albums, ThemeData theme) {
    return ListView.separated(
      itemCount: albums.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      itemBuilder: (context, index) {
        final album = albums[index];
        return ListTile(
          leading: LibraryArtWidget(item: album, viewModel: viewModel, size: 40),
          title: Text(album.name, style: TextStyle(color: theme.colorScheme.onSurface)),
          trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
          onTap: () => viewModel.selectItem(album),
        );
      },
    );
  }

  Widget _buildTrackList(List<dynamic> items, PlayerViewModel playerVM, Color onSurface) {
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final theme = Theme.of(context);
        if (item is Track) {
          return ListTile(
            leading: LibraryArtWidget(item: item, viewModel: viewModel, size: 40),
            title: Text(item.title, style: TextStyle(color: onSurface)),
            subtitle: Text(
              item.path,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.38),
                fontSize: 10,
              ),
              maxLines: 1,
            ),
            trailing: item.isStream == true
                ? Icon(
                    Icons.sensors_rounded,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    size: 16,
                  )
                : null,
            onTap: () async {
              // Ensure we are playing from the correct list
              final tracks = items.whereType<Track>().toList();
              final trackIndex = tracks.indexOf(item);
              await playerVM.setQueueAndPlay(tracks, trackIndex);
            },
          );
        }
        return ListTile(
          leading: LibraryArtWidget(item: item, viewModel: viewModel, size: 40),
          title: Text(
            getCategoryName(item),
            style: TextStyle(color: onSurface),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: onSurface.withValues(alpha: 0.24),
          ),
          onTap: () async {
            if (scrollController.hasClients) {
              viewModel.saveScrollOffset(scrollController.offset);
            }
            await viewModel.selectItem(item);
          },
        );
      },
    );
  }
}

class _ArtistHeader extends StatefulWidget {
  final Artist artist;
  const _ArtistHeader({required this.artist});

  @override
  State<_ArtistHeader> createState() => _ArtistHeaderState();
}

class _ArtistHeaderState extends State<_ArtistHeader> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = widget.artist.photo;
    final bio = widget.artist.bio;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              child: photo != null
                  ? Image.memory(photo, fit: BoxFit.cover)
                  : Icon(Icons.person_rounded, size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(width: 16),
          // 2. Info / Biography
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artist.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (bio != null && bio.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Text(
                        bio,
                        maxLines: _expanded ? null : 3,
                        overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  if (bio.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _expanded ? 'Read Less' : 'Read More',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  Text(
                    'No biography available yet. Run "Auto-Discover" to download details.',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

