import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:aulos/data/playback/just_audio_playback_engine.dart';
import 'package:aulos/data/playback/audio_service_handler.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as domain;
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockAudioHandler extends Mock implements AulosAudioHandler {}

void main() {
  late JustAudioPlaybackEngine engine;
  late MockAudioHandler mockHandler;
  late MockAudioPlayer mockPlayer;
  late BehaviorSubject<PlaybackState> playbackStateSubject;

  setUp(() {
    mockHandler = MockAudioHandler();
    mockPlayer = MockAudioPlayer();
    playbackStateSubject = BehaviorSubject<PlaybackState>.seeded(PlaybackState());

    when(() => mockHandler.player).thenReturn(mockPlayer);
    when(() => mockHandler.playbackState).thenAnswer((_) => playbackStateSubject);
    
    when(() => mockPlayer.durationStream).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.positionStream).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayer.playbackEventStream).thenAnswer((_) => const Stream.empty());

    engine = JustAudioPlaybackEngine(handler: mockHandler);
  });

  group('Playback Verification', () {
    test('should emit idle state initially', () async {
      expect(engine.playbackStateStream, emits(domain.PlaybackState.idle));
    });

    test('should emit playing state when player is playing', () async {
      playbackStateSubject.add(PlaybackState(playing: true, processingState: AudioProcessingState.ready));
      expect(engine.playbackStateStream, emitsThrough(domain.PlaybackState.playing));
    });
  });
}
