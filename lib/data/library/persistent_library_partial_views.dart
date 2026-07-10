import 'package:drift/drift.dart' hide Column;
import 'package:aulos/data/database/app_database.dart';
import 'persistent_library_service.dart';

/// "Partial view" queries used when drilling into a single artist/genre/year
/// filtered to one album (e.g. an artist's tracks within a compilation
/// album). Extracted from PersistentLibraryServiceImpl since these are
/// cross-cutting lookups layered on top of the base CRUD surface, not part
/// of the abstract PersistentLibraryService interface.
extension PersistentLibraryPartialViewsExtension on PersistentLibraryServiceImpl {
  Future<List<Album>> getAlbumsForArtist(String artistId) async {
    final query = db.select(db.artistAlbumRelations).join([
      innerJoin(
        db.albums,
        db.albums.id.equalsExp(db.artistAlbumRelations.albumId),
      ),
    ])..where(db.artistAlbumRelations.artistId.equals(artistId));

    final result = await query.get();
    return result.map((row) => row.readTable(db.albums)).toList();
  }

  Future<List<Track>> getTracksForArtistInAlbum(String artistId, String albumId) =>
      db.getTracksForArtistInAlbum(artistId, albumId);

  Future<List<Album>> getAlbumsForGenre(String genreId) async {
    final query = db.selectOnly(db.tracks, distinct: true)
      ..addColumns([db.tracks.albumId])
      ..where(db.tracks.genreId.equals(genreId));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(db.tracks.albumId))
        .whereType<String>()
        .toList();
    return (db.select(db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Album>> getAlbumsForYear(int year) async {
    final query = db.selectOnly(db.tracks, distinct: true)
      ..addColumns([db.tracks.albumId])
      ..where(db.tracks.year.equals(year));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(db.tracks.albumId))
        .whereType<String>()
        .toList();
    return (db.select(db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Track>> getTracksForGenreInAlbum(String genreId, String albumId) =>
      (db.select(db.tracks)..where(
            (t) => t.genreId.equals(genreId) & t.albumId.equals(albumId),
          ))
          .get();

  Future<List<Track>> getTracksForYearInAlbum(int year, String albumId) =>
      (db.select(
        db.tracks,
      )..where((t) => t.year.equals(year) & t.albumId.equals(albumId))).get();
}
