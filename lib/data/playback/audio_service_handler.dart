import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class ObsidianAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final _customEventController = StreamController<String>.broadcast();

  ObsidianAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Stream<String> get customEventStream => _customEventController.stream;

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    _customEventController.add('skipNext');
  }

  @override
  Future<void> skipToPrevious() async {
    _customEventController.add('skipPrevious');
  }

  Future<void> setSource(Uri uri) async {
    await _player.setAudioSource(AudioSource.uri(uri));
  }

  void updateMetadata(MediaItem item) {
    mediaItem.add(item);
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
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
