import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../../core/utils/id_generator.dart';
import 'package:path/path.dart' as p;

part 'library_dao.g.dart';

@DriftAccessor(tables: [Folders, Artists, Albums, Genres, Tracks, ArtistAlbumRelations])
class LibraryDao extends DatabaseAccessor<AppDatabase> with _$LibraryDaoMixin {
  LibraryDao(AppDatabase db) : super(db);

  AppDatabase get db => attachedDatabase;

  // Folder Operations
  Future<void> addFolder(FoldersCompanion folder) =>
      into(folders).insert(folder, mode: InsertMode.insertOrIgnore);
      
  Future<List<Folder>> getAllFolders({int? limit, int? offset, String? searchQuery}) {
    var query = select(folders);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.name.like('%$searchQuery%'));
    }
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }
  
  Future<List<Folder>> getRootFolders({int folderType = 0, int? limit, int? offset, String? searchQuery}) {
    var query = select(folders);
    query.where((f) {
      var predicate = f.parentId.isNull() & f.folderType.equals(folderType);
      if (searchQuery != null && searchQuery.isNotEmpty) {
        predicate = predicate & f.name.like('%$searchQuery%');
      }
      return predicate;
    });
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }
      
  Future<List<Folder>> getSubFolders(String parentId, {int folderType = 0}) =>
      (select(folders)..where((f) => f.parentId.equals(parentId) & f.folderType.equals(folderType))).get();

  Future<String> ensureFolder(String path, {String? parentId, int folderType = 0}) async {
    final folderName = p.basename(path);
    final fingerprint = "${parentId ?? ''}|$folderName";
    final generatedId = generateContentId(fingerprint);

    final existing = await (select(folders)..where((f) => f.id.equals(generatedId))).getSingleOrNull();
    if (existing != null) return existing.id;
    
    await into(folders).insert(
      FoldersCompanion.insert(
        id: generatedId,
        path: path,
        name: folderName,
        parentId: Value(parentId),
        folderType: Value(folderType),
      ),
    );
    return generatedId;
  }

  // Metadata Operations
  Future<String> ensureArtist(String name, {String? localArtPath}) async {
    final generatedId = generateContentId(name);
    final existing = await (select(artists)..where((a) => a.id.equals(generatedId))).getSingleOrNull();
    if (existing != null) return existing.id;
    
    await into(artists).insert(
      ArtistsCompanion.insert(
        id: generatedId,
        name: name,
        localArtPath: Value(localArtPath),
      ),
    );
    return generatedId;
  }

  Future<String> ensureAlbum(String name, String? artistId, {Uint8List? coverArt, String? localArtPath, bool isAudiobook = false}) async {
    final fingerprint = "${artistId ?? ''}|$name";
    final generatedId = generateContentId(fingerprint);

    final existing = await (select(albums)..where(
              (a) => a.id.equals(generatedId),
            )).getSingleOrNull();

    if (existing != null) {
      if (existing.coverArt == null && coverArt != null) {
        await (update(albums)..where((a) => a.id.equals(existing.id))).write(
          AlbumsCompanion(coverArt: Value(coverArt)),
        );
      }
      if (existing.localArtPath == null && localArtPath != null) {
        await (update(albums)..where((a) => a.id.equals(existing.id))).write(
          AlbumsCompanion(localArtPath: Value(localArtPath)),
        );
      }
      return existing.id;
    }

    await into(albums).insert(
      AlbumsCompanion.insert(
        id: generatedId,
        name: name,
        artistId: Value(artistId),
        coverArt: Value(coverArt),
        localArtPath: Value(localArtPath),
        isAudiobook: Value(isAudiobook),
      ),
    );
    return generatedId;
  }

  Future<String> ensureGenre(String name) async {
    final generatedId = generateContentId(name);
    final existing = await (select(genres)..where((g) => g.id.equals(generatedId))).getSingleOrNull();
    if (existing != null) return existing.id;
    
    await into(genres).insert(
      GenresCompanion.insert(
        id: generatedId,
        name: name,
      ),
    );
    return generatedId;
  }

  Future<List<Artist>> getAllArtists({int? limit, int? offset, String? searchQuery}) {
    var query = select(artists);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.name.like('%$searchQuery%'));
    }
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  Future<List<Album>> getAllAlbums({int? limit, int? offset, String? searchQuery}) {
    var query = select(albums);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.name.like('%$searchQuery%'));
    }
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  Future<List<Genre>> getAllGenres({int? limit, int? offset, String? searchQuery}) {
    var query = select(genres);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.name.like('%$searchQuery%'));
    }
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }
  
  Future<List<int>> getAllYears() async {
    final query = selectOnly(tracks, distinct: true)..addColumns([tracks.year]);
    final result = await query.get();
    return result.map((row) => row.read(tracks.year)).whereType<int>().toList()..sort();
  }

  Future<List<Track>> getTracksForArtist(String artistId) =>
      (select(tracks)..where((t) => t.artistId.equals(artistId))).get();

  Future<List<Track>> getTracksForAlbum(String albumId) =>
      (select(tracks)..where((t) => t.albumId.equals(albumId))).get();

  Future<List<Track>> getTracksForGenre(String genreId) =>
      (select(tracks)..where((t) => t.genreId.equals(genreId))).get();

  Future<List<Track>> getTracksForYear(int year) =>
      (select(tracks)..where((t) => t.year.equals(year))).get();

  Future<void> updateAlbumArt(String albumId, Uint8List? art, {String? localArtPath}) {
    return (update(albums)..where((a) => a.id.equals(albumId))).write(
      AlbumsCompanion(coverArt: Value(art), localArtPath: Value(localArtPath)),
    );
  }

  Future<void> updateArtistPhoto(String artistId, Uint8List? photo, {String? localArtPath}) {
    return (update(artists)..where((a) => a.id.equals(artistId))).write(
      ArtistsCompanion(photo: Value(photo), localArtPath: Value(localArtPath)),
    );
  }

  Future<void> updateArtistBiography(String artistId, String biography) {
    return (update(artists)..where((a) => a.id.equals(artistId))).write(
      ArtistsCompanion(bio: Value(biography)),
    );
  }

  Future<void> updateTrackArt(String trackId, Uint8List? art, {String? localArtPath}) {
    return (update(tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(coverArt: Value(art), localArtPath: Value(localArtPath)),
    );
  }

  Future<List<Track>> getTracksForArtistInAlbum(String artistId, String albumId) =>
      (select(tracks)..where((t) => t.artistId.equals(artistId) & t.albumId.equals(albumId))).get();

  Future<void> cacheArtistAlbumRelations(List<ArtistAlbumRelation> relations) async {
    await batch((b) => b.insertAll(artistAlbumRelations, relations, mode: InsertMode.insertOrReplace));
  }

  Future<void> addTracks(List<TracksCompanion> trackCompanions) async {
    await batch((batch) {
      batch.insertAll(tracks, trackCompanions, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<Track>> getTracksForFolder(String folderId) =>
      (select(tracks)..where((t) => t.folderId.equals(folderId))).get();

  Future<Track?> getTrackById(String id) =>
      (select(tracks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Album?> getAlbumById(String id) =>
      (select(albums)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<List<Track>> getAllTracks({int? limit, int? offset, String? searchQuery}) {
    var query = select(tracks);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where((t) => t.title.like('%$searchQuery%'));
    }
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  Future<void> updateTrackRating(String trackId, int rating) {
    return (update(tracks)..where((t) => t.id.equals(trackId))).write(
      TracksCompanion(
        rating: Value(rating),
        isFavorite: Value(rating == 1),
      ),
    );
  }

  Future<List<Track>> getLikedTracks() =>
      (select(tracks)..where((t) => t.rating.equals(1))).get();

  Future<List<Track>> getDislikedTracks() =>
      (select(tracks)..where((t) => t.rating.equals(-1))).get();

  Future<void> toggleArtistFavorite(String artistId) async {
    final artist = await (select(artists)..where((a) => a.id.equals(artistId))).getSingleOrNull();
    if (artist != null) {
      await (update(artists)..where((a) => a.id.equals(artistId))).write(
        ArtistsCompanion(isFavorite: Value(!artist.isFavorite)),
      );
    }
  }

  Future<void> toggleAlbumFavorite(String albumId) async {
    final album = await (select(albums)..where((a) => a.id.equals(albumId))).getSingleOrNull();
    if (album != null) {
      await (update(albums)..where((a) => a.id.equals(albumId))).write(
        AlbumsCompanion(isFavorite: Value(!album.isFavorite)),
      );
    }
  }
}
