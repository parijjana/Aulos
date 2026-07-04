import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/core/utils/id_generator.dart';

class LibriVoxBookDownloader {
  final AudiobookDatabase _db;
  final http.Client _client;
  final LogService _logService;

  LibriVoxBookDownloader({
    required AudiobookDatabase db,
    required http.Client client,
    LogService? logService,
  }) : _db = db,
       _client = client,
       _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  Future<void> streamBook(LibriVoxBook book) async {
    // 1. Ensure Folder for Streaming
    await _db.ensureFolder('LibriVox Streaming');

    // 2. Ensure Artist
    final artistName = book.authorNames;
    final artistId = await _db.ensureArtist(artistName);

    // 3. Ensure Audiobook
    final existingAlbum = await (_db.select(_db.audiobooks)
          ..where((a) => a.librivoxId.equals(book.id)))
        .getSingleOrNull();

    final albumFingerprint = "${book.authorNames}|${book.title}";
    String albumId = generateContentId(albumFingerprint);

    if (existingAlbum != null) {
      albumId = existingAlbum.id;
    } else {
      await _db.into(_db.audiobooks).insert(
        AudiobooksCompanion.insert(
          id: albumId,
          name: book.title,
          artistId: Value(artistId),
          librivoxId: Value(book.id),
          description: Value(book.description),
          isDownloadedViaAulos: const Value(false),
        ),
      );
    }

    // 4. Fetch RSS feed for tracks
    final response = await _client.get(Uri.parse(book.urlRss));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch RSS: ${response.statusCode}');
    }

    final rss = RssFeed.parse(response.body);

