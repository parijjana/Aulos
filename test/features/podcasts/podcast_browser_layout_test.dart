import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/features/podcasts/screens/podcast_browser_screen.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/presentation/theme/aulos_audio_theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockPodcastViewModel extends Mock implements PodcastViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockDisplayViewModel extends Mock implements DisplayViewModel {}

void main() {
  late MockPodcastViewModel mockVM;
  late MockSettingsViewModel mockSettingsVM;
  late MockPlayerViewModel mockPlayerVM;
  late MockDisplayViewModel mockDisplayVM;

  setUp(() {
    mockVM = MockPodcastViewModel();
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    mockPlayerVM = MockPlayerViewModel();
    when(() => mockPlayerVM.isSleepTimerActive).thenReturn(false);
    when(() => mockPlayerVM.sleepTimeRemaining).thenReturn(Duration.zero);
    mockDisplayVM = MockDisplayViewModel();

    when(() => mockVM.isLoading).thenReturn(false);
    when(() => mockVM.categoryResults).thenReturn({});
    when(() => mockVM.searchResults).thenReturn([]);
    when(() => mockVM.trendingResults).thenReturn([]);
    when(() => mockVM.loadCategoryPreviews(any())).thenAnswer((_) async {});
    when(() => mockVM.addListener(any())).thenReturn(null);
    when(() => mockVM.removeListener(any())).thenReturn(null);

    when(() => mockSettingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => mockSettingsVM.isDynamicTheme).thenReturn(false);
    when(() => mockSettingsVM.libraryViewType).thenReturn(LibraryViewType.grid);
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.extractedColor).thenReturn(null);
    when(() => mockPlayerVM.isRemoteMode).thenReturn(false);
    when(() => mockPlayerVM.isHostMode).thenReturn(false);
    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockVM.search(any())).thenAnswer((_) async {});
  });

  testWidgets('PodcastBrowserScreen renders shelves and grid items without errors', (tester) async {
    final mockResults = [
      PodcastSearchResult(
        title: 'Podcast A',
        artist: 'Artist A',
        feedUrl: 'url_a',
        imageUrl: null,
      ),
      PodcastSearchResult(
        title: 'Podcast B',
        artist: 'Artist B',
        feedUrl: 'url_b',
        imageUrl: 'http://example.com/b.png',
      ),
    ];

    when(() => mockVM.trendingResults).thenReturn(mockResults);
    when(() => mockVM.categoryResults).thenReturn({
      '1318': mockResults,
      '1311': mockResults,
    });
    when(() => mockVM.selectedDiscoveryCategory).thenReturn(null);
    when(() => mockVM.activeDiscoveryDetail).thenReturn(null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PodcastViewModel>.value(value: mockVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
          ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PodcastBrowserScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify it renders the trending shelf title
    expect(find.text('TRENDING'), findsOneWidget);

    // Verify it renders the grid items (both in trending and category shelves)
    expect(find.text('Podcast A'), findsWidgets);
    expect(find.text('Podcast B'), findsWidgets);
  });

  testWidgets('PodcastBrowserScreen renders category detail view and results without errors', (tester) async {
    final mockResults = [
      PodcastSearchResult(
        title: 'Podcast A',
        artist: 'Artist A',
        feedUrl: 'url_a',
        imageUrl: null,
      ),
    ];
    when(() => mockVM.selectedDiscoveryCategory).thenReturn(const {'name': 'Technology', 'id': '1318'});
    when(() => mockVM.categoryResults).thenReturn({'1318': mockResults});
    when(() => mockVM.activeDiscoveryDetail).thenReturn(null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PodcastViewModel>.value(value: mockVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
          ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PodcastBrowserScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TOP TECHNOLOGY'), findsOneWidget);
    expect(find.text('Podcast A'), findsWidgets);
  });

  testWidgets('PodcastBrowserScreen renders search results without errors', (tester) async {
    final mockResults = [
      PodcastSearchResult(
        title: 'Search Result A',
        artist: 'Artist A',
        feedUrl: 'url_a',
        imageUrl: null,
      ),
    ];
    when(() => mockVM.selectedDiscoveryCategory).thenReturn(null);
    when(() => mockVM.activeDiscoveryDetail).thenReturn(null);
    when(() => mockVM.searchResults).thenReturn(mockResults);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PodcastViewModel>.value(value: mockVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
          ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PodcastBrowserScreen(),
          ),
        ),
      ),
    );


    
    // Instead of forcing state, we can simulate search submission!
    final searchIconFinder = find.byIcon(Icons.search);
    await tester.tap(searchIconFinder);
    await tester.pump(const Duration(milliseconds: 300));
    
    final textFieldFinder = find.byType(TextField);
    await tester.enterText(textFieldFinder, 'Query');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1 RESULTS FOUND'), findsOneWidget);
    expect(find.text('Search Result A'), findsOneWidget);
  });

  testWidgets('PodcastDetailScreen handles null/missing activeDiscoveryDetail properties gracefully', (tester) async {
    when(() => mockVM.activeDiscoveryDetail).thenReturn({
      'iTunesId': null,
      'title': null,
      'artist': null,
      'imageUrl': null,
      'feedUrl': null,
    });
    when(() => mockVM.loadPodcastDetails(any(), any())).thenAnswer((_) async {});
    when(() => mockVM.podcasts).thenReturn([]);
    when(() => mockVM.watchPodcast(any())).thenAnswer((_) => const Stream.empty());
    when(() => mockVM.watchEpisodes(any())).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PodcastViewModel>.value(value: mockVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
          ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PodcastBrowserScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify it renders the default fallback names instead of crashing
    expect(find.text('Unknown'), findsWidgets);
  });
}
