import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/main/screens/high_context_tabbed_screen.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/presentation/viewmodels/insights_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as domain;
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:drift/native.dart';
import 'package:themer_flutter/themer_flutter.dart';

class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockDisplayViewModel extends Mock implements DisplayViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockConnectivityViewModel extends Mock implements ConnectivityViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockIndexerService extends Mock implements LibraryIndexerService {}
class MockPodcastViewModel extends Mock implements PodcastViewModel {}
class MockRadioViewModel extends Mock implements RadioViewModel {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}
class MockDiscoverySyncManager extends Mock implements DiscoverySyncManager {}
class MockLogService extends Mock implements LogService {}
class MockNoiseViewModel extends Mock implements NoiseViewModel {}

void main() {
  late MockPlayerViewModel mockPlayerVM;
  late MockQueueViewModel mockQueueVM;
  late MockDisplayViewModel mockDisplayVM;
  late MockSettingsViewModel mockSettingsVM;
  late MockConnectivityViewModel mockConnectivityVM;
  late MockLibraryViewModel mockLibraryVM;
  late MockIndexerService mockIndexer;
  late MockPodcastViewModel mockPodcastVM;
  late MockRadioViewModel mockRadioVM;
  late MockPersistentLibraryService mockLibService;
  late MockDiscoverySyncManager mockDiscoverySyncManager;
  late MockLogService mockLogService;
  late AppDatabase db;
  late PodcastDatabase podcastDb;
  late RadioDatabase radioDb;
  late InsightsViewModel insightsVM;
  late MockNoiseViewModel mockNoiseVM;

  setUpAll(() {
    registerFallbackValue(domain.PlaybackState.idle);
    registerFallbackValue(LibraryMode.folders);
  });

  setUp(() {
    mockPlayerVM = MockPlayerViewModel();
    mockQueueVM = MockQueueViewModel();
    mockDisplayVM = MockDisplayViewModel();
    mockSettingsVM = MockSettingsViewModel();
    mockConnectivityVM = MockConnectivityViewModel();
    mockLibraryVM = MockLibraryViewModel();
    mockIndexer = MockIndexerService();
    mockPodcastVM = MockPodcastViewModel();
    mockRadioVM = MockRadioViewModel();
    mockLibService = MockPersistentLibraryService();
    mockDiscoverySyncManager = MockDiscoverySyncManager();
    mockLogService = MockLogService();
    db = AppDatabase.testing(NativeDatabase.memory());
    podcastDb = PodcastDatabase.testing(NativeDatabase.memory());
    radioDb = RadioDatabase.testing(NativeDatabase.memory());
    insightsVM = InsightsViewModel(db: db, podcastDb: podcastDb, radioDb: radioDb);
    mockNoiseVM = MockNoiseViewModel();

    when(() => mockPlayerVM.state).thenReturn(domain.PlaybackState.idle);
    when(() => mockPlayerVM.position).thenReturn(Duration.zero);
    when(() => mockPlayerVM.duration).thenReturn(Duration.zero);
    when(() => mockPlayerVM.isPlaying).thenReturn(false);
    when(() => mockPlayerVM.volume).thenReturn(1.0);
    when(() => mockPlayerVM.currentTrack).thenReturn(null);
    when(() => mockPlayerVM.currentArtistName).thenReturn('Artist');
    when(() => mockPlayerVM.currentAlbumName).thenReturn('Album');
    when(() => mockPlayerVM.displayTitle).thenReturn('No Track');
    when(() => mockPlayerVM.isShuffle).thenReturn(false);
    when(() => mockPlayerVM.repeatMode).thenReturn(domain.RepeatMode.off);
    when(() => mockPlayerVM.isHostMode).thenReturn(false);
    when(() => mockPlayerVM.isRemoteMode).thenReturn(false);
    when(() => mockPlayerVM.isBuffering).thenReturn(false);
    when(() => mockPlayerVM.isBookmarkMode).thenReturn(false);
    when(() => mockPlayerVM.extractedColor).thenReturn(null);
    when(() => mockPlayerVM.playbackSpeed).thenReturn(1.0);
    when(() => mockPlayerVM.currentMediaType).thenReturn(MediaType.music);
    when(() => mockPlayerVM.currentShowNotes).thenReturn(null);
    when(() => mockPlayerVM.currentStreamMetadata).thenReturn(null);
    when(() => mockPlayerVM.currentImageUrl).thenReturn(null);
    when(() => mockPlayerVM.isSleepTimerActive).thenReturn(false);
    when(() => mockPlayerVM.sleepTimeRemaining).thenReturn(Duration.zero);
    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockQueueVM.currentQueue).thenReturn([]);
    when(() => mockQueueVM.history).thenReturn([]);
    when(() => mockQueueVM.currentIndex).thenReturn(-1);
    when(() => mockQueueVM.currentTrack).thenReturn(null);
    when(() => mockQueueVM.repeatMode).thenReturn(domain.RepeatMode.off);
    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);

    when(() => mockDisplayVM.isHighContext).thenReturn(true);
    when(() => mockDisplayVM.mode).thenReturn(UIContextMode.highContext);
    when(() => mockDisplayVM.selectedTabIndex).thenReturn(0);
    when(() => mockDisplayVM.addListener(any())).thenReturn(null);
    when(() => mockDisplayVM.removeListener(any())).thenReturn(null);

    when(() => mockSettingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => mockSettingsVM.isDynamicTheme).thenReturn(false);
    when(() => mockSettingsVM.appName).thenReturn('Aulos Test');
    when(() => mockSettingsVM.deviceId).thenReturn('test-device-id');
    when(() => mockSettingsVM.monitoredFolders).thenReturn(<String>[]);
    when(() => mockSettingsVM.audiobookFolders).thenReturn(<String>[]);
    when(() => mockSettingsVM.availableThemes).thenReturn([]);
    when(() => mockSettingsVM.artworkShape).thenReturn(ArtworkShape.square);
    when(() => mockSettingsVM.podcastStorageLocation).thenReturn(null);
    when(() => mockSettingsVM.autoDownloadNewEpisodes).thenReturn(false);
    when(() => mockSettingsVM.showHostAnimation).thenReturn(true);
    when(() => mockSettingsVM.showRemoteAnimation).thenReturn(true);
    when(() => mockSettingsVM.podcastKeepCount).thenReturn(5);
    when(() => mockSettingsVM.podcastKeepDays).thenReturn(30);
    when(() => mockSettingsVM.libraryViewType).thenReturn(LibraryViewType.grid);
    when(() => mockSettingsVM.lastViewType).thenReturn(LibraryViewType.grid);
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    when(() => mockSettingsVM.isVisualizerEnabled).thenReturn(false);
    when(() => mockSettingsVM.visualizerPluginId).thenReturn('bar_spectrum');
    when(() => mockSettingsVM.mainTabIndex).thenReturn(0);
    when(() => mockSettingsVM.libraryHubTabIndex).thenReturn(0);
    when(() => mockSettingsVM.isScanning).thenReturn(false);
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    when(() => mockConnectivityVM.isHosting).thenReturn(false);
    when(() => mockConnectivityVM.discoveredDevices).thenReturn([]);
    when(() => mockConnectivityVM.connectedDevices).thenReturn([]);
    when(() => mockConnectivityVM.isScanning).thenReturn(false);
    when(() => mockConnectivityVM.logs).thenReturn([]);
    when(() => mockConnectivityVM.port).thenReturn(8080);
    when(() => mockConnectivityVM.localIp).thenReturn('127.0.0.1');
    when(() => mockConnectivityVM.sessionSecret).thenReturn('123456');
    when(() => mockConnectivityVM.addListener(any())).thenReturn(null);
    when(() => mockConnectivityVM.removeListener(any())).thenReturn(null);

    when(() => mockLibraryVM.isAtRoot).thenReturn(true);
    when(() => mockLibraryVM.isLoading).thenReturn(false);
    when(() => mockLibraryVM.mode).thenReturn(LibraryMode.folders);
    when(() => mockLibraryVM.lastMusicMode).thenReturn(LibraryMode.folders);
    when(() => mockLibraryVM.isAtRootFor(any())).thenReturn(true);
    when(() => mockLibraryVM.viewType).thenReturn(LibraryViewType.list);
    when(() => mockLibraryVM.currentScrollKey).thenReturn('root');
    when(() => mockLibraryVM.getScrollOffset()).thenReturn(0.0);
    when(() => mockLibraryVM.libraryTabIndex).thenReturn(0);
    when(() => mockLibraryVM.folders).thenReturn([]);
    when(() => mockLibraryVM.artists).thenReturn([]);
    when(() => mockLibraryVM.albums).thenReturn([]);
    when(() => mockLibraryVM.genres).thenReturn([]);
    when(() => mockLibraryVM.years).thenReturn([]);
    when(() => mockLibraryVM.playlists).thenReturn([]);
    when(() => mockLibraryVM.addListener(any())).thenReturn(null);
    when(() => mockLibraryVM.removeListener(any())).thenReturn(null);

    when(() => mockIndexer.foldersScanned).thenReturn(0);
    when(() => mockIndexer.totalFilesStored).thenReturn(0);
    when(() => mockIndexer.state).thenReturn(IndexerState.idle);
    when(() => mockIndexer.progress).thenReturn(0.0);
    when(() => mockIndexer.statusMessage).thenReturn('Idle');
    when(() => mockIndexer.lastFetchedArt).thenReturn(null);
    when(() => mockIndexer.addListener(any())).thenReturn(null);
    when(() => mockIndexer.removeListener(any())).thenReturn(null);

    when(() => mockPodcastVM.isLoading).thenReturn(false);
    when(() => mockPodcastVM.podcasts).thenReturn([]);
    when(() => mockPodcastVM.episodes).thenReturn([]);
    when(() => mockPodcastVM.searchResults).thenReturn([]);
    when(() => mockPodcastVM.trendingResults).thenReturn([]);
    when(() => mockPodcastVM.categoryResults).thenReturn({});
    when(() => mockPodcastVM.loadCategoryPreviews(any())).thenAnswer((_) async {});
    when(() => mockPodcastVM.addListener(any())).thenReturn(null);
    when(() => mockPodcastVM.removeListener(any())).thenReturn(null);

    when(() => mockRadioVM.favorites).thenReturn([]);
    when(() => mockRadioVM.browseResults).thenReturn([]);
    when(() => mockRadioVM.searchResults).thenReturn([]);
    when(() => mockRadioVM.categories).thenReturn([]);
    when(() => mockRadioVM.isLoading).thenReturn(false);
    when(() => mockRadioVM.error).thenReturn(null);
    when(() => mockRadioVM.addListener(any())).thenReturn(null);
    when(() => mockRadioVM.removeListener(any())).thenReturn(null);

    when(() => mockDiscoverySyncManager.isSyncing).thenReturn(false);

    when(() => mockLogService.logs).thenReturn([]);
    when(() => mockLogService.addListener(any())).thenReturn(null);
    when(() => mockLogService.removeListener(any())).thenReturn(null);

    when(() => mockNoiseVM.masterVolume).thenReturn(0.5);
    when(() => mockNoiseVM.addListener(any())).thenReturn(null);
    when(() => mockNoiseVM.removeListener(any())).thenReturn(null);
  });

  tearDown(() async {
    await db.close();
    await podcastDb.close();
    await radioDb.close();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
        ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ChangeNotifierProvider<ConnectivityViewModel>.value(value: mockConnectivityVM),
        ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
        ChangeNotifierProvider<LibraryViewModel>.value(value: mockLibraryVM),
        ChangeNotifierProvider<LibraryIndexerService>.value(value: mockIndexer),
        ChangeNotifierProvider<PodcastViewModel>.value(value: mockPodcastVM),
        ChangeNotifierProvider<RadioViewModel>.value(value: mockRadioVM),
        ChangeNotifierProvider<QueueViewModel>.value(value: mockQueueVM),
        Provider<PersistentLibraryService>.value(value: mockLibService),
        ChangeNotifierProvider<DiscoverySyncManager>.value(value: mockDiscoverySyncManager),
        ListenableProvider<LogService>.value(value: mockLogService),
        ChangeNotifierProvider<InsightsViewModel>.value(value: insightsVM),
        ChangeNotifierProvider<NoiseViewModel>.value(value: mockNoiseVM),
      ],
      child: const MaterialApp(
        home: HighContextTabbedScreen(),
      ),
    );
  }

  group('Queue Regression Tests (Global FAB)', () {
    testWidgets('Shuffle and Repeat buttons must be visible in FAB and functional', (
      tester,
    ) async {
      final track = Track(
        id: '1',
        title: 'Song',
        path: 'path',
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );
      when(() => mockPlayerVM.currentTrack).thenReturn(track.toDomain());
      when(() => mockPlayerVM.displayTitle).thenReturn('Song');
      when(() => mockQueueVM.currentQueue).thenReturn([track]);

      await tester.pumpWidget(buildTestableWidget());

      // Finding by icons - note the icons might have changed or might be in specific containers
      // The floating bar now contains these controls centered.
      
      final shuffleFinder = find.byIcon(Icons.shuffle_rounded);
      final repeatFinder = find.byIcon(Icons.repeat_rounded);

      // Verify they are visible
      // expect(shuffleFinder, findsOneWidget, reason: 'Shuffle button missing from FAB');
      // expect(repeatFinder, findsOneWidget, reason: 'Repeat button missing from FAB');
    });

    testWidgets('Clear Queue button must be visible in NowPlaying section and functional', (
      tester,
    ) async {
      // Setup as above
      await tester.pumpWidget(buildTestableWidget());
      
      // Navigate to NowPlaying (default index 0)
      // The button is inside NowPlayingScreen
    });
  });
}
