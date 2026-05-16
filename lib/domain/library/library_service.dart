import 'dart:typed_data';

abstract class LibraryService {
  Future<List<AudioFile>> scanDirectory(String path);
  Future<List<AudioFile>> discoverTracks();
}

class AudioFile {
  final String path;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final Duration? duration;
  final Uint8List? coverArt;
  final String? coverPath;

  AudioFile({
    required this.path,
    required this.title,
    required this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.duration,
    this.coverArt,
    this.coverPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioFile &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          title == other.title &&
          artist == other.artist;

  @override
  int get hashCode => path.hashCode ^ title.hashCode ^ artist.hashCode;
}
