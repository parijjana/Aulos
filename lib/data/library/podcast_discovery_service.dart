import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/domain/network/log_service.dart';

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

  factory PodcastSearchResult.fromJson(Map<String, dynamic> json) {
    return PodcastSearchResult(
      title: (json['collectionName']?.toString() ?? 'Unknown Podcast') as String,
      artist: (json['artistName']?.toString() ?? 'Unknown Artist') as String,
      feedUrl: (json['feedUrl']?.toString() ?? '') as String,
      imageUrl: (json['artworkUrl600'] ?? json['artworkUrl100'])?.toString(),
      itunesId: json['collectionId']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class PodcastDiscoveryService with UniversalLog {
  final http.Client _client;
  final RateLimitDispatcher _rateLimiter;

  PodcastDiscoveryService({
    http.Client? client,
    RateLimitDispatcher? rateLimiter,
  }) : _client = client ?? http.Client(),
       _rateLimiter = rateLimiter ?? RateLimitDispatcher();

  Future<List<PodcastSearchResult>> searchPodcasts(
    String query, {
    int limit = 25,
    int offset = 0,
  }) async {
    if (query.isEmpty) return [];

    log('API: Searching podcasts for "$query" (offset: $offset)');
    final url = 'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=podcast&limit=$limit&offset=$offset';
    
    return _rateLimiter.dispatch<List<PodcastSearchResult>>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as Map<String, dynamic>;
            final results = data['results'] as List? ?? [];
            log('API: Search successful. Found ${results.length} results.');
            return results
                .map<PodcastSearchResult>((j) => PodcastSearchResult.fromJson(j as Map<String, dynamic>))
                .where((r) => r.feedUrl.isNotEmpty)
                .toList();
          } else {
            log('API: Search failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Search error: $e');
        }
        return <PodcastSearchResult>[];
      },
    );
  }

  Future<List<PodcastSearchResult>> getPodcastsByCategory(
    String categoryId, {
    int limit = 5,
    int offset = 0,
  }) async {
    log('API: Fetching category $categoryId (limit: $limit, offset: $offset)');
    final url = 'https://itunes.apple.com/search?term=podcast&genreId=$categoryId&entity=podcast&limit=$limit&offset=$offset';
    
    return _rateLimiter.dispatch<List<PodcastSearchResult>>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as Map<String, dynamic>;
            final results = data['results'] as List? ?? [];
            log('API: Category fetch successful. Found ${results.length} items.');
            return results
                .map<PodcastSearchResult>((j) => PodcastSearchResult.fromJson(j as Map<String, dynamic>))
                .where((r) => r.feedUrl.isNotEmpty)
                .toList();
          } else {
            log('API: Category fetch failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Category fetch error: $e');
        }
        return <PodcastSearchResult>[];
      },
    );
  }

  Future<List<PodcastSearchResult>> getTrendingPodcasts() async {
    const url = 'https://rss.applemarketingtools.com/api/v2/us/podcasts/top/25/podcasts.json';
    log('API: Fetching global trending podcasts');
    return _rateLimiter.dispatch<List<PodcastSearchResult>>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as Map<String, dynamic>;
            final results = data['feed']['results'] as List? ?? [];
            log('API: Trending fetch successful. Found ${results.length} items.');
            return results.map<PodcastSearchResult>((j) {
              final item = j as Map<String, dynamic>;
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
          }
        } catch (e) {
          log('API: Trending fetch error: $e');
        }
        return <PodcastSearchResult>[];
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
          }
        } catch (e) {
          log('API: RSS fetch error ($url): $e');
        }
        return null;
      },
    );
  }

  Future<String?> lookupFeedUrl(String podcastId) async {
    log('API: Looking up feed URL for podcast ID: $podcastId');
    final url = 'https://itunes.apple.com/lookup?id=$podcastId';
    return _rateLimiter.dispatch<String?>(
      apiId: 'itunes',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as Map<String, dynamic>;
            final results = data['results'] as List;
            if (results.isNotEmpty) {
              final item = results.first as Map<String, dynamic>;
              final feedUrl = item['feedUrl'] as String?;
              log('API: Lookup successful. Found URL: $feedUrl');
              return feedUrl;
            } else {
              log('API: Lookup failed. No results for ID: $podcastId');
            }
          } else {
            log('API: Lookup failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('API: Lookup error: $e');
        }
        return null;
      },
    );
  }
}
