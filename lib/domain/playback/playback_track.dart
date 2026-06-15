import 'dart:typed_data';

class PlaybackTrack {
  final String id;
  final String path;
  final String title;
  final String? artistId;
  final String? albumId;
  final String? genreId;
  final int? year;
  final Duration? duration;
  final String folderId;
  final int rating;
  final Uint8List? coverArt;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;
  final bool isAudiobook;
  final bool isPlayed;
  final bool? isStream;

  PlaybackTrack({
    required this.id,
    required this.path,
    required this.title,
    this.artistId,
    this.albumId,
    this.genreId,
    this.year,
    this.duration,
    required this.folderId,
    required this.rating,
    this.coverArt,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
    required this.isAudiobook,
    required this.isPlayed,
    this.isStream,
  });

  PlaybackTrack copyWith({
    String? id,
    String? path,
    String? title,
    String? artistId,
    String? albumId,
    String? genreId,
    int? year,
    Duration? duration,
    String? folderId,
    int? rating,
    Uint8List? coverArt,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayed,
    bool? isAudiobook,
    bool? isPlayed,
    bool? isStream,
  }) {
    return PlaybackTrack(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      albumId: albumId ?? this.albumId,
      genreId: genreId ?? this.genreId,
      year: year ?? this.year,
      duration: duration ?? this.duration,
      folderId: folderId ?? this.folderId,
      rating: rating ?? this.rating,
      coverArt: coverArt ?? this.coverArt,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      isAudiobook: isAudiobook ?? this.isAudiobook,
      isPlayed: isPlayed ?? this.isPlayed,
      isStream: isStream ?? this.isStream,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackTrack &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ path.hashCode ^ title.hashCode;
}
