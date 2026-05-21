import 'package:flutter/material.dart' hide RepeatMode;
import 'package:localaudioplayer/data/playback/just_audio_playback_engine.dart';
import 'package:localaudioplayer/data/playback/audio_service_handler.dart';
import 'package:localaudioplayer/presentation/screens/now_playing_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/data/library/local_library_service.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/playlist_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/radio_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/insights_view_model.dart';
import 'package:localaudioplayer/data/library/playlist_service.dart';
import 'package:localaudioplayer/data/library/library_indexer_service.dart';
import 'package:localaudioplayer/data/library/artwork_service.dart';
import 'package:localaudioplayer/data/library/ensemble_artwork_service.dart';
import 'package:localaudioplayer/data/library/rss_podcast_service.dart';
import 'package:localaudioplayer/data/library/podcast_discovery_service.dart';
import 'package:localaudioplayer/data/library/podcast_download_service.dart';
import 'package:localaudioplayer/data/library/discovery_sync_manager.dart';
import 'package:localaudioplayer/data/library/podcast_storage_manager.dart';
import 'package:localaudioplayer/data/library/radio_browser_service.dart';
import 'package:localaudioplayer/data/library/radio_sync_manager.dart';
import 'package:localaudioplayer/domain/library/podcast_service.dart';
import 'package:localaudioplayer/presentation/viewmodels/podcast_view_model.dart';
import 'package:localaudioplayer/features/main/screens/high_context_tabbed_screen.dart';
import 'package:localaudioplayer/presentation/screens/collapsed_player_screen.dart';
import 'package:file/local.dart';
import 'package:themer_flutter/themer_flutter.dart';
import 'package:provider/provider.dart';
import 'package:localaudioplayer/data/database/app_database.dart' as app_db;
import 'package:localaudioplayer/data/database/discovery_database.dart';
import 'package:localaudioplayer/data/database/radio_database.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/core/network/rate_limit_dispatcher.dart';

import 'package:localaudioplayer/data/network/nsd_discovery_service.dart';
import 'package:localaudioplayer/data/network/websocket_service.dart';
import 'package:localaudioplayer/domain/network/connection_manager.dart';
import 'package:localaudioplayer/domain/network/handshake_service.dart';
import 'package:localaudioplayer/presentation/viewmodels/connectivity_view_model.dart';
import 'package:localaudioplayer/domain/network/log_service.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:localaudioplayer/domain/core/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:window_manager/window_manager.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:audio_service/audio_service.dart';

Future<ObsidianAudioHandler> _initAudioService() async {
  return await AudioService.init(
    builder: () => ObsidianAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.example.localaudioplayer.channel.audio',
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
      minimumSize: Size(640, 48),
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

  final audioHandler = await _initAudioService();
  final playbackEngine = JustAudioPlaybackEngine(handler: audioHandler);

  final database = app_db.AppDatabase();
  final discoveryDb = DiscoveryDatabase();
  final radioDb = RadioDatabase();
  final prefs = await SharedPreferences.getInstance();

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
    scanner: scannerService,
  );

  final playlistService = PlaylistServiceImpl();
  final logService = MediaLogService();
  final artworkService = ArtworkService();
  final ensembleService = EnsembleArtworkService(
    artworkService: artworkService,
  );
  
  final rateLimitDispatcher = RateLimitDispatcher();
  final podcastService = RssPodcastService(db: database);
  final discoveryService = PodcastDiscoveryService(rateLimiter: rateLimitDispatcher);
  final downloadService = PodcastDownloadService(db: database);
  final syncManager = DiscoverySyncManager(api: discoveryService, db: discoveryDb);
  final storageManager = PodcastStorageManager(db: database, settingsVM: settingsViewModel);

  final radioService = RadioBrowserService(rateLimiter: rateLimitDispatcher);
  final radioSyncManager = RadioSyncManager(api: radioService, db: radioDb);

  final libraryIndexerService = LibraryIndexerService(
    db: database,
    prefs: prefs,
    artworkService: artworkService,
    ensembleService: ensembleService,
  );

  final nsdDiscoveryService = NsdDiscoveryService();
  final handshakeService = HandshakeService(prefs);
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
    connectionManager: connectionManager,
    settingsVM: settingsViewModel,
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
    discoveryDb: discoveryDb,
    settingsVM: settingsViewModel,
  );
  final radioViewModel = RadioViewModel(
    api: radioService,
    db: radioDb,
    syncManager: radioSyncManager,
  );
  final insightsViewModel = InsightsViewModel(database);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MediaLogService>.value(value: logService),
        Provider<RateLimitDispatcher>.value(value: rateLimitDispatcher),
        Provider<DiscoveryDatabase>.value(value: discoveryDb),
        Provider<RadioDatabase>.value(value: radioDb),
        ChangeNotifierProvider<DiscoverySyncManager>.value(value: syncManager),
        Provider<PodcastStorageManager>.value(value: storageManager),
        Provider<PersistentLibraryService>.value(value: persistentLibrary),
        Provider<EnsembleArtworkService>.value(value: ensembleService),
        Provider<PodcastService>.value(value: podcastService),
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
        ChangeNotifierProvider.value(value: insightsViewModel),
      ],
      child: const LocalAudioPlayerApp(),
    ),
  );
}

class LocalAudioPlayerApp extends StatelessWidget {
  const LocalAudioPlayerApp({super.key});

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
        home = const NowPlayingScreen();
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
