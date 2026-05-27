import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:io';
import 'package:aulos/domain/network/log_service.dart';
import 'file_stream_source.dart';
import 'package:path/path.dart' as p;

class AulosAudioHandler extends BaseAudioHandler with SeekHandler, UniversalLog {
  final AudioPlayer _player = AudioPlayer();
  final _customEventController = StreamController<String>.broadcast();

  AulosAudioHandler() {
    _player.playerStateStream.listen((state) {
      log('HANDLER: Player State -> Playing: ${state.playing}, Processing: ${state.processingState}');
    });
    
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    
    _player.playbackEventStream.listen((event) {
      if (event.icyMetadata != null) {
        log('HANDLER: ICY Metadata -> ${event.icyMetadata}');
      }
    }, onError: (Object e, StackTrace st) {
      log('HANDLER_ERROR: Player Event Error -> $e');
    });

    _player.durationStream.listen((dur) {
      final currentItem = mediaItem.value;
      if (currentItem != null && dur != null) {
        log('HANDLER: Duration resolved -> ${dur.inSeconds}s');
        mediaItem.add(currentItem.copyWith(duration: dur));
      }
    });
  }

  Stream<String> get customEventStream => _customEventController.stream;

  @override
  Future<void> play() {
    log('HANDLER: Play called. Current State: ${_player.processingState}');
    return _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> skipToNext() async {
    _customEventController.add('skipNext');
  }

  @override
  Future<void> skipToPrevious() async {
    _customEventController.add('skipPrevious');
  }

  Future<void> setSource(Uri uri, {bool isRetry = false}) async {
    try {
      final String rawPath = uri.toFilePath();
      log('HANDLER: Setting source -> $rawPath (Retry: $isRetry)');
      
      final String ext = p.extension(rawPath).toLowerCase();
      final String mimeType = (ext == '.m4b' || ext == '.m4a') ? 'audio/mp4' : 'audio/mpeg';

      final AudioSource source;
      if (uri.isScheme('file')) {
        log('HANDLER: Using FileStreamSource ($mimeType) for local path.');
        source = FileStreamSource(File(rawPath), contentType: mimeType);
      } else {
        source = AudioSource.uri(uri);
      }

      await _player.setAudioSource(source, preload: false).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          log('HANDLER_TIMEOUT: Stream source taking long to init.');
        },
      );
      
      log('HANDLER: Source set success.');
    } catch (e) {
      final errStr = e.toString();
      if (!isRetry && (errStr.contains('Loading interrupted') || errStr.contains('busy'))) {
        log('HANDLER_RECOVERY: Transient error ($errStr). Retrying in 2s...');
        await Future.delayed(const Duration(seconds: 2000));
        return setSource(uri, isRetry: true);
      }
      log('HANDLER_ERROR: Critical failure: $e');
      rethrow;
    }
  }

  void updateMetadata(MediaItem item) {
    mediaItem.add(item);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  AudioPlayer get player => _player;

  Stream<String?> get icyMetadataStream => _player.icyMetadataStream.map((icy) {
    if (icy == null) return null;
    final info = icy.info;
    if (info == null) return icy.headers?.name;
    return '${info.title}${info.url != null ? " (${info.url})" : ""}';
  });

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState] ?? AudioProcessingState.idle,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
