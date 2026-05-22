import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/library/radio_browser_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late RadioBrowserService service;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    // Note: service calls _resolveHost in constructor which triggers a GET
    registerFallbackValue(Uri());
    
    // Default mock for host resolution to prevent constructor failure
    when(() => mockClient.get(Uri.parse('https://all.api.radio-browser.info/json/servers')))
        .thenAnswer((_) async => http.Response(json.encode([
          {'name': 'de1.api.radio-browser.info'}
        ]), 200));

    service = RadioBrowserService(client: mockClient);
  });

  test('RadioStationResult correctly maps to RadioStation domain object', () {
    final result = RadioStationResult(
      stationuuid: 'uuid-123',
      name: 'Test FM',
      url: 'https://stream.url',
      favicon: 'https://favicon.ico',
      tags: 'rock,pop',
      country: 'Germany',
      votes: 100,
      bitrate: 128,
      codec: 'MP3',
    );

    final station = result.toStation();

    expect(station.stationUuid, 'uuid-123');
    expect(station.name, 'Test FM');
    expect(station.url, 'https://stream.url');
    expect(station.isFavorite, false);
  });

  test('getTopVoted fetches and converts stations using resolved host', () async {
    final mockStations = [
      {
        'stationuuid': 'uuid-1',
        'name': 'Top Station',
        'url_resolved': 'https://top.url',
        'votes': 500,
        'bitrate': 192,
      }
    ];

    // Wait for resolution if needed, though in this test setup it's immediate
    when(() => mockClient.get(Uri.parse('https://de1.api.radio-browser.info/json/stations/topvote/10')))
        .thenAnswer((_) async => http.Response(json.encode(mockStations), 200));

    // We manually trigger resolution again to ensure we know the host
    await service.resolveHost(); 
    
    final stations = await service.getTopVoted(10);

    expect(stations.length, 1);
    expect(stations.first.name, 'Top Station');
    expect(stations.first.url, 'https://top.url');
  });
}
