import 'dart:io';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/library/jamendo_track.dart';
import 'package:aulos/domain/network/log_service.dart';

import 'package:aulos/core/utils/id_generator.dart';

class JamendoTrackDownloader {
  final AppDatabase _db;
  final http.Client _client;
  final LogService _logService;

  JamendoTrackDownloader({
    required AppDatabase db,
    required http.Client client,
    LogService? logService,
  }) : _db = db,
       _client = client,
       _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  /// Integrates a track as stream in database, returns the database Track object
  Future<Track> streamTrack(JamendoTrack jamendoTrack) async {
    try {
      // 1. Ensure Folder for Jamendo Streams
      final folderId = await _db.ensureFolder('Jamendo Streaming', folderType: 0);

      // 2. Ensure Artist
      final artistId = await _db.ensureArtist(jamendoTrack.artistName);

      // 3. Ensure Album
      final albumId = await _db.ensureAlbum(jamendoTrack.albumName, artistId);

      // 4. Check if track already exists by stream path
      final existingTrack = await (_db.select(_db.tracks)
            ..where((t) => t.path.equals(jamendoTrack.audioUrl)))
          .getSingleOrNull();

      if (existingTrack != null) {
        return existingTrack;
      }

      // 5. Insert track as a stream
      int fileSize = 0;
      final title = jamendoTrack.title;
      final artist = jamendoTrack.artistName;
      final albumName = jamendoTrack.albumName;
      final durSec = jamendoTrack.durationSeconds;
      
      final fingerprint = "$title|$artist|$albumName|$durSec|$fileSize";
      String trackId = generateContentId(fingerprint);
      String? duplicateOf;
      
      final existingWithId = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
      if (existingWithId != null && existingWithId.path != jamendoTrack.audioUrl) {
        duplicateOf = trackId;
        trackId = generateContentId("$fingerprint|${DateTime.now().millisecondsSinceEpoch}");
      }

      await _db.into(_db.tracks).insert(
        TracksCompanion.insert(
          id: trackId,
          path: jamendoTrack.audioUrl,
          title: jamendoTrack.title,
          artistId: Value(artistId),
          albumId: Value(albumId),
          folderId: folderId,
          isAudiobook: const Value(false),
          isStream: const Value(true),
          durationSeconds: Value(durSec),
          duplicateOf: Value(duplicateOf),
        ),
      );

      final track = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingle();
      log('JAMENDO_DOWNLOADER: Integrated stream track "${track.title}" successfully.');
      return track;
    } catch (e) {
      log('JAMENDO_DOWNLOADER: Stream integration failed: $e');
      rethrow;
    }
  }

  /// Downloads track, saves locally, updates path in DB to point to local file, returns database Track object
  Future<Track> downloadTrack(
    JamendoTrack jamendoTrack, {
    required void Function(double) onProgress,
  }) async {
    try {
      // 1. Determine local Music download directory
      String baseMusicDir;
      final existingFolders = await _db.getRootFolders(folderType: 0);
      if (existingFolders.isNotEmpty) {
        baseMusicDir = existingFolders.first.path;
      } else {
        final docDir = await getApplicationDocumentsDirectory();
        baseMusicDir = p.join(docDir.path, 'Aulos', 'Music');
      }

      final sanitizeArtist = jamendoTrack.artistName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final sanitizeTitle = jamendoTrack.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
      final artistDir = Directory(p.join(baseMusicDir, 'Jamendo', sanitizeArtist));
      if (!artistDir.existsSync()) {
        await artistDir.create(recursive: true);
      }

      final localPath = p.join(artistDir.path, '$sanitizeTitle.mp3');

      // 2. Download track file
      final downloadUrl = jamendoTrack.downloadUrl.isNotEmpty ? jamendoTrack.downloadUrl : jamendoTrack.audioUrl;
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await _client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Download failed with status ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final List<int> bytes = [];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      final file = File(localPath);
      await file.writeAsBytes(bytes);

      // 3. Ensure folder, artist, album in database
      final folderId = await _db.ensureFolder(artistDir.path, folderType: 0);
      final artistId = await _db.ensureArtist(jamendoTrack.artistName);
      final albumId = await _db.ensureAlbum(jamendoTrack.albumName, artistId);

      // 4. Update existing stream track to point to local path and set isStream = false,
      // or insert new track if it wasn't streamed before
      final existingStreamTrack = await (_db.select(_db.tracks)
            ..where((t) => t.path.equals(jamendoTrack.audioUrl)))
          .getSingleOrNull();

      String finalTrackId;
      if (existingStreamTrack != null) {
        finalTrackId = existingStreamTrack.id;
        await (_db.update(_db.tracks)..where((t) => t.id.equals(finalTrackId))).write(
          TracksCompanion(
            path: Value(localPath),
            isStream: const Value(false),
          ),
        );
      } else {
        // Check if a track already exists at localPath
        final existingLocalTrack = await (_db.select(_db.tracks)
              ..where((t) => t.path.equals(localPath)))
            .getSingleOrNull();

        if (existingLocalTrack != null) {
          finalTrackId = existingLocalTrack.id;
        } else {
          int fileSize = 0;
          try {
            fileSize = file.lengthSync();
          } catch (_) {}
          
          final title = jamendoTrack.title;
          final artist = jamendoTrack.artistName;
          final albumName = jamendoTrack.albumName;
          final durSec = jamendoTrack.durationSeconds;
          
          String fingerprint = "$title|$artist|$albumName|$durSec|$fileSize";
          String trackId = generateContentId(fingerprint);
          String? duplicateOf;
          
          final existingWithId = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
          if (existingWithId != null && existingWithId.path != localPath) {
            duplicateOf = trackId;
            fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
            trackId = generateContentId(fingerprint);
          }

          await _db.into(_db.tracks).insert(
            TracksCompanion.insert(
              id: trackId,
              path: localPath,
              title: jamendoTrack.title,
              artistId: Value(artistId),
              albumId: Value(albumId),
              folderId: folderId,
              isAudiobook: const Value(false),
              isStream: const Value(false),
              durationSeconds: Value(durSec),
              duplicateOf: Value(duplicateOf),
            ),
          );
          finalTrackId = trackId;
        }
      }

      final track = await (_db.select(_db.tracks)..where((t) => t.id.equals(finalTrackId))).getSingle();
      log('JAMENDO_DOWNLOADER: Integrated downloaded track "${track.title}" successfully.');
      return track;
    } catch (e) {
      log('JAMENDO_DOWNLOADER: Download failed: $e');
      rethrow;
    }
  }
}
