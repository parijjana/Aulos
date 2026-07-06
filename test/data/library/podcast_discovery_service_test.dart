import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late PodcastDiscoveryService service;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    service = PodcastDiscoveryService(client: mockClient);
    registerFallbackValue(Uri());
  });

  test('getTrendingPodcasts fetches and parses iTunes RSS correctly', () async {
    final mockResponse = {
      'feed': {
        'results': [
          {
            'name': 'Test Podcast',
            'artistName': 'Test Artist',
            'id': '12345',
            'artworkUrl100': 'https://example.com/art.jpg',
          }
        ]
      }
    };

    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response(json.encode(mockResponse), 200),
    );

    final results = await service.getTrendingPodcasts();

    expect(results.length, 1);
    expect(results.first.title, 'Test Podcast');
    expect(results.first.artist, 'Test Artist');
    expect(results.first.itunesId, '12345'); 
  });

  test('lookupFeedUrl returns feed URL from iTunes lookup', () async {
    final mockResponse = {
      'results': [
        {'feedUrl': 'https://example.com/rss'}
      ]
    };

    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response(json.encode(mockResponse), 200),
    );

    final url = await service.lookupFeedUrl('12345');
    expect(url, 'https://example.com/rss');
  });

  group('PodcastIndex Integration', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'podcast_index_api_key': 'test-key',
        'podcast_index_api_secret': 'test-secret',
      });
      prefs = await SharedPreferences.getInstance();
      service = PodcastDiscoveryService(client: mockClient, prefs: prefs);
    });

    test('isPodcastIndexEnabled returns true when credentials exist', () {
      expect(service.isPodcastIndexEnabled, true);
    });

    test('searchPodcasts queries PodcastIndex endpoint and parses response', () async {
      final mockResponse = {
        'status': 'true',
        'feeds': [
          {
            'id': 112233,
            'title': 'PI Podcast',
            'author': 'PI Author',
            'url': 'https://example.com/pi.xml',
            'image': 'https://example.com/pi.jpg',
            'description': 'A PodcastIndex podcast',
          }
        ]
      };

      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments[0] as Uri;
        capturedHeaders = invocation.namedArguments[#headers] as Map<String, String>?;
        return http.Response(json.encode(mockResponse), 200);
      });

      final results = await service.searchPodcasts('tech');

      expect(results.length, 1);
      expect(results.first.title, 'PI Podcast');
      expect(results.first.artist, 'PI Author');
      expect(results.first.feedUrl, 'https://example.com/pi.xml');
      expect(results.first.itunesId, '112233');

      expect(capturedUri.toString(), contains('api.podcastindex.org/api/1.0/search/byterm'));
      expect(capturedUri.toString(), contains('q=tech'));
      expect(capturedHeaders?['X-Auth-Key'], 'test-key');
      expect(capturedHeaders?['X-Auth-Date'], isNotNull);
      expect(capturedHeaders?['Authorization'], isNotNull);
    });

    test('getPodcastsByCategory queries PodcastIndex trending with category name', () async {
      final mockResponse = {
        'status': 'true',
        'feeds': [
          {
            'id': 445566,
            'title': 'Tech Feed',
            'author': 'Tech Author',
            'url': 'https://example.com/tech.xml',
          }
        ]
      };

      Uri? capturedUri;
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments[0] as Uri;
        return http.Response(json.encode(mockResponse), 200);
      });

      final results = await service.getPodcastsByCategory('1318'); // Technology

      expect(results.length, 1);
      expect(results.first.title, 'Tech Feed');
      expect(capturedUri.toString(), contains('api.podcastindex.org/api/1.0/podcasts/trending'));
      expect(capturedUri.toString(), contains('cat=Technology'));
    });

    test('lookupFeedUrl queries byfeedid and falls back to byitunesid', () async {
      // Stub the first call (byfeedid) to return empty/not found
      when(() => mockClient.get(Uri.parse('https://api.podcastindex.org/api/1.0/podcasts/byfeedid?id=999'), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(json.encode({'status': 'false'}), 200));

      // Stub the second call (byitunesid) to return the feed
      final mockResponse = {
        'status': 'true',
        'feed': {
          'id': 999,
          'url': 'https://example.com/found.xml',
        }
      };
      when(() => mockClient.get(Uri.parse('https://api.podcastindex.org/api/1.0/podcasts/byitunesid?id=999'), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      final url = await service.lookupFeedUrl('999');
      expect(url, 'https://example.com/found.xml');
    });
  });
}
