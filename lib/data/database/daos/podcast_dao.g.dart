// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_dao.dart';

// ignore_for_file: type=lint
mixin _$PodcastDaoMixin on DatabaseAccessor<AppDatabase> {
  $PodcastsTable get podcasts => attachedDatabase.podcasts;
  $EpisodesTable get episodes => attachedDatabase.episodes;
  PodcastDaoManager get managers => PodcastDaoManager(this);
}

class PodcastDaoManager {
  final _$PodcastDaoMixin _db;
  PodcastDaoManager(this._db);
  $$PodcastsTableTableManager get podcasts =>
      $$PodcastsTableTableManager(_db.attachedDatabase, _db.podcasts);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db.attachedDatabase, _db.episodes);
}
