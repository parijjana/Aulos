import 'package:flutter/material.dart' hide RepeatMode;
import 'package:aulos/data/playback/just_audio_playback_engine.dart';
import 'package:aulos/data/playback/audio_service_handler.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/data/library/local_library_service.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/playlist_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/insights_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/data/library/playlist_service.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/artwork_service.dart';
import 'package:aulos/data/library/ensemble_artwork_service.dart';
import 'package:aulos/data/library/rss_podcast_service.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/data/library/podcast_download_service.dart';
import 'package:aulos/data/library/discovery_sync_manager.dart';
import 'package:aulos/data/library/podcast_storage_manager.dart';
import 'package:aulos/data/library/radio_browser_service.dart';
import 'package:aulos/data/library/radio_sync_manager.dart';
import 'package:aulos/data/playback/ambient_mixer_service.dart';
import 'package:aulos/domain/library/podcast_service.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/features/main/screens/high_context_tabbed_screen.dart';
import 'package:aulos/presentation/screens/collapsed_player_screen.dart';
import 'package:aulos/presentation/screens/main_pager_screen.dart';
import 'package:aulos/presentation/viewmodels/mood_view_model.dart';
import 'package:aulos/core/storage/storage_directory_manager.dart';
import 'package:file/local.dart';
import 'package:themer_flutter/themer_flutter.dart';
import 'package:provider/provider.dart';
import 'package:aulos/data/database/app_database.dart' as app_db;
import 'package:aulos/data/database/podcast_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/data/database/noise_database.dart';
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/data/database/discovery_database.dart';
import 'package:aulos/data/database/migration_worker.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/core/network/rate_limit_dispatcher.dart';
import 'package:aulos/data/library/providers/audnexus_service.dart';
import 'package:aulos/data/library/providers/wikipedia_service.dart';
import 'package:aulos/data/library/librivox_service.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/data/library/jamendo_service.dart';
import 'package:aulos/presentation/viewmodels/jamendo_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:aulos/data/library/librivox_book_downloader.dart';
import 'package:aulos/data/library/jamendo_track_downloader.dart';
import 'package:aulos/data/library/storage_manager_service.dart';
import 'package:aulos/presentation/viewmodels/storage_cache_view_model.dart';


