import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart'
    as domain;
import 'package:localaudioplayer/data/playback/audio_service_handler.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:io' as io;

class JustAudioPlaybackEngine implements domain.PlaybackEngine {
  final ObsidianAudioHandler _handler;
  bool _isInitialized = false;

  final _currentTrackController = StreamController<Track?>.broadcast();
  Track? _currentTrack;

  JustAudioPlaybackEngine({required ObsidianAudioHandler handler})
    : _handler = handler {
    _handler.player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace st) {
      _logPlaybackError(e, st);
    });
  }

  void _logPlaybackError(Object e, [StackTrace? st]) {
    final trackInfo = _currentTrack != null 
      ? '${_currentTrack!.title} (${_currentTrack!.path})' 
      : 'Unknown Track';
    
    debugPrint('PLAYBACK FAILURE: Failed to play $trackInfo');
    debugPrint('Error Details: $e');
    
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('codec') || errorStr.contains('format')) {
      debugPrint('Diagnostic: Possible missing codec or unsupported format.');
    } else if (errorStr.contains('file') || errorStr.contains('not found')) {
      debugPrint('Diagnostic: File missing or inaccessible.');
    }
  }

  Future<void> _ensureSession() async {
    if (_isInitialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _isInitialized = true;
      debugPrint('Engine: AudioSession configured');
    } catch (e) {
      debugPrint('Engine: AudioSession error: $e');
    }
  }

  @override
  Future<void> play() async {
    await _ensureSession();
    await _handler.play();
  }

  @override
  Future<void> pause() async {
    await _handler.pause();
  }

  @override
  Future<void> stop() async {
    await _handler.stop();
  }

  @override
  Future<void> seek(Duration position) => _handler.seek(position);

  @override
  Future<void> setSpeed(double speed) => _handler.player.setSpeed(speed);

  @override
  Future<void> setVolume(double volume) => _handler.player.setVolume(volume);

  @override
  Future<void> setSource(String path) async {
    await _ensureSession();
    try {
      debugPrint('Engine: Preparing source: $path');
      final file = io.File(path);
      if (!file.existsSync()) {
        final err = 'File does not exist at path: $path';
        debugPrint('PLAYBACK FAILURE: $err');
        return;
      }
      await _handler.setSource(Uri.file(file.absolute.path));
    } catch (e, st) {
      _logPlaybackError(e, st);
    }
  }

  @override
  Future<void> loadTrack(Track track) async {
    _currentTrack = track;
    _currentTrackController.add(track);
    await setSource(track.path);
    await setMetadata(track.title, 'Artist', art: track.coverArt);
  }

  @override
  void setRepeatMode(domain.RepeatMode mode) {
    LoopMode justLoop;
    switch (mode) {
      case domain.RepeatMode.off:
        justLoop = LoopMode.off;
        break;
      case domain.RepeatMode.one:
        justLoop = LoopMode.one;
        break;
      case domain.RepeatMode.all:
        // IMPORTANT: We handle playlist-level repeat in the ViewModel.
        // If we set LoopMode.all here with a single source, just_audio
        // will loop that source forever and never emit 'completed'.
        justLoop = LoopMode.off;
        break;
    }
    _handler.player.setLoopMode(justLoop);
  }

  @override
  Future<void> setMetadata(
    String title,
    String artist, {
    String? album,
    Uint8List? art,
  }) async {
    _handler.updateMetadata(
      MediaItem(id: title + artist, album: album, title: title, artist: artist),
    );
  }

  @override
  Stream<Duration?> get durationStream => _handler.player.durationStream;

  @override
  Stream<Duration> get positionStream => _handler.player.positionStream;

  @override
  Stream<domain.PlaybackState> get stateStream =>
      _handler.player.playerStateStream.map((state) {
        if (state.processingState == ProcessingState.idle) {
          return domain.PlaybackState.idle;
        }
        if (state.processingState == ProcessingState.loading) {
          return domain.PlaybackState.loading;
        }
        if (state.processingState == ProcessingState.buffering) {
          return domain.PlaybackState.buffering;
        }
        if (state.processingState == ProcessingState.ready) {
          return state.playing
              ? domain.PlaybackState.playing
              : domain.PlaybackState.paused;
        }
        if (state.processingState == ProcessingState.completed) {
          return domain.PlaybackState.completed;
        }
        return domain.PlaybackState.error;
      });

  @override
  Stream<domain.PlaybackState> get playbackStateStream => stateStream;

  @override
  Stream<Track?> get currentTrackStream => _currentTrackController.stream;

  @override
  Stream<String> get externalCommandStream => _handler.customEventStream;
}
