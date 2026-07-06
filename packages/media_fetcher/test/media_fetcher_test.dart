import 'package:flutter_test/flutter_test.dart';
import 'package:media_fetcher/media_fetcher.dart';
import 'package:http/http.dart' as http;
import 'package:media_fetcher/src/musicbrainz_client.dart';

void main() {
  group('RateLimiter', () {
    test('should execute tasks sequentially with cooldown', () async {
      final limiter = RateLimiter(cooldown: const Duration(milliseconds: 100));
      final stopwatch = Stopwatch()..start();
      
      final List<int> results = [];
      
      final f1 = limiter.run(() async {
        results.add(1);
        return 1;
      });
      
      final f2 = limiter.run(() async {
        results.add(2);
        return 2;
      });
      
      await Future.wait([f1, f2]);
      
      final elapsed = stopwatch.elapsedMilliseconds;
      
      // First task starts immediately.
      // Second task starts after first task completes + 100ms cooldown.
      expect(results, [1, 2]);
      expect(elapsed, greaterThanOrEqualTo(100));
    });

    test('should handle errors without breaking the queue', () async {
      final limiter = RateLimiter(cooldown: const Duration(milliseconds: 10));
      
      final f1 = limiter.run(() async => throw Exception('Fail'));
      final f2 = limiter.run(() async => 'Success');
      
      expect(f1, throwsException);
      expect(await f2, 'Success');
    });
  });

  group('MusicBrainzClient', () {
    test('getArtistPhotoUrl should rewrite wikimedia/wikipedia File urls to Special:FilePath', () async {
      final mockHttpClient = MockHttpClient((request) async {
        if (request.url.path.contains('/artist/some-mbid')) {
          return http.Response(
            '{"relations": [{"type": "image", "url": {"resource": "https://commons.wikimedia.org/wiki/File:Taylor_Swift.png"}}]}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      final photoUrl = await client.getArtistPhotoUrl('some-mbid');
      expect(photoUrl, 'https://commons.wikimedia.org/wiki/Special:FilePath/Taylor_Swift.png');
    });

    test('getArtistPhotoUrl should leave non-wikipedia/wikimedia urls as is', () async {
      final mockHttpClient = MockHttpClient((request) async {
        if (request.url.path.contains('/artist/some-mbid')) {
          return http.Response(
            '{"relations": [{"type": "image", "url": {"resource": "https://example.com/artist.jpg"}}]}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      final photoUrl = await client.getArtistPhotoUrl('some-mbid');
      expect(photoUrl, 'https://example.com/artist.jpg');
    });

    test('getArtistPhotoUrl should fall back to wikidata and commons query when direct image is missing', () async {
      final mockHttpClient = MockHttpClient((request) async {
        final path = request.url.toString();
        if (path.contains('/artist/some-mbid')) {
          return http.Response(
            '{"relations": [{"type": "wikidata", "url": {"resource": "https://www.wikidata.org/wiki/Q11649"}}]}',
            200,
          );
        } else if (path.contains('wikidata.org/w/api.php') && path.contains('Q11649')) {
          return http.Response(
            '{"claims": {"P18": [{"mainsnak": {"datavalue": {"value": "Taylor_Swift.jpg"}}}]}}',
            200,
          );
        } else if (path.contains('commons.wikimedia.org/w/api.php') && path.contains('Taylor_Swift.jpg')) {
          return http.Response(
            '{"query": {"pages": {"123": {"imageinfo": [{"url": "https://upload.wikimedia.org/wikipedia/commons/e/e1/Taylor_Swift.jpg"}]}}}}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      final photoUrl = await client.getArtistPhotoUrl('some-mbid');
      expect(photoUrl, 'https://upload.wikimedia.org/wikipedia/commons/e/e1/Taylor_Swift.jpg');
    });

    test('findArtistMbid should wrap artist name in double quotes and escape special characters', () async {
      String? capturedQuery;
      final mockHttpClient = MockHttpClient((request) async {
        capturedQuery = request.url.queryParameters['query'];
        return http.Response('{"artists": []}', 200);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      await client.findArtistMbid('AC/DC (remastered) "hits"');
      expect(capturedQuery, r'artist:"AC/DC (remastered) \"hits\""');
    });

    test('findReleaseMbid should wrap release and artist names in double quotes and escape special characters', () async {
      String? capturedQuery;
      final mockHttpClient = MockHttpClient((request) async {
        capturedQuery = request.url.queryParameters['query'];
        return http.Response('{"releases": []}', 200);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      await client.findReleaseMbid('AC/DC \\ back in black', 'Back in "Black"');
      expect(capturedQuery, r'release:"Back in \"Black\"" AND artist:"AC/DC \\ back in black"');
    });

    test('getArtistBiography should fetch wikipedia summary directly if wikipedia relation exists', () async {
      final mockHttpClient = MockHttpClient((request) async {
        final path = request.url.toString();
        if (path.contains('/artist/some-mbid')) {
          return http.Response(
            '{"relations": [{"type": "wikipedia", "url": {"resource": "https://en.wikipedia.org/wiki/Taylor_Swift"}}]}',
            200,
          );
        } else if (path.contains('en.wikipedia.org/api/rest_v1/page/summary/Taylor_Swift')) {
          return http.Response(
            '{"extract": "Taylor Swift is an American singer-songwriter."}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      final bio = await client.getArtistBiography('some-mbid');
      expect(bio, 'Taylor Swift is an American singer-songwriter.');
    });

    test('getArtistBiography should resolve wikidata id to wikipedia summary and fallback to wikidata description', () async {
      final mockHttpClient = MockHttpClient((request) async {
        final path = request.url.toString();
        if (path.contains('/artist/some-mbid')) {
          return http.Response(
            '{"relations": [{"type": "wikidata", "url": {"resource": "https://www.wikidata.org/wiki/Q11649"}}]}',
            200,
          );
        } else if (path.contains('wikidata.org/w/api.php') && path.contains('action=wbgetentities') && path.contains('props=sitelinks') && path.contains('Q11649')) {
          // Resolve to Taylor_Swift
          return http.Response(
            '{"entities": {"Q11649": {"sitelinks": {"enwiki": {"title": "Taylor Swift"}}}}}',
            200,
          );
        } else if (path.contains('en.wikipedia.org/api/rest_v1/page/summary/Taylor_Swift')) {
          // Failed to fetch wikipedia summary
          return http.Response('Not Found', 404);
        } else if (path.contains('wikidata.org/w/api.php') && path.contains('action=wbgetentities') && path.contains('props=descriptions') && path.contains('Q11649')) {
          // Fallback to wikidata description
          return http.Response(
            '{"entities": {"Q11649": {"descriptions": {"en": {"value": "American singer-songwriter"}}}}}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = MusicBrainzClient(
        userAgent: 'test-agent',
        client: mockHttpClient,
      );

      final bio = await client.getArtistBiography('some-mbid');
      expect(bio, 'American singer-songwriter.');
    });
  });
}

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) _handler;
  MockHttpClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}
