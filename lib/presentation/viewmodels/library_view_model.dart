import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/socket_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart'
    as settings;
import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';

enum LibraryMode { folders, artists, albums, genres, years, playlists }

class LibraryViewModel extends ChangeNotifier {
  final PersistentLibraryService _libraryService;
  final ConnectionManager? _connectionManager;
  final settings.SettingsViewModel? _settingsVM;

  settings.SettingsViewModel? get settingsVM => _settingsVM;

  LibraryMode _mode = LibraryMode.folders;
  settings.LibraryViewType _viewType = settings.LibraryViewType.list;
  int _libraryTabIndex = 0;

  List<Folder> _folders = [];
  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<Genre> _genres = [];
  List<int> _years = [];
  List<Playlist> _playlists = [];

  List<Track> _tracks = [];
  List<Album> _subAlbums = [];
  List<Folder> _subFolders = [];

  final Map<int, Uint8List> _artCache = {};
  final List<dynamic> _navStack = [];
  final Map<String, double> _scrollOffsets = {};
  bool _isLoading = false;
  bool _isPartialView = false;
  bool _wasRevealed = false;

  StreamSubscription<MediaCommand>? _remoteSub;

  LibraryViewModel({
    required PersistentLibraryService libraryService,
    ConnectionManager? connectionManager,
    settings.SettingsViewModel? settingsVM,
  }) : _libraryService = libraryService,
       _connectionManager = connectionManager,
       _settingsVM = settingsVM {
    _viewType = _settingsVM?.lastViewType ?? settings.LibraryViewType.list;
    _libraryTabIndex = _settingsVM?.libraryHubTabIndex ?? 0;
    _loadInitialData();
    if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
      unawaited(autoDiscover());
    }
    _remoteSub = _connectionManager?.remoteCommands.listen(
      _handleRemoteCommand,
    );
    _connectionManager?.addListener(_onConnectionStateChanged);
  }

  void _onConnectionStateChanged() {
    if (_connectionManager?.isAuthenticated ?? false) {
      unawaited(_loadInitialData());
    }
  }

  int get libraryTabIndex => _libraryTabIndex;

  void setLibraryTabIndex(int index) {
    _libraryTabIndex = index;
    _settingsVM?.setLibraryHubTabIndex(index);
    notifyListeners();
  }

  void _handleRemoteCommand(MediaCommand command) {
    if (_connectionManager?.isHost ?? false) {
      if (command.type == CommandType.getLibrary) {
        unawaited(_sendLibraryPage(command.payload));
      } else if (command.type == CommandType.getArt) {
        unawaited(_sendArt(command.payload));
      }
    } else if (_connectionManager?.isClient ?? false) {
      if (command.type == CommandType.libraryData) {
        _processRemoteLibraryData(command.payload);
      } else if (command.type == CommandType.artData) {
        _processRemoteArt(command.payload);
      }
    }
  }

  Future<void> _sendLibraryPage(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    final modeStr = payload['mode'] as String;
    final parentId = (payload['parentId'] as num?)?.toInt();

    final Map<String, dynamic> responsePayload = {
      'mode': modeStr,
      'parentId': parentId,
    };

    final service = _libraryService as PersistentLibraryServiceImpl;

    if (parentId == null) {
      switch (modeStr) {
        case 'folders':
          final items = await _libraryService.getRootFolders();
          responsePayload['items'] = items
              .map((e) => {'id': e.id, 'name': e.name, 'path': e.path})
              .toList();
          break;
        case 'artists':
          final items = await _libraryService.getArtists();
          responsePayload['items'] = items
              .map((e) => {'id': e.id, 'name': e.name})
              .toList();
          break;
        case 'albums':
          final items = await _libraryService.getAlbums();
          responsePayload['items'] = items
              .map(
                (e) => {
                  'id': e.id,
                  'name': e.name,
                  'coverArt': e.coverArt != null
                      ? base64.encode(e.coverArt!)
                      : null,
                },
              )
              .toList();
          break;
        case 'genres':
          final items = await _libraryService.getGenres();
          responsePayload['items'] = items
              .map((e) => {'id': e.id, 'name': e.name})
              .toList();
          break;
        case 'years':
          final items = await _libraryService.getYears();
          responsePayload['items'] = items;
          break;
        case 'playlists':
          final items = await _libraryService.getPlaylists();
          responsePayload['items'] = items
              .map(
                (e) => {
                  'id': e.id,
                  'name': e.name,
                  'isSmart': e.isSmart,
                  'createdAt': e.createdAt.toIso8601String(),
                },
              )
              .toList();
          break;
      }
    } else {
      switch (modeStr) {
        case 'folders':
          final subFolders = await _libraryService.getSubFolders(parentId);
          final items = await _libraryService.getTracksForFolder(parentId);
          responsePayload['subFolders'] = subFolders
              .map((e) => {'id': e.id, 'name': e.name, 'path': e.path})
              .toList();
          responsePayload['tracks'] = items
              .map(
                (e) => {
                  'id': e.id,
                  'title': e.title,
                  'path': e.path,
                  'artistId': e.artistId,
                },
              )
              .toList();
          break;
        case 'artists':
          final albums = await service.getAlbumsForArtist(parentId);
          if (albums.isNotEmpty) {
            responsePayload['albums'] = albums
                .map(
                  (e) => {
                    'id': e.id,
                    'name': e.name,
                    'coverArt': e.coverArt != null
                        ? base64.encode(e.coverArt!)
                        : null,
                  },
                )
                .toList();
          } else {
            final items = await _libraryService.getTracksForArtist(parentId);
            responsePayload['tracks'] = items
                .map(
                  (e) => {
                    'id': e.id,
                    'title': e.title,
                    'path': e.path,
                    'artistId': e.artistId,
                  },
                )
                .toList();
          }
          break;
        case 'albums':
          final items = await _libraryService.getTracksForAlbum(parentId);
          responsePayload['tracks'] = items
              .map(
                (e) => {
                  'id': e.id,
                  'title': e.title,
                  'path': e.path,
                  'artistId': e.artistId,
                },
              )
              .toList();
          break;
        case 'genres':
          final albums = await service.getAlbumsForGenre(parentId);
          if (albums.isNotEmpty) {
            responsePayload['albums'] = albums
                .map(
                  (e) => {
                    'id': e.id,
                    'name': e.name,
                    'coverArt': e.coverArt != null
                        ? base64.encode(e.coverArt!)
                        : null,
                  },
                )
                .toList();
          } else {
            final items = await _libraryService.getTracksForGenre(parentId);
            responsePayload['tracks'] = items
                .map(
                  (e) => {
                    'id': e.id,
                    'title': e.title,
                    'path': e.path,
                    'artistId': e.artistId,
                  },
                )
                .toList();
          }
          break;
        case 'years':
          final albums = await service.getAlbumsForYear(parentId);
          if (albums.isNotEmpty) {
            responsePayload['albums'] = albums
                .map(
                  (e) => {
                    'id': e.id,
                    'name': e.name,
                    'coverArt': e.coverArt != null
                        ? base64.encode(e.coverArt!)
                        : null,
                  },
                )
                .toList();
          } else {
            final items = await _libraryService.getTracksForYear(parentId);
            responsePayload['tracks'] = items
                .map(
                  (e) => {
                    'id': e.id,
                    'title': e.title,
                    'path': e.path,
                    'artistId': e.artistId,
                  },
                )
                .toList();
          }
          break;
        case 'playlists':
          final items = await _libraryService.getTracksForPlaylist(parentId);
          responsePayload['tracks'] = items
              .map(
                (e) => {
                  'id': e.id,
                  'title': e.title,
                  'path': e.path,
                  'artistId': e.artistId,
                },
              )
              .toList();
          break;
      }
    }

    unawaited(_connectionManager?.sendCommand(
      MediaCommand(type: CommandType.libraryData, payload: responsePayload),
    ));
  }

  Future<void> _sendArt(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    final trackId = (payload['trackId'] as num?)?.toInt();
    if (trackId == null) return;

    final allTracks = await _libraryService.getAllTracks();
    final track = allTracks.firstWhere((t) => t.id == trackId);
    if (track.coverArt != null) {
      unawaited(_connectionManager?.sendCommand(
        MediaCommand(
          type: CommandType.artData,
          payload: {
            'trackId': trackId,
            'base64': base64.encode(track.coverArt!),
          },
        ),
      ));
    }
  }

  void _processRemoteLibraryData(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final modeStr = payload['mode'] as String;
    final parentId = payload['parentId'] as int?;

    if (parentId == null) {
      final items = payload['items'] as List<dynamic>;
      switch (modeStr) {
        case 'folders':
          _folders = items
              .map(
                (e) {
                  final map = e as Map<String, dynamic>;
                  return Folder(
                    id: map['id'] as int,
                    name: map['name'] as String,
                    path: map['path'] as String,
                  );
                },
              )
              .toList();
          break;
        case 'artists':
          _artists = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Artist(
              id: map['id'] as int,
              name: map['name'] as String,
              isFavorite: false,
              playCount: 0,
            );
          }).toList();
          break;
        case 'albums':
          _albums = items
              .map(
                (e) {
                  final map = e as Map<String, dynamic>;
                  return Album(
                    id: map['id'] as int,
                    name: map['name'] as String,
                    isFavorite: false,
                    playCount: 0,
                    coverArt: map['coverArt'] != null
                        ? base64.decode(map['coverArt'] as String)
                        : null,
                  );
                },
              )
              .toList();
          break;
        case 'genres':
          _genres = items.map((e) {
            final map = e as Map<String, dynamic>;
            return Genre(id: map['id'] as int, name: map['name'] as String);
          }).toList();
          break;
        case 'years':
          _years = items.cast<int>();
          break;
        case 'playlists':
          _playlists = items
              .map(
                (e) {
                  final map = e as Map<String, dynamic>;
                  return Playlist(
                    id: map['id'] as int,
                    name: map['name'] as String,
                    isSmart: map['isSmart'] as bool,
                    createdAt: DateTime.parse(map['createdAt'] as String),
                  );
                },
              )
              .toList();
          break;
      }
    } else {
      _subFolders = [];
      _subAlbums = [];
      _tracks = [];

      if (payload.containsKey('subFolders')) {
        final subs = payload['subFolders'] as List<dynamic>;
        _subFolders = subs
            .map(
              (e) {
                final map = e as Map<String, dynamic>;
                return Folder(
                  id: map['id'] as int,
                  name: map['name'] as String,
                  path: map['path'] as String,
                );
              }
            )
            .toList();
      }

      if (payload.containsKey('albums')) {
        final albums = payload['albums'] as List<dynamic>;
        _subAlbums = albums
            .map(
              (e) {
                final map = e as Map<String, dynamic>;
                return Album(
                  id: map['id'] as int,
                  name: map['name'] as String,
                  isFavorite: false,
                  playCount: 0,
                  coverArt: map['coverArt'] != null
                      ? base64.decode(map['coverArt'] as String)
                      : null,
                );
              }
            )
            .toList();
      } else if (payload.containsKey('tracks')) {
        final tracks = payload['tracks'] as List<dynamic>;
        _tracks = tracks
            .map(
              (e) {
                final map = e as Map<String, dynamic>;
                return Track(
                  id: map['id'] as int,
                  title: map['title'] as String,
                  path: map['path'] as String,
                  folderId: 0,
                  artistId: map['artistId'] as int? ?? 0,
                  rating: 0,
                  isFavorite: false,
                  playCount: 0,
                );
              }
            )
            .toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void _processRemoteArt(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final trackId = (payload['trackId'] as num?)?.toInt();
    final b64 = payload['base64'] as String?;
    if (trackId != null && b64 != null) {
      _artCache[trackId] = base64.decode(b64);
      notifyListeners();
    }
  }

  Uint8List? getArtForTrack({required int trackId}) {
    if (_connectionManager?.isClient ?? false) {
      if (!_artCache.containsKey(trackId)) {
        _artCache[trackId] = Uint8List(0);
        unawaited(_connectionManager?.sendCommand(
          MediaCommand(type: CommandType.getArt, payload: {'trackId': trackId}),
        ));
      }
      final data = _artCache[trackId];
      return (data != null && data.isNotEmpty) ? data : null;
    }
    return null;
  }

  Future<void> autoDiscover() async {
    _isLoading = true;
    notifyListeners();
    await _libraryService.autoDiscoverTracks();
    await _loadInitialData();
    _isLoading = false;
    notifyListeners();
  }

  LibraryMode get mode => _mode;
  settings.LibraryViewType get viewType => _viewType;

  String get currentScrollKey {
    final stackPath = _navStack.map((e) {
      if (e is Folder) return 'f${e.id}';
      if (e is Artist) return 'r${e.id}';
      if (e is Album) return 'a${e.id}';
      if (e is Genre) return 'g${e.id}';
      if (e is int) return 'y$e';
      if (e is Playlist) return 'p${e.id}';
      return e.toString();
    }).join(':');
    return '${_mode.name}:${stackPath.isEmpty ? "root" : stackPath}';
  }

  void saveScrollOffset(double offset) {
    _scrollOffsets[currentScrollKey] = offset;
  }

  double getScrollOffset() {
    return _scrollOffsets[currentScrollKey] ?? 0.0;
  }

  List<Folder> get folders => _folders;
  List<Artist> get artists => _artists;
  List<Album> get albums => _albums;
  List<Genre> get genres => _genres;
  List<int> get years => _years;
  List<Playlist> get playlists => _playlists;

  List<Track> get tracks => _tracks;
  List<Album> get subAlbums => _subAlbums;
  List<Folder> get subFolders => _subFolders;

  dynamic get selectedItem => _navStack.isNotEmpty ? _navStack.last : null;
  bool get isLoading => _isLoading;
  bool get isAtRoot => _navStack.isEmpty;
  bool get isShowingSubContent =>
      _subFolders.isNotEmpty || _subAlbums.isNotEmpty;
  bool get isPartialView => _isPartialView;
  bool get wasRevealed => _wasRevealed;

  void setViewType(settings.LibraryViewType type) {
    _viewType = type;
    _settingsVM?.setLastViewType(type);
    notifyListeners();
  }

  void setMode(LibraryMode mode) {
    _mode = mode;
    _navStack.clear();
    _tracks = [];
    _subAlbums = [];
    _subFolders = [];
    _isPartialView = false;
    _wasRevealed = false;

    if (_connectionManager?.isClient ?? false) {
      _isLoading = true;
      notifyListeners();
      unawaited(_connectionManager?.sendCommand(
        MediaCommand(
          type: CommandType.getLibrary,
          payload: {'mode': mode.name},
        ),
      ));
    } else {
      unawaited(_loadInitialData());
    }
  }

  Future<void> _loadInitialData() async {
    if (_connectionManager?.isClient ?? false) {
      _isLoading = true;
      notifyListeners();
      unawaited(_connectionManager?.sendCommand(
        MediaCommand(
          type: CommandType.getLibrary,
          payload: {'mode': _mode.name},
        ),
      ));
      return;
    }

    _isLoading = true;
    notifyListeners();

    switch (_mode) {
      case LibraryMode.folders:
        _folders = await _libraryService.getRootFolders();
        break;
      case LibraryMode.artists:
        _artists = await _libraryService.getArtists();
        break;
      case LibraryMode.albums:
        _albums = await _libraryService.getAlbums();
        break;
      case LibraryMode.genres:
        _genres = await _libraryService.getGenres();
        break;
      case LibraryMode.years:
        _years = await _libraryService.getYears();
        break;
      case LibraryMode.playlists:
        final all = await _libraryService.getPlaylists();
        final List<Playlist> visible = [];
        for (var p in all) {
          if (p.isSmart) {
            final t = await _libraryService.getTracksForPlaylist(p.id);
            if (t.isNotEmpty) visible.add(p);
          } else {
            visible.add(p);
          }
        }
        _playlists = visible;
        break;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickFolder() async {
    final String? path = await FilePicker.getDirectoryPath();
    if (path != null) {
      await _libraryService.importFolder(path);
      await _loadInitialData();
    }
  }

  Future<void> selectItem(dynamic item) async {
    _isLoading = true;
    _navStack.add(item);
    _tracks = [];
    _subAlbums = [];
    _subFolders = [];
    _wasRevealed = false;
    notifyListeners();

    if (_connectionManager?.isClient ?? false) {
      int? id;
      if (item is Folder) {
        id = item.id;
      } else if (item is Artist) {
        id = item.id;
      } else if (item is Album) {
        id = item.id;
      } else if (item is Genre) {
        id = item.id;
      } else if (item is int) {
        id = item;
      } else if (item is Playlist) {
        id = item.id;
      }

      unawaited(_connectionManager?.sendCommand(
        MediaCommand(
          type: CommandType.getLibrary,
          payload: {'mode': _mode.name, 'parentId': id},
        ),
      ));
      return;
    }

    final service = _libraryService as PersistentLibraryServiceImpl;

    if (item is Folder) {
      _subFolders = await _libraryService.getSubFolders(item.id);
      _tracks = await _libraryService.getTracksForFolder(item.id);
    } else if (item is Artist) {
      _subAlbums = await service.getAlbumsForArtist(item.id);
      if (_subAlbums.isEmpty) {
        _tracks = await _libraryService.getTracksForArtist(item.id);
      }
    } else if (item is Genre) {
      _subAlbums = await service.getAlbumsForGenre(item.id);
      if (_subAlbums.isEmpty) {
        _tracks = await _libraryService.getTracksForGenre(item.id);
      }
    } else if (item is int) {
      // Year
      _subAlbums = await service.getAlbumsForYear(item);
      if (_subAlbums.isEmpty) {
        _tracks = await _libraryService.getTracksForYear(item);
      }
    } else if (item is Album) {
      if (_navStack.length > 1) {
        final parent = _navStack[_navStack.length - 2];
        if (parent is Artist) {
          _tracks = await service.getTracksForArtistInAlbum(parent.id, item.id);
        } else if (parent is Genre) {
          _tracks = await service.getTracksForGenreInAlbum(parent.id, item.id);
        } else if (parent is int) {
          _tracks = await service.getTracksForYearInAlbum(parent, item.id);
        } else {
          _tracks = await _libraryService.getTracksForAlbum(item.id);
        }

        final full = await _libraryService.getTracksForAlbum(item.id);
        _isPartialView = _tracks.length < full.length;
      } else {
        _tracks = await _libraryService.getTracksForAlbum(item.id);
        _isPartialView = false;
      }
    } else if (item is Playlist) {
      _tracks = await _libraryService.getTracksForPlaylist(item.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> revealFullAlbum() async {
    if (selectedItem is Album && _isPartialView) {
      _isLoading = true;
      notifyListeners();
      _tracks = await _libraryService.getTracksForAlbum(
        (selectedItem as Album).id,
      );
      _isPartialView = false;
      _wasRevealed = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rehideFullAlbum() async {
    if (selectedItem is Album && _wasRevealed) {
      _isLoading = true;
      notifyListeners();

      final item = _navStack.removeLast();
      await selectItem(item);

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Track>> getTracksForItem(dynamic item) async {
    if (item is Folder) return _libraryService.getTracksForFolder(item.id);
    if (item is Artist) return _libraryService.getTracksForArtist(item.id);
    if (item is Album) return _libraryService.getTracksForAlbum(item.id);
    if (item is Genre) return _libraryService.getTracksForGenre(item.id);
    if (item is int) return _libraryService.getTracksForYear(item);
    if (item is Playlist) return _libraryService.getTracksForPlaylist(item.id);
    return [];
  }

  void goBack() async {
    if (_navStack.isNotEmpty) {
      _navStack.removeLast();
      _isPartialView = false;
      _wasRevealed = false;
      if (_navStack.isNotEmpty) {
        final prevItem = _navStack.removeLast();
        await selectItem(prevItem);
      } else {
        if (_connectionManager?.isClient ?? false) {
          unawaited(_loadInitialData());
        } else {
          _tracks = [];
          _subAlbums = [];
          _subFolders = [];
          notifyListeners();
        }
      }
    }
  }

  Future<List<Track>> getAllTracks() => _libraryService.getAllTracks();

  @override
  void dispose() {
    unawaited(_remoteSub?.cancel());
    _connectionManager?.removeListener(_onConnectionStateChanged);
    super.dispose();
  }
}
