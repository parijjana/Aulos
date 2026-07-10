import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

class StorageManagerService {
  final SettingsViewModel _settingsVM;
  final AudiobookDatabase _audiobookDb;

  StorageManagerService({
    required SettingsViewModel settingsVM,
    required AudiobookDatabase audiobookDb,
  })  : _settingsVM = settingsVM,
        _audiobookDb = audiobookDb;

  /// Resolves the local podcast downloads directory
  Future<String> getPodcastDirectoryPath() async {
    final configuredPath = _settingsVM.podcastStorageLocation;
    if (configuredPath != null && configuredPath.isNotEmpty) {
      return configuredPath;
    }
    final docDir = await getApplicationDocumentsDirectory();
    return p.join(docDir.path, 'Aulos', 'Podcasts');
  }

  /// Resolves the local audiobook downloads directory
  Future<String> getAudiobookDirectoryPath() async {
    final existingFolders = await _audiobookDb.getRootFolders();
    if (existingFolders.isNotEmpty) {
      return existingFolders.first.path;
    }
    final docDir = await getApplicationDocumentsDirectory();
    return p.join(docDir.path, 'Aulos', 'Audiobooks');
  }

  /// Calculates total size of downloaded podcast episodes
  Future<int> getPodcastCacheSize() async {
    final path = await getPodcastDirectoryPath();
    return _getDirectorySize(Directory(path));
  }

  /// Calculates total size of downloaded audiobooks
  Future<int> getAudiobookCacheSize() async {
    final path = await getAudiobookDirectoryPath();
    return _getDirectorySize(Directory(path));
  }

  /// Opens the podcast downloads folder in default file explorer/finder
  Future<void> openPodcastFolder() async {
    final path = await getPodcastDirectoryPath();
    await _launchFolder(path);
  }

  /// Opens the audiobook downloads folder in default file explorer/finder
  Future<void> openAudiobookFolder() async {
    final path = await getAudiobookDirectoryPath();
    await _launchFolder(path);
  }

  Future<int> _getDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      debugPrint('StorageManagerService: Error calculating size for ${directory.path}: $e');
    }
    return totalSize;
  }

  Future<void> _launchFolder(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    try {
      final uri = Uri.directory(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (Platform.isWindows) {
          await Process.run('explorer.exe', [path]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [path]);
        } else if (Platform.isLinux) {
          await Process.run('xdg-open', [path]);
        } else {
          throw Exception('Platform launch not supported');
        }
      }
    } catch (e) {
      debugPrint('StorageManagerService: Error launching folder $path: $e');
      // Final fallback to platform specific runner directly
      try {
        if (Platform.isWindows) {
          await Process.run('explorer.exe', [path]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [path]);
        } else if (Platform.isLinux) {
          await Process.run('xdg-open', [path]);
        }
      } catch (innerEx) {
        debugPrint('StorageManagerService: Direct process runner execution failed: $innerEx');
      }
    }
  }
}
