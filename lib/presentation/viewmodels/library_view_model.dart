import 'package:flutter/foundation.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/domain/network/socket_service.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:aulos/data/library/providers/audnexus_service.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'library_view_model_sync.dart';
import 'library_view_model_enrichment.dart';

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

  // Getters/setters/helpers for extensions
  Map<LibraryMode, LibraryNavigationState> get states => _states;
  LibraryNavigationState get currentState => _currentState;
  PersistentLibraryService get libraryService => _libraryService;
  ConnectionManager? get connectionManager => _connectionManager;
  Map<String, Uint8List> get artCache => _artCache;

  List<Folder> get foldersRaw => _folders;
  set foldersRaw(List<Folder> val) => _folders = val;

  List<Artist> get artistsRaw => _artists;
  set artistsRaw(List<Artist> val) => _artists = val;

  List<Album> get albumsRaw => _albums;
  set albumsRaw(List<Album> val) => _albums = val;

  List<Album> get booksRaw => _books;
  set booksRaw(List<Album> val) => _books = val;

  List<Genre> get genresRaw => _genres;
  set genresRaw(List<Genre> val) => _genres = val;

  List<int> get yearsRaw => _years;
  set yearsRaw(List<int> val) => _years = val;

  List<Playlist> get playlistsRaw => _playlists;
  set playlistsRaw(List<Playlist> val) => _playlists = val;

  set isLoading(bool val) => _isLoading = val;
  void triggerNotify() => notifyListeners();

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
    _remoteSub = _connectionManager?.remoteCommands.listen(handleRemoteCommand);
    _connectionManager?.addListener(_onConnectionStateChanged);

    if (_indexerService != null) {
      _lastIndexerState = _indexerService.state;
      _indexerService.addListener(_onIndexerChanged);
    }
  }

  void log(String message) => _logService.log(message);

  void _onIndexerChanged() {
    if (_indexerService == null) return;
    final currentState = _indexerService.state;
    if (_lastIndexerState != null &&
        _lastIndexerState != IndexerState.idle &&
        currentState == IndexerState.idle) {
      log('LibraryViewModel: Indexer completed. Reloading library data...');
      unawaited(reloadLibrary());
    }
    _lastIndexerState = currentState;
  }

  AudnexusService get audnexus => _audnexus;

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

  LibraryNavigationState stateFor(LibraryMode m) => _states[m] ?? LibraryNavigationState();
  bool isAtRootFor(LibraryMode m) => stateFor(m).navStack.isEmpty;
  dynamic selectedItemFor(LibraryMode m) => stateFor(m).selectedItem;
  List<Track> tracksFor(LibraryMode m) => stateFor(m).tracks;
  List<Album> subAlbumsFor(LibraryMode m) => stateFor(m).subAlbums;
  List<Folder> subFoldersFor(LibraryMode m) => stateFor(m).subFolders;

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
  }

  bool _isModeLoaded(LibraryMode m) {
    switch (m) {
      case LibraryMode.folders: return _folders.isNotEmpty;
      case LibraryMode.artists: return _artists.isNotEmpty;
      case LibraryMode.albums: return _albums.isNotEmpty;
      case LibraryMode.genres: return _genres.isNotEmpty;
      case LibraryMode.years: return _years.isNotEmpty;
      case LibraryMode.playlists: return _playlists.isNotEmpty;
      case LibraryMode.books: return _books.isNotEmpty;
    }
  }

  void updateLibraryTabIndex(int val) {
    _libraryTabIndex = val;
    _settingsVM?.setLibraryHubTabIndex(val);
    notifyListeners();
  }

  void setBookSort(AudiobookSort val) {
    _bookSort = val;
    notifyListeners();
  }

  void setBookFilterAulos(bool val) {
    _bookFilterAulos = val;
    notifyListeners();
  }

  void setViewType(settings.LibraryViewType val) {
    _viewType = val;
    _settingsVM?.setLastViewType(val);
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _currentState.searchQuery = q.trim();
    notifyListeners();
  }

  Future<void> reloadLibrary() async {
    _isLoading = true;
    notifyListeners();
    // Clear all mode stacks and cache
    for (var mode in LibraryMode.values) {
      final s = _states[mode];
      if (s != null) {
        s.navStack.clear();
        s.selectedItem = null;
        s.subFolders = [];
        s.subAlbums = [];
        s.tracks = [];
        s.searchQuery = '';
      }
    }
    _folders = [];
    _artists = [];
    _albums = [];
    _books = [];
    _genres = [];
    _years = [];
    _playlists = [];

    await _loadInitialData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    if (_connectionManager?.isClient ?? false) {
      _isLoading = true; notifyListeners();
      unawaited(_connectionManager?.sendCommand(MediaCommand(type: CommandType.getLibrary, payload: {'mode': _mode.name})));
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      switch (_mode) {
        case LibraryMode.folders: _folders = await _libraryService.getRootFolders(); break;
        case LibraryMode.artists: _artists = await _libraryService.getArtists(); break;
        case LibraryMode.albums: _albums = await _libraryService.getAlbums(); break;
        case LibraryMode.genres: _genres = await _libraryService.getGenres(); break;
        case LibraryMode.years: _years = await _libraryService.getYears(); break;
        case LibraryMode.playlists: _playlists = await _libraryService.getPlaylists(); break;
        case LibraryMode.books: _books = await _libraryService.getAudiobooks(); await calculateBookProgress(); break;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectItem(dynamic item) async {
    if (item == null) return;
    _isLoading = true; notifyListeners();

    _currentState.navStack.add(item);
    _currentState.selectedItem = item;

    if (item is Folder) {
      _currentState.subFolders = await _libraryService.getSubFolders(item.id, folderType: item.folderType);
      _currentState.tracks = await _libraryService.getTracksForFolder(item.id);
    } else if (item is Artist) {
      final service = _libraryService as PersistentLibraryServiceImpl;
      _currentState.subAlbums = await service.getAlbumsForArtist(item.id);
    } else if (item is Album) {
      _currentState.tracks = item.isAudiobook 
          ? await _libraryService.getChapters(item.id)
          : await _libraryService.getTracksForAlbum(item.id);
    } else if (item is Playlist) {
      _currentState.tracks = await _libraryService.getTracksForPlaylist(item.id);
    }

    _isLoading = false; notifyListeners();
  }

  Future<void> selectArtistAlbum(String artistId, String albumId) async {
    _isLoading = true; notifyListeners();
    final service = _libraryService as PersistentLibraryServiceImpl;
    
    final album = (await _libraryService.getAlbums()).firstWhere((a) => a.id == albumId);
    _currentState.navStack.add(album);
    _currentState.selectedItem = album;
    
    _currentState.tracks = await service.getTracksForArtistInAlbum(artistId, albumId);
    _isLoading = false; notifyListeners();
  }

  Future<void> selectGenreAlbum(String genreId, String albumId) async {
    _isLoading = true; notifyListeners();
    final service = _libraryService as PersistentLibraryServiceImpl;
    
    final album = (await _libraryService.getAlbums()).firstWhere((a) => a.id == albumId);
    _currentState.navStack.add(album);
    _currentState.selectedItem = album;
    
    _currentState.tracks = await service.getTracksForGenreInAlbum(genreId, albumId);
    _isLoading = false; notifyListeners();
  }

  Future<void> selectYearAlbum(int year, String albumId) async {
    _isLoading = true; notifyListeners();
    final service = _libraryService as PersistentLibraryServiceImpl;
    
    final album = (await _libraryService.getAlbums()).firstWhere((a) => a.id == albumId);
    _currentState.navStack.add(album);
    _currentState.selectedItem = album;
    
    _currentState.tracks = await service.getTracksForYearInAlbum(year, albumId);
    _isLoading = false; notifyListeners();
  }

  void goBack() {
    if (_currentState.navStack.isEmpty) return;
    
    _currentState.scrollOffset = 0.0;
    _currentState.navStack.removeLast();
    
    if (_currentState.navStack.isEmpty) {
      _currentState.selectedItem = null;
      _currentState.subFolders = [];
      _currentState.subAlbums = [];
      _currentState.tracks = [];
      unawaited(_loadInitialData());
    } else {
      final prev = _currentState.navStack.last;
      _currentState.selectedItem = prev;
      unawaited(selectItem(prev));
    }
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

  Future<void> autoDiscover() async {
    _isLoading = true; notifyListeners();
    await _libraryService.autoDiscoverTracks();
    await _loadInitialData();
    _isLoading = false; notifyListeners();
  }

  Future<List<Track>> getAllTracks() => _libraryService.getAllTracks();

  Uint8List? getArtForTrack({required String trackId}) =>
      LibraryViewModelSync(this).getArtForTrack(trackId: trackId);

  Future<void> enrichAudiobook(Album book) =>
      LibraryViewModelEnrichment(this).enrichAudiobook(book);

  @override
  void dispose() {
    _remoteSub?.cancel();
    _connectionManager?.removeListener(_onConnectionStateChanged);
    _indexerService?.removeListener(_onIndexerChanged);
    super.dispose();
  }
}
