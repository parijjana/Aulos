import 'package:flutter/foundation.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/domain/network/socket_service.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:aulos/core/utils/id_generator.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'package:drift/drift.dart' hide Column;
import 'package:aulos/data/library/providers/audnexus_service.dart';

import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/data/library/library_indexer_service.dart';

enum LibraryMode { folders, artists, albums, genres, years, playlists, books }
enum AudiobookSort { name, author, series, played }

class LibraryNavigationState {
  final List<dynamic> navStack = [];
  dynamic selectedItem;
  List<Track> tracks = [];
  List<Album> subAlbums = [];
  List<Folder> subFolders = [];
  String searchQuery = '';
  double scrollOffset = 0.0;
  bool isPartialView = false;
  bool wasRevealed = false;
}

class LibraryViewModel extends ChangeNotifier {
  final PersistentLibraryService _libraryService;
  final PlaybackDatabase _playbackDb;
  final AudnexusService _audnexus;
  final ConnectionManager? _connectionManager;
  final settings.SettingsViewModel? _settingsVM;
  final LogService _logService;
  final LibraryIndexerService? _indexerService;
  IndexerState? _lastIndexerState;

  late settings.LibraryViewType _viewType;
  int _libraryTabIndex = 0;
  AudiobookSort _bookSort = AudiobookSort.name;
  bool _bookFilterAulos = false;

  List<Folder> _folders = [];
  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<Album> _books = [];
  List<Genre> _genres = [];
  List<int> _years = [];
  List<Playlist> _playlists = [];

  final Map<String, int> _trackPlaybackPositions = {};
  Map<String, int> get trackPlaybackPositions => _trackPlaybackPositions;

  final Map<String, double> _bookProgress = {};
  double getBookProgress(String bookId) => _bookProgress[bookId] ?? 0.0;

  Future<void> loadTrackPlaybackPositions() async {
    final list = await _playbackDb.select(_playbackDb.playbackPositions).get();
    _trackPlaybackPositions.clear();
    for (final item in list) {
      _trackPlaybackPositions[item.trackId] = item.positionMs;
    }
  }

  Future<void> calculateBookProgress() async {
    await loadTrackPlaybackPositions();
    _bookProgress.clear();
    for (final book in _books) {
      final tracks = await _libraryService.getChapters(book.id);
      if (tracks.isEmpty) continue;
      
      int totalDuration = 0;
      int elapsed = 0;
      for (final track in tracks) {
        final dur = track.durationSeconds ?? 0;
        totalDuration += dur;
        elapsed += ((_trackPlaybackPositions[track.id] ?? 0) / 1000).round();
      }
      
      if (totalDuration > 0) {
        _bookProgress[book.id] = (elapsed / totalDuration).clamp(0.0, 1.0);
      }
    }
  }

  bool _isLoading = false;
  final Map<String, Uint8List> _artCache = {};
  StreamSubscription<MediaCommand>? _remoteSub;

  final Map<LibraryMode, LibraryNavigationState> _states = {};
  LibraryMode _mode = LibraryMode.folders;
  LibraryMode _lastMusicMode = LibraryMode.folders;

  LibraryViewModel({
    required PersistentLibraryService libraryService,
    required PlaybackDatabase playbackDb,
    required AudnexusService audnexus,
    LogService? logService,
    ConnectionManager? connectionManager,
    settings.SettingsViewModel? settingsVM,
    LibraryIndexerService? indexerService,
  }) : _libraryService = libraryService,
       _playbackDb = playbackDb,
       _audnexus = audnexus,
       _logService = logService ?? NoOpLogService(),
       _connectionManager = connectionManager,
       _settingsVM = settingsVM,
       _indexerService = indexerService {
    _viewType = _settingsVM?.lastViewType ?? settings.LibraryViewType.grid;
    _libraryTabIndex = _settingsVM?.libraryHubTabIndex ?? 0;
    
    for (var m in LibraryMode.values) {
      _states[m] = LibraryNavigationState();
    }

    _loadInitialData();
    if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
      unawaited(autoDiscover());
    }
    _remoteSub = _connectionManager?.remoteCommands.listen(_handleRemoteCommand);
    _connectionManager?.addListener(_onConnectionStateChanged);

