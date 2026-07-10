import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/library/providers/wikipedia_service.dart';
import 'package:aulos/data/database/discovery_database.dart';
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late WikipediaService service;
  late MockHttpClient mockClient;
  late DiscoveryDatabase db;

  setUp(() {
    mockClient = MockHttpClient();
    db = DiscoveryDatabase.testing(NativeDatabase.memory());
    service = WikipediaService(client: mockClient, db: db);
    registerFallbackValue(Uri());
  });

  tearDown(() async {
    await db.close();
  });

  test('fetchSummary fetches search and summary correctly on success', () async {
    final mockSearchResponse = {
      'query': {
        'search': [
          {'title': 'Test Article'}
        ]
      }
    };

    final mockSummaryResponse = {
      'extract': 'This is a test summary extract.',
      'thumbnail': {'source': 'https://example.com/thumb.jpg'},
      'content_urls': {
        'desktop': {'page': 'https://en.wikipedia.org/wiki/Test_Article'}
      }
    };

    when(() => mockClient.get(Uri.parse(
      'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Test%20Query&format=json&origin=*',
    ))).thenAnswer((_) async => http.Response(json.encode(mockSearchResponse), 200));

    when(() => mockClient.get(Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/Test%20Article',
    ))).thenAnswer((_) async => http.Response(json.encode(mockSummaryResponse), 200));

    final result = await service.fetchSummary('Test Query');

    expect(result, isNotNull);
    expect(result!.title, 'Test Article');
    expect(result.extract, 'This is a test summary extract.');
    expect(result.thumbnailUrl, 'https://example.com/thumb.jpg');
    expect(result.pageUrl, 'https://en.wikipedia.org/wiki/Test_Article');
  });

  test('fetchSummary returns null if search results are empty', () async {
    final mockSearchResponse = {
      'query': {
        'search': <Map<String, dynamic>>[]
      }
    };

    when(() => mockClient.get(any()))
        .thenAnswer((_) async => http.Response(json.encode(mockSearchResponse), 200));

    final result = await service.fetchSummary('Unknown Query');

    expect(result, isNull);
  });

  test('fetchSummary caches results in database and resolves offline on subsequent calls', () async {
    final mockSearchResponse = {
      'query': {
        'search': [
          {'title': 'Cache Test'}
        ]
      }
    };
    final mockSummaryResponse = {
      'extract': 'Cached summary content.',
      'thumbnail': {'source': 'https://example.com/cache.jpg'},
      'content_urls': {
        'desktop': {'page': 'https://en.wikipedia.org/wiki/Cache_Test'}
      }
    };

    // First call: hits HTTP Client and populates cache
    when(() => mockClient.get(Uri.parse(
      'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=Cache%20Query&format=json&origin=*',
    ))).thenAnswer((_) async => http.Response(json.encode(mockSearchResponse), 200));

    when(() => mockClient.get(Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/Cache%20Test',
    ))).thenAnswer((_) async => http.Response(json.encode(mockSummaryResponse), 200));

    final result1 = await service.fetchSummary('Cache Query');
    expect(result1, isNotNull);
    expect(result1!.extract, 'Cached summary content.');

    // Reset client to ensure we do NOT hit the network anymore
    reset(mockClient);

    // Second call: queries the local database cache directly without making network requests
    final result2 = await service.fetchSummary('Cache Query');
    expect(result2, isNotNull);
    expect(result2!.title, 'Cache Test');
    expect(result2.extract, 'Cached summary content.');
    
    // Verify mockClient.get was never called this time
    verifyNoMoreInteractions(mockClient);
  });
}
