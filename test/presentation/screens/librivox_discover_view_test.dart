import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/audiobooks/widgets/librivox_discover_view.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';

class MockLibriVoxViewModel extends Mock implements LibriVoxViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockPlayerViewModel extends Mock implements PlayerViewModel {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late MockLibriVoxViewModel mockLibriVoxVM;
  late MockLibraryViewModel mockLibraryVM;
  late MockPlayerViewModel mockPlayerVM;
  late MockSettingsViewModel mockSettingsVM;

  setUp(() {
    mockLibriVoxVM = MockLibriVoxViewModel();
    mockLibraryVM = MockLibraryViewModel();
    mockPlayerVM = MockPlayerViewModel();
    mockSettingsVM = MockSettingsViewModel();

    // Default stubbing
    when(() => mockSettingsVM.libraryViewType).thenReturn(LibraryViewType.grid);
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    when(() => mockLibriVoxVM.searchResults).thenReturn([]);
    when(() => mockLibriVoxVM.filteredResults).thenReturn([]);
    when(() => mockLibriVoxVM.categoryResults).thenReturn(<String, List<LibriVoxBook>>{});
    when(() => mockLibriVoxVM.categoryLoading).thenReturn(<String, bool>{});
    when(() => mockLibriVoxVM.isLoading).thenReturn(false);
    when(() => mockLibriVoxVM.error).thenReturn(null);
    when(() => mockLibriVoxVM.downloadProgress).thenReturn(<String, double>{});
    when(() => mockLibriVoxVM.lastSearchQuery).thenReturn('');
    when(() => mockLibriVoxVM.search(any())).thenAnswer((_) async {});
    when(() => mockLibriVoxVM.loadCategoryPreviews(any())).thenAnswer((_) async {});
    when(() => mockLibriVoxVM.loadCategoryPreviews(any(), force: any(named: 'force'))).thenAnswer((_) async {});
    when(() => mockLibriVoxVM.addListener(any())).thenReturn(null);
    when(() => mockLibriVoxVM.removeListener(any())).thenReturn(null);

    when(() => mockLibriVoxVM.selectedBook).thenReturn(null);
    when(() => mockLibriVoxVM.selectBook(any())).thenReturn(null);

    when(() => mockLibraryVM.books).thenReturn([]);
    when(() => mockLibraryVM.addListener(any())).thenReturn(null);
    when(() => mockLibraryVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);
  });

  Widget buildTestableWidget({Size? screenSize}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            if (screenSize != null) {
              // Override screen size for testing responsiveness
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  size: screenSize,
                ),
                child: ThemerProvider(
                  theme: AulosAudioTheme.model,
                  child: MultiProvider(
                    providers: [
                      ChangeNotifierProvider<LibriVoxViewModel>.value(value: mockLibriVoxVM),
                      ChangeNotifierProvider<LibraryViewModel>.value(value: mockLibraryVM),
                      ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
                      ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
                    ],
                    child: const LibriVoxDiscoverView(),
                  ),
                ),
              );
            }
            return ThemerProvider(
              theme: AulosAudioTheme.model,
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<LibriVoxViewModel>.value(value: mockLibriVoxVM),
                  ChangeNotifierProvider<LibraryViewModel>.value(value: mockLibraryVM),
                  ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
                  ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
                ],
                child: const LibriVoxDiscoverView(),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('renders search box and empty results state initially', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Expand the search bar to show the TextField
    final searchIconFinder = find.byIcon(Icons.search);
    expect(searchIconFinder, findsOneWidget);
    await tester.tap(searchIconFinder);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No audiobooks found.'), findsOneWidget);
    verify(() => mockLibriVoxVM.loadCategoryPreviews(any())).called(1); // Auto pre-population on init
  });

  testWidgets('renders search results on shelves', (WidgetTester tester) async {
    final books = [
      LibriVoxBook(
        id: '1',
        title: 'Moby Dick',
        description: 'Call me Ishmael.',
        totalTimeSecs: 3600,
        authors: [LibriVoxAuthor(id: '1', firstName: 'Herman', lastName: 'Melville')],
        urlRss: 'https://example.com/rss',
        urlZipFile: 'https://example.com/zip',
        language: 'English',
        narrators: const ['John Doe'],
      ),
    ];

    when(() => mockLibriVoxVM.filteredResults).thenReturn(books);
    when(() => mockLibriVoxVM.searchResults).thenReturn(books);
    when(() => mockLibriVoxVM.categoryResults).thenReturn({'': books});

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Moby Dick'), findsOneWidget);
    expect(find.text('Herman Melville'), findsOneWidget);
  });

  testWidgets('renders split-pane layout on wide screens (>= 720dp)', (WidgetTester tester) async {
    final book = LibriVoxBook(
      id: '1',
      title: 'Moby Dick',
      description: 'Call me Ishmael.',
      totalTimeSecs: 3600,
      authors: [LibriVoxAuthor(id: '1', firstName: 'Herman', lastName: 'Melville')],
      urlRss: 'https://example.com/rss',
      urlZipFile: 'https://example.com/zip',
      language: 'English',
      narrators: const ['John Doe'],
    );

    when(() => mockLibriVoxVM.filteredResults).thenReturn([book]);
    when(() => mockLibriVoxVM.selectedBook).thenReturn(book);
    when(() => mockLibriVoxVM.categoryResults).thenReturn({'': [book]});

    // Wide screen (1024x768)
    await tester.pumpWidget(buildTestableWidget(screenSize: const Size(1024, 768)));
    await tester.pumpAndSettle();

    // Both storefront and details panel should be visible simultaneously
    expect(find.text('Moby Dick'), findsNWidgets(3)); // One in shelf list, two in details (cover + header)
    expect(find.text('DESCRIPTION'), findsOneWidget); // Details panel indicator
  });

  testWidgets('renders tabbed/navigation layout on narrow screens (< 720dp)', (WidgetTester tester) async {
    final book = LibriVoxBook(
      id: '1',
      title: 'Moby Dick',
      description: 'Call me Ishmael.',
      totalTimeSecs: 3600,
      authors: [LibriVoxAuthor(id: '1', firstName: 'Herman', lastName: 'Melville')],
      urlRss: 'https://example.com/rss',
      urlZipFile: 'https://example.com/zip',
      language: 'English',
      narrators: const ['John Doe'],
    );

    when(() => mockLibriVoxVM.filteredResults).thenReturn([book]);
    when(() => mockLibriVoxVM.selectedBook).thenReturn(book);

    // Narrow screen (400x800)
    await tester.pumpWidget(buildTestableWidget(screenSize: const Size(400, 800)));
    await tester.pumpAndSettle();

    // On narrow screen, only one view is visible at a time.
    // If book is selected, it should switch to details, displaying the details content and back button.
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget); // Back button in details
    
    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    verify(() => mockLibriVoxVM.selectBook(null)).called(1);
  });

  testWidgets('typing in search box updates filter query', (WidgetTester tester) async {
    when(() => mockLibriVoxVM.setFilterQuery(any())).thenReturn(null);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Expand search bar
    final searchIconFinder = find.byIcon(Icons.search);
    expect(searchIconFinder, findsOneWidget);
    await tester.tap(searchIconFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Find the TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text
    await tester.enterText(textField, 'John Doe');
    await tester.pump();

    verify(() => mockLibriVoxVM.setFilterQuery('John Doe')).called(1);
  });
}
