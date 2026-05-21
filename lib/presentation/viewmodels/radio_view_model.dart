import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/radio_database.dart';
import 'package:localaudioplayer/data/library/radio_browser_service.dart';
import 'package:localaudioplayer/data/library/radio_sync_manager.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/data/database/app_database.dart' as app_db;
import 'package:drift/drift.dart';
import 'dart:async';

class RadioViewModel extends ChangeNotifier {
  final RadioBrowserService _api;
  final RadioDatabase _db;
  final RadioSyncManager _syncManager;

  List<RadioStation> _favorites = [];
  List<RadioCategory> _categories = [];
  List<RadioStation> _browseResults = [];
  List<RadioStation> _searchResults = [];

  StreamSubscription? _browseSub;
  StreamSubscription? _searchSub;
  StreamSubscription? _favSub;
  StreamSubscription? _catSub;

  bool _isLoading = false;
  String? _error;

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
    super.dispose();
  }

  List<RadioStation> get favorites => _favorites;
  List<RadioCategory> get categories => _categories;
  List<RadioStation> get browseResults => _browseResults;
  List<RadioStation> get searchResults => _searchResults;
  bool get isLoading => _isLoading || _syncManager.isSyncing;
  String? get error => _error;

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // 1. Setup Reactive Subscriptions for everything
    _favSub?.cancel();
    _favSub = _db.select(_db.radioStations).watch().listen((stations) {
      _favorites = stations.where((s) => s.isFavorite).toList();
      notifyListeners();
    });

    _catSub?.cancel();
    _catSub = _db.select(_db.radioCategories).watch().listen((cats) {
      _categories = cats;
      notifyListeners();
    });

    _browseSub?.cancel();
    _browseSub = _db.watchTopStations(limit: 30).listen((stations) {
      _browseResults = stations;
      notifyListeners();
    });

    try {
      // 2. Trigger Initial Sync in background (SyncManager handles DB persistence)
      unawaited(_syncManager.runInitialSync());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> browseCategory(String tag) async {
    _isLoading = true;
    notifyListeners();
    
    _browseSub?.cancel();
    _browseSub = _db.watchByCategory(tag, limit: 50).listen((stations) {
      _browseResults = stations;
      notifyListeners();
    });

    try {
      // Trigger background sync for this category
      await _syncManager.syncCategory(tag);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _searchSub?.cancel();
    _searchSub = _db.watchSearch(query).listen((stations) {
      _searchResults = stations;
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

  Future<void> toggleFavorite(RadioStation station) async {
    await _db.setFavorite(station.stationUuid, !station.isFavorite);
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
    );
    
    await playerVM.loadTrack(
      track,
      imageUrl: station.favicon,
    );
  }

  Future<void> refresh() async {
    _error = null;
    await _init();
  }
}
