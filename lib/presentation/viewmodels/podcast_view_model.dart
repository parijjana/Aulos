import 'package:flutter/material.dart';
import 'package:aulos/data/database/app_database.dart' as app_db;
import 'package:aulos/data/database/podcast_database.dart' as podcast_db;
import 'package:aulos/domain/library/podcast_service.dart';
import 'package:aulos/domain/library/podcast.dart' as dom_podcast;
import 'package:aulos/domain/library/episode.dart' as dom_episode;
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/data/library/podcast_download_service.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

class PodcastViewModel extends ChangeNotifier {
  final PodcastService _podcastService;
  final PodcastDiscoveryService _discoveryService;
  final PodcastDownloadService _downloadService;
  final DiscoverySyncManager _syncManager;
  final podcast_db.PodcastDatabase _discoveryDb;
  final SettingsViewModel _settingsVM;
  final LogService _logService;

  List<podcast_db.Podcast> _podcasts = [];
  List<podcast_db.Episode> _episodes = [];
  
  // Discovery State
  List<PodcastSearchResult> _searchResults = [];
  List<PodcastSearchResult> _trendingResults = [];
  Map<String, List<PodcastSearchResult>> _categoryResults = {};
  
  final Map<String, StreamSubscription<dynamic>> _categorySubs = {};
  final Map<String, int> _categoryLimits = {};
  
  bool _isLoading = false;
  String? _error;

  Map<String, double> _downloadProgress = {};
  final Map<String, int> _episodePositions = {};
  Map<String, int> get episodePositions => _episodePositions;

  Future<void> _loadEpisodePositions() async {
    _episodePositions.clear();
    for (final ep in _episodes) {
      final pos = await _podcastService.getPlaybackPosition(ep.id);
      _episodePositions[ep.id] = pos;
    }
  }

  StreamSubscription<dynamic>? _downloadSub;
  StreamSubscription<dynamic>? _searchSub;
  String _lastSearchQuery = '';
  bool _disposed = false;
  
  // UI State Persistence
  Map<String, dynamic>? _selectedDiscoveryCategory;
  Map<String, dynamic>? _activeDiscoveryDetail;
  podcast_db.Podcast? _activePodcast;
  String _libraryFilter = 'ALL SHOWS';
  bool _tempShowHome = false;

  PodcastViewModel({
    required PodcastService podcastService,
    required PodcastDiscoveryService discoveryService,
    required PodcastDownloadService downloadService,
    required DiscoverySyncManager syncManager,
    required podcast_db.PodcastDatabase discoveryDb,
    required SettingsViewModel settingsVM,
    LogService? logService,
  }) : _podcastService = podcastService,
       _discoveryService = discoveryService,
       _downloadService = downloadService,
       _syncManager = syncManager,
       _discoveryDb = discoveryDb,
       _settingsVM = settingsVM,
       _logService = logService ?? NoOpLogService() {
    log('PODCAST_VM: Initializing...');
    _libraryFilter = 'ALL SHOWS';
    unawaited(loadPodcasts());
    unawaited(_syncManager.triggerInitialSync());
    _downloadSub = _downloadService.progressStream.listen((progress) {
      _downloadProgress = progress;
      notifyListeners();
    });
    _syncManager.addListener(notifyListeners);
  }

  void log(String message) => _logService.log(message);

  List<podcast_db.Podcast> get podcasts => _podcasts;
  List<podcast_db.Episode> get episodes => _episodes;
  List<PodcastSearchResult> get searchResults => _searchResults;
  List<PodcastSearchResult> get trendingResults => _trendingResults;
  Map<String, List<PodcastSearchResult>> get categoryResults => _categoryResults;
  bool get isLoading => _isLoading || _syncManager.isSyncing;
  bool get isSyncing => _syncManager.isSyncing;
  String? get error => _error;
  Map<String, double> get downloadProgress => _downloadProgress;
  String get lastSearchQuery => _lastSearchQuery;
  
  Map<String, dynamic>? get selectedDiscoveryCategory => _selectedDiscoveryCategory;
  Map<String, dynamic>? get activeDiscoveryDetail => _activeDiscoveryDetail;
  podcast_db.Podcast? get activePodcast => _activePodcast;
  String get libraryFilter => _libraryFilter;
  bool get tempShowHome => _tempShowHome;

