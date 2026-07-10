import 'dart:io';

import 'package:aulos/core/utils/id_generator.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:path/path.dart' as p;

/// Result of resolving a deterministic content id for a newly-discovered
/// [AudioFile], including whether it collides with a different file that
/// already claimed the same generated id.
class TrackFingerprintResult {
  final String trackId;
  final String? duplicateOf;

  const TrackFingerprintResult(this.trackId, this.duplicateOf);
}

/// Generates the deterministic content id for [f], using its tags when
/// available and falling back to folder/file name. If [existingWithId]
/// resolves to a different path than f.path, a collision suffix
/// (timestamp) is appended and the id is regenerated, with the original id
/// recorded as [TrackFingerprintResult.duplicateOf].
///
/// [existingWithId] should look up whether some other track already has the
/// candidate id, returning its stored path (or null if none).
Future<TrackFingerprintResult> resolveTrackFingerprint(
  AudioFile f, {
  required Future<String?> Function(String candidateId) existingWithId,
}) async {
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

  final existingPath = await existingWithId(trackId);
  if (existingPath != null && existingPath != f.path) {
    duplicateOf = trackId;
    fingerprint = "$fingerprint|${DateTime.now().millisecondsSinceEpoch}";
    trackId = generateContentId(fingerprint);
  }

  return TrackFingerprintResult(trackId, duplicateOf);
}
