import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/core/utils/id_generator.dart';
import 'persistent_library_service.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> _saveArtToDisk(Uint8List? art, String generatedId) async {
  if (art == null) return null;
  final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'artwork'));
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File(p.join(dir.path, '$generatedId.jpg'));
  if (!file.existsSync()) {
    await file.writeAsBytes(art);
  }
  return file.path;
}

extension PersistentLibraryImportExtension on PersistentLibraryServiceImpl {
  Future<void> pickAndAddFolder({int folderType = 0}) async {
    final String? path = await FilePicker.getDirectoryPath();
    if (path != null) {
      await importFolder(path, folderType: folderType);
    }
  }

  Future<void> importFolder(String path, {VoidCallback? onFileFound, int folderType = 0}) async {
    final bool isAudiobook = folderType == 1;

    if (isAudiobook) {
      final rootId = await audiobookDb.ensureFolder(path);
      final existingPaths = (await audiobookDb.select(audiobookDb.audiobookTracks).get())
          .map((t) => t.path)
          .toSet();
      final files = await scanner.scanDirectory(path, existingPaths: existingPaths);

      final Map<String, String> folderCache = {path: rootId};

      for (final f in files) {
        final fileDir = p.dirname(f.path);
        await ensureFolderHierarchy(
          fileDir,
          rootId,
          path,
          folderCache,
          folderType: folderType,
        );

        final artistId = await audiobookDb.ensureArtist(f.artist);
        final albumArtistId = f.albumArtist != null
            ? await audiobookDb.ensureArtist(f.albumArtist!)
            : artistId;
        
        String bookName = f.album ?? p.basename(fileDir);
        
        final albumFingerprint = "${albumArtistId}|$bookName";
        final albumIdExpected = generateContentId(albumFingerprint);
        final albumArtPath = await _saveArtToDisk(f.coverArt, albumIdExpected);

        final albumId = await audiobookDb.ensureAudiobook(
          bookName, 
          albumArtistId, 
          localArtPath: albumArtPath,
        );

        String effectiveTrackId;
        final existing = await (audiobookDb.select(audiobookDb.audiobookTracks)..where((t) => t.path.equals(f.path))).getSingleOrNull();
        
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
          
          final existingWithId = await (audiobookDb.select(audiobookDb.audiobookTracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
          if (existingWithId != null && existingWithId.path != f.path) {
            duplicateOf = trackId;
            fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
            trackId = generateContentId(fingerprint);
          }

          final trackArtPath = await _saveArtToDisk(f.coverArt, trackId);

          await audiobookDb.into(audiobookDb.audiobookTracks).insert(
            AudiobookTracksCompanion.insert(
              id: trackId,
              path: f.path,
              title: f.title,
              artistId: Value(artistId),
              audiobookId: Value(albumId),
              durationSeconds: Value(f.duration?.inSeconds),
              coverArt: const Value(null),
              localArtPath: Value(trackArtPath),
              isStream: const Value(false),
              duplicateOf: Value(duplicateOf),
            ),
          );
          effectiveTrackId = trackId;
        } else {
          effectiveTrackId = existing.id;
          if (existing.audiobookId == null) {
             await (audiobookDb.update(audiobookDb.audiobookTracks)..where((t) => t.id.equals(effectiveTrackId))).write(AudiobookTracksCompanion(audiobookId: Value(albumId)));
          }
        }

        if (f.chapters.isNotEmpty) {
          await (audiobookDb.delete(audiobookDb.audiobookChapters)..where((c) => c.audiobookTrackId.equals(effectiveTrackId))).go();

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
          await audiobookDb.addChapters(companions);
        }
      }
      return;
    }

    final rootId = await db.ensureFolder(path, folderType: folderType);
    final existingPaths = (await db.select(db.tracks).get())
        .map((t) => t.path)
        .toSet();
    final files = await scanner.scanDirectory(path, existingPaths: existingPaths);

    final Map<String, String> folderCache = {path: rootId};

    for (final f in files) {
      final fileDir = p.dirname(f.path);
      final trackFolderId = await ensureFolderHierarchy(
        fileDir,
        rootId,
        path,
        folderCache,
        folderType: folderType,
      );

      final artistId = await db.ensureArtist(f.artist);
      final albumArtistId = f.albumArtist != null
          ? await db.ensureArtist(f.albumArtist!)
          : artistId;
      
      String bookName = f.album ?? p.basename(fileDir);
      
      final albumFingerprint = "${albumArtistId}|$bookName";
      final albumIdExpected = generateContentId(albumFingerprint);
      final albumArtPath = await _saveArtToDisk(f.coverArt, albumIdExpected);

      final albumId = await db.ensureAlbum(
        bookName, 
        albumArtistId, 
        localArtPath: albumArtPath,
        isAudiobook: isAudiobook,
      );
      
      final genreId = f.genre != null ? await db.ensureGenre(f.genre!) : null;

      String effectiveTrackId;
      final existing = await (db.select(db.tracks)..where((t) => t.path.equals(f.path))).getSingleOrNull();
      
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
        
        final existingWithId = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
        if (existingWithId != null && existingWithId.path != f.path) {
          duplicateOf = trackId;
          fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
          trackId = generateContentId(fingerprint);
        }

        final trackArtPath = await _saveArtToDisk(f.coverArt, trackId);

        await db.into(db.tracks).insert(
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
            coverArt: const Value(null),
            localArtPath: Value(trackArtPath),
            isAudiobook: Value(isAudiobook),
            duplicateOf: Value(duplicateOf),
          ),
        );
        effectiveTrackId = trackId;
      } else {
        effectiveTrackId = existing.id;
        if (existing.albumId == null) {
           await (db.update(db.tracks)..where((t) => t.id.equals(effectiveTrackId))).write(TracksCompanion(albumId: Value(albumId)));
        }
      }
    }
  }

  Future<String> ensureFolderHierarchy(
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

    final parentId = await ensureFolderHierarchy(
      parentPath,
      rootId,
      normalizedRoot,
      cache,
      folderType: folderType,
    );

    final folderId = folderType == 1
        ? await audiobookDb.ensureFolder(normalizedCurrent, parentId: parentId)
        : await db.ensureFolder(normalizedCurrent, parentId: parentId, folderType: folderType);
    cache[normalizedCurrent] = folderId;
    return folderId;
  }

  Future<void> autoDiscoverTracks() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final systemFolderId = generateContentId('system://mediastore');
    await db.addFolder(
      FoldersCompanion.insert(
        id: systemFolderId,
        path: 'system://mediastore',
        name: 'Android MediaStore',
      ),
    );

    final files = await scanner.discoverTracks();

    for (final f in files) {
      final artistId = await db.ensureArtist(f.artist);
      String? albumId;
      if (f.album != null) {
        final albumFingerprint = "${artistId}|${f.album!}";
        final albumIdExpected = generateContentId(albumFingerprint);
        final albumArtPath = await _saveArtToDisk(f.coverArt, albumIdExpected);
        albumId = await db.ensureAlbum(f.album!, artistId, localArtPath: albumArtPath);
      }

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
      
      final existingWithId = await (db.select(db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
      if (existingWithId != null && existingWithId.path != f.path) {
        duplicateOf = trackId;
        fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
        trackId = generateContentId(fingerprint);
      }

      final trackArtPath = await _saveArtToDisk(f.coverArt, trackId);

      await db.addTracks([
        TracksCompanion(
          id: Value(trackId),
          path: Value(f.path),
          title: Value(f.title),
          folderId: Value(systemFolderId),
          artistId: Value(artistId),
          albumId: Value(albumId),
          durationSeconds: Value(f.duration?.inSeconds),
          coverArt: const Value(null),
          localArtPath: Value(trackArtPath),
          duplicateOf: Value(duplicateOf),
        ),
      ]);
    }
  }
}
