import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/presentation/screens/now_playing_screen.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/insights_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as engine_domain;
import 'package:drift/native.dart';

class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockNoiseViewModel extends Mock implements NoiseViewModel {}

void main() {
  late MockPlayerViewModel playerVM;
  late MockQueueViewModel queueVM;
  late MockSettingsViewModel settingsVM;
  late MockNoiseViewModel noiseVM;
  late AppDatabase db;
  late PodcastDatabase podcastDb;
  late RadioDatabase radioDb;
  late InsightsViewModel insightsVM;

  setUp(() {
    playerVM = MockPlayerViewModel();
    when(() => playerVM.isSleepTimerActive).thenReturn(false);
    when(() => playerVM.sleepTimeRemaining).thenReturn(Duration.zero);
    queueVM = MockQueueViewModel();
    settingsVM = MockSettingsViewModel();
    when(() => settingsVM.isFolderWatcherEnabled).thenReturn(true);
    noiseVM = MockNoiseViewModel();
    db = AppDatabase.testing(NativeDatabase.memory());
    podcastDb = PodcastDatabase.testing(NativeDatabase.memory());
    radioDb = RadioDatabase.testing(NativeDatabase.memory());
    insightsVM = InsightsViewModel(db: db, podcastDb: podcastDb, radioDb: radioDb);

    when(() => playerVM.displayTitle).thenReturn('Test Track');
    when(() => playerVM.currentArtistName).thenReturn('Test Artist');
    when(() => playerVM.isPlaying).thenReturn(false);
    when(() => playerVM.volume).thenReturn(0.5);
    when(() => playerVM.position).thenReturn(Duration.zero);
    when(() => playerVM.duration).thenReturn(const Duration(minutes: 3));
    when(() => playerVM.currentMediaType).thenReturn(MediaType.music);
    when(() => playerVM.playbackSpeed).thenReturn(1.0);
    when(() => playerVM.repeatMode).thenReturn(engine_domain.RepeatMode.off);
    when(() => playerVM.isShuffle).thenReturn(false);
    when(() => playerVM.isRemoteMode).thenReturn(false);
    when(() => playerVM.isHostMode).thenReturn(false);
    when(() => playerVM.extractedColor).thenReturn(null);
    when(() => playerVM.currentTrack).thenReturn(null);
    when(() => playerVM.currentImageUrl).thenReturn(null);
    when(() => playerVM.currentShowNotes).thenReturn(null);
    when(() => playerVM.currentStreamMetadata).thenReturn(null);
    when(() => playerVM.isBookmarkMode).thenReturn(false);
    when(() => playerVM.isBuffering).thenReturn(false);
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);
    
    when(() => queueVM.currentQueue).thenReturn([]);
    when(() => queueVM.currentIndex).thenReturn(0);
    when(() => queueVM.addListener(any())).thenReturn(null);
    when(() => queueVM.removeListener(any())).thenReturn(null);

    when(() => settingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(true);
    when(() => settingsVM.isVisualizerEnabled).thenReturn(false);
    when(() => settingsVM.visualizerPluginId).thenReturn('bar_spectrum');
    when(() => settingsVM.addListener(any())).thenReturn(null);
    when(() => settingsVM.removeListener(any())).thenReturn(null);

    when(() => noiseVM.masterVolume).thenReturn(0.5);
    when(() => noiseVM.addListener(any())).thenReturn(null);
    when(() => noiseVM.removeListener(any())).thenReturn(null);
  });

  tearDown(() async {
    await db.close();
    await podcastDb.close();
    await radioDb.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
          ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
          ChangeNotifierProvider<InsightsViewModel>.value(value: insightsVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
          ChangeNotifierProvider<NoiseViewModel>.value(value: noiseVM),
        ],
        child: const NowPlayingScreen(),
      ),
    );
  }

  testWidgets('NowPlayingScreen should have a grab bar for Insights drawer', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.byKey(const Key('insights_grab_bar')), findsOneWidget);
  });

  testWidgets('Opening Insights drawer should show insights content', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openEndDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Favorites & Insights'), findsAtLeastNWidgets(1));

    // Force widget disposal and pump timers
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });
}
