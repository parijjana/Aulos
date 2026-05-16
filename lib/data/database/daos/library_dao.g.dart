// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_dao.dart';

// ignore_for_file: type=lint
mixin _$LibraryDaoMixin on DatabaseAccessor<AppDatabase> {
  $FoldersTable get folders => attachedDatabase.folders;
  $ArtistsTable get artists => attachedDatabase.artists;
  $AlbumsTable get albums => attachedDatabase.albums;
  $GenresTable get genres => attachedDatabase.genres;
  $TracksTable get tracks => attachedDatabase.tracks;
  $ArtistAlbumRelationsTable get artistAlbumRelations =>
      attachedDatabase.artistAlbumRelations;
  LibraryDaoManager get managers => LibraryDaoManager(this);
}

class LibraryDaoManager {
  final _$LibraryDaoMixin _db;
  LibraryDaoManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
  $$ArtistsTableTableManager get artists =>
      $$ArtistsTableTableManager(_db.attachedDatabase, _db.artists);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db.attachedDatabase, _db.albums);
  $$GenresTableTableManager get genres =>
      $$GenresTableTableManager(_db.attachedDatabase, _db.genres);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db.attachedDatabase, _db.tracks);
  $$ArtistAlbumRelationsTableTableManager get artistAlbumRelations =>
      $$ArtistAlbumRelationsTableTableManager(
        _db.attachedDatabase,
        _db.artistAlbumRelations,
      );
}
