import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:aulos/data/playback/just_audio_playback_engine.dart';
import 'package:aulos/data/playback/audio_service_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockAudioHandler extends Mock implements AulosAudioHandler {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  group('JustAudioPlaybackEngine', () {
    test('play calls handler.play', () async {
      when(() => mockHandler.play()).thenAnswer((_) async {});
      await engine.play();
      verify(() => mockHandler.play()).called(1);
    });

    test('pause calls handler.pause', () async {
      when(() => mockHandler.pause()).thenAnswer((_) async {});
      await engine.pause();
      verify(() => mockHandler.pause()).called(1);
    });

    test('stop calls handler.stop', () async {
      when(() => mockHandler.stop()).thenAnswer((_) async {});
      await engine.stop();
      verify(() => mockHandler.stop()).called(1);
    });
  });
}
