import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/data/library/rss_podcast_service.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late PodcastDatabase database;
  late PlaybackDatabase playbackDb;
  late RssPodcastService service;
  late MockHttpClient mockClient;

  setUp(() {
    database = PodcastDatabase.testing(NativeDatabase.memory());
    playbackDb = PlaybackDatabase.testing(NativeDatabase.memory());
    mockClient = MockHttpClient();
    service = RssPodcastService(
      db: database,
      playbackDb: playbackDb,
      client: mockClient,
    );
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  tearDown(() async {
    await database.close();
    await playbackDb.close();
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

  test('Sync should update pubDate on conflict (DO UPDATE) while preserving user play state', () async {
    // 1. Setup mock RSS response
    when(() => mockClient.get(any())).thenAnswer((_) async => http.Response(sampleRss, 200));

    // 2. Subscribe to create the database entries
    final podcast = await service.subscribeToFeed('http://example.com/rss');
    var episodes = await service.getEpisodes(podcast.id);
    expect(episodes.first.pubDate, isNotNull); // Initially parsed

    // 3. Manually update pubDate to null and isPlayed to true in database to simulate old state
    await database.updateEpisodePlayback(episodes.first.id, isPlayed: true);
    // Since we don't have a direct method to set pubDate to null in the DAO, we write a raw update
    await database.customStatement('UPDATE episodes SET pub_date = NULL WHERE id = ?', [episodes.first.id]);

    // Verify it is indeed null and isPlayed is true
    episodes = await service.getEpisodes(podcast.id);
    expect(episodes.first.pubDate, isNull);
    expect(episodes.first.isPlayed, isTrue);

    // 4. Trigger refresh feed
    await service.refreshPodcast(podcast.id);

    // 5. Verify date is updated while isPlayed is preserved!
    episodes = await service.getEpisodes(podcast.id);
    expect(episodes.first.pubDate, isNotNull);
    expect(episodes.first.isPlayed, isTrue);
  });
}
