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

class RadioViewModel extends ChangeNotifier with UniversalLog {
  final RadioBrowserService _api;
  final RadioDatabase _db;
  final RadioSyncManager _syncManager;
  final http.Client _httpClient = http.Client();

  List<RadioStation> _favorites = [];
  List<RadioCategory> _categories = [];
  List<RadioStation> _browseResults = [];
  List<RadioStation> _searchResults = [];
  List<Map<String, dynamic>> _allCountries = [];
  List<Map<String, dynamic>> _allLanguages = [];

  StreamSubscription? _browseSub;
  StreamSubscription? _searchSub;
  StreamSubscription? _favSub;
  StreamSubscription? _catSub;

  bool _isLoading = false;
  String? _error;
  bool _isShowingHidden = false;
  int _nextUnavailableCheckIndex = 0;

  RadioViewModel({
    required RadioBrowserService api,
    required RadioDatabase db,
    required RadioSyncManager syncManager,
  }) : _api = api, _db = db, _syncManager = syncManager {
    _init();
  }

  @override
  void dispose() {
    _browseSub?.cancel();
    _searchSub?.cancel();
    _favSub?.cancel();
    _catSub?.cancel();
    _httpClient.close();
    super.dispose();
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

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _setupSubscriptions();

    try {
      unawaited(_syncManager.runInitialSync());
      _allCountries = await _api.getAllCountries();
      _allLanguages = await _api.getAllLanguages();
      
      // Load initial discovery view
      await loadDiscoveryHome();
      
      // HEALTH CHECK: Run health checks for library stations at startup
      unawaited(_performHealthChecks());
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
    // REMOVED: _browseSub here was overwriting specific results with generic 'Top Stations'
  }

  Future<void> loadDiscoveryHome() async {
    _browseResults = await _db.getTopStations(limit: 30);
    notifyListeners();
    unawaited(checkHealthForBrowseResults());
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
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _updateInMemoryStation(String uuid, bool available) {
    final now = DateTime.now();
    
    final bIndex = _browseResults.indexWhere((s) => s.stationUuid == uuid);
    if (bIndex != -1) {
      _browseResults[bIndex] = _browseResults[bIndex].copyWith(
        isAvailable: available,
        lastCheck: Value(now),
      );
    }
    
    final sIndex = _searchResults.indexWhere((s) => s.stationUuid == uuid);
    if (sIndex != -1) {
      _searchResults[sIndex] = _searchResults[sIndex].copyWith(
        isAvailable: available,
        lastCheck: Value(now),
      );
    }
  }

  Future<void> toggleHidden(RadioStation station) async {
    await _db.setHidden(station.stationUuid, !station.isHidden);
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
    await _db.setFavorite(station.stationUuid, !station.isFavorite);
  }

  Future<void> togglePin(RadioStation station) async {
    await _db.setPinned(station.stationUuid, !station.isPinned);
  }

  Future<void> addFavoriteFromResult(RadioStation result) async {
     await _db.setFavorite(result.stationUuid, true);
  }

  Future<void> addManualStation(String name, String url) async {
    await _db.upsertStations([RadioStationsCompanion.insert(
      stationUuid: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      url: url,
      isFavorite: const Value(true),
    )]);
  }

  Future<void> playStation(RadioStation station, PlayerViewModel playerVM) async {
    final track = app_db.Track(
      id: 0, 
      path: station.url,
      title: station.name,
      artistId: 0,
      folderId: 0,
      rating: 0,
      isFavorite: false,
      playCount: 0,
    );
    
    // ANALYTICS & HOMEPAGE: Pass UUID and Homepage in description
    final metadataStr = '${station.stationUuid}|${station.homepage ?? ""}';

    await playerVM.loadTrack(
      track,
      imageUrl: station.favicon,
      description: metadataStr,
    );
  }

  Future<void> refresh() async {
    _error = null;
    await _init();
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
