import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/library_dao.dart';
import 'daos/playlist_dao.dart';
import 'daos/podcast_dao.dart';

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
  ],
  daos: [
    LibraryDao,
    PlaylistDao,
    PodcastDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.testing(super.executor);

  @override
  int get schemaVersion => 10;

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

  // Delegation methods to maintain compatibility with existing services
  // Library Operations
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

  // Playlist Operations
  Future<List<Playlist>> getAllPlaylists() => playlistDao.getAllPlaylists();
  Future<void> deletePlaylist(int id) => playlistDao.deletePlaylist(id);
  Future<void> savePlaylistWithTracks(String name, List<int> trackIds, {bool isSmart = false}) => playlistDao.savePlaylistWithTracks(name, trackIds, isSmart: isSmart);
  Future<List<Track>> getTracksForPlaylist(int playlistId) => playlistDao.getTracksForPlaylist(playlistId);
  Future<void> clearQueue() => playlistDao.clearQueue();
  Future<void> saveQueue(List<int> trackIds) => playlistDao.saveQueue(trackIds);
  Future<List<Track>> getQueue() => playlistDao.getQueue();

  // Podcast Operations
  Future<int> addPodcast(PodcastsCompanion podcast) => podcastDao.addPodcast(podcast);
  Future<void> updatePodcast(int id, PodcastsCompanion podcast) => podcastDao.updatePodcast(id, podcast);
  Future<void> deletePodcast(int id) => podcastDao.deletePodcast(id);
  Future<List<Podcast>> getAllPodcasts() => podcastDao.getAllPodcasts();
  Future<Podcast?> getPodcastByFeedUrl(String url) => podcastDao.getPodcastByFeedUrl(url);
  Future<void> addEpisodes(List<EpisodesCompanion> companions) => podcastDao.addEpisodes(companions);
  Future<List<Episode>> getEpisodesForPodcast(int podcastId) => podcastDao.getEpisodesForPodcast(podcastId);
  Future<void> updateEpisodePlayback(int id, {int? positionSeconds, bool? isPlayed}) => podcastDao.updateEpisodePlayback(id, positionSeconds: positionSeconds, isPlayed: isPlayed);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'localaudio.sqlite'));
    return NativeDatabase(file);
  });
}
