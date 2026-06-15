import 'package:flutter_test/flutter_test.dart';
import 'package:aulos/core/utils/date_parser.dart';

void main() {
  group('date_parser - parseRfc822', () {
    test('should parse standard RFC 822 GMT dates', () {
      final date = parseRfc822('Wed, 04 Jun 2026 10:26:11 GMT');
      expect(date, isNotNull);
      expect(date!.year, 2026);
      expect(date.month, 6);
      expect(date.day, 4);
      expect(date.hour, 10 + date.timeZoneOffset.inHours); // adjusted for local timezone conversion
    });

    test('should parse dates with numeric offset (+0000)', () {
      final date = parseRfc822('Wed, 04 Jun 2026 10:26:11 +0000');
      expect(date, isNotNull);
      expect(date!.year, 2026);
      expect(date.month, 6);
      expect(date.day, 4);
    });

    test('should parse dates without day of week', () {
      final date = parseRfc822('04 Jun 2026 10:26:11 GMT');
      expect(date, isNotNull);
      expect(date!.year, 2026);
      expect(date.month, 6);
      expect(date.day, 4);
    });

    test('should parse dates with negative numeric offset (-0500)', () {
      final date = parseRfc822('Wed, 04 Jun 2026 10:26:11 -0500');
      expect(date, isNotNull);
      expect(date!.year, 2026);
      expect(date.month, 6);
      expect(date.day, 4);
    });

    test('should parse ISO 8601 fallback dates', () {
      final date = parseRfc822('2026-06-04T10:26:11.000Z');
      expect(date, isNotNull);
      expect(date!.year, 2026);
      expect(date.month, 6);
      expect(date.day, 4);
    });

    test('should return null for invalid dates', () {
      expect(parseRfc822(null), isNull);
      expect(parseRfc822(''), isNull);
      expect(parseRfc822('invalid-date-string'), isNull);
    });
  });
}
