import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/domain/library/librivox_book.dart';

void main() {
  group('LibriVoxBook parsing and sanitization tests', () {
    test('should parse book details, collect unique narrators, and sanitize description', () {
      final json = {
        'id': '12345',
        'title': 'The Odyssey',
        'description': '<p>The <i>Odyssey</i> is one of two major ancient Greek epic poems...</p> <br/> &amp; it is wonderful.',
        'totaltimesecs': '3600',
        'authors': [
          {'id': '1', 'first_name': 'Homer', 'last_name': ''}
        ],
        'url_rss': 'https://example.com/rss',
        'url_zip_file': 'https://example.com/zip',
        'language': 'English',
        'sections': [
          {
            'id': '1',
            'readers': [
              {'reader_id': '10', 'display_name': 'John Doe'},
              {'reader_id': '11', 'display_name': 'Jane Smith'}
            ]
          },
          {
            'id': '2',
            'readers': [
              {'reader_id': '10', 'display_name': 'John Doe'},
              {'reader_id': '12', 'display_name': 'Bob Johnson'}
            ]
          }
        ]
      };

      final book = LibriVoxBook.fromJson(json);

      expect(book.id, equals('12345'));
      expect(book.title, equals('The Odyssey'));
      // Verify description is sanitized
      expect(book.description, equals('The Odyssey is one of two major ancient Greek epic poems...\n& it is wonderful.'));
      
      // Verify narrators list
      expect(book.narrators, containsAll(['Bob Johnson', 'Jane Smith', 'John Doe']));
      expect(book.narrators.length, equals(3));
    });
  });
}
