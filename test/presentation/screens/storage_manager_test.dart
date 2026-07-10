import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/library/storage_manager_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/presentation/viewmodels/storage_cache_view_model.dart';

class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockAudiobookDatabase extends Mock implements AudiobookDatabase {}

void main() {
  late MockSettingsViewModel mockSettingsVM;
  late MockAudiobookDatabase mockAudiobookDb;
  late StorageManagerService storageService;
  late StorageCacheViewModel viewModel;
  late Directory tempDir;

  setUp(() async {
    mockSettingsVM = MockSettingsViewModel();
    mockAudiobookDb = MockAudiobookDatabase();
    
    // Create a real temp directory for size calculations
    tempDir = await Directory.systemTemp.createTempSync('aulos_storage_test');

    // Create subfolders for podcasts and audiobooks
    final podcastDir = Directory(p.join(tempDir.path, 'Podcasts'));
    final audiobookDir = Directory(p.join(tempDir.path, 'Audiobooks'));
    await podcastDir.create(recursive: true);
    await audiobookDir.create(recursive: true);

    // Create mock files with exact sizes
    final file1 = File(p.join(podcastDir.path, 'episode1.mp3'));
    await file1.writeAsBytes(List.generate(1024, (index) => 0)); // 1 KB

    final file2 = File(p.join(audiobookDir.path, 'chapter1.m4b'));
    await file2.writeAsBytes(List.generate(2048, (index) => 0)); // 2 KB

    // Set mock expectations
    when(() => mockSettingsVM.podcastStorageLocation).thenReturn(podcastDir.path);
    when(() => mockAudiobookDb.getRootFolders()).thenAnswer((_) async => []);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('StorageManagerService calculates directory sizes correctly', () async {
    // We override getRootFolders to return our temp audiobook directory path
    when(() => mockAudiobookDb.getRootFolders()).thenAnswer((_) async => [
      AudiobookFolder(
        id: 'root_audiobooks',
        path: tempDir.path + '/Audiobooks',
        name: 'Audiobooks',
      )
    ]);

    storageService = StorageManagerService(
      settingsVM: mockSettingsVM,
      audiobookDb: mockAudiobookDb,
    );

    final podcastSize = await storageService.getPodcastCacheSize();
    final audiobookSize = await storageService.getAudiobookCacheSize();

    expect(podcastSize, 1024); // 1 KB
    expect(audiobookSize, 2048); // 2 KB
  });

  test('StorageCacheViewModel exposes sizes and updates loading state', () async {
    when(() => mockAudiobookDb.getRootFolders()).thenAnswer((_) async => [
      AudiobookFolder(
        id: 'root_audiobooks',
        path: tempDir.path + '/Audiobooks',
        name: 'Audiobooks',
      )
    ]);

    storageService = StorageManagerService(
      settingsVM: mockSettingsVM,
      audiobookDb: mockAudiobookDb,
    );

    viewModel = StorageCacheViewModel(storageService);

    // Wait for the initial refresh in constructor to finish
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.podcastSize, 1024);
    expect(viewModel.audiobookSize, 2048);
    expect(viewModel.totalSize, 3072);
  });
}
