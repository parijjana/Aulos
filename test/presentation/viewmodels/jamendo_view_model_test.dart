import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/data/database/app_database.dart';
import 'package:aulos/data/library/jamendo_service.dart';
import 'package:aulos/data/library/jamendo_track_downloader.dart';
import 'package:aulos/presentation/viewmodels/jamendo_view_model.dart';
import 'package:aulos/domain/library/jamendo_track.dart';

class MockJamendoService extends Mock implements JamendoService {}
class MockJamendoTrackDownloader extends Mock implements JamendoTrackDownloader {}

void main() {
  late JamendoViewModel viewModel;
  late MockJamendoService mockService;
  late MockJamendoTrackDownloader mockDownloader;

  setUpAll(() {
    registerFallbackValue(JamendoTrack(
      id: 'fallback',
      title: 'Fallback',
      artistName: 'Fallback',
      albumName: 'Fallback',
      durationSeconds: 0,
      audioUrl: '',
      downloadUrl: '',
      imageUrl: '',
    ));
  });

  setUp(() {
    mockService = MockJamendoService();
    mockDownloader = MockJamendoTrackDownloader();
    viewModel = JamendoViewModel(
      service: mockService,
      downloader: mockDownloader,
    );
  });

  group('JamendoViewModel', () {
    test('search tracks updates results and state', () async {
      final tracks = [
        JamendoTrack(
          id: '1',
          title: 'Track Title',
          artistName: 'Artist Name',
          albumName: 'Album Name',
          durationSeconds: 120,
          audioUrl: 'https://example.com/stream.mp3',
          downloadUrl: 'https://example.com/download.mp3',
          imageUrl: '',
        )
      ];

      when(() => mockService.searchTracks(any())).thenAnswer((_) async => tracks);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.searchResults, isEmpty);

      final future = viewModel.search('jazz');
      expect(viewModel.isLoading, isTrue);

      await future;
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.searchResults, tracks);
      expect(viewModel.lastSearchQuery, 'jazz');
    });

    test('streamTrack delegates to downloader and returns track', () async {
      final jamendoTrack = JamendoTrack(
        id: '1',
        title: 'Track Title',
        artistName: 'Artist Name',
        albumName: 'Album Name',
        durationSeconds: 120,
        audioUrl: 'https://example.com/stream.mp3',
        downloadUrl: 'https://example.com/download.mp3',
        imageUrl: '',
      );

      final mockTrack = Track(
        id: '1',
        path: 'https://example.com/stream.mp3',
        title: 'Track Title',
        artistId: '1',
        albumId: '1',
        folderId: '1',
        isAudiobook: false,
        isStream: true,
        durationSeconds: 120,
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isPlayed: false,
      );

      when(() => mockDownloader.streamTrack(any())).thenAnswer((_) async => mockTrack);

      final result = await viewModel.streamTrack(jamendoTrack);

      expect(result.title, equals('Track Title'));
      expect(result.path, equals('https://example.com/stream.mp3'));
      expect(result.isStream, isTrue);
      verify(() => mockDownloader.streamTrack(jamendoTrack)).called(1);
    });

    test('downloadTrack delegates to downloader and updates progress', () async {
      final jamendoTrack = JamendoTrack(
        id: '1',
        title: 'Track Title',
        artistName: 'Artist Name',
        albumName: 'Album Name',
        durationSeconds: 120,
        audioUrl: 'https://example.com/stream.mp3',
        downloadUrl: 'https://example.com/download.mp3',
        imageUrl: '',
      );

      final mockTrack = Track(
        id: '1',
        path: 'local/path/track.mp3',
        title: 'Track Title',
        artistId: '1',
        albumId: '1',
        folderId: '1',
        isAudiobook: false,
        isStream: false,
        durationSeconds: 120,
        rating: 0,
        isFavorite: false,
        playCount: 0,
        isPlayed: false,
      );

      when(() => mockDownloader.downloadTrack(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((invocation) async {
            final onProgress = invocation.namedArguments[#onProgress] as void Function(double);
            onProgress(0.5);
            onProgress(1.0);
            return mockTrack;
          });

      expect(viewModel.downloadProgress[jamendoTrack.id], isNull);

      final result = await viewModel.downloadTrack(jamendoTrack);

      expect(result.isStream, isFalse);
      expect(result.path, equals('local/path/track.mp3'));
      expect(viewModel.downloadProgress[jamendoTrack.id], isNull); // removed after completion
      verify(() => mockDownloader.downloadTrack(jamendoTrack, onProgress: any(named: 'onProgress'))).called(1);
    });
  });
}
