// Widget-level portfolio screenshots for Aulos.
//
// Renders real screens/widgets from lib/ with fake data injected via mocked
// ViewModels (same DI pattern as the rest of test/presentation and
// test/features -- MultiProvider of ChangeNotifierProvider<X>.value(mock)),
// wrapped in a RepaintBoundary, and writes PNGs to screenshots/harness/.
//
// Run with: flutter test test/screenshots/capture_test.dart
import 'dart:typed_data';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:themer_flutter/themer_flutter.dart';

import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart' show AudiobookChapter;
import 'package:aulos/data/database/playback_database.dart' show Bookmark;
import 'package:aulos/domain/playback/playback_engine.dart' as domain;
import 'package:aulos/features/library/screens/library_screen.dart';
import 'package:aulos/features/noise/models/noise_item.dart';
import 'package:aulos/features/noise/screens/noise_root_screen.dart';
import 'package:aulos/presentation/screens/mood_dashboard_screen.dart';
import 'package:aulos/presentation/screens/now_playing_screen.dart';
import 'package:aulos/presentation/theme/aulos_audio_theme.dart';
import 'package:aulos/presentation/viewmodels/connectivity_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/mood_view_model.dart';
import 'package:aulos/presentation/viewmodels/noise_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

import 'screenshot_harness.dart';

// ---------------------------------------------------------------------------
// Mocks (mocktail, same pattern used across test/presentation/screens/*_test.dart)
// ---------------------------------------------------------------------------
class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockQueueViewModel extends Mock implements QueueViewModel {}
class MockDisplayViewModel extends Mock implements DisplayViewModel {}
class MockConnectivityViewModel extends Mock implements ConnectivityViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockNoiseViewModel extends Mock implements NoiseViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockMoodViewModel extends Mock implements MoodViewModel {}

