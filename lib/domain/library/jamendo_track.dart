import 'package:aulos/core/network/json_types.dart';

class JamendoTrack {
  final String id;
  final String title;
  final String artistName;
  final String albumName;
  final int durationSeconds;
  final String audioUrl;
  final String downloadUrl;
  final String imageUrl;

  JamendoTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumName,
    required this.durationSeconds,
    required this.audioUrl,
    required this.downloadUrl,
    required this.imageUrl,
  });

  String get durationString {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory JamendoTrack.fromJson(JsonMap json) {
    return JamendoTrack(
      id: (json['id']?.toString() ?? '') as String,
      title: (json['name']?.toString() ?? 'Unknown Track') as String,
      artistName: (json['artist_name']?.toString() ?? 'Unknown Artist') as String,
      albumName: (json['album_name']?.toString() ?? 'Unknown Album') as String,
      durationSeconds: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      audioUrl: (json['audio']?.toString() ?? '') as String,
      downloadUrl: (json['audiodownload']?.toString() ?? '') as String,
      imageUrl: (json['image']?.toString() ?? json['album_image']?.toString() ?? '') as String,
    );
  }
}
