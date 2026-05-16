import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/artwork_service.dart';
import 'package:localaudioplayer/data/library/ensemble_artwork_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

enum IndexerState { idle, scanning, optimizing, hardening, paused, error }

class LibraryIndexerService extends ChangeNotifier {
  final AppDatabase _db;
  final SharedPreferences _prefs;
  final ArtworkService _artworkService;
  final EnsembleArtworkService _ensembleService;

  IndexerState _state = IndexerState.idle;
  double _progress = 0.0;
  String _statusMessage = 'Idle';
  Uint8List? _lastFetchedArt;

  // Telemetry
  int _foldersScanned = 0;
  int _filesDiscovered = 0;
  int _totalFilesStored = 0;

  static const String _progressKey = 'indexer_progress_offset';
  bool _shouldPause = false;

  LibraryIndexerService({
    required AppDatabase db,
    required SharedPreferences prefs,
    required ArtworkService artworkService,
    required EnsembleArtworkService ensembleService,
  }) : _db = db,
       _prefs = prefs,
       _artworkService = artworkService,
       _ensembleService = ensembleService {
    unawaited(_resumeIfNeeded());
    unawaited(_updateTotalCount());
  }

  IndexerState get state => _state;
  double get progress => _progress;
  String get statusMessage => _statusMessage;
  Uint8List? get lastFetchedArt => _lastFetchedArt;

  int get foldersScanned => _foldersScanned;
  int get filesDiscovered => _filesDiscovered;
  int get totalFilesStored => _totalFilesStored;

  Future<void> fetchMissingMetadata(PersistentLibraryService service) async {
    if (_state != IndexerState.idle) return;

    _state = IndexerState.hardening;
    _shouldPause = false;
    _statusMessage = 'Starting metadata hardening...';
    _progress = 0.0;
    _lastFetchedArt = null;
    notifyListeners();

    try {
      final allArtists = await _db.getAllArtists();
      final allAlbums = await service.getAlbums();

      final missingArtAlbums = allAlbums.where((a) => a.coverArt == null).toList();
      final missingPhotoArtists = allArtists.where((a) => a.photo == null).toList();
      
      final int totalTasks = missingArtAlbums.length + missingPhotoArtists.length;
      if (totalTasks == 0) {
        _statusMessage = 'All artwork and photos are already up to date.';
        _state = IndexerState.idle;
        _progress = 1.0;
        notifyListeners();
        return;
      }

      int completedTasks = 0;

      // 1. Fetch missing Album Art
      for (final album in missingArtAlbums) {
        if (_shouldPause) break;
        
        final artist = allArtists.cast<Artist?>().firstWhere(
          (a) => a?.id == album.artistId,
          orElse: () => null,
        );
        
        if (artist == null) {
          completedTasks++;
          continue;
        }

        _statusMessage = 'Fetching Art: ${album.name} by ${artist.name}';
        notifyListeners();

        // Resolve a local folder from the first track in this album
        String? albumPath;
        String? firstTrackPath;
        final albumTracks = await _db.getTracksForAlbum(album.id);
        if (albumTracks.isNotEmpty) {
          firstTrackPath = albumTracks.first.path;
          albumPath = p.dirname(firstTrackPath);
        }

        try {
          Uint8List? art;
          
          // Stage 1: Check .artwork subfolder
          if (albumPath != null) {
            art = await _artworkService.tryGetLocalArtwork(albumPath);
            if (art != null) {
              debugPrint('Indexer: Found local cover for ${album.name}');
            }
          }

          // Stage 2: Extract embedded artwork
          if (art == null && firstTrackPath != null) {
            art = await _artworkService.extractEmbeddedArtwork(firstTrackPath);
            if (art != null) {
              debugPrint('Indexer: Extracted embedded art for ${album.name}');
            }
          }

          // Stage 3: Fetch from network
          if (art == null) {
            art = await _artworkService.fetchAlbumArt(
              artist.name,
              album.name,
              localFolder: albumPath,
            ).timeout(const Duration(seconds: 30));
          }
          
          if (art != null) {
            await service.updateAlbumArt(album.id, art);
            _lastFetchedArt = art;
          }
        } catch (e) {
          debugPrint('Error fetching art for ${album.name}: $e');
        }
        
        completedTasks++;
        _progress = completedTasks / totalTasks;
        notifyListeners();
      }

      // 2. Fetch missing Artist Photos
      for (final artist in missingPhotoArtists) {
        if (_shouldPause) break;
        
        _statusMessage = 'Fetching Photo: ${artist.name}';
        notifyListeners();

        // Resolve a local folder for the artist (using their first album's parent dir)
        String? artistPath;
        final artistTracks = await _db.getTracksForArtist(artist.id);
        if (artistTracks.isNotEmpty) {
          final firstTrackDir = p.dirname(artistTracks.first.path);
          artistPath = p.dirname(firstTrackDir); 
        }

        try {
          Uint8List? photo;

          // Stage 1: Check .artwork subfolder
          if (artistPath != null) {
            photo = await _artworkService.tryGetLocalArtistPhoto(artistPath);
            if (photo != null) {
              debugPrint('Indexer: Found local photo for ${artist.name}');
            }
          }

          // Stage 2: Fetch from network
          if (photo == null) {
            if (_ensembleService.isEnsemble(artist.name)) {
              _statusMessage = 'Stitching ensemble photo: ${artist.name}';
              notifyListeners();
              photo = await _ensembleService.createEnsembleArtwork(
                artist.name,
                localFolder: artistPath,
              ).timeout(const Duration(minutes: 1));
            } else {
              photo = await _artworkService.fetchArtistPhoto(
                artist.name,
                localFolder: artistPath,
              ).timeout(const Duration(seconds: 30));
            }
          }

          if (photo != null) {
            await service.updateArtistPhoto(artist.id, photo);
            _lastFetchedArt = photo;
          }
        } catch (e) {
          debugPrint('Error fetching photo for ${artist.name}: $e');
        }
        
        completedTasks++;
        _progress = completedTasks / totalTasks;
        notifyListeners();
      }

      _statusMessage = _shouldPause ? 'Hardening paused' : 'Metadata Hardening Complete';
      _state = IndexerState.idle;
      _progress = 1.0;
      notifyListeners();
    } catch (e) {
      _state = IndexerState.error;
      _statusMessage = 'Hardening Error: $e';
      notifyListeners();
    }
  }

