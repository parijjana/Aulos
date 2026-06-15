import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:drift/native.dart';

class MockLibraryScanner extends Mock implements LibraryService {}

void main() {
  late AppDatabase db;
  late AudiobookDatabase audiobookDb;
  late MockLibraryScanner mockScanner;
  late PersistentLibraryServiceImpl service;

  setUpAll(() {
    registerFallbackValue(<String>{});
  });

  setUp(() {
    db = AppDatabase.testing(NativeDatabase.memory());
    audiobookDb = AudiobookDatabase.testing(NativeDatabase.memory());
    mockScanner = MockLibraryScanner();
    service = PersistentLibraryServiceImpl(
      db: db,
      audiobookDb: audiobookDb,
      scanner: mockScanner,
    );
  });

  tearDown(() async {
    await db.close();
    await audiobookDb.close();
  });

  group('PersistentLibraryService Verification', () {
    test('importFolder() should create folder and tracks entries', () async {
      final mockFiles = [
        AudioFile(
          path: 'C:\\Music\\p1.mp3',
          title: 'Title 1',
          artist: 'Artist 1',
        ),
      ];
      when(
        () => mockScanner.scanDirectory(any(), existingPaths: any(named: 'existingPaths')),
      ).thenAnswer((_) async => mockFiles);

      await service.importFolder('C:\\Music');

      final folders = await service.getFolders();
      expect(folders.length, 1);
      expect(folders.first.name, 'Music');

      final tracks = await service.getTracksForFolder(folders.first.id);
      expect(tracks.length, 1);
      expect(tracks.first.title, 'Title 1');
    });

    test('getRootFolders() and getSubFolders() should filter by folderType', () async {
      final musicFolderId = await db.ensureFolder('/music', folderType: 0);
      final audiobookFolderId = await audiobookDb.ensureFolder('/audiobooks');

      // Create subfolders
      await db.ensureFolder('/music/rock', parentId: musicFolderId, folderType: 0);
      await audiobookDb.ensureFolder('/audiobooks/fantasy', parentId: audiobookFolderId);

      // Query root folders
      final rootMusic = await service.getRootFolders(folderType: 0);
      final rootAudiobook = await service.getRootFolders(folderType: 1);

      expect(rootMusic.length, 1);
      expect(rootMusic.first.name, 'music');

      expect(rootAudiobook.length, 1);
      expect(rootAudiobook.first.name, 'audiobooks');

      // Query subfolders
      final subMusic = await service.getSubFolders(musicFolderId, folderType: 0);
      final subAudiobook = await service.getSubFolders(audiobookFolderId, folderType: 1);

      expect(subMusic.length, 1);
      expect(subMusic.first.name, 'rock');

      expect(subAudiobook.length, 1);
      expect(subAudiobook.first.name, 'fantasy');
    });
  });
}
