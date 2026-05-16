import 'package:media_fetcher/media_fetcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:audiotags/audiotags.dart' as tags;
import 'dart:io';
import 'dart:async';

class ArtworkService {
  MediaFetcher? _fetcher;
  MediaCache? _cache;
  bool _isInitialized = false;

  ArtworkService();

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final appDir = await getApplicationSupportDirectory();
      final cachePath = p.join(appDir.path, 'artwork_cache');
      _cache = MediaCache(cachePath: cachePath);
      
      _fetcher = MediaFetcher(
        userAgent: 'AulosAudio/1.2.0 ( contact@aulos.audio )',
        cache: _cache,
      );
    } catch (e) {
      debugPrint('ArtworkService: Failed to init cache: $e');
      // Fallback without cache
      _fetcher = MediaFetcher(
        userAgent: 'AulosAudio/1.2.0 ( contact@aulos.audio )',
      );
    }
    _isInitialized = true;
  }

  Future<Uint8List?> tryGetLocalArtwork(String localFolder) async {
    try {
      final file = File(p.join(localFolder, '.artwork', 'cover.jpg'));
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('ArtworkService: Error reading local cover: $e');
    }
    return null;
  }

  Future<Uint8List?> tryGetLocalArtistPhoto(String localFolder) async {
    try {
      final file = File(p.join(localFolder, '.artwork', 'artist.jpg'));
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('ArtworkService: Error reading local photo: $e');
    }
    return null;
  }

  Future<Uint8List?> extractEmbeddedArtwork(String trackPath) async {
    try {
      final tag = await tags.AudioTags.read(trackPath);
      if (tag != null && tag.pictures.isNotEmpty) {
        return tag.pictures.first.bytes;
      }
    } catch (e) {
      debugPrint('ArtworkService: Error extracting embedded art: $e');
    }
    return null;
  }

  Future<Uint8List?> fetchAlbumArt(String artist, String album, {String? localFolder}) async {
    await init();
    final bytes = await _fetcher?.getAlbumArt(artist, album);
    
    if (bytes != null && localFolder != null) {
      unawaited(_saveToLocalFolder(localFolder, 'cover.jpg', bytes));
    }
    
    return bytes;
  }

  Future<Uint8List?> fetchArtistPhoto(String artist, {String? localFolder}) async {
    await init();
    final bytes = await _fetcher?.getArtistPhoto(artist);

    if (bytes != null && localFolder != null) {
      unawaited(_saveToLocalFolder(localFolder, 'artist.jpg', bytes));
    }

    return bytes;
  }

  Future<void> _saveToLocalFolder(String parentPath, String filename, Uint8List bytes) async {
    try {
      final artworkDir = Directory(p.join(parentPath, '.artwork'));
      if (!artworkDir.existsSync()) {
        await artworkDir.create(recursive: true);
        if (Platform.isWindows) {
          // Attempt to hide the folder on Windows
          unawaited(Process.run('attrib', ['+h', artworkDir.path]));
        }
      }

      final file = File(p.join(artworkDir.path, filename));
      
      // If file already exists, don't overwrite if it's the same size (basic check)
      if (file.existsSync()) {
        final existingBytes = await file.length();
        if (existingBytes == bytes.length) {
          return;
        }
      }

      await file.writeAsBytes(bytes);
      debugPrint('ArtworkService: Saved $filename to ${artworkDir.path}');
    } catch (e) {
      debugPrint('ArtworkService: Failed to save local artwork: $e');
    }
  }
}
