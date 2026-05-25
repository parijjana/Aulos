import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/domain/playback/playback_engine.dart'
    as engine_domain;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/socket_service.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';

enum MediaType { music, podcast, radio, audiobook }

class PlayerViewModel extends ChangeNotifier with UniversalLog {
  final engine_domain.PlaybackEngine _engine;
  final QueueViewModel _queueVM;
  final ConnectionManager _connectionManager;
  final AppDatabase _db;
  final RadioDatabase _radioDb;
  final SettingsViewModel _settingsVM;
  final http.Client _httpClient = http.Client();

  Track? _currentTrack;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _volume = 1.0;
  bool _isShuffle = false;
  engine_domain.RepeatMode _repeatMode = engine_domain.RepeatMode.off;
  engine_domain.PlaybackState _playbackState = engine_domain.PlaybackState.idle;
  double _playbackSpeed = 1.0;
  String? _currentShowNotes;
  String? _currentStreamMetadata;
  String? _currentImageUrl;
  bool _isCurrentStationFavorite = false;

  Color? _extractedColor;
  PaletteGenerator? _currentPalette;

  StreamSubscription<Track?>? _trackSub;
  StreamSubscription<engine_domain.PlaybackState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<MediaCommand>? _remoteSub;
  StreamSubscription<String?>? _icySub;

  int? _bookmarkEndMs;
  bool _isResumingBookmark = false;
  MediaType? _forcedMediaType;
  bool _isBookmarkMode = false;
  double _bookmarkStartMs = 0;
  double _bookmarkEndMsVal = 0;

