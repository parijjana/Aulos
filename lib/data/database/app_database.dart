import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/library_dao.dart';
import 'daos/playlist_dao.dart';
import 'daos/podcast_dao.dart';
import 'daos/analytics_dao.dart';

export 'tables.dart';

part 'app_database.g.dart';

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
    Bookmarks,
    RadioListeningStats,
    PlaybackPositions,
  ],
  daos: [
    LibraryDao,
    PlaylistDao,
    PodcastDao,
    AnalyticsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.testing(super.executor);

  @override
  int get schemaVersion => 17;

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
        try {
          await m.addColumn(episodes, episodes.localFilePath);
          await m.addColumn(episodes, episodes.downloadState);
        } catch (_) {}
      }
      if (from < 11) {
        try {
          await m.addColumn(podcasts, podcasts.image);
        } catch (_) {}
      }
      if (from < 12) {
        try {
          await m.addColumn(episodes, episodes.isPinned);
        } catch (_) {}
      }
      if (from < 13) {
        await m.createTable(bookmarks);
      }
      if (from < 14) {
        await m.createTable(radioListeningStats);
        await m.addColumn(tracks, tracks.isFavorite);
        await m.addColumn(tracks, tracks.playCount);
        await m.addColumn(tracks, tracks.lastPlayed);
        await m.addColumn(artists, artists.isFavorite);
        await m.addColumn(artists, artists.playCount);
        await m.addColumn(artists, artists.lastPlayed);
        await m.addColumn(albums, albums.isFavorite);
        await m.addColumn(albums, albums.playCount);
        await m.addColumn(albums, albums.lastPlayed);
        await m.addColumn(podcasts, podcasts.isFavorite);
        await m.addColumn(podcasts, podcasts.playCount);
        await m.addColumn(podcasts, podcasts.lastPlayed);
        await m.addColumn(episodes, episodes.playCount);
        await m.addColumn(episodes, episodes.lastPlayed);
      }
      if (from < 15) {
        await m.addColumn(bookmarks, bookmarks.endTimeMs);
      }
      if (from < 16) {
        // RESET: Drop and recreate bookmarks due to previous schema corruption
        await m.deleteTable(bookmarks.actualTableName);
        await m.createTable(bookmarks);
      }
      if (from < 17) {
        await m.createTable(playbackPositions);
      }
    },
  );

  // Delegation methods
  Future<int> addFolder(FoldersCompanion folder) => libraryDao.addFolder(folder);
  Future<List<Folder>> getAllFolders() => libraryDao.getAllFolders();
  Future<List<Folder>> getRootFolders() => libraryDao.getRootFolders();
  Future<List<Folder>> getSubFolders(int parentId) => libraryDao.getSubFolders(parentId);
  Future<int> ensureFolder(String path, {int? parentId}) => libraryDao.ensureFolder(path, parentId: parentId);
  Future<int> ensureArtist(String name) => libraryDao.ensureArtist(name);
  Future<int> ensureAlbum(String name, int? artistId, {Uint8List? coverArt}) => libraryDao.ensureAlbum(name, artistId, coverArt: coverArt);
  Future<int> ensureGenre(String name) => libraryDao.ensureGenre(name);
  Future<List<Artist>> getAllArtists() => libraryDao.getAllArtists();
  Future<List<Album>> getAllAlbums() => libraryDao.getAllAlbums();
  Future<List<Genre>> getAllGenres() => libraryDao.getAllGenres();
  Future<List<int>> getAllYears() => libraryDao.getAllYears();
  Future<List<Track>> getTracksForArtist(int artistId) => libraryDao.getTracksForArtist(artistId);
  Future<List<Track>> getTracksForAlbum(int albumId) => libraryDao.getTracksForAlbum(albumId);
  Future<List<Track>> getTracksForGenre(int genreId) => libraryDao.getTracksForGenre(genreId);
  Future<List<Track>> getTracksForYear(int year) => libraryDao.getTracksForYear(year);
  Future<void> updateAlbumArt(int albumId, Uint8List art) => libraryDao.updateAlbumArt(albumId, art);
  Future<void> updateArtistPhoto(int artistId, Uint8List photo) => libraryDao.updateArtistPhoto(artistId, photo);
  Future<void> updateTrackArt(int trackId, Uint8List art) => libraryDao.updateTrackArt(trackId, art);
  Future<List<Track>> getTracksForArtistInAlbum(int artistId, int albumId) => libraryDao.getTracksForArtistInAlbum(artistId, albumId);
  Future<void> cacheArtistAlbumRelations(List<ArtistAlbumRelation> relations) => libraryDao.cacheArtistAlbumRelations(relations);
  Future<void> addTracks(List<TracksCompanion> trackCompanions) => libraryDao.addTracks(trackCompanions);
  Future<List<Track>> getTracksForFolder(int folderId) => libraryDao.getTracksForFolder(folderId);
  Future<List<Track>> getAllTracks() => libraryDao.getAllTracks();
  Future<void> updateTrackRating(int trackId, int rating) => libraryDao.updateTrackRating(trackId, rating);
  Future<List<Track>> getLikedTracks() => libraryDao.getLikedTracks();
  Future<List<Track>> getDislikedTracks() => libraryDao.getDislikedTracks();

  Future<List<Playlist>> getAllPlaylists() => playlistDao.getAllPlaylists();
  Future<void> deletePlaylist(int id) => playlistDao.deletePlaylist(id);
  Future<void> savePlaylistWithTracks(String name, List<int> trackIds, {bool isSmart = false}) => playlistDao.savePlaylistWithTracks(name, trackIds, isSmart: isSmart);
  Future<List<Track>> getTracksForPlaylist(int playlistId) => playlistDao.getTracksForPlaylist(playlistId);
  Future<void> clearQueue() => playlistDao.clearQueue();
  Future<void> saveQueue(List<int> trackIds) => playlistDao.saveQueue(trackIds);
  Future<List<Track>> getQueue() => playlistDao.getQueue();

  Future<int> addPodcast(PodcastsCompanion podcast) => podcastDao.addPodcast(podcast);
  Future<void> updatePodcast(int id, PodcastsCompanion podcast) => podcastDao.updatePodcast(id, podcast);
  Future<void> deletePodcast(int id) => podcastDao.deletePodcast(id);
  Future<List<Podcast>> getAllPodcasts() => podcastDao.getAllPodcasts();
  Future<Podcast?> getPodcastByFeedUrl(String url) => podcastDao.getPodcastByFeedUrl(url);
  Future<void> addEpisodes(List<EpisodesCompanion> companions) => podcastDao.addEpisodes(companions);
  Future<List<Episode>> getEpisodesForPodcast(int podcastId) => podcastDao.getEpisodesForPodcast(podcastId);
  
  Future<void> updateEpisodePlayback(
    int id, {
    int? positionSeconds,
    bool? isPlayed,
    int? downloadState,
    String? localFilePath,
    bool? isPinned,
  }) => podcastDao.updateEpisodePlayback(
        id,
        positionSeconds: positionSeconds,
        isPlayed: isPlayed,
        downloadState: downloadState,
        localFilePath: localFilePath,
        isPinned: isPinned,
      );

  Future<int> saveBookmark(BookmarksCompanion companion) => into(bookmarks).insert(companion);
  Future<List<Bookmark>> getBookmarksForTrack(String path) => (select(bookmarks)..where((t) => t.trackPath.equals(path))).get();
  Future<void> deleteBookmark(int id) => (delete(bookmarks)..where((t) => t.id.equals(id))).go();
  Future<void> deleteBookmarksForTrack(String path) => (delete(bookmarks)..where((t) => t.trackPath.equals(path))).go();
  Future<void> updateBookmarkPaths(String oldPath, String newPath) {
    return (update(bookmarks)..where((t) => t.trackPath.equals(oldPath)))
        .write(BookmarksCompanion(trackPath: Value(newPath)));
  }

  // Playback Positions
  Future<void> savePlaybackPosition(int trackId, int positionMs) {
    return into(playbackPositions).insert(
      PlaybackPositionsCompanion(
        trackId: Value(trackId),
        positionMs: Value(positionMs),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<PlaybackPosition?> getPlaybackPosition(int trackId) {
    return (select(playbackPositions)..where((t) => t.trackId.equals(trackId)))
        .getSingleOrNull();
  }

  Future<void> deletePlaybackPosition(int trackId) {
    return (delete(playbackPositions)..where((t) => t.trackId.equals(trackId))).go();
  }

  // Analytics Delegation
  Future<void> setTrackFavorite(int id, bool favorite) => analyticsDao.setTrackFavorite(id, favorite);
  Future<void> setArtistFavorite(int id, bool favorite) => analyticsDao.setArtistFavorite(id, favorite);
  Future<void> setAlbumFavorite(int id, bool favorite) => analyticsDao.setAlbumFavorite(id, favorite);
  Future<void> setPodcastFavorite(int id, bool favorite) => analyticsDao.setPodcastFavorite(id, favorite);
  Future<void> recordTrackPlay(int id) => analyticsDao.recordTrackPlay(id);
  Future<void> recordArtistPlay(int id) => analyticsDao.recordArtistPlay(id);
  Future<void> recordAlbumPlay(int id) => analyticsDao.recordAlbumPlay(id);
  Future<void> recordRadioListen(String uuid, int seconds) => analyticsDao.recordRadioListen(uuid, seconds);
  Stream<List<Track>> watchFavoriteTracks() => analyticsDao.watchFavoriteTracks();
  Stream<List<Artist>> watchFavoriteArtists() => analyticsDao.watchFavoriteArtists();
  Stream<List<Album>> watchFavoriteAlbums() => analyticsDao.watchFavoriteAlbums();
  Stream<List<Podcast>> watchFavoritePodcasts() => analyticsDao.watchFavoritePodcasts();
  Stream<List<Track>> watchMostPlayedTracks({int limit = 20}) => analyticsDao.watchMostPlayedTracks(limit: limit);
  Stream<List<RadioListeningStat>> watchRadioStats({int limit = 10}) => analyticsDao.watchRadioStats(limit: limit);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'localaudio.sqlite'));
    return NativeDatabase(file);
  });
}
