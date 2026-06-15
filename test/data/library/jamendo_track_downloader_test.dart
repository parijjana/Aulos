import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/library/jamendo_track_downloader.dart';
import 'package:aulos/domain/library/jamendo_track.dart';
import 'package:aulos/domain/network/log_service.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late JamendoTrackDownloader downloader;
  late MockHttpClient mockClient;
  late AppDatabase db;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeBaseRequest());
  });

  setUp(() async {
    mockClient = MockHttpClient();
    db = AppDatabase.testing(NativeDatabase.memory());
    
    // Seed database with a root folder for Music
    await db.into(db.folders).insert(FoldersCompanion.insert(
      id: 'mock_music_id',
      path: '/mock/music',
      name: 'Music',
      folderType: const Value(0),
    ));

    downloader = JamendoTrackDownloader(
      db: db,
      client: mockClient,
      logService: NoOpLogService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('JamendoTrackDownloader Integration Tests', () {
    final trackData = JamendoTrack(
      id: '999',
      title: 'Jamendo Hit',
      artistName: 'Awesome Band',
      albumName: 'Cool Album',
      durationSeconds: 180,
      audioUrl: 'https://example.com/audio.mp3',
      downloadUrl: 'https://example.com/download.mp3',
      imageUrl: 'https://example.com/art.jpg',
    );

    test('streamTrack should insert stream tracks', () async {
      final track = await downloader.streamTrack(trackData);

      expect(track.title, equals('Jamendo Hit'));
      expect(track.isStream, isTrue);
      expect(track.path, equals('https://example.com/audio.mp3'));

      // Verify Track is saved in DB
      final dbTracks = await db.select(db.tracks).get();
      expect(dbTracks.length, equals(1));
      expect(dbTracks.first.title, equals('Jamendo Hit'));
    });

    test('downloadTrack should fetch MP3, save locally, and update database track', () async {
      // Mock streamTrack first so we test the path-update path
      await downloader.streamTrack(trackData);

      final mp3Bytes = utf8.encode('mockmp3');
      final responseStream = Stream.value(mp3Bytes);
      final mockResponse = http.StreamedResponse(
        responseStream,
        200,
        contentLength: mp3Bytes.length,
        request: http.Request('GET', Uri.parse(trackData.downloadUrl)),
      );

      when(() => mockClient.send(any())).thenAnswer((_) async => mockResponse);

      double progressVal = 0.0;
      final track = await downloader.downloadTrack(
        trackData,
        onProgress: (p) => progressVal = p,
      );

      expect(progressVal, equals(1.0));
      expect(track.isStream, isFalse);
      expect(track.path, contains('Jamendo Hit.mp3'));

      // Verify db updated
      final dbTracks = await db.select(db.tracks).get();
      expect(dbTracks.length, equals(1));
      expect(dbTracks.first.isStream, isFalse);
      expect(dbTracks.first.path, contains('Jamendo Hit.mp3'));
    });
  });
}
