import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart'
    as settings;
import 'package:localaudioplayer/presentation/screens/widgets/obsidian_orbit.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  late ScrollController _scrollController;
  String? _currentKey;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 6, vsync: this);
    _subTabController.addListener(_handleTabSelection);
    _scrollController = ScrollController();
  }

  void _handleTabSelection() {
    if (_subTabController.indexIsChanging) return;
    final viewModel = context.read<LibraryViewModel>();
    
    // Save current offset before switching categories
    if (_scrollController.hasClients) {
      viewModel.saveScrollOffset(_scrollController.offset);
    }
    
    switch (_subTabController.index) {
      case 0:
        viewModel.setMode(LibraryMode.folders);
        break;
      case 1:
        viewModel.setMode(LibraryMode.artists);
        break;
      case 2:
        viewModel.setMode(LibraryMode.albums);
        break;
      case 3:
        viewModel.setMode(LibraryMode.genres);
        break;
      case 4:
        viewModel.setMode(LibraryMode.years);
        break;
      case 5:
        viewModel.setMode(LibraryMode.playlists);
        break;
    }
  }

  @override
  void dispose() {
    _subTabController.removeListener(_handleTabSelection);
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LibraryViewModel>();
    final playerViewModel = context.watch<PlayerViewModel>();
    final queueViewModel = context.watch<QueueViewModel>();
    final theme = Theme.of(context);

    // Restore scroll position if the navigation key has changed
    if (_currentKey != viewModel.currentScrollKey) {
      _currentKey = viewModel.currentScrollKey;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final offset = viewModel.getScrollOffset();
          // Ensure we don't jump to an offset that's out of bounds for the new list
          final max = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(offset.clamp(0.0, max));
        }
      });
    }

    return PopScope(
      canPop: viewModel.isAtRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Save current sub-view offset before going back
        if (_scrollController.hasClients) {
          viewModel.saveScrollOffset(_scrollController.offset);
        }
        viewModel.goBack();
      },
      child: Column(
        children: [
          if (viewModel.isAtRoot)
            _buildRootHeader(viewModel, theme)
          else
            _buildBreadcrumb(viewModel, theme),
          Expanded(
            child: viewModel.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _buildContent(
                    context,
                    viewModel,
                    playerViewModel,
                    queueViewModel,
                    theme,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootHeader(LibraryViewModel viewModel, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _subTabController,
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
          _buildViewModeSelector(viewModel, theme),
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
  }

  Widget _buildViewModeSelector(LibraryViewModel viewModel, ThemeData theme) {
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

  Widget _buildContent(
    BuildContext context,
    LibraryViewModel viewModel,
    PlayerViewModel playerVM,
    QueueViewModel queueVM,
    ThemeData theme,
  ) {
    switch (viewModel.viewType) {
      case settings.LibraryViewType.list:
        return viewModel.isAtRoot
            ? _buildCategoryList(context, viewModel, theme)
            : _buildSubList(context, viewModel, playerVM, queueVM, theme);
      case settings.LibraryViewType.grid:
        return _buildGenericGrid(context, viewModel, playerVM, queueVM, theme);
      case settings.LibraryViewType.orbit:
        return _buildGenericOrbit(context, viewModel, playerVM, queueVM, theme);
    }
  }

  Widget _buildCategoryList(
    BuildContext context,
    LibraryViewModel viewModel,
    ThemeData theme,
  ) {
    final queueVM = context.read<QueueViewModel>();
    final playerVM = context.read<PlayerViewModel>();
    final onSurface = theme.colorScheme.onSurface;

    return ListView.builder(
      controller: _scrollController,
      itemCount: _getCategoryCount(viewModel),
      itemBuilder: (context, index) {
        final item = _getCategoryItem(viewModel, index);
        return ListTile(
          leading: _buildLargeArt(viewModel, item, theme, size: 40),
          title: Text(
            _getCategoryName(item),
            style: TextStyle(color: onSurface),
          ),
          subtitle: _getCategorySubtitle(item, theme),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.playlist_add,
                  color: onSurface.withValues(alpha: 0.24),
                  size: 20,
                ),
                onPressed: () async {
                  final tracks = await viewModel.getTracksForItem(item);
                  await queueVM.addAllToQueue(tracks);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: onSurface.withValues(alpha: 0.24),
                  size: 20,
                ),
                onPressed: () async {
                  final tracks = await viewModel.getTracksForItem(item);
                  if (tracks.isNotEmpty) {
                    await playerVM.setQueueAndPlay(tracks, 0);
                  }
                },
              ),
            ],
          ),
          onTap: () async {
            if (_scrollController.hasClients) {
              viewModel.saveScrollOffset(_scrollController.offset);
            }
            await viewModel.selectItem(item);
          },
        );
      },
    );
  }

  Widget _buildSubList(
    BuildContext context,
    LibraryViewModel viewModel,
    PlayerViewModel playerVM,
    QueueViewModel queueVM,
    ThemeData theme,
  ) {
    final combined = _getCombinedItems(viewModel);
    final onSurface = theme.colorScheme.onSurface;

    return ListView.builder(
      controller: _scrollController,
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        if (item is Track) {
          return ListTile(
            leading: _buildMiniArt(viewModel, item, theme),
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
              await playerVM.setQueueAndPlay(
                viewModel.tracks,
                viewModel.tracks.indexOf(item),
              );
            },
          );
        }
        return ListTile(
          leading: _buildLargeArt(viewModel, item, theme, size: 40),
          title: Text(
            _getCategoryName(item),
            style: TextStyle(color: onSurface),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: onSurface.withValues(alpha: 0.24),
          ),
          onTap: () async {
            if (_scrollController.hasClients) {
              viewModel.saveScrollOffset(_scrollController.offset);
            }
            await viewModel.selectItem(item);
          },
        );
      },
    );
  }

  Widget _buildGenericGrid(
    BuildContext context,
    LibraryViewModel viewModel,
    PlayerViewModel playerVM,
    QueueViewModel queueVM,
    ThemeData theme,
  ) {
    final combined = viewModel.isAtRoot
        ? _getAllCategoryItems(viewModel)
        : _getCombinedItems(viewModel);
    final onSurface = theme.colorScheme.onSurface;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        return GestureDetector(
          onTap: () async {
            if (_scrollController.hasClients) {
              viewModel.saveScrollOffset(_scrollController.offset);
            }
            await viewModel.selectItem(item);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'cat_${_getCategoryId(item)}',
                      child: _buildLargeArt(viewModel, item, theme),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionCircle(
                            icon: Icons.playlist_add,
                            onTap: () async {
                              final tracks = await viewModel.getTracksForItem(
                                item,
                              );
                              await queueVM.addAllToQueue(tracks);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionCircle(
                            icon: Icons.play_arrow,
                            onTap: () async {
                              final tracks = await viewModel.getTracksForItem(
                                item,
                              );
                              if (tracks.isNotEmpty) {
                                await playerVM.setQueueAndPlay(tracks, 0);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getCategoryName(item),
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _getCategoryGridSubtitle(item),
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.38),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenericOrbit(
    BuildContext context,
    LibraryViewModel viewModel,
    PlayerViewModel playerVM,
    QueueViewModel queueVM,
    ThemeData theme,
  ) {
    final combined = viewModel.isAtRoot
        ? _getAllCategoryItems(viewModel)
        : _getCombinedItems(viewModel);

    return AulosOrbit(
      items: combined,
      itemBuilder: (item) => AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildLargeArt(viewModel, item, theme),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionCircle(
                      icon: Icons.playlist_add,
                      size: 40,
                      onTap: () async {
                        final tracks = await viewModel.getTracksForItem(item);
                        await queueVM.addAllToQueue(tracks);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionCircle(
                      icon: Icons.play_arrow,
                      size: 40,
                      onTap: () async {
                        final tracks = await viewModel.getTracksForItem(item);
                        if (tracks.isNotEmpty) {
                          await playerVM.setQueueAndPlay(tracks, 0);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Text(
                    _getCategoryName(item),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (item) async => await viewModel.selectItem(item),
    );
  }

  List<dynamic> _getCombinedItems(LibraryViewModel vm) {
    final List<dynamic> combined = [];
    combined.addAll(vm.subFolders);
    combined.addAll(vm.subAlbums);
    combined.addAll(vm.tracks);
    return combined;
  }

  Widget _buildActionCircle({
    required IconData icon,
    required VoidCallback onTap,
    double size = 32,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.6),
      ),
    );
  }

  Widget _buildLargeArt(
    LibraryViewModel viewModel,
    dynamic item,
    ThemeData theme, {
    double? size,
  }) {
    Uint8List? art;
    if (item is Album) {
      art = item.coverArt;
    } else if (item is Track) {
      art = item.coverArt ?? viewModel.getArtForTrack(trackId: item.id);
    } else if (item is Artist) {
      art = item.photo;
    }

    final settingsVM = viewModel.settingsVM ??
        Provider.of<settings.SettingsViewModel>(context, listen: false);

    final isCircle = settingsVM.artworkShape == settings.ArtworkShape.circle;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(size == null ? 12 : 4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : null,
      ),
      child: art == null || art.isEmpty
          ? Center(
              child: _getCategoryIcon(
                viewModel,
                theme,
                size: size == null ? 64 : 20,
              ),
            )
          : null,
    );
  }

  int _getCategoryId(dynamic item) {
    if (item is int) return item;
    if (item is Track) return item.id;
    if (item is Folder) return item.id;
    if (item is Album) return item.id;
    if (item is Artist) return item.id;
    return (item as dynamic).id as int;
  }

  List<dynamic> _getAllCategoryItems(LibraryViewModel vm) {
    switch (vm.mode) {
      case LibraryMode.folders:
        return vm.folders;
      case LibraryMode.artists:
        return vm.artists;
      case LibraryMode.albums:
        return vm.albums;
      case LibraryMode.genres:
        return vm.genres;
      case LibraryMode.years:
        return vm.years;
      case LibraryMode.playlists:
        return vm.playlists;
    }
  }

  int _getCategoryCount(LibraryViewModel vm) {
    switch (vm.mode) {
      case LibraryMode.folders:
        return vm.folders.length;
      case LibraryMode.artists:
        return vm.artists.length;
      case LibraryMode.albums:
        return vm.albums.length;
      case LibraryMode.genres:
        return vm.genres.length;
      case LibraryMode.years:
        return vm.years.length;
      case LibraryMode.playlists:
        return vm.playlists.length;
    }
  }

  dynamic _getCategoryItem(LibraryViewModel vm, int index) {
    switch (vm.mode) {
      case LibraryMode.folders:
        return vm.folders[index];
      case LibraryMode.artists:
        return vm.artists[index];
      case LibraryMode.albums:
        return vm.albums[index];
      case LibraryMode.genres:
        return vm.genres[index];
      case LibraryMode.years:
        return vm.years[index];
      case LibraryMode.playlists:
        return vm.playlists[index];
    }
  }

  Widget _getCategoryIcon(
    LibraryViewModel vm,
    ThemeData theme, {
    double size = 24,
  }) {
    IconData icon;
    switch (vm.mode) {
      case LibraryMode.folders:
        icon = Icons.folder;
        break;
      case LibraryMode.artists:
        icon = Icons.person;
        break;
      case LibraryMode.albums:
        icon = Icons.album;
        break;
      case LibraryMode.genres:
        icon = Icons.category;
        break;
      case LibraryMode.years:
        icon = Icons.calendar_today;
        break;
      case LibraryMode.playlists:
        icon = Icons.playlist_play;
        break;
    }
    return Icon(
      icon,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
      size: size,
    );
  }

  String _getCategoryName(dynamic item) {
    if (item is int) return item.toString();
    if (item is Track) return item.title;
    return (item as dynamic).name as String;
  }

  Widget? _getCategorySubtitle(dynamic item, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    if (item is Folder) {
      return Text(
        item.path,
        style: TextStyle(color: onSurface, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (item is Track) {
      return Text(
        item.path,
        style: TextStyle(color: onSurface, fontSize: 10),
        maxLines: 1,
      );
    }
    return null;
  }

  String _getCategoryGridSubtitle(dynamic item) {
    if (item is Folder) return item.path;
    if (item is Artist) return 'Artist';
    if (item is Album) return 'Album';
    if (item is Track) return 'Track';
    return '';
  }

  Widget _buildBreadcrumb(LibraryViewModel viewModel, ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: onSurface.withValues(alpha: 0.05),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () {
              if (_scrollController.hasClients) {
                viewModel.saveScrollOffset(_scrollController.offset);
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
          _buildViewModeSelector(viewModel, theme),
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

  Widget _buildMiniArt(
    LibraryViewModel viewModel,
    Track track,
    ThemeData theme,
  ) {
    final art = track.coverArt ?? viewModel.getArtForTrack(trackId: track.id);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
        image: art != null && art.isNotEmpty
            ? DecorationImage(image: MemoryImage(art), fit: BoxFit.cover)
            : null,
      ),
      child: art == null || art.isEmpty
          ? Icon(
              Icons.music_note,
              color: onSurface.withValues(alpha: 0.24),
              size: 20,
            )
          : null,
    );
  }
}
