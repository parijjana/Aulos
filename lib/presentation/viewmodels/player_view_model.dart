import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/domain/playback/playback_engine.dart'
    as engine_domain;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/socket_service.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'mixins/player_bookmark_mixin.dart';
import 'mixins/player_analytics_mixin.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:typed_data';

enum MediaType { music, podcast, radio, audiobook, noise }

class PlayerViewModel extends ChangeNotifier with UniversalLog, PlayerBookmarkMixin, PlayerAnalyticsMixin {
  final engine_domain.PlaybackEngine _engine;
  final QueueViewModel _queueVM;
  final ConnectionManager _connectionManager;
  final AppDatabase _db;
  final RadioDatabase _radioDb;
  final SettingsViewModel _settingsVM;
  final http.Client _httpClient = http.Client();
  NoiseViewModel? _noiseVM;

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

  List<Chapter> _currentChapters = [];

  StreamSubscription<Track?>? _trackSub;
  StreamSubscription<engine_domain.PlaybackState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<MediaCommand>? _remoteSub;
  StreamSubscription<String?>? _icySub;

  int? _bookmarkEndMs;
  bool _isResumingBookmark = false;
  MediaType? _forcedMediaType;

  DateTime? _lastSkipTime;
  Timer? _resumeSaveTimer;
  int _lastLoggedSec = -1;

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
    initBookmarkMixin(db);
    initAnalyticsMixin(db);
    _remoteSub = _connectionManager.remoteCommands.listen(_handleRemoteCommand);
    
