import 'package:audiotags/audiotags.dart' as tags;
import 'package:file/file.dart';
import 'package:localaudioplayer/domain/library/library_service.dart';
import 'package:path/path.dart' as p;
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'dart:developer' as developer;

import 'package:platform/platform.dart';

import 'package:localaudioplayer/domain/core/permission_service.dart';

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
  Future<List<AudioFile>> scanDirectory(String path) async {
    developer.log('Scanner: Accessing path $path', name: 'LocalLibraryService');
    final directory = _fileSystem.directory(path);

    if (!await directory.exists()) {
      developer.log(
        'Scanner Error: Path does not exist - $path',
        name: 'LocalLibraryService',
      );
      return [];
    }

    final files = <AudioFile>[];

    try {
      developer.log(
        'Scanner: Starting recursive list of $path',
        name: 'LocalLibraryService',
      );
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && _isAudioFile(entity.path)) {
          developer.log(
            'Scanner: Discovered audio file ${entity.path}',
            name: 'LocalLibraryService',
          );
          try {
            final tag = await _tagsWrapper.read(entity.path);
            files.add(
              AudioFile(
                path: entity.path,
                title: tag?.title ?? p.basenameWithoutExtension(entity.path),
                artist:
                    tag?.trackArtist ?? tag?.albumArtist ?? 'Unknown Artist',
                album: tag?.album,
                albumArtist: tag?.albumArtist,
                genre: tag?.genre,
                year: tag?.year,
                duration: tag?.duration != null
                    ? Duration(seconds: tag!.duration!)
                    : null,
                coverArt: tag?.pictures.isNotEmpty == true
                    ? tag!.pictures.first.bytes
                    : null,
              ),
            );
          } catch (e) {
            developer.log(
              'Scanner Warning: Failed to read tags for ${entity.path}: $e',
              name: 'LocalLibraryService',
            );
          }
        }
      }
      developer.log(
        'Scanner Success: Found ${files.length} audio files in $path',
        name: 'LocalLibraryService',
      );
    } catch (e) {
      developer.log(
        'Scanner Fatal Error: $e',
        name: 'LocalLibraryService',
        error: e,
      );
    }

    return files;
  }

  @override
  Future<List<AudioFile>> discoverTracks() async {
    if (!_platform.isAndroid && !_platform.isIOS) return [];

    developer.log(
      'Starting MediaStore discovery...',
      name: 'LocalLibraryService',
    );

    if (_platform.isAndroid) {
      final isGranted = await _permissions.requestAudioPermission();
      if (!isGranted) {
        developer.log('Permission.audio denied', name: 'LocalLibraryService');
        return [];
      }
    }

    bool hasPermission = await _audioQuery.permissionsStatus();
    if (!hasPermission) {
      hasPermission = await _audioQuery.permissionsRequest();
    }

    if (!hasPermission) {
      developer.log(
        'OnAudioQuery plugin permissions denied',
        name: 'LocalLibraryService',
      );
      return [];
    }

    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      developer.log(
        'MediaStore returned ${songs.length} songs',
        name: 'LocalLibraryService',
      );

      final List<AudioFile> audioFiles = [];

      for (var song in songs) {
        final String path = song.data;
        if (path.isEmpty) continue;

        final artwork = await _audioQuery.queryArtwork(
          song.id,
          ArtworkType.AUDIO,
          format: ArtworkFormat.JPEG,
          size: 200,
        );

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
      developer.log(
        'Error querying songs: $e',
        name: 'LocalLibraryService',
        error: e,
      );
      return [];
    }
  }

  bool _isAudioFile(String path) {
    final extension = p.extension(path).toLowerCase();
    return ['.mp3', '.m4a', '.wav', '.flac', '.ogg'].contains(extension);
  }
}
