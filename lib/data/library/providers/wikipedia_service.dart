import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/data/database/discovery_database.dart';

class WikipediaService {
  final http.Client _client;
  final RateLimitDispatcher _rateLimiter;
  final LogService _logService;
  final DiscoveryDatabase? _db;

  WikipediaService({
    http.Client? client,
    LogService? logService,
    RateLimitDispatcher? rateLimiter,
    DiscoveryDatabase? db,
  })  : _client = client ?? http.Client(),
        _logService = logService ?? NoOpLogService(),
        _rateLimiter = rateLimiter ?? RateLimitDispatcher(),
        _db = db;

  void log(String message) => _logService.log(message);

  /// Searches Wikipedia and fetches the page summary for the first result.
  Future<WikipediaSummary?> fetchSummary(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return null;

    final bytes = utf8.encode(cleanQuery);
    final cacheKey = sha256.convert(bytes).toString().substring(0, 16);

    // 1. Check local database cache
    if (_db != null) {
      try {
        final cached = await _db.getWikipediaSummary(cacheKey);
        if (cached != null) {
          log('WIKIPEDIA: Found cached summary for "$query" (key: $cacheKey)');
          return WikipediaSummary(
            title: cached.title,
            extract: cached.extract,
            thumbnailUrl: cached.thumbnailUrl,
            pageUrl: cached.pageUrl,
          );
        }
      } catch (e) {
        log('WIKIPEDIA_ERROR: Failed to query cache: $e');
      }
    }

    // 2. Fetch from Wikipedia API if not cached
    log('WIKIPEDIA: Searching summary for "$query"');
    return _rateLimiter.dispatch<WikipediaSummary?>(
      apiId: 'musicbrainz', // Reuse musicbrainz api rate limiting mapping (1s delay)
      call: () async {
        try {
          // Search for matching page
          final searchUrl = Uri.parse(
            'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=${Uri.encodeComponent(query)}&format=json&origin=*',
          );
          final searchResponse = await _client.get(searchUrl).timeout(const Duration(seconds: 15));
          if (searchResponse.statusCode != 200) {
            log('WIKIPEDIA: Search status code: ${searchResponse.statusCode}');
            return null;
          }

          final searchData = json.decode(searchResponse.body) as Map<String, dynamic>;
          final queryObj = searchData['query'] as Map<String, dynamic>?;
          final searchResults = queryObj?['search'] as List<dynamic>?;

          if (searchResults == null || searchResults.isEmpty) {
            log('WIKIPEDIA: No page matches found for "$query"');
            return null;
          }

          final firstMatchTitle = searchResults.first['title'] as String;
          log('WIKIPEDIA: Found matching title: "$firstMatchTitle"');

          // Fetch page summary
          final summaryUrl = Uri.parse(
            'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(firstMatchTitle)}',
          );
          final summaryResponse = await _client.get(summaryUrl).timeout(const Duration(seconds: 15));
          log('WIKIPEDIA: Summary response status: ${summaryResponse.statusCode}');
          
          if (summaryResponse.statusCode == 200) {
            final summaryData = json.decode(summaryResponse.body) as Map<String, dynamic>;
            final extract = summaryData['extract'] as String?;
            final thumbnailObj = summaryData['thumbnail'] as Map<String, dynamic>?;
            final thumbnailUrl = thumbnailObj?['source'] as String?;
            final contentUrlsObj = summaryData['content_urls'] as Map<String, dynamic>?;
            final desktopObj = contentUrlsObj?['desktop'] as Map<String, dynamic>?;
            final pageUrl = desktopObj?['page'] as String?;

            if (extract != null && extract.isNotEmpty) {
              final summary = WikipediaSummary(
                title: firstMatchTitle,
                extract: extract,
                thumbnailUrl: thumbnailUrl,
                pageUrl: pageUrl,
              );

              // 3. Save to database cache
              if (_db != null) {
                try {
                  await _db.insertWikipediaSummary(
                    WikipediaSummariesCompanion.insert(
                      cacheKey: cacheKey,
                      query: query,
                      title: firstMatchTitle,
                      extract: extract,
                      thumbnailUrl: Value(thumbnailUrl),
                      pageUrl: Value(pageUrl),
                    ),
                  );
                  log('WIKIPEDIA: Saved search summary to cache for "$query" (key: $cacheKey)');
                } catch (e) {
                  log('WIKIPEDIA_ERROR: Failed to save to cache: $e');
                }
              }

              return summary;
            }
          }
        } catch (e) {
          log('WIKIPEDIA_ERROR: Fetch failed for "$query": $e');
        }
        return null;
      },
    );
  }
}

class WikipediaSummary {
  final String title;
  final String extract;
  final String? thumbnailUrl;
  final String? pageUrl;

  WikipediaSummary({
    required this.title,
    required this.extract,
    this.thumbnailUrl,
    this.pageUrl,
  });
}
