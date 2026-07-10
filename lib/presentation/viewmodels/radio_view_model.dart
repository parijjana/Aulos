import 'package:flutter/foundation.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/data/library/radio_browser_service.dart';
import 'package:aulos/data/library/radio_sync_manager.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/data/database/app_database.dart' as app_db;
import 'package:aulos/domain/network/log_service.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'radio_station_list_updater.dart';

class RadioViewModel extends ChangeNotifier {
  final RadioBrowserService _api;
  final RadioDatabase _db;
  final RadioSyncManager _syncManager;
  final LogService _logService;
  final http.Client _httpClient = http.Client();

  List<RadioStation> _favorites = [];
  List<RadioCategory> _categories = [];
  List<RadioStation> _browseResults = [];
  List<RadioStation> _searchResults = [];
  List<Map<String, dynamic>> _allCountries = [];
  List<Map<String, dynamic>> _allLanguages = [];

  StreamSubscription<dynamic>? _browseSub;
  StreamSubscription<dynamic>? _searchSub;
  StreamSubscription<dynamic>? _favSub;
  StreamSubscription<dynamic>? _catSub;

  bool _isLoading = false;
  String? _error;
  bool _isShowingHidden = false;
  int _nextUnavailableCheckIndex = 0;
  String _libraryFilter = 'ALL STATIONS';
  bool _disposed = false;

  bool _tempShowHome = false;

  RadioViewModel({
    required RadioBrowserService api,
    required RadioDatabase db,
    required RadioSyncManager syncManager,
    LogService? logService,
  }) : _api = api, _db = db, _syncManager = syncManager, _logService = logService ?? NoOpLogService() {
    _init();
  }

  void log(String message) => _logService.log(message);

