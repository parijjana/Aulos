import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:aulos/core/utils/id_generator.dart';

abstract class PersistentLibraryService {
  Future<List<Folder>> getFolders();
  Future<List<Folder>> getRootFolders({int folderType = 0});
  Future<List<Folder>> getSubFolders(String parentId, {int folderType = 0});
  Future<List<Artist>> getArtists();
  Future<List<Album>> getAlbums();
  Future<List<Genre>> getGenres();
  Future<List<int>> getYears();

  Future<List<Track>> getTracksForFolder(String folderId);
  Future<List<Track>> getTracksForArtist(String artistId);
  Future<List<Track>> getTracksForAlbum(String albumId);
  Future<List<Track>> getTracksForGenre(String genreId);
  Future<List<Track>> getTracksForYear(int year);

  Future<List<Track>> getAllTracks();
  Future<void> importFolder(String path, {VoidCallback? onFileFound, int folderType = 0});
  Future<void> autoDiscoverTracks();
  Future<void> pickAndAddFolder({int folderType = 0});
  Future<void> updateRating(String trackId, int rating);
  Future<void> updateAlbumArt(String albumId, Uint8List art);
  Future<void> updateArtistPhoto(String artistId, Uint8List photo);
  Future<List<Track>> getQueue();
  Future<void> saveQueue(List<String> trackIds);
  Future<List<Playlist>> getPlaylists();
  Future<void> savePlaylist(String name, List<String> trackIds);
  Future<List<Track>> getTracksForPlaylist(String playlistId);
  Future<void> deletePlaylist(String playlistId);

  // Audiobook Specific
  Future<List<Album>> getAudiobooks();
  Future<List<Track>> getChapters(String bookId);
}

class PersistentLibraryServiceImpl implements PersistentLibraryService {
  final AppDatabase _db;
  final AudiobookDatabase _audiobookDb;
  final LibraryService _scanner;

  PersistentLibraryServiceImpl({
    required AppDatabase db,
    required AudiobookDatabase audiobookDb,
    required LibraryService scanner,
  }) : _db = db,
       _audiobookDb = audiobookDb,
       _scanner = scanner;

  AppDatabase get db => _db;
  AudiobookDatabase get audiobookDb => _audiobookDb;

  @override
  Future<List<Folder>> getFolders() => _db.getAllFolders();

  @override
  Future<List<Folder>> getRootFolders({int folderType = 0}) async {
    if (folderType == 1) {
      final list = await _audiobookDb.getRootFolders();
      return list.map((f) => Folder(
        id: f.id,
        path: f.path,
        name: f.name,
        parentId: f.parentId,
        folderType: 1,
      )).toList();
    }
    return _db.getRootFolders(folderType: folderType);
  }

  @override
  Future<List<Folder>> getSubFolders(String parentId, {int folderType = 0}) async {
    if (folderType == 1) {
      final list = await _audiobookDb.getSubFolders(parentId);
      return list.map((f) => Folder(
        id: f.id,
        path: f.path,
        name: f.name,
        parentId: f.parentId,
        folderType: 1,
      )).toList();
    }
    return _db.getSubFolders(parentId, folderType: folderType);
  }

  @override
  Future<List<Artist>> getArtists() => _db.getAllArtists();

  @override
  Future<List<Album>> getAlbums() => _db.getAllAlbums();

  @override
  Future<List<Genre>> getGenres() => _db.getAllGenres();

  @override
  Future<List<int>> getYears() => _db.getAllYears();

  @override
  Future<List<Track>> getTracksForFolder(String folderId) =>
      _db.getTracksForFolder(folderId);

  @override
  Future<List<Track>> getTracksForArtist(String artistId) =>
      _db.getTracksForArtist(artistId);

  @override
  Future<List<Track>> getTracksForAlbum(String albumId) =>
      _db.getTracksForAlbum(albumId);

  @override
  Future<List<Track>> getTracksForGenre(String genreId) =>
      _db.getTracksForGenre(genreId);

  @override
  Future<List<Track>> getTracksForYear(int year) => _db.getTracksForYear(year);

  @override
  Future<List<Track>> getAllTracks() => _db.getAllTracks();

