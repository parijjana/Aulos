import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aulos/data/library/librivox_service.dart';
import 'package:aulos/data/library/librivox_book_downloader.dart';
import 'package:aulos/presentation/viewmodels/librivox_view_model.dart';
import 'package:aulos/domain/library/librivox_book.dart';
import 'package:aulos/domain/network/log_service.dart';

class MockLibriVoxService extends Mock implements LibriVoxService {}
class MockLibriVoxBookDownloader extends Mock implements LibriVoxBookDownloader {}

void main() {
  late LibriVoxViewModel viewModel;
  late MockLibriVoxService mockService;
  late MockLibriVoxBookDownloader mockDownloader;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(LibriVoxBook(
      id: 'fallback',
      title: 'Fallback',
      description: 'Fallback',
      urlZipFile: '',
      urlRss: '',
      authors: [],
      totalTimeSecs: 0,
      language: 'English',
      narrators: [],
    ));
  });

  setUp(() {
    mockService = MockLibriVoxService();
    mockDownloader = MockLibriVoxBookDownloader();
    
    // Default stubbing
    when(() => mockDownloader.streamBook(any())).thenAnswer((_) async {});
    when(() => mockDownloader.downloadBook(any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async {});

    viewModel = LibriVoxViewModel(
      service: mockService,
      downloader: mockDownloader,
      logService: NoOpLogService(),
    );
  });

  group('LibriVoxViewModel Tests', () {
    test('notifyListeners should not throw when called after dispose', () {
      viewModel.dispose();
      expect(() => viewModel.notifyListeners(), returnsNormally);
    });

    test('downloadBook should set error state when download throws exception', () async {
      final book = LibriVoxBook(
        id: '123',
        title: 'Failing Book',
        description: 'A book that fails download',
        urlZipFile: 'https://example.com/fail.zip',
        urlRss: 'https://example.com/rss',
        authors: [LibriVoxAuthor(id: '1', firstName: 'Author', lastName: 'Name')],
        totalTimeSecs: 100,
        language: 'English',
        narrators: const [],
      );

      // Stub downloader to throw an exception
      when(() => mockDownloader.downloadBook(any(), onProgress: any(named: 'onProgress')))
          .thenThrow(Exception('Network disconnected'));

      expect(viewModel.error, isNull);

      await viewModel.downloadBook(book);

      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('Network disconnected'));
    });

    test('filteredResults should filter by title, author names, and narrators', () async {
      final book1 = LibriVoxBook(
        id: '1',
        title: 'Moby Dick',
        description: 'Description',
        urlZipFile: 'zip',
        urlRss: 'rss',
        authors: [LibriVoxAuthor(id: '1', firstName: 'Herman', lastName: 'Melville')],
        totalTimeSecs: 100,
        language: 'English',
        narrators: const ['John Doe'],
      );
      final book2 = LibriVoxBook(
        id: '2',
        title: 'The Odyssey',
        description: 'Description',
        urlZipFile: 'zip',
        urlRss: 'rss',
        authors: [LibriVoxAuthor(id: '2', firstName: 'Homer', lastName: '')],
        totalTimeSecs: 100,
        language: 'English',
        narrators: const ['Jane Smith'],
      );

      when(() => mockService.searchBooks(any())).thenAnswer((_) async => [book1, book2]);

      // Call search
      await viewModel.search('query');

      // Filter query is empty initially, returns all
      expect(viewModel.filteredResults.length, equals(2));

      // Filter by title
      viewModel.setFilterQuery('Moby');
      expect(viewModel.filteredResults.length, equals(1));
      expect(viewModel.filteredResults.first.id, equals('1'));

      // Filter by author
      viewModel.setFilterQuery('Homer');
      expect(viewModel.filteredResults.length, equals(1));
      expect(viewModel.filteredResults.first.id, equals('2'));

      // Filter by narrator/voice artist (Jane)
      viewModel.setFilterQuery('Jane');
      expect(viewModel.filteredResults.length, equals(1));
      expect(viewModel.filteredResults.first.id, equals('2'));

      // Filter by narrator case-insensitive (john)
      viewModel.setFilterQuery('john');
      expect(viewModel.filteredResults.length, equals(1));
      expect(viewModel.filteredResults.first.id, equals('1'));

      // Empty query should reset and return all
      viewModel.setFilterQuery('');
      expect(viewModel.filteredResults.length, equals(2));
    });
  });
}
