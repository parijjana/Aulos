import 'package:drift/drift.dart';
import '../app_database.dart';

part 'analytics_dao.g.dart';

@DriftAccessor(tables: [Folders, Artists, Albums, Genres, Tracks])
class AnalyticsDao extends DatabaseAccessor<AppDatabase> with _$AnalyticsDaoMixin {
  AnalyticsDao(super.db);

  // Favorites Toggles
  Future<void> setTrackFavorite(String id, bool favorite) =>
      (update(tracks)..where((t) => t.id.equals(id)))
          .write(TracksCompanion(
            isFavorite: Value(favorite),
            rating: Value(favorite ? 1 : 0),
          ));

  Future<void> setArtistFavorite(String id, bool favorite) =>
      (update(artists)..where((t) => t.id.equals(id)))
          .write(ArtistsCompanion(isFavorite: Value(favorite)));

  Future<void> setAlbumFavorite(String id, bool favorite) =>
      (update(albums)..where((t) => t.id.equals(id)))
          .write(AlbumsCompanion(isFavorite: Value(favorite)));

  // Analytics Recording
  Future<void> recordTrackPlay(String id) async {
    final track = await (select(tracks)..where((t) => t.id.equals(id))).getSingle();
    await (update(tracks)..where((t) => t.id.equals(id))).write(
      TracksCompanion(
        playCount: Value(track.playCount + 1),
        lastPlayed: Value(DateTime.now()),
      ),
    );
  }

  Future<void> recordArtistPlay(String id) async {
    final artist = await (select(artists)..where((t) => t.id.equals(id))).getSingle();
    await (update(artists)..where((t) => t.id.equals(id))).write(
      ArtistsCompanion(
        playCount: Value(artist.playCount + 1),
        lastPlayed: Value(DateTime.now()),
      ),
    );
  }

  Future<void> recordAlbumPlay(String id) async {
    final album = await (select(albums)..where((t) => t.id.equals(id))).getSingle();
    await (update(albums)..where((t) => t.id.equals(id))).write(
      AlbumsCompanion(
        playCount: Value(album.playCount + 1),
        lastPlayed: Value(DateTime.now()),
      ),
    );
  }

  // Retrieval for Analytics View
  Stream<List<Track>> watchFavoriteTracks() =>
      (select(tracks)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Artist>> watchFavoriteArtists() =>
      (select(artists)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Album>> watchFavoriteAlbums() =>
      (select(albums)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Track>> watchMostPlayedTracks({int limit = 20}) =>
      (select(tracks)
            ..where((t) => t.playCount.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
            ..limit(limit))
          .watch();
}