  @override
  void dispose() {
    _disposed = true;
    _browseSub?.cancel();
    _searchSub?.cancel();
    _favSub?.cancel();
    _catSub?.cancel();
    _httpClient.close();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  List<RadioStation> get favorites => _favorites;
  List<RadioCategory> get categories => _categories;
  List<RadioStation> get browseResults => _browseResults;
  List<RadioStation> get searchResults => _searchResults;
  List<Map<String, dynamic>> get allCountries => _allCountries;
  List<Map<String, dynamic>> get allLanguages => _allLanguages;
  bool get isLoading => _isLoading || _syncManager.isSyncing;
  String? get error => _error;
  bool get isShowingHidden => _isShowingHidden;
  String get libraryFilter => _libraryFilter;
  bool get tempShowHome => _tempShowHome;

  void setTempShowHome(bool value) {
    _tempShowHome = value;
    notifyListeners();
  }

  List<RadioStation> get filteredFavorites {
    var list = List<RadioStation>.from(_favorites);
    
    if (_libraryFilter == 'RECENT') {
      list.sort((a, b) {
        final dateA = a.lastCheck ?? DateTime(1970);
        final dateB = b.lastCheck ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });
    } else if (_libraryFilter == 'AVAILABLE') {
      return list.where((s) => s.isAvailable).toList();
    }
    
    return list;
  }

  void setLibraryFilter(String filter) {
    _libraryFilter = filter;
    notifyListeners();
  }

  Future<void> _init({bool force = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _setupSubscriptions();

    try {
      unawaited(_syncManager.runInitialSync(force: force));
      
      final prefs = await SharedPreferences.getInstance();
      final cachedCountries = prefs.getString('cached_radio_countries');
      final cachedLanguages = prefs.getString('cached_radio_languages');
      final lastMetaSyncStr = prefs.getString('last_radio_metadata_sync_time');
      
      bool needsMetaSync = force || cachedCountries == null || cachedLanguages == null || lastMetaSyncStr == null;
      if (!needsMetaSync) {
        final lastMetaSync = DateTime.tryParse(lastMetaSyncStr);
        if (lastMetaSync == null || DateTime.now().difference(lastMetaSync).inDays >= 30) {
          needsMetaSync = true;
        }
      }
      
      if (needsMetaSync) {
        log('RADIO: Fetching countries and languages from remote API...');
        _allCountries = await _api.getAllCountries();
        _allLanguages = await _api.getAllLanguages();
        
        await prefs.setString('cached_radio_countries', jsonEncode(_allCountries));
        await prefs.setString('cached_radio_languages', jsonEncode(_allLanguages));
        await prefs.setString('last_radio_metadata_sync_time', DateTime.now().toIso8601String());
      } else {
        log('RADIO: Loading countries and languages from local cache...');
        _allCountries = List<Map<String, dynamic>>.from(jsonDecode(cachedCountries!) as List);
        _allLanguages = List<Map<String, dynamic>>.from(jsonDecode(cachedLanguages!) as List);
      }
      
      // Load initial discovery view
      await loadDiscoveryHome(runHealthCheck: force);
      
      // HEALTH CHECK: Run health checks for library stations (cached monthly or forced)
      final lastHealthCheckStr = prefs.getString('last_radio_health_check_time');
      bool needsHealthCheck = force || lastHealthCheckStr == null;
      if (!needsHealthCheck) {
        final lastHealthCheck = DateTime.tryParse(lastHealthCheckStr);
        if (lastHealthCheck == null || DateTime.now().difference(lastHealthCheck).inDays >= 30) {
          needsHealthCheck = true;
        }
      }
      if (needsHealthCheck) {
        unawaited(_performHealthChecks().then((_) async {
          await prefs.setString('last_radio_health_check_time', DateTime.now().toIso8601String());
        }));
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupSubscriptions() {
    _favSub?.cancel();
    _favSub = _db.watchFavorites(includeHidden: _isShowingHidden).listen((stations) {
      _favorites = stations;
      notifyListeners();
    });

    _catSub?.cancel();
    _catSub = _db.select(_db.radioCategories).watch().listen((cats) {
      _categories = cats;
      notifyListeners();
    });
  }

  Future<void> loadDiscoveryHome({bool runHealthCheck = false}) async {
    _browseResults = await _db.getTopStations(limit: 30);
    notifyListeners();
    if (runHealthCheck) {
      unawaited(checkHealthForBrowseResults());
    }
  }

  void toggleShowingHidden() {
    _isShowingHidden = !_isShowingHidden;
    _setupSubscriptions();
  }

  Future<void> _performHealthChecks() async {
    final library = await _db.getFavorites(includeHidden: true);
    await checkHealthForStations(library);
  }

  Future<void> checkHealthForBrowseResults() async {
    _nextUnavailableCheckIndex = 0;
    final healthy = _browseResults.where((s) => s.isAvailable).toList();
    final offline = _browseResults.where((s) => !s.isAvailable).toList();
    
    log('RADIO_HEALTH: Running initial health check (Healthy: ${healthy.length}, First 20 Offline)');
    
    // 1. Check all healthy
    await checkHealthForStations(healthy);
    
    // 2. Check first 20 offline
    final firstBatch = offline.take(20).toList();
    _nextUnavailableCheckIndex = firstBatch.length;
    await checkHealthForStations(firstBatch);
  }

  Future<void> checkMoreUnavailableHealth() async {
    final offline = _browseResults.where((s) => !s.isAvailable).toList();
    if (_nextUnavailableCheckIndex >= offline.length) return;

    final nextBatch = offline.skip(_nextUnavailableCheckIndex).take(20).toList();
    log('RADIO_HEALTH: Lazy-checking next ${nextBatch.length} offline stations (Index: $_nextUnavailableCheckIndex)');
    
    _nextUnavailableCheckIndex += nextBatch.length;
    await checkHealthForStations(nextBatch);
  }

  Future<void> checkHealthForStations(List<RadioStation> stations) async {
    if (stations.isEmpty) return;

    // Process in batches of 5 to be network friendly
    const int batchSize = 5;
    for (int i = 0; i < stations.length; i += batchSize) {
      final end = (i + batchSize < stations.length) ? i + batchSize : stations.length;
      final batch = stations.sublist(i, end);
      
      await Future.wait(batch.map((station) async {
        try {
          final response = await _httpClient.head(Uri.parse(station.url))
              .timeout(const Duration(seconds: 4));
          final available = response.statusCode < 400;
          
          // 1. Update in-memory to prevent re-sorting UI
          _updateInMemoryStation(station.stationUuid, available);
          
          // 2. Persist to DB
          await _db.updateHealth(station.stationUuid, available);
        } catch (e) {
          _updateInMemoryStation(station.stationUuid, false);
          await _db.updateHealth(station.stationUuid, false);
        }
      }));
      
      notifyListeners(); // Refresh UI for this batch
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  void _updateInMemoryStation(String uuid, bool available) {
    RadioStationListUpdater.updateAvailability(_browseResults, _searchResults, uuid, available);
  }

  Future<void> toggleHidden(RadioStation station) async {
    final targetHidden = !station.isHidden;
    _updateStationHiddenState(station.stationUuid, targetHidden);
    try {
      await _db.setHidden(station.stationUuid, targetHidden);
    } catch (e) {
      log('Failed to toggle hidden in DB: $e');
      _updateStationHiddenState(station.stationUuid, !targetHidden);
    }
  }

  Future<void> browseCategory(String tag) async {
    _isLoading = true;
    _browseResults = [];
    notifyListeners();
    
    try {
      // 1. Sync metadata in background
      await _syncManager.syncCategory(tag);
      
      // 2. Fetch from DB with STABLE order (get() instead of watch())
      _browseResults = await _db.getByCategory(tag, limit: 100);
      notifyListeners();
      
      // 3. Trigger initial health checks
      unawaited(checkHealthForBrowseResults());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> browseByCountry(String country) async {
    _isLoading = true;
    _browseResults = [];
    notifyListeners();
    
    try {
      await _syncManager.syncByCountry(country);
      _browseResults = await (_db.select(_db.radioStations)
            ..where((t) => t.country.equals(country) & t.isHidden.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.votes)])
            ..limit(100))
          .get();
      notifyListeners();
      unawaited(checkHealthForBrowseResults());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> browseByLanguage(String language) async {
    _isLoading = true;
    _browseResults = [];
    notifyListeners();
    
    try {
      await _syncManager.syncByLanguage(language);
      _browseResults = await (_db.select(_db.radioStations)
            ..where((t) => t.language.equals(language) & t.isHidden.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.isAvailable), (t) => OrderingTerm.desc(t.isPinned), (t) => OrderingTerm.desc(t.votes)])
            ..limit(100))
          .get();
      notifyListeners();
      unawaited(checkHealthForBrowseResults());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _searchResults = [];
    notifyListeners();
    
    try {
      await _syncManager.performSearch(query);
      _searchResults = await _db.search(query);
      notifyListeners();
      
      // Trigger health checks for search results
      final results = List<RadioStation>.from(_searchResults);
      unawaited(checkHealthForStations(results));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(RadioStation station) async {
    final targetFav = !station.isFavorite;
    _updateStationFavoriteState(station.stationUuid, targetFav);
    try {
      await _db.setFavorite(station.stationUuid, targetFav);
    } catch (e) {
      log('Failed to update favorite in DB: $e');
      _updateStationFavoriteState(station.stationUuid, !targetFav);
    }
  }

  Future<void> togglePin(RadioStation station) async {
    final targetPinned = !station.isPinned;
    _updateStationPinState(station.stationUuid, targetPinned);
    try {
      await _db.setPinned(station.stationUuid, targetPinned);
    } catch (e) {
      log('Failed to update pin in DB: $e');
      _updateStationPinState(station.stationUuid, !targetPinned);
    }
  }

  Future<void> addFavoriteFromResult(RadioStation result) async {
    _updateStationFavoriteState(result.stationUuid, true);
    try {
      await _db.setFavorite(result.stationUuid, true);
    } catch (e) {
      log('Failed to add favorite in DB: $e');
      _updateStationFavoriteState(result.stationUuid, false);
    }
  }

  Future<void> addManualStation(String name, String url) async {
    await _db.upsertStations([RadioStationsCompanion.insert(
      stationUuid: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      url: url,
      isFavorite: const Value(true),
    )]);
  }

  Future<void> removeStation(RadioStation station) async {
    if (station.stationUuid.startsWith('manual_')) {
      _browseResults.removeWhere((s) => s.stationUuid == station.stationUuid);
      _searchResults.removeWhere((s) => s.stationUuid == station.stationUuid);
      notifyListeners();
      try {
        await _db.deleteStation(station.stationUuid);
      } catch (e) {
        log('Failed to delete manual station in DB: $e');
      }
    } else {
      _updateStationFavoriteState(station.stationUuid, false);
      try {
        await _db.setFavorite(station.stationUuid, false);
      } catch (e) {
        log('Failed to remove favorite in DB: $e');
        _updateStationFavoriteState(station.stationUuid, true);
      }
    }
  }

  void _updateStationFavoriteState(String uuid, bool isFavorite) {
    final changed = RadioStationListUpdater.updateFavorite(_browseResults, _searchResults, uuid, isFavorite);
    if (changed) {
      notifyListeners();
    }
  }

  void _updateStationPinState(String uuid, bool isPinned) {
    final changed = RadioStationListUpdater.updatePinned(_browseResults, _searchResults, uuid, isPinned);
    if (changed) {
      notifyListeners();
    }
  }

  void _updateStationHiddenState(String uuid, bool isHidden) {
    final changed = RadioStationListUpdater.updateHidden(_browseResults, _searchResults, uuid, isHidden);
    if (changed) {
      notifyListeners();
    }
  }

  Future<void> playStation(RadioStation station, PlayerViewModel playerVM, {bool isAvailable = true}) async {
    final track = app_db.Track(
      id: 'radio_${station.stationUuid}', 
      path: station.url,
      title: station.name,
      artistId: 'radio_artist',
      folderId: 'radio_folder',
      rating: 0,
      isFavorite: false,
      playCount: 0,
      isAudiobook: false,
      isPlayed: false,
    );
    
    // ANALYTICS & HOMEPAGE: Pass UUID and Homepage in description
    final metadataStr = '${station.stationUuid}|${station.homepage ?? ""}';

    await playerVM.loadTrack(
      track,
      imageUrl: station.favicon,
      description: metadataStr,
      isAvailable: isAvailable,
    );
  }

  Future<void> refresh() async {
    _error = null;
    await _init(force: true);
  }

  Future<void> clearRadioCache() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.clearCache();
      _browseResults = [];
      _searchResults = [];
      await _init(); // Re-trigger initial sync
    } catch (e) {
      _error = 'Failed to clear cache: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
