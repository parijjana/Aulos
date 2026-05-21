import 'dart:io';
import 'package:drift/native.dart';
import 'package:localaudioplayer/data/database/discovery_database.dart';
import 'package:path/path.dart' as p;

void main() async {
  // 1. Locate the database
  // Note: On Windows, getApplicationDocumentsDirectory() usually points to Documents
  final dbPath = p.join(Platform.environment['USERPROFILE']!, 'Documents', 'discovery.sqlite');
  print('Checking database at: $dbPath');
  
  if (!File(dbPath).existsSync()) {
    print('ERROR: Database file not found!');
    return;
  }

  final db = DiscoveryDatabase(); // This will use the default _openConnection logic

  try {
    // 2. Count Total
    final all = await db.select(db.discoveredPodcasts).get();
    print('\nTOTAL PODCASTS IN DB: ${all.length}');

    // 3. Group by Category
    final relations = await db.select(db.discoveryCategoryRelations).get();
    final Map<String, int> counts = {};
    for (var r in relations) {
      counts[r.categoryId] = (counts[r.categoryId] ?? 0) + 1;
    }

    print('\nCOUNTS BY CATEGORY:');
    counts.forEach((cat, count) {
      print(' - $cat: $count');
    });

    // 4. Inspect Sample (Trending)
    final trendingIds = relations
        .where((r) => r.categoryId == 'trending')
        .map((r) => r.iTunesId)
        .take(5)
        .toSet();
    
    final trendingPodcasts = all.where((p) => trendingIds.contains(p.iTunesId)).toList();
    print('\nSAMPLE TRENDING:');
    for (var t in trendingPodcasts) {
      print(' - ${t.title} (ID: ${t.iTunesId})');
    }

  } catch (e) {
    print('ERROR: $e');
  } finally {
    await db.close();
    exit(0);
  }
}
