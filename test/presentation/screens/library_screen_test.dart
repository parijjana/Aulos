import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:localaudioplayer/features/library/screens/library_screen.dart';
import 'package:localaudioplayer/presentation/viewmodels/library_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/player_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/display_view_model.dart';
import 'package:localaudioplayer/presentation/viewmodels/settings_view_model.dart';
import 'package:localaudioplayer/presentation/theme/obsidian_audio_theme.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/domain/playback/playback_engine.dart' as domain;
import 'package:themer_flutter/themer_flutter.dart';

class MockLibraryViewModel extends Mock implements LibraryViewModel {}

class MockPlayerViewModel extends Mock implements PlayerViewModel {}

class MockQueueViewModel extends Mock implements QueueViewModel {}

class MockDisplayViewModel extends Mock implements DisplayViewModel {}

class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late MockLibraryViewModel mockLibraryVM;
  late MockPlayerViewModel mockPlayerVM;
  late MockQueueViewModel mockQueueVM;
  late MockDisplayViewModel mockDisplayVM;
  late MockSettingsViewModel mockSettingsVM;

  setUpAll(() {
    registerFallbackValue(domain.PlaybackState.idle);
  });

  setUp(() {
    mockLibraryVM = MockLibraryViewModel();
    mockPlayerVM = MockPlayerViewModel();
    mockQueueVM = MockQueueViewModel();
    mockDisplayVM = MockDisplayViewModel();
    mockSettingsVM = MockSettingsViewModel();

    when(() => mockLibraryVM.folders).thenReturn([]);
    when(() => mockLibraryVM.artists).thenReturn([]);
    when(() => mockLibraryVM.albums).thenReturn([]);
    when(() => mockLibraryVM.genres).thenReturn([]);
    when(() => mockLibraryVM.years).thenReturn([]);
    when(() => mockLibraryVM.playlists).thenReturn([]);
    when(() => mockLibraryVM.tracks).thenReturn([]);
    when(() => mockLibraryVM.isLoading).thenReturn(false);
    when(() => mockLibraryVM.selectedItem).thenReturn(null);
    when(() => mockLibraryVM.isAtRoot).thenReturn(true);
    when(() => mockLibraryVM.isPartialView).thenReturn(false);
    when(() => mockLibraryVM.wasRevealed).thenReturn(false);
    when(() => mockLibraryVM.isShowingSubContent).thenReturn(false);
    when(() => mockLibraryVM.subFolders).thenReturn([]);
    when(() => mockLibraryVM.subAlbums).thenReturn([]);
    when(() => mockLibraryVM.mode).thenReturn(LibraryMode.folders);
    when(() => mockLibraryVM.viewType).thenReturn(LibraryViewType.list);
    when(() => mockLibraryVM.currentScrollKey).thenReturn('root');
    when(() => mockLibraryVM.getScrollOffset()).thenReturn(0.0);
    when(() => mockLibraryVM.addListener(any())).thenReturn(null);
    when(() => mockLibraryVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.state).thenReturn(domain.PlaybackState.idle);
    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockQueueVM.addListener(any())).thenReturn(null);
    when(() => mockQueueVM.removeListener(any())).thenReturn(null);

    when(() => mockDisplayVM.isHighContext).thenReturn(false);
    when(() => mockDisplayVM.addListener(any())).thenReturn(null);
    when(() => mockDisplayVM.removeListener(any())).thenReturn(null);
    
    when(() => mockSettingsVM.themeModel).thenReturn(ObsidianAudioTheme.model);
    when(() => mockSettingsVM.isDynamicTheme).thenReturn(false);
    when(() => mockSettingsVM.artworkShape).thenReturn(ArtworkShape.square);
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
              ChangeNotifierProvider<LibraryViewModel>.value(
                value: mockLibraryVM,
              ),
              ChangeNotifierProvider<PlayerViewModel>.value(
                value: mockPlayerVM,
              ),
              ChangeNotifierProvider<QueueViewModel>.value(value: mockQueueVM),
              ChangeNotifierProvider<DisplayViewModel>.value(
                value: mockDisplayVM,
              ),
              ChangeNotifierProvider<SettingsViewModel>.value(
                value: mockSettingsVM,
              ),
            ],
            child: const LibraryScreen(),
          ),
        ),
      ),
    );
  }

  group('LibraryScreen', () {
    testWidgets('should render folder list when at root', (tester) async {
      final mockFolders = [Folder(id: 1, path: '/m1', name: 'Music 1')];
      when(() => mockLibraryVM.folders).thenReturn(mockFolders);

      await tester.pumpWidget(buildTestableWidget());
      expect(find.text('Music 1'), findsOneWidget);
    });

    testWidgets('should render track list when in a folder', (tester) async {
      final mockFolder = Folder(id: 1, path: '/m1', name: 'Music 1');
      final mockTracks = [
        Track(
          id: 1,
          path: '/m1/s1.mp3',
          title: 'Song 1',
          folderId: 1,
          rating: 0,
          isFavorite: false,
          playCount: 0,
        ),
      ];
      when(() => mockLibraryVM.isAtRoot).thenReturn(false);
      when(() => mockLibraryVM.selectedItem).thenReturn(mockFolder);
      when(() => mockLibraryVM.tracks).thenReturn(mockTracks);

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Song 1'), findsOneWidget);
    });
  });
}
