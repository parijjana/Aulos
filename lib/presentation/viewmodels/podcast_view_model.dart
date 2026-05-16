import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/domain/library/podcast_service.dart';
import 'package:localaudioplayer/data/library/podcast_discovery_service.dart';
import 'package:localaudioplayer/data/library/podcast_download_service.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'dart:async';

class PodcastViewModel extends ChangeNotifier {
  final PodcastService _podcastService;
  final PodcastDiscoveryService _discoveryService;
  final PodcastDownloadService _downloadService;
  final SettingsViewModel _settingsVM;

  List<Podcast> _podcasts = [];
  List<Episode> _episodes = [];
  List<PodcastSearchResult> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  Map<int, double> _downloadProgress = {};
  StreamSubscription? _downloadSub;

  PodcastViewModel({
    required PodcastService podcastService,
    required PodcastDiscoveryService discoveryService,
    required PodcastDownloadService downloadService,
    required SettingsViewModel settingsVM,
  }) : _podcastService = podcastService,
       _discoveryService = discoveryService,
       _downloadService = downloadService,
       _settingsVM = settingsVM {
    unawaited(loadPodcasts());
    _downloadSub = _downloadService.progressStream.listen((progress) {
      _downloadProgress = progress;
      notifyListeners();
    });
  }

  List<Podcast> get podcasts => _podcasts;
  List<Episode> get episodes => _episodes;
  List<PodcastSearchResult> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<int, double> get downloadProgress => _downloadProgress;

  Future<void> loadPodcasts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _podcasts = await _podcastService.getSubscribedPodcasts();
      _error = null;
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

  Future<void> search(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      _searchResults = await _discoveryService.searchPodcasts(query);
      _error = null;
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
      _error = null;

      // Handle auto-download
      if (_settingsVM.autoDownloadNewEpisodes) {
        final episodes = await _podcastService.getEpisodes(podcast.id);
        if (episodes.isNotEmpty) {
          unawaited(downloadEpisode(episodes.first));
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadEpisode(Episode episode) async {
    final storage = _settingsVM.podcastStorageLocation;
    if (storage == null) {
      _error = 'Podcast storage location not set in Settings.';
      notifyListeners();
      return;
    }

    try {
      await _downloadService.downloadEpisode(episode, storage);
      // Refresh current episode list to update UI states
      final podcastId = episode.podcastId;
      _episodes = await _podcastService.getEpisodes(podcastId);
      notifyListeners();
    } catch (e) {
      _error = 'Download failed: $e';
      notifyListeners();
    }
  }

  Future<void> refreshPodcast(int podcastId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _podcastService.refreshPodcast(podcastId);
      await loadEpisodes(podcastId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unsubscribe(int podcastId) async {
    try {
      await _podcastService.unsubscribe(podcastId);
      await loadPodcasts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }

  Future<void> unawaited(Future<void> future) async {}
}
