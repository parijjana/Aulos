import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rate_limiter.dart';

class MusicBrainzClient {
  final String baseUrl;
  final String caaUrl;
  
  final String userAgent;
  final RateLimiter? _legacyLimiter;
  final Future<T> Function<T>(Future<T> Function() call)? _universalDispatcher;
  final http.Client _client;
  final void Function(String message)? _onLog;

  MusicBrainzClient({
    required this.userAgent,
    String? baseUrl,
    String? caaUrl,
    RateLimiter? limiter,
    Future<T> Function<T>(Future<T> Function() call)? universalDispatcher,
    http.Client? client,
    void Function(String message)? onLog,
  }) : baseUrl = baseUrl ?? 'https://musicbrainz.org/ws/2',
       caaUrl = caaUrl ?? 'https://coverartarchive.org',
       _legacyLimiter = limiter ?? (universalDispatcher == null ? RateLimiter(cooldown: const Duration(seconds: 1)) : null),
       _universalDispatcher = universalDispatcher,
       _client = client ?? http.Client(),
       _onLog = onLog;

  void _log(String message) {
    if (_onLog != null) _onLog(message);
  }

  Future<T> _run<T>(Future<T> Function() task) {
    if (_universalDispatcher != null) {
      return _universalDispatcher<T>(task);
    }
    return _legacyLimiter!.run(task);
  }

  String _escapePhrase(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  }

