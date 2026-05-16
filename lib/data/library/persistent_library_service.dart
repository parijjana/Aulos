import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/domain/library/library_service.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

abstract class PersistentLibraryService {
  Future<List<Folder>> getFolders();
  Future<List<Folder>> getRootFolders();
  Future<List<Folder>> getSubFolders(int parentId);
  Future<List<Artist>> getArtists();
  Future<List<Album>> getAlbums();
  Future<List<Genre>> getGenres();
  Future<List<int>> getYears();

  Future<List<Track>> getTracksForFolder(int folderId);
  Future<List<Track>> getTracksForArtist(int artistId);
  Future<List<Track>> getTracksForAlbum(int albumId);
  Future<List<Track>> getTracksForGenre(int genreId);
  Future<List<Track>> getTracksForYear(int year);

  Future<List<Track>> getAllTracks();
  Future<void> importFolder(String path, {VoidCallback? onFileFound});
  Future<void> autoDiscoverTracks();
  Future<void> updateRating(int trackId, int rating);
  Future<void> updateAlbumArt(int albumId, Uint8List art);
  Future<void> updateArtistPhoto(int artistId, Uint8List photo);
  Future<List<Track>> getQueue();
  Future<void> saveQueue(List<int> trackIds);
  Future<List<Playlist>> getPlaylists();
  Future<void> savePlaylist(String name, List<int> trackIds);
  Future<List<Track>> getTracksForPlaylist(int playlistId);
  Future<void> deletePlaylist(int playlistId);
}

class PersistentLibraryServiceImpl implements PersistentLibraryService {
  final AppDatabase _db;
  final LibraryService _scanner;

  PersistentLibraryServiceImpl({
    required AppDatabase db,
    required LibraryService scanner,
  }) : _db = db,
       _scanner = scanner;

  @override
  Future<List<Folder>> getFolders() => _db.getAllFolders();

  @override
  Future<List<Folder>> getRootFolders() => _db.getRootFolders();

  @override
  Future<List<Folder>> getSubFolders(int parentId) =>
      _db.getSubFolders(parentId);

  @override
  Future<List<Artist>> getArtists() => _db.getAllArtists();

  @override
  Future<List<Album>> getAlbums() => _db.getAllAlbums();

  @override
  Future<List<Genre>> getGenres() => _db.getAllGenres();

  @override
  Future<List<int>> getYears() => _db.getAllYears();

  @override
  Future<List<Track>> getTracksForFolder(int folderId) =>
      _db.getTracksForFolder(folderId);

  @override
  Future<List<Track>> getTracksForArtist(int artistId) =>
      _db.getTracksForArtist(artistId);

  @override
  Future<List<Track>> getTracksForAlbum(int albumId) =>
      _db.getTracksForAlbum(albumId);

  @override
  Future<List<Track>> getTracksForGenre(int genreId) =>
      _db.getTracksForGenre(genreId);

  @override
  Future<List<Track>> getTracksForYear(int year) => _db.getTracksForYear(year);

  @override
  Future<List<Track>> getAllTracks() => _db.getAllTracks();

  @override
  Future<void> importFolder(String path, {VoidCallback? onFileFound}) async {
    // 1. Ensure the root folder exists
    final rootId = await _db.ensureFolder(path);

    // 2. Scan all files recursively
    final files = await _scanner.scanDirectory(path);

    // Cache for folder paths to IDs to minimize DB hits
    final Map<String, int> folderCache = {path: rootId};

    for (final f in files) {
      onFileFound?.call();

      // 3. Resolve the folder hierarchy for this file
      final fileDir = p.dirname(f.path);
      final trackFolderId = await _ensureFolderHierarchy(
        fileDir,
        rootId,
        path,
        folderCache,
      );

      // 4. Extract metadata and add track
      final artistId = await _db.ensureArtist(f.artist);
      final albumArtistId = f.albumArtist != null
          ? await _db.ensureArtist(f.albumArtist!)
          : artistId;
      final albumId = f.album != null
          ? await _db.ensureAlbum(f.album!, albumArtistId, coverArt: f.coverArt)
          : null;
      final genreId = f.genre != null ? await _db.ensureGenre(f.genre!) : null;

      await _db.addTracks([
        TracksCompanion(
          path: Value(f.path),
          title: Value(f.title),
          folderId: Value(trackFolderId),
          artistId: Value(artistId),
          albumId: Value(albumId),
          genreId: Value(genreId),
          year: Value(f.year),
          durationSeconds: Value(f.duration?.inSeconds),
          coverArt: Value(f.coverArt),
        ),
      ]);
    }
  }

