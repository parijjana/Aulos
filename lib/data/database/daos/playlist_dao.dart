import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../core/utils/id_generator.dart';

part 'playlist_dao.g.dart';

@DriftAccessor(tables: [Playlists, PlaylistTracks, QueueTracks, Tracks])
class PlaylistDao extends DatabaseAccessor<AppDatabase> with _$PlaylistDaoMixin {
  PlaylistDao(AppDatabase db) : super(db);

  Future<List<Playlist>> getAllPlaylists() async {
    final list = await select(playlists).get();
    final defaultSmartNames = [
      'Likes',
      'Dislikes',
      'Recently Played',
      'Most Played',
      'Recently Added'
    ];
    final existingNames = list.map((p) => p.name).toSet();

    bool addedAny = false;
    for (final name in defaultSmartNames) {
      if (!existingNames.contains(name)) {
        final generatedId = generateContentId(name);
        await into(playlists).insert(
          PlaylistsCompanion.insert(
            id: generatedId,
            name: name,
            isSmart: const Value(true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        addedAny = true;
      }
    }

    if (addedAny) {
      return select(playlists).get();
    }
    return list;
  }

  Future<void> deletePlaylist(String id) =>
      (delete(playlists)..where((p) => p.id.equals(id))).go();

  Future<void> savePlaylistWithTracks(
    String name,
    List<String> trackIds, {
    bool isSmart = false,
  }) async {
    await transaction(() async {
      final existing = await (select(playlists)..where((p) => p.name.equals(name))).getSingleOrNull();
      String id;
      if (existing != null) {
        id = existing.id;
      } else {
        id = generateContentId("$name|${DateTime.now().millisecondsSinceEpoch}");
        await into(playlists).insert(
          PlaylistsCompanion.insert(
            id: id,
            name: name,
            isSmart: Value(isSmart),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
      
      await (delete(playlistTracks)..where((pt) => pt.playlistId.equals(id))).go();
      for (int i = 0; i < trackIds.length; i++) {
        await into(playlistTracks).insert(
          PlaylistTracksCompanion.insert(
            playlistId: id,
            trackId: trackIds[i],
            position: i,
          ),
        );
      }
    });
  }

  Future<List<Track>> getTracksForPlaylist(String playlistId) async {
    final playlist = await (select(playlists)..where((t) => t.id.equals(playlistId))).getSingleOrNull();
    if (playlist != null && playlist.isSmart) {
      if (playlist.name == 'Likes') {
        return (select(tracks)..where((t) => t.isFavorite.equals(true))).get();
      } else if (playlist.name == 'Dislikes') {
        return (select(tracks)..where((t) => t.rating.equals(-1))).get();
      } else if (playlist.name == 'Recently Played') {
        return (select(tracks)
          ..where((t) => t.lastPlayed.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.lastPlayed)])
          ..limit(50)
        ).get();
      } else if (playlist.name == 'Most Played') {
        return (select(tracks)
          ..where((t) => t.playCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
          ..limit(50)
        ).get();
      } else if (playlist.name == 'Recently Added') {
        return (select(tracks)
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(50)
        ).get();
      }
    }

    final query = select(playlistTracks).join([
      innerJoin(tracks, tracks.id.equalsExp(playlistTracks.trackId)),
    ])
      ..where(playlistTracks.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistTracks.position)]);

    final result = await query.get();
    return result.map((row) => row.readTable(tracks)).toList();
  }

  Future<void> clearQueue() => delete(queueTracks).go();
  
  Future<void> saveQueue(List<String> trackIds) async {
    await transaction(() async {
      await clearQueue();
      for (int i = 0; i < trackIds.length; i++) {
        final queueTrackId = generateContentId("${trackIds[i]}|$i|${DateTime.now().millisecondsSinceEpoch}");
        await into(queueTracks).insert(
          QueueTracksCompanion.insert(
            id: queueTrackId,
            trackId: trackIds[i],
            position: i,
          ),
        );
      }
    });
  }

  Future<List<Track>> getQueue() async {
    final query = select(queueTracks).join([
      innerJoin(tracks, tracks.id.equalsExp(queueTracks.trackId)),
    ])..orderBy([OrderingTerm.asc(queueTracks.position)]);

    final result = await query.get();
    return result.map((row) => row.readTable(tracks)).toList();
  }
}
