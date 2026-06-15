import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:aulos/data/database/podcast_database.dart';
import 'package:drift/drift.dart';
import 'dart:async';
import 'package:aulos/domain/network/log_service.dart';

class PodcastDownloadService {
  final PodcastDatabase _db;
  final http.Client _client;
  final LogService _logService;

  PodcastDownloadService({
    required PodcastDatabase db,
    LogService? logService,
    http.Client? client,
  })  : _db = db,
        _client = client ?? http.Client(),
        _logService = logService ?? NoOpLogService();

  void log(String message) => _logService.log(message);

  final Map<String, double> _progressMap = {};
  final StreamController<Map<String, double>> _progressController =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream => _progressController.stream;

  Future<void> downloadEpisode(Episode episode, String storageDir) async {
    if (episode.downloadState == 2) {
      log('STORAGE: Episode "${episode.title}" already downloaded. Skipping.');
      return; 
    }

    log('STORAGE: Starting download for "${episode.title}"');

    // 1. Fetch Podcast metadata for folder naming
    final podcast = await (_db.select(_db.podcasts)..where((t) => t.id.equals(episode.podcastId))).getSingleOrNull();
    final podcastName = _sanitize(podcast?.title ?? 'Unknown Podcast');
    final episodeName = _sanitize(episode.title);
    
    final podDirectory = Directory(p.join(storageDir, podcastName));
    if (!podDirectory.existsSync()) {
      await podDirectory.create(recursive: true);
      log('STORAGE: Created directory: ${podDirectory.path}');
    }

    final fileName = '$episodeName.mp3';
    final filePath = p.join(podDirectory.path, fileName);
    final file = File(filePath);

    try {
      await _updateDownloadState(episode.id, 1, path: filePath);

      final request = http.Request('GET', Uri.parse(episode.audioUrl));
      final response = await _client.send(request);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download: ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final List<int> bytes = [];
      double lastEmittedProgress = -1.0;

      log('STORAGE: Downloading ${totalBytes > 0 ? (totalBytes / 1024 / 1024).toStringAsFixed(2) : "unknown"} MB...');

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          final progress = receivedBytes / totalBytes;
          // Only emit and log if progress moves by at least 1%
          if ((progress - lastEmittedProgress).abs() > 0.01) {
            lastEmittedProgress = progress;
            _progressMap[episode.id] = progress;
            _progressController.add(Map.unmodifiable(_progressMap));
          }
        }
      }

      await file.writeAsBytes(bytes);
      await _updateDownloadState(episode.id, 2, path: filePath);
      
      log('STORAGE: Download complete. Saved to: ${file.path}');
      
      _progressMap.remove(episode.id);
      _progressController.add(Map.unmodifiable(_progressMap));
    } catch (e) {
      log('STORAGE: Download failed for ${episode.title}: $e');
      await _updateDownloadState(episode.id, 3);
      _progressMap.remove(episode.id);
      _progressController.add(Map.unmodifiable(_progressMap));
    }
  }

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }

  Future<void> _updateDownloadState(String id, int state, {String? path}) async {
    await _db.updateEpisodePlayback(id, downloadState: state, localFilePath: path);
  }
}
