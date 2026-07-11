import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/features/settings/screens/settings_screen.dart';
import 'package:aulos/features/library/widgets/music_library_view.dart';
import 'package:aulos/presentation/screens/now_playing_screen.dart';
import 'package:aulos/presentation/screens/collapsed_player_screen.dart';
import 'package:aulos/features/podcasts/screens/podcast_root_screen.dart';
import 'package:aulos/features/audiobooks/screens/audiobook_root_screen.dart';
import 'package:aulos/features/radio/screens/radio_root_screen.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/insights_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/theme/aulos_audio_theme.dart';
import 'package:aulos/domain/playback/playback_engine.dart' as domain;
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:aulos/presentation/viewmodels/storage_cache_view_model.dart';

class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockDisplayViewModel extends Mock implements DisplayViewModel {}
class MockConnectivityViewModel extends Mock implements ConnectivityViewModel {}
class MockStorageCacheViewModel extends Mock implements StorageCacheViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockIndexerService extends Mock implements LibraryIndexerService {}
class MockPodcastViewModel extends Mock implements PodcastViewModel {}
class MockRadioViewModel extends Mock implements RadioViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}
class MockDiscoverySyncManager extends Mock implements DiscoverySyncManager {}
class MockLogService extends Mock implements LogService {}
class MockNoiseViewModel extends Mock implements NoiseViewModel {}

