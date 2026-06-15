import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/features/library/widgets/jamendo_discover_view.dart';
import 'package:aulos/presentation/viewmodels/jamendo_view_model.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';
import 'package:aulos/domain/library/jamendo_track.dart';
import 'package:aulos/presentation/theme/Aulos_audio_theme.dart';
import 'package:themer_flutter/themer_flutter.dart';

class MockJamendoViewModel extends Mock implements JamendoViewModel {}
class MockLibraryViewModel extends Mock implements LibraryViewModel {}
class MockPlayerViewModel extends Mock implements PlayerViewModel {}

void main() {
  late MockJamendoViewModel mockJamendoVM;
  late MockLibraryViewModel mockLibraryVM;
  late MockPlayerViewModel mockPlayerVM;

  setUp(() {
    mockJamendoVM = MockJamendoViewModel();
    mockLibraryVM = MockLibraryViewModel();
    mockPlayerVM = MockPlayerViewModel();

    // Default stubbing
    when(() => mockJamendoVM.searchResults).thenReturn([]);
    when(() => mockJamendoVM.isLoading).thenReturn(false);
    when(() => mockJamendoVM.error).thenReturn(null);
    when(() => mockJamendoVM.downloadProgress).thenReturn(<String, double>{});
    when(() => mockJamendoVM.lastSearchQuery).thenReturn('');
    when(() => mockJamendoVM.search(any())).thenAnswer((_) async {});
    when(() => mockJamendoVM.addListener(any())).thenReturn(null);
    when(() => mockJamendoVM.removeListener(any())).thenReturn(null);

    when(() => mockLibraryVM.tracks).thenReturn([]);
    when(() => mockLibraryVM.addListener(any())).thenReturn(null);
    when(() => mockLibraryVM.removeListener(any())).thenReturn(null);

    when(() => mockPlayerVM.addListener(any())).thenReturn(null);
    when(() => mockPlayerVM.removeListener(any())).thenReturn(null);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ThemerProvider(
          theme: AulosAudioTheme.model,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<JamendoViewModel>.value(value: mockJamendoVM),
              ChangeNotifierProvider<LibraryViewModel>.value(value: mockLibraryVM),
              ChangeNotifierProvider<PlayerViewModel>.value(value: mockPlayerVM),
            ],
            child: const JamendoDiscoverView(),
          ),
        ),
      ),
    );
  }

  testWidgets('renders search box and empty results state initially', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No tracks found.'), findsOneWidget);
    verify(() => mockJamendoVM.search('')).called(1); // Auto pre-population on init
  });

  testWidgets('renders search results correctly', (WidgetTester tester) async {
    final tracks = [
      JamendoTrack(
        id: '1',
        title: 'Free Music',
        artistName: 'Awesome Artist',
        albumName: 'Creative Album',
        durationSeconds: 180,
        audioUrl: 'https://example.com/audio.mp3',
        downloadUrl: 'https://example.com/download.mp3',
        imageUrl: '',
      ),
    ];

    when(() => mockJamendoVM.searchResults).thenReturn(tracks);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Free Music'), findsOneWidget);
    expect(find.text('Awesome Artist • Creative Album'), findsOneWidget);
  });
}