    // 5. Insert streaming tracks
    int index = 0;
    for (final item in rss.items) {
      final streamUrl = item.enclosure?.url;
      if (streamUrl == null) continue;

      final durationSecs = item.itunes?.duration?.inSeconds ?? 0;
      final trackTitle = item.title ?? 'Section ${index + 1}';

      final trackPath = streamUrl;
      final existingTrack = await (_db.select(_db.audiobookTracks)
            ..where((t) => t.path.equals(trackPath)))
          .getSingleOrNull();

      if (existingTrack == null) {
        final trackFingerprint = "$artistId|$albumId|$trackTitle|$durationSecs";
        String trackId = generateContentId(trackFingerprint);
        String? duplicateOf;

        final existingWithId = await (_db.select(_db.audiobookTracks)
              ..where((t) => t.id.equals(trackId)))
            .getSingleOrNull();

        if (existingWithId != null && existingWithId.path != trackPath) {
          duplicateOf = trackId;
          trackId = generateContentId("$trackFingerprint|${DateTime.now().millisecondsSinceEpoch}");
        }

        await _db.into(_db.audiobookTracks).insert(
          AudiobookTracksCompanion.insert(
            id: trackId,
            path: trackPath,
            title: trackTitle,
            artistId: Value(artistId),
            audiobookId: Value(albumId),
            isStream: const Value(true),
            durationSeconds: Value(durationSecs),
            duplicateOf: Value(duplicateOf),
          ),
        );
      }
      index++;
    }
    log('LIBRIVOX_DOWNLOADER: Integrated streaming for "${book.title}" successfully.');
  }

  Future<void> downloadBook(LibriVoxBook book, {required void Function(double) onProgress}) async {
    // 1. Determine local Audiobook download directory
    String baseAudiobooksDir;
    final existingFolders = await _db.getRootFolders();
    if (existingFolders.isNotEmpty) {
      baseAudiobooksDir = existingFolders.first.path;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      baseAudiobooksDir = p.join(docDir.path, 'Aulos', 'Audiobooks');
    }

    final sanitizeName = book.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final bookDir = Directory(p.join(baseAudiobooksDir, 'LibriVox', sanitizeName));
    if (!bookDir.existsSync()) {
      await bookDir.create(recursive: true);
    }

    // 2. Download the ZIP file
    final zipFilePath = p.join(bookDir.path, 'package.zip');
    final request = http.Request('GET', Uri.parse(book.urlZipFile));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('ZIP download failed with status ${response.statusCode}');
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

    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(bytes);

    // 3. Extract the ZIP archive
    log('LIBRIVOX_DOWNLOADER: Extracting zip for "${book.title}"...');
    final zipBytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(zipBytes);

    final List<String> extractedFiles = [];
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final filePath = p.join(bookDir.path, filename);
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
        if (filename.toLowerCase().endsWith('.mp3')) {
          extractedFiles.add(filePath);
        }
      }
    }

    // Cleanup ZIP file
    await zipFile.delete();

    // Sort extracted files alphabetically to maintain chapter ordering
    extractedFiles.sort();

    // 4. Ensure Album and Artist in database
    await _db.ensureFolder(bookDir.path);
    final artistId = await _db.ensureArtist(book.authorNames);

    final existingAlbum = await (_db.select(_db.audiobooks)
          ..where((a) => a.librivoxId.equals(book.id)))
        .getSingleOrNull();

    final albumFingerprint = "${book.authorNames}|${book.title}";
    String albumId = generateContentId(albumFingerprint);

    if (existingAlbum != null) {
      albumId = existingAlbum.id;
      // Update to mark downloaded
      await (_db.update(_db.audiobooks)..where((a) => a.id.equals(albumId))).write(
        AudiobooksCompanion(
          isDownloadedViaAulos: const Value(true),
        ),
      );
    } else {
      await _db.into(_db.audiobooks).insert(
        AudiobooksCompanion.insert(
          id: albumId,
          name: book.title,
          artistId: Value(artistId),
          librivoxId: Value(book.id),
          description: Value(book.description),
          isDownloadedViaAulos: const Value(true),
        ),
      );
    }

    // 5. Insert tracks pointing to local paths
    // Delete any existing streaming tracks for this album first (to override with downloaded)
    await (_db.delete(_db.audiobookTracks)..where((t) => t.audiobookId.equals(albumId))).go();

    // Read details from RSS to align track durations & titles if possible
    RssFeed? rss;
    try {
      final rssRes = await _client.get(Uri.parse(book.urlRss));
      if (rssRes.statusCode == 200) {
        rss = RssFeed.parse(rssRes.body);
      }
    } catch (_) {
      // Fallback
    }

    for (int i = 0; i < extractedFiles.length; i++) {
      final localPath = extractedFiles[i];
      final filename = p.basenameWithoutExtension(localPath);
      
      String trackTitle = filename;
      int durationSecs = 0;

      if (rss != null && i < rss.items.length) {
        final rssItem = rss.items[i];
        trackTitle = rssItem.title ?? filename;
        durationSecs = rssItem.itunes?.duration?.inSeconds ?? 0;
      }

      int fileSize = 0;
      try {
        fileSize = File(localPath).lengthSync();
      } catch (_) {}

      final trackFingerprint = "$trackTitle|$artistId|$albumId|$durationSecs|$fileSize";
      String trackId = generateContentId(trackFingerprint);
      String? duplicateOf;

      final existingWithId = await (_db.select(_db.audiobookTracks)
            ..where((t) => t.id.equals(trackId)))
          .getSingleOrNull();

      if (existingWithId != null && existingWithId.path != localPath) {
        duplicateOf = trackId;
        trackId = generateContentId("$trackFingerprint|${DateTime.now().millisecondsSinceEpoch}");
      }

      await _db.into(_db.audiobookTracks).insert(
        AudiobookTracksCompanion.insert(
          id: trackId,
          path: localPath,
          title: trackTitle,
          artistId: Value(artistId),
          audiobookId: Value(albumId),
          isStream: const Value(false),
          durationSeconds: Value(durationSecs),
          duplicateOf: Value(duplicateOf),
        ),
      );
    }

    log('LIBRIVOX_DOWNLOADER: Integrated downloaded audiobook "${book.title}" successfully.');
  }
}