  DateTime? _lastSkipTime;
  Timer? _radioStatsTimer;
  Timer? _resumeSaveTimer;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PlayerViewModel({
    required engine_domain.PlaybackEngine engine,
    required QueueViewModel queueVM,
    required ConnectionManager connectionManager,
    required AppDatabase db,
    required RadioDatabase radioDb,
    required SettingsViewModel settingsVM,
  }) : _engine = engine,
       _queueVM = queueVM,
       _connectionManager = connectionManager,
       _db = db,
       _radioDb = radioDb,
       _settingsVM = settingsVM {
    _init();
    _remoteSub = _connectionManager.remoteCommands.listen(_handleRemoteCommand);
    
    // START RESUME TIMER: Periodic save for Spoken Word content
    _resumeSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isPlaying && (currentMediaType == MediaType.podcast || currentMediaType == MediaType.audiobook)) {
        if (_currentTrack != null) {
          unawaited(_db.savePlaybackPosition(_currentTrack!.id, _position.inMilliseconds));
        }
      }
    });
  }

  bool get isCurrentStationFavorite => _isCurrentStationFavorite;
  bool get isBookmarkMode => _isBookmarkMode;
  double get bookmarkStartMs => _bookmarkStartMs;
  double get bookmarkEndMsVal => _bookmarkEndMsVal;

  void _init() {
    _trackSub = _engine.currentTrackStream.listen((track) {
      _currentTrack = track;
      if (track != null) {
        log('PLAYER: Now playing "${track.title}"');
        _errorMessage = null; // Clear error on new track
        _recordPlayAnalytics(track);
        
        // ASYNC COLOR EXTRACTION: Don't block UI or playback
        if (track.coverArt != null && track.coverArt!.isNotEmpty) {
           _extractColorFromMemory(track.coverArt!);
        } else if (_currentImageUrl != null) {
           _extractColorFromUrl(_currentImageUrl!);
        }
      }
      notifyListeners();
      _broadcastState();
    });

    _stateSub = _engine.playbackStateStream.listen((state) {
      _playbackState = state;
      _isPlaying = state == engine_domain.PlaybackState.playing;
      
      if (_isPlaying) {
        _startAnalyticsTracking();
      } else {
        _stopAnalyticsTracking();
      }

      if (state == engine_domain.PlaybackState.completed) {
        log('PLAYER: Track reached end. Type: $currentMediaType');
        // LOCK: Only auto-skip for music and podcasts, NEVER for radio
        if (currentMediaType == MediaType.music || currentMediaType == MediaType.podcast) {
           _debouncedSkipNext();
        } else {
           stop(); // Radio should just stop if it ends
        }
      }
      notifyListeners();
      _broadcastState();
    });

    _posSub = _engine.positionStream.listen((pos) {
      _position = pos;

      // BOUNDED PLAYBACK CHECK: Stop if we're playing a bookmark clip
      if (_bookmarkEndMs != null && !_isResumingBookmark) {
        if (pos.inMilliseconds >= _bookmarkEndMs!) {
          log('PLAYER: Bounded bookmark reached end time (${pos.inMilliseconds}ms >= $_bookmarkEndMs). Stopping.');
          _bookmarkEndMs = null; // Clear the bound
          pause();
        }
      }

      notifyListeners();
    });

    _durSub = _engine.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
      _broadcastState();
    });

    _engine.externalCommandStream.listen((command) {
      if (command == 'skipNext') {
        skipNext();
      } else if (command == 'skipPrevious') {
        skipPrevious();
      }
    });

    _icySub = _engine.icyMetadataStream.listen((metadata) {
      if (metadata != null && metadata.isNotEmpty) {
        log('PLAYER: ICY Metadata received: $metadata');
        _currentStreamMetadata = metadata;
        
        if (currentMediaType == MediaType.radio) {
          // Metadata usually format: "Artist - Title" or "Artist - Title (URL)"
          final parts = metadata.split(' - ');
          if (parts.length >= 2) {
             _currentArtistName = parts[0].trim();
             String title = parts.sublist(1).join(' - ');
             // Remove the URL if present (handler adds it)
             if (title.contains(' (http')) {
               title = title.split(' (http')[0].trim();
             }
             // Update the track title for display
             if (_currentTrack != null) {
               _currentTrack = _currentTrack!.copyWith(title: title);
             }
          }
        }
        notifyListeners();
      }
    });
  }

  Future<bool> _performHealthCheck(String url) async {
    try {
      log('HEALTH: Checking stream availability: $url');
      final response = await _httpClient.head(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 400) {
        log('HEALTH_FAIL: Stream returned status ${response.statusCode}');
        return false;
      }
      return true;
    } catch (e) {
      log('HEALTH_ERROR: Stream check failed: $e');
      return false;
    }
  }

  Future<void> loadTrack(
    Track track, {
    bool navigateToNowPlaying = false,
    String? description,
    String? artistName,
    String? albumName,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    _lastSkipTime = DateTime.now();
    _position = Duration.zero;
    _duration = Duration.zero;
    _playbackState = engine_domain.PlaybackState.loading;
    _currentShowNotes = description;
    _currentStreamMetadata = null;
    _currentImageUrl = imageUrl;
    _errorMessage = null;
    
    _currentArtistName = artistName ?? 'Loading...';
    _currentAlbumName = albumName ?? 'Loading...';
    
    // CONTEXT LOCK: Capture the intended type before potential health check failure
    final intendedType = _getMediaTypeForTrack(track);
    _forcedMediaType = null; // Clear existing
    _isCurrentStationFavorite = false;
    _isBookmarkMode = false;
    notifyListeners();

    // 0. AVAILABILITY GUARD: Block verified dead streams
    if (!isAvailable) {
      log('PLAYER: Blocking playback for verified unavailable stream: ${track.path}');
      await _engine.stop();
      _errorMessage = 'Media verified unavailable';
      _playbackState = engine_domain.PlaybackState.error;
      _currentArtistName = 'Unavailable';
      _forcedMediaType = intendedType;
      notifyListeners();
      return;
    }

    // HEALTH CHECK: For Radio and Podcasts (Manual check for newly selected items)
    if (track.path.startsWith('http')) {
      final isAlive = await _performHealthCheck(track.path);
      if (!isAlive) {
        String typeStr = 'Media';
        if (intendedType == MediaType.radio) typeStr = 'Station';
        if (intendedType == MediaType.podcast) typeStr = 'Podcast';
        
        log('PLAYER: Health check failed for ${track.path}. Stopping engine.');
        await _engine.stop(); // CRITICAL: Stop previous stream on failure
        
        _errorMessage = '$typeStr currently unavailable';
        _playbackState = engine_domain.PlaybackState.error;
        _currentArtistName = 'Unavailable';
        _forcedMediaType = intendedType; // Lock UI to intended type
        notifyListeners();
        return;
      }
    }

    // SESSION PERSISTENCE & FAVORITE RESOLUTION
    if (intendedType == MediaType.radio) {
       // Format: UUID|HOMEPAGE
       final parts = description?.split('|');
       final uuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;
       
       if (uuid != null) {
         unawaited(_settingsVM.setLastRadioStation(uuid));
         // Resolve library status
         final station = await (_radioDb.select(_radioDb.radioStations)..where((t) => t.stationUuid.equals(uuid))).getSingleOrNull();
         _isCurrentStationFavorite = station?.isFavorite ?? false;
       }
    } else if (intendedType == MediaType.podcast) {
       // For podcast episodes, we store by ID (absolute value)
       unawaited(_settingsVM.setLastPodcastEpisode(track.id.abs()));
    } else if (intendedType == MediaType.music) {
      // METADATA RESOLUTION: Fetch artist/album names if not provided
      if (artistName == null && track.artistId != null) {
        final artist = await (_db.select(_db.artists)..where((a) => a.id.equals(track.artistId!))).getSingleOrNull();
        if (artist != null) _currentArtistName = artist.name;
      }
      if (albumName == null && track.albumId != null) {
        final album = await (_db.select(_db.albums)..where((a) => a.id.equals(track.albumId!))).getSingleOrNull();
        if (album != null) _currentAlbumName = album.name;
      }
    }

    try {
      // 1. STOP PREVIOUS: Ensure no overlap and clear state
      await _engine.stop();

      // 2. ASYNC COLOR EXTRACTION: Start immediately but don't await
      if (track.coverArt != null && track.coverArt!.isNotEmpty) {
        unawaited(_extractColorFromMemory(track.coverArt!));
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        unawaited(_extractColorFromUrl(imageUrl));
      } else {
        _extractedColor = null;
      }

      // 3. SEQUENTIAL LOADING: Tell engine to prepare the track
      await _engine.loadTrack(track);
      
      // 4. IMMEDIATE PLAY: Audio starts now
      play();

      // 5. ASYNC RESUME & METADATA: Handle these in background
      unawaited(() async {
        // RESUME LOGIC: For Spoken Word content
        if (intendedType == MediaType.podcast || intendedType == MediaType.audiobook) {
          final saved = await _db.getPlaybackPosition(track.id);
          if (saved != null && saved.positionMs > 5000) {
            log('PLAYER: Resuming from saved position: ${saved.positionMs}ms');
            await _engine.seek(Duration(milliseconds: saved.positionMs));
          }
        }

        // Update UI strings if still on this track
        if (_currentTrack?.id == track.id) {
          if (track.id < 0 && _currentArtistName == 'Loading...') {
            _currentArtistName = artistName ?? 'Podcast Episode';
            _currentAlbumName = albumName ?? 'Podcast';
          } else if (track.id == 0 && _currentArtistName == 'Loading...') {
            _currentArtistName = artistName ?? 'Radio Station';
            _currentAlbumName = albumName ?? 'Internet Radio';
          } else if (_currentArtistName == 'Loading...') {
            _currentArtistName = artistName ?? 'Artist';
            _currentAlbumName = albumName ?? 'Album';
          }
          notifyListeners();
        }
      }());
    } catch (e) {
      log('PLAYER_ERROR: Failed to load track: $e');
      _errorMessage = 'Failed to load media';
      _playbackState = engine_domain.PlaybackState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setQueueAndPlay(List<Track> tracks, int index) async {
    await _queueVM.setQueue(tracks, startIndex: index);
    await loadTrack(tracks[index]);
  }

  void playTrackAtIndex(int index) {
    final track = _queueVM.currentQueue[index];
    _queueVM.setTrackByIndex(index);
    loadTrack(track);
  }

  void play() {
    log('PLAYER: User clicked play');
    _engine.play();
  }
  
  void pause() {
    log('PLAYER: User clicked pause');
    _engine.pause();
  }

  void _broadcastState() {
    if (_connectionManager.isHost) {
      _connectionManager.broadcastState(
        title: _currentTrack?.title ?? 'Idle',
        artist: currentArtistName,
        isPlaying: _isPlaying,
        positionMs: _position.inMilliseconds,
        durationMs: _duration.inMilliseconds,
      );
    }
  }

  MediaType get currentMediaType {
    if (_forcedMediaType != null) return _forcedMediaType!;
    if (_currentTrack == null) return MediaType.music;
    
    final type = _getMediaTypeForTrack(_currentTrack!);
    return type;
  }

  Track? get currentTrack {
    if (_currentTrack == null) return null;
    final qt = _queueVM.currentTrack;
    if (qt != null && qt.id == _currentTrack!.id && qt.id != 0) {
      return qt;
    }
    return _currentTrack;
  }
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get isMuted => _volume == 0;
  bool get isShuffle => _isShuffle;
  engine_domain.RepeatMode get repeatMode => _repeatMode;
  engine_domain.PlaybackState get state => _playbackState;
  double get playbackSpeed => _playbackSpeed;
  Color? get extractedColor => _extractedColor;
  String? get currentShowNotes => _currentShowNotes;
  String? get currentStreamMetadata => _currentStreamMetadata;
  String? get currentImageUrl => _currentImageUrl;

  bool get isHostMode => _connectionManager.isHost;
  bool get isRemoteMode => _connectionManager.isClient;

  String get displayTitle => _currentTrack?.title ?? 'No Track Selected';
  String _currentArtistName = 'Unknown Artist';
  String _currentAlbumName = 'Unknown Album';
  
  String get currentArtistName => _currentArtistName;
  String get currentAlbumName => _currentAlbumName;
  
  void stop() {
    log('PLAYER: User clicked stop');
    _engine.stop();
  }
  
  void seek(Duration position) {
    log('PLAYER: Seeking to ${_formatDuration(position)}');
    _bookmarkEndMs = null; // Clear bounds on manual seek
    _engine.seek(position);
  }

  void playBookmark(Bookmark bookmark) async {
    log('PLAYER: Playing bookmark "${bookmark.title}" from ${_formatDuration(Duration(milliseconds: bookmark.startTimeMs))} to ${_formatDuration(Duration(milliseconds: bookmark.endTimeMs ?? 0))}');
    
    _bookmarkEndMs = bookmark.endTimeMs;
    _isResumingBookmark = true; // Block end-check during seek
    
    await _engine.seek(Duration(milliseconds: bookmark.startTimeMs));
    play();
    
    // Safety: Allow 500ms for engine to stabilize before allowing the end-check
    Future.delayed(const Duration(milliseconds: 500), () {
      _isResumingBookmark = false;
    });
  }
  
  void setVolume(double volume) {
    _volume = volume;
    _engine.setVolume(volume);
    notifyListeners();
  }

  void setSpeed(double speed) {
    log('PLAYER: Speed set to ${speed}x');
    _playbackSpeed = speed;
    _engine.setSpeed(speed);
    notifyListeners();
  }

  Future<void> toggleCurrentStationFavorite() async {
    if (currentMediaType != MediaType.radio || _currentTrack == null) return;
    final parts = _currentShowNotes?.split('|');
    final uuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;
    if (uuid == null) return;

    _isCurrentStationFavorite = !_isCurrentStationFavorite;
    await _radioDb.setFavorite(uuid, _isCurrentStationFavorite);
    notifyListeners();
  }

  Future<void> saveBookmark({
    required String title,
    String? tags,
    String? notes,
  }) async {
    if (_currentTrack == null) return;
    final startMs = _bookmarkStartMs.toInt();
    final endMs = _bookmarkEndMsVal.toInt();

    log('PLAYER: Saving rich bookmark "$title" at ${_formatDuration(Duration(milliseconds: startMs))} - ${_formatDuration(Duration(milliseconds: endMs))}');
    try {
      await _db.saveBookmark(BookmarksCompanion.insert(
        trackPath: _currentTrack!.path,
        title: title,
        startTimeMs: startMs,
        endTimeMs: Value(endMs),
        tags: Value(tags),
        notes: Value(notes),
      ));
      
      // AUTO-PIN PODCASTS
      if (currentMediaType == MediaType.podcast) {
        log('PLAYER: Auto-pinning podcast episode due to bookmark creation.');
        await _db.updateEpisodePlayback(_currentTrack!.id.abs(), isPinned: true);
      }

      _isBookmarkMode = false;
      log('PLAYER: Bookmark saved.');
    } catch (e) {
      log('PLAYER_ERROR: Failed to save bookmark: $e');
    } finally {
      notifyListeners();
    }
  }

  void setBookmarkRange(double start, double end) {
    _bookmarkStartMs = start;
    _bookmarkEndMsVal = end;
    notifyListeners();
  }

  void toggleBookmarkMode() {
    _isBookmarkMode = !_isBookmarkMode;
    if (_isBookmarkMode) {
      // Initial range: -10s to +20s
      final pos = _position.inMilliseconds.toDouble();
      final dur = _duration.inMilliseconds.toDouble();
      _bookmarkStartMs = (pos - 10000).clamp(0, dur);
      _bookmarkEndMsVal = (pos + 20000).clamp(0, dur);
    }
    notifyListeners();
  }

  void skipForward() {
    log('PLAYER: Skip Forward +15s');
    final newPos = _position + const Duration(seconds: 15);
    seek(newPos < _duration ? newPos : _duration);
  }

  void skipBackward() {
    log('PLAYER: Skip Backward -10s');
    final newPos = _position - const Duration(seconds: 10);
    seek(newPos > Duration.zero ? newPos : Duration.zero);
  }

  void skipNext() {
    final originalType = currentMediaType;
    log('PLAYER: Skipping to next track (Context: $originalType)');
    
    _lastSkipTime = DateTime.now();
    _queueVM.skipNext();
    final next = _queueVM.currentTrack;
    
    if (next != null) {
      // SCOPE LOCK: Ensure we don't cross-pollinate media types during auto-skip or manual skip
      // This is especially important for Podcasts which have specific UI/behavior
      final nextType = _getMediaTypeForTrack(next);
      if (originalType == MediaType.podcast && nextType != MediaType.podcast) {
        log('PLAYER: SkipNext blocked - crossing from Podcast to $nextType');
        _queueVM.skipPrevious(); // Rollback
        stop();
        return;
      }
      
      loadTrack(next);
    }
  }

  void skipPrevious() {
    final originalType = currentMediaType;
    log('PLAYER: Skipping to previous track (Context: $originalType)');
    
    _lastSkipTime = DateTime.now();
    _queueVM.skipPrevious();
    final prev = _queueVM.currentTrack;
    
    if (prev != null) {
      final prevType = _getMediaTypeForTrack(prev);
      if (originalType == MediaType.podcast && prevType != MediaType.podcast) {
        log('PLAYER: SkipPrevious blocked - crossing from Podcast to $prevType');
        _queueVM.skipNext(); // Rollback
        return;
      }
      loadTrack(prev);
    }
  }

  MediaType _getMediaTypeForTrack(Track track) {
    if (track.id < -1000000) return MediaType.audiobook;
    if (track.id < 0) return MediaType.podcast;
    if (track.id == 0) return MediaType.radio;
    return MediaType.music;
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _queueVM.setShuffle(_isShuffle);
    notifyListeners();
  }

  void toggleRepeat() {
    _queueVM.toggleRepeat();
    _repeatMode = _queueVM.repeatMode;
    _engine.setRepeatMode(_repeatMode);
    notifyListeners();
  }

  void updateStreamMetadata(String metadata) {
    _currentStreamMetadata = metadata;
    notifyListeners();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _debouncedSkipNext() {
    final now = DateTime.now();
    if (_lastSkipTime != null &&
        now.difference(_lastSkipTime!) < const Duration(seconds: 1)) {
      return;
    }
    _lastSkipTime = now;
    skipNext();
  }

  void _handleRemoteCommand(MediaCommand command) {
    if (_connectionManager.isHost) {
      switch (command.type) {
        case CommandType.play: play(); break;
        case CommandType.pause: pause(); break;
        case CommandType.skipNext: skipNext(); break;
        case CommandType.skipPrev: skipPrevious(); break;
        case CommandType.seek:
          final ms = command.payload?['positionMs'] as int?;
          if (ms != null) seek(Duration(milliseconds: ms));
          break;
        default: break;
      }
    } else if (_connectionManager.isClient) {
      if (command.type == CommandType.syncState) {
        _updateFromRemote(command.payload);
      }
    }
  }

  Future<void> _extractColorFromMemory(Uint8List art) async {
    try {
      final provider = MemoryImage(art);
      _currentPalette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 10,
      );
      _extractedColor =
          _currentPalette?.vibrantColor?.color ??
          _currentPalette?.dominantColor?.color;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to extract color from memory: $e');
    }
  }

  Future<void> _extractColorFromUrl(String url) async {
    try {
      final provider = NetworkImage(url);
      _currentPalette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 10,
      );
      _extractedColor =
          _extractedColor =
          _currentPalette?.vibrantColor?.color ??
          _currentPalette?.dominantColor?.color;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to extract color from URL: $e');
    }
  }

  void _updateFromRemote(Map<String, dynamic>? payload) {
    if (payload == null) return;
    _currentTrack = Track(
      id: -1,
      title: payload['title']?.toString() ?? 'Remote Track',
      artistId: 0,
      path: '',
      folderId: 0,
      rating: 0,
      isFavorite: false,
      playCount: 0,
    );
    _isPlaying = payload['isPlaying'] as bool? ?? false;
    _position = Duration(milliseconds: (payload['positionMs'] as num?)?.toInt() ?? 0);
    _duration = Duration(milliseconds: (payload['durationMs'] as num?)?.toInt() ?? 0);
    notifyListeners();
  }

  void _recordPlayAnalytics(Track track) {
    if (!_connectionManager.isHost) return;

    if (track.id > 0) {
      // Music
      unawaited(_db.recordTrackPlay(track.id));
      if (track.artistId != null) unawaited(_db.recordArtistPlay(track.artistId!));
      if (track.albumId != null) unawaited(_db.recordAlbumPlay(track.albumId!));
    }
    // Radio stats handled by timer
  }

  void _startAnalyticsTracking() {
    if (!_connectionManager.isHost) return;
    if (currentMediaType == MediaType.radio) {
      // Parse UUID from metadata description (Format: UUID|HOMEPAGE)
      final parts = _currentShowNotes?.split('|');
      final radioUuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;

      if (radioUuid != null && radioUuid.isNotEmpty) {
        _radioStatsTimer?.cancel();
        _radioStatsTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
           unawaited(_db.recordRadioListen(radioUuid, 30));
        });
      }
    }
  }

  void _stopAnalyticsTracking() {
    _radioStatsTimer?.cancel();
    _radioStatsTimer = null;
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _trackSub?.cancel();
    _remoteSub?.cancel();
    _icySub?.cancel();
    _resumeSaveTimer?.cancel();
    _httpClient.close();
    super.dispose();
  }
}
