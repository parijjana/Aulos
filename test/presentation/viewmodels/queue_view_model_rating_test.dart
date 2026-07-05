import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/presentation/viewmodels/queue_view_model.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/library/persistent_library_service.dart';
import 'package:aulos/domain/network/connection_manager.dart';
import 'package:aulos/domain/network/socket_service.dart';

class MockConnectionManager extends Mock implements ConnectionManager {}
class MockPersistentLibraryService extends Mock implements PersistentLibraryService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      MediaCommand(type: CommandType.play, payload: null),
    );
  });

  late QueueViewModel queueVM;
  late MockConnectionManager mockConnectionManager;
  late MockPersistentLibraryService mockLibService;

  setUp(() {
    mockConnectionManager = MockConnectionManager();
    mockLibService = MockPersistentLibraryService();

    when(() => mockConnectionManager.remoteCommands).thenAnswer((_) => const Stream.empty());
    when(() => mockConnectionManager.isHost).thenReturn(false);
    when(() => mockConnectionManager.isClient).thenReturn(false);
    when(() => mockConnectionManager.sendCommand(any())).thenAnswer((_) async => {});

    when(() => mockLibService.getQueue()).thenAnswer((_) async => <Track>[]);
    when(() => mockLibService.saveQueue(any())).thenAnswer((_) async => {});

    queueVM = QueueViewModel(
      libraryService: mockLibService,
      connectionManager: mockConnectionManager,
    );
  });

  group('QueueViewModel Ratings Toggling', () {
    test('updateRating should set rating and toggle to 0 if updated with same rating', () async {
      final track = Track(
        id: '1',
        path: 'song.mp3',
        title: 'Song',
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      // Set up queue with the track
      await queueVM.setQueue([track]);

      when(() => mockLibService.updateRating('1', 1)).thenAnswer((_) async => {});
      when(() => mockLibService.updateRating('1', 0)).thenAnswer((_) async => {});

      // 1. Initial rating is 0. Update to 1 -> rating becomes 1
      await queueVM.updateRating('1', 1);
      expect(queueVM.currentQueue[0].rating, 1);
      verify(() => mockLibService.updateRating('1', 1)).called(1);

      // 2. Rating is now 1. Update to 1 again -> rating toggles back to 0
      await queueVM.updateRating('1', 1);
      expect(queueVM.currentQueue[0].rating, 0);
      verify(() => mockLibService.updateRating('1', 0)).called(1);
    });

    test('updateRating should toggle dislike (-1) to 0', () async {
      final track = Track(
        id: '2',
        path: 'song2.mp3',
        title: 'Song 2',
        folderId: '1',
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isAudiobook: false,
        isPlayed: false,
      );

      await queueVM.setQueue([track]);

      when(() => mockLibService.updateRating('2', -1)).thenAnswer((_) async => {});
      when(() => mockLibService.updateRating('2', 0)).thenAnswer((_) async => {});

      // 1. Update to -1 -> rating becomes -1
      await queueVM.updateRating('2', -1);
      expect(queueVM.currentQueue[0].rating, -1);
      verify(() => mockLibService.updateRating('2', -1)).called(1);

      // 2. Update to -1 again -> rating toggles back to 0
      await queueVM.updateRating('2', -1);
      expect(queueVM.currentQueue[0].rating, 0);
      verify(() => mockLibService.updateRating('2', 0)).called(1);
    });
  });
}
