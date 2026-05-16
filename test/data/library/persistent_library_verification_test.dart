import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:localaudioplayer/domain/library/library_service.dart';
import 'package:drift/native.dart';

class MockLibraryScanner extends Mock implements LibraryService {}

void main() {
  late AppDatabase db;
  late MockLibraryScanner mockScanner;
  late PersistentLibraryServiceImpl service;

  setUp(() {
    db = AppDatabase.testing(NativeDatabase.memory());
    mockScanner = MockLibraryScanner();
    service = PersistentLibraryServiceImpl(db: db, scanner: mockScanner);
  });

  tearDown(() async {
    await db.close();
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
        () => mockScanner.scanDirectory(any()),
      ).thenAnswer((_) async => mockFiles);

      await service.importFolder('C:\\Music');

      final folders = await service.getFolders();
      expect(folders.length, 1);
      expect(folders.first.name, 'Music');

      final tracks = await service.getTracksForFolder(folders.first.id);
      expect(tracks.length, 1);
      expect(tracks.first.title, 'Title 1');
    });
  });
}
