import 'package:flutter/foundation.dart';
import 'package:aulos/data/database/app_database.dart' as app_db;
import 'package:aulos/data/database/discovery_database.dart';
import 'package:aulos/domain/library/podcast_service.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/data/library/podcast_download_service.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'dart:async';

class PodcastViewModel extends ChangeNotifier {
  final PodcastService _podcastService;
  final PodcastDiscoveryService _discoveryService;
  final PodcastDownloadService _downloadService;
  final DiscoverySyncManager _syncManager;
  final DiscoveryDatabase _discoveryDb;
  final SettingsViewModel _settingsVM;

  List<app_db.Podcast> _podcasts = [];
  List<app_db.Episode> _episodes = [];
  
  // Discovery State
  List<PodcastSearchResult> _searchResults = [];
  List<PodcastSearchResult> _trendingResults = [];
  Map<String, List<PodcastSearchResult>> _categoryResults = {};
  
  final Map<String, StreamSubscription> _categorySubs = {};
  final Map<String, int> _categoryLimits = {};
  
  bool _isLoading = false;
  String? _error;

  Map<int, double> _downloadProgress = {};
  StreamSubscription? _downloadSub;
  StreamSubscription? _searchSub;
  
  // UI State Persistence
  Map<String, dynamic>? _selectedDiscoveryCategory;
  Map<String, dynamic>? _activeDiscoveryDetail;

  PodcastViewModel({
    required PodcastService podcastService,
    required PodcastDiscoveryService discoveryService,
    required PodcastDownloadService downloadService,
    required DiscoverySyncManager syncManager,
    required DiscoveryDatabase discoveryDb,
    required SettingsViewModel settingsVM,
  }) : _podcastService = podcastService,
       _discoveryService = discoveryService,
       _downloadService = downloadService,
       _syncManager = syncManager,
       _discoveryDb = discoveryDb,
       _settingsVM = settingsVM {
    unawaited(loadPodcasts());
    unawaited(_syncManager.triggerInitialSync());
    
    _downloadSub = _downloadService.progressStream.listen((progress) {
      _downloadProgress = progress;
      notifyListeners();
    });

    _syncManager.addListener(notifyListeners);
  }

  List<app_db.Podcast> get podcasts => _podcasts;
  List<app_db.Episode> get episodes => _episodes;
  List<PodcastSearchResult> get searchResults => _searchResults;
  List<PodcastSearchResult> get trendingResults => _trendingResults;
  Map<String, List<PodcastSearchResult>> get categoryResults => _categoryResults;
  bool get isLoading => _isLoading || _syncManager.isSyncing;
  bool get isSyncing => _syncManager.isSyncing;
  String? get error => _error;
  Map<int, double> get downloadProgress => _downloadProgress;
  
  Map<String, dynamic>? get selectedDiscoveryCategory => _selectedDiscoveryCategory;
  Map<String, dynamic>? get activeDiscoveryDetail => _activeDiscoveryDetail;

  void setSelectedDiscoveryCategory(Map<String, dynamic>? cat) {
    _selectedDiscoveryCategory = cat;
    notifyListeners();
  }

  void setActiveDiscoveryDetail(Map<String, dynamic>? detail) {
    _activeDiscoveryDetail = detail;
    notifyListeners();
  }

  Future<void> loadPodcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _podcasts = await _podcastService.getSubscribedPodcasts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets up a real-time watch for a specific category shelf with a dynamic limit.
  void watchCategory(String catId, {int limit = 10}) {
    // If limit hasn't changed and we already have a sub, do nothing
    if (_categoryLimits[catId] == limit && _categorySubs.containsKey(catId)) return;

    _categoryLimits[catId] = limit;
    _categorySubs[catId]?.cancel();

    _categorySubs[catId] = _discoveryDb.watchByCategory(catId, limit: limit).listen((raw) {
      final mapped = _mapFromDb(raw);
      _categoryResults[catId] = mapped;
      if (catId == 'trending') {
        _trendingResults = mapped;
      }
      notifyListeners();
    });
  }

  List<PodcastSearchResult> _mapFromDb(List<DiscoveredPodcast> raw) {
    return raw.map((p) => PodcastSearchResult(
      title: p.title,
      artist: p.artist,
      feedUrl: p.feedUrl,
      imageUrl: p.imageUrl,
      itunesId: p.iTunesId,
    )).toList();
  }

  Future<void> loadCategoryPreviews(List<Map<String, dynamic>> categories) async {
    for (var cat in categories) {
      watchCategory(cat['id'] as String, limit: 20); // Small preview for home
    }
    watchCategory('trending', limit: 25);
  }

  Future<void> loadMoreForCategory(String categoryId, int currentCount) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Expand the DB watcher limit first
      final newLimit = currentCount + 50;
      watchCategory(categoryId, limit: newLimit);

