import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'src/musicbrainz_client.dart';
import 'src/media_cache.dart';
import 'src/rate_limiter.dart';

export 'src/rate_limiter.dart';
export 'src/media_cache.dart';
export 'src/musicbrainz_client.dart';

class MediaFetcher {
  final MusicBrainzClient _client;
  final MediaCache? _cache;
  final http.Client _httpClient;

  MediaFetcher({
    required String userAgent,
    MediaCache? cache,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client(),
       _cache = cache,
       _client = MusicBrainzClient(
         userAgent: userAgent,
         client: httpClient,
       );

  /// Fetches album art for the given artist and album.
  /// Returns the image bytes or null if not found.
  Future<Uint8List?> getAlbumArt(String artist, String album) async {
    final cacheKey = 'album_art:$artist:$album';
    if (_cache != null) {
      final cached = await _cache.get(cacheKey);
      if (cached != null) return cached;
    }

    final mbid = await _client.findReleaseMbid(artist, album);
    if (mbid == null) return null;

    final url = await _client.getCoverArtUrl(mbid);
    if (url == null) return null;

    final bytes = await _downloadImage(url);
    if (bytes != null) {
      await _cache?.put(cacheKey, bytes);
    }
    return bytes;
  }

  /// Fetches an artist photo.
  /// Returns the image bytes or null if not found.
  Future<Uint8List?> getArtistPhoto(String artist) async {
    final cacheKey = 'artist_photo:$artist';
    if (_cache != null) {
      final cached = await _cache.get(cacheKey);
      if (cached != null) return cached;
    }

    final mbid = await _client.findArtistMbid(artist);
    if (mbid == null) return null;

    final url = await _client.getArtistPhotoUrl(mbid);
    if (url == null) return null;

    final bytes = await _downloadImage(url);
    if (bytes != null) {
      await _cache?.put(cacheKey, bytes);
    }
    return bytes;
  }

  Future<Uint8List?> _downloadImage(String url) async {
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
