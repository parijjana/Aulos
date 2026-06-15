import 'package:aulos/domain/library/podcast.dart';
import 'package:aulos/domain/library/episode.dart';
import 'package:aulos/domain/library/bookmark.dart';

abstract class PodcastService {
  Future<Podcast> subscribeToFeed(String url);
  Future<List<Episode>> refreshPodcast(String podcastId);
  Future<List<Podcast>> getSubscribedPodcasts();
  Future<List<Episode>> getEpisodes(String podcastId);
  Future<void> unsubscribe(String podcastId);
  Future<void> updateEpisodePlayback(
    String id, {
    int? positionSeconds,
    bool? isPlayed,
    int? downloadState,
    String? localFilePath,
    bool? isPinned,
  });

  // Database access wrappers to prevent raw client leakage
  Future<List<Bookmark>> getBookmarksForTrack(String path);
  Future<void> deleteBookmarksForTrack(String path);
  Future<void> updateBookmarkPaths(String oldPath, String newPath);
  Future<void> deletePlaybackPosition(String episodeId);
  Future<int> getPlaybackPosition(String episodeId);
}
