import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

import 'package:path/path.dart' as p;

part 'library_dao.g.dart';

@DriftAccessor(tables: [Folders, Artists, Albums, Genres, Tracks, ArtistAlbumRelations])
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(AppDatabase db) : super(db);

  // Folder Operations
  Future<int> addFolder(FoldersCompanion folder) =>
      into(folders).insert(folder, mode: InsertMode.insertOrIgnore);
  Future<List<Folder>> getAllFolders() => select(folders).get();
  Future<List<Folder>> getRootFolders() =>
      (select(folders)..where((f) => f.parentId.isNull())).get();
  Future<List<Folder>> getSubFolders(int parentId) =>
      (select(folders)..where((f) => f.parentId.equals(parentId))).get();

  Future<int> ensureFolder(String path, {int? parentId}) async {
    final existing = await (select(folders)..where((f) => f.path.equals(path))).getSingleOrNull();
    if (existing != null) return existing.id;
    final name = p.basename(path);
    return into(folders).insert(
      FoldersCompanion.insert(
        path: path,
        name: name,
        parentId: Value(parentId),
      ),
    );
  }

  // Metadata Operations
  Future<int> ensureArtist(String name) async {
    final existing = await (select(artists)..where((a) => a.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(artists).insert(ArtistsCompanion.insert(name: name));
  }

  Future<int> ensureAlbum(String name, int? artistId, {Uint8List? coverArt}) async {
    final existing = await (select(albums)..where(
              (a) => a.name.equals(name) &
                  (artistId == null ? a.artistId.isNull() : a.artistId.equals(artistId)),
            )).getSingleOrNull();

    if (existing != null) {
      if (existing.coverArt == null && coverArt != null) {
        await (update(albums)..where((a) => a.id.equals(existing.id))).write(
          AlbumsCompanion(coverArt: Value(coverArt)),
        );
      }
      return existing.id;
    }

    return into(albums).insert(
      AlbumsCompanion.insert(
        name: name,
        artistId: Value(artistId),
        coverArt: Value(coverArt),
      ),
    );
  }

  Future<int> ensureGenre(String name) async {
    final existing = await (select(genres)..where((g) => g.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(genres).insert(GenresCompanion.insert(name: name));
  }

  Future<List<Artist>> getAllArtists() => select(artists).get();
  Future<List<Album>> getAllAlbums() => select(albums).get();
  Future<List<Genre>> getAllGenres() => select(genres).get();
  Future<List<int>> getAllYears() async {
    final query = selectOnly(tracks, distinct: true)..addColumns([tracks.year]);
    final result = await query.get();
    return result.map((row) => row.read(tracks.year)).whereType<int>().toList()..sort();
  }

  Future<List<Track>> getTracksForArtist(int artistId) =>
      (select(tracks)..where((t) => t.artistId.equals(artistId))).get();

  Future<List<Track>> getTracksForAlbum(int albumId) =>
      (select(tracks)..where((t) => t.albumId.equals(albumId))).get();

  Future<List<Track>> getTracksForGenre(int genreId) =>
      (select(tracks)..where((t) => t.genreId.equals(genreId))).get();

  Future<List<Track>> getTracksForYear(int year) =>
      (select(tracks)..where((t) => t.year.equals(year))).get();

  Future<void> updateAlbumArt(int albumId, Uint8List art) {
    return (update(albums)..where((a) => a.id.equals(albumId))).write(
      AlbumsCompanion(coverArt: Value(art)),
    );
  }

  Future<void> updateArtistPhoto(int artistId, Uint8List photo) {
    return (update(artists)..where((a) => a.id.equals(artistId))).write(
      ArtistsCompanion(photo: Value(photo)),
    );
  }

  Future<void> updateTrackArt(int trackId, Uint8List art) {
    return (update(tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(coverArt: Value(art)),
    );
  }

  Future<List<Track>> getTracksForArtistInAlbum(int artistId, int albumId) =>
      (select(tracks)..where((t) => t.artistId.equals(artistId) & t.albumId.equals(albumId))).get();

  Future<void> cacheArtistAlbumRelations(List<ArtistAlbumRelation> relations) async {
    await batch((b) => b.insertAll(artistAlbumRelations, relations, mode: InsertMode.insertOrReplace));
  }

  Future<void> addTracks(List<TracksCompanion> trackCompanions) async {
    await batch((batch) {
      batch.insertAll(tracks, trackCompanions, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<Track>> getTracksForFolder(int folderId) =>
      (select(tracks)..where((t) => t.folderId.equals(folderId))).get();

  Future<List<Track>> getAllTracks() => select(tracks).get();

  Future<void> updateTrackRating(int trackId, int rating) {
    return (update(tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(rating: Value(rating)),
    );
  }

  Future<List<Track>> getLikedTracks() =>
      (select(tracks)..where((t) => t.rating.equals(1))).get();

  Future<List<Track>> getDislikedTracks() =>
      (select(tracks)..where((t) => t.rating.equals(-1))).get();
}
