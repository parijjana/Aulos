import 'package:localaudioplayer/data/database/app_database.dart';

abstract class PodcastService {
  Future<Podcast> subscribeToFeed(String url);
  Future<List<Episode>> refreshPodcast(int podcastId);
  Future<List<Podcast>> getSubscribedPodcasts();
  Future<List<Episode>> getEpisodes(int podcastId);
  Future<void> unsubscribe(int podcastId);
  Future<void> updateEpisodePlayback(
    int id, {
    int? positionSeconds,
    bool? isPlayed,
    int? downloadState,
    String? localFilePath,
    bool? isPinned,
  });
}
