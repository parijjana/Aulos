import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'src/musicbrainz_client.dart';
import 'src/media_cache.dart';
import 'src/rate_limiter.dart';

export 'src/rate_limiter.dart';
export 'src/media_cache.dart';

class MediaFetcher {
  final MusicBrainzClient _client;
  final MediaCache? _cache;
  final http.Client _httpClient;

  MediaFetcher({
    required String userAgent,
    MediaCache? cache,
    http.Client? httpClient,
    Future<T> Function<T>(Future<T> Function() call)? universalDispatcher,
    void Function(String message)? onLog,
  }) : _httpClient = httpClient ?? http.Client(),
       _cache = cache,
       _client = MusicBrainzClient(
         userAgent: userAgent,
         client: httpClient,
         universalDispatcher: universalDispatcher,
         onLog: onLog,
       );

  Future<Uint8List?> getAlbumArt(String artist, String album) async {
    // 1. Check Cache
    final cacheKey = 'art_${artist}_$album'.replaceAll(' ', '_').toLowerCase();
    if (_cache != null) {
      final cached = await _cache!.get(cacheKey);
      if (cached != null) return cached;
    }

    // 2. Find Release MBID
    final mbid = await _client.findReleaseMbid(artist, album);
    if (mbid == null) return null;

    // 3. Get Image URL
    final url = await _client.getCoverArtUrl(mbid);
    if (url == null) return null;

    // 4. Download
    final bytes = await _download(url);
    
    // 5. Store in Cache
    if (bytes != null && _cache != null) {
      await _cache!.put(cacheKey, bytes);
    }

    return bytes;
  }

  Future<Uint8List?> getArtistPhoto(String artist) async {
    // 1. Check Cache
    final cacheKey = 'artist_$artist'.replaceAll(' ', '_').toLowerCase();
    if (_cache != null) {
      final cached = await _cache!.get(cacheKey);
      if (cached != null) return cached;
    }

    // 2. Find Artist MBID
    final mbid = await _client.findArtistMbid(artist);
    if (mbid == null) return null;

    // 3. Get Image URL
    final url = await _client.getArtistPhotoUrl(mbid);
    if (url == null) return null;

    // 4. Download
    final bytes = await _download(url);

    // 5. Store in Cache
    if (bytes != null && _cache != null) {
      await _cache!.put(cacheKey, bytes);
    }

    return bytes;
  }

  Future<Uint8List?> _download(String url) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      // Log or handle error
    }
    return null;
  }
}