void main() {
  setUpAll(() async {
    registerFallbackValue(domain.PlaybackState.idle);
    registerFallbackValue(LibraryMode.folders);
    registerFallbackValue(NoiseCategory.nature);
  });

  // -------------------------------------------------------------------------
  // Scene 1: Now Playing (Music) -- waveform seekbar + WinampVisualizer
  // -------------------------------------------------------------------------
  testWidgets('Now Playing - Music (waveform + visualizer)', (tester) async {
    await tester.runAsync(loadAppFonts);

    final playerVM = MockPlayerViewModel();
    final queueVM = MockQueueViewModel();
    final displayVM = MockDisplayViewModel();
    final connectivityVM = MockConnectivityViewModel();
    final settingsVM = MockSettingsViewModel();
    final noiseVM = MockNoiseViewModel();

    final dbTrack = Track(
      id: 't1',
      title: 'Nightdrive Synthesis',
      path: '/music/nightdrive.flac',
      folderId: 'f1',
      rating: 1,
      isFavorite: true,
      playCount: 42,
      isAudiobook: false,
      isPlayed: true,
    );
    final track = dbTrack.toDomain();

    when(() => playerVM.isSleepTimerActive).thenReturn(true);
    when(() => playerVM.sleepTimeRemaining).thenReturn(const Duration(minutes: 24, seconds: 5));
    when(() => playerVM.state).thenReturn(domain.PlaybackState.playing);
    when(() => playerVM.position).thenReturn(const Duration(minutes: 1, seconds: 47));
    when(() => playerVM.duration).thenReturn(const Duration(minutes: 4, seconds: 12));
    when(() => playerVM.isPlaying).thenReturn(true);
    when(() => playerVM.isRemoteMode).thenReturn(false);
    when(() => playerVM.isHostMode).thenReturn(false);
    when(() => playerVM.volume).thenReturn(0.8);
    when(() => playerVM.currentTrack).thenReturn(track);
    when(() => playerVM.currentArtistName).thenReturn('Solstice Array');
    when(() => playerVM.currentAlbumName).thenReturn('Afterglow Cycles');
    when(() => playerVM.displayTitle).thenReturn(track.title);
    when(() => playerVM.isShuffle).thenReturn(true);
    when(() => playerVM.repeatMode).thenReturn(domain.RepeatMode.all);
    when(() => playerVM.currentMediaType).thenReturn(MediaType.music);
    when(() => playerVM.currentShowNotes).thenReturn(null);
    when(() => playerVM.currentStreamMetadata).thenReturn(null);
    when(() => playerVM.currentImageUrl).thenReturn(null);
    when(() => playerVM.isBookmarkMode).thenReturn(false);
    when(() => playerVM.isBuffering).thenReturn(false);
    when(() => playerVM.extractedColor).thenReturn(const Color(0xFF00F0FF));
    when(() => playerVM.playbackSpeed).thenReturn(1.0);
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);

    when(() => queueVM.currentQueue).thenReturn([dbTrack, dbTrack]);
    when(() => queueVM.history).thenReturn([]);
    when(() => queueVM.currentIndex).thenReturn(0);
    when(() => queueVM.currentTrack).thenReturn(dbTrack);
    when(() => queueVM.addListener(any())).thenReturn(null);
    when(() => queueVM.removeListener(any())).thenReturn(null);

    when(() => displayVM.isHighContext).thenReturn(true);
    when(() => displayVM.addListener(any())).thenReturn(null);
    when(() => displayVM.removeListener(any())).thenReturn(null);

    when(() => connectivityVM.isHosting).thenReturn(false);
    when(() => connectivityVM.isRemoteMode).thenReturn(false);
    when(() => connectivityVM.addListener(any())).thenReturn(null);
    when(() => connectivityVM.removeListener(any())).thenReturn(null);

    when(() => settingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(false);
    when(() => settingsVM.isVisualizerEnabled).thenReturn(true);
    when(() => settingsVM.visualizerPluginId).thenReturn('bar_spectrum');
    when(() => settingsVM.addListener(any())).thenReturn(null);
    when(() => settingsVM.removeListener(any())).thenReturn(null);

    when(() => noiseVM.masterVolume).thenReturn(0.5);
    when(() => noiseVM.addListener(any())).thenReturn(null);
    when(() => noiseVM.removeListener(any())).thenReturn(null);

    await captureWidget(
      tester,
      name: '01_now_playing_music',
      child: MaterialApp(
        // Match main.dart:424 — without this the Scaffold falls back to
        // Material's default LIGHT theme while the themer supplies colours
        // designed for a dark background.
        theme: ThemerCompiler.compile(AulosAudioTheme.model),
        home: Scaffold(
          body: ThemerProvider(
            theme: AulosAudioTheme.model,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
                ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
                ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
                ChangeNotifierProvider<ConnectivityViewModel>.value(value: connectivityVM),
                ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
                ChangeNotifierProvider<NoiseViewModel>.value(value: noiseVM),
              ],
              child: const NowPlayingScreen(),
            ),
          ),
        ),
      ),
    );
  });

  // -------------------------------------------------------------------------
  // Scene 2: Now Playing (Audiobook) -- AudiobookStrategy chapters UI
  // -------------------------------------------------------------------------
  testWidgets('Now Playing - Audiobook (chapters strategy)', (tester) async {
    await tester.runAsync(loadAppFonts);

    final playerVM = MockPlayerViewModel();
    final queueVM = MockQueueViewModel();
    final displayVM = MockDisplayViewModel();
    final connectivityVM = MockConnectivityViewModel();
    final settingsVM = MockSettingsViewModel();
    final noiseVM = MockNoiseViewModel();

    final dbBook = Track(
      id: 'b1',
      title: 'The Salt Roads',
      path: '/audiobooks/salt_roads.m4b',
      folderId: 'fb1',
      rating: 0,
      isFavorite: false,
      playCount: 3,
      isAudiobook: true,
      isPlayed: false,
    );
    final book = dbBook.toDomain();

    final chapters = List.generate(
      8,
      (i) => AudiobookChapter(
        id: 'c$i',
        audiobookTrackId: 'b1',
        title: 'Chapter ${i + 1}: ${[
          'Departure',
          'The Coastline',
          'Old Debts',
          'A Stranger\'s Map',
          'Low Tide',
          'The Lighthouse',
          'Storm Warning',
          'Landfall',
        ][i]}',
        startTimeMs: i * 12 * 60 * 1000,
        durationMs: 12 * 60 * 1000,
      ),
    );

    when(() => playerVM.isSleepTimerActive).thenReturn(false);
    when(() => playerVM.sleepTimeRemaining).thenReturn(Duration.zero);
    when(() => playerVM.state).thenReturn(domain.PlaybackState.playing);
    when(() => playerVM.position).thenReturn(const Duration(minutes: 38, seconds: 22));
    when(() => playerVM.duration).thenReturn(const Duration(hours: 1, minutes: 36));
    when(() => playerVM.isPlaying).thenReturn(true);
    when(() => playerVM.isRemoteMode).thenReturn(false);
    when(() => playerVM.isHostMode).thenReturn(false);
    when(() => playerVM.volume).thenReturn(1.0);
    when(() => playerVM.currentTrack).thenReturn(book);
    when(() => playerVM.currentArtistName).thenReturn('Narrated by Priya Okonkwo');
    when(() => playerVM.currentAlbumName).thenReturn('The Salt Roads');
    when(() => playerVM.displayTitle).thenReturn(book.title);
    when(() => playerVM.isShuffle).thenReturn(false);
    when(() => playerVM.repeatMode).thenReturn(domain.RepeatMode.off);
    when(() => playerVM.currentMediaType).thenReturn(MediaType.audiobook);
    when(() => playerVM.currentChapters).thenReturn(chapters);
    when(() => playerVM.currentShowNotes).thenReturn(null);
    when(() => playerVM.currentStreamMetadata).thenReturn(null);
    when(() => playerVM.currentImageUrl).thenReturn(null);
    when(() => playerVM.isBookmarkMode).thenReturn(false);
    when(() => playerVM.isBuffering).thenReturn(false);
    when(() => playerVM.extractedColor).thenReturn(const Color(0xFFB0CCC0));
    when(() => playerVM.playbackSpeed).thenReturn(1.25);
    when(() => playerVM.watchAudiobookBookmarksForTrack(any()))
        .thenAnswer((_) => Stream<List<Bookmark>>.value(const []));
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);

    when(() => queueVM.currentQueue).thenReturn([dbBook]);
    when(() => queueVM.history).thenReturn([]);
    when(() => queueVM.currentIndex).thenReturn(0);
    when(() => queueVM.currentTrack).thenReturn(dbBook);
    when(() => queueVM.addListener(any())).thenReturn(null);
    when(() => queueVM.removeListener(any())).thenReturn(null);

    when(() => displayVM.isHighContext).thenReturn(true);
    when(() => displayVM.addListener(any())).thenReturn(null);
    when(() => displayVM.removeListener(any())).thenReturn(null);

    when(() => connectivityVM.isHosting).thenReturn(false);
    when(() => connectivityVM.isRemoteMode).thenReturn(false);
    when(() => connectivityVM.addListener(any())).thenReturn(null);
    when(() => connectivityVM.removeListener(any())).thenReturn(null);

    when(() => settingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(false);
    when(() => settingsVM.isVisualizerEnabled).thenReturn(false);
    when(() => settingsVM.visualizerPluginId).thenReturn('bar_spectrum');
    when(() => settingsVM.addListener(any())).thenReturn(null);
    when(() => settingsVM.removeListener(any())).thenReturn(null);

    when(() => noiseVM.masterVolume).thenReturn(0.5);
    when(() => noiseVM.addListener(any())).thenReturn(null);
    when(() => noiseVM.removeListener(any())).thenReturn(null);

    await captureWidget(
      tester,
      name: '02_now_playing_audiobook',
      child: MaterialApp(
        // Match main.dart:424 — without this the Scaffold falls back to
        // Material's default LIGHT theme while the themer supplies colours
        // designed for a dark background.
        theme: ThemerCompiler.compile(AulosAudioTheme.model),
        home: Scaffold(
          body: ThemerProvider(
            theme: AulosAudioTheme.model,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
                ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
                ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
                ChangeNotifierProvider<ConnectivityViewModel>.value(value: connectivityVM),
                ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
                ChangeNotifierProvider<NoiseViewModel>.value(value: noiseVM),
              ],
              child: const NowPlayingScreen(),
            ),
          ),
        ),
      ),
    );
  });

  // -------------------------------------------------------------------------
  // Scene 3: Library browse (grid of albums with synthetic cover art)
  // -------------------------------------------------------------------------
  testWidgets('Library - album grid', (tester) async {
    await tester.runAsync(loadAppFonts);

    final libraryVM = MockLibraryViewModel();
    final playerVM = MockPlayerViewModel();
    final queueVM = MockQueueViewModel();
    final displayVM = MockDisplayViewModel();
    final settingsVM = MockSettingsViewModel();

    final albumTitles = [
      'Afterglow Cycles',
      'Marrow & Ash',
      'Concrete Orchards',
      'The Salt Roads (Audiobook)',
      'Low Tide Radio',
      'Halide',
      'Nine Winters',
      'Static Bloom',
    ];

    Uint8List coverArt(int i) => syntheticCoverArt(seed: i);

    final albums = List.generate(albumTitles.length, (i) {
      return Album(
        id: 'al$i',
        name: albumTitles[i],
        isFavorite: i == 0 || i == 3,
        playCount: 10 + i,
        isAudiobook: i == 3,
        isPlayed: false,
        isDownloadedViaAulos: true,
        coverArt: coverArt(i),
      );
    });

    when(() => libraryVM.folders).thenReturn([]);
    when(() => libraryVM.artists).thenReturn([]);
    when(() => libraryVM.albums).thenReturn(albums);
    when(() => libraryVM.genres).thenReturn([]);
    when(() => libraryVM.years).thenReturn([]);
    when(() => libraryVM.playlists).thenReturn([]);
    when(() => libraryVM.tracks).thenReturn([]);
    when(() => libraryVM.isLoading).thenReturn(false);
    when(() => libraryVM.showFavoritesOnly).thenReturn(false);
    when(() => libraryVM.selectedItem).thenReturn(null);
    when(() => libraryVM.isAtRoot).thenReturn(true);
    when(() => libraryVM.isPartialView).thenReturn(false);
    when(() => libraryVM.subFolders).thenReturn([]);
    when(() => libraryVM.subAlbums).thenReturn([]);
    when(() => libraryVM.mode).thenReturn(LibraryMode.albums);
    when(() => libraryVM.viewType).thenReturn(LibraryViewType.grid);
    when(() => libraryVM.currentScrollKey).thenReturn('root');
    when(() => libraryVM.getScrollOffset()).thenReturn(0.0);
    when(() => libraryVM.tempShowHome).thenReturn(false);
    when(() => libraryVM.tempShowHomeFor(any())).thenReturn(false);
    when(() => libraryVM.navStack).thenReturn([]);
    when(() => libraryVM.stateFor(any())).thenReturn(LibraryNavigationState());
    when(() => libraryVM.getBookProgress(any())).thenReturn(0.4);
    when(() => libraryVM.addListener(any())).thenReturn(null);
    when(() => libraryVM.removeListener(any())).thenReturn(null);

    when(() => playerVM.state).thenReturn(domain.PlaybackState.idle);
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);

    when(() => queueVM.addListener(any())).thenReturn(null);
    when(() => queueVM.removeListener(any())).thenReturn(null);

    when(() => displayVM.isHighContext).thenReturn(false);
    when(() => displayVM.addListener(any())).thenReturn(null);
    when(() => displayVM.removeListener(any())).thenReturn(null);

    when(() => settingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => settingsVM.isDynamicTheme).thenReturn(false);
    when(() => settingsVM.artworkShape).thenReturn(ArtworkShape.square);
    when(() => settingsVM.addListener(any())).thenReturn(null);
    when(() => settingsVM.removeListener(any())).thenReturn(null);

    await captureWidget(
      tester,
      name: '03_library_album_grid',
      child: MaterialApp(
        // Match main.dart:424 — without this the Scaffold falls back to
        // Material's default LIGHT theme while the themer supplies colours
        // designed for a dark background.
        theme: ThemerCompiler.compile(AulosAudioTheme.model),
        home: Scaffold(
          body: ThemerProvider(
            theme: AulosAudioTheme.model,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<LibraryViewModel>.value(value: libraryVM),
                ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
                ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
                ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
                ChangeNotifierProvider<SettingsViewModel>.value(value: settingsVM),
              ],
              child: const LibraryScreen(),
            ),
          ),
        ),
      ),
    );
  });

  // -------------------------------------------------------------------------
  // Scene 4: Mood Dashboard
  // -------------------------------------------------------------------------
  testWidgets('Mood Dashboard', (tester) async {
    await tester.runAsync(loadAppFonts);

    final moodVM = MockMoodViewModel();
    final playerVM = MockPlayerViewModel();
    final noiseVM = MockNoiseViewModel();
    final displayVM = MockDisplayViewModel();
    final queueVM = MockQueueViewModel();

    when(() => moodVM.isLoading).thenReturn(false);
    when(() => moodVM.lastMusic).thenReturn(
      MoodItemData(
        title: 'Nightdrive Synthesis',
        subtitle: 'Solstice Array',
        coverArt: syntheticCoverArt(seed: 0),
      ),
    );
    when(() => moodVM.lastPodcast).thenReturn(
      MoodItemData(
        title: 'Ep. 142: Deep Sea Signals',
        subtitle: 'Field Notes Podcast',
        coverArt: syntheticCoverArt(seed: 1),
      ),
    );
    when(() => moodVM.lastAudiobook).thenReturn(
      MoodItemData(
        title: 'The Salt Roads',
        subtitle: 'Ch. 5 of 8',
        coverArt: syntheticCoverArt(seed: 3),
      ),
    );
    when(() => moodVM.lastNoise).thenReturn(
      MoodItemData(title: 'Rain + Fireplace', subtitle: 'Saved mix'),
    );
    when(() => moodVM.lastRadio).thenReturn(
      MoodItemData(title: 'Low Tide Radio', subtitle: 'Live stream'),
    );
    when(() => moodVM.addListener(any())).thenReturn(null);
    when(() => moodVM.removeListener(any())).thenReturn(null);

    when(() => playerVM.currentMediaType).thenReturn(MediaType.music);
    when(() => playerVM.addListener(any())).thenReturn(null);
    when(() => playerVM.removeListener(any())).thenReturn(null);

    when(() => noiseVM.addListener(any())).thenReturn(null);
    when(() => noiseVM.removeListener(any())).thenReturn(null);

    when(() => displayVM.mode).thenReturn(UIContextMode.minimalist);
    when(() => displayVM.addListener(any())).thenReturn(null);
    when(() => displayVM.removeListener(any())).thenReturn(null);

    when(() => queueVM.currentQueue).thenReturn([]);
    when(() => queueVM.addListener(any())).thenReturn(null);
    when(() => queueVM.removeListener(any())).thenReturn(null);

    await captureWidget(
      tester,
      name: '04_mood_dashboard',
      child: MaterialApp(
        // Match main.dart:424 — without this the Scaffold falls back to
        // Material's default LIGHT theme while the themer supplies colours
        // designed for a dark background.
        theme: ThemerCompiler.compile(AulosAudioTheme.model),
        home: Scaffold(
          body: ThemerProvider(
            theme: AulosAudioTheme.model,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<MoodViewModel>.value(value: moodVM),
                ChangeNotifierProvider<PlayerViewModel>.value(value: playerVM),
                ChangeNotifierProvider<NoiseViewModel>.value(value: noiseVM),
                ChangeNotifierProvider<DisplayViewModel>.value(value: displayVM),
                ChangeNotifierProvider<QueueViewModel>.value(value: queueVM),
              ],
              child: const MoodDashboardScreen(),
            ),
          ),
        ),
      ),
    );
  });

  // -------------------------------------------------------------------------
  // Scene 5: Ambient Noise mixer
  // -------------------------------------------------------------------------
  testWidgets('Ambient Noise mixer', (tester) async {
    await tester.runAsync(loadAppFonts);

    final noiseVM = MockNoiseViewModel();

    // NoiseRootScreen reads noiseVM.filteredItems, which is a real getter
    // implemented on top of the ViewModel's own hardcoded catalogue
    // (NoiseViewModel._items) filtered by selectedCategory/searchQuery. We
    // can't stub a non-overridden getter on a Mock, so we stub its inputs
    // and the concrete NoiseItem list directly via allItems/filteredItems.
    const activeItems = [
      NoiseItem(
        id: 'n_rain_heavy',
        title: 'Heavy Rain',
        url: 'asset:///assets/audio/noise/rain_heavy.mp3',
        category: NoiseCategory.nature,
        icon: Icons.umbrella,
        color: Colors.indigo,
        source: 'BigSoundBank',
        author: 'CC0 / Public Domain',
      ),
      NoiseItem(
        id: 'n_campfire',
        title: 'Campfire',
        url: 'asset:///assets/audio/noise/campfire.mp3',
        category: NoiseCategory.nature,
        icon: Icons.fireplace,
        color: Colors.orangeAccent,
        source: 'BigSoundBank',
        author: 'CC0 / Public Domain',
      ),
      NoiseItem(
        id: 'n_ocean_surf',
        title: 'Ocean Surf',
        url: 'asset:///assets/audio/noise/ocean_surf.mp3',
        category: NoiseCategory.nature,
        icon: Icons.waves,
        color: Colors.blue,
        source: 'BigSoundBank',
        author: 'CC0 / Public Domain',
      ),
      NoiseItem(
        id: 'n_forest_amb',
        title: 'Forest Ambience',
        url: 'asset:///assets/audio/noise/forest_ambience.mp3',
        category: NoiseCategory.nature,
        icon: Icons.park,
        color: Colors.green,
        source: 'BigSoundBank',
        author: 'CC0 / Public Domain',
      ),
    ];

    when(() => noiseVM.allItems).thenReturn(activeItems);
    when(() => noiseVM.filteredItems).thenReturn(activeItems);
    when(() => noiseVM.activeVolumes).thenReturn({
      'n_rain_heavy': 0.75,
      'n_campfire': 0.45,
    });
    when(() => noiseVM.savedMixes).thenReturn([]);
    when(() => noiseVM.selectedCategory).thenReturn(NoiseCategory.nature);
    when(() => noiseVM.searchQuery).thenReturn('');
    when(() => noiseVM.isMixerActive).thenReturn(true);
    when(() => noiseVM.isPlaying).thenReturn(true);
    when(() => noiseVM.masterVolume).thenReturn(0.6);
    when(() => noiseVM.activeIngredientsLabel).thenReturn('Heavy Rain + Campfire');
    when(() => noiseVM.activeAttributions).thenReturn('BigSoundBank (CC0)');
    when(() => noiseVM.addListener(any())).thenReturn(null);
    when(() => noiseVM.removeListener(any())).thenReturn(null);

    await captureWidget(
      tester,
      name: '05_ambient_noise_mixer',
      child: MaterialApp(
        // Match main.dart:424 — without this the Scaffold falls back to
        // Material's default LIGHT theme while the themer supplies colours
        // designed for a dark background.
        theme: ThemerCompiler.compile(AulosAudioTheme.model),
        home: Scaffold(
          body: ThemerProvider(
            theme: AulosAudioTheme.model,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<NoiseViewModel>.value(value: noiseVM),
              ],
              child: const NoiseRootScreen(),
            ),
          ),
        ),
      ),
    );
  });
}
