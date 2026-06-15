import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/core/config/api_config.dart';

class AudnexusService {
  final http.Client _client = http.Client();
  final RateLimitDispatcher _rateLimiter;
  final LogService _logService;
  final String _baseUrl = ApiConfig.audnexusBaseUrl;

  AudnexusService({
    LogService? logService,
    required RateLimitDispatcher rateLimiter,
  })  : _logService = logService ?? NoOpLogService(),
        _rateLimiter = rateLimiter;

  void log(String message) => _logService.log(message);

  Future<Map<String, dynamic>?> searchBook(String query) async {
    log('AUDNEXUS: Searching for "$query"');
    return _rateLimiter.dispatch<Map<String, dynamic>?>(
      apiId: 'audnexus',
      call: () async {
        try {
          final response = await _client.get(
            Uri.parse('$_baseUrl/search/books?q=${Uri.encodeComponent(query)}'),
          ).timeout(const Duration(seconds: 15));
          
          log('AUDNEXUS: Search status: ${response.statusCode}');
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            if (data.isNotEmpty) {
              log('AUDNEXUS: Found ${data.length} potential matches. Using first.');
              return data.first as Map<String, dynamic>;
            } else {
              log('AUDNEXUS: No matches found for "$query"');
            }
          }
        } catch (e) {
          log('AUDNEXUS_ERROR: Search failed: $e');
        }
        return null;
      },
    );
  }

  Future<Map<String, dynamic>?> getBookMetadata(String asin) async {
    log('AUDNEXUS: Fetching metadata for ASIN: $asin');
    return _rateLimiter.dispatch<Map<String, dynamic>?>(
      apiId: 'audnexus',
      call: () async {
        try {
          final response = await _client.get(
            Uri.parse('$_baseUrl/books/$asin'),
          ).timeout(const Duration(seconds: 15));
          
          log('AUDNEXUS: Metadata status: ${response.statusCode}');
          if (response.statusCode == 200) {
            return json.decode(response.body) as Map<String, dynamic>;
          }
        } catch (e) {
          log('AUDNEXUS_ERROR: Metadata fetch failed: $e');
        }
        return null;
      },
    );
  }

  Future<List<dynamic>> getChapters(String asin) async {
    log('AUDNEXUS: Fetching chapters for ASIN: $asin');
    return _rateLimiter.dispatch<List<dynamic>>(
      apiId: 'audnexus',
      call: () async {
        try {
          final response = await _client.get(
            Uri.parse('$_baseUrl/books/$asin/chapters'),
          ).timeout(const Duration(seconds: 15));
          
          log('AUDNEXUS: Chapters status: ${response.statusCode}');
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as Map<String, dynamic>;
            return data['chapters'] as List? ?? [];
          }
        } catch (e) {
          log('AUDNEXUS_ERROR: Chapters fetch failed: $e');
        }
        return [];
      },
    );
  }

  Future<Map<String, dynamic>?> getAuthorMetadata(String name) async {
    log('AUDNEXUS: Searching author "$name"');
    return _rateLimiter.dispatch<Map<String, dynamic>?>(
      apiId: 'audnexus',
      call: () async {
        try {
          final response = await _client.get(
            Uri.parse('$_baseUrl/search/authors?q=${Uri.encodeComponent(name)}'),
          ).timeout(const Duration(seconds: 15));
          
          log('AUDNEXUS: Author search status: ${response.statusCode}');
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            if (data.isNotEmpty) {
               final first = data.first as Map<String, dynamic>;
               final id = first['id'];
               if (id != null) {
                 final detailResp = await _client.get(
                   Uri.parse('$_baseUrl/authors/$id'),
                 ).timeout(const Duration(seconds: 15));
                 
                 log('AUDNEXUS: Author detail status: ${detailResp.statusCode}');
                 if (detailResp.statusCode == 200) {
                   return json.decode(detailResp.body) as Map<String, dynamic>;
                 }
               }
            }
          }
        } catch (e) {
          log('AUDNEXUS_ERROR: Author fetch failed: $e');
        }
        return null;
      },
    );
  }

  void dispose() {
    _client.close();
  }
}
