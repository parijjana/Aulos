import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/domain/playback/playback_engine.dart';

class MockPlaybackEngine extends Mock implements PlaybackEngine {}

void main() {
  late MockPlaybackEngine mockEngine;

  setUp(() {
    mockEngine = MockPlaybackEngine();
  });

  group('PlaybackEngine Interface', () {
    test('should be able to call play', () async {
      when(() => mockEngine.play()).thenAnswer((_) async => {});

      await mockEngine.play();

      verify(() => mockEngine.play()).called(1);
    });

    test('should be able to call pause', () async {
      when(() => mockEngine.pause()).thenAnswer((_) async => {});

      await mockEngine.pause();

      verify(() => mockEngine.pause()).called(1);
    });

    test('should be able to call stop', () async {
      when(() => mockEngine.stop()).thenAnswer((_) async => {});

      await mockEngine.stop();

      verify(() => mockEngine.stop()).called(1);
    });
  });
}
