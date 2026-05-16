import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localaudioplayer/data/library/library_indexer_service.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/artwork_service.dart';
import 'package:localaudioplayer/data/library/ensemble_artwork_service.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'dart:typed_data';
import 'package:drift/drift.dart';

class MockArtworkService extends Mock implements ArtworkService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}
class MockEnsembleArtworkService extends Mock implements EnsembleArtworkService {}

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
      await db.into(db.folders).insert(FoldersCompanion.insert(path: '/music/Artist 1/Album 1', name: 'Album 1'));
      await db.into(db.tracks).insert(TracksCompanion.insert(
        path: '/music/Artist 1/Album 1/song.mp3',
        title: 'Song',
        folderId: 1,
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
  });
}