import 'package:aulos/data/network/nsd_discovery_service.dart';
import 'package:aulos/data/network/websocket_service.dart';
import 'package:aulos/data/network/persistent_log_service.dart';
import 'package:aulos/data/core/permission_service_impl.dart';
import 'package:aulos/data/network/cryptographic_handshake_service.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/domain/network/log_service.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:window_manager/window_manager.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<AulosAudioHandler> _initAudioService(LogService logService) async {
  return await AudioService.init(
    builder: () => AulosAudioHandler(logService: logService),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.example.aulos.channel.audio',
      androidNotificationChannelName: 'Aulos Audio Playback',
      androidNotificationOngoing: true,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await [
      Permission.storage,
      Permission.audio,
      Permission.mediaLibrary,
    ].request();
  }

  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    final WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(400, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    unawaited(
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      }),
    );
  }

  final prefs = await SharedPreferences.getInstance();
  final docsDir = await getApplicationDocumentsDirectory();
  final logFile = File(p.join(docsDir.path, 'aulos.log'));
  final logService = PersistentLogService(logFile: logFile);

  final audioHandler = await _initAudioService(logService);
  final playbackEngine = JustAudioPlaybackEngine(handler: audioHandler, logService: logService);

  final directoryManager = StorageDirectoryManager(prefs);
  final dbDir = await directoryManager.getDatabaseDirectory();
  final dbPath = dbDir.path;

  final database = app_db.AppDatabase(dbPath);
  final podcastDb = PodcastDatabase(dbPath);
  final audiobookDb = AudiobookDatabase(dbPath);
  final playbackDb = PlaybackDatabase(dbPath);
  final noiseDb = NoiseDatabase(dbPath);
  final radioDb = RadioDatabase(dbPath);
  final discoveryDb = DiscoveryDatabase(dbPath);

  final migrationCompleted = prefs.getBool('database_migration_completed') ?? false;
  if (!migrationCompleted) {
    final migrationWorker = DatabaseMigrationWorker(
      podcastDb: podcastDb,
      audiobookDb: audiobookDb,
      playbackDb: playbackDb,
      noiseDb: noiseDb,
      radioDb: radioDb,
    );
    await migrationWorker.migrateIfNeeded();
    await prefs.setBool('database_migration_completed', true);
  }

  final settingsViewModel = SettingsViewModel(prefs);
  final displayViewModel = DisplayViewModel(settingsVM: settingsViewModel);
  
  final scannerService = LocalLibraryService(
    fileSystem: const LocalFileSystem(),
    tagsWrapper: AudioTagsWrapperImpl(),
    audioQuery: OnAudioQuery(),
    permissions: PermissionServiceImpl(),
  );

  final persistentLibrary = PersistentLibraryServiceImpl(
    db: database,
    audiobookDb: audiobookDb,
    scanner: scannerService,
  );

  final playlistService = PlaylistServiceImpl();
  final rateLimitDispatcher = RateLimitDispatcher();
  final artworkService = ArtworkService(logService: logService, rateLimitDispatcher: rateLimitDispatcher);
  final ensembleService = EnsembleArtworkService(
    artworkService: artworkService,
  );
  
  final podcastService = RssPodcastService(db: podcastDb, playbackDb: playbackDb);
  final discoveryService = PodcastDiscoveryService(logService: logService, rateLimiter: rateLimitDispatcher, prefs: prefs);
  final downloadService = PodcastDownloadService(db: podcastDb, logService: logService);
  final syncManager = DiscoverySyncManager(api: discoveryService, db: podcastDb, logService: logService);
  final storageManager = PodcastStorageManager(db: podcastDb, settingsVM: settingsViewModel);

  final radioService = RadioBrowserService(logService: logService, rateLimiter: rateLimitDispatcher);
  final radioSyncManager = RadioSyncManager(api: radioService, db: radioDb, logService: logService);

  final ambientMixerService = AmbientMixerService();
  final audnexusService = AudnexusService(logService: logService, rateLimiter: rateLimitDispatcher);
  final librivoxService = LibriVoxService(logService: logService, rateLimiter: rateLimitDispatcher);
  final jamendoService = JamendoService(logService: logService, rateLimiter: rateLimitDispatcher);
  final wikipediaService = WikipediaService(logService: logService, rateLimiter: rateLimitDispatcher, db: discoveryDb);

  final libraryIndexerService = LibraryIndexerService(
    db: database,
    prefs: prefs,
    artworkService: artworkService,
    ensembleService: ensembleService,
    settingsVM: settingsViewModel,
    libService: persistentLibrary,
    logService: logService,
  );

  final nsdDiscoveryService = NsdDiscoveryService();
  final handshakeService = CryptographicHandshakeService(prefs);
  final socketService = WebSocketService();

  final connectionManager = ConnectionManager(
    discovery: nsdDiscoveryService,
    handshake: handshakeService,
    socket: socketService,
    prefs: prefs,
    logService: logService,
  );

  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky));
  unawaited(storageManager.pruneDownloads());

  final libraryViewModel = LibraryViewModel(
    libraryService: persistentLibrary,
    playbackDb: playbackDb,
    audnexus: audnexusService,
    connectionManager: connectionManager,
    settingsVM: settingsViewModel,
    logService: logService,
    indexerService: libraryIndexerService,
  );

  final queueViewModel = QueueViewModel(
    libraryService: persistentLibrary,
    connectionManager: connectionManager,
  );
  final playerViewModel = PlayerViewModel(
    engine: playbackEngine,
    queueVM: queueViewModel,
    connectionManager: connectionManager,
    db: database,
    radioDb: radioDb,
    playbackDb: playbackDb,
    audiobookDb: audiobookDb,
    podcastDb: podcastDb,
    settingsVM: settingsViewModel,
    logService: logService,
  );
  final playlistViewModel = PlaylistViewModel(
    libraryService: persistentLibrary,
    playlistService: playlistService,
  );
  final connectivityViewModel = ConnectivityViewModel(
    connectionManager: connectionManager,
    discoveryService: nsdDiscoveryService,
    handshakeService: handshakeService,
    logService: logService,
  );
  final podcastViewModel = PodcastViewModel(
    podcastService: podcastService,
    discoveryService: discoveryService,
    downloadService: downloadService,
    syncManager: syncManager,
    discoveryDb: podcastDb,
    settingsVM: settingsViewModel,
    logService: logService,
  );
  final radioViewModel = RadioViewModel(
    api: radioService,
    db: radioDb,
    syncManager: radioSyncManager,
    logService: logService,
  );
  final noiseViewModel = NoiseViewModel(
    mixerService: ambientMixerService,
    db: noiseDb,
  );
  playerViewModel.setNoiseViewModel(noiseViewModel);
  final insightsViewModel = InsightsViewModel(
    db: database,
    podcastDb: podcastDb,
    radioDb: radioDb,
  );
  final librivoxViewModel = LibriVoxViewModel(
    service: librivoxService,
    downloader: LibriVoxBookDownloader(
      db: audiobookDb,
      client: http.Client(),
      logService: logService,
    ),
    logService: logService,
  );
  final jamendoViewModel = JamendoViewModel(
    service: jamendoService,
    downloader: JamendoTrackDownloader(
      db: database,
      client: http.Client(),
      logService: logService,
    ),

    logService: logService,
  );

  final moodViewModel = MoodViewModel(
    settingsVM: settingsViewModel,
    appDb: database,
    podcastDb: podcastDb,
    audiobookDb: audiobookDb,
    noiseDb: noiseDb,
    radioDb: radioDb,
  );

  final storageManagerService = StorageManagerService(
    settingsVM: settingsViewModel,
    audiobookDb: audiobookDb,
  );
  final storageCacheViewModel = StorageCacheViewModel(storageManagerService);

  runApp(
    MultiProvider(
      providers: [
        Provider<app_db.AppDatabase>.value(value: database),
        ListenableProvider<LogService>.value(value: logService),
        Provider<RateLimitDispatcher>.value(value: rateLimitDispatcher),
        Provider<PodcastDatabase>.value(value: podcastDb),
        Provider<AudiobookDatabase>.value(value: audiobookDb),
        Provider<PlaybackDatabase>.value(value: playbackDb),
        Provider<NoiseDatabase>.value(value: noiseDb),
        Provider<RadioDatabase>.value(value: radioDb),
        Provider<DiscoveryDatabase>.value(value: discoveryDb),
        ChangeNotifierProvider<DiscoverySyncManager>.value(value: syncManager),
        Provider<PodcastStorageManager>.value(value: storageManager),
        Provider<PersistentLibraryService>.value(value: persistentLibrary),
        Provider<EnsembleArtworkService>.value(value: ensembleService),
        Provider<PodcastService>.value(value: podcastService),
        Provider<AmbientMixerService>.value(value: ambientMixerService),
        Provider<AudnexusService>.value(value: audnexusService),
        Provider<WikipediaService>.value(value: wikipediaService),
        ChangeNotifierProvider.value(value: playerViewModel),
        ChangeNotifierProvider.value(value: libraryViewModel),
        ChangeNotifierProvider.value(value: queueViewModel),
        ChangeNotifierProvider.value(value: playlistViewModel),
        ChangeNotifierProvider.value(value: displayViewModel),
        ChangeNotifierProvider.value(value: settingsViewModel),
        ChangeNotifierProvider.value(value: connectivityViewModel),
        ChangeNotifierProvider.value(value: libraryIndexerService),
        ChangeNotifierProvider.value(value: podcastViewModel),
        ChangeNotifierProvider.value(value: radioViewModel),
        ChangeNotifierProvider.value(value: noiseViewModel),
        ChangeNotifierProvider.value(value: insightsViewModel),
        ChangeNotifierProvider.value(value: librivoxViewModel),
        ChangeNotifierProvider.value(value: jamendoViewModel),
        ChangeNotifierProvider.value(value: moodViewModel),
        Provider<StorageManagerService>.value(value: storageManagerService),
        ChangeNotifierProvider<StorageCacheViewModel>.value(value: storageCacheViewModel),
      ],
      child: const AulosApp(),
    ),
  );
}