  Future<int> _ensureFolderHierarchy(
    String currentPath,
    int rootId,
    String rootPath,
    Map<String, int> cache,
  ) async {
    final normalizedCurrent = p.normalize(p.absolute(currentPath));
    final normalizedRoot = p.normalize(p.absolute(rootPath));

    if (cache.containsKey(normalizedCurrent)) return cache[normalizedCurrent]!;
    if (normalizedCurrent == normalizedRoot) return rootId;

    final parentPath = p.dirname(normalizedCurrent);
    if (parentPath == normalizedCurrent) {
      // Reached filesystem root
      return rootId;
    }

    // Recursively ensure parent folders exist up to the root
    final parentId = await _ensureFolderHierarchy(
      parentPath,
      rootId,
      normalizedRoot,
      cache,
    );

    final folderId =
        await _db.ensureFolder(normalizedCurrent, parentId: parentId);
    cache[normalizedCurrent] = folderId;
    return folderId;
  }

  @override
  Future<void> autoDiscoverTracks() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final systemFolderId = await _db.addFolder(
      FoldersCompanion.insert(
        path: 'system://mediastore',
        name: 'Android MediaStore',
      ),
    );

    final files = await _scanner.discoverTracks();

    for (final f in files) {
      final artistId = await _db.ensureArtist(f.artist);
      final albumId = f.album != null
          ? await _db.ensureAlbum(f.album!, artistId, coverArt: f.coverArt)
          : null;

      await _db.addTracks([
        TracksCompanion(
          path: Value(f.path),
          title: Value(f.title),
          folderId: Value(systemFolderId),
          artistId: Value(artistId),
          albumId: Value(albumId),
          durationSeconds: Value(f.duration?.inSeconds),
          coverArt: Value(f.coverArt),
        ),
      ]);
    }
  }

  @override
  Future<void> updateRating(int trackId, int rating) =>
      _db.updateTrackRating(trackId, rating);

  @override
  Future<void> updateAlbumArt(int albumId, Uint8List art) =>
      _db.updateAlbumArt(albumId, art);

  @override
  Future<void> updateArtistPhoto(int artistId, Uint8List photo) =>
      _db.updateArtistPhoto(artistId, photo);

  @override
  Future<List<Track>> getQueue() => _db.getQueue();

  @override
  Future<void> saveQueue(List<int> trackIds) => _db.saveQueue(trackIds);

  @override
  Future<List<Playlist>> getPlaylists() => _db.getAllPlaylists();

  @override
  Future<void> savePlaylist(String name, List<int> trackIds) =>
      _db.savePlaylistWithTracks(name, trackIds);

  @override
  Future<List<Track>> getTracksForPlaylist(int playlistId) =>
      _db.getTracksForPlaylist(playlistId);

  @override
  Future<void> deletePlaylist(int playlistId) => _db.deletePlaylist(playlistId);

  // Partial Views
  Future<List<Album>> getAlbumsForArtist(int artistId) async {
    final query = _db.select(_db.artistAlbumRelations).join([
      innerJoin(
        _db.albums,
        _db.albums.id.equalsExp(_db.artistAlbumRelations.albumId),
      ),
    ])..where(_db.artistAlbumRelations.artistId.equals(artistId));

    final result = await query.get();
    return result.map((row) => row.readTable(_db.albums)).toList();
  }

  Future<List<Track>> getTracksForArtistInAlbum(int artistId, int albumId) =>
      _db.getTracksForArtistInAlbum(artistId, albumId);

  Future<List<Album>> getAlbumsForGenre(int genreId) async {
    final query = _db.selectOnly(_db.tracks, distinct: true)
      ..addColumns([_db.tracks.albumId])
      ..where(_db.tracks.genreId.equals(genreId));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(_db.tracks.albumId))
        .whereType<int>()
        .toList();
    return (_db.select(_db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Album>> getAlbumsForYear(int year) async {
    final query = _db.selectOnly(_db.tracks, distinct: true)
      ..addColumns([_db.tracks.albumId])
      ..where(_db.tracks.year.equals(year));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(_db.tracks.albumId))
        .whereType<int>()
        .toList();
    return (_db.select(_db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Track>> getTracksForGenreInAlbum(int genreId, int albumId) =>
      (_db.select(_db.tracks)..where(
            (t) => t.genreId.equals(genreId) & t.albumId.equals(albumId),
          ))
          .get();

  Future<List<Track>> getTracksForYearInAlbum(int year, int albumId) =>
      (_db.select(
        _db.tracks,
      )..where((t) => t.year.equals(year) & t.albumId.equals(albumId))).get();
}
