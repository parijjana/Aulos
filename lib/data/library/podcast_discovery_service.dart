import 'dart:convert';
import 'package:http/http.dart' as http;

class PodcastSearchResult {
  final String title;
  final String artist;
  final String feedUrl;
  final String? imageUrl;
  final String? description;

  PodcastSearchResult({
    required this.title,
    required this.artist,
    required this.feedUrl,
    this.imageUrl,
    this.description,
  });

  factory PodcastSearchResult.fromJson(Map<String, dynamic> json) {
    return PodcastSearchResult(
      title: json['collectionName'] ?? 'Unknown Podcast',
      artist: json['artistName'] ?? 'Unknown Artist',
      feedUrl: json['feedUrl'] ?? '',
      imageUrl: json['artworkUrl600'] ?? json['artworkUrl100'],
    );
  }
}

class PodcastDiscoveryService {
  final http.Client _client;

  PodcastDiscoveryService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PodcastSearchResult>> searchPodcasts(String query) async {
    if (query.isEmpty) return [];

    final url = 'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=podcast&limit=25';
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results
            .map((json) => PodcastSearchResult.fromJson(json))
            .where((r) => r.feedUrl.isNotEmpty)
            .toList();
      }
    } catch (e) {
      print('PodcastDiscoveryService: Search failed: $e');
    }
    return [];
  }

  Future<List<PodcastSearchResult>> getTopPodcasts() async {
    // iTunes RSS generator for top podcasts
    const url = 'https://itunes.apple.com/search?term=podcast&entity=podcast&limit=15';
    return searchPodcasts('podcast'); // Fallback to a general search for now
  }
}
