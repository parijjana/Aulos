import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/radio/screens/radio_browser_screen.dart';
import 'package:aulos/presentation/viewmodels/radio_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart' as settings;
import 'package:aulos/data/database/radio_database.dart';
import 'package:aulos/presentation/theme/aulos_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';

class MockRadioViewModel extends Mock implements RadioViewModel {}
class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockSettingsViewModel extends Mock implements settings.SettingsViewModel {}
class FakePlayerViewModel extends Fake implements PlayerViewModel {}

void main() {
  late MockRadioViewModel mockRadioVM;
  late MockPlayerViewModel mockPlayerVM;
  late MockSettingsViewModel mockSettingsVM;

  setUpAll(() {
    registerFallbackValue(FakePlayerViewModel());
    registerFallbackValue(
      const RadioStation(
        id: 1,
        stationUuid: '123',
        name: 'Rock FM',
        url: 'http://rock.fm',
        votes: 100,
        bitrate: 128,
        isFavorite: false,
        isPinned: false,
        isHidden: false,
        isAvailable: true,
      ),
    );
  });

  setUp(() {
    mockRadioVM = MockRadioViewModel();
    mockPlayerVM = MockPlayerViewModel();
    mockSettingsVM = MockSettingsViewModel();

    // Base mock stubs
    when(() => mockRadioVM.isLoading).thenReturn(false);
    when(() => mockRadioVM.categories).thenReturn([
      const RadioCategory(id: 1, name: 'rock', stationCount: 10),
    ]);
    when(() => mockRadioVM.allCountries).thenReturn([]);
    when(() => mockRadioVM.allLanguages).thenReturn([]);
    when(() => mockRadioVM.browseResults).thenReturn([]);
    when(() => mockRadioVM.searchResults).thenReturn([]);
    when(() => mockRadioVM.tempShowHome).thenReturn(false);
    when(() => mockRadioVM.addListener(any())).thenReturn(null);
    when(() => mockRadioVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);

    when(() => mockSettingsVM.libraryViewType).thenReturn(settings.LibraryViewType.grid);
    when(() => mockSettingsVM.isDynamicTheme).thenReturn(false);
    when(() => mockSettingsVM.themeModel).thenReturn(AulosAudioTheme.model);
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ThemerProvider(
          theme: AulosAudioTheme.model,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioViewModel>.value(value: mockRadioVM),
              ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
              ChangeNotifierProvider<settings.SettingsViewModel>.value(value: mockSettingsVM),
            ],
            child: const RadioBrowserScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('RadioBrowserScreen - Grid Tile Add To Library and Info Sidebar tests', (tester) async {
    final station = const RadioStation(
      id: 1,
      stationUuid: '123',
      name: 'Rock FM',
      url: 'http://rock.fm',
      homepage: 'http://rock.fm/homepage',
      votes: 100,
      bitrate: 128,
      codec: 'MP3',
      country: 'USA',
      language: 'English',
      isFavorite: false,
      isPinned: false,
      isHidden: false,
      isAvailable: true,
    );

    // Setup stubs for browsing
    when(() => mockRadioVM.browseCategory(any())).thenAnswer((_) async {});
    when(() => mockRadioVM.checkHealthForBrowseResults()).thenAnswer((_) async {});
    when(() => mockRadioVM.browseResults).thenReturn([station]);
    when(() => mockRadioVM.toggleFavorite(any())).thenAnswer((_) async {});
    when(() => mockRadioVM.playStation(any(), any(), isAvailable: any(named: 'isAvailable'))).thenAnswer((_) async {});

    // Render screen
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // 1. Verify Rock category is visible in the grid
    final categoryFinder = find.text('ROCK');
    expect(categoryFinder, findsOneWidget);

    // Tap on category ROCK to list stations
    await tester.tap(categoryFinder);
    await tester.pumpAndSettle();

    // 2. Verify station 'Rock FM' is visible
    expect(find.text('Rock FM'), findsOneWidget);

    // 3. Find the Add to Library button (which covers bottom third of card)
    final addBtnFinder = find.text('ADD TO LIBRARY');
    expect(addBtnFinder, findsOneWidget);

    // Tap the Add to Library button and verify it calls toggleFavorite but NOT playStation
    await tester.tap(addBtnFinder);
    await tester.pumpAndSettle();

    verify(() => mockRadioVM.toggleFavorite(any())).called(1);
    verifyNever(() => mockRadioVM.playStation(any(), any(), isAvailable: any(named: 'isAvailable')));

    // 4. Find the info button (top right of card) and verify it opens the drawer
    final infoBtnFinder = find.byIcon(Icons.info_outline);
    expect(infoBtnFinder, findsOneWidget);

    await tester.tap(infoBtnFinder);
    await tester.pumpAndSettle();

    // Verify info drawer contents
    expect(find.text('Station Information'), findsOneWidget);
    expect(find.text('http://rock.fm'), findsOneWidget);
    expect(find.text('MP3'), findsOneWidget);
    expect(find.text('128 kbps'), findsOneWidget);
    expect(find.text('USA'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });
}
