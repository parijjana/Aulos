// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_dao.dart';

// ignore_for_file: type=lint
mixin _$AnalyticsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ArtistsTable get artists => attachedDatabase.artists;
  $AlbumsTable get albums => attachedDatabase.albums;
  $GenresTable get genres => attachedDatabase.genres;
  $FoldersTable get folders => attachedDatabase.folders;
  $TracksTable get tracks => attachedDatabase.tracks;
  $PodcastsTable get podcasts => attachedDatabase.podcasts;
  $EpisodesTable get episodes => attachedDatabase.episodes;
  $RadioListeningStatsTable get radioListeningStats =>
      attachedDatabase.radioListeningStats;
  AnalyticsDaoManager get managers => AnalyticsDaoManager(this);
}

class AnalyticsDaoManager {
  final _$AnalyticsDaoMixin _db;
  AnalyticsDaoManager(this._db);
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
  $$PodcastsTableTableManager get podcasts =>
      $$PodcastsTableTableManager(_db.attachedDatabase, _db.podcasts);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db.attachedDatabase, _db.episodes);
  $$RadioListeningStatsTableTableManager get radioListeningStats =>
      $$RadioListeningStatsTableTableManager(
        _db.attachedDatabase,
        _db.radioListeningStats,
      );
}
