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

        if (isArtist && isNarrow) {
          return DefaultTabController(
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
        }

        final combined = getCombinedItems(viewModel);
        return _buildTrackList(combined, playerVM, onSurface);
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
