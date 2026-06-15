import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/data/database/podcast_database_extensions.dart';
import 'package:aulos/data/database/playback_database_extensions.dart';
import 'package:aulos/domain/library/podcast_service.dart';
import 'package:aulos/domain/library/podcast.dart' as dom_podcast;
import 'package:aulos/domain/library/episode.dart' as dom_episode;
import 'package:aulos/domain/library/bookmark.dart' as dom_bookmark;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:aulos/core/utils/date_parser.dart';

import 'package:aulos/core/utils/id_generator.dart';

// Top-level function for compute()
RssFeed _parseRss(String body) => RssFeed.parse(body);

class RssPodcastService implements PodcastService {
  final PodcastDatabase _db;
  final PlaybackDatabase _playbackDb;
  final http.Client _client;

  RssPodcastService({
    required PodcastDatabase db,
    required PlaybackDatabase playbackDb,
    http.Client? client,
  })  : _db = db,
        _playbackDb = playbackDb,
        _client = client ?? http.Client();

  @override
  Future<dom_podcast.Podcast> subscribeToFeed(String url) async {
    // Check if already subscribed
    final existing = await _db.getPodcastByFeedUrl(url);
    if (existing != null) return existing.toDomain();

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch RSS feed: ${response.statusCode}');
    }

    final rss = await compute(_parseRss, response.body);
    
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

    final podcastId = generateContentId(url);
    final podcastCompanion = PodcastsCompanion.insert(
      id: podcastId,
      feedUrl: url,
      title: rss.title ?? 'Unknown',
      description: Value(rss.description),
      author: Value(rss.itunes?.author ?? rss.dc?.creator),
      imageUrl: Value(imageUrl),
      image: Value(imageBytes),
    );

    await _db.addPodcast(podcastCompanion);
    
    // Fetch initial episodes
    await refreshPodcast(podcastId);
    
    final podcasts = await _db.getAllPodcasts();
    return podcasts.firstWhere((p) => p.id == podcastId).toDomain();
  }

  @override
  Future<List<dom_episode.Episode>> refreshPodcast(String podcastId) async {
    final podcasts = await _db.getAllPodcasts();
    final podcast = podcasts.firstWhere((p) => p.id == podcastId);
    
    final response = await _client.get(Uri.parse(podcast.feedUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to refresh RSS feed: ${response.statusCode}');
    }

    final rss = await compute(_parseRss, response.body);
    final List<EpisodesCompanion> companions = [];

    for (final item in rss.items) {
      final audioUrl = item.enclosure?.url;
      if (audioUrl == null) continue;
      
      final pubDateStr = item.pubDate;
      final guid = item.guid ?? audioUrl;
      final episodeId = generateContentId("$podcastId|$guid");

      companions.add(EpisodesCompanion.insert(
        id: episodeId,
        podcastId: podcastId,
        guid: guid,
        title: item.title ?? 'Untitled Episode',
        description: Value(item.description),
        audioUrl: audioUrl,
        pubDate: Value(parseRfc822(pubDateStr)),
        durationSeconds: Value(item.itunes?.duration?.inSeconds),
      ));
    }

    await _db.addEpisodes(companions);
    final list = await _db.getEpisodesForPodcast(podcastId);
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<dom_podcast.Podcast>> getSubscribedPodcasts() async {
    final list = await _db.getAllPodcasts();
    return list.map((p) => p.toDomain()).toList();
  }

  @override
  Future<List<dom_episode.Episode>> getEpisodes(String podcastId) async {
    final list = await _db.getEpisodesForPodcast(podcastId);
    return list.map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> unsubscribe(String podcastId) => _db.deletePodcast(podcastId);

  @override
  Future<void> updateEpisodePlayback(
    String id, {
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

  @override
  Future<List<dom_bookmark.Bookmark>> getBookmarksForTrack(String path) async {
    final list = await _playbackDb.getBookmarksForTrack(path);
    return list.map((b) => b.toDomain()).toList();
  }

  @override
  Future<void> deleteBookmarksForTrack(String path) => _playbackDb.deleteBookmarksForTrack(path);

  @override
  Future<void> updateBookmarkPaths(String oldPath, String newPath) => _playbackDb.updateBookmarkPaths(oldPath, newPath);

  @override
  Future<void> deletePlaybackPosition(String episodeId) => _playbackDb.deletePlaybackPosition(episodeId);

  @override
  Future<int> getPlaybackPosition(String episodeId) async {
    final pos = await _playbackDb.getPlaybackPosition(episodeId);
    return pos?.positionMs ?? 0;
  }
}
