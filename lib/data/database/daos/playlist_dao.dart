import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'playlist_dao.g.dart';

@DriftAccessor(tables: [Playlists, PlaylistTracks, QueueTracks, Tracks])
class PlaylistDao extends DatabaseAccessor<AppDatabase> with _$PlaylistDaoMixin {
  PlaylistDao(AppDatabase db) : super(db);

  Future<List<Playlist>> getAllPlaylists() => select(playlists).get();

  Future<void> deletePlaylist(int id) =>
      (delete(playlists)..where((p) => p.id.equals(id))).go();

  Future<void> savePlaylistWithTracks(
    String name,
    List<int> trackIds, {
    bool isSmart = false,
  }) async {
    await transaction(() async {
      final id = await into(playlists).insert(
        PlaylistsCompanion.insert(name: name, isSmart: Value(isSmart)),
        mode: InsertMode.insertOrIgnore,
      );
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

  Future<List<Track>> getTracksForPlaylist(int playlistId) async {
    final playlist = await (select(playlists)..where((t) => t.id.equals(playlistId))).getSingleOrNull();
    if (playlist != null && playlist.isSmart) {
      if (playlist.name == 'Likes') {
        return (select(tracks)..where((t) => t.isFavorite.equals(true))).get();
      } else if (playlist.name == 'Dislikes') {
        return (select(tracks)..where((t) => t.rating.equals(-1))).get();
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
  
  Future<void> saveQueue(List<int> trackIds) async {
    await transaction(() async {
      await clearQueue();
      for (int i = 0; i < trackIds.length; i++) {
        await into(queueTracks).insert(
          QueueTracksCompanion.insert(trackId: trackIds[i], position: i),
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
