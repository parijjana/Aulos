import 'package:audiotags/audiotags.dart' as tags;
import 'package:file/file.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:aulos/core/network/json_types.dart';
import 'package:path/path.dart' as p;
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'dart:developer' as developer;
import 'package:platform/platform.dart';

import 'package:aulos/domain/core/permission_service.dart';

abstract class AudioTagsWrapper {
  Future<tags.Tag?> read(String path);
}

class AudioTagsWrapperImpl implements AudioTagsWrapper {
  @override
  Future<tags.Tag?> read(String path) => tags.AudioTags.read(path);
}

class LocalLibraryService implements LibraryService {
  final FileSystem _fileSystem;
  final AudioTagsWrapper _tagsWrapper;
  final OnAudioQuery _audioQuery;
  final Platform _platform;
  final PermissionService _permissions;

  LocalLibraryService({
    required FileSystem fileSystem,
    required AudioTagsWrapper tagsWrapper,
    required OnAudioQuery audioQuery,
    required PermissionService permissions,
    Platform platform = const LocalPlatform(),
  }) : _fileSystem = fileSystem,
       _tagsWrapper = tagsWrapper,
       _audioQuery = audioQuery,
       _permissions = permissions,
       _platform = platform;

  @override
  Future<List<AudioFile>> scanDirectory(String path, {Set<String>? existingPaths}) async {
    developer.log('Scanner: Accessing path $path', name: 'LocalLibraryService');
    final directory = _fileSystem.directory(path);

    if (!await directory.exists()) {
      developer.log('Scanner Error: Path does not exist - $path', name: 'LocalLibraryService');
      return [];
    }

    final files = <AudioFile>[];

    try {
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          if (existingPaths != null && existingPaths.contains(entity.path)) {
            files.add(
              AudioFile(
                path: entity.path,
                title: p.basenameWithoutExtension(entity.path),
                artist: 'Unknown Artist',
                chapters: const [],
              ),
            );
            continue;
          }
          try {
            final tag = await _tagsWrapper.read(entity.path);
            
            // CUE ENRICHMENT: Try to find a .cue file in the same directory
            final cueData = await _tryGetCueMetadata(entity);

            files.add(
              AudioFile(
                path: entity.path,
                title: (cueData['title'] as String?) ?? tag?.title ?? p.basenameWithoutExtension(entity.path),
                artist: (cueData['artist'] as String?) ?? tag?.trackArtist ?? tag?.albumArtist ?? 'Unknown Artist',
                album: (cueData['album'] as String?) ?? tag?.album,
                albumArtist: tag?.albumArtist,
                genre: tag?.genre,
                year: tag?.year,
                duration: tag?.duration != null ? Duration(seconds: tag!.duration!) : null,
                coverArt: tag?.pictures.isNotEmpty == true ? tag!.pictures.first.bytes : null,
                chapters: (cueData['chapters'] as List<AudioChapter>?) ?? const [],
              ),
            );
          } catch (e) {
            developer.log('Scanner Warning: Failed to read tags for ${entity.path}: $e', name: 'LocalLibraryService');
          }
        }
      }
    } catch (e) {
      developer.log('Scanner Fatal Error: $e', name: 'LocalLibraryService', error: e);
    }

    return files;
  }

  Future<JsonMap> _tryGetCueMetadata(File audioFile) async {
    final JsonMap metadata = {};
    final List<AudioChapter> chapters = [];
    try {
      final dir = audioFile.parent;
      final baseName = p.basenameWithoutExtension(audioFile.path);
      
      File? cueFile;
      final potentialCue = dir.childFile('$baseName.cue');
      if (await potentialCue.exists()) {
        cueFile = potentialCue;
      } else {
        await for (final entity in dir.list()) {
          if (entity is File && p.extension(entity.path).toLowerCase() == '.cue') {
            cueFile = entity;
            break;
          }
        }
      }

      if (cueFile != null) {
        developer.log('Scanner: Parsing CUE chapters: ${cueFile.path}', name: 'LocalLibraryService');
        final lines = await cueFile.readAsLines();
        String? currentTrackTitle;
        
        for (var line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('TITLE "') && chapters.isEmpty && metadata['title'] == null) {
            metadata['title'] = _extractQuoted(trimmed);
          } else if (trimmed.startsWith('PERFORMER "') && chapters.isEmpty && metadata['artist'] == null) {
            metadata['artist'] = _extractQuoted(trimmed);
          } else if (trimmed.startsWith('TITLE "')) {
            currentTrackTitle = _extractQuoted(trimmed);
          } else if (trimmed.startsWith('INDEX 01 ')) {
            final timestamp = trimmed.substring(9).trim();
            final startTime = _parseCueTimestamp(timestamp);
            if (startTime != null) {
              chapters.add(AudioChapter(
                title: currentTrackTitle ?? 'Chapter ${chapters.length + 1}',
                startTime: startTime,
              ));
              currentTrackTitle = null; // Reset for next track
            }
          }
        }
      }
    } catch (e) {
      developer.log('Scanner: CUE parsing failed: $e', name: 'LocalLibraryService');
    }
    metadata['chapters'] = chapters;
    return metadata;
  }

  Duration? _parseCueTimestamp(String ts) {
    // Format: MM:SS:FF (Minutes:Seconds:Frames, 75 frames = 1 second)
    try {
      final parts = ts.split(':');
      if (parts.length != 3) return null;
      final m = int.parse(parts[0]);
      final s = int.parse(parts[1]);
      final f = int.parse(parts[2]);
      
      final totalMs = (m * 60 * 1000) + (s * 1000) + (f * 1000 ~/ 75);
      return Duration(milliseconds: totalMs);
    } catch (_) {
      return null;
    }
  }

  String? _extractQuoted(String line) {
    final start = line.indexOf('"');
    final end = line.lastIndexOf('"');
    if (start != -1 && end > start) {
      return line.substring(start + 1, end);
    }
    return null;
  }

  @override
  Future<List<AudioFile>> discoverTracks() async {
    if (!_platform.isAndroid && !_platform.isIOS) return [];

    developer.log('Starting MediaStore discovery...', name: 'LocalLibraryService');

    if (_platform.isAndroid) {
      final isGranted = await _permissions.requestAudioPermission();
      if (!isGranted) return [];
    }

    bool hasPermission = await _audioQuery.permissionsStatus();
    if (!hasPermission) hasPermission = await _audioQuery.permissionsRequest();
    if (!hasPermission) return [];

    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      final List<AudioFile> audioFiles = [];
      for (var song in songs) {
        final String path = song.data;
        if (path.isEmpty) continue;

        final artwork = await _audioQuery.queryArtwork(song.id, ArtworkType.AUDIO, format: ArtworkFormat.JPEG, size: 200);

        audioFiles.add(
          AudioFile(
            path: path,
            title: song.title,
            artist: song.artist ?? 'Unknown Artist',
            album: song.album,
            genre: song.genre,
            year: int.tryParse(song.getMap['year']?.toString() ?? ''),
            duration: Duration(milliseconds: song.duration ?? 0),
            coverArt: artwork,
          ),
        );
      }
      return audioFiles;
    } catch (e) {
      developer.log('Error querying songs: $e', name: 'LocalLibraryService', error: e);
      return [];
    }
  }

  bool _isAudioFile(String path) {
    final extension = p.extension(path).toLowerCase();
    return ['.mp3', '.m4a', '.m4b', '.wav', '.flac', '.ogg'].contains(extension);
  }
}
