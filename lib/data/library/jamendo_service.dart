import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/core/network/json_types.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/domain/library/jamendo_track.dart';

class JamendoService {
  final http.Client _client;
  final RateLimitDispatcher _rateLimiter;
  final LogService _logService;

  static const String _baseUrl = 'https://api.jamendo.com/v3.0/tracks/';
  // Using public Jamendo client ID from VLC Media Player source code
  static const String _clientId = '3dce8b55'; 

  JamendoService({
    LogService? logService,
    http.Client? client,
    RateLimitDispatcher? rateLimiter,
  }) : _client = client ?? http.Client(),
       _rateLimiter = rateLimiter ?? RateLimitDispatcher(),
       _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  Future<List<JamendoTrack>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final term = query.trim();
    String url = '$_baseUrl?client_id=$_clientId&format=json&limit=$limit&offset=$offset&audioformat=mp32';
    
    if (term.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(term)}';
    } else {
      // If no query, fetch popular/trending tracks by order of downloads
      url += '&order=downloads_desc';
    }

    log('JAMENDO: Searching tracks with query "$term" (offset: $offset)');

    return _rateLimiter.dispatch<List<JamendoTrack>>(
      apiId: 'jamendo',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final results = data['results'] as List? ?? [];
            final List<JamendoTrack> tracks = [];

            for (var item in results) {
              if (item is JsonMap) {
                tracks.add(JamendoTrack.fromJson(item));
              }
            }
            log('JAMENDO: Found ${tracks.length} tracks.');
            return tracks;
          } else {
            log('JAMENDO: Search failed with status ${response.statusCode}');
            throw Exception('Search failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('JAMENDO: Search error: $e');
          rethrow;
        }
      },
    );
  }
}
