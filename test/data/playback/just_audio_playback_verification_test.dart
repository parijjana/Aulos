import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:localaudioplayer/data/playback/just_audio_playback_engine.dart';
import 'package:localaudioplayer/data/playback/audio_service_handler.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart'
    as domain;

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockAudioHandler extends Mock implements ObsidianAudioHandler {}

void main() {
  late JustAudioPlaybackEngine engine;
  late MockAudioHandler mockHandler;
  late MockAudioPlayer mockPlayer;

  setUp(() {
    mockHandler = MockAudioHandler();
    mockPlayer = MockAudioPlayer();

    when(() => mockHandler.player).thenReturn(mockPlayer);
    when(
      () => mockPlayer.durationStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayer.positionStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayer.playerStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayer.playbackEventStream,
    ).thenAnswer((_) => const Stream.empty());

    engine = JustAudioPlaybackEngine(handler: mockHandler);
  });

  group('Playback Verification', () {
    test('should emit idle state initially', () {
      final stateController = StreamController<PlayerState>();
      when(
        () => mockPlayer.playerStateStream,
      ).thenAnswer((_) => stateController.stream);

      // Re-init with stream
      engine = JustAudioPlaybackEngine(handler: mockHandler);

      stateController.add(PlayerState(false, ProcessingState.idle));

      expect(engine.stateStream, emits(domain.PlaybackState.idle));
      stateController.close();
    });

    test('should emit playing state when player is playing', () {
      final stateController = StreamController<PlayerState>();
      when(
        () => mockPlayer.playerStateStream,
      ).thenAnswer((_) => stateController.stream);

      engine = JustAudioPlaybackEngine(handler: mockHandler);

      stateController.add(PlayerState(true, ProcessingState.ready));

      expect(engine.stateStream, emits(domain.PlaybackState.playing));
      stateController.close();
    });
  });
}
