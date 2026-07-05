import 'package:aulos/domain/playback/playback_track.dart';

abstract class PlaybackEngine {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setSource(String path);
  Future<void> setVolume(double volume);
  // Added methods for PlayerViewModel parity
  Future<void> loadTrack(PlaybackTrack track);
  void setRepeatMode(RepeatMode mode);

  Stream<Duration?> get durationStream;
  Stream<Duration> get positionStream;
  Stream<PlaybackState> get playbackStateStream; // Alias/Added for parity
  Stream<PlaybackTrack?> get currentTrackStream;
  Stream<String> get externalCommandStream;
  Stream<String?> get icyMetadataStream;
}

enum RepeatMode { off, all, one }

enum PlaybackState {
  idle,
  loading,
  buffering,
  ready,
  playing,
  paused,
  completed,
  error,
}
