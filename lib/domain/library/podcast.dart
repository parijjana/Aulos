import 'dart:typed_data';

class Podcast {
  final String id;
  final String feedUrl;
  final String title;
  final String? description;
  final String? author;
  final String? imageUrl;
  final Uint8List? image;
  final DateTime subscribedAt;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;

  Podcast({
    required this.id,
    required this.feedUrl,
    required this.title,
    this.description,
    this.author,
    this.imageUrl,
    this.image,
    required this.subscribedAt,
    required this.isFavorite,
    required this.playCount,
    this.lastPlayed,
  });
}