    _resumeSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isPlaying && (currentMediaType == MediaType.podcast || currentMediaType == MediaType.audiobook)) {
        if (_currentTrack != null) {
          unawaited(_db.savePlaybackPosition(_currentTrack!.id, _position.inMilliseconds));
        }
      }
    });
  }

  void setNoiseViewModel(NoiseViewModel vm) {
    _noiseVM = vm;
    _noiseVM?.addListener(notifyListeners);
  }

  void forceMediaType(MediaType type) {
    _forcedMediaType = type;
    notifyListeners();
  }

  bool get isCurrentStationFavorite => _isCurrentStationFavorite;
  bool get isHostMode => _connectionManager.isHost;
  bool get isRemoteMode => _connectionManager.isClient;

  void _init() {
    _trackSub = _engine.currentTrackStream.listen((track) async {
      _currentTrack = track;
      _currentChapters = [];
      if (track != null) {
        log('PLAYER: Now playing "${track.title}"');
        _errorMessage = null; 
        if (_connectionManager.isHost) recordPlayAnalytics(track);
        
        if (track.coverArt != null && track.coverArt!.isNotEmpty) {
           unawaited(_extractColorFromMemory(track.coverArt!));
        } else if (_currentImageUrl != null) {
           unawaited(_extractColorFromUrl(_currentImageUrl!));
        }

        // LOAD CHAPTERS
        _currentChapters = await _db.getChaptersForTrack(track.id);
      }
      notifyListeners();
      _broadcastState();
    });

    _stateSub = _engine.playbackStateStream.listen((state) {
      _playbackState = state;
      _isPlaying = state == engine_domain.PlaybackState.playing;
      
      if (_isPlaying && _connectionManager.isHost && currentMediaType == MediaType.radio) {
        startRadioTracking(_currentShowNotes);
      } else {
        stopRadioTracking();
      }

      if (state == engine_domain.PlaybackState.completed) {
        if (currentMediaType == MediaType.music || currentMediaType == MediaType.podcast) {
           _debouncedSkipNext();
        } else {
           stop(); 
        }
      }
      notifyListeners();
      _broadcastState();
    });

    _posSub = _engine.positionStream.listen((pos) {
      _position = pos;
      final int currentSec = pos.inSeconds;
      if (currentSec % 5 == 0 && currentSec != _lastLoggedSec) {
        _lastLoggedSec = currentSec;
        log('PLAYER: Position Update -> ${currentSec}s / ${_duration.inSeconds}s');
      }

      if (_bookmarkEndMs != null && !_isResumingBookmark) {
        if (pos.inMilliseconds >= _bookmarkEndMs!) {
          _bookmarkEndMs = null; 
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

    _engine.icyMetadataStream.listen((metadata) {
      if (metadata != null && metadata.isNotEmpty) {
        _currentStreamMetadata = metadata;
        if (currentMediaType == MediaType.radio) {
          final parts = metadata.split(' - ');
          if (parts.length >= 2) {
             _currentArtistName = parts[0].trim();
             String title = parts.sublist(1).join(' - ');
             if (title.contains(' (http')) title = title.split(' (http')[0].trim();
             if (_currentTrack != null) _currentTrack = _currentTrack!.copyWith(title: title);
          }
        }
        notifyListeners();
      }
    });
  }

  Future<void> loadTrack(Track track, {String? description, String? artistName, String? albumName, String? imageUrl, bool isAvailable = true}) async {
    _lastSkipTime = DateTime.now();
    _position = Duration.zero; _duration = Duration.zero;
    _playbackState = engine_domain.PlaybackState.loading;
    _currentShowNotes = description; _currentImageUrl = imageUrl;
    _errorMessage = null; _currentArtistName = artistName ?? 'Loading...'; _currentAlbumName = albumName ?? 'Loading...';
    
    final intendedType = _getMediaTypeForTrack(track);
    _forcedMediaType = null; _isCurrentStationFavorite = false; resetBookmarkState();
    notifyListeners();

    if (!isAvailable) {
      await _engine.stop();
      _errorMessage = 'Media verified unavailable';
      _playbackState = engine_domain.PlaybackState.error;
      _forcedMediaType = intendedType;
      notifyListeners(); return;
    }

    if (intendedType == MediaType.radio) {
       final parts = description?.split('|');
       final uuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;
       if (uuid != null) {
         unawaited(_settingsVM.setLastRadioStation(uuid));
         final station = await (_radioDb.select(_radioDb.radioStations)..where((t) => t.stationUuid.equals(uuid))).getSingleOrNull();
         _isCurrentStationFavorite = station?.isFavorite ?? false;
       }
    } else if (intendedType == MediaType.podcast) {
       unawaited(_settingsVM.setLastPodcastEpisode(track.id.abs()));
    } else if (intendedType == MediaType.music || intendedType == MediaType.audiobook) {
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
      if (intendedType != MediaType.noise) {
        await _engine.stop();
        if (_noiseVM?.isMixerActive ?? false) unawaited(_noiseVM?.clearMix());
      }

      await _engine.loadTrack(track);
      play();

      unawaited(() async {
        if (intendedType == MediaType.podcast || intendedType == MediaType.audiobook) {
          final saved = await _db.getPlaybackPosition(track.id);
          if (saved != null && saved.positionMs > 5000) await _engine.seek(Duration(milliseconds: saved.positionMs));
        }
      }());
    } catch (e) {
      _errorMessage = 'Failed to load media';
      _playbackState = engine_domain.PlaybackState.error;
    } finally {
      notifyListeners();
    }
  }

  void play() {
    log('PLAYER: User clicked play');
    if (currentMediaType == MediaType.noise && _noiseVM != null) {
       unawaited(_noiseVM!.restoreActiveMix());
    } else {
       _engine.play();
    }
    notifyListeners();
  }
  
  void pause() {
    log('PLAYER: User clicked pause');
    if (currentMediaType == MediaType.noise && _noiseVM != null) {
       _noiseVM!.stopAll();
    } else {
       _engine.pause();
    }
    notifyListeners();
  }

  void _broadcastState() {
    if (_connectionManager.isHost) {
      _connectionManager.broadcastState(
        title: _currentTrack?.title ?? 'Idle',
        artist: currentArtistName,
        isPlaying: isPlaying,
        positionMs: _position.inMilliseconds,
        durationMs: _duration.inMilliseconds,
      );
    }
  }

  MediaType get currentMediaType {
    if (_forcedMediaType != null) return _forcedMediaType!;
    
    // Check Noise state without calling isPlaying to avoid recursion
    if (_noiseVM?.isPlaying ?? false) return MediaType.noise;
    
    final bool mainEngineIsActive = _isPlaying || _playbackState == engine_domain.PlaybackState.loading || _playbackState == engine_domain.PlaybackState.buffering;
    if (mainEngineIsActive || _currentTrack != null) return _getMediaTypeForTrack(_currentTrack);
    
    if (_noiseVM?.isMixerActive ?? false) return MediaType.noise;
    return MediaType.music;
  }

  List<Chapter> get currentChapters => _currentChapters;

  Track? get currentTrack => _currentTrack;
  Duration get position => _position;
  Duration get duration => _duration;
  
  bool get isPlaying {
    // Determine context manually to avoid recursive currentMediaType call
    if (_noiseVM?.isPlaying ?? false) return true;
    return _isPlaying || _playbackState == engine_domain.PlaybackState.loading || _playbackState == engine_domain.PlaybackState.buffering;
  }
  
  bool get isBuffering => _playbackState == engine_domain.PlaybackState.loading || _playbackState == engine_domain.PlaybackState.buffering;

  double get volume => _volume;
  bool get isShuffle => _isShuffle;
  engine_domain.RepeatMode get repeatMode => _repeatMode;
  engine_domain.PlaybackState get state => _playbackState;
  double get playbackSpeed => _playbackSpeed;
  Color? get extractedColor => _extractedColor;
  String? get currentShowNotes => currentMediaType == MediaType.noise ? _noiseVM?.activeAttributions : _currentShowNotes;
  String? get currentStreamMetadata => _currentStreamMetadata;
  String? get currentImageUrl => _currentImageUrl;

  String _currentArtistName = 'Unknown Artist';
  String _currentAlbumName = 'Unknown Album';
  String get currentArtistName => currentMediaType == MediaType.noise ? _noiseVM?.activeAttributions ?? '' : _currentArtistName;
  String get currentAlbumName => _currentAlbumName;
  String get displayTitle => currentMediaType == MediaType.noise ? _noiseVM?.activeIngredientsLabel ?? '' : _currentTrack?.title ?? 'No Track';

  void stop() { _engine.stop(); if (currentMediaType == MediaType.noise) _noiseVM?.stopAll(); notifyListeners(); }
  void seek(Duration pos) { _bookmarkEndMs = null; _engine.seek(pos); notifyListeners(); }
  void setVolume(double v) { _volume = v; _engine.setVolume(v); notifyListeners(); }
  void setSpeed(double s) { _playbackSpeed = s; _engine.setSpeed(s); notifyListeners(); }

  Future<void> toggleCurrentStationFavorite() async {
    final parts = _currentShowNotes?.split('|');
    final uuid = (parts != null && parts.isNotEmpty) ? parts[0] : null;
    if (uuid != null) {
      _isCurrentStationFavorite = !_isCurrentStationFavorite;
      await _radioDb.setFavorite(uuid, _isCurrentStationFavorite);
      notifyListeners();
    }
  }

  void toggleBookmark() => toggleBookmarkMode(currentPosition: _position, totalDuration: _duration);

  Future<void> saveBookmark({required String title, String? tags, String? notes}) async {
    if (_currentTrack == null) return;
    await saveRichBookmark(
      track: _currentTrack!,
      title: title,
      isAudiobook: currentMediaType == MediaType.audiobook,
      isPodcast: currentMediaType == MediaType.podcast,
      tags: tags,
      notes: notes,
    );
  }

  void playBookmark(Bookmark bookmark) async {
    _bookmarkEndMs = bookmark.endTimeMs;
    _isResumingBookmark = true;
    await _engine.seek(Duration(milliseconds: bookmark.startTimeMs));
    play();
    Future.delayed(const Duration(milliseconds: 500), () => _isResumingBookmark = false);
  }

  void skipForward() => seek(_position + const Duration(seconds: 15));
  void skipBackward() => seek(_position - const Duration(seconds: 10));

  void skipNext() {
    _lastSkipTime = DateTime.now(); _queueVM.skipNext();
    final next = _queueVM.currentTrack;
    if (next != null) loadTrack(next);
  }

  void skipPrevious() {
    _lastSkipTime = DateTime.now(); _queueVM.skipPrevious();
    final prev = _queueVM.currentTrack;
    if (prev != null) loadTrack(prev);
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

  MediaType _getMediaTypeForTrack(Track? track) {
    if (track == null) return MediaType.music;
    if (track.isAudiobook) return MediaType.audiobook;
    if (track.id < -2000000) return MediaType.noise;
    if (track.id < -1000000) return MediaType.audiobook;
    if (track.id < 0) return MediaType.podcast;
    if (track.id == 0) return MediaType.radio;
    return MediaType.music;
  }

  void toggleShuffle() { _isShuffle = !_isShuffle; _queueVM.setShuffle(_isShuffle); notifyListeners(); }
  void toggleRepeat() { _queueVM.toggleRepeat(); _repeatMode = _queueVM.repeatMode; _engine.setRepeatMode(_repeatMode); notifyListeners(); }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _debouncedSkipNext() {
    final now = DateTime.now();
    if (_lastSkipTime != null && now.difference(_lastSkipTime!) < const Duration(seconds: 1)) return;
    skipNext();
  }

  void _handleRemoteCommand(MediaCommand command) {
    if (_connectionManager.isHost) {
      switch (command.type) {
        case CommandType.play: play(); break;
        case CommandType.pause: pause(); break;
        case CommandType.skipNext: skipNext(); break;
        case CommandType.seek:
          final ms = command.payload?['positionMs'] as int?;
          if (ms != null) seek(Duration(milliseconds: ms));
          break;
        default: break;
      }
    }
  }

  Future<void> _extractColorFromMemory(Uint8List art) async {
    final provider = MemoryImage(art);
    _currentPalette = await PaletteGenerator.fromImageProvider(provider, maximumColorCount: 10);
    _extractedColor = _currentPalette?.vibrantColor?.color ?? _currentPalette?.dominantColor?.color;
    notifyListeners();
  }

  Future<void> _extractColorFromUrl(String url) async {
    final provider = NetworkImage(url);
    _currentPalette = await PaletteGenerator.fromImageProvider(provider, maximumColorCount: 10);
    _extractedColor = _currentPalette?.vibrantColor?.color ?? _currentPalette?.dominantColor?.color;
    notifyListeners();
  }

  @override
  void dispose() {
    _noiseVM?.removeListener(notifyListeners);
    _posSub?.cancel(); _durSub?.cancel(); _stateSub?.cancel();
    _trackSub?.cancel(); _remoteSub?.cancel(); _icySub?.cancel();
    _resumeSaveTimer?.cancel(); _httpClient.close();
    super.dispose();
  }
}
