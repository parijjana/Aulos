import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/artwork_service.dart';
import 'package:localaudioplayer/data/library/ensemble_artwork_service.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

enum IndexerState { idle, scanning, optimizing, hardening, paused, error }

class LibraryIndexerService extends ChangeNotifier with UniversalLog {
  final AppDatabase _db;
  final SharedPreferences _prefs;
  final ArtworkService _artworkService;
  final EnsembleArtworkService _ensembleService;

  IndexerState _state = IndexerState.idle;
  double _progress = 0.0;
  String _statusMessage = 'Idle';
  Uint8List? _lastFetchedArt;

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

    log('INDEXER: Starting metadata hardening (Artwork & Photos)');
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
        log('INDEXER: No missing metadata found.');
        _statusMessage = 'All artwork and photos are already up to date.';
        _state = IndexerState.idle;
        _progress = 1.0;
        notifyListeners();
        return;
      }

      log('INDEXER: Found $totalTasks missing metadata items.');
      int completedTasks = 0;

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

        log('INDEXER: Fetching art for "${album.name}" by "${artist.name}"');
        _statusMessage = 'Fetching Art: ${album.name}';
        notifyListeners();

        String? albumPath;
        String? firstTrackPath;
        final albumTracks = await _db.getTracksForAlbum(album.id);
        if (albumTracks.isNotEmpty) {
          firstTrackPath = albumTracks.first.path;
          albumPath = p.dirname(firstTrackPath);
        }

        try {
          Uint8List? art;
          if (albumPath != null) {
            art = await _artworkService.tryGetLocalArtwork(albumPath);
          }

          if (art == null && firstTrackPath != null) {
            art = await _artworkService.extractEmbeddedArtwork(firstTrackPath);
          }

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
            log('INDEXER: Saved art for "${album.name}"');
          }
        } catch (e) {
          log('INDEXER: Error fetching art for "${album.name}": $e');
        }
        
        completedTasks++;
        _progress = completedTasks / totalTasks;
        notifyListeners();
      }

      for (final artist in missingPhotoArtists) {
        if (_shouldPause) break;
        
        log('INDEXER: Fetching photo for artist "${artist.name}"');
        _statusMessage = 'Fetching Photo: ${artist.name}';
        notifyListeners();

        String? artistPath;
        final artistTracks = await _db.getTracksForArtist(artist.id);
        if (artistTracks.isNotEmpty) {
          final firstTrackDir = p.dirname(artistTracks.first.path);
          artistPath = p.dirname(firstTrackDir); 
        }

        try {
          Uint8List? photo;
          if (artistPath != null) {
            photo = await _artworkService.tryGetLocalArtistPhoto(artistPath);
          }

          if (photo == null) {
            if (_ensembleService.isEnsemble(artist.name)) {
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
            log('INDEXER: Saved photo for "${artist.name}"');
          }
        } catch (e) {
          log('INDEXER: Error fetching photo for "${artist.name}": $e');
        }
        
        completedTasks++;
        _progress = completedTasks / totalTasks;
        notifyListeners();
      }

      log('INDEXER: Metadata hardening complete.');
      _statusMessage = _shouldPause ? 'Hardening paused' : 'Metadata Hardening Complete';
      _state = IndexerState.idle;
      _progress = 1.0;
      notifyListeners();
    } catch (e) {
      log('INDEXER: Hardening error: $e');
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
      log('INDEXER: Resuming database optimization from index $offset');
      unawaited(_startOptimizing(startOffset: offset));
    }
  }

  Future<void> rebuildFromScratch() async {
    log('INDEXER: Wiping library and rebuilding from scratch...');
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
    log('INDEXER: Library wiped. Starting fresh index...');
    unawaited(_startOptimizing(startOffset: 0));
  }

  Future<void> scanLibrary(
    List<String> folders,
    PersistentLibraryService service,
  ) async {
    if (_state != IndexerState.idle) return;

    log('INDEXER: Starting library scan on ${folders.length} folders.');
    _state = IndexerState.scanning;
    _shouldPause = false;
    _statusMessage = 'Initializing scan...';
    _foldersScanned = 0;
    _filesDiscovered = 0;
    notifyListeners();

    try {
      for (final path in folders) {
        if (_shouldPause) break;
        log('INDEXER: Scanning directory: $path');
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
      log('INDEXER: Discovered $_filesDiscovered new files across $_foldersScanned folders.');
      
      _statusMessage = 'Scan Complete. Optimizing Database...';
      notifyListeners();
      await _startOptimizing(startOffset: 0);

      _statusMessage = _shouldPause ? 'Scan Stopped' : 'Ready';
      _state = IndexerState.idle;
      notifyListeners();
    } catch (e) {
      log('INDEXER: Scan error: $e');
      _state = IndexerState.error;
      _statusMessage = 'Scan Error: $e';
      notifyListeners();
    }
  }

  void stopIndexer() {
    log('INDEXER: User requested stop.');
    _shouldPause = true;
    notifyListeners();
  }

  Future<void> _startOptimizing({required int startOffset}) async {
    log('INDEXER: Running database optimization...');
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

      log('INDEXER: Database optimization complete.');
      _state = IndexerState.idle;
      _progress = 1.0;
      await _prefs.setInt(_progressKey, 0);
      notifyListeners();
    } catch (e) {
      log('INDEXER: Optimization error: $e');
      _state = IndexerState.error;
      _statusMessage = 'Error: $e';
      notifyListeners();
    }
  }
}
