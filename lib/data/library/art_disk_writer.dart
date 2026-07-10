import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Persists artwork bytes to the app's on-disk artwork cache and returns the
/// resulting file path, or null if there was no art to save.
///
/// Shared by LibraryIndexerService and PersistentLibraryImportExtension,
/// which both need to write fetched/extracted art to a deterministic path
/// keyed by a generated content id.
Future<String?> saveArtToDisk(Uint8List? art, String generatedId) async {
  if (art == null) return null;
  final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'artwork'));
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File(p.join(dir.path, '$generatedId.jpg'));
  if (!file.existsSync()) {
    await file.writeAsBytes(art);
  }
  return file.path;
}
