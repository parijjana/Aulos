import 'dart:typed_data';
import 'package:localaudioplayer/data/database/app_database.dart';

abstract class PlaybackEngine {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> setSource(String path);
  Future<void> setVolume(double volume);
  Future<void> setMetadata(
    String title,
    String artist, {
    String? album,
    Uint8List? art,
  });

  // Added methods for PlayerViewModel parity
  Future<void> loadTrack(Track track);
  void setRepeatMode(RepeatMode mode);

  Stream<Duration?> get durationStream;
  Stream<Duration> get positionStream;
  Stream<PlaybackState> get stateStream;
  Stream<PlaybackState> get playbackStateStream; // Alias/Added for parity
  Stream<Track?> get currentTrackStream;
  Stream<String> get externalCommandStream;
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
