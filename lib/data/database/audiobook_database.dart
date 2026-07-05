import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import '../../../core/utils/id_generator.dart';

part 'audiobook_database.g.dart';

@DriftDatabase(tables: [AudiobookFolders, AudiobookArtists, Audiobooks, AudiobookTracks, AudiobookChapters])
class AudiobookDatabase extends _$AudiobookDatabase {
  AudiobookDatabase([String? basePath]) : super(_openConnection(basePath));
  AudiobookDatabase.testing(QueryExecutor e) : super(e);

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

  // Folder Operations
  Future<void> addFolder(AudiobookFoldersCompanion folder) =>
      into(audiobookFolders).insert(folder, mode: InsertMode.insertOrIgnore);
      
  Future<List<AudiobookFolder>> getAllFolders() => select(audiobookFolders).get();
  
  Future<List<AudiobookFolder>> getRootFolders() =>
      (select(audiobookFolders)..where((f) => f.parentId.isNull())).get();
      
  Future<List<AudiobookFolder>> getSubFolders(String parentId) =>
      (select(audiobookFolders)..where((f) => f.parentId.equals(parentId))).get();

  Future<String> ensureFolder(String path, {String? parentId}) async {
    final folderName = p.basename(path);
    final fingerprint = "${parentId ?? ''}|$folderName";
    final generatedId = generateContentId(fingerprint);

    final existing = await (select(audiobookFolders)..where((f) => f.id.equals(generatedId))).getSingleOrNull();
    if (existing != null) return existing.id;

    await into(audiobookFolders).insert(
      AudiobookFoldersCompanion.insert(
        id: generatedId,
        path: path,
        name: folderName,
        parentId: Value(parentId),
      ),
    );
    return generatedId;
  }

  // Metadata Operations
  Future<String> ensureArtist(String name) async {
    final generatedId = generateContentId(name);
    final existing = await (select(audiobookArtists)..where((a) => a.id.equals(generatedId))).getSingleOrNull();
    if (existing != null) return existing.id;
    
    await into(audiobookArtists).insert(
      AudiobookArtistsCompanion.insert(
        id: generatedId,
        name: name,
      ),
    );
    return generatedId;
  }

  Future<String> ensureAudiobook(String name, String? artistId, {Uint8List? coverArt}) async {
    final fingerprint = "${artistId ?? ''}|$name";
    final generatedId = generateContentId(fingerprint);

    final existing = await (select(audiobooks)..where((a) => a.id.equals(generatedId))).getSingleOrNull();

    if (existing != null) {
      if (existing.coverArt == null && coverArt != null) {
        await (update(audiobooks)..where((a) => a.id.equals(existing.id))).write(
          AudiobooksCompanion(coverArt: Value(coverArt)),
        );
      }
      return existing.id;
    }

    await into(audiobooks).insert(
      AudiobooksCompanion.insert(
        id: generatedId,
        name: name,
        artistId: Value(artistId),
        coverArt: Value(coverArt),
      ),
    );
    return generatedId;
  }

  Future<List<AudiobookArtist>> getAllArtists() => select(audiobookArtists).get();
  Future<List<Audiobook>> getAudiobooks() => select(audiobooks).get();

  Future<Audiobook?> getAudiobookById(String id) =>
      (select(audiobooks)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<AudiobookTrack?> getTrackById(String id) =>
      (select(audiobookTracks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<AudiobookTrack>> getTracksForArtist(String artistId) =>
      (select(audiobookTracks)..where((t) => t.artistId.equals(artistId))).get();

  Future<List<AudiobookTrack>> getTracksForBook(String bookId) =>
      (select(audiobookTracks)..where((t) => t.audiobookId.equals(bookId))).get();

  Future<void> updateAudiobookArt(String bookId, Uint8List art) {
    return (update(audiobooks)..where((a) => a.id.equals(bookId))).write(
      AudiobooksCompanion(coverArt: Value(art)),
    );
  }

  Future<void> updateArtistPhoto(String artistId, Uint8List photo) {
    return (update(audiobookArtists)..where((a) => a.id.equals(artistId))).write(
      AudiobookArtistsCompanion(photo: Value(photo)),
    );
  }

  Future<void> updateTrackArt(String trackId, Uint8List art) {
    return (update(audiobookTracks)..where((t) => t.id.equals(trackId))).write(
      AudiobookTracksCompanion(coverArt: Value(art)),
    );
  }

  Future<void> addTracks(List<AudiobookTracksCompanion> companions) async {
    await batch((batch) {
      batch.insertAll(audiobookTracks, companions, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<AudiobookTrack>> getTracksForFolder(String folderId) =>
      (select(audiobookTracks)..where((t) => t.audiobookId.isNotNull())).get();

  Future<List<AudiobookTrack>> getAllTracks() => select(audiobookTracks).get();

  // Chapter Operations
  Future<void> addChapters(List<AudiobookChaptersCompanion> companions) async {
    await batch((b) {
      b.insertAll(audiobookChapters, companions, mode: InsertMode.insertOrReplace);
    });
  }

  Future<List<AudiobookChapter>> getChaptersForTrack(String trackId) =>
      (select(audiobookChapters)..where((c) => c.audiobookTrackId.equals(trackId))).get();
}

LazyDatabase _openConnection(String? basePath) {
  return LazyDatabase(() async {
    final path = basePath ?? (await getApplicationSupportDirectory()).path;
    final file = File(p.join(path, 'audiobook_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
