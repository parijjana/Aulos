import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/library/podcast_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

class RssPodcastService implements PodcastService {
  final AppDatabase _db;
  final http.Client _client;

  @override
  AppDatabase get db => _db;

  RssPodcastService({required AppDatabase db, http.Client? client})
      : _db = db,
        _client = client ?? http.Client();

  @override
  Future<Podcast> subscribeToFeed(String url) async {
    // Check if already subscribed
    final existing = await _db.getPodcastByFeedUrl(url);
    if (existing != null) return existing;

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch RSS feed: ${response.statusCode}');
    }

    final rss = RssFeed.parse(response.body);
    
    final imageUrl = rss.itunes?.image?.href ?? rss.image?.url;
    Uint8List? imageBytes;
    if (imageUrl != null) {
      try {
        final imgRes = await _client.get(Uri.parse(imageUrl));
        if (imgRes.statusCode == 200) {
          imageBytes = imgRes.bodyBytes;
        }
      } catch (e) {
        debugPrint('RssPodcastService: Failed to fetch podcast image: $e');
      }
    }

    final podcastCompanion = PodcastsCompanion.insert(
      feedUrl: url,
      title: rss.title ?? 'Unknown',
      description: Value(rss.description),
      author: Value(rss.itunes?.author ?? rss.dc?.creator),
      imageUrl: Value(imageUrl),
      image: Value(imageBytes),
    );

    final id = await _db.addPodcast(podcastCompanion);
    
    // Fetch initial episodes
    await refreshPodcast(id);
    
    final podcasts = await _db.getAllPodcasts();
    return podcasts.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<Episode>> refreshPodcast(int podcastId) async {
    final podcasts = await _db.getAllPodcasts();
    final podcast = podcasts.firstWhere((p) => p.id == podcastId);
    
    final response = await _client.get(Uri.parse(podcast.feedUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to refresh RSS feed: ${response.statusCode}');
    }

    final rss = RssFeed.parse(response.body);
    final List<EpisodesCompanion> companions = [];

    for (final item in rss.items) {
      if (item.enclosure?.url == null) continue;
      
      companions.add(EpisodesCompanion.insert(
        podcastId: podcastId,
        guid: item.guid ?? item.enclosure!.url!,
        title: item.title ?? 'Untitled Episode',
        description: Value(item.description),
        audioUrl: item.enclosure!.url!,
        pubDate: Value(item.pubDate != null ? DateTime.tryParse(item.pubDate!) : null),
        durationSeconds: Value(item.itunes?.duration?.inSeconds),
      ));
    }

    await _db.addEpisodes(companions);
    return _db.getEpisodesForPodcast(podcastId);
  }

  @override
  Future<List<Podcast>> getSubscribedPodcasts() => _db.getAllPodcasts();

  @override
  Future<List<Episode>> getEpisodes(int podcastId) => _db.getEpisodesForPodcast(podcastId);

  @override
  Future<void> unsubscribe(int podcastId) => _db.deletePodcast(podcastId);

  @override
  Future<void> updateEpisodePlayback(
    int id, {
    int? positionSeconds,
    bool? isPlayed,
    int? downloadState,
    String? localFilePath,
    bool? isPinned,
  }) =>
      _db.updateEpisodePlayback(
        id,
        positionSeconds: positionSeconds,
        isPlayed: isPlayed,
        downloadState: downloadState,
        localFilePath: localFilePath,
        isPinned: isPinned,
      );
}
