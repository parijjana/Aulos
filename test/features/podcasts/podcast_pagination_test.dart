import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/features/podcasts/screens/podcast_browser_screen.dart';
import 'package:aulos/presentation/viewmodels/podcast_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/display_view_model.dart';
import 'package:aulos/data/library/podcast_discovery_service.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
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
    mockPlayerVM = MockPlayerViewModel();
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
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.extractedColor).thenReturn(null);
    when(() => mockPlayerVM.isRemoteMode).thenReturn(false);
    when(() => mockPlayerVM.isHostMode).thenReturn(false);
    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockDisplayVM.addListener(any())).thenReturn(null);
    when(() => mockDisplayVM.removeListener(any())).thenReturn(null);
  });

  testWidgets('PodcastBrowserScreen pagination triggers loadMore', (tester) async {
    final catId = '1318';
    final mockResults = List.generate(20, (i) => PodcastSearchResult(
      title: 'Podcast $i',
      artist: 'Artist $i',
      feedUrl: 'url $i',
      imageUrl: null,
    ));

    when(() => mockVM.categoryResults).thenReturn({catId: mockResults});
    when(() => mockVM.loadMoreForCategory(any(), any())).thenAnswer((_) async {});
    
    // Start directly in detail view to simplify the test
    when(() => mockVM.selectedDiscoveryCategory).thenReturn({'name': 'Technology', 'id': catId});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PodcastViewModel>.value(value: mockVM),
          ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
          ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
          ChangeNotifierProvider<DisplayViewModel>.value(value: mockDisplayVM),
        ],
        child: const MaterialApp(home: PodcastBrowserScreen()),
      ),
    );

    // Verify we are in detail view
    expect(find.textContaining('TOP TECHNOLOGY'), findsWidgets);

    // Find the GridView which should have the controller
    final scrollableFinder = find.byType(Scrollable).last;
    
    // Simulate scroll to trigger pagination
    await tester.drag(scrollableFinder, const Offset(0, -2000));
    await tester.pump();

    // Verify loadMoreForCategory was called
    verify(() => mockVM.loadMoreForCategory(catId, 20)).called(1);
  });
}
