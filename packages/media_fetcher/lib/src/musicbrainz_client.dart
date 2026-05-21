import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rate_limiter.dart';

class MusicBrainzClient {
  static const _baseUrl = 'https://musicbrainz.org/ws/2';
  static const _caaUrl = 'https://coverartarchive.org';
  
  final String userAgent;
  final RateLimiter? _legacyLimiter;
  final Future<T> Function<T>(Future<T> Function() call)? _universalDispatcher;
  final http.Client _client;
  final void Function(String message)? _onLog;

  MusicBrainzClient({
    required this.userAgent,
    RateLimiter? limiter,
    Future<T> Function<T>(Future<T> Function() call)? universalDispatcher,
    http.Client? client,
    void Function(String message)? onLog,
  }) : _legacyLimiter = limiter ?? (universalDispatcher == null ? RateLimiter(cooldown: const Duration(seconds: 1)) : null),
       _universalDispatcher = universalDispatcher,
       _client = client ?? http.Client(),
       _onLog = onLog;

  void _log(String message) {
    if (_onLog != null) _onLog!(message);
  }

  Future<T> _run<T>(Future<T> Function() task) {
    if (_universalDispatcher != null) {
      return _universalDispatcher!<T>(task);
    }
    return _legacyLimiter!.run(task);
  }

  /// Searches for an artist and returns their MusicBrainz ID (MBID).
  Future<String?> findArtistMbid(String name) async {
    _log('API: Searching MusicBrainz for artist: $name');
    final uri = Uri.parse('$_baseUrl/artist?query=artist:${Uri.encodeComponent(name)}&fmt=json');
    
    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final artists = data['artists'] as List<dynamic>;
      if (artists.isNotEmpty) {
        final id = artists.first['id'] as String;
        _log('API: Found artist MBID: $id');
        return id;
      }
    }
    _log('API: No MusicBrainz ID found for artist: $name');
    return null;
  }

  /// Searches for a release (album) and returns its MBID.
  Future<String?> findReleaseMbid(String artistName, String albumName) async {
    _log('API: Searching MusicBrainz for album: "$albumName" by "$artistName"');
    final query = 'release:${Uri.encodeComponent(albumName)} AND artist:${Uri.encodeComponent(artistName)}';
    final uri = Uri.parse('$_baseUrl/release?query=$query&fmt=json');

    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final releases = data['releases'] as List<dynamic>;
      if (releases.isNotEmpty) {
        final id = releases.first['id'] as String;
        _log('API: Found release MBID: $id');
        return id;
      }
    }
    _log('API: No release MBID found for: $albumName');
    return null;
  }

  /// Returns the URL for the front cover of a release MBID.
  Future<String?> getCoverArtUrl(String mbid) async {
    _log('API: Checking CoverArtArchive for MBID: $mbid');
    final uri = Uri.parse('$_caaUrl/release/$mbid');

    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = data['images'] as List<dynamic>;
      for (var img in images) {
        if (img['front'] == true) {
          final url = img['image'] as String;
          _log('API: Found cover art URL: $url');
          return url;
        }
      }
    }
    _log('API: No cover art found for MBID: $mbid');
    return null;
  }

  /// Attempts to find an artist photo URL.
  Future<String?> getArtistPhotoUrl(String mbid) async {
    _log('API: Checking artist photo for MBID: $mbid');
    final uri = Uri.parse('$_baseUrl/artist/$mbid?inc=url-rels&fmt=json');
    
    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final relations = data['relations'] as List<dynamic>? ?? [];
      for (var rel in relations) {
        if (rel['type'] == 'image') {
          final url = rel['url']?['resource'] as String?;
          if (url != null) {
            _log('API: Found artist photo URL: $url');
            return url;
          }
        }
      }
    }
    return null;
  }
}
