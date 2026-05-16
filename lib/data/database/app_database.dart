import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

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
}

class Albums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get artistId => integer().nullable().references(Artists, #id)();
  BlobColumn get coverArt => blob().nullable()();

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
  IntColumn get playbackPositionSeconds =>
      integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Folders,
    Artists,
    Albums,
    Genres,
    Tracks,
    Playlists,
    PlaylistTracks,
    QueueTracks,
    ArtistAlbumRelations,
    Podcasts,
    Episodes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.testing(super.executor);

  @override
  int get schemaVersion => 10; // Bump to 10 for Episode download fields

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(playlists).insert(
        PlaylistsCompanion.insert(name: 'Likes', isSmart: const Value(true)),
      );
      await into(playlists).insert(
        PlaylistsCompanion.insert(name: 'Dislikes', isSmart: const Value(true)),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 7) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
        await into(playlists).insert(
          PlaylistsCompanion.insert(name: 'Likes', isSmart: const Value(true)),
        );
        await into(playlists).insert(
          PlaylistsCompanion.insert(
            name: 'Dislikes',
            isSmart: const Value(true),
          ),
        );
      } else if (from < 8) {
        await m.addColumn(artists, artists.photo);
      }
      if (from < 9) {
        await m.createTable(podcasts);
        await m.createTable(episodes);
      }
      if (from < 10) {
        await m.addColumn(episodes, episodes.localFilePath);
        await m.addColumn(episodes, episodes.downloadState);
      }
    },
  );

  // Folder Operations
  Future<int> addFolder(FoldersCompanion folder) =>
      into(folders).insert(folder, mode: InsertMode.insertOrIgnore);
  Future<List<Folder>> getAllFolders() => select(folders).get();
  Future<List<Folder>> getRootFolders() =>
      (select(folders)..where((f) => f.parentId.isNull())).get();
  Future<List<Folder>> getSubFolders(int parentId) =>
      (select(folders)..where((f) => f.parentId.equals(parentId))).get();

  Future<int> ensureFolder(String path, {int? parentId}) async {
    final existing = await (select(
      folders,
    )..where((f) => f.path.equals(path))).getSingleOrNull();
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
    final existing = await (select(
      artists,
    )..where((a) => a.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(artists).insert(ArtistsCompanion.insert(name: name));
  }

  Future<int> ensureAlbum(
    String name,
    int? artistId, {
    Uint8List? coverArt,
  }) async {
    final existing =
        await (select(albums)..where(
              (a) =>
                  a.name.equals(name) &
                  (artistId == null
                      ? a.artistId.isNull()
                      : a.artistId.equals(artistId)),
            ))
            .getSingleOrNull();

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
    final existing = await (select(
      genres,
    )..where((g) => g.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return into(genres).insert(GenresCompanion.insert(name: name));
  }

  Future<List<Artist>> getAllArtists() => select(artists).get();
  Future<List<Album>> getAllAlbums() => select(albums).get();
  Future<List<Genre>> getAllGenres() => select(genres).get();
  Future<List<int>> getAllYears() async {
    final query = selectOnly(tracks, distinct: true)..addColumns([tracks.year]);
    final result = await query.get();
    return result.map((row) => row.read(tracks.year)).whereType<int>().toList()
      ..sort();
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

  // Partial Views / Cached queries
  Future<List<Track>> getTracksForArtistInAlbum(int artistId, int albumId) =>
      (select(tracks)..where(
            (t) => t.artistId.equals(artistId) & t.albumId.equals(albumId),
          ))
          .get();

  Future<void> cacheArtistAlbumRelations(
    List<ArtistAlbumRelation> relations,
  ) async {
    await batch(
      (b) => b.insertAll(
        artistAlbumRelations,
        relations,
        mode: InsertMode.insertOrReplace,
      ),
    );
  }

  // Track Operations
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

  // Queue Operations
  Future<void> clearQueue() => delete(queueTracks).go();
  Future<void> saveQueue(List<int> trackIds) async {
    await transaction(() async {
      await clearQueue();
      for (int i = 0; i < trackIds.length; i++) {
        await into(queueTracks).insert(
          QueueTracksCompanion.insert(trackId: trackIds[i], position: i),
        );
      }
    });
  }

  Future<List<Track>> getQueue() async {
    final query = select(queueTracks).join([
      innerJoin(tracks, tracks.id.equalsExp(queueTracks.trackId)),
    ])..orderBy([OrderingTerm.asc(queueTracks.position)]);

    final result = await query.get();
    return result.map((row) => row.readTable(tracks)).toList();
  }

  // Playlist Operations
  Future<List<Playlist>> getAllPlaylists() => select(playlists).get();

  Future<void> deletePlaylist(int id) =>
      (delete(playlists)..where((p) => p.id.equals(id))).go();

  Future<void> savePlaylistWithTracks(
    String name,
    List<int> trackIds, {
    bool isSmart = false,
  }) async {
    await transaction(() async {
      final id = await into(playlists).insert(
        PlaylistsCompanion.insert(name: name, isSmart: Value(isSmart)),
        mode: InsertMode.insertOrIgnore,
      );
      await (delete(
        playlistTracks,
      )..where((pt) => pt.playlistId.equals(id))).go();
      for (int i = 0; i < trackIds.length; i++) {
        await into(playlistTracks).insert(
          PlaylistTracksCompanion.insert(
            playlistId: id,
            trackId: trackIds[i],
            position: i,
          ),
        );
      }
    });
  }

  Future<List<Track>> getTracksForPlaylist(int playlistId) async {
    final query =
        select(playlistTracks).join([
            innerJoin(tracks, tracks.id.equalsExp(playlistTracks.trackId)),
          ])
          ..where(playlistTracks.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(playlistTracks.position)]);

    final result = await query.get();
    return result.map((row) => row.readTable(tracks)).toList();
  }

  // Podcast Operations
  Future<int> addPodcast(PodcastsCompanion podcast) =>
      into(podcasts).insert(podcast, mode: InsertMode.insertOrIgnore);

  Future<void> updatePodcast(int id, PodcastsCompanion podcast) =>
      (update(podcasts)..where((p) => p.id.equals(id))).write(podcast);

  Future<void> deletePodcast(int id) async {
    await transaction(() async {
      await (delete(episodes)..where((e) => e.podcastId.equals(id))).go();
      await (delete(podcasts)..where((p) => p.id.equals(id))).go();
    });
  }

  Future<List<Podcast>> getAllPodcasts() => select(podcasts).get();

  Future<Podcast?> getPodcastByFeedUrl(String url) =>
      (select(podcasts)..where((p) => p.feedUrl.equals(url))).getSingleOrNull();

  // Episode Operations
  Future<void> addEpisodes(List<EpisodesCompanion> companions) async {
    await batch((b) {
      b.insertAll(episodes, companions, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<Episode>> getEpisodesForPodcast(int podcastId) =>
      (select(episodes)
            ..where((e) => e.podcastId.equals(podcastId))
            ..orderBy([
              (e) =>
                  OrderingTerm(expression: e.pubDate, mode: OrderingMode.desc),
            ]))
          .get();

  Future<void> updateEpisodePlayback(
    int id, {
    int? positionSeconds,
    bool? isPlayed,
  }) {
    return (update(episodes)..where((e) => e.id.equals(id))).write(
      EpisodesCompanion(
        playbackPositionSeconds:
            positionSeconds != null ? Value(positionSeconds) : const Value.absent(),
        isPlayed: isPlayed != null ? Value(isPlayed) : const Value.absent(),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'localaudio.sqlite'));
    return NativeDatabase(file);
  });
}
