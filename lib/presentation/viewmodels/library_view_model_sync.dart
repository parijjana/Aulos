import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/data/library/persistent_library_partial_views.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/network/socket_service.dart';
import 'library_view_model.dart';

extension LibraryViewModelSync on LibraryViewModel {
  Uint8List? getArtForTrack({required String trackId}) {
    if (connectionManager?.isClient ?? false) {
      if (!artCache.containsKey(trackId)) {
        artCache[trackId] = Uint8List(0);
        unawaited(connectionManager?.sendCommand(MediaCommand(type: CommandType.getArt, payload: {'trackId': trackId})));
      }
      final data = artCache[trackId];
      return (data != null && data.isNotEmpty) ? data : null;
    }
    return null;
  }

  void handleRemoteCommand(MediaCommand command) {
    if (connectionManager?.isHost ?? false) {
      if (command.type == CommandType.getLibrary) {
        unawaited(sendLibraryPage(command.payload));
      } else if (command.type == CommandType.getArt) {
        unawaited(sendArt(command.payload));
      } else if (command.type == CommandType.custom) {
        final action = command.payload?['action'];
        if (action == 'toggleArtistFavorite') {
          final artistId = command.payload?['artistId']?.toString();
          if (artistId != null) unawaited(toggleArtistFavorite(artistId));
        } else if (action == 'toggleAlbumFavorite') {
          final albumId = command.payload?['albumId']?.toString();
          if (albumId != null) unawaited(toggleAlbumFavorite(albumId));
        }
      }
    } else if (connectionManager?.isClient ?? false) {
      if (command.type == CommandType.libraryData) processRemoteLibraryData(command.payload);
      else if (command.type == CommandType.artData) processRemoteArt(command.payload);
    }
  }

  Future<void> sendArt(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    final trackId = payload['trackId']?.toString();
    if (trackId == null) return;
    final allTracks = await libraryService.getAllTracks();
    final track = allTracks.firstWhere((t) => t.id == trackId);
    if (track.coverArt != null) {
      unawaited(connectionManager?.sendCommand(MediaCommand(type: CommandType.artData, payload: {'trackId': trackId, 'base64': base64.encode(track.coverArt!)})));
    }
  }

  void processRemoteArt(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final trackId = payload['trackId']?.toString();
    final b64 = payload['base64'] as String?;
    if (trackId != null && b64 != null) {
      artCache[trackId] = base64.decode(b64);
      triggerNotify();
    }
  }

  Future<void> sendLibraryPage(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    final modeStr = payload['mode'] as String;
    final parentId = payload['parentId']?.toString();
    final Map<String, dynamic> responsePayload = { 'mode': modeStr, 'parentId': parentId };
    final service = libraryService as PersistentLibraryServiceImpl;
    if (parentId == null) {
      switch (modeStr) {
        case 'folders':
          final items = await libraryService.getRootFolders();
          responsePayload['items'] = items.map((e) => {'id': e.id, 'name': e.name, 'path': e.path}).toList();
          break;
        case 'artists':
          final items = await libraryService.getArtists();
          responsePayload['items'] = items.map((e) => {'id': e.id, 'name': e.name, 'isFavorite': e.isFavorite}).toList();
          break;
        case 'albums':
        case 'books':
          final items = modeStr == 'books' ? await libraryService.getAudiobooks() : await libraryService.getAlbums();
          responsePayload['items'] = items.map((e) => { 'id': e.id, 'name': e.name, 'isFavorite': e.isFavorite, 'coverArt': e.coverArt != null ? base64.encode(e.coverArt!) : null }).toList();
          break;
        case 'genres':
          final items = await libraryService.getGenres();
          responsePayload['items'] = items.map((e) => {'id': e.id, 'name': e.name}).toList();
          break;
        case 'years':
          final items = await libraryService.getYears();
          responsePayload['items'] = items;
          break;
        case 'playlists':
          final items = await libraryService.getPlaylists();
          responsePayload['items'] = items.map((e) => { 'id': e.id, 'name': e.name, 'isSmart': e.isSmart, 'createdAt': e.createdAt.toIso8601String() }).toList();
          break;
      }
    } else {
      switch (modeStr) {
        case 'folders':
          final subs = await libraryService.getSubFolders(parentId);
          final tracks = await libraryService.getTracksForFolder(parentId);
          responsePayload['subFolders'] = subs.map((e) => {'id': e.id, 'name': e.name, 'path': e.path}).toList();
          responsePayload['tracks'] = tracks.map((e) => {'id': e.id, 'title': e.title, 'path': e.path, 'artistId': e.artistId}).toList();
          break;
        case 'artists':
          final items = await service.getAlbumsForArtist(parentId);
          responsePayload['albums'] = items.map((e) => {'id': e.id, 'name': e.name, 'isFavorite': e.isFavorite, 'coverArt': e.coverArt != null ? base64.encode(e.coverArt!) : null}).toList();
          break;
      }
    }
    unawaited(connectionManager?.sendCommand(MediaCommand(type: CommandType.libraryData, payload: responsePayload)));
  }

