import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/audiobooks/widgets/librivox_book_detail_view.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';

class MockLibriVoxViewModel extends Mock implements LibriVoxViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockPlayerViewModel extends Mock implements PlayerViewModel {}

void main() {
  late MockLibriVoxViewModel mockLibriVoxVM;
  late MockLibraryViewModel mockLibraryVM;
  late MockPlayerViewModel mockPlayerVM;
  late LibriVoxBook testBook;

  setUpAll(() {
    registerFallbackValue(
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
    );
  });

  setUp(() {
    mockLibriVoxVM = MockLibriVoxViewModel();
    mockLibraryVM = MockLibraryViewModel();
    mockPlayerVM = MockPlayerViewModel();

    testBook = LibriVoxBook(
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

    // Stubs
    when(() => mockLibriVoxVM.downloadProgress).thenReturn(<String, double>{});
    when(() => mockLibriVoxVM.addListener(any())).thenReturn(null);
    when(() => mockLibriVoxVM.removeListener(any())).thenReturn(null);

    when(() => mockLibraryVM.addListener(any())).thenReturn(null);
    when(() => mockLibraryVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);
  });

  Widget buildTestableWidget(LibriVoxBook book) {
    return MaterialApp(
      home: Scaffold(
        body: ThemerProvider(
          theme: AulosAudioTheme.model,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<LibriVoxViewModel>.value(value: mockLibriVoxVM),
              ChangeNotifierProvider<LibraryViewModel>.value(value: mockLibraryVM),
              ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
            ],
            child: LibriVoxBookDetailView(book: book),
          ),
        ),
      ),
    );
  }

  testWidgets('renders details screen elements correctly', (WidgetTester tester) async {
    when(() => mockLibraryVM.findBookByLibrivoxId('1')).thenReturn(null);

    await tester.pumpWidget(buildTestableWidget(testBook));
    await tester.pumpAndSettle();

    expect(find.text('Moby Dick'), findsNWidgets(2)); // Cover + Header title
    expect(find.text('By Herman Melville'), findsOneWidget);
    expect(find.text('Narrated by: John Doe'), findsOneWidget);
    expect(find.text('Call me Ishmael.'), findsOneWidget);
    expect(find.text('Public Domain'), findsOneWidget);
  });

  testWidgets('renders Play button when book is fully downloaded', (WidgetTester tester) async {
    final mockAlbum = Album(
      id: '1',
      name: 'Moby Dick',
      isFavorite: false,
      playCount: 0,
      isAudiobook: true,
      isPlayed: false,
      isDownloadedViaAulos: true,
    );
    when(() => mockLibraryVM.findBookByLibrivoxId('1')).thenReturn(mockAlbum);

    await tester.pumpWidget(buildTestableWidget(testBook));
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Downloaded'), findsOneWidget);
    expect(find.text('Play (Stream)'), findsNothing);
    expect(find.text('Download & Play'), findsNothing);
  });

  testWidgets('renders Stream and Download & Play buttons when book is not in library', (WidgetTester tester) async {
    when(() => mockLibraryVM.findBookByLibrivoxId('1')).thenReturn(null);

    await tester.pumpWidget(buildTestableWidget(testBook));
    await tester.pumpAndSettle();

    expect(find.text('Play (Stream)'), findsOneWidget);
    expect(find.text('Download & Play'), findsOneWidget);
    expect(find.text('Play'), findsNothing);
  });

  testWidgets('renders Stream and Download buttons when book is in library as streaming', (WidgetTester tester) async {
    final mockAlbum = Album(
      id: '1',
      name: 'Moby Dick',
      isFavorite: false,
      playCount: 0,
      isAudiobook: true,
      isPlayed: false,
      isDownloadedViaAulos: false, // Streaming
    );
    when(() => mockLibraryVM.findBookByLibrivoxId('1')).thenReturn(mockAlbum);

    await tester.pumpWidget(buildTestableWidget(testBook));
    await tester.pumpAndSettle();

    expect(find.text('Play (Stream)'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Streaming Available'), findsOneWidget);
    expect(find.text('Play'), findsNothing);
  });

  testWidgets('Play (Stream) triggers streamBook and plays tracks when not streaming yet', (WidgetTester tester) async {
    when(() => mockLibraryVM.findBookByLibrivoxId('1')).thenReturn(null);
    when(() => mockLibriVoxVM.streamBook(any())).thenAnswer((_) async {});
    when(() => mockLibraryVM.reloadLibrary()).thenAnswer((_) async {});

    final mockAlbum = Album(
      id: '1',
      name: 'Moby Dick',
      isFavorite: false,
      playCount: 0,
      isAudiobook: true,
      isPlayed: false,
      isDownloadedViaAulos: false,
    );
    final mockTrack = Track(
      id: '10',
      title: 'Chapter 1',
      path: 'http://example.com/1.mp3',
      folderId: '1',
      artistId: '1',
      rating: 0,
      isFavorite: false,
      playCount: 0,
      isAudiobook: true,
      isPlayed: false,
    );

    // After streamBook and reloadLibrary, findBookByLibrivoxId returns the streaming album
    var callCount = 0;
    when(() => mockLibraryVM.findBookByLibrivoxId('1')).thenAnswer((_) {
      callCount++;
      return callCount > 1 ? mockAlbum : null;
    });

    when(() => mockLibraryVM.getTracksForItem(mockAlbum)).thenAnswer((_) async => [mockTrack]);
    when(() => mockPlayerVM.setQueueAndPlay(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(buildTestableWidget(testBook));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play (Stream)'));
    await tester.pump();

    verify(() => mockLibriVoxVM.streamBook(testBook)).called(1);
    verify(() => mockLibraryVM.reloadLibrary()).called(1);
    verify(() => mockPlayerVM.setQueueAndPlay([mockTrack], 0)).called(1);
  });
}
