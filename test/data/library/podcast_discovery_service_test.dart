import 'package:flutter_test/flutter_test.dart';
import 'package:localaudioplayer/data/library/podcast_discovery_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

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
}
