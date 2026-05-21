import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart'
    as domain;
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/playback/audio_service_handler.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';

class JustAudioPlaybackEngine extends domain.PlaybackEngine with UniversalLog {
  final ObsidianAudioHandler _handler;
  final BehaviorSubject<domain.PlaybackState> _stateController =
      BehaviorSubject<domain.PlaybackState>.seeded(domain.PlaybackState.idle);
  final StreamController<Track?> _currentTrackController =
      StreamController<Track?>.broadcast();

  JustAudioPlaybackEngine({required ObsidianAudioHandler handler})
      : _handler = handler {
    _init();
  }

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
      if (path.startsWith('http')) {
        uri = Uri.parse(path);
      } else {
        final file = io.File(path);
        if (!file.existsSync()) {
          final err = 'File does not exist at path: $path';
          log('ENGINE_FAILURE: $err');
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
    await _handler.customAction('setVolume', {'volume': volume});
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
  Future<void> setMetadata(String title, String artist, {String? album, Uint8List? art}) async {
    // MediaItem setup is usually handled within the handler when a source is loaded
  }

  @override
  Future<void> loadTrack(Track track) async {
    log('ENGINE: Loading track: "${track.title}"');
    _currentTrackController.add(track);
    await setSource(track.path);
  }

  @override
  Stream<Duration> get positionStream => AudioService.position;

  @override
  Stream<Duration?> get durationStream => _handler.mediaItem.map((i) => i?.duration);

  @override
  Stream<domain.PlaybackState> get stateStream => _stateController.stream;

  @override
  Stream<domain.PlaybackState> get playbackStateStream => _stateController.stream;

  @override
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;

  @override
  Stream<String> get externalCommandStream => _handler.customEventStream.cast<String>();

  @override
  Stream<String?> get icyMetadataStream => _handler.icyMetadataStream;
  }
