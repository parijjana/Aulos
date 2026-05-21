import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/radio_database.dart';
import 'package:localaudioplayer/data/library/radio_browser_service.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:drift/drift.dart';

class RadioSyncManager with UniversalLog {
  final RadioBrowserService _api;
  final RadioDatabase _db;
  bool _isSyncing = false;

  RadioSyncManager({
    required RadioBrowserService api,
    required RadioDatabase db,
  }) : _api = api, _db = db;

  bool get isSyncing => _isSyncing;

  Future<void> runInitialSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      log('RADIO: Starting station discovery sync...');

      // 1. Sync Top Tags (Categories)
      final tags = await _api.getTopTags(50);
      final tagCompanions = tags.map((t) => RadioCategoriesCompanion(
        name: Value(t['name'] ?? 'Unknown'),
        stationCount: Value(t['stationcount'] ?? 0),
      )).toList();
      await _db.upsertCategories(tagCompanions);
      log('RADIO: Synced ${tags.length} genres.');

      // 2. Fetch Top 100 Global Stations
      final topStations = await _api.getTopVoted(100);
      await _commitStations(topStations);
      log('RADIO: Synced top 100 global stations.');

      log('RADIO: Discovery sync complete.');
    } catch (e) {
      log('RADIO: Discovery sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncCategory(String tag) async {
    if (_isSyncing) return;
    _isSyncing = true;
    log('RADIO: Syncing category "$tag"...');
    try {
      final stations = await _api.getByTag(tag, 50);
      await _commitStations(stations);
      log('RADIO: Synced ${stations.length} stations for genre "$tag".');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> performSearch(String query) async {
    if (_isSyncing) return;
    _isSyncing = true;
    log('RADIO: Searching for "$query"...');
    try {
      final stations = await _api.searchStations(query);
      // Map RadioStationResult to RadioStation objects for the commit helper
      final domainStations = stations.map((r) => r.toStation()).toList();
      await _commitStations(domainStations);
      log('RADIO: Search complete. Persisted ${stations.length} results.');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _commitStations(List<RadioStation> results) async {
    final companions = results.map<RadioStationsCompanion>((r) {
      return RadioStationsCompanion(
        stationUuid: Value(r.stationUuid),
        name: Value(r.name),
        url: Value(r.url),
        homepage: Value(r.homepage),
        favicon: Value(r.favicon),
        tags: Value(r.tags),
        country: Value(r.country),
        language: Value(r.language),
        votes: Value(r.votes),
        bitrate: Value(r.bitrate),
        codec: Value(r.codec),
        isFavorite: Value(r.isFavorite),
        lastCheck: Value(r.lastCheck),
      );
    }).toList();
    await _db.upsertStations(companions);
  }
}
