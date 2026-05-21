import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/discovery_database.dart';
import 'package:localaudioplayer/data/library/podcast_discovery_service.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:drift/drift.dart';
import 'package:dart_rss/dart_rss.dart';

class DiscoverySyncManager extends ChangeNotifier with UniversalLog {
  final PodcastDiscoveryService _api;
  final DiscoveryDatabase _db;
  
  bool _isSyncing = false;
  bool _isActiveSyncEnabled = false;
  
  final _syncCooldown = const Duration(hours: 6);

  DiscoverySyncManager({
    required PodcastDiscoveryService api,
    required DiscoveryDatabase db,
  }) : _api = api, _db = db;

  bool get isSyncing => _isSyncing;

  Future<void> triggerInitialSync() async {
    if (_isSyncing) return;

    final lastRun = await _db.getLastSuccessfulRun();
    if (lastRun != null) {
      final timeSinceLast = DateTime.now().difference(lastRun.lastRun);
      if (timeSinceLast < _syncCooldown) {
        log('DISCOVERY: Cache is fresh (${timeSinceLast.inHours}h old).');
        await _printStats();
        return;
      }
    }

    await runGlobalSync();
  }

  Future<void> clearCache() async {
    log('DISCOVERY: User requested cache reset.');
    await _db.clearAll();
    log('DISCOVERY: Cache cleared. Triggering fresh sync...');
    unawaited(runGlobalSync());
  }

  Future<void> runGlobalSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    int totalFetched = 0;

    try {
      log('DISCOVERY: Starting deep marketplace sync (Top 200 per category)...');
      
      // 1. Fetch Trending
      log('DISCOVERY: Fetching trending podcasts...');
      var trending = await _api.getTrendingPodcasts();
      
      // Optimization: If trending items lack feedUrl, try to fetch them for the top 10
      // so the trending shelf isn't completely empty when first viewed
      for (int i = 0; i < trending.length && i < 10; i++) {
        if (trending[i].feedUrl.isEmpty && trending[i].itunesId != null) {
          final url = await _api.lookupFeedUrl(trending[i].itunesId!);
          if (url != null) {
            trending[i] = PodcastSearchResult(
              title: trending[i].title,
              artist: trending[i].artist,
              feedUrl: url,
              imageUrl: trending[i].imageUrl,
              itunesId: trending[i].itunesId,
              description: trending[i].description,
            );
          }
        }
      }
      
      await _db.upsertPodcasts(_mapToCompanions(trending), 'trending');
      totalFetched += trending.length;

      // 2. Fetch Expanded Category List (12 major genres)
      final categories = [
        '1318', '1311', '1321', '1303', '1315', '1488', '1324', '1310',
        '1301', '1304', '1309', '1307',
      ];

      for (var catId in categories) {
        final results = await _api.getPodcastsByCategory(catId, limit: 200);
        await _db.upsertPodcasts(_mapToCompanions(results), catId);
        totalFetched += results.length;
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await _db.logRun(DateTime.now(), totalFetched, 'success');
      log('DISCOVERY: Marketplace sync complete. Indexed $totalFetched global podcasts.');
      await _printStats();
    } catch (e) {
      log('DISCOVERY: Global sync failed: $e');
      await _db.logRun(DateTime.now(), totalFetched, 'failed');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> proactiveSync(String categoryId, int currentCount) async {
    if (_isSyncing) return;
    
    log('DISCOVERY: Expanding category $categoryId (offset: $currentCount)');
    _isSyncing = true;
    notifyListeners();
    try {
      final results = await _api.getPodcastsByCategory(categoryId, limit: 50, offset: currentCount);
      await _db.upsertPodcasts(_mapToCompanions(results), categoryId);
      log('DISCOVERY: Fetched ${results.length} more podcasts for category $categoryId.');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> performSearch(String query) async {
    if (_isSyncing || query.isEmpty) return;
    
    log('DISCOVERY: Searching for "$query"...');
    _isSyncing = true;
    notifyListeners();
    try {
      final results = await _api.searchPodcasts(query, limit: 50);
      await _db.upsertPodcasts(_mapToCompanions(results), 'search:$query');
      log('DISCOVERY: Persisted ${results.length} search results for "$query".');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncPodcastDetails(String iTunesId, String? feedUrl) async {
    if (_isSyncing) return;
    
    log('DISCOVERY: Syncing details for podcast $iTunesId...');
    _isSyncing = true;
    notifyListeners();
    try {
      String? resolvedUrl = feedUrl;
      
      // 1. Proactive Lookup if feedUrl is missing (common for Trending items)
      if (resolvedUrl == null || resolvedUrl.isEmpty) {
        log('DISCOVERY: Feed URL missing for $iTunesId, performing lookup...');
        resolvedUrl = await _api.lookupFeedUrl(iTunesId);
      }

      if (resolvedUrl == null || resolvedUrl.isEmpty) {
        log('DISCOVERY: Could not resolve feed URL for $iTunesId. Sync aborted.');
        return;
      }

      final xml = await _api.fetchRawRss(resolvedUrl);
      if (xml == null) return;

      final rss = RssFeed.parse(xml);
      
      // 2. Update Podcast with description and resolved feedUrl
      final podcast = await _db.getByITunesId(iTunesId);
      if (podcast != null) {
        await _db.update(_db.discoveredPodcasts).replace(
          DiscoveredPodcastsCompanion(
            id: Value(podcast.id),
            iTunesId: Value(iTunesId),
            title: Value(podcast.title),
            artist: Value(podcast.artist),
            feedUrl: Value(resolvedUrl),
            imageUrl: Value(podcast.imageUrl),
            description: Value(rss.description),
          )
        );
      }

      // 3. Sync Top 5 Episodes
      final episodes = rss.items.take(5).map((item) => DiscoveredEpisodesCompanion.insert(
        iTunesId: iTunesId,
        title: item.title ?? 'Untitled Episode',
        audioUrl: item.enclosure?.url ?? '',
        pubDate: Value(item.pubDate != null ? DateTime.tryParse(item.pubDate!) : null),
      )).toList();

      await _db.upsertEpisodes(episodes);
      log('DISCOVERY: Persisted details and ${episodes.length} episodes for $iTunesId.');
    } catch (e) {
      log('DISCOVERY: Detail sync failed: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  List<DiscoveredPodcastsCompanion> _mapToCompanions(List<PodcastSearchResult> results) {
    return results.map<DiscoveredPodcastsCompanion>((r) => DiscoveredPodcastsCompanion.insert(
      iTunesId: r.itunesId ?? r.feedUrl, 
      title: r.title,
      artist: r.artist,
      feedUrl: r.feedUrl,
      imageUrl: Value(r.imageUrl),
      description: Value(r.description),
    )).toList();
  }

  Future<void> _printStats() async {
    try {
      final all = await _db.select(_db.discoveredPodcasts).get();
      final rels = await _db.select(_db.discoveryCategoryRelations).get();
      
      final Map<String, int> counts = {};
      for (var r in rels) {
        counts[r.categoryId] = (counts[r.categoryId] ?? 0) + 1;
      }
      
      String stats = 'DISCOVERY STATS: UniquePodcasts=${all.length} | Links=${rels.length} | ';
      counts.forEach((k, v) => stats += '$k:$v ');
      log(stats);
    } catch (e) {
      log('DISCOVERY: Failed to print stats: $e');
    }
  }

  void enableActiveSync() => _isActiveSyncEnabled = true;
  void disableActiveSync() => _isActiveSyncEnabled = false;
}