  @override
  Future<List<Album>> getAudiobooks() async {
    final list = await _audiobookDb.getAudiobooks();
    return list.map((a) => Album(
      id: a.id,
      name: a.name,
      artistId: a.artistId,
      coverArt: a.coverArt,
      coverArtUrl: a.coverArtUrl,
      isFavorite: a.isFavorite,
      playCount: a.playCount,
      lastPlayed: a.lastPlayed,
      isAudiobook: true,
      asin: a.asin,
      subtitle: a.subtitle,
      seriesName: a.seriesName,
      seriesPosition: a.seriesPosition,
      narrator: a.narrator,
      description: a.description,
      publisher: a.publisher,
      publishedDate: a.publishedDate,
      isPlayed: a.isPlayed,
      librivoxId: a.librivoxId,
      isDownloadedViaAulos: a.isDownloadedViaAulos,
    )).toList();
  }

  @override
  Future<List<Track>> getChapters(String bookId) async {
    final list = await _audiobookDb.getTracksForBook(bookId);
    return list.map((t) => Track(
      id: t.id,
      path: t.path,
      title: t.title,
      artistId: t.artistId,
      albumId: t.audiobookId,
      genreId: null,
      year: null,
      durationSeconds: t.durationSeconds,
      folderId: '',
      rating: t.rating,
      coverArt: t.coverArt,
      isFavorite: t.isFavorite,
      playCount: t.playCount,
      lastPlayed: t.lastPlayed,
      isAudiobook: true,
      isPlayed: t.isPlayed,
      isStream: t.isStream,
    )).toList();
  }

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

