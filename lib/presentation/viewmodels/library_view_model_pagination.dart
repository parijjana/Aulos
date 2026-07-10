import 'library_view_model.dart';

extension LibraryViewModelPagination on LibraryViewModel {
  Future<void> loadMore() async {
    if (isLoading || !currentState.hasMore) return;

    isLoading = true;
    triggerNotify();

    final limit = 50;
    currentState.currentOffset += limit;
    final offset = currentState.currentOffset;
    final query = currentState.searchQuery;

    try {
      switch (mode) {
        case LibraryMode.folders:
          final newFolders = await libraryService.getRootFolders(limit: limit, offset: offset, searchQuery: query);
          foldersRaw = [...foldersRaw, ...newFolders];
          currentState.hasMore = newFolders.length == limit;
          break;
        case LibraryMode.artists:
          final newArtists = await libraryService.getArtists(limit: limit, offset: offset, searchQuery: query);
          artistsRaw = [...artistsRaw, ...newArtists];
          currentState.hasMore = newArtists.length == limit;
          break;
        case LibraryMode.albums:
          final newAlbums = await libraryService.getAlbums(limit: limit, offset: offset, searchQuery: query);
          albumsRaw = [...albumsRaw, ...newAlbums];
          currentState.hasMore = newAlbums.length == limit;
          break;
        case LibraryMode.genres:
          final newGenres = await libraryService.getGenres(limit: limit, offset: offset, searchQuery: query);
          genresRaw = [...genresRaw, ...newGenres];
          currentState.hasMore = newGenres.length == limit;
          break;
        default:
          break;
      }
    } finally {
      isLoading = false;
      triggerNotify();
    }
  }
}
