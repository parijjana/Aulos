import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
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
  Future<void> importFolder(String path, {VoidCallback? onFileFound, int folderType = 0});
  Future<void> autoDiscoverTracks();
  Future<void> pickAndAddFolder({int folderType = 0});
  Future<void> updateRating(int trackId, int rating);
  Future<void> updateAlbumArt(int albumId, Uint8List art);
  Future<void> updateArtistPhoto(int artistId, Uint8List photo);
  Future<List<Track>> getQueue();
  Future<void> saveQueue(List<int> trackIds);
  Future<List<Playlist>> getPlaylists();
  Future<void> savePlaylist(String name, List<int> trackIds);
  Future<List<Track>> getTracksForPlaylist(int playlistId);
  Future<void> deletePlaylist(int playlistId);

  // Audiobook Specific
  Future<List<Album>> getAudiobooks();
  Future<List<Track>> getChapters(int bookId);
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
  Future<List<Album>> getAudiobooks() => _db.getAudiobooks();

  @override
  Future<List<Track>> getChapters(int bookId) => _db.getChaptersForBook(bookId);

  @override
  Future<void> pickAndAddFolder({int folderType = 0}) async {
    final String? path = await FilePicker.getDirectoryPath();
    if (path != null) {
      await importFolder(path, folderType: folderType);
    }
  }

  @override
  Future<void> importFolder(String path, {VoidCallback? onFileFound, int folderType = 0}) async {
    final bool isAudiobook = folderType == 1;

    final rootId = await _db.ensureFolder(path, folderType: folderType);
    final files = await _scanner.scanDirectory(path);

    final Map<String, int> folderCache = {path: rootId};

    for (final f in files) {
      onFileFound?.call();

      final fileDir = p.dirname(f.path);
      final trackFolderId = await _ensureFolderHierarchy(
        fileDir,
        rootId,
        path,
        folderCache,
        folderType: folderType,
      );

      final artistId = await _db.ensureArtist(f.artist);
      final albumArtistId = f.albumArtist != null
          ? await _db.ensureArtist(f.albumArtist!)
          : artistId;
      
      String bookName = f.album ?? p.basename(fileDir);
      
      final albumId = await _db.ensureAlbum(
        bookName, 
        albumArtistId, 
        coverArt: f.coverArt,
        isAudiobook: isAudiobook,
      );
      
      final genreId = f.genre != null ? await _db.ensureGenre(f.genre!) : null;

      // 4a. Add track or get existing ID
      int effectiveTrackId;
      final existing = await (_db.select(_db.tracks)..where((t) => t.path.equals(f.path))).getSingleOrNull();
      
      if (existing == null) {
        effectiveTrackId = await _db.into(_db.tracks).insert(
          TracksCompanion.insert(
            path: f.path,
            title: f.title,
            folderId: trackFolderId,
            artistId: Value(artistId),
            albumId: Value(albumId),
            genreId: Value(genreId),
            year: Value(f.year),
            durationSeconds: Value(f.duration?.inSeconds),
            coverArt: Value(f.coverArt),
            isAudiobook: Value(isAudiobook),
          ),
        );
      } else {
        effectiveTrackId = existing.id;
        // Optional: Update metadata if it was missing before
        if (existing.albumId == null) {
           await (_db.update(_db.tracks)..where((t) => t.id.equals(effectiveTrackId))).write(TracksCompanion(albumId: Value(albumId)));
        }
      }

      // 4b. ADD CHAPTERS IF PRESENT
      if (f.chapters.isNotEmpty && effectiveTrackId > 0) {
        // Clear existing chapters for this track first to prevent duplicates
        await (_db.delete(_db.chapters)..where((c) => c.trackId.equals(effectiveTrackId))).go();

        final List<ChaptersCompanion> companions = [];
        for (int i = 0; i < f.chapters.length; i++) {
          final chapter = f.chapters[i];
          int? durationMs;
          if (i < f.chapters.length - 1) {
            durationMs = f.chapters[i + 1].startTime.inMilliseconds - chapter.startTime.inMilliseconds;
          } else if (f.duration != null) {
            durationMs = f.duration!.inMilliseconds - chapter.startTime.inMilliseconds;
          }

          companions.add(ChaptersCompanion.insert(
            trackId: effectiveTrackId,
            title: chapter.title,
            startTimeMs: chapter.startTime.inMilliseconds,
            durationMs: Value(durationMs),
          ));
        }
        await _db.addChapters(companions);
      }
    }
  }

  Future<int> _ensureFolderHierarchy(
    String currentPath,
    int rootId,
    String rootPath,
    Map<String, int> cache, {
    int folderType = 0,
  }) async {
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
      folderType: folderType,
    );

    final folderId =
        await _db.ensureFolder(normalizedCurrent, parentId: parentId, folderType: folderType);
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