    if (isAudiobook) {
      final rootId = await _audiobookDb.ensureFolder(path);
      final existingPaths = (await _audiobookDb.select(_audiobookDb.audiobookTracks).get())
          .map((t) => t.path)
          .toSet();
      final files = await _scanner.scanDirectory(path, existingPaths: existingPaths);

      final Map<String, String> folderCache = {path: rootId};

      for (final f in files) {
        final fileDir = p.dirname(f.path);
        final trackFolderId = await _ensureFolderHierarchy(
          fileDir,
          rootId,
          path,
          folderCache,
          folderType: folderType,
        );

        final artistId = await _audiobookDb.ensureArtist(f.artist);
        final albumArtistId = f.albumArtist != null
            ? await _audiobookDb.ensureArtist(f.albumArtist!)
            : artistId;
        
        String bookName = f.album ?? p.basename(fileDir);
        
        final albumId = await _audiobookDb.ensureAudiobook(
          bookName, 
          albumArtistId, 
          coverArt: f.coverArt,
        );

        String effectiveTrackId;
        final existing = await (_audiobookDb.select(_audiobookDb.audiobookTracks)..where((t) => t.path.equals(f.path))).getSingleOrNull();
        
        if (existing == null) {
          onFileFound?.call();
          int fileSize = 0;
          try {
            fileSize = File(f.path).lengthSync();
          } catch (_) {}
          
          final title = f.title;
          final artist = f.artist;
          final albumName = f.album ?? '';
          final durSec = f.duration?.inSeconds ?? 0;
          final folderName = p.basename(p.dirname(f.path));
          final fileName = p.basename(f.path);
          
          String fingerprint = (title.isNotEmpty && artist.isNotEmpty)
              ? "$title|$artist|$albumName|$durSec|$fileSize"
              : "$folderName|$fileName";
              
          String trackId = generateContentId(fingerprint);
          String? duplicateOf;
          
          final existingWithId = await (_audiobookDb.select(_audiobookDb.audiobookTracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
          if (existingWithId != null && existingWithId.path != f.path) {
            duplicateOf = trackId;
            fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
            trackId = generateContentId(fingerprint);
          }

          await _audiobookDb.into(_audiobookDb.audiobookTracks).insert(
            AudiobookTracksCompanion.insert(
              id: trackId,
              path: f.path,
              title: f.title,
              artistId: Value(artistId),
              audiobookId: Value(albumId),
              durationSeconds: Value(f.duration?.inSeconds),
              coverArt: Value(f.coverArt),
              isStream: const Value(false),
              duplicateOf: Value(duplicateOf),
            ),
          );
          effectiveTrackId = trackId;
        } else {
          effectiveTrackId = existing.id;
          if (existing.audiobookId == null) {
             await (_audiobookDb.update(_audiobookDb.audiobookTracks)..where((t) => t.id.equals(effectiveTrackId))).write(AudiobookTracksCompanion(audiobookId: Value(albumId)));
          }
        }

        if (f.chapters.isNotEmpty) {
          await (_audiobookDb.delete(_audiobookDb.audiobookChapters)..where((c) => c.audiobookTrackId.equals(effectiveTrackId))).go();

          final List<AudiobookChaptersCompanion> companions = [];
          for (int i = 0; i < f.chapters.length; i++) {
            final chapter = f.chapters[i];
            int? durationMs;
            if (i < f.chapters.length - 1) {
              durationMs = f.chapters[i + 1].startTime.inMilliseconds - chapter.startTime.inMilliseconds;
            } else if (f.duration != null) {
              durationMs = f.duration!.inMilliseconds - chapter.startTime.inMilliseconds;
            }

            // Generate deterministic ID for chapter
            final chapterFingerprint = "$effectiveTrackId|${chapter.title}|${chapter.startTime.inMilliseconds}";
            final chapterId = generateContentId(chapterFingerprint);

            companions.add(AudiobookChaptersCompanion.insert(
              id: chapterId,
              audiobookTrackId: effectiveTrackId,
              title: chapter.title,
              startTimeMs: chapter.startTime.inMilliseconds,
              durationMs: Value(durationMs),
            ));
          }
          await _audiobookDb.addChapters(companions);
        }
      }
      return;
    }

    final rootId = await _db.ensureFolder(path, folderType: folderType);
    final existingPaths = (await _db.select(_db.tracks).get())
        .map((t) => t.path)
        .toSet();
    final files = await _scanner.scanDirectory(path, existingPaths: existingPaths);

    final Map<String, String> folderCache = {path: rootId};

    for (final f in files) {
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

      String effectiveTrackId;
      final existing = await (_db.select(_db.tracks)..where((t) => t.path.equals(f.path))).getSingleOrNull();
      
      if (existing == null) {
        onFileFound?.call();
        int fileSize = 0;
        try {
          fileSize = File(f.path).lengthSync();
        } catch (_) {}
        
        final title = f.title;
        final artist = f.artist;
        final albumName = f.album ?? '';
        final durSec = f.duration?.inSeconds ?? 0;
        final folderName = p.basename(p.dirname(f.path));
        final fileName = p.basename(f.path);
        
        String fingerprint = (title.isNotEmpty && artist.isNotEmpty)
            ? "$title|$artist|$albumName|$durSec|$fileSize"
            : "$folderName|$fileName";
            
        String trackId = generateContentId(fingerprint);
        String? duplicateOf;
        
        final existingWithId = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
        if (existingWithId != null && existingWithId.path != f.path) {
          duplicateOf = trackId;
          fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
          trackId = generateContentId(fingerprint);
        }

        await _db.into(_db.tracks).insert(
          TracksCompanion.insert(
            id: trackId,
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
            duplicateOf: Value(duplicateOf),
          ),
        );
        effectiveTrackId = trackId;
      } else {
        effectiveTrackId = existing.id;
        if (existing.albumId == null) {
           await (_db.update(_db.tracks)..where((t) => t.id.equals(effectiveTrackId))).write(TracksCompanion(albumId: Value(albumId)));
        }
      }
    }
  }

  Future<String> _ensureFolderHierarchy(
    String currentPath,
    String rootId,
    String rootPath,
    Map<String, String> cache, {
    int folderType = 0,
  }) async {
    final normalizedCurrent = p.normalize(p.absolute(currentPath));
    final normalizedRoot = p.normalize(p.absolute(rootPath));

    if (cache.containsKey(normalizedCurrent)) return cache[normalizedCurrent]!;
    if (normalizedCurrent == normalizedRoot) return rootId;

    final parentPath = p.dirname(normalizedCurrent);
    if (parentPath == normalizedCurrent) {
      return rootId;
    }

    final parentId = await _ensureFolderHierarchy(
      parentPath,
      rootId,
      normalizedRoot,
      cache,
      folderType: folderType,
    );

    final folderId = folderType == 1
        ? await _audiobookDb.ensureFolder(normalizedCurrent, parentId: parentId)
        : await _db.ensureFolder(normalizedCurrent, parentId: parentId, folderType: folderType);
    cache[normalizedCurrent] = folderId;
    return folderId;
  }

  @override
  Future<void> autoDiscoverTracks() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final systemFolderId = generateContentId('system://mediastore');
    await _db.addFolder(
      FoldersCompanion.insert(
        id: systemFolderId,
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

      int fileSize = 0;
      try {
        fileSize = File(f.path).lengthSync();
      } catch (_) {}
      
      final title = f.title;
      final artist = f.artist;
      final albumName = f.album ?? '';
      final durSec = f.duration?.inSeconds ?? 0;
      final folderName = p.basename(p.dirname(f.path));
      final fileName = p.basename(f.path);
      
      String fingerprint = (title.isNotEmpty && artist.isNotEmpty)
          ? "$title|$artist|$albumName|$durSec|$fileSize"
          : "$folderName|$fileName";
          
      String trackId = generateContentId(fingerprint);
      String? duplicateOf;
      
      final existingWithId = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
      if (existingWithId != null && existingWithId.path != f.path) {
        duplicateOf = trackId;
        fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
        trackId = generateContentId(fingerprint);
      }

      await _db.addTracks([
        TracksCompanion(
          id: Value(trackId),
          path: Value(f.path),
          title: Value(f.title),
          folderId: Value(systemFolderId),
          artistId: Value(artistId),
          albumId: Value(albumId),
          durationSeconds: Value(f.duration?.inSeconds),
          coverArt: Value(f.coverArt),
          duplicateOf: Value(duplicateOf),
        ),
      ]);
    }
  }

  @override
  Future<void> updateRating(String trackId, int rating) =>
      _db.updateTrackRating(trackId, rating);

  @override
  Future<void> updateAlbumArt(String albumId, Uint8List art) =>
      _db.updateAlbumArt(albumId, art);

  @override
  Future<void> updateArtistPhoto(String artistId, Uint8List photo) =>
      _db.updateArtistPhoto(artistId, photo);

  @override
  Future<List<Track>> getQueue() => _db.getQueue();

  @override
  Future<void> saveQueue(List<String> trackIds) => _db.saveQueue(trackIds);

  @override
  Future<List<Playlist>> getPlaylists() => _db.getAllPlaylists();

  @override
  Future<void> savePlaylist(String name, List<String> trackIds) =>
      _db.savePlaylistWithTracks(name, trackIds);

  @override
  Future<List<Track>> getTracksForPlaylist(String playlistId) =>
      _db.getTracksForPlaylist(playlistId);

  @override
  Future<void> deletePlaylist(String playlistId) => _db.deletePlaylist(playlistId);

  // Partial Views
  Future<List<Album>> getAlbumsForArtist(String artistId) async {
    final query = _db.select(_db.artistAlbumRelations).join([
      innerJoin(
        _db.albums,
        _db.albums.id.equalsExp(_db.artistAlbumRelations.albumId),
      ),
    ])..where(_db.artistAlbumRelations.artistId.equals(artistId));

    final result = await query.get();
    return result.map((row) => row.readTable(_db.albums)).toList();
  }

  Future<List<Track>> getTracksForArtistInAlbum(String artistId, String albumId) =>
      _db.getTracksForArtistInAlbum(artistId, albumId);

  Future<List<Album>> getAlbumsForGenre(String genreId) async {
    final query = _db.selectOnly(_db.tracks, distinct: true)
      ..addColumns([_db.tracks.albumId])
      ..where(_db.tracks.genreId.equals(genreId));
    final rows = await query.get();
    final albumIds = rows
        .map((r) => r.read(_db.tracks.albumId))
        .whereType<String>()
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
        .whereType<String>()
        .toList();
    return (_db.select(_db.albums)..where((a) => a.id.isIn(albumIds))).get();
  }

  Future<List<Track>> getTracksForGenreInAlbum(String genreId, String albumId) =>
      (_db.select(_db.tracks)..where(
            (t) => t.genreId.equals(genreId) & t.albumId.equals(albumId),
          ))
          .get();

  Future<List<Track>> getTracksForYearInAlbum(int year, String albumId) =>
      (_db.select(
        _db.tracks,
      )..where((t) => t.year.equals(year) & t.albumId.equals(albumId))).get();
}