  void processRemoteLibraryData(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final modeStr = payload['mode'] as String;
    final parentId = payload['parentId']?.toString();
    if (parentId == null) {
      final items = payload['items'] as List<dynamic>;
      switch (modeStr) {
        case 'folders':
          foldersRaw = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Folder(id: map['id']?.toString() ?? '', name: map['name'] as String, path: map['path'] as String, folderType: 0);
          }).toList();
          break;
        case 'artists':
          artistsRaw = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Artist(id: map['id']?.toString() ?? '', name: map['name'] as String, isFavorite: map['isFavorite'] as bool? ?? false, playCount: 0);
          }).toList();
          break;
        case 'albums':
        case 'books':
          final mapped = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Album(
              id: map['id']?.toString() ?? '',
              name: map['name'] as String,
              isFavorite: map['isFavorite'] as bool? ?? false,
              playCount: 0,
              isAudiobook: modeStr == 'books',
              isPlayed: false,
              isDownloadedViaAulos: false,
              coverArt: map['coverArt'] != null ? base64.decode(map['coverArt'] as String) : null,
            );
          }).toList();
          if (modeStr == 'books') {
            booksRaw = mapped;
          } else {
            albumsRaw = mapped;
          }
          break;
        case 'genres':
          genresRaw = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Genre(id: map['id']?.toString() ?? '', name: map['name'] as String);
          }).toList();
          break;
        case 'years':
          yearsRaw = items.cast<int>();
          break;
        case 'playlists':
          playlistsRaw = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Playlist(id: map['id']?.toString() ?? '', name: map['name'] as String, isSmart: map['isSmart'] as bool, createdAt: DateTime.parse(map['createdAt'] as String));
          }).toList();
          break;
      }
    } else {
      currentState.subFolders = [];
      currentState.subAlbums = [];
      currentState.tracks = [];
      if (payload.containsKey('subFolders')) {
        final subs = payload['subFolders'] as List<dynamic>;
        currentState.subFolders = subs.map((e) {
          final map = e as Map<String, dynamic>;
          return Folder(id: map['id']?.toString() ?? '', name: map['name'] as String, path: map['path'] as String, folderType: 0);
        }).toList();
      }
      if (payload.containsKey('albums')) {
        final albumsItems = payload['albums'] as List<dynamic>;
        currentState.subAlbums = albumsItems.map((e) {
          final map = e as Map<String, dynamic>;
          return Album(
            id: map['id']?.toString() ?? '',
            name: map['name'] as String,
            isFavorite: map['isFavorite'] as bool? ?? false,
            playCount: 0,
            isAudiobook: false,
            isPlayed: false,
            isDownloadedViaAulos: false,
            coverArt: map['coverArt'] != null ? base64.decode(map['coverArt'] as String) : null,
          );
        }).toList();
      } else if (payload.containsKey('tracks')) {
        final tracksItems = payload['tracks'] as List<dynamic>;
        currentState.tracks = tracksItems.map((e) {
          final map = e as Map<String, dynamic>;
          return Track(
            id: map['id']?.toString() ?? '',
            title: map['title'] as String,
            path: map['path'] as String,
            folderId: '',
            artistId: map['artistId']?.toString(),
            rating: 0,
            isFavorite: false,
            playCount: 0,
            isAudiobook: false,
            isPlayed: false,
          );
        }).toList();
      }
    }
    isLoading = false;
    triggerNotify();
  }
}
