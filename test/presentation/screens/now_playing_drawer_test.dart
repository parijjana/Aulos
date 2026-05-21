import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localaudioplayer/presentation/screens/now_playing_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/insights_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/theme/obsidian_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as engine_domain;
import 'package:drift/native.dart';

class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late MockPlayerViewModel playerVM;
  late MockQueueViewModel queueVM;
  late MockSettingsViewModel settingsVM;
  late AppDatabase db;
  late InsightsViewModel insightsVM;

  setUp(() {
    playerVM = MockPlayerViewModel();
    queueVM = MockQueueViewModel();
    settingsVM = MockSettingsViewModel();
    db = AppDatabase.testing(NativeDatabase.memory());
    insightsVM = InsightsViewModel(db);

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
    
    when(() => queueVM.currentQueue).thenReturn([]);
    when(() => queueVM.currentIndex).thenReturn(0);

    when(() => settingsVM.themeModel).thenReturn(ObsidianAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(true);
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
          ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
          ChangeNotifierProvider<InsightsViewModel>.value(value: insightsVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
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
  });
}
