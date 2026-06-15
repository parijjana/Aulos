import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/features/main/widgets/indexer_progress_overlay.dart';
import 'dart:typed_data';

class MockLibraryIndexerService extends Mock implements LibraryIndexerService {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}

void main() {
  late MockLibraryIndexerService mockIndexer;
  late MockSettingsViewModel mockSettingsVM;
  late MockPersistentLibraryService mockLibService;

  setUp(() {
    mockIndexer = MockLibraryIndexerService();
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    mockLibService = MockPersistentLibraryService();

    // Setup default stubbing
    when(() => mockIndexer.state).thenReturn(IndexerState.idle);
    when(() => mockIndexer.progress).thenReturn(0.0);
    when(() => mockIndexer.statusMessage).thenReturn('Idle');
    when(() => mockIndexer.lastFetchedArt).thenReturn(null);
    when(() => mockIndexer.foldersScanned).thenReturn(0);
    when(() => mockIndexer.filesDiscovered).thenReturn(0);
    when(() => mockIndexer.totalFilesStored).thenReturn(0);
    when(() => mockIndexer.addListener(any())).thenReturn(null);
    when(() => mockIndexer.removeListener(any())).thenReturn(null);

    when(() => mockSettingsVM.monitoredFolders).thenReturn([]);
    when(() => mockSettingsVM.addListener(any())).thenReturn(null);
    when(() => mockSettingsVM.removeListener(any())).thenReturn(null);

    when(() => mockIndexer.stopIndexer()).thenAnswer((_) async => {});
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<LibraryIndexerService>.value(value: mockIndexer),
            ChangeNotifierProvider<SettingsViewModel>.value(value: mockSettingsVM),
            Provider<PersistentLibraryService>.value(value: mockLibService),
          ],
          child: const Stack(
            children: [
              Positioned.fill(child: SizedBox()),
              IndexerProgressOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  group('IndexerProgressOverlay', () {
    testWidgets('should be hidden when indexer is idle', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Find the AnimatedPositioned by type
      final Finder positionedFinder = find.byType(AnimatedPositioned);
      expect(positionedFinder, findsOneWidget);

      final AnimatedPositioned positioned = tester.widget<AnimatedPositioned>(positionedFinder);
      // When idle, bottom is set to -100.0 (hidden)
      expect(positioned.bottom, -100.0);
    });

    testWidgets('should display status and progress when indexer is active', (tester) async {
      when(() => mockIndexer.state).thenReturn(IndexerState.scanning);
      when(() => mockIndexer.progress).thenReturn(0.45);
      when(() => mockIndexer.statusMessage).thenReturn('Scanning Music Folder...');

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final Finder positionedFinder = find.byType(AnimatedPositioned);
      final AnimatedPositioned positioned = tester.widget<AnimatedPositioned>(positionedFinder);
      expect(positioned.bottom, 16.0); // visible

      expect(find.text('SCANNING LIBRARY...'), findsOneWidget);
      expect(find.text('Scanning Music Folder...'), findsOneWidget);

      // Verify progress indicator is rendered
      final Finder progressIndicatorFinder = find.byType(CircularProgressIndicator);
      expect(progressIndicatorFinder, findsOneWidget);
      final CircularProgressIndicator progressIndicator = tester.widget<CircularProgressIndicator>(progressIndicatorFinder);
      expect(progressIndicator.value, 0.45);
    });

    testWidgets('should render artwork thumbnail if available', (tester) async {
      final fakeArtBytes = Uint8List.fromList([
        137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
        1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 204, 137, 0, 0, 0, 13, 73, 68,
        65, 84, 120, 156, 99, 96, 0, 0, 0, 2, 0, 1, 72, 175, 164, 113, 0, 0,
        0, 0, 73, 69, 78, 68, 174, 66, 96, 130
      ]);
      when(() => mockIndexer.state).thenReturn(IndexerState.hardening);
      when(() => mockIndexer.progress).thenReturn(0.8);
      when(() => mockIndexer.statusMessage).thenReturn('Fetching Taylor Swift photo...');
      when(() => mockIndexer.lastFetchedArt).thenReturn(fakeArtBytes);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should trigger stopIndexer when stop button is pressed', (tester) async {
      when(() => mockIndexer.state).thenReturn(IndexerState.scanning);
      when(() => mockIndexer.progress).thenReturn(0.1);
      when(() => mockIndexer.statusMessage).thenReturn('Scanning...');

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      final Finder stopButton = find.byIcon(Icons.stop_circle_outlined);
      expect(stopButton, findsOneWidget);

      await tester.tap(stopButton);
      await tester.pump(const Duration(milliseconds: 350));

      verify(() => mockIndexer.stopIndexer()).called(1);
    });

    testWidgets('tapping card should open bottom sheet with detailed stats', (tester) async {
      when(() => mockIndexer.state).thenReturn(IndexerState.hardening);
      when(() => mockIndexer.progress).thenReturn(0.5);
      when(() => mockIndexer.statusMessage).thenReturn('Syncing...');
      when(() => mockIndexer.foldersScanned).thenReturn(15);
      when(() => mockIndexer.filesDiscovered).thenReturn(150);
      when(() => mockIndexer.totalFilesStored).thenReturn(1000);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Tap the card to open sheet
      final Finder card = find.byKey(const Key('indexer_progress_card'));
      await tester.tap(card);
      await tester.pump(const Duration(milliseconds: 350));

      // Check bottom sheet text
      expect(find.text('BACKGROUND SYNC'), findsOneWidget);
      expect(find.text('15'), findsOneWidget); // Folders
      expect(find.text('150'), findsOneWidget); // Discovered
      expect(find.text('1000'), findsOneWidget); // Total
    });
  });
}
