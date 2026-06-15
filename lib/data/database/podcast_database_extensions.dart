import 'package:aulos/domain/library/podcast.dart' as dom_podcast;
import 'package:aulos/domain/library/episode.dart' as dom_episode;
import 'podcast_database.dart';

extension PodcastToDomain on Podcast {
  dom_podcast.Podcast toDomain() {
    return dom_podcast.Podcast(
      id: id,
      feedUrl: feedUrl,
      title: title,
      description: description,
      author: author,
      imageUrl: imageUrl,
      image: image,
      subscribedAt: subscribedAt,
      isFavorite: isFavorite,
      playCount: playCount,
      lastPlayed: lastPlayed,
    );
  }
}

extension EpisodeToDomain on Episode {
  dom_episode.Episode toDomain() {
    return dom_episode.Episode(
      id: id,
      podcastId: podcastId,
      guid: guid,
      title: title,
      description: description,
      audioUrl: audioUrl,
      localFilePath: localFilePath,
      downloadState: downloadState,
      pubDate: pubDate,
      durationSeconds: durationSeconds,
      isPlayed: isPlayed,
      isPinned: isPinned,
      playbackPositionSeconds: playbackPositionSeconds,
      playCount: playCount,
      lastPlayed: lastPlayed,
    );
  }
}
