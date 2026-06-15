class Episode {
  final String id;
  final String podcastId;
  final String guid;
  final String title;
  final String? description;
  final String audioUrl;
  final String? localFilePath;
  final int downloadState;
  final DateTime? pubDate;
  final int? durationSeconds;
  final bool isPlayed;
  final bool isPinned;
  final int playbackPositionSeconds;
  final int playCount;
  final DateTime? lastPlayed;

  Episode({
    required this.id,
    required this.podcastId,
    required this.guid,
    required this.title,
    this.description,
    required this.audioUrl,
    this.localFilePath,
    required this.downloadState,
    this.pubDate,
    this.durationSeconds,
    required this.isPlayed,
    required this.isPinned,
    required this.playbackPositionSeconds,
    required this.playCount,
    this.lastPlayed,
  });
}
