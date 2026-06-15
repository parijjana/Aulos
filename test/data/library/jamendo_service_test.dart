import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/library/jamendo_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late JamendoService service;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    service = JamendoService(client: mockClient);
    registerFallbackValue(Uri());
  });

  test('searchTracks fetches and parses Jamendo tracks correctly', () async {
    final mockResponse = {
      'results': [
        {
          'id': '12345',
          'name': 'Test Song',
          'artist_name': 'Test Artist',
          'album_name': 'Test Album',
          'duration': 180,
          'audio': 'https://example.com/stream.mp3',
          'audiodownload': 'https://example.com/download.mp3',
          'image': 'https://example.com/cover.jpg',
        }
      ]
    };

    when(() => mockClient.get(any())).thenAnswer(
      (_) async => http.Response(json.encode(mockResponse), 200),
    );

    final results = await service.searchTracks('jazz');

    expect(results.length, 1);
    expect(results.first.title, 'Test Song');
    expect(results.first.artistName, 'Test Artist');
    expect(results.first.albumName, 'Test Album');
    expect(results.first.durationSeconds, 180);
    expect(results.first.audioUrl, 'https://example.com/stream.mp3');
    expect(results.first.downloadUrl, 'https://example.com/download.mp3');
    expect(results.first.imageUrl, 'https://example.com/cover.jpg');
  });
}
