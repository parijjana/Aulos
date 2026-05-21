import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:localaudioplayer/presentation/screens/now_playing_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/theme/obsidian_audio_theme.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as domain;
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:themer_flutter/themer_flutter.dart';

class MockPlayerViewModel extends Mock implements PlayerViewModel {}

class MockQueueViewModel extends Mock implements QueueViewModel {}

class MockDisplayViewModel extends Mock implements DisplayViewModel {}

class MockConnectivityViewModel extends Mock implements ConnectivityViewModel {}

class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late MockPlayerViewModel mockPlayerVM;
  late MockQueueViewModel mockQueueVM;
  late MockDisplayViewModel mockDisplayVM;
  late MockConnectivityViewModel mockConnectivityVM;
  late MockSettingsViewModel mockSettingsVM;

  setUpAll(() {
    registerFallbackValue(domain.PlaybackState.idle);
  });

  setUp(() {
    mockPlayerVM = MockPlayerViewModel();
    mockQueueVM = MockQueueViewModel();
    mockDisplayVM = MockDisplayViewModel();
    mockConnectivityVM = MockConnectivityViewModel();
    mockSettingsVM = MockSettingsViewModel();

    when(() => mockPlayerVM.state).thenReturn(domain.PlaybackState.idle);
    when(() => mockPlayerVM.position).thenReturn(Duration.zero);
    when(() => mockPlayerVM.duration).thenReturn(Duration.zero);
    when(() => mockPlayerVM.isPlaying).thenReturn(false);
    when(() => mockPlayerVM.isMuted).thenReturn(false);
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
    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockQueueVM.currentQueue).thenReturn([]);
    when(() => mockQueueVM.history).thenReturn([]);
    when(() => mockQueueVM.currentIndex).thenReturn(-1);
    when(() => mockQueueVM.currentTrack).thenReturn(null);
    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);

    when(() => mockDisplayVM.isHighContext).thenReturn(false);
    when(() => mockDisplayVM.addListener(any())).thenReturn(null);
    when(() => mockDisplayVM.removeListener(any())).thenReturn(null);

    when(() => mockConnectivityVM.isHosting).thenReturn(false);
    when(() => mockConnectivityVM.isRemoteMode).thenReturn(false);
    when(() => mockConnectivityVM.addListener(any())).thenReturn(null);
    when(() => mockConnectivityVM.removeListener(any())).thenReturn(null);
    
    when(() => mockSettingsVM.themeModel).thenReturn(ObsidianAudioTheme.model);
    when(() => mockSettingsVM.isDynamicTheme).thenReturn(false);
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ThemerProvider(
          theme: ObsidianAudioTheme.model,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<PlayerViewModel>.value(
                value: mockPlayerVM,
              ),
              ChangeNotifierProvider<QueueViewModel>.value(value: mockQueueVM),
              ChangeNotifierProvider<DisplayViewModel>.value(
                value: mockDisplayVM,
              ),
              ChangeNotifierProvider<ConnectivityViewModel>.value(
                value: mockConnectivityVM,
              ),
              ChangeNotifierProvider<SettingsViewModel>.value(
                value: mockSettingsVM,
              ),
            ],
            child: const NowPlayingScreen(),
          ),
        ),
      ),
    );
  }

  group('NowPlayingScreen', () {
    testWidgets('should render progress bar', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      expect(
        find.byType(Slider),
        findsNWidgets(2),
      ); 
    });

    testWidgets('should trigger like and dislike on tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final track = Track(
        id: 1,
        title: 'Test',
        path: 'path',
        folderId: 1,
        rating: 0,
        isFavorite: false,
        playCount: 0,
      );
      when(() => mockPlayerVM.currentTrack).thenReturn(track);
      when(
        () => mockQueueVM.updateRating(any(), any()),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(buildTestableWidget());

      final favFinder = find.byIcon(Icons.favorite_border);
      await tester.ensureVisible(favFinder);
      await tester.tap(favFinder);
      verify(() => mockQueueVM.updateRating(1, 1)).called(1);

      final thumbFinder = find.byIcon(Icons.thumb_down_alt_outlined);
      await tester.ensureVisible(thumbFinder);
      await tester.tap(thumbFinder);
      verify(() => mockQueueVM.updateRating(1, -1)).called(1);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
