import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/data/library/library_indexer_service.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/library/artwork_service.dart';
import 'package:aulos/data/library/ensemble_artwork_service.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'dart:typed_data';
import 'package:drift/drift.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/domain/network/log_service.dart';

class MockArtworkService extends Mock implements ArtworkService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}
class MockEnsembleArtworkService extends Mock implements EnsembleArtworkService {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockLogService extends Mock implements LogService {}

void main() {
  late AppDatabase db;
  late MockSharedPreferences mockPrefs;
  late MockArtworkService mockArtworkService;
  late MockPersistentLibraryService mockLibraryService;
  late MockEnsembleArtworkService mockEnsembleService;
  late LibraryIndexerService indexerService;

  setUpAll(() {
    registerFallbackValue(Uint8List.fromList([]));
  });

  setUp(() {
    db = AppDatabase.testing(NativeDatabase.memory());
    mockPrefs = MockSharedPreferences();
    mockArtworkService = MockArtworkService();
    mockLibraryService = MockPersistentLibraryService();
    mockEnsembleService = MockEnsembleArtworkService();

    when(() => mockPrefs.getInt(any())).thenReturn(0);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
    when(() => mockEnsembleService.isEnsemble(any())).thenReturn(false);

    indexerService = LibraryIndexerService(
      db: db,
      prefs: mockPrefs,
      artworkService: mockArtworkService,
      ensembleService: mockEnsembleService,
      logService: NoOpLogService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LibraryIndexerService - fetchMissingMetadata', () {
    test('should report progress correctly for missing artwork and photos', () async {
      // Arrange
      final artistId = await db.ensureArtist('Artist 1');
      final albumId = await db.ensureAlbum('Album 1', artistId);
      
      // Add a track to the album so it can resolve a local folder
      await db.into(db.folders).insert(FoldersCompanion.insert(id: 'folder_album_1', path: '/music/Artist 1/Album 1', name: 'Album 1'));
      await db.into(db.tracks).insert(TracksCompanion.insert(
        id: 'song_track_1',
        path: '/music/Artist 1/Album 1/song.mp3',
        title: 'Song',
        folderId: 'folder_album_1',
        artistId: Value(artistId),
        albumId: Value(albumId),
      ));

      final dummyArt = Uint8List.fromList([1, 2, 3]);
      final dummyPhoto = Uint8List.fromList([4, 5, 6]);

      when(() => mockLibraryService.getAlbums()).thenAnswer((_) async => db.getAllAlbums());
    when(() => mockArtworkService.fetchAlbumArt(any(), any(), localFolder: any(named: 'localFolder')))
          .thenAnswer((_) async => dummyArt);
    when(() => mockArtworkService.fetchArtistPhoto(any(), localFolder: any(named: 'localFolder')))
          .thenAnswer((_) async => dummyPhoto);
    when(() => mockArtworkService.tryGetLocalArtwork(any())).thenAnswer((_) async => null);
    when(() => mockArtworkService.tryGetLocalArtistPhoto(any())).thenAnswer((_) async => null);
    when(() => mockArtworkService.extractEmbeddedArtwork(any())).thenAnswer((_) async => null);
    when(() => mockLibraryService.updateAlbumArt(any(), any())).thenAnswer((_) async {});
    when(() => mockLibraryService.updateArtistPhoto(any(), any())).thenAnswer((_) async {});

      // Act
      final progressValues = <double>[];
      indexerService.addListener(() {
        progressValues.add(indexerService.progress);
      });

      await indexerService.fetchMissingMetadata(mockLibraryService);

      // Assert
      expect(indexerService.state, IndexerState.idle);
      expect(indexerService.progress, 1.0);
      expect(indexerService.lastFetchedArt, dummyPhoto); 
      
      // totalTasks = 1 (art) + 1 (photo) = 2.
      // Progress steps: 0.0 (start), 0.5 (after art), 1.0 (after photo), 1.0 (idle)
      expect(progressValues, contains(0.5));
      expect(progressValues, contains(1.0));
      
      verify(() => mockArtworkService.fetchAlbumArt('Artist 1', 'Album 1', localFolder: '/music/Artist 1/Album 1')).called(1);
      verify(() => mockArtworkService.fetchArtistPhoto('Artist 1', localFolder: '/music/Artist 1')).called(1);
    });

    test('should handle no missing metadata gracefully', () async {
      // Arrange
      when(() => mockLibraryService.getAlbums()).thenAnswer((_) async => []);
      
      // Act
      await indexerService.fetchMissingMetadata(mockLibraryService);

      // Assert
      expect(indexerService.state, IndexerState.idle);
      expect(indexerService.progress, 1.0);
      expect(indexerService.statusMessage, contains('already up to date'));
    });

    test('should ignore audiobooks and audiobook-only authors during fetchMissingMetadata', () async {
      // Arrange
      final authorId = await db.ensureArtist('Author 1');
      final audiobookId = await db.ensureAlbum('Audiobook 1', authorId, isAudiobook: true);
      
      await db.into(db.folders).insert(FoldersCompanion.insert(id: 'folder_audiobook_1', path: '/audiobooks/Author 1/Audiobook 1', name: 'Audiobook 1'));
      await db.into(db.tracks).insert(TracksCompanion.insert(
        id: 'audiobook_track_1',
        path: '/audiobooks/Author 1/Audiobook 1/chapter1.mp3',
        title: 'Chapter 1',
        folderId: 'folder_audiobook_1',
        artistId: Value(authorId),
        albumId: Value(audiobookId),
      ));

      when(() => mockLibraryService.getAlbums()).thenAnswer((_) async => db.getAllAlbums());

      // Act
      await indexerService.fetchMissingMetadata(mockLibraryService);

      // Assert
      expect(indexerService.state, IndexerState.idle);
      expect(indexerService.progress, 1.0);
      expect(indexerService.statusMessage, contains('already up to date'));
      
      // Verify no MusicBrainz lookup or download attempt was made for the audiobook or author
      verifyNever(() => mockArtworkService.fetchAlbumArt(any(), any(), localFolder: any(named: 'localFolder')));
      verifyNever(() => mockArtworkService.fetchArtistPhoto(any(), localFolder: any(named: 'localFolder')));
    });

    test('updateWatcherSubscriptions should safely exit when settingsVM is null', () {
      expect(() => indexerService.updateWatcherSubscriptions(), returnsNormally);
    });

    test('notifyListeners should not throw when called after dispose', () {
      indexerService.dispose();
      expect(() => indexerService.notifyListeners(), returnsNormally);
    });

    test('rebuildFromScratch should set shouldPause and wait for idle state if currently scanning', () async {
      // Set service state to scanning manually
      // Since _state is private, we can trigger scanLibrary on an empty folder list to set state
      // or we can simulate it. But wait, we can run a scan that takes a bit of time.
      // Alternatively, let's trigger scanLibrary with a custom library service that delays,
      // and while it is scanning, call rebuildFromScratch.
      
      final folders = ['/music/folder'];
      when(() => mockLibraryService.importFolder(any(), folderType: any(named: 'folderType'), onFileFound: any(named: 'onFileFound')))
          .thenAnswer((_) async => Future.delayed(const Duration(milliseconds: 200)));

      // Start scanLibrary in background
      final scanFuture = indexerService.scanLibrary(folders, mockLibraryService);
      expect(indexerService.state, IndexerState.scanning);

      // Now call rebuildFromScratch which should wait for it to stop
      final rebuildFuture = indexerService.rebuildFromScratch();
      
      await scanFuture;
      await rebuildFuture;
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(indexerService.state, IndexerState.idle);
    });

    test('does not recreate watchers when unrelated settings change', () {
      final mockSettings = MockSettingsViewModel();
      final mockLog = MockLogService();
      
      when(() => mockSettings.isFolderWatcherEnabled).thenReturn(true);
      when(() => mockSettings.monitoredFolders).thenReturn(['/music/folder']);
      when(() => mockSettings.audiobookFolders).thenReturn(['/audiobooks/folder']);
      when(() => mockSettings.addListener(any())).thenReturn(null);
      
      when(() => mockLog.log(any())).thenReturn(null);

      // Create directories to pass dir.existsSync() check
      final tempDir = Directory.systemTemp.createTempSync();
      final musicPath = '${tempDir.path}/music';
      final audioPath = '${tempDir.path}/audiobooks';
      Directory(musicPath).createSync();
      Directory(audioPath).createSync();

      when(() => mockSettings.monitoredFolders).thenReturn([musicPath]);
      when(() => mockSettings.audiobookFolders).thenReturn([audioPath]);

      final indexer = LibraryIndexerService(
        db: db,
        prefs: mockPrefs,
        artworkService: mockArtworkService,
        ensembleService: mockEnsembleService,
        logService: mockLog,
        settingsVM: mockSettings,
        libService: mockLibraryService,
      );

      // Initial watchers start: should log 2 watcher starts
      verify(() => mockLog.log(any(that: contains('Starting filesystem watcher')))).called(2);

      // Now capture the listener that was added
      final capturedListener = verify(() => mockSettings.addListener(captureAny())).captured.first as VoidCallback;

      // Trigger setting changed without changing folder paths or watcher status
      capturedListener();

      // Verify no additional watcher starts were logged after the setting change trigger
      verifyNever(() => mockLog.log(any(that: contains('Starting filesystem watcher'))));

      // Cleanup
      tempDir.deleteSync(recursive: true);
    });
  });
}