class AulosApp extends StatefulWidget {
  const AulosApp({super.key});

  @override
  State<AulosApp> createState() => _AulosAppState();
}

class _AulosAppState extends State<AulosApp> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (!mounted) return false;

    final playerVM = context.read<PlayerViewModel>();
    final logicalKey = event.logicalKey;

    if (logicalKey == LogicalKeyboardKey.mediaPlayPause) {
      playerVM.togglePlay();
      return true;
    } else if (logicalKey == LogicalKeyboardKey.mediaPlay) {
      playerVM.play();
      return true;
    } else if (logicalKey == LogicalKeyboardKey.mediaPause) {
      playerVM.pause();
      return true;
    } else if (logicalKey == LogicalKeyboardKey.mediaTrackNext) {
      playerVM.skipNext();
      return true;
    } else if (logicalKey == LogicalKeyboardKey.mediaTrackPrevious) {
      playerVM.skipPrevious();
      return true;
    } else if (logicalKey == LogicalKeyboardKey.mediaStop) {
      playerVM.stop();
      return true;
    }

    if (logicalKey == LogicalKeyboardKey.space) {
      final primaryFocus = FocusManager.instance.primaryFocus;
      final isTextFieldFocused = primaryFocus != null &&
          (primaryFocus.context?.widget is EditableText ||
           primaryFocus.context?.findAncestorWidgetOfExactType<EditableText>() != null);
      
      if (!isTextFieldFocused) {
        playerVM.togglePlay();
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final displayVM = context.watch<DisplayViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    
    final themeData = ThemerCompiler.compile(settingsVM.themeModel);

    Widget home;
    switch (displayVM.mode) {
      case UIContextMode.collapsed:
        home = const CollapsedPlayerScreen();
        break;
      case UIContextMode.highContext:
        home = const HighContextTabbedScreen();
        break;
      case UIContextMode.minimalist:
        home = const MainPagerScreen();
        break;
    }

    return MaterialApp(
      title: 'Aulos',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      home: home,
    );
  }
}