    if (_indexerService != null) {
      _lastIndexerState = _indexerService!.state;
      _indexerService!.addListener(_onIndexerChanged);
    }
  }

  void log(String message) => _logService.log(message);

  void _onIndexerChanged() {
    if (_indexerService == null) return;
    final currentState = _indexerService!.state;
    if (_lastIndexerState != null &&
        _lastIndexerState != IndexerState.idle &&
        currentState == IndexerState.idle) {
      log('LibraryViewModel: Indexer completed. Reloading library data...');
      unawaited(reloadLibrary());
    }
    _lastIndexerState = currentState;
  }

  AudnexusService get audnexus => _audnexus;

  Future<void> enrichAudiobook(Album book) async {
    _isLoading = true; notifyListeners();
    try {
      // 1. Search if no ASIN
      String? asin = book.asin;
      if (asin == null || asin.isEmpty) {
        // CLEAN TITLE FOR BETTER SEARCH
        String cleanTitle = book.name
            .replaceAll(RegExp(r'\(.*?\)', caseSensitive: false), '') // Remove (Unabridged), (Cradle, Book 9)
            .replaceAll(RegExp(r'\[.*?\]', caseSensitive: false), '')
            .replaceAll(RegExp(r'unabridged', caseSensitive: false), '')
            .trim();
        
        String searchQuery = cleanTitle;
        
        // ADD AUTHOR TO SEARCH IF AVAILABLE
        final audiobookDb = (_libraryService as PersistentLibraryServiceImpl).audiobookDb;
        if (book.artistId != null) {
          final artist = await (audiobookDb.select(audiobookDb.audiobookArtists)..where((a) => a.id.equals(book.artistId!))).getSingleOrNull();
          if (artist != null && artist.name != 'Unknown Artist') {
            searchQuery = '$cleanTitle ${artist.name}';
          }
        }

        log('AUDNEXUS: Optimized search query: "$searchQuery"');
        final searchResult = await _audnexus.searchBook(searchQuery);
        asin = searchResult?['asin'] as String?;
      }

      if (asin == null) {
        log('AUDNEXUS: No ASIN found for "${book.name}". Enrichment aborted.');
        return;
      }

      // 2. Fetch Full Metadata
      final meta = await _audnexus.getBookMetadata(asin);
      if (meta != null) {
        final description = meta['description'] as String?;
        final narrators = (meta['narrators'] as List?)?.join(', ');
        final subtitle = meta['subtitle'] as String?;
        final publisher = meta['publisher'] as String?;
        final publishedDate = meta['publishedDate'] != null ? DateTime.tryParse(meta['publishedDate'] as String) : null;
        
        // Series
        String? seriesName;
        int? seriesPosition;
        final seriesList = meta['series'] as List?;
        if (seriesList != null && seriesList.isNotEmpty) {
           seriesName = seriesList.first['name'] as String?;
           seriesPosition = int.tryParse(seriesList.first['position']?.toString() ?? '');
        }

        // High-res art
        final imageUrl = meta['image'] as String?;

        // UPDATE ALBUM
        final db = (_libraryService as PersistentLibraryServiceImpl).db;
        final audiobookDb = (_libraryService as PersistentLibraryServiceImpl).audiobookDb;
        await (audiobookDb.update(audiobookDb.audiobooks)..where((a) => a.id.equals(book.id))).write(
          AudiobooksCompanion(
            description: Value(meta['description'] as String?),
            publishedDate: Value(publishedDate),
            seriesName: Value(seriesName),
            seriesPosition: Value(seriesPosition),
            coverArtUrl: Value(imageUrl),
          ),
        );

        // 3. Fetch Chapters
        final chapters = await _audnexus.getChapters(asin);
        if (chapters.isNotEmpty) {
          final tracks = await _libraryService.getChapters(book.id);
          if (tracks.length == 1) {
            final trackId = tracks.first.id;
            // Clear existing
            await (audiobookDb.delete(audiobookDb.audiobookChapters)
                  ..where((c) => c.audiobookTrackId.equals(trackId)))
                .go();
            
            final List<AudiobookChaptersCompanion> companions = [];
            for (var c in chapters) {
               final startMs = (c['startOffsetMs'] as num).toInt();
               final title = (c['title'] as String?) ?? 'Chapter';
               final chapterFingerprint = "$trackId|$title|$startMs";
               final chapterId = generateContentId(chapterFingerprint);

               companions.add(AudiobookChaptersCompanion.insert(
                 id: chapterId,
                 audiobookTrackId: trackId,
                 title: title,
                 startTimeMs: startMs,
                 durationMs: Value((c['lengthMs'] as num?)?.toInt()),
               ));
            }
            await audiobookDb.addChapters(companions);
          }
        }

        // 4. Fetch Author Bio
        final authors = (meta['authors'] as List?);
        if (authors != null && authors.isNotEmpty && book.artistId != null) {
          final firstAuthor = authors.first?.toString();
          if (firstAuthor != null && firstAuthor.isNotEmpty) {
            final authorMeta = await _audnexus.getAuthorMetadata(firstAuthor);
            if (authorMeta != null) {
              await (audiobookDb.update(audiobookDb.audiobookArtists)..where((a) => a.id.equals(book.artistId!))).write(
                AudiobookArtistsCompanion(
                  bio: Value(authorMeta['description'] as String?),
                  photoUrl: Value(authorMeta['image'] as String?),
                ),
              );
            }
          }
        }
      }
      
      // Reload current item if it was the one being enriched
      if (selectedItem?.id == book.id) {
         final books = await _libraryService.getAudiobooks();
         final updated = books.firstWhere((b) => b.id == book.id, orElse: () => book);
         _currentState.selectedItem = updated;
      }

      await _loadInitialData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LibraryNavigationState get _currentState {
    var s = _states[_mode];
    if (s == null) {
      s = LibraryNavigationState();
      _states[_mode] = s;
    }
    return s;
  }

  void syncLibraryMode(int tabIndex) {
    if (tabIndex == 1) { 
      setMode(_lastMusicMode);
    } else if (tabIndex == 3) { 
      setMode(LibraryMode.books);
    }
  }

  void _onConnectionStateChanged() {
    if (_connectionManager?.isAuthenticated ?? false) {
      unawaited(_loadInitialData());
    }
  }

  LibraryMode get mode => _mode;
  LibraryMode get lastMusicMode => _lastMusicMode;
  int get libraryTabIndex => _libraryTabIndex;
  String get searchQuery => _currentState.searchQuery;
  bool get isSearching => _currentState.searchQuery.isNotEmpty;
  AudiobookSort get bookSort => _bookSort;
  bool get bookFilterAulos => _bookFilterAulos;
  settings.LibraryViewType get viewType => _viewType;
  bool get isLoading => _isLoading;
  bool get isPartialView => _currentState.isPartialView;
  settings.SettingsViewModel? get settingsVM => _settingsVM;

  String get currentScrollKey {
    final stackPath = _currentState.navStack.map((e) {
      if (e is Folder) return 'f${e.id}';
      if (e is Artist) return 'r${e.id}';
      if (e is Album) return 'a${e.id}';
      if (e is Genre) return 'g${e.id}';
      if (e is int) return 'y$e';
      if (e is Playlist) return 'p${e.id}';
      return '';
    }).join('/');
    return '${_mode.name}/$stackPath';
  }

  // --- State Aware Getters ---
  LibraryNavigationState stateFor(LibraryMode m) => _states[m] ?? LibraryNavigationState();
  bool isAtRootFor(LibraryMode m) => stateFor(m).navStack.isEmpty;
  dynamic selectedItemFor(LibraryMode m) => stateFor(m).selectedItem;
  List<Track> tracksFor(LibraryMode m) => stateFor(m).tracks;
  List<Album> subAlbumsFor(LibraryMode m) => stateFor(m).subAlbums;
  List<Folder> subFoldersFor(LibraryMode m) => stateFor(m).subFolders;

  // --- Default Getters (Legacy/Shared Compatibility) ---
  List<dynamic> get navStack => _currentState.navStack;
  dynamic get selectedItem => _currentState.selectedItem;
  bool get isAtRoot => _currentState.navStack.isEmpty;

  void setMode(LibraryMode newMode) {
    if (_mode == newMode) return;
    if (newMode != LibraryMode.books) _lastMusicMode = newMode;
    _mode = newMode;
    
    if (!_isModeLoaded(newMode)) {
      unawaited(_loadInitialData());
    } else {
      notifyListeners();
    }

    if (_connectionManager?.isClient ?? false) {
      unawaited(_connectionManager?.sendCommand(MediaCommand(type: CommandType.getLibrary, payload: {'mode': newMode.name})));
    }
  }

  bool _isModeLoaded(LibraryMode mode) {
    switch (mode) {
      case LibraryMode.folders: return _folders.isNotEmpty;
      case LibraryMode.artists: return _artists.isNotEmpty;
      case LibraryMode.albums: return _albums.isNotEmpty;
      case LibraryMode.books: return _books.isNotEmpty;
      case LibraryMode.genres: return _genres.isNotEmpty;
      case LibraryMode.years: return _years.isNotEmpty;
      case LibraryMode.playlists: return _playlists.isNotEmpty;
    }
  }

  Future<void> selectItem(dynamic item) async {
    _currentState.navStack.add(item);
    _currentState.selectedItem = item;
    notifyListeners();

    if (item is Folder) { await _loadFolderContent(item); }
    else if (item is Artist) { await _loadArtistContent(item); }
    else if (item is Album) { await _loadAlbumContent(item); }
    else if (item is Genre) { await _loadGenreContent(item); }
    else if (item is int) { await _loadYearContent(item); }
    else if (item is Playlist) { await _loadPlaylistContent(item); }
  }

  void goBack() async {
    if (_currentState.navStack.isNotEmpty) {
      _currentState.navStack.removeLast();
      _currentState.isPartialView = false;
      _currentState.wasRevealed = false;
      
      if (_currentState.navStack.isNotEmpty) {
        final prevItem = _currentState.navStack.last;
        _currentState.selectedItem = prevItem;
        if (prevItem is Folder) { await _loadFolderContent(prevItem); }
        else if (prevItem is Artist) { await _loadArtistContent(prevItem); }
        else if (prevItem is Album) { await _loadAlbumContent(prevItem); }
        else if (prevItem is Genre) { await _loadGenreContent(prevItem); }
        else if (prevItem is int) { await _loadYearContent(prevItem); }
        else if (prevItem is Playlist) { await _loadPlaylistContent(prevItem); }
      } else {
        _currentState.selectedItem = null;
        _currentState.tracks = [];
        _currentState.subAlbums = [];
        _currentState.subFolders = [];
        notifyListeners();
      }
    }
  }

  void setSearchQuery(String query) { _currentState.searchQuery = query; notifyListeners(); }
  void setBookSort(AudiobookSort sort) { _bookSort = sort; notifyListeners(); }
  void setBookFilterAulos(bool value) { _bookFilterAulos = value; notifyListeners(); }
  void setLibraryTabIndex(int index) { _libraryTabIndex = index; _settingsVM?.setLibraryHubTabIndex(index); notifyListeners(); }

  Future<void> reloadLibrary() async {
    _folders.clear();
    _artists.clear();
    _albums.clear();
    _books.clear();
    _genres.clear();
    _years.clear();
    _playlists.clear();
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_connectionManager?.isClient ?? false) return;
    _isLoading = true; notifyListeners();
    try {
      switch (_mode) {
        case LibraryMode.folders: _folders = await _libraryService.getRootFolders(); break;
        case LibraryMode.artists: _artists = await _libraryService.getArtists(); break;
        case LibraryMode.albums: _albums = await _libraryService.getAlbums(); break;
        case LibraryMode.books:
          _books = await _libraryService.getAudiobooks();
          await calculateBookProgress();
          break;
        case LibraryMode.genres: _genres = await _libraryService.getGenres(); break;
        case LibraryMode.years: _years = await _libraryService.getYears(); break;
        case LibraryMode.playlists: _playlists = await _libraryService.getPlaylists(); break;
      }
    } finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> _loadFolderContent(Folder folder) async {
    _isLoading = true; notifyListeners();
    _currentState.subFolders = await _libraryService.getSubFolders(folder.id, folderType: folder.folderType);
    _currentState.tracks = await _libraryService.getTracksForFolder(folder.id);
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadArtistContent(Artist artist) async {
    _isLoading = true; notifyListeners();
    final impl = _libraryService as PersistentLibraryServiceImpl;
    _currentState.subAlbums = await impl.getAlbumsForArtist(artist.id);
    if (_currentState.subAlbums.isEmpty) _currentState.tracks = await _libraryService.getTracksForArtist(artist.id);
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadAlbumContent(Album album) async {
    _isLoading = true; notifyListeners();
    if (album.isAudiobook) {
      _currentState.tracks = await _libraryService.getChapters(album.id);
    } else {
      _currentState.tracks = await _libraryService.getTracksForAlbum(album.id);
    }
    await loadTrackPlaybackPositions();
    _currentState.isPartialView = false;
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadGenreContent(Genre genre) async {
    _isLoading = true; notifyListeners();
    final impl = _libraryService as PersistentLibraryServiceImpl;
    _currentState.subAlbums = await impl.getAlbumsForGenre(genre.id);
    if (_currentState.subAlbums.isEmpty) _currentState.tracks = await _libraryService.getTracksForGenre(genre.id);
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadYearContent(int year) async {
    _isLoading = true; notifyListeners();
    final impl = _libraryService as PersistentLibraryServiceImpl;
    _currentState.subAlbums = await impl.getAlbumsForYear(year);
    if (_currentState.subAlbums.isEmpty) _currentState.tracks = await _libraryService.getTracksForYear(year);
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadPlaylistContent(Playlist playlist) async {
    _isLoading = true; notifyListeners();
    _currentState.tracks = await _libraryService.getTracksForPlaylist(playlist.id);
    _isLoading = false; notifyListeners();
  }

  List<Folder> get folders => _applySearch(_folders, (f) => f.name);
  List<Artist> get artists => _applySearch(_artists, (a) => a.name);
  List<Album> get albums => _applySearch(_albums, (a) => a.name);
  List<Genre> get genres => _applySearch(_genres, (g) => g.name);
  List<int> get years => _applySearch(_years, (y) => y.toString());
  List<Playlist> get playlists => _applySearch(_playlists, (p) => p.name);
  List<Album> get books {
    var list = _applySearch(_books, (b) => b.name);
    if (_bookFilterAulos) {
      list = list.where((b) => b.isDownloadedViaAulos).toList();
    }
    switch (_bookSort) {
      case AudiobookSort.name: list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())); break;
      case AudiobookSort.author: list.sort((a, b) => (a.narrator ?? '').toLowerCase().compareTo((b.narrator ?? '').toLowerCase())); break;
      case AudiobookSort.series: list.sort((a, b) => (a.seriesName ?? '').toLowerCase().compareTo((b.seriesName ?? '').toLowerCase())); break;
      case AudiobookSort.played: list.sort((a, b) => (a.isPlayed ? 1 : 0).compareTo(b.isPlayed ? 1 : 0)); break;
    }
    return list;
  }

  Album? findBookByLibrivoxId(String librivoxId) {
    for (final b in _books) {
      if (b.librivoxId == librivoxId) return b;
    }
    return null;
  }

  List<T> _applySearch<T>(List<T> items, String Function(T) mapper) {
    final query = _currentState.searchQuery;
    if (query.isEmpty) return items;
    return items.where((i) => mapper(i).toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<Folder> get subFolders => _currentState.subFolders;
  List<Album> get subAlbums => _currentState.subAlbums;
  List<Track> get tracks => _currentState.tracks;

  void saveScrollOffset(double offset) { _currentState.scrollOffset = offset; }
  double getScrollOffset() => _currentState.scrollOffset;

  Future<List<Track>> getTracksForItem(dynamic item) async {
    if (item is Folder) return _libraryService.getTracksForFolder(item.id);
    if (item is Artist) return _libraryService.getTracksForArtist(item.id);
    if (item is Album) {
      if (item.isAudiobook) {
        return _libraryService.getChapters(item.id);
      }
      return _libraryService.getTracksForAlbum(item.id);
    }
    if (item is Genre) return _libraryService.getTracksForGenre(item.id);
    if (item is int) return _libraryService.getTracksForYear(item);
    if (item is Playlist) return _libraryService.getTracksForPlaylist(item.id);
    return [];
  }

  Future<void> pickFolder({int folderType = 0}) async {
    final String? path = await FilePicker.getDirectoryPath();
    if (path != null) {
      await _libraryService.importFolder(path, folderType: folderType);
      await _loadInitialData();
    }
  }

  Uint8List? getArtForTrack({required String trackId}) {
    if (_connectionManager?.isClient ?? false) {
      if (!_artCache.containsKey(trackId)) {
        _artCache[trackId] = Uint8List(0);
        unawaited(_connectionManager?.sendCommand(MediaCommand(type: CommandType.getArt, payload: {'trackId': trackId})));
      }
      final data = _artCache[trackId];
      return (data != null && data.isNotEmpty) ? data : null;
    }
    return null;
  }

  void _handleRemoteCommand(MediaCommand command) {
    if (_connectionManager?.isHost ?? false) {
      if (command.type == CommandType.getLibrary) unawaited(_sendLibraryPage(command.payload));
      else if (command.type == CommandType.getArt) unawaited(_sendArt(command.payload));
    } else if (_connectionManager?.isClient ?? false) {
      if (command.type == CommandType.libraryData) _processRemoteLibraryData(command.payload);
      else if (command.type == CommandType.artData) _processRemoteArt(command.payload);
    }
  }

  Future<void> _sendArt(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    final trackId = payload['trackId']?.toString();
    if (trackId == null) return;
    final allTracks = await _libraryService.getAllTracks();
    final track = allTracks.firstWhere((t) => t.id == trackId);
    if (track.coverArt != null) {
      unawaited(_connectionManager?.sendCommand(MediaCommand(type: CommandType.artData, payload: {'trackId': trackId, 'base64': base64.encode(track.coverArt!)})));
    }
  }

  void _processRemoteArt(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final trackId = payload['trackId']?.toString();
    final b64 = payload['base64'] as String?;
    if (trackId != null && b64 != null) { _artCache[trackId] = base64.decode(b64); notifyListeners(); }
  }

  Future<void> _sendLibraryPage(Map<String, dynamic>? payload) async {
    if (payload == null) return;
    final modeStr = payload['mode'] as String;
    final parentId = payload['parentId']?.toString();
    final Map<String, dynamic> responsePayload = { 'mode': modeStr, 'parentId': parentId };
    final service = _libraryService as PersistentLibraryServiceImpl;
    if (parentId == null) {
      switch (modeStr) {
        case 'folders': final items = await _libraryService.getRootFolders(); responsePayload['items'] = items.map((e) => {'id': e.id, 'name': e.name, 'path': e.path}).toList(); break;
        case 'artists': final items = await _libraryService.getArtists(); responsePayload['items'] = items.map((e) => {'id': e.id, 'name': e.name}).toList(); break;
        case 'albums': case 'books': final items = modeStr == 'books' ? await _libraryService.getAudiobooks() : await _libraryService.getAlbums(); responsePayload['items'] = items.map((e) => { 'id': e.id, 'name': e.name, 'coverArt': e.coverArt != null ? base64.encode(e.coverArt!) : null }).toList(); break;
        case 'genres': final items = await _libraryService.getGenres(); responsePayload['items'] = items.map((e) => {'id': e.id, 'name': e.name}).toList(); break;
        case 'years': final items = await _libraryService.getYears(); responsePayload['items'] = items; break;
        case 'playlists': final items = await _libraryService.getPlaylists(); responsePayload['items'] = items.map((e) => { 'id': e.id, 'name': e.name, 'isSmart': e.isSmart, 'createdAt': e.createdAt.toIso8601String() }).toList(); break;
      }
    } else {
      switch (modeStr) {
        case 'folders':
          final subs = await _libraryService.getSubFolders(parentId);
          final tracks = await _libraryService.getTracksForFolder(parentId);
          responsePayload['subFolders'] = subs.map((e) => {'id': e.id, 'name': e.name, 'path': e.path}).toList();
          responsePayload['tracks'] = tracks.map((e) => {'id': e.id, 'title': e.title, 'path': e.path, 'artistId': e.artistId}).toList();
          break;
        case 'artists':
          final items = await service.getAlbumsForArtist(parentId);
          responsePayload['albums'] = items.map((e) => {'id': e.id, 'name': e.name, 'coverArt': e.coverArt != null ? base64.encode(e.coverArt!) : null}).toList();
          break;
      }
    }
    unawaited(_connectionManager?.sendCommand(MediaCommand(type: CommandType.libraryData, payload: responsePayload)));
  }

  void _processRemoteLibraryData(Map<String, dynamic>? payload) {
    if (payload == null) return;
    final modeStr = payload['mode'] as String;
    final parentId = payload['parentId']?.toString();
    if (parentId == null) {
      final items = payload['items'] as List<dynamic>;
      switch (modeStr) {
        case 'folders': _folders = items.map((e) { final map = e as Map<String, dynamic>; return Folder(id: map['id']?.toString() ?? '', name: map['name'] as String, path: map['path'] as String, folderType: 0); }).toList(); break;
        case 'artists': _artists = items.map((e) { final map = e as Map<String, dynamic>; return Artist(id: map['id']?.toString() ?? '', name: map['name'] as String, isFavorite: false, playCount: 0); }).toList(); break;
        case 'albums': case 'books': final mapped = items.map((e) { final map = e as Map<String, dynamic>; return Album(id: map['id']?.toString() ?? '', name: map['name'] as String, isFavorite: false, playCount: 0, isAudiobook: modeStr == 'books', isPlayed: false, isDownloadedViaAulos: false, coverArt: map['coverArt'] != null ? base64.decode(map['coverArt'] as String) : null); }).toList(); if (modeStr == 'books') { _books = mapped; } else { _albums = mapped; } break;
        case 'genres': _genres = items.map((e) { final map = e as Map<String, dynamic>; return Genre(id: map['id']?.toString() ?? '', name: map['name'] as String); }).toList(); break;
        case 'years': _years = items.cast<int>(); break;
        case 'playlists': _playlists = items.map((e) { final map = e as Map<String, dynamic>; return Playlist(id: map['id']?.toString() ?? '', name: map['name'] as String, isSmart: map['isSmart'] as bool, createdAt: DateTime.parse(map['createdAt'] as String)); }).toList(); break;
      }
    } else {
      _currentState.subFolders = []; _currentState.subAlbums = []; _currentState.tracks = [];
      if (payload.containsKey('subFolders')) { final subs = payload['subFolders'] as List<dynamic>; _currentState.subFolders = subs.map((e) { final map = e as Map<String, dynamic>; return Folder(id: map['id']?.toString() ?? '', name: map['name'] as String, path: map['path'] as String, folderType: 0); }).toList(); }
      if (payload.containsKey('albums')) { final albumsItems = payload['albums'] as List<dynamic>; _currentState.subAlbums = albumsItems.map((e) { final map = e as Map<String, dynamic>; return Album(id: map['id']?.toString() ?? '', name: map['name'] as String, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false, isDownloadedViaAulos: false, coverArt: map['coverArt'] != null ? base64.decode(map['coverArt'] as String) : null); }).toList(); }
      else if (payload.containsKey('tracks')) { final tracksItems = payload['tracks'] as List<dynamic>; _currentState.tracks = tracksItems.map((e) { final map = e as Map<String, dynamic>; return Track(id: map['id']?.toString() ?? '', title: map['title'] as String, path: map['path'] as String, folderId: '', artistId: map['artistId']?.toString(), rating: 0, isFavorite: false, playCount: 0, isAudiobook: false, isPlayed: false); }).toList(); }
    }
    _isLoading = false; notifyListeners();
  }

  Future<void> autoDiscover() async {
    _isLoading = true; notifyListeners();
    await _libraryService.autoDiscoverTracks();
    await _loadInitialData();
    _isLoading = false; notifyListeners();
  }

  Future<List<Track>> getAllTracks() => _libraryService.getAllTracks();

  @override
  void dispose() {
    _remoteSub?.cancel();
    _connectionManager?.removeListener(_onConnectionStateChanged);
    _indexerService?.removeListener(_onIndexerChanged);
    super.dispose();
  }
}