  void setTempShowHome(bool show) {
    _tempShowHome = show;
    notifyListeners();
  }

  List<podcast_db.Podcast> get filteredPodcasts {
    var list = List<podcast_db.Podcast>.from(_podcasts);
    
    if (_libraryFilter == 'RECENT') {
      list.sort((a, b) {
        final dateA = a.lastPlayed ?? DateTime(1970);
        final dateB = b.lastPlayed ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    } else if (_libraryFilter == 'DOWNLOADED') {
      list = _podcasts.where((p) => p.playCount > 0).toList();
    }
    
    log('PODCAST_VM: filteredPodcasts called. Filter: $_libraryFilter, Returning: ${list.length}/${_podcasts.length}');
    return list;
  }

  void setLibraryFilter(String filter) {
    _libraryFilter = filter;
    notifyListeners();
  }

  void setSelectedDiscoveryCategory(Map<String, dynamic>? cat) {
    _selectedDiscoveryCategory = cat;
    notifyListeners();
  }

  void setActiveDiscoveryDetail(Map<String, dynamic>? detail) {
    _activeDiscoveryDetail = detail;
    notifyListeners();
  }

  void setActivePodcast(podcast_db.Podcast? podcast) {
    _activePodcast = podcast;
    _tempShowHome = false;
    notifyListeners();
  }

  Future<void> loadPodcasts() async {
    log('PODCAST_VM: loadPodcasts() started');
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _podcasts = (await _podcastService.getSubscribedPodcasts()).map((p) => p.toDrift()).toList();
      log('PODCAST_VM: Fetched ${_podcasts.length} podcasts from service');
    } catch (e) {
      log('PODCAST_VM: Error loading podcasts: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void watchCategory(String catId, {int limit = 10}) {
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

  List<PodcastSearchResult> _mapFromDb(List<podcast_db.DiscoveredPodcast> raw) {
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
    log('PODCAST_VM: search("$query") called');
    _lastSearchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _searchSub?.cancel();
    _searchSub = _discoveryDb.watchByCategory('search:$query', limit: 50).listen((raw) {
      log('PODCAST_VM: Search watcher fired for "$query". Emitted ${raw.length} items.');
      _searchResults = _mapFromDb(raw);
      notifyListeners();
    });

    try {
      // Trigger background search and persistence
      await _syncManager.performSearch(query);
    } catch (e) {
      log('PODCAST_VM_ERROR: Search failed: $e');
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
      final podcast = (await _podcastService.subscribeToFeed(url)).toDrift();
      await loadPodcasts();
      
      final episodes = await _podcastService.getEpisodes(podcast.id);
      if (episodes.isNotEmpty) {
        unawaited(downloadEpisode(episodes.first.toDrift()));
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
      final itunesId = result.itunesId;
      if (feedUrl.isEmpty && itunesId != null) {
        feedUrl = await _discoveryService.lookupFeedUrl(itunesId);
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

  Future<void> loadEpisodes(String podcastId) async {
    log('PODCAST_VM: loadEpisodes($podcastId) started');
    _isLoading = true;
    _episodes = []; // CLEAR OLD EPISODES
    _error = null;
    notifyListeners();
    try {
      _episodes = (await _podcastService.getEpisodes(podcastId)).map((e) => e.toDrift()).toList();
      await _loadEpisodePositions();
      log('PODCAST_VM: Fetched ${_episodes.length} episodes for podcast $podcastId');
      _error = null;
    } catch (e) {
      log('PODCAST_VM_ERROR: Error loading episodes: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPodcast(String podcastId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _podcastService.refreshPodcast(podcastId);
      await loadEpisodes(podcastId);
    } catch (e) {
      _error = 'Failed to refresh feed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAllSubscribedPodcasts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final subscribed = await _podcastService.getSubscribedPodcasts();
      if (subscribed.isNotEmpty) {
        log('PODCAST_VM: Refreshing ${subscribed.length} subscribed podcasts...');
        await Future.wait(subscribed.map((pod) async {
          try {
            await _podcastService.refreshPodcast(pod.id);
          } catch (e) {
            log('PODCAST_VM: Failed to refresh podcast ${pod.id}: $e');
          }
        }));
      }
      await loadPodcasts();
    } catch (e) {
      log('PODCAST_VM: Error refreshing subscribed podcasts: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAndRefreshLibraryDaily() async {
    final lastRefresh = _settingsVM.lastPodcastRefreshTime;
    final now = DateTime.now();
    if (lastRefresh == null || now.difference(lastRefresh).inHours >= 24) {
      log('PODCAST_VM: Automatically refreshing subscribed podcasts (daily sync)...');
      await refreshAllSubscribedPodcasts();
      await _settingsVM.setLastPodcastRefreshTime(now);
    } else {
      log('PODCAST_VM: Daily refresh not needed. Last refresh was at $lastRefresh');
    }
  }

  Future<void> downloadEpisode(podcast_db.Episode episode) async {
    final storage = _settingsVM.podcastStorageLocation;
    if (storage == null) return;

    try {
      await _downloadService.downloadEpisode(episode, storage);
      if (_episodes.any((e) => e.id == episode.id)) {
        _episodes = (await _podcastService.getEpisodes(episode.podcastId)).map((e) => e.toDrift()).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('PodcastViewModel: Download failed: $e');
    }
  }

  Future<void> playEpisode(podcast_db.Episode episode, PlayerViewModel playerVM, {bool isAvailable = true}) async {
    final storage = _settingsVM.podcastStorageLocation;
    if (episode.downloadState != 2 && storage != null) {
       unawaited(downloadEpisode(episode));
    }

    final podcast = _podcasts.where((p) => p.id == episode.podcastId).firstOrNull;
    if (podcast == null) {
      log('PODCAST_VM_ERROR: Cannot play episode, parent podcast not found in memory.');
      return;
    }

    final localFilePath = episode.localFilePath;
    final track = app_db.Track(
      id: 'podcast_${episode.id}',
      path: (episode.downloadState == 2 && localFilePath != null)
          ? localFilePath
          : episode.audioUrl,
      title: episode.title,
      artistId: 'podcast_artist',
      folderId: 'podcast_folder',
      rating: 0,
      isFavorite: false,
      playCount: 0,
      isAudiobook: false,
      isPlayed: false,
    );

    await playerVM.loadTrack(
      track,
      description: episode.description,
      artistName: episode.title,
      albumName: podcast.title,
      imageUrl: podcast.imageUrl,
      isAvailable: isAvailable,
    );
  }

  Future<void> playDiscoveredEpisode(
    podcast_db.DiscoveredEpisode ep, 
    String podcastTitle,
    PlayerViewModel playerVM, {
    bool isAvailable = true,
  }) async {
    final track = app_db.Track(
      id: 'podcast_${ep.id}', // Prefix with podcast_
      path: ep.audioUrl,
      title: ep.title,
      artistId: 'podcast_artist',
      folderId: 'podcast_folder',
      rating: 0,
      isFavorite: false,
      playCount: 0,
      isAudiobook: false,
      isPlayed: false,
    );

    // Fetch the full podcast metadata to get the image
    final podcast = await _discoveryDb.getByITunesId(ep.iTunesId);

    await playerVM.loadTrack(
      track,
      description: ep.title, // Default to title if no notes yet
      artistName: ep.title,
      albumName: podcastTitle,
      imageUrl: podcast?.imageUrl,
      isAvailable: isAvailable,
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

  Future<void> deleteEpisode(podcast_db.Episode episode, BuildContext context) async {
    final path = episode.localFilePath ?? '';
    final bookmarks = await _podcastService.getBookmarksForTrack(path);
    
    if (bookmarks.isNotEmpty) {
      if (!context.mounted) return;
      final result = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Episode?'),
          content: Text('This episode has ${bookmarks.length} saved clips. What would you like to do?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, 0), child: const Text('CANCEL')),
            TextButton(onPressed: () => Navigator.pop(context, 1), child: const Text('DELETE ALL', style: TextStyle(color: Colors.redAccent))),
            TextButton(onPressed: () => Navigator.pop(context, 2), child: const Text('PRESERVE CLIPS')),
          ],
        ),
      );

      if (result == 0 || result == null) return;
      if (result == 1) {
        // Option 2: Delete episode + bookmarks
        await _podcastService.deleteBookmarksForTrack(path);
      } else if (result == 2) {
        // Option 3: Preserve bookmarks (Move to Remote URL)
        await _podcastService.updateBookmarkPaths(path, episode.audioUrl);
      }
    }

    try {
      // CLEANUP RESUME DATA
      await _podcastService.deletePlaybackPosition(episode.id);

      final localFilePath = episode.localFilePath;
      if (localFilePath != null) {
        final file = File(localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _podcastService.updateEpisodePlayback(
        episode.id,
        downloadState: 0,
        localFilePath: null,
      );
      _episodes = (await _podcastService.getEpisodes(episode.podcastId)).map((e) => e.toDrift()).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete episode: $e';
      notifyListeners();
    }
  }

  Future<void> togglePin(podcast_db.Episode episode) async {
    try {
      String? newPath = episode.localFilePath;
      
      final localFilePath = episode.localFilePath;
      if (episode.downloadState == 2 && localFilePath != null) {
        final storage = _settingsVM.podcastStorageLocation;
        if (storage != null) {
          final file = File(localFilePath);
          if (await file.exists()) {
            final fileName = p.basename(localFilePath);
            final favoritesDir = Directory(p.join(storage, 'favorites'));
            if (!favoritesDir.existsSync()) await favoritesDir.create(recursive: true);

            final podcast = _podcasts.firstWhere((p) => p.id == episode.podcastId);
            final podcastName = _sanitize(podcast.title);

            if (!episode.isPinned) {
              final targetPath = p.join(favoritesDir.path, '${podcastName}_$fileName');
              await file.rename(targetPath);
              newPath = targetPath;
            } else {
              final podDir = Directory(p.join(storage, podcastName));
              if (!podDir.existsSync()) await podDir.create(recursive: true);
              
              final cleanName = fileName.replaceFirst('${podcastName}_', '');
              final targetPath = p.join(podDir.path, cleanName);
              await file.rename(targetPath);
              newPath = targetPath;
            }
          }
        }
      }

      await _podcastService.updateEpisodePlayback(
        episode.id,
        isPinned: !episode.isPinned,
        localFilePath: newPath,
      );
      _episodes = (await _podcastService.getEpisodes(episode.podcastId)).map((e) => e.toDrift()).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update pin status: $e';
      notifyListeners();
    }
  }

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  Future<void> unsubscribe(String podcastId) async {
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

  Stream<podcast_db.DiscoveredPodcast?> watchPodcast(String iTunesId) {
    return _discoveryDb.watchByITunesId(iTunesId);
  }

  Stream<List<podcast_db.DiscoveredEpisode>> watchEpisodes(String iTunesId) {
    return _discoveryDb.watchEpisodes(iTunesId);
  }

  Future<void> loadPodcastDetails(String iTunesId, String? feedUrl) async {
    unawaited(_syncManager.syncPodcastDetails(iTunesId, feedUrl));
  }

  @override
  void dispose() {
    _disposed = true;
    _syncManager.removeListener(notifyListeners);
    for (var sub in _categorySubs.values) {
      sub.cancel();
    }
    _downloadSub?.cancel();
    _searchSub?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}

extension DomainPodcastToDrift on dom_podcast.Podcast {
  podcast_db.Podcast toDrift() {
    return podcast_db.Podcast(
      id: id,
      feedUrl: feedUrl,
      title: title,
      description: description,
      author: author,
      imageUrl: imageUrl,
      image: image,
      subscribedAt: subscribedAt,
      isFavorite: isFavorite,
      playCount: playCount,
      lastPlayed: lastPlayed,
    );
  }
}

extension DomainEpisodeToDrift on dom_episode.Episode {
  podcast_db.Episode toDrift() {
    return podcast_db.Episode(
      id: id,
      podcastId: podcastId,
      guid: guid,
      title: title,
      description: description,
      audioUrl: audioUrl,
      localFilePath: localFilePath,
      downloadState: downloadState,
      pubDate: pubDate,
      durationSeconds: durationSeconds,
      isPlayed: isPlayed,
      isPinned: isPinned,
      playbackPositionSeconds: playbackPositionSeconds,
      playCount: playCount,
      lastPlayed: lastPlayed,
    );
  }
}
