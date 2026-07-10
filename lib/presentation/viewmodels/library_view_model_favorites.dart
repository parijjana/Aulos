import 'dart:async';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/network/socket_service.dart';
import 'library_view_model.dart';

extension LibraryViewModelFavorites on LibraryViewModel {
  void setShowFavoritesOnly(bool val) {
    showFavoritesOnlyRaw = val;
    triggerNotify();
  }

  Future<void> toggleArtistFavorite(String artistId) async {
    if (connectionManager?.isClient ?? false) {
      unawaited(connectionManager?.sendCommand(MediaCommand(
        type: CommandType.custom,
        payload: {'action': 'toggleArtistFavorite', 'artistId': artistId},
      )));
      return;
    }
    await libraryService.toggleArtistFavorite(artistId);
    artistsRaw = await libraryService.getArtists();

    if (currentState.selectedItem is Artist && (currentState.selectedItem as Artist).id == artistId) {
      final updated = artistsRaw.firstWhere((a) => a.id == artistId);
      currentState.selectedItem = updated;
      final idx = currentState.navStack.indexWhere((e) => e is Artist && e.id == artistId);
      if (idx != -1) {
        currentState.navStack[idx] = updated;
      }
    }
    triggerNotify();
  }

  Future<void> toggleAlbumFavorite(String albumId) async {
    if (connectionManager?.isClient ?? false) {
      unawaited(connectionManager?.sendCommand(MediaCommand(
        type: CommandType.custom,
        payload: {'action': 'toggleAlbumFavorite', 'albumId': albumId},
      )));
      return;
    }
    await libraryService.toggleAlbumFavorite(albumId);
    albumsRaw = await libraryService.getAlbums();

    if (currentState.selectedItem is Album && (currentState.selectedItem as Album).id == albumId) {
      final updated = albumsRaw.firstWhere((a) => a.id == albumId);
      currentState.selectedItem = updated;
      final idx = currentState.navStack.indexWhere((e) => e is Album && e.id == albumId);
      if (idx != -1) {
        currentState.navStack[idx] = updated;
      }
    }
    triggerNotify();
  }
}
