import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'playback_database.g.dart';

@DriftDatabase(tables: [Bookmarks, PlaybackPositions])
class PlaybackDatabase extends _$PlaybackDatabase {
  PlaybackDatabase() : super(_openConnection());
  PlaybackDatabase.testing(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      }
    },
  );

  // Playback Positions CRUD
  Future<void> savePlaybackPosition(String trackId, int positionMs) {
    return into(playbackPositions).insert(
      PlaybackPositionsCompanion(
        trackId: Value(trackId),
        positionMs: Value(positionMs),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<PlaybackPosition?> getPlaybackPosition(String trackId) {
    return (select(playbackPositions)..where((t) => t.trackId.equals(trackId)))
        .getSingleOrNull();
  }

  Future<void> deletePlaybackPosition(String trackId) {
    return (delete(playbackPositions)..where((t) => t.trackId.equals(trackId))).go();
  }

  // Bookmarks CRUD
  Future<void> saveBookmark(BookmarksCompanion companion) => into(bookmarks).insert(companion);
  
  Future<List<Bookmark>> getBookmarksForTrack(String path) =>
      (select(bookmarks)..where((t) => t.trackPath.equals(path))).get();

  Future<List<Bookmark>> getPodcastBookmarks() =>
      (select(bookmarks)..where((t) => t.contextType.equals(1))).get();

  Future<List<Bookmark>> getAudiobookBookmarks() =>
      (select(bookmarks)..where((t) => t.contextType.equals(2))).get();

  Stream<List<Bookmark>> watchAudiobookBookmarks() =>
      (select(bookmarks)..where((t) => t.contextType.equals(2))).watch();

  Stream<List<Bookmark>> watchPodcastBookmarks() =>
      (select(bookmarks)..where((t) => t.contextType.equals(1))).watch();

  Stream<List<Bookmark>> watchAudiobookBookmarksForTrack(String trackPath) {
    return (select(bookmarks)
          ..where((t) => t.trackPath.equals(trackPath) & t.contextType.equals(2)))
        .watch();
  }

  Stream<List<Bookmark>> watchBookmarksForTrack(String trackPath) {
    return (select(bookmarks)..where((t) => t.trackPath.equals(trackPath))).watch();
  }

  Future<void> deleteBookmark(String id) =>
      (delete(bookmarks)..where((t) => t.id.equals(id))).go();

  Future<void> deleteBookmarksForTrack(String path) =>
      (delete(bookmarks)..where((t) => t.trackPath.equals(path))).go();

  Future<void> updateBookmarkPaths(String oldPath, String newPath) {
    return (update(bookmarks)..where((t) => t.trackPath.equals(oldPath)))
        .write(BookmarksCompanion(trackPath: Value(newPath)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'playback_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
