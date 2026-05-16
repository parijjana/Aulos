import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rate_limiter.dart';

class MusicBrainzClient {
  static const _baseUrl = 'https://musicbrainz.org/ws/2';
  static const _caaUrl = 'https://coverartarchive.org';
  
  final String userAgent;
  final RateLimiter _limiter;
  final http.Client _client;

  MusicBrainzClient({
    required this.userAgent,
    RateLimiter? limiter,
    http.Client? client,
  }) : _limiter = limiter ?? RateLimiter(cooldown: const Duration(seconds: 1)),
       _client = client ?? http.Client();

  /// Searches for an artist and returns their MusicBrainz ID (MBID).
  Future<String?> findArtistMbid(String name) async {
    final uri = Uri.parse('$_baseUrl/artist?query=artist:${Uri.encodeComponent(name)}&fmt=json');
    
    final response = await _limiter.run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final artists = data['artists'] as List<dynamic>;
      if (artists.isNotEmpty) {
        return artists.first['id'] as String;
      }
    }
    return null;
  }

  /// Searches for a release (album) and returns its MBID.
  Future<String?> findReleaseMbid(String artistName, String albumName) async {
    final query = 'release:${Uri.encodeComponent(albumName)} AND artist:${Uri.encodeComponent(artistName)}';
    final uri = Uri.parse('$_baseUrl/release?query=$query&fmt=json');

    final response = await _limiter.run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final releases = data['releases'] as List<dynamic>;
      if (releases.isNotEmpty) {
        return releases.first['id'] as String;
      }
    }
    return null;
  }

  /// Returns the URL for the front cover of a release MBID.
  Future<String?> getCoverArtUrl(String mbid) async {
    // CAA doesn't have the same strict rate limit as MB, but we still route 
    // through the limiter if we are doing many metadata checks.
    // However, direct 'front' URL is predictable.
    // Let's check if it exists first via metadata.
    final uri = Uri.parse('$_caaUrl/release/$mbid');

    final response = await _limiter.run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = data['images'] as List<dynamic>;
      for (var img in images) {
        if (img['front'] == true) {
          return img['image'] as String;
        }
      }
    }
    return null;
  }

  /// Attempts to find an artist photo URL.
  /// This follows MusicBrainz relationships to find a Wikimedia Commons image.
  Future<String?> getArtistPhotoUrl(String mbid) async {
    final uri = Uri.parse('$_baseUrl/artist/$mbid?inc=url-rels&fmt=json');
    
    final response = await _limiter.run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final relations = data['relations'] as List<dynamic>? ?? [];
      for (var rel in relations) {
        if (rel['type'] == 'image') {
          final url = rel['url']?['resource'] as String?;
          if (url != null) return url;
        }
      }
    }
    return null;
  }
}
