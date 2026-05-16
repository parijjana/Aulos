import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:drift/drift.dart';
import 'dart:async';

class PodcastDownloadService {
  final AppDatabase _db;
  final http.Client _client;

  PodcastDownloadService({required AppDatabase db, http.Client? client})
      : _db = db,
        _client = client ?? http.Client();

  final Map<int, double> _progressMap = {};
  final StreamController<Map<int, double>> _progressController =
      StreamController<Map<int, double>>.broadcast();

  Stream<Map<int, double>> get progressStream => _progressController.stream;

  Future<void> downloadEpisode(Episode episode, String storageDir) async {
    if (episode.downloadState == 2) return; // Already downloaded

    final directory = Directory(storageDir);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final fileName = '${episode.guid.hashCode}.mp3';
    final filePath = p.join(storageDir, fileName);
    final file = File(filePath);

    try {
      await _db.updateEpisodePlayback(episode.id); // Reset or update state
      // Actually we need a specific update for download state.
      // I will add a helper to the database later if needed, but for now I'll use raw update.
      await _updateDownloadState(episode.id, 1, path: filePath);

      final request = http.Request('GET', Uri.parse(episode.audioUrl));
      final response = await _client.send(request);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download: ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final List<int> bytes = [];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _progressMap[episode.id] = receivedBytes / totalBytes;
          _progressController.add(Map.unmodifiable(_progressMap));
        }
      }

      await file.writeAsBytes(bytes);
      await _updateDownloadState(episode.id, 2, path: filePath);
      _progressMap.remove(episode.id);
      _progressController.add(Map.unmodifiable(_progressMap));
    } catch (e) {
      print('PodcastDownloadService: Download failed for ${episode.title}: $e');
      await _updateDownloadState(episode.id, 3);
      _progressMap.remove(episode.id);
      _progressController.add(Map.unmodifiable(_progressMap));
    }
  }

  Future<void> _updateDownloadState(int id, int state, {String? path}) async {
    // We use a custom query since the generated update helper might not have the new columns yet
    // without a build_runner run, but I already ran it.
    // I'll use the drift companion for safety.
    await (_db.update(_db.episodes)..where((t) => t.id.equals(id))).write(
      EpisodesCompanion(
        downloadState: Value(state),
        localFilePath: path != null ? Value(path) : const Value.absent(),
      ),
    );
  }
}
