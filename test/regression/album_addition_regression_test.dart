import 'package:flutter_test/flutter_test.dart';
import 'package:localaudioplayer/data/database/app_database.dart';
import 'package:localaudioplayer/presentation/viewmodels/queue_view_model.dart';
import 'package:localaudioplayer/data/library/persistent_library_service.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}

void main() {
  late QueueViewModel viewModel;
  late MockPersistentLibraryService mockLibraryService;

  setUp(() {
    mockLibraryService = MockPersistentLibraryService();
    when(() => mockLibraryService.getQueue()).thenAnswer((_) async => []);
    when(() => mockLibraryService.saveQueue(any())).thenAnswer((_) async {});
    
    viewModel = QueueViewModel(libraryService: mockLibraryService);
  });

  group('Queue Regression: Album Addition', () {
    test('Adding an album to queue and skipping should work correctly', () async {
      final trackA = Track(id: 1, path: 'a.mp3', title: 'Song A', artistId: 1, albumId: 1, folderId: 1, rating: 0, isFavorite: false, playCount: 0);
      final track1 = Track(id: 2, path: '1.mp3', title: 'Song 1', artistId: 1, albumId: 2, folderId: 1, rating: 0, isFavorite: false, playCount: 0);
      final track2 = Track(id: 3, path: '2.mp3', title: 'Song 2', artistId: 1, albumId: 2, folderId: 1, rating: 0, isFavorite: false, playCount: 0);

      // 1. Set initial queue with Song A
      await viewModel.setQueue([trackA], startIndex: 0);
      expect(viewModel.currentIndex, 0);
      expect(viewModel.currentTrack, trackA);

      // 2. Add Album [Song 1, Song 2] to queue
      await viewModel.addAllToQueue([track1, track2]);
      expect(viewModel.currentQueue.length, 3);
      expect(viewModel.currentIndex, 0);

      // 3. Skip next (should go to Song 1)
      viewModel.skipNext();
      expect(viewModel.currentIndex, 1);
      expect(viewModel.currentTrack, track1);

      // 4. Skip next (should go to Song 2)
      viewModel.skipNext();
      expect(viewModel.currentIndex, 2);
      expect(viewModel.currentTrack, track2);
    });

    test('Adding an album to empty queue should work correctly', () async {
      final track1 = Track(id: 2, path: '1.mp3', title: 'Song 1', artistId: 1, albumId: 2, folderId: 1, rating: 0, isFavorite: false, playCount: 0);
      final track2 = Track(id: 3, path: '2.mp3', title: 'Song 2', artistId: 1, albumId: 2, folderId: 1, rating: 0, isFavorite: false, playCount: 0);

      // 1. Add Album [Song 1, Song 2] to empty queue
      await viewModel.addAllToQueue([track1, track2]);
      expect(viewModel.currentQueue.length, 2);
      expect(viewModel.currentIndex, -1); // Current index stays -1

      // 2. Skip next (should go to Song 1)
      viewModel.skipNext();
      expect(viewModel.currentIndex, 0);
      expect(viewModel.currentTrack, track1);
    });
  });
}
