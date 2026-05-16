import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:localaudioplayer/domain/library/library_service.dart';

class MockLibraryService extends Mock implements LibraryService {}

void main() {
  late MockLibraryService mockLibrary;

  setUp(() {
    mockLibrary = MockLibraryService();
  });

  group('LibraryService Interface', () {
    test('should scan a directory and return audio files', () async {
      final mockFiles = [
        AudioFile(
          path: 'path/to/song1.mp3',
          title: 'Song 1',
          artist: 'Artist 1',
        ),
        AudioFile(
          path: 'path/to/song2.mp3',
          title: 'Song 2',
          artist: 'Artist 2',
        ),
      ];

      when(
        () => mockLibrary.scanDirectory('path/to/dir'),
      ).thenAnswer((_) async => mockFiles);

      final result = await mockLibrary.scanDirectory('path/to/dir');

      expect(result, mockFiles);
      verify(() => mockLibrary.scanDirectory('path/to/dir')).called(1);
    });
  });
}