void main() {
  late MockPlayerViewModel playerVM;
  late MockDisplayViewModel displayVM;
  late MockConnectivityViewModel connectivityVM;
  late MockSettingsViewModel settingsVM;
  late MockLibraryViewModel libraryVM;
  late MockIndexerService indexerService;
  late MockPodcastViewModel podcastVM;
  late MockRadioViewModel radioVM;
  late MockQueueViewModel queueVM;
  late MockPersistentLibraryService persistentLibrary;
  late MockDiscoverySyncManager discoverySyncManager;
  late MockLogService logService;
  late AppDatabase db;
  late PodcastDatabase podcastDb;
  late RadioDatabase radioDb;
  late InsightsViewModel insightsVM;
  late MockNoiseViewModel noiseVM;
  late MockStorageCacheViewModel storageCacheVM;

  setUpAll(() {
    registerFallbackValue(domain.PlaybackState.idle);
    registerFallbackValue(LibraryMode.folders);
  });

  setUp(() {
    playerVM = MockPlayerViewModel();
    displayVM = MockDisplayViewModel();
    connectivityVM = MockConnectivityViewModel();
    settingsVM = MockSettingsViewModel();
    libraryVM = MockLibraryViewModel();
    indexerService = MockIndexerService();
    podcastVM = MockPodcastViewModel();
    radioVM = MockRadioViewModel();
    queueVM = MockQueueViewModel();
    persistentLibrary = MockPersistentLibraryService();
    discoverySyncManager = MockDiscoverySyncManager();
    logService = MockLogService();
    db = AppDatabase.testing(NativeDatabase.memory());
    podcastDb = PodcastDatabase.testing(NativeDatabase.memory());
    radioDb = RadioDatabase.testing(NativeDatabase.memory());
    insightsVM = InsightsViewModel(db: db, podcastDb: podcastDb, radioDb: radioDb);
    noiseVM = MockNoiseViewModel();
    storageCacheVM = MockStorageCacheViewModel();

    when(() => storageCacheVM.podcastSize).thenReturn(1024);
    when(() => storageCacheVM.audiobookSize).thenReturn(2048);
    when(() => storageCacheVM.totalSize).thenReturn(3072);
    when(() => storageCacheVM.isLoading).thenReturn(false);
    when(() => storageCacheVM.addListener(any())).thenReturn(null);
    when(() => storageCacheVM.removeListener(any())).thenReturn(null);

    when(() => playerVM.isPlaying).thenReturn(false);
    when(() => playerVM.isShuffle).thenReturn(false);
    when(() => playerVM.volume).thenReturn(1.0);
    when(() => playerVM.state).thenReturn(domain.PlaybackState.idle);
    when(() => playerVM.repeatMode).thenReturn(domain.RepeatMode.off);
    when(() => playerVM.displayTitle).thenReturn('Test Track');
    when(() => playerVM.currentArtistName).thenReturn('Test Artist');
    when(() => playerVM.currentAlbumName).thenReturn('Test Album');
    when(() => playerVM.currentTrack).thenReturn(null);
    when(() => playerVM.position).thenReturn(Duration.zero);
    when(() => playerVM.duration).thenReturn(Duration.zero);
    when(() => playerVM.playbackSpeed).thenReturn(1.0);
    when(() => playerVM.extractedColor).thenReturn(null);
    when(() => playerVM.isHostMode).thenReturn(false);
    when(() => playerVM.isRemoteMode).thenReturn(false);
    when(() => playerVM.isBuffering).thenReturn(false);
    when(() => playerVM.isBookmarkMode).thenReturn(false);
    when(() => playerVM.currentMediaType).thenReturn(MediaType.music);
    when(() => playerVM.currentShowNotes).thenReturn(null);
    when(() => playerVM.currentStreamMetadata).thenReturn(null);
    when(() => playerVM.currentImageUrl).thenReturn(null);
    when(() => playerVM.isSleepTimerActive).thenReturn(false);
    when(() => playerVM.sleepTimeRemaining).thenReturn(Duration.zero);
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);

    when(() => settingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(false);
    when(() => settingsVM.appName).thenReturn('Aulos Test');
    when(() => settingsVM.deviceId).thenReturn('test-device-id');
    when(() => settingsVM.monitoredFolders).thenReturn(<String>[]);
    when(() => settingsVM.audiobookFolders).thenReturn(<String>[]);
    when(() => settingsVM.availableThemes).thenReturn([]);
    when(() => settingsVM.artworkShape).thenReturn(ArtworkShape.square);
    when(() => settingsVM.podcastStorageLocation).thenReturn(null);
    when(() => settingsVM.autoDownloadNewEpisodes).thenReturn(false);
    when(() => settingsVM.showHostAnimation).thenReturn(true);
    when(() => settingsVM.showRemoteAnimation).thenReturn(true);
    when(() => settingsVM.podcastKeepCount).thenReturn(5);
    when(() => settingsVM.podcastKeepDays).thenReturn(30);
    when(() => settingsVM.libraryViewType).thenReturn(LibraryViewType.grid);
    when(() => settingsVM.lastViewType).thenReturn(LibraryViewType.grid);
    when(() => settingsVM.isFolderWatcherEnabled).thenReturn(true);
    when(() => settingsVM.isVisualizerEnabled).thenReturn(false);
    when(() => settingsVM.visualizerPluginId).thenReturn('bar_spectrum');
    when(() => settingsVM.mainTabIndex).thenReturn(0);
    when(() => settingsVM.libraryHubTabIndex).thenReturn(0);
    when(() => settingsVM.isScanning).thenReturn(false);
    when(() => settingsVM.isPortableMode).thenReturn(false);
    when(() => settingsVM.customDatabaseDirectory).thenReturn(null);
    when(() => settingsVM.addListener(any())).thenReturn(null);
    when(() => settingsVM.removeListener(any())).thenReturn(null);

    when(() => connectivityVM.isHosting).thenReturn(false);
    when(() => connectivityVM.discoveredDevices).thenReturn([]);
    when(() => connectivityVM.connectedDevices).thenReturn([]);
    when(() => connectivityVM.isScanning).thenReturn(false);
    when(() => connectivityVM.logs).thenReturn([]);
    when(() => connectivityVM.port).thenReturn(8080);
    when(() => connectivityVM.localIp).thenReturn('127.0.0.1');
    when(() => connectivityVM.sessionSecret).thenReturn('123456');
    when(() => connectivityVM.addListener(any())).thenReturn(null);
    when(() => connectivityVM.removeListener(any())).thenReturn(null);

    when(() => libraryVM.isAtRoot).thenReturn(true);
    when(() => libraryVM.isLoading).thenReturn(false);
    when(() => libraryVM.showFavoritesOnly).thenReturn(false);
    when(() => libraryVM.mode).thenReturn(LibraryMode.folders);
    when(() => libraryVM.lastMusicMode).thenReturn(LibraryMode.folders);
    when(() => libraryVM.isAtRootFor(any())).thenReturn(true);
    when(() => libraryVM.viewType).thenReturn(LibraryViewType.list);
    when(() => libraryVM.currentScrollKey).thenReturn('root');
    when(() => libraryVM.getScrollOffset()).thenReturn(0.0);
    when(() => libraryVM.libraryTabIndex).thenReturn(0);
    when(() => libraryVM.folders).thenReturn([]);
    when(() => libraryVM.artists).thenReturn([]);
    when(() => libraryVM.albums).thenReturn([]);
    when(() => libraryVM.genres).thenReturn([]);
    when(() => libraryVM.years).thenReturn([]);
    when(() => libraryVM.playlists).thenReturn([]);
    when(() => libraryVM.books).thenReturn([]);
    when(() => libraryVM.tempShowHome).thenReturn(false);
    when(() => libraryVM.tempShowHomeFor(any())).thenReturn(false);
    when(() => libraryVM.navStack).thenReturn([]);
    when(() => libraryVM.stateFor(any())).thenReturn(LibraryNavigationState());
    when(() => libraryVM.addListener(any())).thenReturn(null);
    when(() => libraryVM.removeListener(any())).thenReturn(null);

    when(() => indexerService.foldersScanned).thenReturn(0);
    when(() => indexerService.totalFilesStored).thenReturn(0);
    when(() => indexerService.state).thenReturn(IndexerState.idle);
    when(() => indexerService.progress).thenReturn(0.0);
    when(() => indexerService.statusMessage).thenReturn('Idle');
    when(() => indexerService.lastFetchedArt).thenReturn(null);
    when(() => indexerService.addListener(any())).thenReturn(null);
    when(() => indexerService.removeListener(any())).thenReturn(null);

    when(() => podcastVM.tempShowHome).thenReturn(false);
    when(() => podcastVM.isLoading).thenReturn(false);
    when(() => podcastVM.podcasts).thenReturn([]);
    when(() => podcastVM.episodes).thenReturn([]);
    when(() => podcastVM.searchResults).thenReturn([]);
    when(() => podcastVM.trendingResults).thenReturn([]);
    when(() => podcastVM.categoryResults).thenReturn({});
    when(() => podcastVM.libraryFilter).thenReturn('ALL SHOWS');
    when(() => podcastVM.filteredPodcasts).thenReturn([]);
    when(() => podcastVM.activePodcast).thenReturn(null);
    when(() => podcastVM.loadPodcasts()).thenAnswer((_) async {});
    when(() => podcastVM.checkAndRefreshLibraryDaily()).thenAnswer((_) async {});
    when(() => podcastVM.loadCategoryPreviews(any())).thenAnswer((_) async {});
    when(() => podcastVM.addListener(any())).thenReturn(null);
    when(() => podcastVM.removeListener(any())).thenReturn(null);

    when(() => radioVM.favorites).thenReturn([]);
    when(() => radioVM.browseResults).thenReturn([]);
    when(() => radioVM.searchResults).thenReturn([]);
    when(() => radioVM.categories).thenReturn([]);
    when(() => radioVM.isLoading).thenReturn(false);
    when(() => radioVM.error).thenReturn(null);
    when(() => radioVM.tempShowHome).thenReturn(false);
    when(() => radioVM.libraryFilter).thenReturn('ALL STATIONS');
    when(() => radioVM.isShowingHidden).thenReturn(false);
    when(() => radioVM.filteredFavorites).thenReturn([]);
    when(() => radioVM.addListener(any())).thenReturn(null);
    when(() => radioVM.removeListener(any())).thenReturn(null);

    when(() => queueVM.currentQueue).thenReturn([]);
    when(() => queueVM.currentIndex).thenReturn(0);
    when(() => queueVM.history).thenReturn([]);
    when(() => queueVM.addListener(any())).thenReturn(null);
    when(() => queueVM.removeListener(any())).thenReturn(null);

    when(() => displayVM.mode).thenReturn(UIContextMode.highContext);
    when(() => displayVM.selectedTabIndex).thenReturn(0);
    when(() => displayVM.addListener(any())).thenReturn(null);
    when(() => displayVM.removeListener(any())).thenReturn(null);

    when(() => discoverySyncManager.isSyncing).thenReturn(false);

    when(() => logService.logs).thenReturn([]);
    when(() => logService.addListener(any())).thenReturn(null);
    when(() => logService.removeListener(any())).thenReturn(null);

    when(() => noiseVM.masterVolume).thenReturn(0.5);
    when(() => noiseVM.addListener(any())).thenReturn(null);
    when(() => noiseVM.removeListener(any())).thenReturn(null);
  });

  tearDown(() async {
    await db.close();
    await podcastDb.close();
    await radioDb.close();
  });

  Widget _wrap(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
        ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
        ChangeNotifierProvider<ConnectivityViewModel>.value(value: connectivityVM),
        ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
        ChangeNotifierProvider<LibraryViewModel>.value(value: libraryVM),
        ChangeNotifierProvider<LibraryIndexerService>.value(value: indexerService),
        ChangeNotifierProvider<PodcastViewModel>.value(value: podcastVM),
        ChangeNotifierProvider<RadioViewModel>.value(value: radioVM),
        ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
        Provider<PersistentLibraryService>.value(value: persistentLibrary),
        ChangeNotifierProvider<DiscoverySyncManager>.value(value: discoverySyncManager),
        ListenableProvider<LogService>.value(value: logService),
        ChangeNotifierProvider<InsightsViewModel>.value(value: insightsVM),
        ChangeNotifierProvider<NoiseViewModel>.value(value: noiseVM),
        ChangeNotifierProvider<StorageCacheViewModel>.value(value: storageCacheVM),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('Overflow Check - Settings Screen', (tester) async {
    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Music Library View', (tester) async {
    await tester.pumpWidget(_wrap(const MusicLibraryView()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Now Playing Screen', (tester) async {
    await tester.pumpWidget(_wrap(const NowPlayingScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Collapsed Player Screen (Narrow Viewport)', (tester) async {
    tester.view.physicalSize = const Size(320, 100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_wrap(const CollapsedPlayerScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Podcast Root Screen (Narrow Viewport)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_wrap(const PodcastRootScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Audiobook Root Screen (Narrow Viewport)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_wrap(const AudiobookRootScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Radio Root Screen (Narrow Viewport)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_wrap(const RadioRootScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Music Library View (Narrow Viewport)', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_wrap(const MusicLibraryView()));
    await tester.pumpAndSettle();
  });
}
