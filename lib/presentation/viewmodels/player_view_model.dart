import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/domain/playback/playback_engine.dart'
    as engine_domain;
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/domain/network/connection_manager.dart';
import 'package:localaudioplayer/domain/network/socket_service.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:drift/drift.dart';
import 'dart:async';
import 'dart:typed_data';

enum MediaType { music, podcast, radio, audiobook }

class PlayerViewModel extends ChangeNotifier with UniversalLog {
  final engine_domain.PlaybackEngine _engine;
  final QueueViewModel _queueVM;
  final ConnectionManager _connectionManager;
  final AppDatabase _db;

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

  Color? _extractedColor;
  PaletteGenerator? _currentPalette;

  StreamSubscription<Track?>? _trackSub;
  StreamSubscription<engine_domain.PlaybackState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<MediaCommand>? _remoteSub;
  StreamSubscription<String?>? _icySub;

  PlayerViewModel({
    required engine_domain.PlaybackEngine engine,
    required QueueViewModel queueVM,
    required ConnectionManager connectionManager,
    required AppDatabase db,
  }) : _engine = engine,
       _queueVM = queueVM,
       _connectionManager = connectionManager,
       _db = db {
    _init();
    _remoteSub = _connectionManager.remoteCommands.listen(_handleRemoteCommand);
  }

  DateTime? _lastSkipTime;
  Timer? _radioStatsTimer;
  String? _lastRadioUuid;

  void _init() {
    _trackSub = _engine.currentTrackStream.listen((track) {
      _currentTrack = track;
      if (track != null) {
        log('PLAYER: Now playing "${track.title}"');
        _recordPlayAnalytics(track);
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
        log('PLAYER: Track reached end. Skipping...');
        _debouncedSkipNext();
      }
      notifyListeners();
      _broadcastState();
    });

    _posSub = _engine.positionStream.listen((pos) {
      _position = pos;
      if (_playbackState == engine_domain.PlaybackState.playing &&
          _duration > Duration.zero &&
          pos >= _duration &&
          pos > Duration.zero) {
        _debouncedSkipNext();
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
        notifyListeners();
      }
    });
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
      final radioUuid = _currentTrack?.path; // For radio, we store UUID in path
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
    if (_currentTrack == null) return MediaType.music;
    if (_currentTrack!.id < -1000000) return MediaType.audiobook;
    if (_currentTrack!.id < 0) return MediaType.podcast;
    if (_currentTrack!.id == 0) return MediaType.radio;
    return MediaType.music;
  }

  Track? get currentTrack => _currentTrack;
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

  Future<void> loadTrack(
    Track track, {
    bool navigateToNowPlaying = false,
    String? description,
    String? artistName,
    String? albumName,
    String? imageUrl,
  }) async {
    _lastSkipTime = DateTime.now();
    _position = Duration.zero;
    _duration = Duration.zero;
    _playbackState = engine_domain.PlaybackState.loading;
    _currentShowNotes = description;
    _currentStreamMetadata = null;
    _currentImageUrl = imageUrl;
    
    _currentArtistName = artistName ?? 'Loading...';
    _currentAlbumName = albumName ?? 'Loading...';
    notifyListeners();

    try {
      await _engine.loadTrack(track);
      if (track.id < 0 && artistName == null) {
        _currentArtistName = 'Podcast Episode';
        _currentAlbumName = 'Podcast';
      } else if (track.id == 0 && artistName == null) {
        _currentArtistName = 'Radio Station';
        _currentAlbumName = 'Internet Radio';
      } else if (artistName == null) {
        _currentArtistName = 'Artist';
        _currentAlbumName = 'Album';
      }

      if (track.coverArt != null && track.coverArt!.isNotEmpty) {
        await _extractColorFromMemory(track.coverArt!);
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        await _extractColorFromUrl(imageUrl);
      } else {
        _extractedColor = null;
        notifyListeners();
      }

      play();
    } catch (e) {
      log('PLAYER_ERROR: Failed to load track: $e');
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
  
  void stop() {
    log('PLAYER: User clicked stop');
    _engine.stop();
  }
  
  void seek(Duration position) {
    log('PLAYER: Seeking to ${_formatDuration(position)}');
    _engine.seek(position);
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

  Future<void> bookmark() async {
    if (_currentTrack == null) return;
    log('PLAYER: Saving bookmark for "${_currentTrack!.title}" at ${_formatDuration(_position)}');
    try {
      await _db.saveBookmark(BookmarksCompanion.insert(
        trackPath: _currentTrack!.path,
        title: _currentTrack!.title,
        positionMs: _position.inMilliseconds,
      ));
      log('PLAYER: Bookmark saved.');
    } catch (e) {
      log('PLAYER_ERROR: Failed to save bookmark: $e');
    }
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
    log('PLAYER: Skipping to next track');
    _lastSkipTime = DateTime.now();
    _queueVM.skipNext();
    final next = _queueVM.currentTrack;
    if (next != null) loadTrack(next);
  }

  void skipPrevious() {
    log('PLAYER: Skipping to previous track');
    _lastSkipTime = DateTime.now();
    _queueVM.skipPrevious();
    final prev = _queueVM.currentTrack;
    if (prev != null) loadTrack(prev);
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

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _trackSub?.cancel();
    _remoteSub?.cancel();
    _icySub?.cancel();
    super.dispose();
  }
}
