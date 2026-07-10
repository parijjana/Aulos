import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:aulos/data/database/discovery_database.dart';

void main() {
  late DiscoveryDatabase db;

  setUp(() {
    db = DiscoveryDatabase.testing(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DiscoveryDatabase Wikipedia Offline Summary Caching', () {
    test('should insert and retrieve a wikipedia summary by cacheKey', () async {
      // 1. Initially should return null
      final cacheKey = 'artist_john_doe';
      var cached = await db.getWikipediaSummary(cacheKey);
      expect(cached, isNull);

      // 2. Insert summary
      await db.insertWikipediaSummary(
        WikipediaSummariesCompanion.insert(
          cacheKey: cacheKey,
          query: 'John Doe',
          title: 'John Doe (Artist)',
          extract: 'John Doe was an artist who painted beautiful landscapes.',
          thumbnailUrl: const Value('https://example.com/john_doe.jpg'),
          pageUrl: const Value('https://en.wikipedia.org/wiki/John_Doe'),
        ),
      );

      // 3. Retrieve summary
      cached = await db.getWikipediaSummary(cacheKey);
      expect(cached, isNotNull);
      expect(cached!.cacheKey, cacheKey);
      expect(cached.query, 'John Doe');
      expect(cached.title, 'John Doe (Artist)');
      expect(cached.extract, 'John Doe was an artist who painted beautiful landscapes.');
      expect(cached.thumbnailUrl, 'https://example.com/john_doe.jpg');
      expect(cached.pageUrl, 'https://en.wikipedia.org/wiki/John_Doe');
      expect(cached.cachedAt, isNotNull);
    });

    test('should replace existing summary on duplicate cacheKey insert', () async {
      final cacheKey = 'author_jane_smith';
      
      await db.insertWikipediaSummary(
        WikipediaSummariesCompanion.insert(
          cacheKey: cacheKey,
          query: 'Jane Smith',
          title: 'Jane Smith (Author)',
          extract: 'Jane Smith wrote short stories.',
        ),
      );

      await db.insertWikipediaSummary(
        WikipediaSummariesCompanion.insert(
          cacheKey: cacheKey,
          query: 'Jane Smith',
          title: 'Jane Smith (Novelist)',
          extract: 'Jane Smith is an award-winning novelist.',
        ),
      );

      final cached = await db.getWikipediaSummary(cacheKey);
      expect(cached, isNotNull);
      expect(cached!.title, 'Jane Smith (Novelist)');
      expect(cached.extract, 'Jane Smith is an award-winning novelist.');
    });
  });
}
