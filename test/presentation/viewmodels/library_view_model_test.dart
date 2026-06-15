import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/database/audiobook_database.dart';
import 'package:aulos/data/database/playback_database.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/data/library/providers/audnexus_service.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:aulos/data/library/library_indexer_service.dart';

class MockPersistentLibraryService extends Mock implements PersistentLibraryServiceImpl {}
class MockConnectionManager extends Mock implements ConnectionManager {}
class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockAudnexusService extends Mock implements AudnexusService {}
class MockLibraryIndexerService extends Mock implements LibraryIndexerService {
  VoidCallback? listener;

  @override
  void addListener(VoidCallback listener) {
    this.listener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (this.listener == listener) {
      this.listener = null;
    }
  }
}

void main() {
  late LibraryViewModel viewModel;
  late MockPersistentLibraryService mockService;
  late MockConnectionManager mockConnectionManager;
  late MockSettingsViewModel mockSettingsVM;
  late MockAudnexusService mockAudnexus;
  late PlaybackDatabase playbackDb;
  late AppDatabase appDb;
  late AudiobookDatabase audiobookDb;

  setUp(() {
    mockService = MockPersistentLibraryService();
    mockConnectionManager = MockConnectionManager();
    mockSettingsVM = MockSettingsViewModel();
    when(() => mockSettingsVM.isFolderWatcherEnabled).thenReturn(true);
    mockAudnexus = MockAudnexusService();
    
    playbackDb = PlaybackDatabase.testing(NativeDatabase.memory());
    appDb = AppDatabase.testing(NativeDatabase.memory());
    audiobookDb = AudiobookDatabase.testing(NativeDatabase.memory());

    when(() => mockService.db).thenReturn(appDb);
    when(() => mockService.audiobookDb).thenReturn(audiobookDb);

    // Default stubs
    when(() => mockService.getRootFolders()).thenAnswer((_) async => []);
    when(() => mockService.getSubFolders(any())).thenAnswer((_) async => []);
    when(() => mockService.getArtists()).thenAnswer((_) async => []);
    when(() => mockService.getAlbums()).thenAnswer((_) async => []);
    when(() => mockService.getGenres()).thenAnswer((_) async => []);
    when(() => mockService.getYears()).thenAnswer((_) async => []);
    when(() => mockService.getPlaylists()).thenAnswer((_) async => []);
    when(() => mockAudnexus.getAuthorMetadata(any())).thenAnswer((_) async => null);
    
    when(() => mockSettingsVM.lastViewType).thenReturn(LibraryViewType.list);
    when(() => mockSettingsVM.libraryHubTabIndex).thenReturn(0);
    when(() => mockConnectionManager.remoteCommands).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectionManager.isClient).thenReturn(false);
    when(() => mockConnectionManager.addListener(any())).thenReturn(null);
    when(() => mockConnectionManager.removeListener(any())).thenReturn(null);

    viewModel = LibraryViewModel(
      libraryService: mockService,
      playbackDb: playbackDb,
      audnexus: mockAudnexus,
      connectionManager: mockConnectionManager,
      settingsVM: mockSettingsVM,
    );
  });

  tearDown(() async {
    await playbackDb.close();
    await appDb.close();
    await audiobookDb.close();
  });

  group('LibraryViewModel', () {
    test('selectItem(Folder) should update tracks', () async {
      final mockFolder = Folder(id: '1', path: '/music', name: 'Music', folderType: 0);
      final mockTracks = [
        Track(
          id: '1',
          path: '/music/1.mp3',
          title: 'Song 1',
          folderId: '1',
          artistId: '1',
          rating: 0,
          isFavorite: false,
          playCount: 0,
          isAudiobook: false,
          isPlayed: false,
        ),
      ];

      when(
        () => mockService.getTracksForFolder(any()),
      ).thenAnswer((_) async => mockTracks);

      await viewModel.selectItem(mockFolder);

      expect(viewModel.selectedItem, mockFolder);
      expect(viewModel.tracks, mockTracks);
      expect(viewModel.isAtRoot, isFalse);
    });

    test('enrichAudiobook should report progress and complete successfully', () async {
      // Seed data into appDb so update can run
      await appDb.into(appDb.artists).insert(
        ArtistsCompanion.insert(id: '1', name: 'Author 1'),
      );
      await appDb.into(appDb.albums).insert(
        AlbumsCompanion.insert(
          id: '1',
          name: 'Audiobook 1',
          artistId: const Value('1'),
          isAudiobook: const Value(true),
          isFavorite: const Value(false),
        ),
      );

      final mockAlbum = Album(
        id: '1',
        name: 'Audiobook 1',
        artistId: '1',
        coverArt: null,
        description: null,
        narrator: null,
        asin: '1234567890',
        isAudiobook: true,
        isFavorite: false,
        playCount: 0,
        isPlayed: false,
        isDownloadedViaAulos: false,
      );

      final meta = {
        'asin': '1234567890',
        'title': 'Audiobook 1',
        'description': 'Description',
        'authors': ['Author 1'],
        'narrators': ['Narrator 1'],
        'series': [
          {'name': 'Series 1', 'position': '1'}
        ],
        'image': 'http://example.com/image.jpg',
      };

      when(() => mockAudnexus.getBookMetadata(any())).thenAnswer((_) async => meta);
      when(() => mockAudnexus.getChapters(any())).thenAnswer((_) async => []);
      when(() => mockService.getChapters(any())).thenAnswer((_) async => []);
      
      final future = viewModel.enrichAudiobook(mockAlbum);
      
      expect(viewModel.isLoading, isTrue);
      await future;
      expect(viewModel.isLoading, isFalse);
    });

    test('goBack() should return to root', () async {
      final mockFolder = Folder(id: '1', path: '/music', name: 'Music', folderType: 0);
      when(() => mockService.getSubFolders(any())).thenAnswer((_) async => []);
      when(
        () => mockService.getTracksForFolder(any()),
      ).thenAnswer((_) async => []);

      await viewModel.selectItem(mockFolder);
      expect(viewModel.isAtRoot, isFalse);

      viewModel.goBack();

      expect(viewModel.isAtRoot, isTrue);
      expect(viewModel.selectedItem, isNull);
    });

    test('reloadLibrary() should clear caches of other modes and reload current mode', () async {
      final folder1 = Folder(id: '1', name: 'Folder 1', path: '/path1', folderType: 0);
      final artist1 = Artist(id: '1', name: 'Artist 1', isFavorite: false, playCount: 0);
      
      when(() => mockService.getRootFolders()).thenAnswer((_) async => [folder1]);
      when(() => mockService.getArtists()).thenAnswer((_) async => [artist1]);

      final testViewModel = LibraryViewModel(
        libraryService: mockService,
        playbackDb: playbackDb,
        audnexus: mockAudnexus,
        connectionManager: mockConnectionManager,
        settingsVM: mockSettingsVM,
      );

      expect(testViewModel.mode, LibraryMode.folders);
      while (testViewModel.isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(testViewModel.folders, contains(folder1));

      testViewModel.setMode(LibraryMode.artists);
      while (testViewModel.isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(testViewModel.artists, contains(artist1));

      final folder2 = Folder(id: '2', name: 'Folder 2', path: '/path2', folderType: 0);
      final artist2 = Artist(id: '2', name: 'Artist 2', isFavorite: false, playCount: 0);
      
      when(() => mockService.getRootFolders()).thenAnswer((_) async => [folder1, folder2]);
      when(() => mockService.getArtists()).thenAnswer((_) async => [artist1, artist2]);

      await testViewModel.reloadLibrary();
      expect(testViewModel.artists, contains(artist2));

      testViewModel.setMode(LibraryMode.folders);
      while (testViewModel.isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(testViewModel.folders, contains(folder2));
    });

    test('LibraryViewModel should listen to LibraryIndexerService and reload on finish', () async {
      final mockIndexer = MockLibraryIndexerService();
      when(() => mockIndexer.state).thenReturn(IndexerState.scanning);
      
      final folder1 = Folder(id: '1', name: 'Folder 1', path: '/path1', folderType: 0);
      when(() => mockService.getRootFolders()).thenAnswer((_) async => [folder1]);

      final vmWithIndexer = LibraryViewModel(
        libraryService: mockService,
        playbackDb: playbackDb,
        audnexus: mockAudnexus,
        connectionManager: mockConnectionManager,
        settingsVM: mockSettingsVM,
        indexerService: mockIndexer,
      );

      while (vmWithIndexer.isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      expect(vmWithIndexer.folders, contains(folder1));

      final folder2 = Folder(id: '2', name: 'Folder 2', path: '/path2', folderType: 0);
      when(() => mockService.getRootFolders()).thenAnswer((_) async => [folder1, folder2]);

      expect(mockIndexer.listener, isNotNull);
      
      when(() => mockIndexer.state).thenReturn(IndexerState.idle);
      mockIndexer.listener!();

      while (vmWithIndexer.isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }

      expect(vmWithIndexer.folders, contains(folder2));
    });
  });
}
