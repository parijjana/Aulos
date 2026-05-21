import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localaudioplayer/core/network/rate_limit_dispatcher.dart';
import 'package:localaudioplayer/data/database/radio_database.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:flutter/foundation.dart';

class RadioStationResult {
  final String stationuuid;
  final String name;
  final String url;
  final String? favicon;
  final String? tags;
  final String? country;
  final int votes;
  final int bitrate;
  final String? codec;

  RadioStationResult({
    required this.stationuuid,
    required this.name,
    required this.url,
    this.favicon,
    this.tags,
    this.country,
    required this.votes,
    required this.bitrate,
    this.codec,
  });

  RadioStation toStation() {
    return RadioStation(
      id: 0,
      stationUuid: stationuuid,
      name: name,
      url: url,
      favicon: favicon,
      tags: tags,
      country: country,
      votes: votes,
      bitrate: bitrate,
      codec: codec,
      isFavorite: false,
    );
  }

  factory RadioStationResult.fromJson(Map<String, dynamic> json) {
    return RadioStationResult(
      stationuuid: json['stationuuid'] ?? '',
      name: json['name'] ?? 'Unknown Station',
      url: json['url_resolved'] ?? json['url'] ?? '',
      favicon: json['favicon'],
      tags: json['tags'],
      country: json['country'],
      votes: json['votes'] ?? 0,
      bitrate: json['bitrate'] ?? 0,
      codec: json['codec'],
    );
  }
}

class RadioBrowserService with UniversalLog {
  final http.Client _client;
  final RateLimitDispatcher _rateLimiter;
  
  // Use a reliable default mirror (German mirror is usually very stable)
  String _baseUrl = 'https://de1.api.radio-browser.info/json';

  RadioBrowserService({
    http.Client? client,
    RateLimitDispatcher? rateLimiter,
  }) : _client = client ?? http.Client(),
       _rateLimiter = rateLimiter ?? RateLimitDispatcher() {
    _resolveHost();
  }

  @visibleForTesting
  Future<void> resolveHost() => _resolveHost();

  Future<void> _resolveHost() async {
    try {
      // Use DNS lookup or a known reliable mirror
      final response = await http.get(Uri.parse('https://all.api.radio-browser.info/json/servers'));
      if (response.statusCode == 200) {
        final List servers = json.decode(response.body);
        if (servers.isNotEmpty) {
          final best = servers.first['name'];
          _baseUrl = 'https://$best/json';
          log('RADIO: Resolved API host to $best');
        }
      }
    } catch (e) {
      log('RADIO: Failed to resolve host, using default pool.');
    }
  }

  Future<List<RadioStationResult>> searchStations(String query) async {
    final url = '$_baseUrl/stations/byname/${Uri.encodeComponent(query)}';
    return _dispatch(url);
  }

  Future<List<RadioStation>> getTopVoted(int limit) async {
    final url = '$_baseUrl/stations/topvote/$limit';
    final results = await _dispatch(url);
    return results.map((r) => r.toStation()).toList();
  }

  Future<List<RadioStation>> getByTag(String tag, int limit) async {
    final url = '$_baseUrl/stations/bytag/${Uri.encodeComponent(tag)}?limit=$limit&order=votes&reverse=true';
    final results = await _dispatch(url);
    return results.map((r) => r.toStation()).toList();
  }

  Future<List<Map<String, dynamic>>> getTopTags(int limit) async {
    final url = '$_baseUrl/tags?limit=$limit&order=stationcount&reverse=true';
    return _rateLimiter.dispatch(
      apiId: 'radio-browser',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final List data = json.decode(response.body);
            return data.cast<Map<String, dynamic>>();
          }
        } catch (e) {
          debugPrint('RadioBrowserService: Tag fetch failed: $e');
        }
        return [];
      },
    );
  }

  Future<List<RadioStationResult>> _dispatch(String url) async {
    return _rateLimiter.dispatch(
      apiId: 'radio-browser',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final List data = json.decode(response.body);
            return data.map((j) => RadioStationResult.fromJson(j)).toList();
          }
        } catch (e) {
          debugPrint('RadioBrowserService: Request failed ($url): $e');
        }
        return <RadioStationResult>[];
      },
    );
  }
}
