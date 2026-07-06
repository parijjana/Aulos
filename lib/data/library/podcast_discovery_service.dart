import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/core/network/json_types.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class PodcastSearchResult {
  final String title;
  final String artist;
  final String feedUrl;
  final String? imageUrl;
  final String? itunesId;
  final String? description;

  PodcastSearchResult({
    required this.title,
    required this.artist,
    required this.feedUrl,
    this.imageUrl,
    this.itunesId,
    this.description,
  });

  factory PodcastSearchResult.fromJson(JsonMap json) {
    return PodcastSearchResult(
      title: (json['collectionName']?.toString() ?? 'Unknown Podcast'),
      artist: (json['artistName']?.toString() ?? 'Unknown Artist'),
      feedUrl: (json['feedUrl']?.toString() ?? ''),
      imageUrl: (json['artworkUrl600'] ?? json['artworkUrl100'])?.toString(),
      itunesId: json['collectionId']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class PodcastDiscoveryService {
  final http.Client _client;
  final RateLimitDispatcher _rateLimiter;
  final LogService _logService;
  final SharedPreferences? _prefs;

  static const Map<String, String> _genreMap = {
    '1318': 'Technology',
    '1311': 'Business',
    '1321': 'Science',
    '1303': 'Comedy',
    '1315': 'Health',
    '1488': 'True Crime',
    '1324': 'Society & Culture',
    '1310': 'Books',
    '1301': 'Arts',
    '1304': 'Education',
    '1309': 'TV & Film',
    '1307': 'History',
  };

  PodcastDiscoveryService({
    LogService? logService,
    http.Client? client,
    RateLimitDispatcher? rateLimiter,
    SharedPreferences? prefs,
  }) : _client = client ?? http.Client(),
       _rateLimiter = rateLimiter ?? RateLimitDispatcher(),
       _logService = logService ?? NoOpLogService(),
       _prefs = prefs;

  void log(String message) => _logService.log(message);

  bool get isPodcastIndexEnabled =>
      _prefs != null &&
      (_prefs.getString('podcast_index_api_key')?.isNotEmpty ?? false) &&
      (_prefs.getString('podcast_index_api_secret')?.isNotEmpty ?? false);

  Map<String, String> _buildPodcastIndexHeaders() {
    final apiKey = _prefs?.getString('podcast_index_api_key') ?? '';
    final apiSecret = _prefs?.getString('podcast_index_api_secret') ?? '';
    final apiHeaderTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final authString = apiKey + apiSecret + apiHeaderTime;
    final authorization = sha1.convert(utf8.encode(authString)).toString();

    return {
      'User-Agent': 'Aulos/1.0',
      'X-Auth-Key': apiKey,
      'X-Auth-Date': apiHeaderTime,
      'Authorization': authorization,
      'Accept': 'application/json',
    };
  }

  Future<List<PodcastSearchResult>> searchPodcasts(
    String query, {
    int limit = 25,
    int offset = 0,
  }) async {
    if (query.isEmpty) return [];

    if (isPodcastIndexEnabled) {
      log('API: Searching PodcastIndex for "$query" (limit: $limit)');
      final url = 'https://api.podcastindex.org/api/1.0/search/byterm?q=${Uri.encodeComponent(query)}&max=$limit';
      return _rateLimiter.dispatch<List<PodcastSearchResult>>(
        apiId: 'podcastindex',
        call: () async {
          try {
            final response = await _client.get(
              Uri.parse(url),
              headers: _buildPodcastIndexHeaders(),
            );
            if (response.statusCode == 200) {
              final data = await compute(json.decode, response.body) as JsonMap;
              final feeds = data['feeds'] as List? ?? [];
              log('API: PodcastIndex Search successful. Found ${feeds.length} results.');
              return feeds.map((j) {
                final item = j as JsonMap;
                return PodcastSearchResult(
                  title: item['title']?.toString() ?? 'Unknown',
                  artist: item['author']?.toString() ?? 'Unknown',
                  feedUrl: item['url']?.toString() ?? '',
                  imageUrl: item['image']?.toString() ?? item['artwork']?.toString(),
                  itunesId: item['itunesId']?.toString() ?? item['id']?.toString(),
                  description: item['description']?.toString(),
                );
              }).where((r) => r.feedUrl.isNotEmpty).toList();
            } else {
              log('API: PodcastIndex Search failed with status ${response.statusCode}');
              throw Exception('PodcastIndex Search failed with status ${response.statusCode}');
            }
          } catch (e) {
            log('API: PodcastIndex Search error: $e');
            rethrow;
          }
        },
      );
    }

    log('API: Searching iTunes for "$query" (offset: $offset)');
    final url = 'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=podcast&limit=$limit&offset=$offset';
    
    return _rateLimiter.dispatch<List<PodcastSearchResult>>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final results = data['results'] as List? ?? [];
            log('API: Search successful. Found ${results.length} results.');
            return results
                .map<PodcastSearchResult>((j) => PodcastSearchResult.fromJson(j as JsonMap))
                .where((r) => r.feedUrl.isNotEmpty)
                .toList();
          } else {
            log('API: Search failed with status ${response.statusCode}');
            throw Exception('Search failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Search error: $e');
          rethrow;
        }
      },
    );
  }

  Future<List<PodcastSearchResult>> getPodcastsByCategory(
    String categoryId, {
    int limit = 5,
    int offset = 0,
  }) async {
    if (isPodcastIndexEnabled) {
      final catName = _genreMap[categoryId] ?? 'Technology';
      log('API: Fetching PodcastIndex category $catName (limit: $limit)');
      final url = 'https://api.podcastindex.org/api/1.0/podcasts/trending?cat=${Uri.encodeComponent(catName)}&max=$limit';
      return _rateLimiter.dispatch<List<PodcastSearchResult>>(
        apiId: 'podcastindex',
        call: () async {
          try {
            final response = await _client.get(
              Uri.parse(url),
              headers: _buildPodcastIndexHeaders(),
            );
            if (response.statusCode == 200) {
              final data = await compute(json.decode, response.body) as JsonMap;
              final feeds = data['feeds'] as List? ?? [];
              log('API: PodcastIndex Category fetch successful. Found ${feeds.length} items.');
              return feeds.map((j) {
                final item = j as JsonMap;
                return PodcastSearchResult(
                  title: item['title']?.toString() ?? 'Unknown',
                  artist: item['author']?.toString() ?? 'Unknown',
                  feedUrl: item['url']?.toString() ?? '',
                  imageUrl: item['image']?.toString() ?? item['artwork']?.toString(),
                  itunesId: item['itunesId']?.toString() ?? item['id']?.toString(),
                  description: item['description']?.toString(),
                );
              }).where((r) => r.feedUrl.isNotEmpty).toList();
            } else {
              log('API: PodcastIndex Category fetch failed with status ${response.statusCode}');
              throw Exception('PodcastIndex Category fetch failed with status ${response.statusCode}');
            }
          } catch (e) {
            log('API: PodcastIndex Category fetch error: $e');
            rethrow;
          }
        },
      );
    }

    log('API: Fetching iTunes category $categoryId (limit: $limit, offset: $offset)');
    final url = 'https://itunes.apple.com/search?term=podcast&genreId=$categoryId&entity=podcast&limit=$limit&offset=$offset';
    
    return _rateLimiter.dispatch<List<PodcastSearchResult>>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final results = data['results'] as List? ?? [];
            log('API: Category fetch successful. Found ${results.length} items.');
            return results
                .map<PodcastSearchResult>((j) => PodcastSearchResult.fromJson(j as JsonMap))
                .where((r) => r.feedUrl.isNotEmpty)
                .toList();
          } else {
            log('API: Category fetch failed with status ${response.statusCode}');
            throw Exception('Category fetch failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Category fetch error: $e');
          rethrow;
        }
      },
    );
  }

  Future<List<PodcastSearchResult>> getTrendingPodcasts() async {
    if (isPodcastIndexEnabled) {
      log('API: Fetching global trending podcasts from PodcastIndex');
      const url = 'https://api.podcastindex.org/api/1.0/podcasts/trending?max=25';
      return _rateLimiter.dispatch<List<PodcastSearchResult>>(
        apiId: 'podcastindex',
        call: () async {
          try {
            final response = await _client.get(
              Uri.parse(url),
              headers: _buildPodcastIndexHeaders(),
            );
            if (response.statusCode == 200) {
              final data = await compute(json.decode, response.body) as JsonMap;
              final feeds = data['feeds'] as List? ?? [];
              log('API: PodcastIndex Trending fetch successful. Found ${feeds.length} items.');
              return feeds.map((j) {
                final item = j as JsonMap;
                return PodcastSearchResult(
                  title: item['title']?.toString() ?? 'Unknown',
                  artist: item['author']?.toString() ?? 'Unknown',
                  feedUrl: item['url']?.toString() ?? '',
                  imageUrl: item['image']?.toString() ?? item['artwork']?.toString(),
                  itunesId: item['itunesId']?.toString() ?? item['id']?.toString(),
                  description: item['description']?.toString(),
                );
              }).where((r) => r.feedUrl.isNotEmpty).toList();
            } else {
              log('API: PodcastIndex Trending fetch failed with status ${response.statusCode}');
              throw Exception('PodcastIndex Trending fetch failed with status ${response.statusCode}');
            }
          } catch (e) {
            log('API: PodcastIndex Trending fetch error: $e');
            rethrow;
          }
        },
      );
    }

    const url = 'https://rss.applemarketingtools.com/api/v2/us/podcasts/top/25/podcasts.json';
    log('API: Fetching global trending podcasts');
    return _rateLimiter.dispatch<List<PodcastSearchResult>>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final results = (data['feed'] as JsonMap)['results'] as List? ?? [];
            log('API: Trending fetch successful. Found ${results.length} items.');
            return results.map<PodcastSearchResult>((j) {
              final item = j as JsonMap;
              return PodcastSearchResult(
                title: item['name'] as String? ?? 'Unknown',
                artist: item['artistName'] as String? ?? 'Unknown',
                feedUrl: '', 
                imageUrl: item['artworkUrl100'] as String?,
                itunesId: item['id']?.toString(),
              );
            }).toList();
          } else {
            log('API: Trending fetch failed with status ${response.statusCode}');
            throw Exception('Trending fetch failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Trending fetch error: $e');
          rethrow;
        }
      },
    );
  }

  Future<String?> fetchRawRss(String url) async {
    return _rateLimiter.dispatch<String?>(
      apiId: 'rss',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            return response.body;
          } else {
            throw Exception('RSS fetch failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: RSS fetch error ($url): $e');
          rethrow;
        }
      },
    );
  }

  Future<String?> lookupFeedUrl(String podcastId) async {
    if (isPodcastIndexEnabled) {
      log('API: Looking up PodcastIndex feed for ID: $podcastId');
      return _rateLimiter.dispatch<String?>(
        apiId: 'podcastindex',
        call: () async {
          try {
            // Try byfeedid first
            final url1 = 'https://api.podcastindex.org/api/1.0/podcasts/byfeedid?id=$podcastId';
            final response1 = await _client.get(Uri.parse(url1), headers: _buildPodcastIndexHeaders());
            if (response1.statusCode == 200) {
              final data = await compute(json.decode, response1.body) as JsonMap;
              final feed = data['feed'] as Map?;
              if (feed != null && feed['url'] != null) {
                log('API: PodcastIndex Lookup byfeedid successful. Found: ${feed['url']}');
                return feed['url'] as String?;
              }
            }

            // Fallback: Try byitunesid
            final url2 = 'https://api.podcastindex.org/api/1.0/podcasts/byitunesid?id=$podcastId';
            final response2 = await _client.get(Uri.parse(url2), headers: _buildPodcastIndexHeaders());
            if (response2.statusCode == 200) {
              final data = await compute(json.decode, response2.body) as JsonMap;
              final feed = data['feed'] as Map?;
              if (feed != null && feed['url'] != null) {
                log('API: PodcastIndex Lookup byitunesid successful. Found: ${feed['url']}');
                return feed['url'] as String?;
              }
            }
            log('API: PodcastIndex Lookup failed for ID: $podcastId');
            return null;
          } catch (e) {
            log('API: PodcastIndex Lookup error: $e');
            return null;
          }
        },
      );
    }

    log('API: Looking up feed URL for podcast ID: $podcastId');
    final url = 'https://itunes.apple.com/lookup?id=$podcastId';
    return _rateLimiter.dispatch<String?>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final results = data['results'] as List;
            if (results.isNotEmpty) {
              final item = results.first as JsonMap;
              final feedUrl = item['feedUrl'] as String?;
              log('API: Lookup successful. Found URL: $feedUrl');
              return feedUrl;
            } else {
              log('API: Lookup failed. No results for ID: $podcastId');
              return null;
            }
          } else {
            log('API: Lookup failed with status ${response.statusCode}');
            throw Exception('Lookup failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Lookup error: $e');
          rethrow;
        }
      },
    );
  }
}
