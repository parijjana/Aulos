import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:aulos/domain/playback/playback_engine.dart'
    as domain;
import 'package:aulos/domain/playback/playback_track.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/playback/audio_service_handler.dart';
import 'package:aulos/domain/network/log_service.dart';

class JustAudioPlaybackEngine extends domain.PlaybackEngine {
  final AulosAudioHandler _handler;
  final LogService _logService;
  final BehaviorSubject<domain.PlaybackState> _stateController =
      BehaviorSubject<domain.PlaybackState>.seeded(domain.PlaybackState.idle);
  final StreamController<PlaybackTrack?> _currentTrackController =
      StreamController<PlaybackTrack?>.broadcast();

  JustAudioPlaybackEngine({
    required AulosAudioHandler handler,
    LogService? logService,
  })  : _handler = handler,
        _logService = logService ?? NoOpLogService() {
    _init();
  }

  void log(String message) => _logService.log(message);

  void _init() {
    _handler.playbackState.listen((state) {
      final domainState = _mapState(state.processingState, state.playing);
      _stateController.add(domainState);
    });
  }

  domain.PlaybackState _mapState(AudioProcessingState state, bool playing) {
    if (!playing && 
        state != AudioProcessingState.completed && 
        state != AudioProcessingState.idle &&
        state != AudioProcessingState.error) {
      return domain.PlaybackState.paused;
    }
    switch (state) {
      case AudioProcessingState.idle:
        return domain.PlaybackState.idle;
      case AudioProcessingState.loading:
      case AudioProcessingState.buffering:
        return domain.PlaybackState.loading;
      case AudioProcessingState.ready:
        return domain.PlaybackState.playing;
      case AudioProcessingState.completed:
        return domain.PlaybackState.completed;
      case AudioProcessingState.error:
        return domain.PlaybackState.error;
    }
  }

  Future<void> _ensureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  @override
  Future<void> setSource(String path) async {
    await _ensureSession();
    try {
      log('ENGINE: Preparing source: $path');
      Uri uri;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        uri = Uri.parse(path);
      } else {
        final file = io.File(path);
        if (!file.existsSync()) {
          log('ENGINE_FAILURE: File does not exist at path: $path');
          return;
        }
        uri = Uri.file(file.absolute.path);
      }
      await _handler.setSource(uri);
    } catch (e) {
      log('ENGINE_ERROR: Failed to set source: $e');
    }
  }

  @override
  Future<void> play() async {
    log('ENGINE: Play');
    await _handler.play();
  }

  @override
  Future<void> pause() async {
    log('ENGINE: Pause');
    await _handler.pause();
  }

  @override
  Future<void> stop() async {
    log('ENGINE: Stop');
    await _handler.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    log('ENGINE: Seek to ${position.inSeconds}s');
    await _handler.seek(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _handler.setVolume(volume);
  }

  @override
  Future<void> setSpeed(double speed) async {
    log('ENGINE: Speed set to ${speed}x');
    await _handler.setSpeed(speed);
  }

  @override
  Future<void> setRepeatMode(domain.RepeatMode mode) async {
    log('ENGINE: Repeat mode set to $mode');
    AudioServiceRepeatMode am;
    switch (mode) {
      case domain.RepeatMode.off: am = AudioServiceRepeatMode.none; break;
      case domain.RepeatMode.one: am = AudioServiceRepeatMode.one; break;
      case domain.RepeatMode.all: am = AudioServiceRepeatMode.all; break;
    }
    await _handler.setRepeatMode(am);
  }



  @override
  Future<void> loadTrack(PlaybackTrack track) async {
    log('ENGINE: Loading track: "${track.title}"');
    _currentTrackController.add(track);
    
    // SYNC METADATA: Tell AudioService about the track so it can track duration
    _handler.updateMetadata(MediaItem(
      id: track.path,
      title: track.title,
      artist: 'Aulos Audio',
    ));

    await setSource(track.path);
  }

  @override
  Stream<Duration> get positionStream => _handler.player.positionStream;

  @override
  Stream<Duration?> get durationStream => _handler.player.durationStream;



  @override
  Stream<domain.PlaybackState> get playbackStateStream => _stateController.stream;

  @override
  Stream<PlaybackTrack?> get currentTrackStream => _currentTrackController.stream;

  @override
  Stream<String> get externalCommandStream => _handler.customEventStream.cast<String>();

  @override
  Stream<String?> get icyMetadataStream => _handler.icyMetadataStream;
}
