import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/core/utils/text_sanitizer.dart';

void main() {
  group('TextSanitizer Tests', () {
    test('should return empty string for empty input', () {
      expect(TextSanitizer.sanitize(''), equals(''));
    });

    test('should remove basic HTML tags', () {
      final input = '<p>This is a <b>bold</b> text.</p>';
      final expected = 'This is a bold text.';
      expect(TextSanitizer.sanitize(input), equals(expected));
    });

    test('should remove HTML tags with attributes', () {
      final input = 'Click <a href="http://example.com" target="_blank">here</a> to view.';
      final expected = 'Click here to view.';
      expect(TextSanitizer.sanitize(input), equals(expected));
    });

    test('should decode common HTML entities', () {
      final input = 'Fish &amp; Chips &quot;special&#39;s&quot; &lt; \$5 &gt; &nbsp; today!';
      final expected = "Fish & Chips \"special's\" < \$5 > today!";
      expect(TextSanitizer.sanitize(input), equals(expected));
    });

    test('should normalize duplicate whitespaces and multiple consecutive newlines', () {
      final input = '  Hello   World! \n\n\n Keep  it   clean.  ';
      final expected = 'Hello World!\n\nKeep it clean.';
      expect(TextSanitizer.sanitize(input), equals(expected));
    });

    test('should handle XML/HTML elements with custom namespaces or self-closing tags', () {
      final input = '<book:description>The Odyssey <br/> by Homer</book:description>';
      final expected = 'The Odyssey\nby Homer';
      expect(TextSanitizer.sanitize(input), equals(expected));
    });
  });
}
