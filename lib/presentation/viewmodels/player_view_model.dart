import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/domain/playback/playback_engine.dart'
    as engine_domain;
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/domain/network/connection_manager.dart';
import 'package:localaudioplayer/domain/network/socket_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:async';

class PlayerViewModel extends ChangeNotifier {
  final engine_domain.PlaybackEngine _engine;
  final QueueViewModel _queueVM;
  final ConnectionManager _connectionManager;

  Track? _currentTrack;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _volume = 1.0;
  bool _isShuffle = false;
  engine_domain.RepeatMode _repeatMode = engine_domain.RepeatMode.off;
  engine_domain.PlaybackState _playbackState = engine_domain.PlaybackState.idle;
  double _playbackSpeed = 1.0;

  Color? _extractedColor;
  PaletteGenerator? _currentPalette;

  StreamSubscription<Track?>? _trackSub;
  StreamSubscription<engine_domain.PlaybackState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<MediaCommand>? _remoteSub;

  PlayerViewModel({
    required engine_domain.PlaybackEngine engine,
    required QueueViewModel queueVM,
    required ConnectionManager connectionManager,
  }) : _engine = engine,
       _queueVM = queueVM,
       _connectionManager = connectionManager {
    _init();
    _remoteSub = _connectionManager.remoteCommands.listen(_handleRemoteCommand);
  }

  DateTime? _lastSkipTime;

  void _init() {
    _trackSub = _engine.currentTrackStream.listen((track) {
      _currentTrack = track;
      if (track != null) {
        _extractColor(track);
      }
      notifyListeners();
      _broadcastState();
    });

    _stateSub = _engine.playbackStateStream.listen((state) {
      _playbackState = state;
      _isPlaying = state == engine_domain.PlaybackState.playing;
      if (state == engine_domain.PlaybackState.completed) {
        debugPrint('ViewModel: Track completed, triggering auto-skip.');
        _debouncedSkipNext();
      }
      notifyListeners();
      _broadcastState();
    });

    _posSub = _engine.positionStream.listen((pos) {
      _position = pos;
      
      // Fallback for platforms where completed state might be missed
      if (_playbackState == engine_domain.PlaybackState.playing &&
          _duration > Duration.zero &&
          pos >= _duration &&
          pos > Duration.zero) {
        debugPrint('ViewModel: Fallback end-of-track detected.');
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
  }

  void _debouncedSkipNext() {
    final now = DateTime.now();
    if (_lastSkipTime != null &&
        now.difference(_lastSkipTime!) < const Duration(seconds: 1)) {
      debugPrint('ViewModel: Skipping duplicate skip request (cooldown).');
      return;
    }
    _lastSkipTime = now;
    skipNext();
  }

  void _debouncedSkipPrevious() {
    final now = DateTime.now();
    if (_lastSkipTime != null &&
        now.difference(_lastSkipTime!) < const Duration(seconds: 1)) {
      debugPrint('ViewModel: Skipping duplicate skip request (cooldown).');
      return;
    }
    _lastSkipTime = now;
    skipPrevious();
  }

  void _handleRemoteCommand(MediaCommand command) {
    if (_connectionManager.isHost) {
      switch (command.type) {
        case CommandType.play:
          play();
          break;
        case CommandType.pause:
          pause();
          break;
        case CommandType.skipNext:
          skipNext();
          break;
        case CommandType.skipPrev:
          skipPrevious();
          break;
        case CommandType.seek:
          final ms = command.payload?['positionMs'] as int?;
          if (ms != null) seek(Duration(milliseconds: ms));
          break;
        default:
          break;
      }
    } else if (_connectionManager.isClient) {
      if (command.type == CommandType.syncState) {
        _updateFromRemote(command.payload);
      }
    }
  }

  Future<void> _extractColor(Track track) async {
    if (track.coverArt == null || track.coverArt!.isEmpty) {
      _extractedColor = null;
      _currentPalette = null;
      notifyListeners();
      return;
    }

    try {
      final provider = MemoryImage(track.coverArt!);
      _currentPalette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 10,
      );
      _extractedColor =
          _currentPalette?.vibrantColor?.color ??
          _currentPalette?.dominantColor?.color;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to extract color: $e');
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
    );
    _isPlaying = payload['isPlaying'] as bool? ?? false;
    _position = Duration(
      milliseconds: (payload['positionMs'] as num?)?.toInt() ?? 0,
    );
    _duration = Duration(
      milliseconds: (payload['durationMs'] as num?)?.toInt() ?? 0,
    );
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

  bool get isHostMode => _connectionManager.isHost;
  bool get isRemoteMode => _connectionManager.isClient;

  String get displayTitle => _currentTrack?.title ?? 'No Track Selected';
  String get currentArtistName => 'Artist';
  String get currentAlbumName => 'Album';

  Future<void> loadTrack(Track track) async {
    _lastSkipTime = DateTime.now(); // Set/Reset cooldown window
    _position = Duration.zero;
    _duration = Duration.zero;
    _playbackState = engine_domain.PlaybackState.loading;
    notifyListeners();

    await _engine.loadTrack(track);
    await _extractColor(track);
    play();
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

  void play() => _engine.play();
  void pause() => _engine.pause();
  void stop() => _engine.stop();
  void seek(Duration position) => _engine.seek(position);
  void setVolume(double volume) {
    _volume = volume;
    _engine.setVolume(volume);
    notifyListeners();
  }

  void setSpeed(double speed) {
    _playbackSpeed = speed;
    _engine.setSpeed(speed);
    notifyListeners();
  }

  void skipForward() {
    final newPos = _position + const Duration(seconds: 30);
    seek(newPos < _duration ? newPos : _duration);
  }

  void skipBackward() {
    final newPos = _position - const Duration(seconds: 10);
    seek(newPos > Duration.zero ? newPos : Duration.zero);
  }

  void skipNext() {
    _lastSkipTime = DateTime.now();
    _queueVM.skipNext();
    final next = _queueVM.currentTrack;
    if (next != null) {
      loadTrack(next);
    }
  }

  void skipPrevious() {
    _lastSkipTime = DateTime.now();
    _queueVM.skipPrevious();
    final prev = _queueVM.currentTrack;
    if (prev != null) {
      loadTrack(prev);
    }
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

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _trackSub?.cancel();
    _remoteSub?.cancel();
    super.dispose();
  }
}
