import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/main.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/presentation/viewmodels/mood_view_model.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as domain;

class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockDisplayViewModel extends Mock implements DisplayViewModel {}
class MockConnectivityViewModel extends Mock implements ConnectivityViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockNoiseViewModel extends Mock implements NoiseViewModel {}
class MockMoodViewModel extends Mock implements MoodViewModel {}

void main() {
  late MockPlayerViewModel mockPlayerVM;
  late MockQueueViewModel mockQueueVM;
  late MockDisplayViewModel mockDisplayVM;
  late MockConnectivityViewModel mockConnectivityVM;
  late MockSettingsViewModel mockSettingsVM;
  late MockNoiseViewModel mockNoiseVM;
  late MockMoodViewModel mockMoodViewModel;

  setUpAll(() {
    registerFallbackValue(domain.PlaybackState.idle);
  });

  setUp(() {
    mockPlayerVM = MockPlayerViewModel();
    when(() => mockPlayerVM.isSleepTimerActive).thenReturn(false);
    when(() => mockPlayerVM.sleepTimeRemaining).thenReturn(Duration.zero);
    mockQueueVM = MockQueueViewModel();
    mockDisplayVM = MockDisplayViewModel();
    mockConnectivityVM = MockConnectivityViewModel();
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    mockNoiseVM = MockNoiseViewModel();
    mockMoodViewModel = MockMoodViewModel();

    // MoodViewModel stubs
    when(() => mockMoodViewModel.lastMusic).thenReturn(null);
    when(() => mockMoodViewModel.lastPodcast).thenReturn(null);
    when(() => mockMoodViewModel.lastAudiobook).thenReturn(null);
    when(() => mockMoodViewModel.lastNoise).thenReturn(null);
    when(() => mockMoodViewModel.isLoading).thenReturn(false);
    when(() => mockMoodViewModel.loadLastPlayedItems()).thenAnswer((_) async {});
    when(() => mockMoodViewModel.addListener(any())).thenReturn(null);
    when(() => mockMoodViewModel.removeListener(any())).thenReturn(null);

    // Default mock setup
    when(() => mockPlayerVM.state).thenReturn(domain.PlaybackState.idle);
    when(() => mockPlayerVM.position).thenReturn(Duration.zero);
    when(() => mockPlayerVM.duration).thenReturn(Duration.zero);
    when(() => mockPlayerVM.isPlaying).thenReturn(false);
    when(() => mockPlayerVM.isRemoteMode).thenReturn(false);
    when(() => mockPlayerVM.isHostMode).thenReturn(false);
    when(() => mockPlayerVM.volume).thenReturn(1.0);
    when(() => mockPlayerVM.currentTrack).thenReturn(null);
    when(() => mockPlayerVM.currentArtistName).thenReturn('Test Artist');
    when(() => mockPlayerVM.currentAlbumName).thenReturn('Test Album');
    when(() => mockPlayerVM.displayTitle).thenReturn('No Track');
    when(() => mockPlayerVM.isShuffle).thenReturn(false);
    when(() => mockPlayerVM.repeatMode).thenReturn(domain.RepeatMode.off);
    when(() => mockPlayerVM.currentMediaType).thenReturn(MediaType.music);
    when(() => mockPlayerVM.currentShowNotes).thenReturn(null);
    when(() => mockPlayerVM.currentStreamMetadata).thenReturn(null);
    when(() => mockPlayerVM.currentImageUrl).thenReturn(null);
    when(() => mockPlayerVM.isBookmarkMode).thenReturn(false);
    when(() => mockPlayerVM.isBuffering).thenReturn(false);
    when(() => mockPlayerVM.extractedColor).thenReturn(null);
    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockQueueVM.currentQueue).thenReturn([]);
    when(() => mockQueueVM.history).thenReturn([]);
    when(() => mockQueueVM.currentIndex).thenReturn(-1);
    when(() => mockQueueVM.currentTrack).thenReturn(null);
    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);

    when(() => mockDisplayVM.mode).thenReturn(UIContextMode.minimalist);
    when(() => mockDisplayVM.addListener(any())).thenReturn(null);
    when(() => mockDisplayVM.removeListener(any())).thenReturn(null);

    when(() => mockConnectivityVM.isHosting).thenReturn(false);
    when(() => mockConnectivityVM.isRemoteMode).thenReturn(false);
    when(() => mockConnectivityVM.addListener(any())).thenReturn(null);
    when(() => mockConnectivityVM.removeListener(any())).thenReturn(null);
    
    when(() => mockSettingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => mockSettingsVM.isDynamicTheme).thenReturn(false);
    when(() => mockSettingsVM.isVisualizerEnabled).thenReturn(false);
    when(() => mockSettingsVM.visualizerPluginId).thenReturn('bar_spectrum');
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    when(() => mockNoiseVM.masterVolume).thenReturn(0.5);
    when(() => mockNoiseVM.addListener(any())).thenReturn(null);
    when(() => mockNoiseVM.removeListener(any())).thenReturn(null);

    // Setup stubbing for playerVM control methods
    when(() => mockPlayerVM.togglePlay()).thenReturn(null);
    when(() => mockPlayerVM.play()).thenReturn(null);
    when(() => mockPlayerVM.pause()).thenReturn(null);
    when(() => mockPlayerVM.stop()).thenReturn(null);
    when(() => mockPlayerVM.skipNext()).thenReturn(null);
    when(() => mockPlayerVM.skipPrevious()).thenReturn(null);
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
        ChangeNotifierProvider<QueueViewModel>.value(value: mockQueueVM),
        ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ChangeNotifierProvider<ConnectivityViewModel>.value(value: mockConnectivityVM),
        ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
        ChangeNotifierProvider<NoiseViewModel>.value(value: mockNoiseVM),
        ChangeNotifierProvider<MoodViewModel>.value(value: mockMoodViewModel),
      ],
      child: const AulosApp(),
    );
  }

  group('Global Keyboard Shortcuts', () {
    testWidgets('Space key toggles playback when no input is focused', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Send space bar key event
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      verify(() => mockPlayerVM.togglePlay()).called(1);
    });

    testWidgets('Space key does NOT toggle playback when a TextField is focused', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Push a new page with a TextField to gain focus
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.push(MaterialPageRoute<void>(
        builder: (context) => const Scaffold(
          body: TextField(
            autofocus: true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Send space bar key event
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      // Verify togglePlay is NOT called
      verifyNever(() => mockPlayerVM.togglePlay());
    });

    testWidgets('Media play/pause keys always trigger correct ViewModel operations', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // 1. MediaPlayPause key
      await tester.sendKeyEvent(LogicalKeyboardKey.mediaPlayPause);
      await tester.pumpAndSettle();
      verify(() => mockPlayerVM.togglePlay()).called(1);

      // 2. MediaPlay key
      await tester.sendKeyEvent(LogicalKeyboardKey.mediaPlay);
      await tester.pumpAndSettle();
      verify(() => mockPlayerVM.play()).called(1);

      // 3. MediaPause key
      await tester.sendKeyEvent(LogicalKeyboardKey.mediaPause);
      await tester.pumpAndSettle();
      verify(() => mockPlayerVM.pause()).called(1);

      // 4. MediaTrackNext key
      await tester.sendKeyEvent(LogicalKeyboardKey.mediaTrackNext);
      await tester.pumpAndSettle();
      verify(() => mockPlayerVM.skipNext()).called(1);

      // 5. MediaTrackPrevious key
      await tester.sendKeyEvent(LogicalKeyboardKey.mediaTrackPrevious);
      await tester.pumpAndSettle();
      verify(() => mockPlayerVM.skipPrevious()).called(1);

      // 6. MediaStop key
      await tester.sendKeyEvent(LogicalKeyboardKey.mediaStop);
      await tester.pumpAndSettle();
      verify(() => mockPlayerVM.stop()).called(1);
    });
  });
}
