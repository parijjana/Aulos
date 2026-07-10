import 'package:drift/drift.dart';

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get path => text().unique()();
  TextColumn get name => text()();
  TextColumn get parentId =>
      text().nullable().references(Folders, #id)(); // Hierarchical Folders
  IntColumn get folderType => integer().withDefault(const Constant(0))(); // 0: Music, 1: Audiobooks
}

class Artists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  BlobColumn get photo => blob().nullable()();
  TextColumn get localArtPath => text().nullable()();
  TextColumn get bio => text().nullable()(); 
  TextColumn get photoUrl => text().nullable()(); 
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class Albums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get artistId => text().nullable().references(Artists, #id)();
  BlobColumn get coverArt => blob().nullable()();
  TextColumn get localArtPath => text().nullable()();
  TextColumn get coverArtUrl => text().nullable()(); 
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  BoolColumn get isAudiobook => boolean().withDefault(const Constant(false))();
  
  // Audiobook/Series Metadata
  TextColumn get asin => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get seriesName => text().nullable()();
  IntColumn get seriesPosition => integer().nullable()();
  TextColumn get narrator => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get publishedDate => dateTime().nullable()();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  
  // LibriVox specific fields
  TextColumn get librivoxId => text().nullable()();
  BoolColumn get isDownloadedViaAulos => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name, artistId},
  ];
}

class Genres extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
}

class Tracks extends Table {
  TextColumn get id => text()();
  TextColumn get path => text().unique()();
  TextColumn get title => text()();
  TextColumn get artistId => text().nullable().references(Artists, #id)();
  TextColumn get albumId => text().nullable().references(Albums, #id)();
  TextColumn get genreId => text().nullable().references(Genres, #id)();
  IntColumn get year => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  TextColumn get folderId => text().references(Folders, #id)();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  BlobColumn get coverArt => blob().nullable()();
  TextColumn get localArtPath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  BoolColumn get isAudiobook => boolean().withDefault(const Constant(false))();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  BoolColumn get isStream => boolean().nullable()();
  TextColumn get duplicateOf => text().nullable()(); // Added for collision duplicate tracking
}

class ArtistAlbumRelations extends Table {
  TextColumn get artistId => text().references(Artists, #id)();
  TextColumn get albumId => text().references(Albums, #id)();
  IntColumn get trackCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {artistId, albumId};
}

class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  TextColumn get rulesJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PlaylistTracks extends Table {
  TextColumn get playlistId => text().references(Playlists, #id)();
  TextColumn get trackId => text().references(Tracks, #id)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, trackId};
}

class QueueTracks extends Table {
  TextColumn get id => text()();
  TextColumn get trackId => text()();
  IntColumn get position => integer()();
}

class Podcasts extends Table {
  TextColumn get id => text()();
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
  TextColumn get id => text()();
  TextColumn get podcastId => text().references(Podcasts, #id)();
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
  TextColumn get duplicateOf => text().nullable()(); // Added for collision duplicate tracking
}

class RadioListeningStats extends Table {
  TextColumn get id => text()();
  TextColumn get stationUuid => text().unique()();
  IntColumn get timeSpentSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastListened => dateTime().nullable()();
}

class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get trackPath => text()();
  TextColumn get title => text()();
  IntColumn get startTimeMs => integer()();
  IntColumn get endTimeMs => integer().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get contextType => integer().withDefault(const Constant(0))(); // 0: Music, 1: Podcast, 2: Audiobook
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get trackId => text().references(Tracks, #id)();
  TextColumn get title => text()();
  IntColumn get startTimeMs => integer()();
  IntColumn get durationMs => integer().nullable()();
}

class PlaybackPositions extends Table {
  TextColumn get trackId => text()();
  IntColumn get positionMs => integer()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {trackId};
}

@DataClassName('SavedMix')
class SavedMixes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get mixData => text()(); // JSON map of soundId -> volume
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AudiobookFolders extends Table {
  TextColumn get id => text()();
  TextColumn get path => text().unique()();
  TextColumn get name => text()();
  TextColumn get parentId =>
      text().nullable().references(AudiobookFolders, #id)(); 
}

class AudiobookArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  BlobColumn get photo => blob().nullable()();
  TextColumn get localArtPath => text().nullable()();
  TextColumn get bio => text().nullable()(); 
  TextColumn get photoUrl => text().nullable()(); 
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
}

class Audiobooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get artistId => text().nullable().references(AudiobookArtists, #id)(); // References author in AudiobookArtists table
  BlobColumn get coverArt => blob().nullable()();
  TextColumn get localArtPath => text().nullable()();
  TextColumn get coverArtUrl => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  TextColumn get asin => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get seriesName => text().nullable()();
  IntColumn get seriesPosition => integer().nullable()();
  TextColumn get narrator => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get publishedDate => dateTime().nullable()();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  TextColumn get librivoxId => text().nullable()();
  BoolColumn get isDownloadedViaAulos => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name, artistId},
  ];
}

class AudiobookTracks extends Table {
  TextColumn get id => text()();
  TextColumn get path => text().unique()();
  TextColumn get title => text()();
  TextColumn get artistId => text().nullable().references(AudiobookArtists, #id)();
  TextColumn get audiobookId => text().nullable().references(Audiobooks, #id)();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  BlobColumn get coverArt => blob().nullable()();
  TextColumn get localArtPath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  BoolColumn get isStream => boolean().nullable()();
  TextColumn get duplicateOf => text().nullable()(); // Added for collision duplicate tracking
}

class AudiobookChapters extends Table {
  TextColumn get id => text()();
  TextColumn get audiobookTrackId => text().references(AudiobookTracks, #id)();
  TextColumn get title => text()();
  IntColumn get startTimeMs => integer()();
  IntColumn get durationMs => integer().nullable()();
}
