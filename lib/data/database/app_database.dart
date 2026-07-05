import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/library_dao.dart';
import 'daos/playlist_dao.dart';
import 'daos/analytics_dao.dart';
import '../../core/utils/id_generator.dart';

import 'package:aulos/domain/playback/playback_track.dart' as dom_track;

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
  ],
  daos: [
    LibraryDao,
    PlaylistDao,
    AnalyticsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([String? basePath]) : super(_openConnection(basePath));
  AppDatabase.testing(super.executor);

  @override
  int get schemaVersion => 25;

  Future<void> _safeAddColumn(Migrator m, TableInfo table, GeneratedColumn column) async {
    try {
      await m.addColumn(table, column);
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('duplicate column name') || 
          err.contains('already exists') || 
          err.contains('sqlite_error')) {
        // Ignored duplicate column
        return;
      }
      rethrow;
    }
  }

  Future<void> _safeDeleteTable(Migrator m, String tableName) async {
    try {
      await m.deleteTable(tableName);
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (err.contains('no such table') || err.contains('sqlite_error')) {
        return;
      }
      rethrow;
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(playlists).insert(
        PlaylistsCompanion.insert(id: generateContentId('Likes'), name: 'Likes', isSmart: const Value(true)),
      );
      await into(playlists).insert(
        PlaylistsCompanion.insert(id: generateContentId('Dislikes'), name: 'Dislikes', isSmart: const Value(true)),
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 25) {
        // Recreate all tables to migrate from old integer primary keys to text/string primary keys
        for (final table in allTables) {
          await _safeDeleteTable(m, table.actualTableName);
        }
        await m.createAll();
        await into(playlists).insert(
          PlaylistsCompanion.insert(id: generateContentId('Likes'), name: 'Likes', isSmart: const Value(true)),
        );
        await into(playlists).insert(
          PlaylistsCompanion.insert(id: generateContentId('Dislikes'), name: 'Dislikes', isSmart: const Value(true)),
        );
      }
    },
  );

  // Delegation methods
  Future<void> addFolder(FoldersCompanion folder) => libraryDao.addFolder(folder);
  Future<List<Folder>> getAllFolders() => libraryDao.getAllFolders();
  Future<List<Folder>> getRootFolders({int folderType = 0}) => libraryDao.getRootFolders(folderType: folderType);
  Future<List<Folder>> getSubFolders(String parentId, {int folderType = 0}) => libraryDao.getSubFolders(parentId, folderType: folderType);
  Future<String> ensureFolder(String path, {String? parentId, int folderType = 0}) => libraryDao.ensureFolder(path, parentId: parentId, folderType: folderType);
  Future<String> ensureArtist(String name) => libraryDao.ensureArtist(name);
  Future<String> ensureAlbum(String name, String? artistId, {Uint8List? coverArt, bool isAudiobook = false}) => libraryDao.ensureAlbum(name, artistId, coverArt: coverArt, isAudiobook: isAudiobook);
  Future<String> ensureGenre(String name) => libraryDao.ensureGenre(name);
  Future<List<Artist>> getAllArtists() => libraryDao.getAllArtists();
  Future<List<Album>> getAllAlbums() => libraryDao.getAllAlbums();
  Future<List<Genre>> getAllGenres() => libraryDao.getAllGenres();
  Future<Track?> getTrackById(String id) => libraryDao.getTrackById(id);
  Future<Album?> getAlbumById(String id) => libraryDao.getAlbumById(id);
  Future<List<int>> getAllYears() => libraryDao.getAllYears();
  Future<List<Track>> getTracksForArtist(String artistId) => libraryDao.getTracksForArtist(artistId);
  Future<List<Track>> getTracksForAlbum(String albumId) => libraryDao.getTracksForAlbum(albumId);
  Future<List<Track>> getTracksForGenre(String genreId) => libraryDao.getTracksForGenre(genreId);
  Future<List<Track>> getTracksForYear(int year) => libraryDao.getTracksForYear(year);
  Future<void> updateAlbumArt(String albumId, Uint8List art) => libraryDao.updateAlbumArt(albumId, art);
  Future<void> updateArtistPhoto(String artistId, Uint8List photo) => libraryDao.updateArtistPhoto(artistId, photo);
  Future<void> updateTrackArt(String trackId, Uint8List art) => libraryDao.updateTrackArt(trackId, art);
  Future<List<Track>> getTracksForArtistInAlbum(String artistId, String albumId) => libraryDao.getTracksForArtistInAlbum(artistId, albumId);
  Future<void> cacheArtistAlbumRelations(List<ArtistAlbumRelation> relations) => libraryDao.cacheArtistAlbumRelations(relations);
  Future<void> addTracks(List<TracksCompanion> trackCompanions) => libraryDao.addTracks(trackCompanions);
  Future<List<Track>> getTracksForFolder(String folderId) => libraryDao.getTracksForFolder(folderId);
  Future<List<Track>> getAllTracks() => libraryDao.getAllTracks();
  Future<void> updateTrackRating(String trackId, int rating) => libraryDao.updateTrackRating(trackId, rating);
  Future<List<Track>> getLikedTracks() => libraryDao.getLikedTracks();
  Future<List<Track>> getDislikedTracks() => libraryDao.getDislikedTracks();

  Future<List<Playlist>> getAllPlaylists() => playlistDao.getAllPlaylists();
  Future<void> deletePlaylist(String id) => playlistDao.deletePlaylist(id);
  Future<void> savePlaylistWithTracks(String name, List<String> trackIds, {bool isSmart = false}) => playlistDao.savePlaylistWithTracks(name, trackIds, isSmart: isSmart);
  Future<void> saveSmartPlaylist(String name, String rulesJson) => playlistDao.saveSmartPlaylist(name, rulesJson);
  Future<List<Track>> getTracksForPlaylist(String playlistId) => playlistDao.getTracksForPlaylist(playlistId);
  Future<void> clearQueue() => playlistDao.clearQueue();
  Future<void> saveQueue(List<String> trackIds) => playlistDao.saveQueue(trackIds);
  Future<List<Track>> getQueue() => playlistDao.getQueue();

  // Analytics Delegation
  Future<void> setTrackFavorite(String id, bool favorite) => analyticsDao.setTrackFavorite(id, favorite);
  Future<void> setArtistFavorite(String id, bool favorite) => analyticsDao.setArtistFavorite(id, favorite);
  Future<void> setAlbumFavorite(String id, bool favorite) => analyticsDao.setAlbumFavorite(id, favorite);
  Future<void> recordTrackPlay(String id) => analyticsDao.recordTrackPlay(id);
  Future<void> recordArtistPlay(String id) => analyticsDao.recordArtistPlay(id);
  Future<void> recordAlbumPlay(String id) => analyticsDao.recordAlbumPlay(id);
  Stream<List<Track>> watchFavoriteTracks() => analyticsDao.watchFavoriteTracks();
  Stream<List<Artist>> watchFavoriteArtists() => analyticsDao.watchFavoriteArtists();
  Stream<List<Album>> watchFavoriteAlbums() => analyticsDao.watchFavoriteAlbums();
  Stream<List<Track>> watchMostPlayedTracks({int limit = 20}) => analyticsDao.watchMostPlayedTracks(limit: limit);
}

LazyDatabase _openConnection(String? basePath) {
  return LazyDatabase(() async {
    final path = basePath ?? (await getApplicationDocumentsDirectory()).path;
    final file = File(p.join(path, 'localaudio.sqlite'));
    return NativeDatabase(file);
  });
}

extension TrackToDomain on Track {
  dom_track.PlaybackTrack toDomain() {
    return dom_track.PlaybackTrack(
      id: id,
      path: path,
      title: title,
      artistId: artistId,
      albumId: albumId,
      genreId: genreId,
      year: year,
      duration: durationSeconds != null ? Duration(seconds: durationSeconds!) : null,
      folderId: folderId,
      rating: rating,
      coverArt: coverArt,
      isFavorite: isFavorite,
      playCount: playCount,
      lastPlayed: lastPlayed,
      isAudiobook: isAudiobook,
      isPlayed: isPlayed,
      isStream: isStream,
    );
  }
}
