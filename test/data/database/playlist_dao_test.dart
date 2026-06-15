import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:aulos/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.testing(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('PlaylistDao Smart Playlists', () {
    test('getAllPlaylists should auto-populate default smart playlists', () async {
      var playlists = await db.getAllPlaylists();
      expect(playlists.any((p) => p.name == 'Likes' && p.isSmart), isTrue);
      expect(playlists.any((p) => p.name == 'Dislikes' && p.isSmart), isTrue);
      expect(playlists.any((p) => p.name == 'Recently Played' && p.isSmart), isTrue);
      expect(playlists.any((p) => p.name == 'Most Played' && p.isSmart), isTrue);
      expect(playlists.any((p) => p.name == 'Recently Added' && p.isSmart), isTrue);
    });

    test('getTracksForPlaylist should fetch tracks matching smart playlist criteria', () async {
      final folderId = await db.ensureFolder('/music');
      final artistId = await db.ensureArtist('Artist');
      final albumId = await db.ensureAlbum('Album', artistId);

      await db.addTracks([
        TracksCompanion.insert(
          id: '1',
          path: 'song1.mp3',
          title: 'Song 1',
          folderId: folderId,
          artistId: Value(artistId),
          albumId: Value(albumId),
          isFavorite: const Value(true),
          playCount: const Value(5),
          lastPlayed: Value(DateTime.now().subtract(const Duration(minutes: 10))),
        ),
        TracksCompanion.insert(
          id: '2',
          path: 'song2.mp3',
          title: 'Song 2',
          folderId: folderId,
          artistId: Value(artistId),
          albumId: Value(albumId),
          isFavorite: const Value(false),
          playCount: const Value(1),
          lastPlayed: Value(DateTime.now().subtract(const Duration(hours: 1))),
        ),
      ]);

      final allPlaylists = await db.getAllPlaylists();
      
      final likesPlaylist = allPlaylists.firstWhere((p) => p.name == 'Likes');
      final likesTracks = await db.getTracksForPlaylist(likesPlaylist.id);
      expect(likesTracks.length, 1);
      expect(likesTracks[0].title, 'Song 1');

      final recentPlaylist = allPlaylists.firstWhere((p) => p.name == 'Recently Played');
      final recentTracks = await db.getTracksForPlaylist(recentPlaylist.id);
      expect(recentTracks.length, 2);
      expect(recentTracks[0].title, 'Song 1');
      expect(recentTracks[1].title, 'Song 2');

      final mostPlaylist = allPlaylists.firstWhere((p) => p.name == 'Most Played');
      final mostTracks = await db.getTracksForPlaylist(mostPlaylist.id);
      expect(mostTracks.length, 2);
      expect(mostTracks[0].title, 'Song 1');
      expect(mostTracks[1].title, 'Song 2');

      final addedPlaylist = allPlaylists.firstWhere((p) => p.name == 'Recently Added');
      final addedTracks = await db.getTracksForPlaylist(addedPlaylist.id);
      expect(addedTracks.length, 2);
      expect(addedTracks[0].title, 'Song 2');
      expect(addedTracks[1].title, 'Song 1');
    });

    test('updateTrackRating and setTrackFavorite should sync rating and isFavorite', () async {
      final folderId = await db.ensureFolder('/music');
      final artistId = await db.ensureArtist('Artist');
      final albumId = await db.ensureAlbum('Album', artistId);

      const trackId = 'song';
      await db.into(db.tracks).insert(
        TracksCompanion.insert(
          id: trackId,
          path: 'song.mp3',
          title: 'Song',
          folderId: folderId,
          artistId: Value(artistId),
          albumId: Value(albumId),
        ),
      );

      // 1. Rate as 1 (favorite) -> should set isFavorite = true
      await db.updateTrackRating(trackId, 1);
      var track = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
      expect(track.rating, 1);
      expect(track.isFavorite, true);

      // 2. Rate as -1 (dislike) -> should set isFavorite = false
      await db.updateTrackRating(trackId, -1);
      track = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
      expect(track.rating, -1);
      expect(track.isFavorite, false);

      // 3. setTrackFavorite(true) -> should set rating = 1
      await db.setTrackFavorite(trackId, true);
      track = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
      expect(track.rating, 1);
      expect(track.isFavorite, true);

      // 4. setTrackFavorite(false) -> should set rating = 0
      await db.setTrackFavorite(trackId, false);
      track = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
      expect(track.rating, 0);
      expect(track.isFavorite, false);
    });
  });
}
