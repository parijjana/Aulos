import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/data/database/app_database.dart';

class LibraryHeader extends StatelessWidget {
  final LibraryViewModel viewModel;
  final ScrollController scrollController;
  final TabController subTabController;

  const LibraryHeader({
    super.key,
    required this.viewModel,
    required this.scrollController,
    required this.subTabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    if (viewModel.isAtRoot) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Row(
          children: [
            Expanded(
              child: TabBar(
                controller: subTabController,
                isScrollable: true,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: onSurface.withValues(alpha: 0.38),
                tabs: const [
                  Tab(text: 'FOLDERS'),
                  Tab(text: 'ARTISTS'),
                  Tab(text: 'ALBUMS'),
                  Tab(text: 'GENRES'),
                  Tab(text: 'YEARS'),
                  Tab(text: 'PLAYLISTS'),
                ],
              ),
            ),
            _ViewModeSelector(viewModel: viewModel),
            IconButton(
              icon: Icon(
                Icons.add_to_photos,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: viewModel.pickFolder,
              tooltip: 'Import Folders',
            ),
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: viewModel.autoDiscover,
              tooltip: 'Auto-Discover',
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: onSurface.withValues(alpha: 0.05),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              onPressed: () {
                if (scrollController.hasClients) {
                  viewModel.saveScrollOffset(scrollController.offset);
                }
                viewModel.goBack();
              },
            ),
            Expanded(
              child: Text(
                _getTitle(viewModel).toUpperCase(),
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _ViewModeSelector(viewModel: viewModel),
            IconButton(
              icon: Icon(
                Icons.add_to_photos,
                color: onSurface.withValues(alpha: 0.7),
              ),
              onPressed: viewModel.pickFolder,
            ),
          ],
        ),
      );
    }
  }

  String _getTitle(LibraryViewModel viewModel) {
    final item = viewModel.selectedItem;
    if (item is Folder) return item.name;
    if (item is Artist) return item.name;
    if (item is Album) return item.name;
    if (item is Genre) return item.name;
    if (item is int) return item.toString();
    if (item is Playlist) return item.name;
    return 'Library';
  }
}

class _ViewModeSelector extends StatelessWidget {
  final LibraryViewModel viewModel;

  const _ViewModeSelector({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurfaceDim = theme.colorScheme.onSurface.withValues(alpha: 0.24);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.list,
            color: viewModel.viewType == settings.LibraryViewType.list
                ? primary
                : onSurfaceDim,
            size: 20,
          ),
          onPressed: () => viewModel.setViewType(settings.LibraryViewType.list),
        ),
        IconButton(
          icon: Icon(
            Icons.grid_view,
            color: viewModel.viewType == settings.LibraryViewType.grid
                ? primary
                : onSurfaceDim,
            size: 20,
          ),
          onPressed: () => viewModel.setViewType(settings.LibraryViewType.grid),
        ),
        IconButton(
          icon: Icon(
            Icons.blur_circular,
            color: viewModel.viewType == settings.LibraryViewType.orbit
                ? primary
                : onSurfaceDim,
            size: 20,
          ),
          onPressed: () =>
              viewModel.setViewType(settings.LibraryViewType.orbit),
        ),
      ],
    );
  }
}
