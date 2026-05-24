import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/domain/network/log_service.dart';
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
      isPinned: false,
      isHidden: false,
      isAvailable: true,
    );
  }

  factory RadioStationResult.fromJson(Map<String, dynamic> json) {
    return RadioStationResult(
      stationuuid: (json['stationuuid']?.toString() ?? '') as String,
      name: (json['name']?.toString() ?? 'Unknown Station') as String,
      url: (json['url_resolved']?.toString() ?? json['url']?.toString() ?? '') as String,
      favicon: json['favicon']?.toString(),
      tags: json['tags']?.toString(),
      country: json['country']?.toString(),
      votes: (json['votes'] as num? ?? 0).toInt(),
      bitrate: (json['bitrate'] as num? ?? 0).toInt(),
      codec: json['codec']?.toString(),
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
        final servers = json.decode(response.body) as List;
        if (servers.isNotEmpty) {
          final best = (servers.first as Map<String, dynamic>)['name'];
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

  Future<List<RadioStation>> getByCountry(String country, int limit) async {
    final url = '$_baseUrl/stations/bycountry/${Uri.encodeComponent(country)}?limit=$limit&order=votes&reverse=true';
    final results = await _dispatch(url);
    return results.map((r) => r.toStation()).toList();
  }

  Future<List<RadioStation>> getByLanguage(String language, int limit) async {
    final url = '$_baseUrl/stations/bylanguage/${Uri.encodeComponent(language)}?limit=$limit&order=votes&reverse=true';
    final results = await _dispatch(url);
    return results.map((r) => r.toStation()).toList();
  }

  Future<List<Map<String, dynamic>>> getAllCountries() async {
    final url = '$_baseUrl/countries?order=stationcount&reverse=true';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getAllLanguages() async {
    final url = '$_baseUrl/languages?order=stationcount&reverse=true';
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getTopTags(int limit) async {
    final url = '$_baseUrl/tags?limit=$limit&order=stationcount&reverse=true';
    return _rateLimiter.dispatch<List<Map<String, dynamic>>>(
      apiId: 'radio-browser',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            return data.map((e) => e as Map<String, dynamic>).toList();
          }
        } catch (e) {
          debugPrint('RadioBrowserService: Tag fetch failed: $e');
        }
        return [];
      },
    );
  }

  Future<List<RadioStationResult>> _dispatch(String url) async {
    return _rateLimiter.dispatch<List<RadioStationResult>>(
      apiId: 'radio-browser',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            return data.map((j) => RadioStationResult.fromJson(j as Map<String, dynamic>)).toList();
          }
        } catch (e) {
          debugPrint('RadioBrowserService: Request failed ($url): $e');
        }
        return <RadioStationResult>[];
      },
    );
  }
}
