import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/library/rss_podcast_service.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late AppDatabase database;
  late RssPodcastService service;
  late MockHttpClient mockClient;

  setUp(() {
    database = AppDatabase.testing(NativeDatabase.memory());
    mockClient = MockHttpClient();
    service = RssPodcastService(db: database, client: mockClient);
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  tearDown(() async {
    await database.close();
  });

  const sampleRss = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast description</description>
    <itunes:author>Test Author</itunes:author>
    <item>
      <title>Episode 1</title>
      <enclosure url="http://example.com/ep1.mp3" type="audio/mpeg" />
      <pubDate>Mon, 01 Jan 2026 00:00:00 GMT</pubDate>
      <itunes:duration>00:30:00</itunes:duration>
      <guid>ep1</guid>
    </item>
  </channel>
</rss>
''';

  test('Subscribing to a feed should add podcast and episodes to database', () async {
    when(() => mockClient.get(any())).thenAnswer((_) async => http.Response(sampleRss, 200));

    final podcast = await service.subscribeToFeed('http://example.com/rss');

    expect(podcast.title, 'Test Podcast');
    expect(podcast.author, 'Test Author');

    final episodes = await service.getEpisodes(podcast.id);
    expect(episodes.length, 1);
    expect(episodes.first.title, 'Episode 1');
    expect(episodes.first.durationSeconds, 1800);
  });
}