  Future<void> _updateTotalCount() async {
    _totalFilesStored = (await _db.getAllTracks()).length;
    notifyListeners();
  }

  Future<void> _resumeIfNeeded() async {
    final offset = _prefs.getInt(_progressKey) ?? 0;
    if (offset > 0) {
      unawaited(_startOptimizing(startOffset: offset));
    }
  }

  void triggerOptimize() {
    if (_state == IndexerState.idle) {
      unawaited(
        _startOptimizing(startOffset: _prefs.getInt(_progressKey) ?? 0),
      );
    }
  }

  void pauseIndexer() {
    if (_state == IndexerState.optimizing || _state == IndexerState.scanning) {
      _shouldPause = true;
      _state = IndexerState.paused;
      _statusMessage = 'Paused';
      notifyListeners();
    }
  }

  Future<void> rebuildFromScratch() async {
    _shouldPause = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _db.delete(_db.artistAlbumRelations).go();
    await _db.delete(_db.tracks).go();
    await _db.delete(_db.albums).go();
    await _db.delete(_db.artists).go();
    await _db.delete(_db.genres).go();
    await _db.delete(_db.folders).go();
    await _prefs.setInt(_progressKey, 0);
    _foldersScanned = 0;
    _filesDiscovered = 0;
    _totalFilesStored = 0;
    unawaited(_startOptimizing(startOffset: 0));
  }

  Future<void> scanLibrary(
    List<String> folders,
    PersistentLibraryService service,
  ) async {
    if (_state != IndexerState.idle) return;

    _state = IndexerState.scanning;
    _shouldPause = false;
    _statusMessage = 'Initializing scan...';
    _foldersScanned = 0;
    _filesDiscovered = 0;
    notifyListeners();

    try {
      for (final path in folders) {
        if (_shouldPause) break;
        _statusMessage = 'Scanning: $path';
        notifyListeners();

        await service.importFolder(
          path,
          onFileFound: () {
            _filesDiscovered++;
            _totalFilesStored++;
            notifyListeners();
          },
        );

        _foldersScanned++;
        notifyListeners();
      }

      await _updateTotalCount();

      _statusMessage = 'Scan Complete. Optimizing Database...';
      notifyListeners();
      await _startOptimizing(startOffset: 0);

      _statusMessage = _shouldPause ? 'Scan Stopped' : 'Ready';
      _state = IndexerState.idle;
      notifyListeners();
    } catch (e) {
      _state = IndexerState.error;
      _statusMessage = 'Scan Error: $e';
      notifyListeners();
    }
  }

  void stopIndexer() {
    _shouldPause = true;
    notifyListeners();
  }

  Future<void> _startOptimizing({required int startOffset}) async {
    _state = IndexerState.optimizing;
    _shouldPause = false;
    notifyListeners();

    try {
      final allArtists = await _db.getAllArtists();
      final totalArtists = allArtists.length;

      if (totalArtists == 0) {
        _state = IndexerState.idle;
        _progress = 1.0;
        notifyListeners();
        return;
      }

      int processed = startOffset;

      for (int i = startOffset; i < totalArtists; i++) {
        if (_shouldPause) {
          await _prefs.setInt(_progressKey, processed);
          return;
        }

        final artist = allArtists[i];
        _statusMessage = 'Indexing: ${artist.name}';

        final artistTracks = await _db.getTracksForArtist(artist.id);
        final Map<int, int> albumCounts = {};
        for (var track in artistTracks) {
          if (track.albumId != null) {
            albumCounts[track.albumId!] =
                (albumCounts[track.albumId!] ?? 0) + 1;
          }
        }

        final relations = albumCounts.entries
            .map(
              (e) => ArtistAlbumRelation(
                artistId: artist.id,
                albumId: e.key,
                trackCount: e.value,
              ),
            )
            .toList();

        if (relations.isNotEmpty) {
          await _db.cacheArtistAlbumRelations(relations);
        }

        processed++;
        _progress = processed / totalArtists;
        await _prefs.setInt(_progressKey, processed);
        notifyListeners();

        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      _state = IndexerState.idle;
      _progress = 1.0;
      await _prefs.setInt(_progressKey, 0);
      notifyListeners();
    } catch (e) {
      debugPrint('Optimization Error: $e');
      _state = IndexerState.error;
      _statusMessage = 'Error: $e';
      notifyListeners();
    }
  }
}