      // 2. Proactively fetch from API to ensure DB stays ahead of scroll
      await _syncManager.proactiveSync(categoryId, currentCount);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query, {int offset = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _searchSub?.cancel();
    _searchSub = _discoveryDb.watchByCategory('search:$query', limit: 50).listen((raw) {
      _searchResults = _mapFromDb(raw);
      notifyListeners();
    });

    try {
      // Trigger background search and persistence
      await _syncManager.performSearch(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribe(String url) async {
    _isLoading = true;
    notifyListeners();
    try {
      final podcast = await _podcastService.subscribeToFeed(url);
      await loadPodcasts();
      
      final episodes = await _podcastService.getEpisodes(podcast.id);
      if (episodes.isNotEmpty) {
        unawaited(downloadEpisode(episodes.first));
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> subscribeFromDiscovery(PodcastSearchResult result) async {
    _isLoading = true;
    notifyListeners();
    try {
      String? feedUrl = result.feedUrl;
      // Note: In decoupled mode, we still might need a one-off lookup if feedUrl is empty
      // but ideally this is handled in sync layer.
      if (feedUrl.isEmpty && result.itunesId != null) {
        feedUrl = await _discoveryService.lookupFeedUrl(result.itunesId!);
      }

      if (feedUrl != null && feedUrl.isNotEmpty) {
        await subscribe(feedUrl);
      } else {
        _error = 'Could not find feed URL for this podcast.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEpisodes(int podcastId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _episodes = await _podcastService.getEpisodes(podcastId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadEpisode(app_db.Episode episode) async {
    final storage = _settingsVM.podcastStorageLocation;
    if (storage == null) return;

    try {
      await _downloadService.downloadEpisode(episode, storage);
      if (_episodes.any((e) => e.id == episode.id)) {
        _episodes = await _podcastService.getEpisodes(episode.podcastId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('PodcastViewModel: Download failed: $e');
    }
  }

  Future<void> playEpisode(app_db.Episode episode, PlayerViewModel playerVM) async {
    final storage = _settingsVM.podcastStorageLocation;
    if (episode.downloadState != 2 && storage != null) {
       unawaited(downloadEpisode(episode));
    }

    final podcast = _podcasts.firstWhere((p) => p.id == episode.podcastId);

    final track = app_db.Track(
      id: -episode.id,
      path: (episode.downloadState == 2 && episode.localFilePath != null)
          ? episode.localFilePath!
          : episode.audioUrl,
      title: episode.title,
      artistId: 0,
      folderId: 0,
      rating: 0,
      isFavorite: false,
      playCount: 0,
    );

    await playerVM.loadTrack(
      track,
      description: episode.description,
      artistName: episode.title,
      albumName: podcast.title,
      imageUrl: podcast.imageUrl,
    );
  }

  Future<void> playDiscoveredEpisode(
    DiscoveredEpisode ep, 
    String podcastTitle,
    PlayerViewModel playerVM,
  ) async {
    final track = app_db.Track(
      id: -ep.id, // Negative ID to indicate virtual/remote track
      path: ep.audioUrl,
      title: ep.title,
      artistId: 0,
      folderId: 0,
      rating: 0,
      isFavorite: false,
      playCount: 0,
    );

    // Fetch the full podcast metadata to get the image
    final podcast = await _discoveryDb.getByITunesId(ep.iTunesId);

    await playerVM.loadTrack(
      track,
      description: ep.title, // Default to title if no notes yet
      artistName: ep.title,
      albumName: podcastTitle,
      imageUrl: podcast?.imageUrl,
    );
  }

  Future<void> refreshDiscovery() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _syncManager.runGlobalSync();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePin(app_db.Episode episode) async {
    try {
      await _podcastService.updateEpisodePlayback(
        episode.id,
        isPinned: !episode.isPinned,
      );
      _episodes = await _podcastService.getEpisodes(episode.podcastId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update pin status: $e';
      notifyListeners();
    }
  }

  Future<void> unsubscribe(int podcastId) async {
    try {
      await _podcastService.unsubscribe(podcastId);
      await loadPodcasts();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to unsubscribe: $e';
      notifyListeners();
    }
  }

  void exitDiscoveryView() => _syncManager.disableActiveSync();

  Stream<DiscoveredPodcast?> watchPodcast(String iTunesId) {
    return _discoveryDb.watchByITunesId(iTunesId);
  }

  Stream<List<DiscoveredEpisode>> watchEpisodes(String iTunesId) {
    return _discoveryDb.watchEpisodes(iTunesId);
  }

  Future<void> loadPodcastDetails(String iTunesId, String? feedUrl) async {
    // Note: We don't set _isLoading here because syncManager has its own state
    // and we want the UI to show partial data from DB immediately.
    unawaited(_syncManager.syncPodcastDetails(iTunesId, feedUrl));
  }

  @override
  void dispose() {
    _syncManager.removeListener(notifyListeners);
    for (var sub in _categorySubs.values) {
      sub.cancel();
    }
    _downloadSub?.cancel();
    _searchSub?.cancel();
    super.dispose();
  }
}