  /// Searches for an artist and returns their MusicBrainz ID (MBID).
  Future<String?> findArtistMbid(String name) async {
    _log('API: Searching MusicBrainz for artist: $name');
    final escapedName = _escapePhrase(name);
    final query = 'artist:"$escapedName"';
    final uri = Uri.parse('$baseUrl/artist').replace(
      queryParameters: {
        'query': query,
        'fmt': 'json',
      },
    );
    
    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final artists = data['artists'] as List<dynamic>;
      if (artists.isNotEmpty) {
        final id = artists.first['id']?.toString();
        if (id != null) {
          _log('API: Found artist MBID: $id');
          return id;
        }
      }
    }
    _log('API: No MusicBrainz ID found for artist: $name');
    return null;
  }

  /// Searches for a release (album) and returns its MBID.
  Future<String?> findReleaseMbid(String artistName, String albumName) async {
    _log('API: Searching MusicBrainz for album: "$albumName" by "$artistName"');
    final escapedArtist = _escapePhrase(artistName);
    final escapedAlbum = _escapePhrase(albumName);
    final query = 'release:"$escapedAlbum" AND artist:"$escapedArtist"';
    final uri = Uri.parse('$baseUrl/release').replace(
      queryParameters: {
        'query': query,
        'fmt': 'json',
      },
    );

    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final releases = data['releases'] as List<dynamic>;
      if (releases.isNotEmpty) {
        final id = releases.first['id']?.toString();
        if (id != null) {
          _log('API: Found release MBID: $id');
          return id;
        }
      }
    }
    _log('API: No release MBID found for: $albumName');
    return null;
  }

  /// Returns the URL for the front cover of a release MBID.
  Future<String?> getCoverArtUrl(String mbid) async {
    _log('API: Checking CoverArtArchive for MBID: $mbid');
    final uri = Uri.parse('$caaUrl/release/$mbid');

    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = data['images'] as List<dynamic>;
      for (var img in images) {
        if (img['front'] == true) {
          final url = img['image']?.toString();
          if (url != null) {
            _log('API: Found cover art URL: $url');
            return url;
          }
        }
      }
    }
    _log('API: No cover art found for MBID: $mbid');
    return null;
  }

  /// Attempts to find an artist photo URL.
  Future<String?> getArtistPhotoUrl(String mbid) async {
    _log('API: Checking artist photo for MBID: $mbid');
    final uri = Uri.parse('$baseUrl/artist/$mbid?inc=url-rels&fmt=json');
    
    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final relations = data['relations'] as List<dynamic>? ?? [];
      
      // First pass: try to find a direct image relation
      for (var rel in relations) {
        if (rel['type'] == 'image') {
          String? url = rel['url']?['resource'] as String?;
          if (url != null) {
            final fileUri = Uri.tryParse(url);
            if (fileUri != null && fileUri.path.contains('/wiki/File:')) {
              final index = fileUri.path.indexOf('/wiki/File:');
              final filename = fileUri.path.substring(index + 11);
              final prefix = fileUri.path.substring(0, index);
              final newPath = '$prefix/wiki/Special:FilePath/$filename';
              url = fileUri.replace(path: newPath).toString();
            }
            _log('API: Found direct artist photo URL: $url');
            return url;
          }
        }
      }

      // Second pass: fallback to wikidata relation
      for (var rel in relations) {
        if (rel['type'] == 'wikidata') {
          final wikidataUrl = rel['url']?['resource'] as String?;
          if (wikidataUrl != null) {
            _log('API: Found Wikidata URL: $wikidataUrl');
            final wikidataId = _extractWikidataId(wikidataUrl);
            if (wikidataId != null) {
              final imageUrl = await _fetchImageFromWikidata(wikidataId);
              if (imageUrl != null) {
                _log('API: Found artist photo via Wikidata: $imageUrl');
                return imageUrl;
              }
            }
          }
        }
      }
    }
    return null;
  }

  String? _extractWikidataId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[segments.length - 2] == 'wiki') {
      return segments.last;
    }
    final match = RegExp(r'(Q\d+)$').firstMatch(url);
    return match?.group(1);
  }

  Future<String?> _fetchImageFromWikidata(String wikidataId) async {
    try {
      _log('API: Querying Wikidata entity $wikidataId for P18 (image)');
      final uri = Uri.parse('https://www.wikidata.org/w/api.php?action=wbgetclaims&entity=$wikidataId&property=P18&format=json');
      final response = await _run(() => _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final claims = data['claims'] as Map<String, dynamic>?;
        final p18 = claims?['P18'] as List<dynamic>?;
        if (p18 != null && p18.isNotEmpty) {
          final filename = p18.first['mainsnak']?['datavalue']?['value'] as String?;
          if (filename != null && filename.isNotEmpty) {
            _log('API: Found image filename from Wikidata: $filename');
            return await _fetchUrlFromCommons(filename);
          }
        }
      }
    } catch (e) {
      _log('API_ERROR: Failed to fetch from Wikidata: $e');
    }
    return null;
  }

  Future<String?> _fetchUrlFromCommons(String filename) async {
    try {
      _log('API: Querying Wikimedia Commons for file URL of $filename');
      final uri = Uri.parse('https://commons.wikimedia.org/w/api.php?action=query&titles=File:${Uri.encodeComponent(filename)}&prop=imageinfo&iiprop=url&format=json');
      final response = await _run(() => _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pages = data['query']?['pages'] as Map<String, dynamic>?;
        if (pages != null && pages.isNotEmpty) {
          final firstPage = pages.values.first;
          final imageinfo = firstPage['imageinfo'] as List<dynamic>?;
          if (imageinfo != null && imageinfo.isNotEmpty) {
            final url = imageinfo.first['url'] as String?;
            if (url != null) {
              _log('API: Found Commons file URL: $url');
              return url;
            }
          }
        }
      }
    } catch (e) {
      _log('API_ERROR: Failed to fetch from Commons: $e');
    }
    return null;
  }

  /// Attempts to fetch an artist biography.
  Future<String?> getArtistBiography(String mbid) async {
    _log('API: Fetching artist biography for MBID: $mbid');
    final uri = Uri.parse('$baseUrl/artist/$mbid?inc=url-rels&fmt=json');
    
    final response = await _run(() => _client.get(
      uri,
      headers: {'User-Agent': userAgent, 'Accept': 'application/json'},
    ));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final relations = data['relations'] as List<dynamic>? ?? [];
    
    String? wikipediaTitle;
    String? wikidataId;

    // 1. Look for wikipedia relations
    for (var rel in relations) {
      if (rel['type'] == 'wikipedia') {
        final resourceUrl = rel['url']?['resource'] as String?;
        if (resourceUrl != null) {
          final uri = Uri.tryParse(resourceUrl);
          if (uri != null && uri.host.endsWith('wikipedia.org')) {
            final segments = uri.pathSegments;
            if (segments.length >= 2 && segments[segments.length - 2] == 'wiki') {
              wikipediaTitle = segments.last;
              _log('API: Found Wikipedia title directly: $wikipediaTitle');
              break;
            }
          }
        }
      }
    }

    // 2. Look for wikidata relation if no direct Wikipedia title
    if (wikipediaTitle == null) {
      for (var rel in relations) {
        if (rel['type'] == 'wikidata') {
          final wikidataUrl = rel['url']?['resource'] as String?;
          if (wikidataUrl != null) {
            wikidataId = _extractWikidataId(wikidataUrl);
            _log('API: Found Wikidata ID: $wikidataId');
            break;
          }
        }
      }
    }

    // 3. Resolve Wikidata ID to Wikipedia Title if needed
    if (wikipediaTitle == null && wikidataId != null) {
      wikipediaTitle = await _resolveWikidataToWikipediaTitle(wikidataId);
    }

    // 4. Fetch Wikipedia Summary
    if (wikipediaTitle != null) {
      final summary = await _fetchWikipediaSummary(wikipediaTitle);
      if (summary != null && summary.isNotEmpty) {
        return summary;
      }
    }

    // 5. Fallback: Get Wikidata English description if all else fails
    if (wikidataId != null) {
      final desc = await _fetchWikidataDescription(wikidataId);
      if (desc != null && desc.isNotEmpty) {
        return desc;
      }
    }

    return null;
  }

  Future<String?> _resolveWikidataToWikipediaTitle(String wikidataId) async {
    try {
      _log('API: Resolving Wikidata $wikidataId to enwiki sitelink');
      final uri = Uri.parse('https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$wikidataId&props=sitelinks&sitefilter=enwiki&format=json');
      final response = await _run(() => _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final enwiki = data['entities']?[wikidataId]?['sitelinks']?['enwiki']?['title'] as String?;
        if (enwiki != null) {
          _log('API: Wikidata resolved to Wikipedia title: $enwiki');
          return enwiki.replaceAll(' ', '_');
        }
      }
    } catch (e) {
      _log('API_ERROR: Failed to resolve Wikidata ID to Wikipedia title: $e');
    }
    return null;
  }

  Future<String?> _fetchWikipediaSummary(String title) async {
    try {
      _log('API: Fetching Wikipedia summary for: $title');
      final uri = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}');
      final response = await _run(() => _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final extract = data['extract'] as String?;
        if (extract != null && extract.isNotEmpty) {
          _log('API: Successfully fetched Wikipedia summary.');
          return extract;
        }
      }
    } catch (e) {
      _log('API_ERROR: Failed to fetch Wikipedia summary: $e');
    }
    return null;
  }

  Future<String?> _fetchWikidataDescription(String wikidataId) async {
    try {
      _log('API: Fetching description from Wikidata for: $wikidataId');
      final uri = Uri.parse('https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$wikidataId&props=descriptions&languages=en&format=json');
      final response = await _run(() => _client.get(
        uri,
        headers: {'User-Agent': userAgent},
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final desc = data['entities']?[wikidataId]?['descriptions']?['en']?['value'] as String?;
        if (desc != null && desc.isNotEmpty) {
          _log('API: Successfully fetched Wikidata description.');
          return desc;
        }
      }
    } catch (e) {
      _log('API_ERROR: Failed to fetch Wikidata description: $e');
    }
    return null;
  }
}
