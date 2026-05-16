import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:localaudioplayer/data/playback/just_audio_playback_engine.dart';
import 'package:localaudioplayer/data/playback/audio_service_handler.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockAudioHandler extends Mock implements ObsidianAudioHandler {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late JustAudioPlaybackEngine engine;
  late ObsidianAudioHandler handler;

  setUp(() {
    handler = ObsidianAudioHandler();

    // We need to use the real handler but mock the underlying player to avoid platform calls
    // However, ObsidianAudioHandler creates its own player.
    // For this test, we'll verify the stream logic.
    engine = JustAudioPlaybackEngine(handler: handler);
  });

  group('Android Notification Integration', () {
    test(
      'handler.skipToNext() should emit skipNext on engine.externalCommandStream',
      () async {
        final List<String> commands = [];
        final sub = engine.externalCommandStream.listen(commands.add);

        await handler.skipToNext();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(commands, contains('skipNext'));
        await sub.cancel();
      },
    );

    test(
      'handler.skipToPrevious() should emit skipPrevious on engine.externalCommandStream',
      () async {
        final List<String> commands = [];
        final sub = engine.externalCommandStream.listen(commands.add);

        await handler.skipToPrevious();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(commands, contains('skipPrevious'));
        await sub.cancel();
      },
    );
  });
}
