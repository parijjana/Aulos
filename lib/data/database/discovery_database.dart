import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'discovery_database.g.dart';

class DiscoveredPodcasts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get iTunesId => text().unique()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get feedUrl => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get firstSeen => dateTime().withDefault(currentDateAndTime)();
}

class DiscoveredEpisodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get iTunesId => text().references(DiscoveredPodcasts, #iTunesId)();
  TextColumn get title => text()();
  TextColumn get audioUrl => text()();
  DateTimeColumn get pubDate => dateTime().nullable()();
}

class DiscoveryCategoryRelations extends Table {
  TextColumn get iTunesId => text().references(DiscoveredPodcasts, #iTunesId)();
  TextColumn get categoryId => text()();
  
  @override
  Set<Column> get primaryKey => {iTunesId, categoryId};
}

class DiscoveryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get lastRun => dateTime()();
  IntColumn get fetchCount => integer()();
  TextColumn get status => text()(); // e.g., 'success', 'failed'
}

@DriftDatabase(tables: [DiscoveredPodcasts, DiscoveredEpisodes, DiscoveryCategoryRelations, DiscoveryLogs])
class DiscoveryDatabase extends _$DiscoveryDatabase {
  DiscoveryDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        // Wipe cache on schema change for simplicity during rapid development
        await m.deleteTable(discoveryCategoryRelations.actualTableName);
        await m.deleteTable(discoveredEpisodes.actualTableName);
        await m.deleteTable(discoveredPodcasts.actualTableName);
        await m.deleteTable(discoveryLogs.actualTableName);
        
        await m.createTable(discoveredPodcasts);
        await m.createTable(discoveredEpisodes);
        await m.createTable(discoveryCategoryRelations);
        await m.createTable(discoveryLogs);
      }
    },
  );

  // Persistence Operations
  Future<void> upsertPodcasts(List<DiscoveredPodcastsCompanion> podcasts, String categoryId) async {
    await transaction(() async {
      for (var p in podcasts) {
        // 1. Insert/Update Podcast
        await into(discoveredPodcasts).insert(p, mode: InsertMode.insertOrReplace);
        
        // 2. Link to Category
        final id = p.iTunesId.value;
        await into(discoveryCategoryRelations).insert(
          DiscoveryCategoryRelationsCompanion.insert(
            iTunesId: id,
            categoryId: categoryId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> upsertEpisodes(List<DiscoveredEpisodesCompanion> episodes) async {
    await batch((b) {
      b.insertAll(discoveredEpisodes, episodes, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> clearAll() async {
    await delete(discoveryCategoryRelations).go();
    await delete(discoveredEpisodes).go();
    await delete(discoveredPodcasts).go();
    await delete(discoveryLogs).go();
  }

  Stream<List<DiscoveredEpisode>> watchEpisodes(String iTunesId) {
    return (select(discoveredEpisodes)
          ..where((t) => t.iTunesId.equals(iTunesId))
          ..orderBy([(t) => OrderingTerm.desc(t.pubDate)])
          ..limit(5))
        .watch();
  }

  Stream<DiscoveredPodcast?> watchByITunesId(String id) {
    return (select(discoveredPodcasts)..where((t) => t.iTunesId.equals(id))).watchSingleOrNull();
  }

  Stream<List<DiscoveredPodcast>> watchByCategory(String catId, {int limit = 50}) {
    final query = select(discoveredPodcasts).join([
      innerJoin(discoveryCategoryRelations, discoveryCategoryRelations.iTunesId.equalsExp(discoveredPodcasts.iTunesId)),
    ])
      ..where(discoveryCategoryRelations.categoryId.equals(catId))
      ..orderBy([OrderingTerm.desc(discoveredPodcasts.id)])
      ..limit(limit);

    return query.watch().map((rows) => rows.map((r) => r.readTable(discoveredPodcasts)).toList());
  }

  Future<List<DiscoveredPodcast>> getByCategory(String catId, {int limit = 20, int offset = 0}) async {
    final query = select(discoveredPodcasts).join([
      innerJoin(discoveryCategoryRelations, discoveryCategoryRelations.iTunesId.equalsExp(discoveredPodcasts.iTunesId)),
    ])
      ..where(discoveryCategoryRelations.categoryId.equals(catId))
      ..orderBy([OrderingTerm.desc(discoveredPodcasts.id)])
      ..limit(limit, offset: offset);

    final rows = await query.get();
    return rows.map((r) => r.readTable(discoveredPodcasts)).toList();
  }

  Future<List<DiscoveredPodcast>> search(String query, {int limit = 20, int offset = 0}) {
    return (select(discoveredPodcasts)
          ..where((t) => t.title.contains(query) | t.artist.contains(query))
          ..limit(limit, offset: offset))
        .get();
  }

  Future<DiscoveredPodcast?> getByITunesId(String id) {
    return (select(discoveredPodcasts)..where((t) => t.iTunesId.equals(id))).getSingleOrNull();
  }

  Future<DiscoveryLog?> getLastSuccessfulRun() {
    return (select(discoveryLogs)
          ..where((t) => t.status.equals('success'))
          ..orderBy([(t) => OrderingTerm.desc(t.lastRun)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> logRun(DateTime time, int count, String status) {
    return into(discoveryLogs).insert(
      DiscoveryLogsCompanion.insert(
        lastRun: time,
        fetchCount: count,
        status: status,
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'discovery.sqlite'));
    return NativeDatabase(file);
  });
}
