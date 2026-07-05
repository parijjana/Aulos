import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageDirectoryManager {
  static const String customPathKey = 'custom_database_directory';
  final SharedPreferences _prefs;

  StorageDirectoryManager(this._prefs);

  Future<String> getDefaultSupportDirectoryPath() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  /// Resolves the base directory for database storage based on configuration
  Future<Directory> getDatabaseDirectory() async {
    // 1. Check for Portable Mode indicator file next to the executable
    try {
      final exeDir = File(Platform.resolvedExecutable).parent;
      final portableIndicator = File(p.join(exeDir.path, 'aulos_portable.txt'));

      if (await portableIndicator.exists()) {
        if (await _hasWritePermission(exeDir)) {
          return exeDir;
        }
      }
    } catch (_) {
      // Fallback on platforms/environments where Platform.resolvedExecutable fails
    }

    // 2. Check for User-defined Custom Directory
    final customPath = _prefs.getString(customPathKey);
    if (customPath != null && customPath.isNotEmpty) {
      final customDir = Directory(customPath);
      if (await customDir.exists() && await _hasWritePermission(customDir)) {
        return customDir;
      }
    }

    // 3. Fallback to default application support directory
    return getApplicationSupportDirectory();
  }

  Future<bool> _hasWritePermission(Directory dir) async {
    try {
      final testFile = File(p.join(dir.path, '.write_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sets the custom database path
  Future<void> setCustomPath(String? path) async {
    if (path == null || path.isEmpty) {
      await _prefs.remove(customPathKey);
    } else {
      await _prefs.setString(customPathKey, path);
    }
  }

  File get _portableFile {
    final exeDir = File(Platform.resolvedExecutable).parent;
    return File(p.join(exeDir.path, 'aulos_portable.txt'));
  }

  Future<bool> isPortableModeConfigured() async {
    try {
      return await _portableFile.exists();
    } catch (_) {
      return false;
    }
  }

  Future<bool> canEnablePortableMode() async {
    try {
      final exeDir = File(Platform.resolvedExecutable).parent;
      return await _hasWritePermission(exeDir);
    } catch (_) {
      return false;
    }
  }

  Future<void> setPortableMode(bool enable) async {
    final file = _portableFile;
    if (enable) {
      if (!await file.exists()) {
        await file.writeAsString('aulos portable mode enabled');
      }
    } else {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Copies sqlite databases and their journal/WAL files to the target path
  Future<void> migrateDatabases(String targetPath) async {
    final currentDir = await getDatabaseDirectory();
    final targetDir = Directory(targetPath);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final List<String> dbFiles = [
      'localaudio.sqlite',
      'podcast_database.sqlite',
      'audiobook_database.sqlite',
      'playback_database.sqlite',
      'noise_database.sqlite',
      'radio.sqlite',
    ];

    for (final filename in dbFiles) {
      final currentFile = File(p.join(currentDir.path, filename));
      if (await currentFile.exists()) {
        final targetFile = File(p.join(targetDir.path, filename));
        await currentFile.copy(targetFile.path);

        // Copy auxiliary SQLite files
        for (final suffix in ['-journal', '-wal', '-shm']) {
          final extraFile = File('${currentFile.path}$suffix');
          if (await extraFile.exists()) {
            await extraFile.copy('${targetFile.path}$suffix');
          }
        }
      }
    }
  }
}
