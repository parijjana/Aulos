import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  TextColumn get name => text()();
  IntColumn get parentId =>
      integer().nullable().references(Folders, #id)(); // Hierarchical Folders
}

class Artists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BlobColumn get photo => blob().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get artistId => integer().nullable().references(Artists, #id)();
  BlobColumn get coverArt => blob().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name, artistId},
  ];
}

class Genres extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  TextColumn get title => text()();
  IntColumn get artistId => integer().nullable().references(Artists, #id)();
  IntColumn get albumId => integer().nullable().references(Albums, #id)();
  IntColumn get genreId => integer().nullable().references(Genres, #id)();
  IntColumn get year => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get folderId => integer().references(Folders, #id)();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  BlobColumn get coverArt => blob().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class ArtistAlbumRelations extends Table {
  IntColumn get artistId => integer().references(Artists, #id)();
  IntColumn get albumId => integer().references(Albums, #id)();
  IntColumn get trackCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {artistId, albumId};
}

class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistTracks extends Table {
  IntColumn get playlistId => integer().references(Playlists, #id)();
  IntColumn get trackId => integer().references(Tracks, #id)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};
}

class QueueTracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get trackId => integer().references(Tracks, #id)();
  IntColumn get position => integer()();
}

class Podcasts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get feedUrl => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  BlobColumn get image => blob().nullable()();
  DateTimeColumn get subscribedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get podcastId => integer().references(Podcasts, #id)();
  TextColumn get guid => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get audioUrl => text()();
  TextColumn get localFilePath => text().nullable()();
  IntColumn get downloadState =>
      integer().withDefault(const Constant(0))(); // 0: none, 1: downloading, 2: completed, 3: error
  DateTimeColumn get pubDate => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get playbackPositionSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class RadioListeningStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get stationUuid => text().unique()();
  IntColumn get timeSpentSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastListened => dateTime().nullable()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trackPath => text()();
  TextColumn get title => text()();
  IntColumn get positionMs => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
