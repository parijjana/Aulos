import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:drift/native.dart';
import 'package:archive/archive.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/library/librivox_book_downloader.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/domain/network/log_service.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late LibriVoxBookDownloader downloader;
  late MockHttpClient mockClient;
  late AudiobookDatabase db;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeBaseRequest());
  });

  setUp(() async {
    mockClient = MockHttpClient();
    db = AudiobookDatabase.testing(NativeDatabase.memory());
    
    // Seed database with a root folder
    await db.into(db.audiobookFolders).insert(AudiobookFoldersCompanion.insert(
      id: 'mock_audiobooks_id',
      path: '/mock/audiobooks',
      name: 'Audiobooks',
    ));

    downloader = LibriVoxBookDownloader(
      db: db,
      client: mockClient,
      logService: NoOpLogService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LibriVoxBookDownloader Integration Tests', () {
    final book = LibriVoxBook(
      id: '123',
      title: 'Odyssey',
      description: 'Ancient Greek epic',
      urlZipFile: 'https://example.com/odyssey.zip',
      urlRss: 'https://example.com/odyssey.xml',
      authors: [LibriVoxAuthor(id: '1', firstName: 'Homer', lastName: '')],
      totalTimeSecs: 600,
      language: 'English',
      narrators: const ['John Doe'],
    );

    test('streamBook should parse RSS feed and insert stream tracks', () async {
      final rssXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Odyssey</title>
    <item>
      <title>Chapter 1</title>
      <enclosure url="https://example.com/stream/01.mp3" length="1000" type="audio/mpeg"/>
      <itunes:duration>00:10:00</itunes:duration>
    </item>
  </channel>
</rss>
''';

      when(() => mockClient.get(Uri.parse(book.urlRss)))
          .thenAnswer((_) async => http.Response(rssXml, 200));

      await downloader.streamBook(book);

      // Verify Audiobook is inserted
      final albums = await db.select(db.audiobooks).get();
      expect(albums.length, equals(1));
      expect(albums.first.name, equals('Odyssey'));
      expect(albums.first.librivoxId, equals('123'));
      expect(albums.first.isDownloadedViaAulos, isFalse);

      // Verify AudiobookTrack is inserted
      final tracks = await db.select(db.audiobookTracks).get();
      expect(tracks.length, equals(1));
      expect(tracks.first.title, equals('Chapter 1'));
      expect(tracks.first.isStream, isTrue);
      expect(tracks.first.path, equals('https://example.com/stream/01.mp3'));
      expect(tracks.first.durationSeconds, equals(600)); // 10 minutes
    });

    test('downloadBook should fetch ZIP, extract files, and insert local tracks', () async {
      // Create mock zip bytes in memory
      final archive = Archive();
      final mp3File = ArchiveFile('01_chapter1.mp3', 5, utf8.encode('dummy'));
      archive.addFile(mp3File);
      final zipBytes = ZipEncoder().encode(archive);

      // Stub client.send to return the zip bytes
      final responseStream = Stream.value(zipBytes);
      final mockResponse = http.StreamedResponse(
        responseStream,
        200,
        contentLength: zipBytes.length,
        request: http.Request('GET', Uri.parse(book.urlZipFile)),
      );

      when(() => mockClient.send(any())).thenAnswer((_) async => mockResponse);

      // Mock the RSS call which downloadBook uses to align track titles/durations
      final rssXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <item>
      <title>Chapter 1: Homeric Beginnings</title>
      <enclosure url="https://example.com/stream/01.mp3" length="1000" type="audio/mpeg"/>
      <itunes:duration 600/>
    </item>
  </channel>
</rss>
''';
      // Wait, let's fix the XML to have correct standard tag format for itunes:duration
      // The original XML:
      // <itunes:duration>600</itunes:duration>
      // My typed draft had: <itunes:duration 600/> (invalid XML)
      // Let's correct it: <itunes:duration>600</itunes:duration>
      final rssXmlCorrected = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <item>
      <title>Chapter 1: Homeric Beginnings</title>
      <enclosure url="https://example.com/stream/01.mp3" length="1000" type="audio/mpeg"/>
      <itunes:duration>600</itunes:duration>
    </item>
  </channel>
</rss>
''';
      when(() => mockClient.get(Uri.parse(book.urlRss)))
          .thenAnswer((_) async => http.Response(rssXmlCorrected, 200));

      double progressValue = 0.0;
      await downloader.downloadBook(
        book,
        onProgress: (p) => progressValue = p,
      );

      expect(progressValue, equals(1.0));

      // Verify Audiobook is marked downloaded
      final albums = await db.select(db.audiobooks).get();
      expect(albums.length, equals(1));
      expect(albums.first.isDownloadedViaAulos, isTrue);

      // Verify AudiobookTrack is pointing to local path
      final tracks = await db.select(db.audiobookTracks).get();
      expect(tracks.length, equals(1));
      expect(tracks.first.isStream, isFalse);
      expect(tracks.first.title, equals('Chapter 1: Homeric Beginnings'));
      expect(tracks.first.path, contains('01_chapter1.mp3'));
      expect(tracks.first.durationSeconds, equals(600));
    });
  });
}
