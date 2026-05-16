// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_dao.dart';

// ignore_for_file: type=lint
mixin _$PlaylistDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlaylistsTable get playlists => attachedDatabase.playlists;
  $ArtistsTable get artists => attachedDatabase.artists;
  $AlbumsTable get albums => attachedDatabase.albums;
  $GenresTable get genres => attachedDatabase.genres;
  $FoldersTable get folders => attachedDatabase.folders;
  $TracksTable get tracks => attachedDatabase.tracks;
  $PlaylistTracksTable get playlistTracks => attachedDatabase.playlistTracks;
  $QueueTracksTable get queueTracks => attachedDatabase.queueTracks;
  PlaylistDaoManager get managers => PlaylistDaoManager(this);
}

class PlaylistDaoManager {
  final _$PlaylistDaoMixin _db;
  PlaylistDaoManager(this._db);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db.attachedDatabase, _db.playlists);
  $$ArtistsTableTableManager get artists =>
      $$ArtistsTableTableManager(_db.attachedDatabase, _db.artists);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db.attachedDatabase, _db.albums);
  $$GenresTableTableManager get genres =>
      $$GenresTableTableManager(_db.attachedDatabase, _db.genres);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db.attachedDatabase, _db.tracks);
  $$PlaylistTracksTableTableManager get playlistTracks =>
      $$PlaylistTracksTableTableManager(
        _db.attachedDatabase,
        _db.playlistTracks,
      );
  $$QueueTracksTableTableManager get queueTracks =>
      $$QueueTracksTableTableManager(_db.attachedDatabase, _db.queueTracks);
}
