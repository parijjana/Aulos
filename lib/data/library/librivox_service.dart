import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/core/network/json_types.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/domain/library/librivox_book.dart';

class LibriVoxService {
  final http.Client _client;
  final RateLimitDispatcher _rateLimiter;
  final LogService _logService;
  static const String _baseUrl = 'https://librivox.org/api/feed/audiobooks';

  LibriVoxService({
    LogService? logService,
    http.Client? client,
    RateLimitDispatcher? rateLimiter,
  }) : _client = client ?? http.Client(),
       _rateLimiter = rateLimiter ?? RateLimitDispatcher(),
       _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  Future<List<LibriVoxBook>> searchBooks(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final term = query.trim();
    String url = '$_baseUrl/?format=json&extended=1&limit=$limit&offset=$offset';
    if (term.isNotEmpty) {
      url += '&title=${Uri.encodeComponent(term)}';
    }

    log('LIBRIVOX: Searching books with query "$term" (offset: $offset)');

    return _rateLimiter.dispatch<List<LibriVoxBook>>(
      apiId: 'librivox',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final booksData = data['books'];
            final List<LibriVoxBook> books = [];

            if (booksData is JsonMap) {
              for (var entry in booksData.values) {
                if (entry is JsonMap) {
                  books.add(LibriVoxBook.fromJson(entry));
                }
              }
            } else if (booksData is List) {
              for (var item in booksData) {
                if (item is JsonMap) {
                  books.add(LibriVoxBook.fromJson(item));
                }
              }
            }
            log('LIBRIVOX: Found ${books.length} books.');
            return books;
          } else {
            log('LIBRIVOX: Search failed with status ${response.statusCode}');
            throw Exception('Search failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('LIBRIVOX: Search error: $e');
          rethrow;
        }
      },
    );
  }

  Future<LibriVoxBook?> getBookById(String id) async {
    if (id.isEmpty) return null;
    final url = '$_baseUrl/?id=$id&format=json&extended=1';

    log('LIBRIVOX: Fetching book details for ID $id');

    return _rateLimiter.dispatch<LibriVoxBook?>(
      apiId: 'librivox',
      call: () async {
        try {
          final response = await _client.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = await compute(json.decode, response.body) as JsonMap;
            final booksData = data['books'];

            if (booksData is JsonMap && booksData.isNotEmpty) {
              final firstBook = booksData.values.first;
              if (firstBook is JsonMap) {
                return LibriVoxBook.fromJson(firstBook);
              }
            } else if (booksData is List && booksData.isNotEmpty) {
              final firstBook = booksData.first;
              if (firstBook is JsonMap) {
                return LibriVoxBook.fromJson(firstBook);
              }
            }
          } else {
            log('LIBRIVOX: Fetch by ID failed with status ${response.statusCode}');
            throw Exception('Fetch by ID failed with status ${response.statusCode}');
          }
        } catch (e) {
          log('LIBRIVOX: Fetch by ID error: $e');
          rethrow;
        }
        return null;
      },
    );
  }
}
