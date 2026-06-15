import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'podcast_database.dart';
import 'audiobook_database.dart';
import 'playback_database.dart';
import 'noise_database.dart';
import 'radio_database.dart';

class _MigrationDbUser extends QueryExecutorUser {
  Future<void> onCreate(QueryExecutor executor) async {}

  Future<void> onUpgrade(QueryExecutor executor, int from, int to) async {}

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}

  @override
  int get schemaVersion => 1;
}

class DatabaseMigrationWorker {
  final PodcastDatabase podcastDb;
  final AudiobookDatabase audiobookDb;
  final PlaybackDatabase playbackDb;
  final NoiseDatabase noiseDb;
  final RadioDatabase radioDb;

  DatabaseMigrationWorker({
    required this.podcastDb,
    required this.audiobookDb,
    required this.playbackDb,
    required this.noiseDb,
    required this.radioDb,
  });

  Future<void> migrateIfNeeded() async {
    final docDir = await getApplicationDocumentsDirectory();
    final legacyFile = File(p.join(docDir.path, 'localaudio.sqlite'));
    if (!await legacyFile.exists()) {
      return;
    }

    final executor = NativeDatabase(legacyFile);

    try {
      await executor.ensureOpen(_MigrationDbUser());
      // Check if the legacy database contains the 'podcasts' table
      final checkTable = await executor.runSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='podcasts';",
        const [],
      );
      if (checkTable.isEmpty) {
        await executor.close();
        return;
      }

      print('Starting Database Migration...');

      // 1. Podcasts & Episodes
      final podcasts = await executor.runSelect('SELECT * FROM podcasts;', const []);
      final episodes = await executor.runSelect('SELECT * FROM episodes;', const []);
      await podcastDb.transaction(() async {
        for (final row in podcasts) {
          await podcastDb.into(podcastDb.podcasts).insert(
            PodcastsCompanion(
              id: Value((row['id'] as int).toString()),
              feedUrl: Value(row['feed_url'] as String),
              title: Value(row['title'] as String),
              description: Value(row['description'] as String?),
              author: Value(row['author'] as String?),
              imageUrl: Value(row['image_url'] as String?),
              image: Value(row['image'] as Uint8List?),
              subscribedAt: Value(_parseDateTime(row['subscribed_at']) ?? DateTime.now()),
              isFavorite: Value(_parseBool(row['is_favorite'])),
              playCount: Value(row['play_count'] as int? ?? 0),
              lastPlayed: Value(_parseDateTime(row['last_played'])),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        for (final row in episodes) {
          await podcastDb.into(podcastDb.episodes).insert(
            EpisodesCompanion(
              id: Value((row['id'] as int).toString()),
              podcastId: Value((row['podcast_id'] as int).toString()),
              guid: Value(row['guid'] as String),
              title: Value(row['title'] as String),
              description: Value(row['description'] as String?),
              audioUrl: Value(row['audio_url'] as String),
              localFilePath: Value(row['local_file_path'] as String?),
              downloadState: Value(row['download_state'] as int? ?? 0),
              pubDate: Value(_parseDateTime(row['pub_date'])),
              durationSeconds: Value(row['duration_seconds'] as int?),
              isPlayed: Value(_parseBool(row['is_played'])),
              isPinned: Value(_parseBool(row['is_pinned'])),
              playbackPositionSeconds: Value(row['playback_position_seconds'] as int? ?? 0),
              playCount: Value(row['play_count'] as int? ?? 0),
              lastPlayed: Value(_parseDateTime(row['last_played'])),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });

      // 2. Playback Positions & Bookmarks
      final bookmarks = await executor.runSelect('SELECT * FROM bookmarks;', const []);
      final playbackPositions = await executor.runSelect('SELECT * FROM playback_positions;', const []);
      await playbackDb.transaction(() async {
        for (final row in bookmarks) {
          await playbackDb.into(playbackDb.bookmarks).insert(
            BookmarksCompanion(
              id: Value((row['id'] as int).toString()),
              trackPath: Value(row['track_path'] as String),
              title: Value(row['title'] as String),
              startTimeMs: Value(row['start_time_ms'] as int),
              endTimeMs: Value(row['end_time_ms'] as int?),
              tags: Value(row['tags'] as String?),
              notes: Value(row['notes'] as String?),
              contextType: Value(row['context_type'] as int? ?? 0),
              createdAt: Value(_parseDateTime(row['created_at']) ?? DateTime.now()),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        for (final row in playbackPositions) {
          await playbackDb.savePlaybackPosition(
            (row['track_id'] as int).toString(),
            row['position_ms'] as int,
          );
        }
      });

      // 3. Saved Mixes
      final savedMixes = await executor.runSelect('SELECT * FROM saved_mixes;', const []);
      await noiseDb.transaction(() async {
        for (final row in savedMixes) {
          await noiseDb.into(noiseDb.savedMixes).insert(
            SavedMixesCompanion(
              id: Value((row['id'] as int).toString()),
              name: Value(row['name'] as String),
              mixData: Value(row['mix_data'] as String),
              createdAt: Value(_parseDateTime(row['created_at']) ?? DateTime.now()),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });

      // 4. Radio Listening Stats
      final radioStats = await executor.runSelect('SELECT * FROM radio_listening_stats;', const []);
      await radioDb.transaction(() async {
        for (final row in radioStats) {
          await radioDb.recordRadioListen(
            row['station_uuid'] as String,
            row['time_spent_seconds'] as int,
          );
        }
      });

      // 5. Audiobooks
      final folders = await executor.runSelect('SELECT * FROM folders WHERE folder_type = 1;', const []);
      final audiobookArtists = await executor.runSelect(
        'SELECT * FROM artists WHERE id IN (SELECT artist_id FROM albums WHERE is_audiobook = 1) OR id IN (SELECT artist_id FROM tracks WHERE is_audiobook = 1);',
        const [],
      );
      final audiobooks = await executor.runSelect('SELECT * FROM albums WHERE is_audiobook = 1;', const []);
      final audiobookTracks = await executor.runSelect('SELECT * FROM tracks WHERE is_audiobook = 1;', const []);
      final chapters = await executor.runSelect(
        'SELECT * FROM chapters WHERE track_id IN (SELECT id FROM tracks WHERE is_audiobook = 1);',
        const [],
      );

      await audiobookDb.transaction(() async {
        for (final row in folders) {
          await audiobookDb.into(audiobookDb.audiobookFolders).insert(
            AudiobookFoldersCompanion(
              id: Value((row['id'] as int).toString()),
              path: Value(row['path'] as String),
              name: Value(row['name'] as String),
              parentId: Value(row['parent_id'] != null ? (row['parent_id'] as int).toString() : null),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        for (final row in audiobookArtists) {
          await audiobookDb.into(audiobookDb.audiobookArtists).insert(
            AudiobookArtistsCompanion(
              id: Value((row['id'] as int).toString()),
              name: Value(row['name'] as String),
              photo: Value(row['photo'] as Uint8List?),
              bio: Value(row['bio'] as String?),
              photoUrl: Value(row['photo_url'] as String?),
              isFavorite: Value(_parseBool(row['is_favorite'])),
              playCount: Value(row['play_count'] as int? ?? 0),
              lastPlayed: Value(_parseDateTime(row['last_played'])),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        for (final row in audiobooks) {
          await audiobookDb.into(audiobookDb.audiobooks).insert(
            AudiobooksCompanion(
              id: Value((row['id'] as int).toString()),
              name: Value(row['name'] as String),
              artistId: Value(row['artist_id'] != null ? (row['artist_id'] as int).toString() : null),
              coverArt: Value(row['cover_art'] as Uint8List?),
              coverArtUrl: Value(row['cover_art_url'] as String?),
              isFavorite: Value(_parseBool(row['is_favorite'])),
              playCount: Value(row['play_count'] as int? ?? 0),
              lastPlayed: Value(_parseDateTime(row['last_played'])),
              asin: Value(row['asin'] as String?),
              subtitle: Value(row['subtitle'] as String?),
              seriesName: Value(row['series_name'] as String?),
              seriesPosition: Value(row['series_position'] as int?),
              narrator: Value(row['narrator'] as String?),
              description: Value(row['description'] as String?),
              publisher: Value(row['publisher'] as String?),
              publishedDate: Value(_parseDateTime(row['published_date'])),
              isPlayed: Value(_parseBool(row['is_played'])),
              librivoxId: Value(row['librivox_id'] as String?),
              isDownloadedViaAulos: Value(_parseBool(row['is_downloaded_via_aulos'])),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        for (final row in audiobookTracks) {
          await audiobookDb.into(audiobookDb.audiobookTracks).insert(
            AudiobookTracksCompanion(
              id: Value((row['id'] as int).toString()),
              path: Value(row['path'] as String),
              title: Value(row['title'] as String),
              artistId: Value(row['artist_id'] != null ? (row['artist_id'] as int).toString() : null),
              audiobookId: Value(row['album_id'] != null ? (row['album_id'] as int).toString() : null),
              durationSeconds: Value(row['duration_seconds'] as int?),
              rating: Value(row['rating'] as int? ?? 0),
              coverArt: Value(row['cover_art'] as Uint8List?),
              isFavorite: Value(_parseBool(row['is_favorite'])),
              playCount: Value(row['play_count'] as int? ?? 0),
              lastPlayed: Value(_parseDateTime(row['last_played'])),
              isPlayed: Value(_parseBool(row['is_played'])),
              isStream: Value(_parseBool(row['is_stream'])),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }

        for (final row in chapters) {
          await audiobookDb.into(audiobookDb.audiobookChapters).insert(
            AudiobookChaptersCompanion(
              id: Value((row['id'] as int).toString()),
              audiobookTrackId: Value((row['track_id'] as int).toString()),
              title: Value(row['title'] as String),
              startTimeMs: Value(row['start_time_ms'] as int),
              durationMs: Value(row['duration_ms'] as int?),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });

      print('Database Migration Completed Successfully.');
    } catch (e, stack) {
      print('Database Migration Failed: $e');
      print(stack);
    } finally {
      await executor.close();
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      if (value < 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}
