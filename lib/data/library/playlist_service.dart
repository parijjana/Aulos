import 'dart:io';
import 'package:aulos/data/database/app_database.dart';

abstract class PlaylistService {
  Future<void> exportM3U(String path, List<Track> tracks);
  Future<void> exportXSPF(String path, List<Track> tracks);
  Future<List<String>> importM3U(String path);
}

class PlaylistServiceImpl implements PlaylistService {
  @override
  Future<void> exportM3U(String path, List<Track> tracks) async {
    final file = File(path);
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    for (final track in tracks) {
      buffer.writeln('#EXTINF:${track.durationSeconds ?? -1},${track.title}');
      buffer.writeln(track.path);
    }
    await file.writeAsString(buffer.toString());
  }

  @override
  Future<void> exportXSPF(String path, List<Track> tracks) async {
    final file = File(path);
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<playlist version="1" xmlns="http://xspf.org/ns/0/">');
    buffer.writeln('  <trackList>');
    for (final track in tracks) {
      buffer.writeln('    <track>');
      buffer.writeln(
        '      <location>${Uri.file(track.path).toString()}</location>',
      );
      buffer.writeln('      <title>${track.title}</title>');
      if (track.durationSeconds != null) {
        buffer.writeln(
          '      <duration>${track.durationSeconds! * 1000}</duration>',
        );
      }
      buffer.writeln('    </track>');
    }
    buffer.writeln('  </trackList>');
    buffer.writeln('</playlist>');
    await file.writeAsString(buffer.toString());
  }

  @override
  Future<List<String>> importM3U(String path) async {
    final file = File(path);
    if (!file.existsSync()) return [];

    final lines = await file.readAsLines();
    final paths = <String>[];
    for (final line in lines) {
      if (line.trim().isEmpty || line.startsWith('#')) continue;
      paths.add(line.trim());
    }
    return paths;
  }
}
