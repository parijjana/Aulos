import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/discovery_sync_manager.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:path/path.dart' as p;

class PodcastStorageManager {
  final AppDatabase _db;
  final SettingsViewModel _settingsVM;
  
  PodcastStorageManager({
    required AppDatabase db,
    required SettingsViewModel settingsVM,
  }) : _db = db, _settingsVM = settingsVM;

  /// Prunes old or excessive downloads based on user settings.
  /// Enforces an AND condition: Episode is deleted if it exceeds the count limit
  /// OR if it exceeds the age limit.
  Future<void> pruneDownloads() async {
    final storagePath = _settingsVM.podcastStorageLocation;
    if (storagePath == null) return;

    final keepCount = _settingsVM.podcastKeepCount;
    final keepDays = _settingsVM.podcastKeepDays;

    final allPodcasts = await _db.getAllPodcasts();
    
    for (final podcast in allPodcasts) {
      final episodes = await _db.getEpisodesForPodcast(podcast.id);
      final downloaded = episodes.where((e) => e.downloadState == 2 && !e.isPinned).toList();
      
      // Sort by pubDate descending (newest first)
      downloaded.sort((a, b) => (b.pubDate ?? DateTime(0)).compareTo(a.pubDate ?? DateTime(0)));

      for (int i = 0; i < downloaded.length; i++) {
        final ep = downloaded[i];
        bool shouldPrune = false;

        // Condition 1: Position in list exceeds keepCount
        // (i.e. this is the 6th newest episode but we only keep 5)
        if (i >= keepCount) {
          shouldPrune = true;
        }

        // Condition 2: Age exceeds keepDays
        if (!shouldPrune && ep.pubDate != null) {
          final age = DateTime.now().difference(ep.pubDate!);
          if (age.inDays >= keepDays) {
            shouldPrune = true;
          }
        }

        if (shouldPrune && ep.localFilePath != null) {
          await _deleteFile(ep.localFilePath!);
          await _db.updateEpisodePlayback(ep.id, downloadState: 0, localFilePath: null);
          debugPrint('PodcastStorageManager: Pruned ${ep.title} (Reason: ${i >= keepCount ? "Count Limit" : "Age Limit"})');
        }
      }
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('PodcastStorageManager: Failed to delete file: $e');
    }
  }
}
