import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/library_view_model.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/domain/library/library_service.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/presentation/viewmodels/settings_view_model.dart';

class MockPersistentLibraryService extends Mock
    implements PersistentLibraryServiceImpl {}

class MockScanner extends Mock implements LibraryService {}

class MockConnectionManager extends Mock implements ConnectionManager {}

class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late LibraryViewModel viewModel;
  late MockPersistentLibraryService mockService;
  late MockConnectionManager mockConnectionManager;
  late MockSettingsViewModel mockSettingsVM;

  setUp(() {
    mockService = MockPersistentLibraryService();
    mockConnectionManager = MockConnectionManager();
    mockSettingsVM = MockSettingsViewModel();

    // Default stubs
    when(() => mockService.getRootFolders()).thenAnswer((_) async => []);
    when(() => mockService.getArtists()).thenAnswer((_) async => []);
    when(() => mockService.getAlbums()).thenAnswer((_) async => []);
    when(() => mockService.getGenres()).thenAnswer((_) async => []);
    when(() => mockService.getYears()).thenAnswer((_) async => []);
    when(() => mockService.getPlaylists()).thenAnswer((_) async => []);
    
    when(() => mockSettingsVM.lastViewType).thenReturn(LibraryViewType.list);
    when(() => mockSettingsVM.libraryHubTabIndex).thenReturn(0);
    when(() => mockConnectionManager.remoteCommands).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectionManager.isClient).thenReturn(false);
    when(() => mockConnectionManager.addListener(any())).thenReturn(null);
    when(() => mockConnectionManager.removeListener(any())).thenReturn(null);

    viewModel = LibraryViewModel(
      libraryService: mockService,
      connectionManager: mockConnectionManager,
      settingsVM: mockSettingsVM,
    );
  });

  group('LibraryViewModel', () {
    test('selectItem(Folder) should update tracks', () async {
      final mockFolder = Folder(id: 1, path: '/music', name: 'Music');
      final mockTracks = [
        Track(
          id: 1,
          path: '/music/1.mp3',
          title: 'Song 1',
          folderId: 1,
          artistId: 1,
          rating: 0,
          isFavorite: false,
          playCount: 0,
        ),
      ];

      when(() => mockService.getSubFolders(any())).thenAnswer((_) async => []);
      when(
        () => mockService.getTracksForFolder(any()),
      ).thenAnswer((_) async => mockTracks);

      await viewModel.selectItem(mockFolder);

      expect(viewModel.tracks, mockTracks);
      expect(viewModel.selectedItem, mockFolder);
      expect(viewModel.isAtRoot, isFalse);
    });

    test('isLoading should be true during loading', () async {
      final mockFolder = Folder(id: 1, path: '/music', name: 'Music');
      when(() => mockService.getSubFolders(any())).thenAnswer((_) async => []);
      when(() => mockService.getTracksForFolder(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return [];
      });

      final future = viewModel.selectItem(mockFolder);
      expect(viewModel.isLoading, isTrue);

      await future;
      expect(viewModel.isLoading, isFalse);
    });

    test('goBack() should return to root', () async {
      final mockFolder = Folder(id: 1, path: '/music', name: 'Music');
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
  });
}
