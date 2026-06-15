import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:aulos/data/database/migration_worker.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/data/database/noise_database.dart';
import 'package:aulos/data/database/radio_database.dart';

void _createLegacyDatabase(File file) {
  final db = sqlite.sqlite3.open(file.path);

  // 1. podcasts
  db.execute('''
    CREATE TABLE podcasts (
      id INTEGER PRIMARY KEY,
      feed_url TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      author TEXT,
      image_url TEXT,
      image BLOB,
      subscribed_at INTEGER,
      is_favorite INTEGER,
      play_count INTEGER,
      last_played INTEGER
    );
  ''');

  // 2. episodes
  db.execute('''
    CREATE TABLE episodes (
      id INTEGER PRIMARY KEY,
      podcast_id INTEGER NOT NULL,
      guid TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      audio_url TEXT NOT NULL,
      local_file_path TEXT,
      download_state INTEGER,
      pub_date INTEGER,
      duration_seconds INTEGER,
      is_played INTEGER,
      is_pinned INTEGER,
      playback_position_seconds INTEGER,
      play_count INTEGER,
      last_played INTEGER
    );
  ''');

  // 3. bookmarks
  db.execute('''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY,
      track_path TEXT NOT NULL,
      title TEXT NOT NULL,
      start_time_ms INTEGER NOT NULL,
      end_time_ms INTEGER,
      tags TEXT,
      notes TEXT,
      context_type INTEGER,
      created_at INTEGER
    );
  ''');

  // 4. playback_positions
  db.execute('''
    CREATE TABLE playback_positions (
      track_id INTEGER PRIMARY KEY,
      position_ms INTEGER NOT NULL
    );
  ''');

  // 5. saved_mixes
  db.execute('''
    CREATE TABLE saved_mixes (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      mix_data TEXT NOT NULL,
      created_at INTEGER
    );
  ''');

  // 6. radio_listening_stats
  db.execute('''
    CREATE TABLE radio_listening_stats (
      station_uuid TEXT PRIMARY KEY,
      time_spent_seconds INTEGER NOT NULL
    );
  ''');

  // 7. folders
  db.execute('''
    CREATE TABLE folders (
      id INTEGER PRIMARY KEY,
      path TEXT NOT NULL,
      name TEXT NOT NULL,
      parent_id INTEGER,
      folder_type INTEGER
    );
  ''');

  // 8. artists
  db.execute('''
    CREATE TABLE artists (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      photo BLOB,
      bio TEXT,
      photo_url TEXT,
      is_favorite INTEGER,
      play_count INTEGER,
      last_played INTEGER
    );
  ''');

  // 9. albums
  db.execute('''
    CREATE TABLE albums (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      artist_id INTEGER,
      cover_art BLOB,
      cover_art_url TEXT,
      is_favorite INTEGER,
      play_count INTEGER,
      last_played INTEGER,
      asin TEXT,
      subtitle TEXT,
      series_name TEXT,
      series_position INTEGER,
      narrator TEXT,
      description TEXT,
      publisher TEXT,
      published_date INTEGER,
      is_played INTEGER,
      librivox_id TEXT,
      is_downloaded_via_aulos INTEGER,
      is_audiobook INTEGER
    );
  ''');

  // 10. tracks
  db.execute('''
    CREATE TABLE tracks (
      id INTEGER PRIMARY KEY,
      path TEXT NOT NULL,
      title TEXT NOT NULL,
      artist_id INTEGER,
      album_id INTEGER,
      duration_seconds INTEGER,
      rating INTEGER,
      cover_art BLOB,
      is_favorite INTEGER,
      play_count INTEGER,
      last_played INTEGER,
      is_played INTEGER,
      is_stream INTEGER,
      is_audiobook INTEGER
    );
  ''');

  // 11. chapters
  db.execute('''
    CREATE TABLE chapters (
      id INTEGER PRIMARY KEY,
      track_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      start_time_ms INTEGER NOT NULL,
      duration_ms INTEGER
    );
  ''');

  // Insert some test data
  db.execute("INSERT INTO podcasts (id, feed_url, title) VALUES (1, 'http://test.com/feed', 'Test Podcast');");
  db.execute("INSERT INTO episodes (id, podcast_id, guid, title, audio_url) VALUES (10, 1, 'guid-123', 'Test Episode', 'http://test.com/ep1.mp3');");
  db.execute("INSERT INTO bookmarks (id, track_path, title, start_time_ms) VALUES (20, 'path/to/track', 'Test Bookmark', 5000);");
  db.execute("INSERT INTO playback_positions (track_id, position_ms) VALUES (30, 15000);");
  db.execute("INSERT INTO saved_mixes (id, name, mix_data) VALUES (40, 'Test Mix', 'mix-data');");
  db.execute("INSERT INTO radio_listening_stats (station_uuid, time_spent_seconds) VALUES ('station-123', 300);");
  db.execute("INSERT INTO folders (id, path, name, folder_type) VALUES (50, 'path/to/folder', 'Test Folder', 1);");
  db.execute("INSERT INTO artists (id, name) VALUES (60, 'Test Artist');");
  db.execute("INSERT INTO albums (id, name, artist_id, is_audiobook) VALUES (70, 'Test Audiobook', 60, 1);");
  db.execute("INSERT INTO tracks (id, path, title, album_id, is_audiobook) VALUES (80, 'path/to/audiobook/track', 'Test Chapter Track', 70, 1);");
  db.execute("INSERT INTO chapters (id, track_id, title, start_time_ms) VALUES (90, 80, 'Chapter 1', 0);");

  db.dispose();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late PodcastDatabase podcastDb;
  late AudiobookDatabase audiobookDb;
  late PlaybackDatabase playbackDb;
  late NoiseDatabase noiseDb;
  late RadioDatabase radioDb;
  late DatabaseMigrationWorker worker;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('aulos_migration_test');
    
    // Mock PathProvider
    const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    podcastDb = PodcastDatabase.testing(NativeDatabase.memory());
    audiobookDb = AudiobookDatabase.testing(NativeDatabase.memory());
    playbackDb = PlaybackDatabase.testing(NativeDatabase.memory());
    noiseDb = NoiseDatabase.testing(NativeDatabase.memory());
    radioDb = RadioDatabase.testing(NativeDatabase.memory());

    worker = DatabaseMigrationWorker(
      podcastDb: podcastDb,
      audiobookDb: audiobookDb,
      playbackDb: playbackDb,
      noiseDb: noiseDb,
      radioDb: radioDb,
    );
  });

  tearDown(() async {
    await podcastDb.close();
    await audiobookDb.close();
    await playbackDb.close();
    await noiseDb.close();
    await radioDb.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('DatabaseMigrationWorker does nothing if legacy database does not exist', () async {
    // Ensure file does not exist
    final legacyFile = File(p.join(tempDir.path, 'localaudio.sqlite'));
    if (legacyFile.existsSync()) {
      legacyFile.deleteSync();
    }

    await worker.migrateIfNeeded();

    // Verify all split databases are empty
    final podcasts = await podcastDb.select(podcastDb.podcasts).get();
    expect(podcasts, isEmpty);

    final bookmarks = await playbackDb.select(playbackDb.bookmarks).get();
    expect(bookmarks, isEmpty);
  });

  test('DatabaseMigrationWorker migrates all tables correctly', () async {
    final legacyFile = File(p.join(tempDir.path, 'localaudio.sqlite'));
    _createLegacyDatabase(legacyFile);

    // Run migration
    await worker.migrateIfNeeded();

    // 1. Podcasts & Episodes
    final podcasts = await podcastDb.select(podcastDb.podcasts).get();
    expect(podcasts.length, 1);
    expect(podcasts.first.title, 'Test Podcast');
    expect(podcasts.first.feedUrl, 'http://test.com/feed');

    final episodes = await podcastDb.select(podcastDb.episodes).get();
    expect(episodes.length, 1);
    expect(episodes.first.title, 'Test Episode');
    expect(episodes.first.podcastId, '1');

    // 2. Playback Positions & Bookmarks
    final bookmarks = await playbackDb.select(playbackDb.bookmarks).get();
    expect(bookmarks.length, 1);
    expect(bookmarks.first.title, 'Test Bookmark');
    expect(bookmarks.first.trackPath, 'path/to/track');

    final playbackPosition = await playbackDb.getPlaybackPosition('30');
    expect(playbackPosition?.positionMs, 15000);

    // 3. Saved Mixes
    final mixes = await noiseDb.select(noiseDb.savedMixes).get();
    expect(mixes.length, 1);
    expect(mixes.first.name, 'Test Mix');
    expect(mixes.first.mixData, 'mix-data');

    // 4. Radio Listening Stats
    final radioStats = await radioDb.select(radioDb.radioListeningStats).get();
    expect(radioStats.length, 1);
    expect(radioStats.first.stationUuid, 'station-123');

    // 5. Audiobooks, Folders, Chapters, Tracks, Artists
    final audiobookFolders = await audiobookDb.select(audiobookDb.audiobookFolders).get();
    expect(audiobookFolders.length, 1);
    expect(audiobookFolders.first.path, 'path/to/folder');

    final audiobookArtists = await audiobookDb.select(audiobookDb.audiobookArtists).get();
    expect(audiobookArtists.length, 1);
    expect(audiobookArtists.first.name, 'Test Artist');

    final audiobooks = await audiobookDb.select(audiobookDb.audiobooks).get();
    expect(audiobooks.length, 1);
    expect(audiobooks.first.name, 'Test Audiobook');

    final audiobookTracks = await audiobookDb.select(audiobookDb.audiobookTracks).get();
    expect(audiobookTracks.length, 1);
    expect(audiobookTracks.first.title, 'Test Chapter Track');

    final audiobookChapters = await audiobookDb.select(audiobookDb.audiobookChapters).get();
    expect(audiobookChapters.length, 1);
    expect(audiobookChapters.first.title, 'Chapter 1');
  });
}
