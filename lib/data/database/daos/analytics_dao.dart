import 'package:drift/drift.dart';
import '../app_database.dart';

part 'analytics_dao.g.dart';

@DriftAccessor(tables: [Tracks, Artists, Albums, Podcasts, Episodes, RadioListeningStats])
class AnalyticsDao extends DatabaseAccessor<AppDatabase> with _$AnalyticsDaoMixin {
  AnalyticsDao(super.db);

  // Favorites Toggles
  Future<void> setTrackFavorite(int id, bool favorite) =>
      (update(tracks)..where((t) => t.id.equals(id)))
          .write(TracksCompanion(isFavorite: Value(favorite)));

  Future<void> setArtistFavorite(int id, bool favorite) =>
      (update(artists)..where((t) => t.id.equals(id)))
          .write(ArtistsCompanion(isFavorite: Value(favorite)));

  Future<void> setAlbumFavorite(int id, bool favorite) =>
      (update(albums)..where((t) => t.id.equals(id)))
          .write(AlbumsCompanion(isFavorite: Value(favorite)));

  Future<void> setPodcastFavorite(int id, bool favorite) =>
      (update(podcasts)..where((t) => t.id.equals(id)))
          .write(PodcastsCompanion(isFavorite: Value(favorite)));

  // Analytics Recording
  Future<void> recordTrackPlay(int id) async {
    final track = await (select(tracks)..where((t) => t.id.equals(id))).getSingle();
    await (update(tracks)..where((t) => t.id.equals(id))).write(
      TracksCompanion(
        playCount: Value(track.playCount + 1),
        lastPlayed: Value(DateTime.now()),
      ),
    );
  }

  Future<void> recordArtistPlay(int id) async {
    final artist = await (select(artists)..where((t) => t.id.equals(id))).getSingle();
    await (update(artists)..where((t) => t.id.equals(id))).write(
      ArtistsCompanion(
        playCount: Value(artist.playCount + 1),
        lastPlayed: Value(DateTime.now()),
      ),
    );
  }

  Future<void> recordAlbumPlay(int id) async {
    final album = await (select(albums)..where((t) => t.id.equals(id))).getSingle();
    await (update(albums)..where((t) => t.id.equals(id))).write(
      AlbumsCompanion(
        playCount: Value(album.playCount + 1),
        lastPlayed: Value(DateTime.now()),
      ),
    );
  }

  Future<void> recordRadioListen(String uuid, int seconds) async {
    final existing = await (select(radioListeningStats)
          ..where((t) => t.stationUuid.equals(uuid)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(radioListeningStats)..where((t) => t.stationUuid.equals(uuid))).write(
        RadioListeningStatsCompanion(
          timeSpentSeconds: Value(existing.timeSpentSeconds + seconds),
          lastListened: Value(DateTime.now()),
        ),
      );
    } else {
      await into(radioListeningStats).insert(
        RadioListeningStatsCompanion.insert(
          stationUuid: uuid,
          timeSpentSeconds: Value(seconds),
          lastListened: Value(DateTime.now()),
        ),
      );
    }
  }

  // Retrieval for Analytics View
  Stream<List<Track>> watchFavoriteTracks() =>
      (select(tracks)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Artist>> watchFavoriteArtists() =>
      (select(artists)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Album>> watchFavoriteAlbums() =>
      (select(albums)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Podcast>> watchFavoritePodcasts() =>
      (select(podcasts)..where((t) => t.isFavorite.equals(true))).watch();

  Stream<List<Track>> watchMostPlayedTracks({int limit = 20}) =>
      (select(tracks)
            ..where((t) => t.playCount.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.playCount)])
            ..limit(limit))
          .watch();

  Stream<List<RadioListeningStat>> watchRadioStats({int limit = 10}) =>
      (select(radioListeningStats)
            ..where((t) => t.timeSpentSeconds.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.timeSpentSeconds)])
            ..limit(limit))
          .watch();
}
