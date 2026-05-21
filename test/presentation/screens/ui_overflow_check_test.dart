import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localaudioplayer/features/main/screens/high_context_tabbed_screen.dart';
import 'package:localaudioplayer/features/settings/screens/settings_screen.dart';
import 'package:localaudioplayer/features/library/screens/library_hub_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/data/library/library_indexer_service.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/data/library/discovery_sync_manager.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/radio_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/theme/obsidian_audio_theme.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as domain;
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockDisplayViewModel extends Mock implements DisplayViewModel {}
class MockConnectivityViewModel extends Mock implements ConnectivityViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockIndexerService extends Mock implements LibraryIndexerService {}
class MockPodcastViewModel extends Mock implements PodcastViewModel {}
class MockRadioViewModel extends Mock implements RadioViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}
class MockDiscoverySyncManager extends Mock implements DiscoverySyncManager {}
class MockMediaLogService extends Mock implements MediaLogService {}

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
  late MockMediaLogService logService;

  setUpAll(() {
    registerFallbackValue(domain.PlaybackState.idle);
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
    logService = MockMediaLogService();

    when(() => playerVM.isPlaying).thenReturn(false);
    when(() => playerVM.isShuffle).thenReturn(false);
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
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);

    when(() => settingsVM.themeModel).thenReturn(ObsidianAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(false);
    when(() => settingsVM.appName).thenReturn('Aulos Test');
    when(() => settingsVM.deviceId).thenReturn('test-device-id');
    when(() => settingsVM.monitoredFolders).thenReturn([]);
    when(() => settingsVM.availableThemes).thenReturn([]);
    when(() => settingsVM.artworkShape).thenReturn(ArtworkShape.square);
    when(() => settingsVM.podcastStorageLocation).thenReturn(null);
    when(() => settingsVM.autoDownloadNewEpisodes).thenReturn(false);
    when(() => settingsVM.showHostAnimation).thenReturn(true);
    when(() => settingsVM.showRemoteAnimation).thenReturn(true);
    when(() => settingsVM.podcastKeepCount).thenReturn(5);
    when(() => settingsVM.podcastKeepDays).thenReturn(30);
    when(() => settingsVM.libraryViewType).thenReturn(LibraryViewType.grid);
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
    when(() => libraryVM.mode).thenReturn(LibraryMode.folders);
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

    when(() => podcastVM.isLoading).thenReturn(false);
    when(() => podcastVM.podcasts).thenReturn([]);
    when(() => podcastVM.searchResults).thenReturn([]);
    when(() => podcastVM.trendingResults).thenReturn([]);
    when(() => podcastVM.categoryResults).thenReturn({});
    when(() => podcastVM.loadCategoryPreviews(any())).thenAnswer((_) async {});
    when(() => podcastVM.addListener(any())).thenReturn(null);
    when(() => podcastVM.removeListener(any())).thenReturn(null);

    when(() => radioVM.favorites).thenReturn([]);
    when(() => radioVM.addListener(any())).thenReturn(null);
    when(() => radioVM.removeListener(any())).thenReturn(null);

    when(() => queueVM.currentQueue).thenReturn([]);
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
  });

  Widget buildTestWidget({Size size = const Size(1280, 720)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
          ChangeNotifierProvider<ConnectivityViewModel>.value(value: connectivityVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
          ChangeNotifierProvider<LibraryViewModel>.value(value: libraryVM),
          ChangeNotifierProvider<LibraryIndexerService>.value(value: indexerService),
          ChangeNotifierProvider<PodcastViewModel>.value(value: podcastVM),
          ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
          Provider<PersistentLibraryService>.value(value: persistentLibrary),
          ChangeNotifierProvider<DiscoverySyncManager>.value(value: discoverySyncManager),
          ChangeNotifierProvider<MediaLogService>.value(value: logService),
        ],
        child: const MaterialApp(
          home: HighContextTabbedScreen(),
        ),
      ),
    );
  }

  testWidgets('Overflow Check - Settings Screen', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
          ChangeNotifierProvider<ConnectivityViewModel>.value(value: connectivityVM),
          ChangeNotifierProvider<LibraryIndexerService>.value(value: indexerService),
          ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
          Provider<PersistentLibraryService>.value(value: persistentLibrary),
          ChangeNotifierProvider<DiscoverySyncManager>.value(value: discoverySyncManager),
          ChangeNotifierProvider<MediaLogService>.value(value: logService),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Overflow Check - Library Hub Screen', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LibraryViewModel>.value(value: libraryVM),
          ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
          ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
          ChangeNotifierProvider<PodcastViewModel>.value(value: podcastVM),
          ChangeNotifierProvider<RadioViewModel>.value(value: radioVM),
          ChangeNotifierProvider<DiscoverySyncManager>.value(value: discoverySyncManager),
          ChangeNotifierProvider<MediaLogService>.value(value: logService),
        ],
        child: const MaterialApp(home: Scaffold(body: LibraryHubScreen())),
      ),
    );
    await tester.pump();
  });
}
